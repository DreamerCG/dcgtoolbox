#!/usr/bin/env bash 
# BATOCERA - SWITCH ADD-ON : INSTALL EMULATOR APPIMAGES / BINARIES

# SOURCE GUARD TO PREVENT REDUNDANCY
[ -n "$SOURCED_EMULATORS" ] && return
SOURCED_EMULATORS=true



# INSTALL RYUJINX APPIMAGE
install_emulator_ryujinx() {
	message "log" "$addon_log" "<<< [ INSTALL RYUJINX APPIMAGE ]>>>"

	# INSTALL/UNPACK EMULATOR
	# EMULATOR INSTALL ARCHIVE/APP NOT FOUND LOCALLY THEN ATTEMPT TO DOWNLOAD
	message "log" "$addon_log" "Installing Ryujinx Emulator App"
	# Get lastest version from database & set the version for download
    release=$(curl -fsL https://git.ryujinx.app/Ryubing/Canary/releases | grep -m1 -oP '/releases/tag/\K[0-9]+\.[0-9]+\.[0-9]+')    
    # ryujinx_install_url="https://git.ryujinx.app/Ryubing/Canary/releases/download/${release}/ryujinx-canary-${release}-x64.AppImage"
    ryujinx_install_url="https://git.ryujinx.app/Ryubing/Canary/releases/download/1.3.320/ryujinx-canary-1.3.320-x64.AppImage"
    message "both" "$addon_log" "Ryujinx Version : $release"
    message "both" "$addon_log" "Ryujinx url : $ryujinx_install_url"
    
    #Installation du wrapper pour Ryujinx
    copy_make_executable "ryu_wrapper" "$switch_install_extra_dir" "$switch_system_dir/extra/ryu_wrapper"

	# If missing from local storage then attempt to download latest version
	download_missing_file "$ryujinx_install_url" "$switch_install_emus_dir/$ryujinx_install_file" "Ryujinx (Ryubing)"
	if [ $wget_exit_code -eq 0 ]; then
		copy_make_executable "$ryujinx_install_file" "$switch_install_emus_dir" "$ryujinx_emu_dir"
	fi
}

# INSTALL YUZU APPIMAGE
install_emulator_yuzu() {
	message "log" "$addon_log" "<<< [ INSTALL YUZU APPIMAGE ]>>>"

	# INSTALL/UNPACK EMULATOR
	# EMULATOR INSTALL ARCHIVE/APP NOT FOUND LOCALLY THEN ATTEMPT TO DOWNLOAD
	message "log" "$addon_log" "Installing Yuzu Emulator App"
	yuzu_release_html=""
	yuzu_release_version=""
	yuzu_install_url="https://foclabroc.freeboxos.fr:55973/share/6_FB-NuZriqYuHKt/yuzuea4176.AppImage"
	download_missing_file "$yuzu_install_url" "$switch_install_emus_dir/$yuzu_install_file" "Yuzu (Early Acccess)"
	if [ $wget_exit_code -eq 0 ]; then
		copy_make_executable "$yuzu_install_file" "$switch_install_emus_dir" "$yuzu_emu_dir"
	fi
}

# INSTALL EDEN APPIMAGE
install_emulator_eden() {

    # Latest version
    eden_release_version="$(curl -s https://stable.eden-emu.dev/latest/release.json | jq -r .tag_name)"

    # Detect platform
    pname="$(tr '[:upper:]' '[:lower:]' < /sys/class/dmi/id/product_name 2>/dev/null)"

    case "$pname" in
        jupiter|galileo|*"steam deck"*)
            platform="steamdeck"
            eden_appimage="Eden-Linux-${eden_release_version}-steamdeck-gcc-standard.AppImage"
            ;;
        *rc71l*|*"rog ally"*|*"rog-ally"*)
            platform="rog-ally"
            eden_appimage="Eden-Linux-${eden_release_version}-rog-ally-gcc-standard.AppImage"
            ;;
        *)
            platform="generic"
            eden_appimage="Eden-Linux-${eden_release_version}-amd64-gcc-standard.AppImage"
            ;;
    esac

    eden_install_url="https://stable.eden-emu.dev/${eden_release_version}/${eden_appimage}"
   
    message "both" "$addon_log" "Platform detected : $platform"
    message "both" "$addon_log" "Eden Version : $eden_appimage"
    message "both" "$addon_log" "Download URL       : $eden_install_url"

    # Download & install
    download_missing_file "$eden_install_url" "$switch_install_emus_dir/$eden_install_file" "Eden"
    if [ $wget_exit_code -eq 0 ]; then
        copy_make_executable "$eden_install_file" "$switch_install_emus_dir" "$eden_emu_dir"
    fi
}

