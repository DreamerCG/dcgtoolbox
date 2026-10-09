#!/usr/bin/env bash 
#	BATOCERA - SWITCH ADD-ON: VARIABLES

# SOURCE GUARD TO PREVENT REDUNDANCY
[ -n "$SOURCED_VARIABLES" ] && return
SOURCED_VARIABLES=true


# BATOCERA VERSION
batocera_version="$(batocera-es-swissknife --version | grep -oE '^[0-9]+')"

case "$batocera_version" in
	41)
		folder_version=41
		;;
	4[2-4])
		folder_version=42
		;;
	*)
		echo "Unsupported Batocera version: $batocera_version" >&2
		exit 1
		;;
esac


# ******************************************************************************
# COLORS FOR SCREEN OUTPUT (PRINTF)
# ******************************************************************************
declare -rA print_color=(
	[NONE]='\033[0m'
	[BLACK]='\033[0;30m'
	[GREY]='\033[0;1;30m'
	[LIGHT_GREY]='\033[0;37m'
	[WHITE]='\033[1;37m'
	[RED]='\033[0;31m'
	[LIGHT_RED]='\033[1;31m'
	[GREEN]='\033[0;32m'
	[LIGHT_GREEN]='\033[1;32m'
	[BROWN]='\033[0;33m'
	[LIGHT_BROWN]='\033[1;33m'
	[BLUE]='\033[0;34m'
	[LIGHT_BLUE]='\033[1;34m'
	[PURPLE]='\033[0;35m'
	[LIGHT_PURPLE]='\033[1;35m'
	[CYAN]='\033[0;36m'
	[LIGHT_CYAN]='\033[1;36m'
)


# ******************************************************************************
# BSA INSTALL OPTIONS
# ******************************************************************************
OPT_BLANK="FALSE"
OPT_INSTALL_RYUJINX="TRUE"
OPT_INSTALL_YUZU="TRUE"
OPT_INSTALL_EDEN="TRUE"
OPT_INSTALL_CITRON="TRUE"
OPT_PACKAGE_BIOS_RYUJINX="TRUE"
OPT_PACKAGE_BIOS_YUZU="TRUE"
OPT_PACKAGE_KEYS_RYUJINX="TRUE"
OPT_PACKAGE_KEYS_YUZU="TRUE"
OPT_PACKAGE_SAVES_RYUJINX="TRUE"
OPT_PACKAGE_SAVES_YUZU="TRUE"
OPT_PACKAGE_AMIIBO="TRUE"
OPT_FIX_DIR_LINKS_RYUJINX="FALSE"
OPT_FIX_DIR_LINKS_YUZU="FALSE"
OPT_FIX_DIR_LINKS_EDEN="FALSE"
OPT_FIX_DIR_LINKS_CITRON="FALSE"


# ******************************************************************************
# DIALOG VARIABLES
# ******************************************************************************
DIALOG_PIPE_FILE=""


# ******************************************************************************
# INSTALLATION DIRECTORIES [WHERE FILES ARE INSTALLED FROM]
# ******************************************************************************
# INSTALLATION: ROOT :: Current directory that the Install Script is running from.
switch_install_script_dir="$( cd -- $( dirname -- ${BASH_SOURCE[0]} ) &> /dev/null && pwd )"
# INSTALLATION: PACKAGES :: Post Installation Packages [Firmware, Keys, Saves, Etc.]
switch_install_packages_dir="$switch_install_script_dir/install/$folder_version/system/switch/extra/packages"
# INSTALLATION: ICONS :: Icons use for desktop files [F1-Applications Menu]
switch_install_icons_dir="$switch_install_script_dir/icons"
# INSTALLATION: EMULATORS :: AppImages and Archives of Emulators to install
switch_install_emus_dir="$switch_install_script_dir/emus"
# INSTALLATION: SCRIPTS :: Scripts to install
switch_install_scripts_dir="$switch_install_script_dir/install/$folder_version/system/switch/extra/scripts"
# INSTALLATION: SYSTEM CONFIGS :: System Config Files (EmulationStation, evmapy, etc.)
switch_install_configs_dir="$switch_install_script_dir/install/$folder_version/system/configs"
# INSTALLATION: CONFIG GENERATORS :: Configuration Generation Scripts
switch_install_configgen_dir="$switch_install_script_dir/install/$folder_version/system/switch/configgen"
# INSTALLATION: SWITCH LAUNCHER :: Batocera 44 Switch launch package
switch_install_launch_dir="$switch_install_script_dir/install/$folder_version/system/switch/launch"
# INSTALLATION: CONFIG EXTRA :: Configuration EXTRA Scripts
switch_install_extra_dir="$switch_install_script_dir/install/$folder_version/system/switch/extra"
# INSTALLATION: ROMS :: Roms to Install in Post
switch_install_roms_dir="$switch_install_script_dir/roms"
# INSTALLATION: SWITCH ROMS :: Switch Roms to Install in Post
# switch_install_roms_switch_dir="$switch_install_roms_dir/switch"
# INSTALLATION: PORTS ROMS :: Ports Roms to Install in Post
switch_install_roms_ports_dir="$switch_install_script_dir/install/roms/ports"
switch_install_roms_switch_dir="$switch_install_script_dir/install/roms/switch"
switch_install_roms_ports_images_dir="$switch_install_script_dir/install/roms/ports/images"
switch_install_roms_switch_images_dir="$switch_install_script_dir/install/roms/switch/images"


