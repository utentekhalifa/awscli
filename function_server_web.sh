#!/usr/bin/env bash
set -e


function_server_web() {

            # Creiamo il Security Group e salviamo l'ID, per semplicità utilizzo la vpc di default anche se una delle best practice è la creazione di una propria vpc 
            # con subnet e relative security groups e routing tables
            # 2>/dev/null nasconde l'errore se esiste già, || true evita che lo script si blocchi perchè ho utilizzato il set -e    

           #Cerca l'ID usando i filtri (non restituisce errore se non lo trova)
            SG_ID=$(aws ec2 describe-security-groups \
            --filters "Name=group-name,Values=ilmiglioresecuritygroup" \
            --query 'SecurityGroups[0].GroupId' \
            --output text 2>/dev/null || true)

            #Se SG_ID è vuoto oppure restituisce "None", crea il Security Group
        if [ -z "$SG_ID" ] || [ "$SG_ID" = "None" ]; then
             echo "Security Group non trovato. Creazione di 'ilmiglioresecuritygroup' in corso..."
            SG_ID=$(aws ec2 create-security-group \
            --group-name "ilmiglioresecuritygroup" \
            --description "security group per SSH e HTTP" \
            --query 'GroupId' \
            --output text)

            echo "Aggiunta possibilità di accesso a SSH (22) e HTTP (80)"
        aws ec2 authorize-security-group-ingress \
            --group-id "$SG_ID" \
            --protocol tcp \
            --port 22 \
            --cidr 0.0.0.0/0 2>/dev/null || true

        aws ec2 authorize-security-group-ingress \
            --group-id "$SG_ID" \
            --protocol tcp \
            --port 80 \
            --cidr 0.0.0.0/0 2>/dev/null || true

        else
            echo "Security Group 'ilmiglioresecuritygroup' già esistente con ID: $SG_ID"
        fi

            echo "--- 2. LANCIO DELL'ISTANZA EC2 CON USER-DATA ---"

            #faccio il run dell'istanza passando lo User Data aggiornato, recuperando da console l'immagine corretta della t2.micro disponibile per il free tier, di default
            #per una istanza del genere viene associato un volume basico gp2/gp3 con 8gb di memoria sufficienti per questo progetto ma anch'esso configurabile all'occorrenza,
            #l'intenzione è riutilizzare perte del codice utilizzato da una mia esercitazione precedente per una VM locale ubuntu server disponibile in una repo che ho creato
	    


            INSTANCE_ID=$(aws ec2 run-instances \
                --image-id ami-0b6d9d3d33ba97d99 \
                --instance-type t2.micro \
                --associate-public-ip-address \
                --security-group-ids "$SG_ID" \
                --user-data '#!/usr/bin/env bash
                             set -e

                    echo "AVANZAMENTO 1 DI 3: verifica aggiornamenti in corso..."
                    apt-get update -y && apt-get upgrade -y

                    echo "AVANZAMENTO 2 DI 3: verifica presenza servizi SSH e Nginx..."
                    if command -v sshd &> /dev/null; then
                        echo "SSH presente sul sistema, avvio e abilitazione..."
                        systemctl start ssh
                        systemctl enable ssh
                    else 
                        echo "Servizio SSH non trovato, installazione..."
                        apt-get install openssh-server -y
                        systemctl start ssh
                        systemctl enable ssh 
                    fi
		
                    if command -v nginx &> /dev/null; then
                        echo "Nginx presente sul sistema, avvio e abilitazione..."
                        systemctl start nginx
                        systemctl enable nginx
                    else 
                        echo "Servizio Nginx non trovato, installazione..."
                        apt-get install nginx -y
                        systemctl start nginx
                        systemctl enable nginx
                    fi 

                    echo "AVANZAMENTO 3 DI 3: verifica funzionamento Nginx e SSH..."
                    if systemctl is-active --quiet nginx; then
                        echo "Nginx: ATTIVO"
                    else
                        echo "Nginx: IN ERRORE O DISABILITATO"
                    fi  

                    if systemctl is-active --quiet ssh; then 
                        echo "SSH: ATTIVO"   
                    else 
                        echo "SSH: IN ERRORE O DISABILITATO"  
                    fi  

                    echo "----------------------------------------------------------------------------------"
                    echo "Inizializzazione completata."
                ' \
                --query 'Instances[0].InstanceId' \
                --output text) 
            # qui termina la fase del run intance 

            echo "Attesa che l istanza ($INSTANCE_ID) sia in stato running"
            aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

            # recupero l'IP pubblico assegnato, in questo caso per dimostrare la funzionalità del codice, cioe'
	        # non utilizzare un elastic-ip e quindi un indirizzo fisso è accettabile anche perchè non utilizzo neanche il DNS
 
            PUBLIC_IP=$(aws ec2 describe-instances \
                --instance-ids "$INSTANCE_ID" \
                --query 'Reservations[0].Instances[0].PublicIpAddress' \
                --output text)

            echo "Server avviato! l'IP Pubblico al momento della creazione e' : http://$PUBLIC_IP"

            echo "=== 3. CREAZIONE AMI DI BACKUP ==="

            # Creo l'AMI di backup partendo dall'istanza configurata, per ipotizzare un utilizzo periodico e comune per altri progetti di questo server 
            # quindi ciò fa lo snapshot del vulume EBS sottostante + i metadata dell'immagine ubuntu, e fatta al momento della creazione per non includere
            # dati successivi alla creazione dovuti all'utilizzo dell'istanza (es. anche i log di accesso http e ssh)

            AMI_ID=$(aws ec2 create-image \
                --instance-id "$INSTANCE_ID" \
                --name "backup-webserver-$(date +%Y%m%d)" \
                --description "AMI di backup del server web con Nginx e SSH" \
                --query 'ImageId' \
                --output text)

            echo "AMI di backup creata con successo: $AMI_ID"
            

        }