install_emulator_eden_pgo() {

    # Latest version
    eden_release_version="$(curl -s https://stable.eden-emu.dev/latest/release.json | jq -r .tag_name)"

    # Detect platform
    pname="$(tr '[:upper:]' '[:lower:]' < /sys/class/dmi/id/product_name 2>/dev/null)"

    case "$pname" in
        jupiter|galileo|*"steam deck"*)
            platform="steamdeck"
            eden_appimage="Eden-Linux-${eden_release_version}-steamdeck-clang-pgo.AppImage"
            ;;
        *rc71l*|*"rog ally"*|*"rog-ally"*)
            platform="rog-ally"
            eden_appimage="Eden-Linux-${eden_release_version}-rog-ally-clang-pgo.AppImage"
            ;;
        *)
            platform="generic"
            eden_appimage="Eden-Linux-${eden_release_version}-amd64-clang-pgo.AppImage"
            ;;
    esac

    eden_install_url="https://stable.eden-emu.dev/${eden_release_version}/${eden_appimage}"

    message "both" "$addon_log" "Platform detected : $platform"
    message "both" "$addon_log" "Eden Version : $eden_appimage"
    message "both" "$addon_log" "Download URL       : $eden_install_url"

    # Download & install
    download_missing_file "$eden_install_url" "$switch_install_emus_dir/$eden_pgo_install_file" "Eden-pgo"
    if [ $wget_exit_code -eq 0 ]; then
        copy_make_executable "$eden_pgo_install_file" "$switch_install_emus_dir" "$eden_emu_dir"
    fi
}


# install_emulator_eden_nightly() {

#     # Latest version
#     eden_release_version="$(curl -s https://nightly.eden-emu.dev/latest/release.json | jq -r .tag_name)"

#     # Detect platform
#     pname="$(tr '[:upper:]' '[:lower:]' < /sys/class/dmi/id/product_name 2>/dev/null)"

#     case "$pname" in
#         jupiter|galileo|*"steam deck"*)
#             platform="steamdeck"
#             eden_appimage="Eden-Linux-${eden_release_version}-steamdeck-gcc-standard.AppImage"
#             ;;
#         *rc71l*|*"rog ally"*|*"rog-ally"*)
#             platform="rog-ally"
#             eden_appimage="Eden-Linux-${eden_release_version}-rog-ally-gcc-standard.AppImage"
#             ;;
#         *)
#             platform="generic"
#             eden_appimage="Eden-Linux-${eden_release_version}-amd64-gcc-standard.AppImage"
#             ;;
#     esac

#     eden_install_url="https://nightly.eden-emu.dev/${eden_release_version}/${eden_appimage}"
   
#     message "both" "$addon_log" "Platform detected : $platform"
#     message "both" "$addon_log" "Eden Version : $eden_appimage"
#     message "both" "$addon_log" "Download URL       : $eden_install_url"

#     # Download & install
#     download_missing_file "$eden_install_url" "$switch_install_emus_dir/$eden_install_file" "Eden"
#     if [ $wget_exit_code -eq 0 ]; then
#         copy_make_executable "$eden_install_file" "$switch_install_emus_dir" "$eden_emu_dir"
#     fi
# }



install_emulator_citron() {
	message "log" "$addon_log" "<<< [ INSTALL : CITRON Neo-2026.09.10]>>>"

	# INSTALL/UNPACK EMULATOR
	# EMULATOR INSTALL ARCHIVE/APP NOT FOUND LOCALLY THEN ATTEMPT TO DOWNLOAD
	message "log" "$addon_log" "Installing Citron Neo-2026.09.10 Emulator App "
	# Get lastest version from database & set the version for download
    #citron_install_url="https://foclabroc.freeboxos.fr:55973/share/oZ4k4wPXDTu-fy3g/citron-emu(2026.03.12).AppImage"
    citron_install_url="https://foclabroc.freeboxos.fr:55973/share/4Hd7ueCAGnpabXA5/citron-emu(2026.09.10).AppImage"

	# If missing from local storage then attempt to download latest version
	download_missing_file "$citron_install_url" "$switch_install_emus_dir/$citron_install_file" "Citron"
	if [ $wget_exit_code -eq 0 ]; then
		copy_make_executable "$citron_install_file" "$switch_install_emus_dir" "$citron_emu_dir"
	fi
}