# ******************************************************************************
# INSTALLATION LOG FILE
# ******************************************************************************
addon_log="$switch_install_script_dir/$this_script_file_name.log"
# standard error
stderr_log="$addon_log"


# ******************************************************************************
# SYSTEM (HOME / ~) DIRECTORIES
# ******************************************************************************
# SYSTEM: ROOT
system_dir="/userdata/system"
# SYSTEM: SERVICES
system_services_dir="$system_dir/services"
# SYSTEM: CONFIGS
system_configs_dir="$system_dir/configs"
# SYSTEM: EMULATION STATION
system_configs_emulationstation_dir="$system_configs_dir/emulationstation"
# SYSTEM: EVMAPY
system_configs_evmapy_dir="$system_configs_dir/evmapy"
# SYSTEM: HIDDEN CONFIGS
system_hidden_config_dir="$system_dir/.config"
# SYSTEM: SHARE (ROOT LEVEL)
system_share_dir="/usr/share"
# SYSTEM: APPLICATIONS (ROOT LEVEL)
system_applications_dir="$system_share_dir/applications"
# SYSTEM: SAVES
system_saves_dir="/userdata/saves"


# ******************************************************************************
# LOCAL DIRECTORIES
# ******************************************************************************
# LOCAL: ROOT
local_dir="$system_dir/.local"
# LOCAL: SHARE
local_share_dir="$local_dir/share"
# LOCAL: APPLICATIONS
local_applications_dir="$local_share_dir/applications"
# LOCAL: ICONS
local_icons_dir="$local_share_dir/applications"


# ******************************************************************************
# SWITCH DIRECTORIES [WHERE FILES ARE INSTALLED TO]
# ******************************************************************************

# ---------- BIOS AREA ----------
# SWITCH: BIOS
switch_bios_dir="/userdata/bios/switch"
# SWITCH: FIRMWARE :: YUZU
switch_yuzu_firmware_dir="$switch_bios_dir/firmware"
# SWITCH: FIRMWARE :: RYUJINX
switch_ryujinx_firmware_dir="$switch_bios_dir/firmware"
# SWITCH: KEYS :: YUZU
switch_yuzu_keys_dir="$switch_bios_dir/keys"
# SWITCH: KEYS :: RYUJINX
switch_ryujinx_keys_dir="$switch_bios_dir/keys"
# SWITCH: AMIIBO
switch_amiibo_dir="$switch_bios_dir/amiibo"
# SWITCH: ROMS
switch_roms_dir="/userdata/roms/switch"
# PORTS: ROMS
switch_ports_dir="/userdata/roms/ports"
# PORTS: IMAGES
switch_ports_images_dir="/userdata/roms/ports/images"
switch_switch_images_dir="/userdata/roms/switch/images"

# ---------- SYSTEM AREA ----------
# SWITCH: SAVES
switch_saves_dir="$system_saves_dir/switch"
# SWITCH: ROOT
switch_system_dir="$system_dir/switch"
# SWITCH: LOGS
switch_logs_dir="$switch_system_dir/logs"
# SWITCH: CONFIG GENERATORS :: Configuration Generation Scripts
switch_configgen_dir="$switch_system_dir/configgen"
# SWITCH: BIN
switch_bin_dir="$switch_system_dir/bin"
# SWITCH: LIB
switch_lib_dir="$switch_system_dir/lib"
# SWITCH: APPIMAGE
switch_Appimage_dir="$switch_system_dir/appimages"


