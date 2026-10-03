#!/usr/bin/env bash 
# BATOCERA - SWITCH ADD-ON: INSTALL
export DISPLAY=:0.0
reset
clear

VERSION_FILE="/userdata/DreamerCGToolBox/version-toolbox.txt"
VERSION_URL="https://raw.githubusercontent.com/DreamerCG/dcgtoolbox/refs/heads/main/version-toolbox.txt"

# Cas 1 : fichier de version absent → installation
if [ ! -f "$VERSION_FILE" ]; then
    echo "Aucune version détectée, installation de la Toolbox…"
	
	DISPLAY=:0.0 xterm -fs 12 -maximized -fg white -bg black \
	-fa "DejaVuSansMono" -en UTF-8 \
	-e bash -c '
	echo
	echo "========================================="
	echo "   🔧 Mise à jour de DreamerCG Toolbox   "
	echo "========================================="
	echo
	curl -k -sL https://dreamercg.s.gy/switch | bash
	curl -sL https://raw.githubusercontent.com/DreamerCG/dcgtoolbox/main/app/dcg_service_update.sh | bash
	echo
	echo "========================================="
	echo "   🔄 Redémarrage EmulationStation       "
	echo "========================================="
	sleep 2
	killall xterm
	'

 
fi

# Lecture version locale
read -r toolbox_current_version < "$VERSION_FILE"

# Lecture version distante (sans écrire sur disque)
toolbox_download_version=$(curl -sL "$VERSION_URL")

# Sécurité : si curl échoue
if [ -z "$toolbox_download_version" ]; then
    echo "Impossible de récupérer la version distante"
    # exit 1
fi

# Comparaison
if [ "$toolbox_current_version" != "$toolbox_download_version" ]; then
    echo "Mise à jour détectée ($toolbox_current_version → $toolbox_download_version)"

	DISPLAY=:0.0 xterm -fs 12 -maximized -fg white -bg black \
	-fa "DejaVuSansMono" -en UTF-8 \
	-e bash -c '
	echo
	echo "========================================="
	echo "   🔧 Mise à jour de DreamerCG Toolbox   "
	echo "========================================="
	echo
	curl -k -sL https://dreamercg.s.gy/switch | bash
	echo
	echo "========================================="
	echo "   🔄 Redémarrage EmulationStation       "
	echo "========================================="
	sleep 2
	killall xterm
	'

else
    echo "Toolbox déjà à jour (version $toolbox_current_version)"
fi



# THIS SCRIPT
this_script_file="${0##*/}"
this_script_file_name="${this_script_file%.*}"
this_script_file_ext="${this_script_file##*.}"


# MAKES EXECUTABLE
dos2unix *.sh 2>>/dev/null
chmod a+x *.sh 2>>/dev/null
dos2unix *.py 2>>/dev/null
chmod a+x *.py 2>>/dev/null

# GLOBAL VARIABLES
source bsa-variables.sh

# GLOBAL FUNCTIONS
source bsa-functions.sh

# ******************************************************************************
# CHECK SYSTEM BEFORE PROCEEDING
# ******************************************************************************
if [[ "$(uname -a | grep "x86_64")" = "" ]]; then
	message "both" "$addon_log" "ERROR :: SYSTEM NOT SUPPORTED :: INSTALLATION ABORTED!" ""
	exit 0
fi


# PURGE INSTALLATION LOG FILE
purge_install_log() {
	rm "$addon_log" 2>>"$stderr_log"
	message "log" "$addon_log" "-=[ BATOCERA :: SWITCH // ADD-ON :: LOG }]=-\n"
	message "log" "$addon_log" " -------------------" "[$(date +"%Y/%m/%d %H:%M:%S")]" " -------------------"
}


# ******************************************************************************
# INTERNET CONNECTION SETUP
# ******************************************************************************
sysctl -w net.ipv6.conf.default.disable_ipv6=1 1>/dev/null 2>>"$stderr_log"
sysctl -w net.ipv6.conf.all.disable_ipv6=1 1>/dev/null 2>>"$stderr_log"


