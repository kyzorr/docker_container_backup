########################################
#####  Universal Docker            #####
#####  Container Restore           #####
##### ---------------------------- #####
#####  Autor: kyzorr               #####
#####  Copyright: kyzorr           #####
#####  Writen by: kyzorr           #####
########################################

# Universaler Backup-Skript zum Sichern von Docker Container auf einen Lokalen Speicherort.
# Bitte die VARIABLEN nach wunsch anpassen. Anschließend die Datei unter 
# <appname-apptyp-backup_script.sh abspeichern. z.B. "wp-db_backup_script.sh"
# Crontab anpassung als root nicht vergessen!

#!/bin/bash

######################################
#####         VARIABLEN          #####
######################################

# Programm Name. Wird verwendet für Ordnername und Backup-Dateinamen.
# meist auch der containernamen
app_name="test"
# Programm Typ/Baustein. Z.B. app, db, admin etc.
app_typ="db"
# Pfad zum zu sichernden Ordner
source_dir="/var/lib/docker/volumes/>Container_Volume>/_data"
# Anzahl der Tage, nach denen alte Backups gelöscht werden sollen
days_to_keep=30


######################################
######################################
### Fix Variablen ###
# Verzeichnis, in dem die Backups gespeichert werden sollen
fq_app_name="$app_name-$app_typ"
backup_dir="/data/backup/$fq_app_name"
# Datum für das Backup-Dateinamen
#today=date +"%Y-%m-%d"
backup_date="backup_"$(date +"%Y-%m-%d")
# Backup-Dateinamen
backup_file="$backup_dir/$fq_app_name-$backup_date.tar.gz"
######################################

# Erstelle das Backup-Verzeichnis, falls es noch nicht existiert
mkdir -p "$backup_dir"
# Erstelle das Backup als TAR-Archiv
tar -czf "$backup_file" -C "$(dirname "$source_dir")" "$(basename "$source_dir")"

# Prüfe, ob das Backup erfolgreich erstellt wurde
if [ $? -eq 0 ]; then
    echo "[OK] Backup der $fq_app_name-App erfolgreich erstellt: $backup_file"
else
    echo "[FAILED] Fehler beim Erstellen des Backups der $fq_app_name-App."
    exit 1
fi

# Zähle die Anzahl der Backups
backup_count=$(ls -d "$backup_dir"/"$fq_app_name"* | wc -l)

# Lösche alte Backups, wenn die Anzahl der Backups größer als die Anzahl der Tage zum Aufbewahren ist
if [ "$backup_count" -gt "$days_to_keep" ]; then
    old_backups=$(ls -dt "$backup_dir"/"$fq_app_name"* | tail -n +"$((backup_count - days_to_keep + 1))")
    rm -rf $old_backups
    echo "Ältere Backups wurden gelöscht."
    echo $old_backups
fi
