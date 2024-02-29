########################################
#####  Universal Docker            #####
#####  Container Restore           #####
##### ---------------------------- #####
#####  Autor: Michael Smuda        #####
#####  Copyright: Tap Holding      #####
#####  Writen by: ChatGTP, M.Smuda #####
#####  Version: 0.2                #####
########################################

# Universaler Restore-Skript zum Wiederherstellen von Docker Container aus einen Lokalen Speicherort.
# Bitte die VARIABLEN nach wunsch anpassen. Anschließend die Datei unter 
# <appname-restore_script.sh abspeichern. z.B. "vaultwarden_restore_script.sh"
# Dieser kann anschließend wie folgt gestartet werden: "sh vaultwarden_restore_script.sh"

#!/bin/bash

# Programm Name. Wird verwendet für Ordnername und Backup-Dateinamen.
# meist auch der containernamen
app_name="test"
# Programm Typ/Baustein. Z.B. app, db, admin etc.
app_typ="app"
sql_typ


# Zielverzeichnis, in das das Backup wiederhergestellt werden soll
restore_dir_app="/var/lib/docker/volumes/vaultwarden_restore_vaultwarden_vol_restore"
restore_dir_db="/var/lib/docker/volumes/vaultwarden_restore_mariadb_vol_restore"

# Präfix hinterlegung wie im jeweiligen Backup-Skript definiert
# Nur ändern wenn nötig!!!
file_prefix_app="vw_backup"
file_prefix_db="vw-sql_backup"
# Container Namen
container_app="restore_vaultwarden"
container_db="restore_mariadb_vw"

###########################################
##### Static Variable. Nicht ändern!  #####
###########################################
# Verzeichnis, in dem die Backups gespeichert sind
fq_app_name="$app_name-$app_typ"
backup_dir="/data/backup/$fq_app-name"
backup_dir_app="/data/backup/$app_name-app"
backup_dir_db="/data/backup/$app_name-db"
selected_backup_app=""
selected_backup_db=""
# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White
# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

NC='\033[0m' 			  # No Color
##########################################

# Funktion zur Anzeige der verfügbaren Backups
list_backups() {
	echo ""
	echo "${BCyan}Auflistung aller verfügbaren Backups${NC}"
	echo ""
	echo "Backup $fq_app_name App:"
    ls -alh "$backup_dir_app" | grep '.tar' | awk '{print $NF}'
	echo ""
	echo ""
	echo "Backup $fq_app_name DB:"
    ls -alh "$backup_dir_db" | grep '.tar' | awk '{print $NF}'
	return;
}