# ==============================================================================
# ******************************************************************************
#  RYUJINX VARIABLES
# ******************************************************************************
# ==============================================================================
# ORIGINAL (What the AppImage Uses) CONFIG DIRECTORIES (WILL BE SYMBOLIC LINKS TO NEW CONFIG DIRECTORIES)
ryujinx_og_config_dir="$system_hidden_config_dir/Ryujinx"
ryujinx_og_local_config_dir="$local_share_dir/Ryujinx"

# NEW CONFIG DIRECTORIES (ACTUAL LOCATION OF CONFIG DIRECTORIES)
ryujinx_config_dir="$system_configs_dir/Ryujinx" # ROOT
ryujinx_config_nand_dir="$ryujinx_config_dir/bis" # NAND
ryujinx_config_firmware_dir="$ryujinx_config_nand_dir/system/Contents/registered" # FIRMWARE
ryujinx_config_keys_dir="$ryujinx_config_dir/system" # KEYS
ryujinx_config_system_saves_dir="$ryujinx_config_dir/bis/system/save" # NAND SYSTEM SAVES (OLD)
ryujinx_config_user_saves_dir="$ryujinx_config_dir/bis/user/save" # NAND USER SAVES (OLD)
ryujinx_config_user_saves_meta_dir="$ryujinx_config_dir/bis/user/saveMeta" # NAND USER SAVES META (OLD)
ryujinx_config_amiibo_dir="$ryujinx_config_dir/amiibo" # AMIIBO
ryujinx_saves_dir="$switch_saves_dir/Ryujinx" # SAVES (NEW)
ryujinx_system_saves_dir="$ryujinx_saves_dir/system/save" # NAND SYSTEM SAVES (NEW)
ryujinx_user_saves_dir="$ryujinx_saves_dir/user/save" # NAND USER SAVES (NEW)
ryujinx_user_saves_meta_dir="$ryujinx_saves_dir/user/saveMeta" # NAND USER SAVES META (NEW)

ryujinx_mods_temp_dir="$switch_saves_dir/mods_ryujinx_tmp" # MODS TEMP DIRECTORY
ryujinx_mods_dir="$ryujinx_config_dir/mods" # MODS DIRECTORY
ryujinx_new_mods_dir="$switch_saves_dir/ryujinx/mods" # NEW MODS DIRECTORY

# EMULATOR INSTALL FROM ARCHIVE/APP FILENAME
ryujinx_install_file="ryujinx-emu.AppImage"
# EMULATOR INSTALL FROM ARCHIVE/APP FILENAME URL (FOR DOWNLOAD IF NOT PRESENT)
ryujinx_install_url=""
# EMULATOR DIRECTORY
ryujinx_emu_dir="$switch_Appimage_dir"


# ==============================================================================
# ******************************************************************************
#  YUZU VARIABLES
# ******************************************************************************
# ==============================================================================
# ORIGINAL (What the AppImage Uses) CONFIG DIRECTORIES (WILL BE SYMBOLIC LINKS TO NEW CONFIG DIRECTORIES)
yuzu_og_config_dir="$system_hidden_config_dir/yuzu"
yuzu_og_local_config_dir="$local_share_dir/yuzu"

# NEW CONFIG DIRECTORIES (ACTUAL LOCATION OF CONFIG DIRECTORIES)
yuzu_config_dir="$system_configs_dir/yuzu" # ROOT
yuzu_config_nand_dir="$yuzu_config_dir/nand" # NAND
yuzu_config_firmware_dir="$yuzu_config_nand_dir/system/Contents/registered" # FIRMWARE
yuzu_config_keys_dir="$yuzu_config_dir/keys" # KEYS
yuzu_config_system_saves_dir="$yuzu_config_dir/nand/system/save" # NAND SYSTEM SAVES (OLD)
yuzu_config_user_saves_dir="$yuzu_config_dir/nand/user/save" # NAND USER SAVES (OLD)
yuzu_config_amiibo_dir="$yuzu_config_dir/amiibo" # AMIIBO
yuzu_system_saves_dir="$switch_saves_dir/eden_citron/save/save_system" # NAND SYSTEM SAVES (NEW)
yuzu_user_saves_dir="$switch_saves_dir/eden_citron/save/save_user" # NAND USER SAVES (NEW)
yuzu_mods_temp_dir="$switch_saves_dir/mods_yuzu_tmp" # MODS TEMP DIRECTORY
yuzu_mods_dir="$yuzu_config_dir/load" # MODS DIRECTORY
yuzu_new_mods_dir="$switch_saves_dir/eden_citron/mods" # NEW MODS DIRECTORY