# ******************************************************************************
# INSTALLATION FUNCTIONS
# ******************************************************************************
# INITIALLIZATION FUNCTIONS (SETUP COMMON & EMULATOR SPECEFIC STRUCTURES [PRE-INSTALL])
source bsa-initialize.sh

# INSTALL EMULATORS FUNCTIONS
source bsa-emulators.sh

# UNPACK PACKAGES FUNCTIONS
source bsa-packages.sh

# POST INSTALL FUNCTIONS
source bsa-post.sh

# UNINSTALL FUNCTIONS
source bsa-uninstall.sh

# FULL INSTALL EMULATOR
full_install() {
	local emu="${1,,}";
	"initialize_${emu}"			# Setup directory structures
	"install_emulator_${emu}"	# Install Emulator (AppImage)
	"unpack_packages_${emu}"	# Install Required Libraries 
	"post_install_${emu}"		# Post Installation Processes
}

# UPDATE APPIMAGE
update_emulator() {
	local emu="${1,,}"
	local update_type="${2:-local}"
	update_type="${update_type,,}"
	local -n emu_file="${emu}_install_file"

	message "log" "$addon_log" "<<< [ UPDATE ${emu^^} ]>>>"
	# if remote update and AppImage in BSA then rename it
	if [ "$update_type" = "remote" ]; then
		local backup_file="$(rename_file_with_timestamp "$switch_install_emus_dir/$emu_file")"
		if [ "$backup_file" != "" ]; then
			message "log" "$addon_log" "${emu^^} APPIAMGE BACKED UP TO: $backup_file"
		fi
	fi

	# Re-install the emulator
	"initialize_${emu}"
	"install_emulator_${emu}"
	
}

