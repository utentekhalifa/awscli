AWS CLI BASH 
ho definito questo semplice strumento basato su un menù interattivo con un case allo scopo di creare un server web e cancellazione risorse tramite l'aws cli.

FUNZIONALITA':
- Menù di selezione per la gestione degli input in base scelta
- Creazione di una EC2 semplice t2.micro, utilizzo del comando run con user-data con script per installazione e configurazione SSH e NGINX
- configurazione e creazione security-groups e porte, utilizzo della vpc di default anche se non è una best practies
- creazione dell'AMI associata all'istanza e conseguente creazione dello snapshot ebs in default (GP3)
- script per cancellazione delle risorse compresee eventuali create con più volte l'esecuzione delle scelte
- divisione delle varie parti in funzioni richiamate dallo script del menù per chiarezza e modularità del codice
- aggiunta del .git per versionamento e pratica su commenti, branch e versionamento locale
- creazione della repo git-hub per fare push degli aggiornamenti ma anche pull, questo per simulare un ambiente di lavoro reale e di lavoro su progetti in comune

RISORSE UTILIZZATE:
- Documentazione cli
- account AWS reale per verifica funzionamento
- youtube per logica e condizioni più complesse del codice
- conoscenza dell'infrastruttura aws appresa durante la preparazione e aver conseguito la AWS Solution Architect Associate

NOTE:

Questa esercitazione è stata fatta allo scopo di fare pratica e capire le funzionalità dell'aws cli, la documentazione, l'utilizzo di git e github e riprendere comandi linux e bash appresi in precedenza con riutilizzo del codice nell'user data del run instance. Il non aver terminato il menù non indica una dimenticanza o un non aver voluto terminare ma aver capito che la cli serve per automatizzare o gestire risorse mentre per creare anche in modo più complesso ci sono strumenti più adatti come cloudformation.

Volutamente non ho inserito delle branch protection roules poichè quelle necessarie in un progetto reale mi sono reso conto avrebbero impedito perfino l'aggiunta di aggiornamenti sul branch main. Questo progetto in fine mi ha fatto apprendere l'uso di condizioni, funzioni e di controllo di errori come ad esempio tramite un semplificato set -e negli eseguibili, interoperabilità del codice tramite il #!/usr/bin/env bash in modo tale da poterlo eseguire non solo su macchine linux, il settaggio della cli tramite chiavi associate a un user non root dell'account aws. 

ps. chiaramente ho testato il punto 1 e 5 che ho completato e fatto dei fix con semplice commento altrimenti il progetto non avrebbe avuto senso, tramite "meaningful commits" cioè standard semplici per l'aggiunta di aggiornamenti ai git add seguiti dai commit -m.

[![AWS Certified Solutions Architect – Associate](aws-certified-solutions-architect-associate.png)]([IL_TUO_LINK_CREDLY](https://www.credly.com/badges/84adf2b3-7281-4c3e-922a-4feeab1fac13/public_url))
