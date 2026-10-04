#!/usr/bin/env bash
set -e

 # piuttosto che il solo bin/bash ciò permette la portabilità del codice a sistemi linux ma anche unix e il set -e termina lo script se ci sono errori e non continua lo script

 #l'opzione get-caller-identity che si trova nella documentazione ufficiale aws, permette di avere nello specifico l'utente attuale come se in locale oppure quando
 #faccio un collegamento SSH digito il 'whoami'
 #si potrebbe usare anche un list-users per sapere in particolare con una query specifica elementi di interesse
 # $USER_ATTIVO=$(aws sts get-caller-identity)
 #echo in questo momento l'utente e': $USER_ATTIVO 

 # Configurazione Regione aws per portabilità del codice, per avere sempre concordanza tra l'ami inserita nella parte run-intance e la regione di appartenenza
 export AWS_DEFAULT_REGION="eu-central-1"

    # Carico le funzioni in memoria, inserirle in questo script completamente avrebbe reso il codice lungo e illegibile
    source ./function_server_web.sh
    source ./function_cleanup.sh
 
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
	echo "	 ps. l'utilizzo della cli ha l'obiettivo di automatizzare un compito ripetitivo o immediatamente applicabile, questo script utilizza competenze apprese "
    echo "   durante lo studio linux con riutilizzo del codice ma anche comandi presenti nella documentazione ufficiale aws.                                        " 
	
	echo " "  


	echo " "
    	read -p "che cosa scegli [1-6] ? ricorda di eseguire la cancellazione per non avere costi extra" INPUT
    	case "$INPUT" in
    	1 ) 
            function_server_web() ;;
    	2 ) 
            function_delete_resources() ;;
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