# EMULATOR INSTALL FROM ARCHIVE/APP FILENAME
yuzu_install_file="yuzu-emu.AppImage"
# EMULATOR INSTALL FROM ARCHIVE/APP FILENAME URL (FOR DOWNLOAD IF NOT PRESENT)
yuzu_install_url="https://foclabroc.freeboxos.fr:55973/share/6_FB-NuZriqYuHKt/yuzuea4176.AppImage"
# EMULATOR DIRECTORY
yuzu_emu_dir="$switch_Appimage_dir"


# ==============================================================================
# ******************************************************************************
#  EDEN VARIABLES
# ******************************************************************************
# ==============================================================================
# ORIGINAL (What the AppImage Uses) CONFIG DIRECTORIES (WILL BE SYMBOLIC LINKS TO NEW CONFIG DIRECTORIES)
eden_og_config_dir="$system_hidden_config_dir/yuzu"
eden_og_local_config_dir="$local_share_dir/yuzu"
# NEW CONFIG DIRECTORIES (ACTUAL LOCATION OF CONFIG DIRECTORIES)
eden_config_dir="$system_configs_dir/eden" # ROOT
eden_config_nand_dir="$eden_config_dir/nand" # NAND
eden_config_firmware_dir="$eden_config_nand_dir/system/Contents/registered" # FIRMWARE
eden_config_keys_dir="$eden_config_dir/keys" # KEYS
eden_config_saves_dir="$eden_config_dir/nand/user/save" # SAVES (OLD)
eden_config_amiibo_dir="$eden_config_dir/amiibo" # AMIIBO
eden_saves_dir="$system_saves_dir/yuzu" # SAVES (NEW)
# EMULATOR INSTALL FROM ARCHIVE/APP FILENAME
eden_install_file="eden-emu.AppImage"
eden_pgo_install_file="eden-pgo.AppImage"
eden_nightly_install_file="eden-nightly.AppImage"

# EMULATOR INSTALL FROM ARCHIVE/APP FILENAME URL (FOR DOWNLOAD IF NOT PRESENT)
eden_install_url=""
# EMULATOR DIRECTORY
eden_emu_dir="$switch_Appimage_dir"


# ==============================================================================
# ******************************************************************************
#  CITRON VARIABLES
# ******************************************************************************
# ==============================================================================
# ORIGINAL (What the AppImage Uses) CONFIG DIRECTORIES (WILL BE SYMBOLIC LINKS TO NEW CONFIG DIRECTORIES)
citron_og_config_dir="$system_hidden_config_dir/yuzu"
citron_og_local_config_dir="$local_share_dir/yuzu"
# NEW CONFIG DIRECTORIES (ACTUAL LOCATION OF CONFIG DIRECTORIES)
citron_config_dir="$system_configs_dir/citron" # ROOT
citron_config_nand_dir="$citron_config_dir/nand" # NAND
citron_config_firmware_dir="$citron_config_nand_dir/system/Contents/registered" # FIRMWARE
citron_config_keys_dir="$citron_config_dir/keys" # KEYS
citron_config_saves_dir="$citron_config_dir/nand/user/save" # SAVES (OLD)
citron_config_amiibo_dir="$citron_config_dir/amiibo" # AMIIBO
citron_saves_dir="$system_saves_dir/yuzu" # SAVES (NEW)
# EMULATOR INSTALL FROM ARCHIVE/APP FILENAME
citron_install_file="citron-emu.AppImage"
# EMULATOR INSTALL FROM ARCHIVE/APP FILENAME URL (FOR DOWNLOAD IF NOT PRESENT)
citron_install_url=""
# EMULATOR DIRECTORY
citron_emu_dir="$switch_Appimage_dir"
