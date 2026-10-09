#!/usr/bin/env bash 
# BATOCERA - SWITCH ADD-ON : INITIALLIZE STRUCTURES

# SOURCE GUARD TO PREVENT REDUNDANCY
[ -n "$SOURCED_INITIALIZE" ] && return
SOURCED_INITIALIZE=true


# ADD EMULATOR TO ES SYSTEMS CONFIG FILE
add_emulator_to_es_systems() {
	local emu="$1"
	local xml_node="<emulator name=\"$emu\"><cores><core default=\"true\">$emu</core></cores></emulator>"
	xml_file_inject_node \
		"$system_configs_dir/emulationstation/es_systems_switch.cfg" \
		"//system[name='switch']/emulators" \
		"emulator[@name='$emu']" \
		"$xml_node"
}

# SETUP COMMON STRUCTURES
initialize_common() {
	# SOURCE GUARD TO PREVENT REDUNDANCY
	[ -n "$RAN_INITIALIZE_COMMON" ] && return

	message "log" "$addon_log" "<<< [ INITIALLIZE COMMON STRUCTURES ]>>>"

	# CREATE SWITCH SYSTEM DIRECTORY
	message "log" "$addon_log" "Creating Switch System Directory => /userdata/system/switch"
	mkdir -p "$switch_system_dir" 2>>"$stderr_log"

	# CREATE SWITCH SYSTEM EXTRA DIRECTORY
	message "log" "$addon_log" "Creating Switch System Extra Directory => /userdata/system/switch/extra"
	mkdir -p "$switch_system_dir/extra" 2>>"$stderr_log"

	# CREATE SWITCH LOGS DIRECTORY
	message "log" "$addon_log" "Creating Switch System Logs Directory => /userdata/system/switch/logs"
	mkdir -p "$switch_logs_dir" 2>>"$stderr_log"

	# SETUP BIOS DIRECTORY (STORES FIRMWARE, KEYS, AMIIBO)
	message "log" "$addon_log" "Creating Switch BIOS Directory > => /userdata/bios/switch"
	mkdir -p "$switch_bios_dir" 2>>"$stderr_log"

	# GENERATE _INFO.TXT IN BIOS DIRECTORY
	message "log" "$addon_log" "Generating _info.txt for Switch BIOS Directory."
	generate_file "$switch_bios_dir/_info.txt" \
		"-= Firmware, Keys, Amiibo, etc. for Switch =-" \
		"" \
		"***NOTE: Yuzu also refers to Forks (Eden, Citron) as well." \
		"" \
		"Directory Structure for the BSA (Batocera Switch Add-On}" \
		"" \
		"	./amiibo" \
		"		... AMIIBO files" \
		"	./firmware_ryujinx" \
		"		... Firmware for Ryujinx (can be different from Yuzu)" \
		"	./firmware_yuzu" \
		"		... Firmware for Yuzu (can be different from Ryujinx)" \
		"	./keys_ryujinx" \
		"		... Keys for Ryujinx (must match the Firmware for Ryujinx)" \
		"	./keys_yuzu" \
		"		... Keys for Yuzu (must match the Firmware for Yuzu)" \
		""

	# SETUP AMIIBO DIRECTORY
	message "log" "$addon_log" "Creating Switch Amiibo Directory. > => /userdata/bios/switch/amiibo"
	mkdir -p "$switch_amiibo_dir" 2>>"$stderr_log"

	# CREATE ROMS DIRECTORY
	message "log" "$addon_log" "Creating Switch ROMs Directory. > => /userdata/roms/switch"
	mkdir -p "$switch_roms_dir" 2>>"$stderr_log"

	# GENERATE _INFO.TXT IN ROMS DIRECTORY
	message "log" "$addon_log" "Generating _info.txt for Switch ROMs Directory."
	generate_file "$switch_roms_dir/_info.txt" \
		"## SYSTEM NINTENDO SWITCH ##" \
		"-------------------------------------------------------------------------------" \
		"ROM files extensions accepted: \".xci, .XCI, .nsp, .NSP, .nsz, .NSZ\"" \
		"-------------------------------------------------------------------------------" \
		"Extensions des fichiers ROMs permises: \".xci, .XCI, .nsp, .NSP, .nsz, .NSZ\""

	# SETUP SYSTEM CONFIGS
	rename_file	"$system_configs_dir/emulationstation/es_systems_switch.cfg" "$system_configs_dir/emulationstation/es_systems_switch.old" "yes"
	message "log" "$addon_log" "Setup Switch System Configs. (EmulationStation, evmapy, etc.)"
	cp -rfT "$switch_install_configs_dir" "$system_configs_dir" 2>>"$stderr_log"
	rename_file	"$system_configs_dir/emulationstation/es_systems_switch.old" "$system_configs_dir/emulationstation/es_systems_switch.cfg" "yes"

	# COPIE ALL IMAGE FOR SWITCH PORTS
	# message "log" "$addon_log" "Copying All Images for Switch Ports. => /userdata/roms/ports/images/"
	# cp -rfT "$switch_install_roms_ports_images_dir" "$switch_ports_images_dir" 2>>"$stderr_log"

	# COPIE ALL IMAGE FOR SWITCH ROMS
	message "log" "$addon_log" "Copying All Images for Switch Roms. => /userdata/roms/switch/images/"
	cp -rfT "$switch_install_roms_switch_images_dir" "$switch_switch_images_dir" 2>>"$stderr_log"

	# SETUP SYSTEM CONFIG GENERATORS
	message "log" "$addon_log" "Setup Switch Config Generators. => /userdata/system/switch/configgen"
	cp -rfT "$switch_install_configgen_dir" "$switch_configgen_dir" 2>>"$stderr_log"

	# INSTALL SWITCH LAUNCHER PACKAGE (Batocera 44)
	if [ -d "$switch_install_launch_dir" ]; then
		message "log" "$addon_log" "Setup Switch Launch Package. => /userdata/system/switch/launch"
		cp -rfT "$switch_install_launch_dir" "$switch_system_dir/launch" 2>>"$stderr_log"
	fi

	# CREATE SWITCH BIN DIRECTORY
	message "log" "$addon_log" "Creating Switch BIN Directory. => /userdata/system/switch/bin"
	mkdir -p "$switch_bin_dir" 2>>"$stderr_log"

	# CREATE SWITCH LIB DIRECTORY
	message "log" "$addon_log" "Creating Switch LIB Directory. => /userdata/system/switch/lib"
	mkdir -p "$switch_lib_dir" 2>>"$stderr_log"

	# CREATE NEW SAVES DIRECTORY
	message "log" "$addon_log" "Yuzu Emulator Directory Saves."
	mkdir -p "$yuzu_system_saves_dir" 2>>"$stderr_log"
	mkdir -p "$yuzu_user_saves_dir" 2>>"$stderr_log"


	# SOURCE GUARD TO PREVENT REDUNDANCY
	RAN_INITIALIZE_COMMON=true
}