# Funktion zur Wiederherstellung eines ausgewählten Backups
restore_backup() {
	clear
	echo "Gewählt wurde 2: Backup Wiederherstellung"
	list_backups
	echo ""
    echo "${BCyan}Geben Sie das ${BYellow}DATUM (JJJJ-MM-TT) ${BCyan}des Backups ein, das Sie wiederherstellen möchten:"
	#echo "Schreibweise: JJJJ-MM-TT  Beispiel: 2023-12-30"
	read -r selected_date
	selected_backup_app="$file_prefix_app-$selected_date.tar.gz"
	selected_backup_db="$file_prefix_db-$selected_date.tar.gz"
	echo "${NC}"
    # Überprüfe, ob das ausgewählte Backup vorhanden ist
    if [ -f "$backup_dir_app/$selected_backup_app" ] && [ -f "$backup_dir_db/$selected_backup_db" ]; 
	then
        echo "Wiederherstellung der Backups:"
		echo ""
		echo "-------------------------------"
		echo "$selected_backup_app"
		echo "$selected_backup_db"
		echo "-------------------------------"
		echo ""
		echo "Restore wird vorbereitet. "
		if [ "$(docker ps -a -q -f name=$container_app)" ]; then 
			if [ "$(docker ps -aq -f status=running -f name=$container_app)" ]; then
				echo "Container $container_app wird gestoppt"
				docker stop $container_app
				until [ "`docker ps -aq -f status=exited -f name=$container_app`"=="true" ]; do
				sleep 1;
				done;
				echo "${Green}Container $container_app gestoppt!${NC}"
			fi
			if [ "$(docker ps -aq -f status=running -f name=$container_db)" ]; then
				echo "Container $container_db wird gestoppt"
				docker stop $container_db 
				until [ "`docker ps -aq -f status=exited -f name=$container_db`"=="true" ]; do
				sleep 1;
				done;
				echo "${Green}Container $container_db gestoppt!${NC}"
			fi 
		else 
		echo "${Yellow}Übersprungen. Container $container_app läuft nicht!" 
		echo "Übersprungen. Container $container_db läuft nicht!${NC}"
		fi
			# Lösche das Zielverzeichnis, bevor das Backup wiederhergestellt wird
			echo "Alte Daten werden bereinigt..."
			rm -rf "$restore_dir_app" "$restore_dir_db"
			echo "Ordner werden angelegt..."
			mkdir -p "$restore_dir_app" "$restore_dir_db"
			# Kopiere den Inhalt des ausgewählten Backups in das Zielverzeichnis
			echo "Dateien werden kopiert... "
			tar -xf "$backup_dir_app/$selected_backup_app" -C "$restore_dir_app"
			tar -xf "$backup_dir_db/$selected_backup_db" -C "$restore_dir_db"
			echo "${Green}Wiederherstellung abgeschlossen.${NC}"
			echo "Restore-Container werden gestartet..."
			#Erste die Datenbank starten, wenn hochgefahren, die App
			docker start $container_db
			until [ "`docker ps -aq -f status=running -f name=$container_db`"=="true" ]; do
			sleep 1;
			done;
			docker start $container_app
			until [ "`docker ps -aq -f status=running -f name=$container_app`"=="true" ]; do
			sleep 1;
			done;
			echo "${Green}Container gestartet."
			echo ""
			echo "${BGreen}#########################################"
			echo "###                                   ###"
			echo "### Restore Erfolgreich abgeschlossen ###"			
			echo "###                                   ###"
			echo "######################################### ${NC}"
			echo ""
			echo "Bitte rufen Sie die Webseite ${BCyan}https://vw_restore.tap.intern/ ${NC} auf um auf den Restore zuzugreifen."
			echo "Bitte nutzen Sie zum Login die eigenen Zugangsdaten."
			echo ""
			echo "${NC}"
			exit 1
		else
			echo "${BRed}Das ausgewählte Backup existiert nicht."
			ls -alh "$restore_dir_app" | grep '.tar' | awk '{print $NF}'
			ls -alh "$restore_dir_db" | grep '.tar' | awk '{print $NF}'
			echo "${NC}"
		    #exit 1
	fi
}
# Funktion zur Wiederherstellung eines ausgewählten Backups
clear_restore_container() {
	clear
	echo "Gewählt wurde 4: Löschen der Restore Container Daten"
	echo ""
	echo "${BRed} Soll wirklich gelöscht werden? [ja/nein] Danach ist nur ein Restore aus über Punkt 2 möglich!"
	read -r  q_delete
	if [ "q_delete"=="ja" ]; then
		echo "Hinweis: Es werden nur die Daten gelöscht, die Container bleiben enthalten."
		echo ""
		if [ "$(docker ps -a -q -f name=$container_app)" ]; then 
			if [ "$(docker ps -aq -f status=running -f name=$container_app)" ]; then
				echo "Container $container_app wird gestoppt"
				docker stop $container_app
				until [ "`docker ps -aq -f status=exited -f name=$container_app`"=="true" ]; do
				sleep 1;
				done;
				echo "${Green}Container $container_app gestoppt!${NC}"
			fi
			if [ "$(docker ps -aq -f status=running -f name=$container_db)" ]; then
				echo "Container $container_db wird gestoppt"
				docker stop $container_db 
				until [ "`docker ps -aq -f status=exited -f name=$container_db`"=="true" ]; do
				sleep 1;
				done;
				echo "${Green}Container $container_db gestoppt!${NC}"
			else 
				echo "${Yellow}Übersprungen. Container $container_app läuft nicht!" 
				echo "Übersprungen. Container $container_db läuft nicht!${NC}"
			fi
			
		rm -rf "$restore_dir_app" "$restore_dir_db"
		echo "${BGreen}Alle Daten von $container_app und $container_db wurden erfolgreich gelöscht.${NC}"
		else
		echo ""
		echo "Es wurden keine Dateien Gelöscht"
		echo ""
		fi
	fi
}
stop_restore_container() {
	clear
	echo "Gewählt wurde 3: Stoppen aller Restore Container"
	echo ""
	echo "${BRed} Soll wirklich alle Restore Container gestoppt werden? [ja/nein]"
	read -r  q_stop
	if [ "q_stop"=="ja" ]; then
		echo "Hinweis: Es werden nur die Daten gelöscht, die Container bleiben enthalten."
		echo ""
		if [ "$(docker ps -a -q -f name=$container_app)" ]; then 
			if [ "$(docker ps -aq -f status=running -f name=$container_app)" ]; then
				echo "Container $container_app wird gestoppt"
				docker stop $container_app
				until [ "`docker ps -aq -f status=exited -f name=$container_app`"=="true" ]; do
				sleep 1;
				done;
				echo "${Green}Container $container_app gestoppt!${NC}"
			fi
			if [ "$(docker ps -aq -f status=running -f name=$container_db)" ]; then
				echo "Container $container_db wird gestoppt"
				docker stop $container_db 
				until [ "`docker ps -aq -f status=exited -f name=$container_db`"=="true" ]; do
				sleep 1;
				done;
				echo "${Green}Container $container_db gestoppt!${NC}"
			else 
				echo "${Yellow}Übersprungen. Container $container_app läuft nicht!" 
				echo "Übersprungen. Container $container_db läuft nicht!${NC}"
			fi
		echo "${BGreen}Container $container_app und $container_db wurden erfolgreich gestoppt.${NC}"
		fi
	fi
	echo ""
	echo ""
}

# Hauptmenü
clear
while true; do
echo "${BPurple}Willkommen zum Backup-Wiederherstellungsprogramm für $fq_app_name"
echo "---------------------------------------------- ${NC}"
echo "${BICyan}Was möchten Sie tun?${NC}"
echo ""
echo "${BWhite}1. Verfügbare Backups anzeigen"
echo ""
echo "${BWhite}2. Backup aus Datei wiederherstellen"
echo ""
echo "${BWhite}3. Container manuell stoppen"
echo ""
echo "${BWhite}4. Restore-Daten manuell bereinigen"
echo ""
echo "${White}0. Beenden"
echo ""
echo ""

read -r choice
	case $choice in
		1)
			list_backups
			;;
		2)
			restore_backup
			;;
		3)
			stop_restore_container
			;;	
		4)
			clear_restore_container
			;;
		0)
			echo "Programm wird beendet."
			exit 0
			;;
		*)	
			echo ""
			echo ""
			echo "${BRed}Ungültige Eingabe. Bitte wählen Sie eine der verfügbaren Optionen.${NC}"
			echo ""
			echo ""
			;;
	esac
done

# Folgende Änderungen müssen druchgeführt werden wenn keine Externe DB Vorhanden ist:
# Auskommentieren: 15,18,23,26,64-65,79,88,101-108, 121, 125-128, 149, 173-179,182,212-218
# Anpassen: 82, 115, 117, 141, 186,223 