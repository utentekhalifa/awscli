#!/bin/bash 


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
                               
        echo "     ___________________________________________________________"                       

	echo "              MENU' DI SELEZIONE PROGETTO AUTOMAZIONE AWS CLI    "

	echo "         -----------------------------------------------------------"
	
	echo " "
	echo " "
	echo "   1) Creazione del solo server web e creazione dell'AMI di backup    "
 	echo "   2) backup dei log utilizzando lo script creato durante studio linux"
	echo "   3) creazione di un sito statico, CDN, DNS e utilizzo HTTPS invece di HTTP"
	echo "   4) upload forzato con chache invalidation per aggiornamento feature sito urgente "
	echo "   5) upload di file su s3
	echo "   6) cancellazione delle risorse							"
	echo " "
	echo "	 ps. l'utilizzo della cli ha l'obiettivo di automatizzare un compito ripetitivo o immediatamente applicabile" 
	
	echo " "
	echo " "
		read -p "che cosa scegli [1-6] ? ricorda di eseguire la cancellazione per non avere costi extra: " INPUT
		case "$INPUT" in
		1)
		2)
		3)
		4)
		5)
		6)
		*)
		esac
		else
		fi




else 
        echo " ---------------------------------------------------------------------------------------"
        echo " "
	echo "hai scelto un input diverso, termine dello script, per riprovare eseguire ./selezione.sh ."
	echo " "
	echo "----------------------------------------------------------------------------------------"
	exit 1
fi 