# INITIALLIZE RYUJINX STRUCTURES
initialize_ryujinx() {

	# SETUP COMMON STRUCTURES
	initialize_common

	message "log" "$addon_log" "<<< [ INITIALLIZE RYUJINX STRUCTURES ]>>>"

	# SETUP FIRMWARE DIRECTORY
	message "log" "$addon_log" "Creating Ryujinx Firmware Directories. => /userdata/bios/switch/firmware"
	mkdir -p "$switch_ryujinx_firmware_dir" 2>>"$stderr_log"

	# SETUP KEYS DIRECTORY
	message "log" "$addon_log" "Creating Ryujinx Keys Directories. => /userdata/bios/switch/keys"
	mkdir -p "$switch_ryujinx_keys_dir" 2>>"$stderr_log"

	# CREATE EMULATOR DIRECTORY
	message "log" "$addon_log" "Ryujinx Emulator Directory Created."
	mkdir -p "$ryujinx_emu_dir" 2>>"$stderr_log"


	# ADD EMULATOR TO ES SYSTEMS CONFIG FILE
	add_emulator_to_es_systems "ryujinx-emu"
}

# INITIALLIZE YUZU STRUCTURES
initialize_yuzu() {


	# SETUP COMMON STRUCTURES
	initialize_common

	message "log" "$addon_log" "<<< [ INITIALLIZE YUZU STRUCTURES ]>>>"

	# SETUP FIRMWARE DIRECTORY
	if [ ! -d "$switch_yuzu_firmware_dir" ]; then
		message "log" "$addon_log" "Creating Firmware Directory."
		mkdir -p "$switch_yuzu_firmware_dir" 2>>"$stderr_log"
	fi

	# SETUP KEYS DIRECTORY
	if [ ! -d "$switch_yuzu_keys_dir" ]; then
		message "log" "$addon_log" "Creating Keys Directory."
		mkdir -p "$switch_yuzu_keys_dir" 2>>"$stderr_log"
	fi

	# CREATE EMULATOR DIRECTORY
	message "log" "$addon_log" "Yuzu Emulator Directory Created."
	mkdir -p "$yuzu_emu_dir" 2>>"$stderr_log"

	# ADD EMULATOR TO ES SYSTEMS CONFIG FILE
	add_emulator_to_es_systems "yuzu-emu"
}


