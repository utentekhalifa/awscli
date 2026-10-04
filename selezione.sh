#!/usr/bin/env bash
set -e

 # piuttosto che il solo bin/bash ciò permette la portabilità del codice a sistemi linux ma anche unix e il set -e termina lo script se ci sono errori e non continua lo script


# $USER_ATTIVO=$(aws sts get-caller-identity)
 #echo in questo momento l'utente e': $USER_ATTIVO 

 read -p "Vuoi proseguire con lo script? (s/n): " ATTESA

if [ "$ATTESA" = "s" ]; then

	echo "							           "
	echo "	         	        	           _ _             "
	echo "		        	                  | (_)            "
	echo "			  __ ___      _____    ___| |_             "
	echo "			 / _  \ \ /\ / / __|  / __| | |            "
	echo "			| (_| |\ V  V /\__ \ | (__| | |            "
	echo "			 \__ _| \_/\_/ |___/  \___|_|_|            "
        echo "								   "
                               
        echo "         ___________________________________________________________"                       

	echo "              MENU' DI SELEZIONE PROGETTO AUTOMAZIONE AWS CLI    "

	echo "         -----------------------------------------------------------"
	
	echo " "
	echo " "
	echo "   1) Creazione del solo server web e creazione dell'AMI di backup    "
 	echo "   2) backup dei log utilizzando lo script creato durante studio linux"
	echo "   3) creazione di un sito statico, CDN, DNS e utilizzo HTTPS invece di HTTP"
	echo "   4) upload forzato con chache invalidation per aggiornamento feature sito urgente "
	echo "   5) upload di file su s3 "
	echo "   6) cancellazione delle risorse							"
	echo " "
	echo "	 ps. l'utilizzo della cli ha l'obiettivo di automatizzare un compito ripetitivo o immediatamente applicabile" 
	
	echo " "

	server_web(){

            echo "=== 1. CREAZIONE SECURITY GROUP ==="

            # Creiamo il Security Group e salviamo l'ID
            # 2>/dev/null nasconde l'errore se esiste già, || true evita che lo script si blocchi perchè ho utilizzato il set -e
 
           SG_ID=$(aws ec2 create-security-group \
                --group-name "sg-webserver" \
                --description "SECURITY GROUP per SSH e HTTP" \
                --query 'GroupId' \ 
                --output text 2>/dev/null || true)

            # Apro la porta 22 (SSH) e la porta 80 (HTTP) da qualsiasi IP, le security group sono statefull quindi se faccio "l'allow" come regola outbound o inbound sarà vero anche il contrario

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

            echo "=== 2. LANCIO ISTANZA EC2 CON USER-DATA ==="

            # faccio il run dell'istanza passando lo User Data aggiornato, recuperando da console l'immagine corretta della t2.micro disponibile per il free tier,
            #l'intenzione è riutilizzare perte del codice utilizzato da una mia esercitazione precedente per una VM locale ubuntu server disponibile in una repo che ho creato
	    # 


            INSTANCE_ID=$(aws ec2 run-instances \
                --image-id ami-0c7217cdde317cfec \
                --instance-type t2.micro \
                --associate-public-ip-address \
                --security-group-ids "$SG_ID" \

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
                --output text) #qui termina il comando del run instance

            echo "Attesa che l'istanza ($INSTANCE_ID) sia in stato 'running'..."
            aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

            # recupero l'IP pubblico assegnato, in questo caso per dimostrare la funzionalità del codice, cioè
	    # non utilizzare un elastic ip e quindi un indirizzo fisso è accettabile anche perchè non utilizzo neanche il DNS
 
            PUBLIC_IP=$(aws ec2 describe-instances \
                --instance-ids "$INSTANCE_ID" \
                --query 'Reservations[0].Instances[0].PublicIpAddress' \
                --output text)

            echo "Server avviato! l'IP Pubblico al momento della creazione e' : http://$PUBLIC_IP"

            echo "=== 3. CREAZIONE AMI DI BACKUP ==="

            # Creo l'AMI di backup partendo dall'istanza configurata

            AMI_ID=$(aws ec2 create-image \
                --instance-id "$INSTANCE_ID" \
                --name "backup-webserver-$(date +%Y%m%d)" \
                --description "AMI di backup del server web con Nginx e SSH" \
                --query 'ImageId' \
                --output text)

            echo "AMI di backup creata con successo: $AMI_ID"
            ;;
}

	echo " "
#		read -p "che cosa scegli [1-6] ? ricorda di eseguire la cancellazione per non avere costi extra: " INPUT
#		case "$INPUT" in
#		1)
#		2)
#		3)
#		4)
#		5)
#		6)
#		*)
#		esac
#		else
#		fi
#
#


else 
        echo " ---------------------------------------------------------------------------------------"
        echo " "
	echo "hai scelto un input diverso, termine dello script, per riprovare eseguire ./selezione.sh ."
	echo " "
	echo "----------------------------------------------------------------------------------------"
	exit 1
fi 