# ******************************************************************************
# FUNCTIONS FOR SAVES BACKUP
# ******************************************************************************

	# BACKUP RYUJINX SAVES
	backup_saves_ryujinx() {
		local save_file="$switch_saves_dir/saves-ryujinx_$(date +"%Y%m%d_%H%M%S").zip"
		zip_it "$ryujinx_config_nand_dir" "$save_file"
		message "both" "$addon_log" "Ryujinx Saves completed: $save_file"
		message "both" "$addon_log" " from $ryujinx_config_nand_dir"
	}

	# BACKUP YUZU SAVES
	backup_saves_yuzu() {
		local save_file="$switch_saves_dir/saves-yuzu_$(date +"%Y%m%d_%H%M%S").zip"
		zip_it "$yuzu_config_nand_dir" "$save_file"
		message "both" "$addon_log" "Yuzu Saves completed"	
		message "both" "$addon_log" "from $yuzu_config_nand_dir"	
	}
	
	# Backup des mods dans yuzu_mods_backup_dir 
	backup_mods_yuzu() {
		local save_mod_file="$switch_saves_dir/mods-yuzu_$(date +"%Y%m%d_%H%M%S").zip"
		zip_it "$yuzu_mods_dir" "$save_mod_file"
		# cp -r "$yuzu_mods_dir"/* "$yuzu_mods_temp_dir"/ 2>>"$stderr_log"
		message "both" "$addon_log" "Mods Yuzu moved to: $yuzu_mods_temp_dir"
	}

	# Backup des mods dans yuzu_mods_backup_dir 
	backup_mods_ryujinx() {
		local save_mod_file="$switch_saves_dir/mods-ryujinx_$(date +"%Y%m%d_%H%M%S").zip"
		zip_it "$ryujinx_mods_dir" "$save_mod_file"		
		# cp -r "$ryujinx_mods_dir"/* "$ryujinx_mods_temp_dir"/ 2>>"$stderr_log"
		message "both" "$addon_log" "Mods Ryujinx moved to: $ryujinx_mods_temp_dir"
	}


	# Backup des mods dans yuzu_mods_backup_dir 
	move_mods_yuzu() {
		mkdir -p "$yuzu_mods_temp_dir"
		mv "$yuzu_mods_dir"/* "$yuzu_mods_temp_dir"/ 2>>"$stderr_log"
		message "both" "$addon_log" "Mods Yuzu moved to: $yuzu_mods_temp_dir"
	}

	# Backup des mods dans yuzu_mods_backup_dir 
	move_mods_ryujinx() {
		mkdir -p "$ryujinx_mods_temp_dir"
		mv "$ryujinx_mods_dir"/* "$ryujinx_mods_temp_dir"/ 2>>"$stderr_log"
		message "both" "$addon_log" "Mods Ryujinx moved to: $ryujinx_mods_temp_dir"
	}


# ******************************************************************************
# MENUS
# ******************************************************************************
platform=$(detect_handheld_platform)
menu_title="DCG Toolbox $toolbox_current_version - Batocera : V$batocera_version - Support $platform"
menu_width=100
menu_height=30
menu_list_height=20

# DISPLAY INSTALL LOG
display_install_log() {
	create_dialog_textbox "$menu_title :: INSTALL LOG" "$menu_height" "$menu_width" "DONE" "$addon_log"
}



install_wrapper() {
    # Clean une seule fois
    if [[ -z "$BSA_CLEAN_DONE" ]]; then
        message "both" "$addon_log" "Clean Install : suppression des anciennes configurations"
        uninstall_BSA
        message "both" "$addon_log" "Clean terminé"
        BSA_CLEAN_DONE=1
	fi

    # Ensuite on appelle la vraie installation
	  message "both" "$addon_log" "- Demarrage de l'installation $1"
    full_install "$1"
}

install_eden()   { install_wrapper "eden"; }
install_eden_pgo()   { install_wrapper "eden_pgo"; }
install_eden_nightly()   { install_wrapper "eden_nightly"; }
install_citron() { install_wrapper "citron"; }
install_ryujinx() { install_wrapper "ryujinx"; }

# Install Menu

install_menu() {
	local menu_items=(
		"Eden|Installation : Eden|on|fn|install_eden"
		"Eden-PGO|Installation : Eden-PGO|on|fn|install_eden_pgo"
		"Eden-Nightly|Installation : Eden-Nightly|on|fn|install_eden_nightly"		
		"Citron Neo|Installation : Citron|on|fn|install_citron"
		"Ryujinx|Installation : Ryujinx|on|fn|install_ryujinx"
	)
	unset RAN_POST_INSTALL_COMMON
	unset RAN_POST_INSTALL_COMMON_YUZU
	create_dialog_checkbox_menu \
		"$menu_title :: Install" "$menu_height" "$menu_width" "$menu_list_height" \
		"Lancer" "Annuler" "on" \
		"Choix des emulateurs" \
		"Confirmer l'installation" "Install?" \
		"TOOLBOX :: Installation" "" \
		"Installation" "Installation terminer" \
		"${menu_items[@]}"
}

# Updates Menu
updates_menu() {
	local menu_items=(
		# "Eden Local|Mise à jour Eden Local|off|fn|update_emulator "eden" "local""
		"Eden Remote|Mise à jour Eden |off|fn|update_emulator "eden" "remote""
		"Eden PGO Remote|Mise à jour Eden PGO |off|fn|update_emulator "eden_pgo" "remote""		
		"Eden Nightly Remote|Mise à jour Eden Nightly |off|fn|update_emulator "eden_nightly" "remote""		
		"Citron Neo Remote|Mise à jour Citron |off|fn|update_emulator "citron" "remote""
		"Ryujinx Remote|Mise à jour Ryujinx |off|fn|update_emulator "ryujinx" "remote""
	)
	create_dialog_checkbox_menu \
		"$menu_title :: Update" "$menu_height" "$menu_width" "$menu_list_height" \
		"MISE A JOUR" "Annuler" "on" \
		"Choix des emulateurs à mettre à jour" \
		"Confirmer la mise à jour" "Update?" \
		"TOOLBOX :: UPDATING" "" \
		"UPDATING" "UPDATED" \
		"${menu_items[@]}"
}


# Saves Menu
saves_menu() {
	local menu_items=(
		"BACKUP RYUJINX|Backup Ryujinx Saves|on|fn|backup_saves_ryujinx"
		"BACKUP Mods RYUJINX|Backup Ryujinx Mods|on|fn|backup_mods_ryujinx"
		"BACKUP Eden/Citron/YUZU|Backup Yuzu Saves|on|fn|backup_saves_yuzu"
		"BACKUP Mods Eden/Citron/YUZU|Backup Yuzu Mods|on|fn|backup_mods_yuzu"
	)
	create_dialog_checkbox_menu \
		"$menu_title :: Saves" "$menu_height" "$menu_width" "$menu_list_height" \
		"Sauvegarder!" "Annuler" "on" \
		"Select Options for Saves" \
		"Confirm Saves Options" "Save it?" \
		"BSA :: SAVES" "" \
		"SAVES OPTION" "COMPLETE" \
		"${menu_items[@]}"
}

# Uninstall Menu
uninstall_menu() {
	local menu_items=(
		"Emulateur|Supprimer les emulateurs|off|fn|uninstall_BSA"
		"Firmware|Supprimer les Firmware|off|fn|uninstall_firmware"
		"Keys|Supprimer les Keys|off|fn|uninstall_keys"
		"Amiibo|Supprimer les Amiibo|off|fn|uninstall_amiibo"
		# "Saves|Supprimer Saves|off|fn|uninstall_saves"
	)
	create_dialog_checkbox_menu \
		"$menu_title :: Uninstall" "$menu_height" "$menu_width" "$menu_list_height" \
		"Desinstaller" "Annuler" "on" \
		"Choix des packages à désinstaller" \
		"Confirmer la désinstallation" "Desinstaller?" \
		":: Desinstallation" "" \
		"Desinstallation" "Desinstallation" \
		"${menu_items[@]}"
}

confirm_purge_install_log() {
	if create_dialog_confirm "$menu_title :: Purge Install Log" $height $width "PURGE INSTALL LOG?"; then
		purge_install_log
		dialog --clear --msgbox "INSTALL LOG PURGED!" $height $width
	fi
}

tools_menu() {
	local menu_items=(
		"SAUVEGARDES|Gestion des sauvegardes|fn|saves_menu"
		"DESINSTALLATION|Desinstaller les emulateurs|fn|uninstall_menu"
		"MISE A JOUR MANUEL TOOLBOX|Mise à jour de la toolbox|fn|update_bsa_toolbox"
	)
	create_dialog_list_menu \
		"$menu_title :: Tools" "$menu_height" "$menu_width" "$menu_list_height" \
		"Confirmer" "Annuler" "on" \
		"Menu" \
		"${menu_items[@]}"
}

# Main Menu
main_menu() {
	local exit_status
	local menu_items=(
		"INSTALLATION|Installation des emulateurs|fn|install_menu"
		"MISE A JOUR|Mise à jour des emulateurs|fn|updates_menu"
		"OUTILS AVANCES|Outils avances|fn|tools_menu"
		"QUITTER|Quitter|cmd|killall -9 xterm; exit 0"
	)
	while true; do
		create_dialog_list_menu \
			"$menu_title" "$menu_height" "$menu_width" "$menu_list_height" \
			"Confirmer" "Annuler" "off" \
			"MENU" \
			"${menu_items[@]}"
		exit_status=$?
		case $exit_status in
			1|255)
				# Annuler
				clear			
				exit
			;;
		esac
	done
}


update_bsa_toolbox() {
                clear
                DISPLAY=:0.0 xterm -fs 12 -maximized -fg white -bg black -fa "DejaVuSansMono" -en UTF-8 -e bash -c "DISPLAY=:0.0  curl -k -sL https://dreamercg.s.gy/switch | bash"
}


# ******************************************************************************
# START HERE
# ******************************************************************************
# create log file if it does not exist
[[ -f "$addon_log" ]] || purge_install_log

#run main menu
main_menu

# ******************************************************************************
# -FIN-
# ******************************************************************************