# INITIALLIZE EDEN STRUCTURES
initialize_eden() {

	# SETUP COMMON STRUCTURES
	initialize_common

	message "log" "$addon_log" "<<< [ INITIALLIZE EDEN STRUCTURES ]>>>"

	# SETUP FIRMWARE DIRECTORY
	if [ ! -d "$switch_yuzu_firmware_dir" ]; then
		message "log" "$addon_log" "Creating Firmware Directory."
		mkdir -p "$switch_yuzu_firmware_dir" 2>>"$stderr_log"
	fi

	# SETUP KEYS DIRECTORY
	if [ ! -d "$switch_yuzu_keys_dir" ]; then
		message "log" "$addon_log" "Creating Keys Directory."
		mkdir -p "$switch_yuzu_keys_dir" 2>>"$stderr_log"
	fi

	# CREATE EMULATOR DIRECTORY
	message "log" "$addon_log" "Eden Emulator Directory Created."
	mkdir -p "$eden_emu_dir" 2>>"$stderr_log"


	# ADD EMULATOR TO ES SYSTEMS CONFIG FILE
	add_emulator_to_es_systems "eden-emu"
}

# INITIALLIZE EDEN STRUCTURES
initialize_eden_pgo() {

	# SETUP COMMON STRUCTURES
	initialize_common

	message "log" "$addon_log" "<<< [ INITIALLIZE EDEN PGO STRUCTURES ]>>>"

	# SETUP FIRMWARE DIRECTORY
	if [ ! -d "$switch_yuzu_firmware_dir" ]; then
		message "log" "$addon_log" "Creating Firmware Directory."
		mkdir -p "$switch_yuzu_firmware_dir" 2>>"$stderr_log"
	fi

	# SETUP KEYS DIRECTORY
	if [ ! -d "$switch_yuzu_keys_dir" ]; then
		message "log" "$addon_log" "Creating Keys Directory."
		mkdir -p "$switch_yuzu_keys_dir" 2>>"$stderr_log"
	fi

	# CREATE EMULATOR DIRECTORY
	message "log" "$addon_log" "Eden Emulator Directory Created."
	mkdir -p "$eden_emu_dir" 2>>"$stderr_log"


	# ADD EMULATOR TO ES SYSTEMS CONFIG FILE
	add_emulator_to_es_systems "eden-pgo"
}


# INITIALLIZE EDEN STRUCTURES
initialize_eden_nightly() {

	# SETUP COMMON STRUCTURES
	initialize_common

	message "log" "$addon_log" "<<< [ INITIALLIZE EDEN NIGHTLY STRUCTURES ]>>>"

	# SETUP FIRMWARE DIRECTORY
	if [ ! -d "$switch_yuzu_firmware_dir" ]; then
		message "log" "$addon_log" "Creating Firmware Directory."
		mkdir -p "$switch_yuzu_firmware_dir" 2>>"$stderr_log"
	fi

	# SETUP KEYS DIRECTORY
	if [ ! -d "$switch_yuzu_keys_dir" ]; then
		message "log" "$addon_log" "Creating Keys Directory."
		mkdir -p "$switch_yuzu_keys_dir" 2>>"$stderr_log"
	fi

	# CREATE EMULATOR DIRECTORY
	message "log" "$addon_log" "Eden Emulator Directory Created."
	mkdir -p "$eden_emu_dir" 2>>"$stderr_log"


	# ADD EMULATOR TO ES SYSTEMS CONFIG FILE
	add_emulator_to_es_systems "eden-nightly"
}

# INITIALLIZE CITRON STRUCTURES
initialize_citron() {

	# SETUP COMMON STRUCTURES
	initialize_common

	message "log" "$addon_log" "<<< [ INITIALLIZE CITRON STRUCTURES ]>>>"

	# SETUP FIRMWARE DIRECTORY
	if [ ! -d "$switch_yuzu_firmware_dir" ]; then
		message "log" "$addon_log" "Creating Firmware Directory."
		mkdir -p "$switch_yuzu_firmware_dir" 2>>"$stderr_log"
	fi

	# SETUP KEYS DIRECTORY
	if [ ! -d "$switch_yuzu_keys_dir" ]; then
		message "log" "$addon_log" "Creating Keys Directory."
		mkdir -p "$switch_yuzu_keys_dir" 2>>"$stderr_log"
	fi

	# CREATE EMULATOR DIRECTORY
	message "log" "$addon_log" "Citron Emulator Directory Created."
	mkdir -p "$citron_emu_dir" 2>>"$stderr_log"


	# ADD EMULATOR TO ES SYSTEMS CONFIG FILE
	add_emulator_to_es_systems "citron-emu"
}
