#!/usr/bin/env bash
set -e

function_delete_resources(){
            echo "--- INIZIO CANCELLAZIONE COMPLETA DELLE RISORSE ---"

            # 1. Recupero ed eliminiamo le istanze EC2 associate al Security Group "ilmiglioresecuritygroup" 

            echo "1. Ricerca ed eliminazione istanze EC2..."
            INSTANCE_IDS=$(aws ec2 describe-instances \
                --filters "Name=instance-state-name,Values=pending,running,stopping,stopped" \
                --query 'Reservations[*].Instances[*].InstanceId' \
                --output text)

            if [ -n "$INSTANCE_IDS" ] && [ "$INSTANCE_IDS" != "None" ]; then  #
                echo "Terminazione istanza/e EC2: $INSTANCE_IDS"
                aws ec2 terminate-instances --instance-ids $INSTANCE_IDS > /dev/null
                echo "Attesa che l'istanza sia completamente terminata..."
                aws ec2 wait instance-terminated --instance-ids $INSTANCE_IDS
                echo "Istanza/e eliminate con successo."
            else
                echo "Nessuna istanza EC2 trovata."
            fi

            # 2. Annullo la registrazione dell'AMI di backup (ricercata per nome "backup-webserver-*")
            echo "2. Ricerca ed eliminazione AMI di backup..."
            AMI_IDS=$(aws ec2 describe-images \
                --owners self \
                --filters "Name=name,Values=backup-webserver-*" \
                --query 'Images[*].ImageId' \
                --output text)

            if [ -n "$AMI_IDS" ] && [ "$AMI_IDS" != "None" ]; then
                for AMI in $AMI_IDS; do
                    echo "Annullamento registrazione AMI (Deregister): $AMI"
                    aws ec2 deregister-image --image-id "$AMI"
                done
            else
                echo "Nessuna AMI di backup trovata."
            fi

            # 3. Elimino lo Snapshot EBS (creato dall'AMI di backup)
            echo "3. Ricerca ed eliminazione Snapshot EBS..."
            SNAP_IDS=$(aws ec2 describe-snapshots \
                --owner-ids self \
                --query 'Snapshots[*].SnapshotId' \
                --output text)

            if [ -n "$SNAP_IDS" ] && [ "$SNAP_IDS" != "None" ]; then
                for SNAP in $SNAP_IDS; do
                    echo "Eliminazione Snapshot EBS: $SNAP"
                    aws ec2 delete-snapshot --snapshot-id "$SNAP" 2>/dev/null || true
                done
            else
                echo "Nessuno Snapshot EBS trovato."
            fi

            # 4. Elimino il Security Group chiamato "ilmiglioresecuritygroup"
            echo "4. Eliminazione Security Group 'ilmiglioresecuritygroup'..."
            SG_ID=$(aws ec2 describe-security-groups \
                --group-names "ilmiglioresecuritygroup" \
                --query 'SecurityGroups[0].GroupId' \
                --output text 2>/dev/null || true)

            if [ -n "$SG_ID" ] && [ "$SG_ID" != "None" ]; then
                aws ec2 delete-security-group --group-id "$SG_ID" 2>/dev/null || true
                echo "Security Group ($SG_ID) eliminato."
            else
                echo "Security Group 'ilmiglioresecuritygroup' non trovato."
            fi

            echo "----------------------------------------------------"
            echo "CANCELLAZIONE COMPLETA EFFETTUATA CON SUCCESSO!"
            echo "----------------------------------------------------"
        }