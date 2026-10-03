#!/usr/bin/env bash 
# BATOCERA - SWITCH ADD-ON : UNPACK PACKAGES

# SOURCE GUARD TO PREVENT REDUNDANCY
[ -n "$SOURCED_PACKAGES" ] && return
SOURCED_PACKAGES=true


# UNPACK AMIIBO PACKAGE
unpack_packages_amiibo() {
	# EXTRACT AMIIBO
	zip_file="$switch_install_packages_dir/amiibo.zip"
	if [ -f "$zip_file" ]; then
		unzip_file "$zip_file" "$switch_amiibo_dir" \
			"Extracting amiibo.zip to Amiibo Directory."
	else
		message "log" "$addon_log" "NOT FOUND: [Amiibo Package] $zip_file"
		message "log" "$addon_log" "*** NOTE **** Amiibo NOT Installed!"
	fi
}


# UNPACK NSZ
unpack_packages_nsz() {
	# EXTRACT NSZ
	zip_file="$switch_install_packages_dir/nsz.zip"
	if [ -f "$zip_file" ]; then
		unzip_file "$zip_file" "$switch_bin_dir" \
			"Extracting nsz.zip to Switch Bin Directory."
	else
		message "log" "$addon_log" "NOT FOUND: [NSZ Package] $zip_file"
		message "log" "$addon_log" "*** NOTE **** NSZ NOT Installed!"
	fi
}


# UNPACK COMMON PACKAGES
unpack_packages_common() {
	# SOURCE GUARD TO PREVENT REDUNDANCY
	[ -n "$RAN_UNPACK_PACKAGES_COMMON" ] && return

	local pkg_desc=""
	local lib_file=""

	message "log" "$addon_log" "<<< [ UNPACK COMMON PACKAGES ]>>>"

	# UNPACK AMIIBO PACKAGE
	unpack_packages_amiibo

	# UNPACK NSZ
	unpack_packages_nsz

	#Install Folder Open Hack Fix of XDG OPEN
	bin_folder_open = xdg-open
	mkdir -p "$switch_bin_dir/xdgfix" 2>>"$stderr_log"
	copy_make_executable "$bin_folder_open" "$switch_install_script_dir" "$switch_bin_dir/xdgfix"

	# INSTALL XDOTOOL
	# DOWNLOAD XDOTOOL IF MISSING
	pkg_desc="XDOTOOL"
	lib_file="libxdo.so.3"
	dl_unpack_missing_package "https://archlinux.org/packages/extra/x86_64/xdotool/download/" "$switch_install_packages_dir/xdotool" "$pkg_desc"
	if [ $wget_exit_code -eq 0 ]; then
		message "log" "$addon_log" "Installing $pkg_desc"
		tar -xf "$tar_file" -C "$switch_bin_dir" "usr/bin/xdotool" --strip-components 2 2>>"$stderr_log"
		tar -xf "$tar_file" -C "$switch_lib_dir" "usr/lib/$lib_file" --strip-components 2 2>>"$stderr_log"
		rm "$tar_file" 2>>"$stderr_log"
		create_slink_directory "$switch_lib_dir/$lib_file" "$switch_lib_dir/libxdo.so"
	fi

	# INSTALL XDG-UTILS
	# DOWNLOAD XDG-UTILS IF MISSING
	pkg_desc="XDG-UTILS"
	dl_unpack_missing_package "https://archlinux.org/packages/extra/any/xdg-utils/download/" "$switch_install_packages_dir/xdg-utils" "$pkg_desc"
	if [ $wget_exit_code -eq 0 ]; then
		message "log" "$addon_log" "Installing $pkg_desc"
		tar -xf "$tar_file" -C "$switch_bin_dir" "usr/bin/" --strip-components 2 2>>"$stderr_log"
		rm "$tar_file" 2>>"$stderr_log"
	fi

	# INSTALL SDL3
	# DOWNLOAD SDL3 IF MISSING
	pkg_desc="SDL3"
	lib_file="libSDL3.so.0.*"
	dl_unpack_missing_package "https://archlinux.org/packages/extra/x86_64/sdl3/download/" "$switch_install_packages_dir/sdl3" "$pkg_desc"
	if [ $wget_exit_code -eq 0 ]; then
		message "log" "$addon_log" "Installing $pkg_desc"
		tar -xf "$tar_file" -C "$switch_lib_dir" --wildcards "usr/lib/$lib_file" --strip-components 2 2>>"$stderr_log"
		rm "$tar_file" 2>>"$stderr_log"
		extracted_lib_file="$(find $switch_lib_dir/$lib_file)"
		create_slink_directory "$extracted_lib_file" "$switch_lib_dir/libSDL3.so.0"
		create_slink_directory "$extracted_lib_file" "$switch_lib_dir/libSDL3.so"
	fi

	# INSTALL SDL2-COMPAT
	# DOWNLOAD SDL2-COMPAT IF MISSING
	pkg_desc="SDL2-COMPAT"
	lib_file="libSDL2-2.0.so.0.*"
	dl_unpack_missing_package "https://archlinux.org/packages/extra/x86_64/sdl2-compat/download/" "$switch_install_packages_dir/sdl2-compat" "$pkg_desc"
	if [ $wget_exit_code -eq 0 ]; then
		message "log" "$addon_log" "Installing $pkg_desc"
		tar -xf "$tar_file" -C "$switch_lib_dir" --wildcards "usr/lib/$lib_file" --strip-components 2 2>>"$stderr_log"
		rm "$tar_file" 2>>"$stderr_log"
		extracted_lib_file="$(find $switch_lib_dir/$lib_file)"
		create_slink_directory "$extracted_lib_file" "$switch_lib_dir/libSDL2-2.0.so.0"
		create_slink_directory "$extracted_lib_file" "$switch_lib_dir/libSDL2-2.0.so"
		create_slink_directory "$extracted_lib_file" "$switch_lib_dir/libSDL2.so.0"
		create_slink_directory "$extracted_lib_file" "$switch_lib_dir/libSDL2.so"
	fi

	# SOURCE GUARD TO PREVENT REDUNDANCY
	RAN_UNPACK_PACKAGES_COMMON=true
}


# UNPACK RYUJINX FIRMWARE PACKAGE
unpack_packages_ryujinx_firmware() {
	# COPY & EXTRACT FIRMWARE: RYUJINX
	zip_file="$switch_install_packages_dir/firmware-ryujinx.zip"
	if [ -f "$zip_file" ]; then
	# DELETE CURRENT RYUJINX FIRMWARE
		if [[ -d "$switch_ryujinx_firmware_dir" ]]; then
			rm -rf "$switch_ryujinx_firmware_dir/"* 2>>"$stderr_log"
		else
			mkdir -p "$switch_ryujinx_firmware_dir" 2>>"$stderr_log"
		fi
		unzip_file "$zip_file" "$switch_ryujinx_firmware_dir" \
			"Extracting $zip_file to Ryujinx Firmware Directory (Manual Install NOT Needed)."
		create_slink_directory "$switch_ryujinx_firmware_dir" "$ryujinx_config_firmware_dir"
	else
		message "log" "$addon_log" "NOT FOUND: [Ryujinx Firmware Package] $zip_file"
		message "log" "$addon_log" "*** NOTE **** Ryujinx Firmware Manual Install Needed!"
	fi
}


# UNPACK RYUJINX KEYS PACKAGE
unpack_packages_ryujinx_keys() {
	# COPY & EXTRACT KEYS: RYUJINX
	zip_file="$switch_install_packages_dir/keys-ryujinx.zip"
	if [ -f "$zip_file" ]; then
	# DELETE CURRENT RYUJINX KEYS
		if [[ -d "$switch_ryujinx_keys_dir" ]]; then
			rm -rf "$switch_ryujinx_keys_dir/"* 2>>"$stderr_log"
		else
			mkdir -p "$switch_ryujinx_keys_dir" 2>>"$stderr_log"
		fi
		unzip_file "$zip_file" "$switch_ryujinx_keys_dir" \
			"Extracting $zip_file to Keys Directory for Ryujinx."
		create_slink_directory "$switch_ryujinx_keys_dir" "$ryujinx_config_keys_dir"
	else
		message "log" "$addon_log" "NOT FOUND: [Ryujinx Keys Package] $zip_file"
		message "log" "$addon_log" "*** NOTE **** Ryujinx Keys Manual Install Needed!"
	fi
}


# UNPACK RYUJINX SAVES PACKAGE
unpack_packages_ryujinx_saves() {
	# RESTORE SAVES
	#	Ryujinx
	#	*** Zip File structure
	#		|-> system
	#			|-> save
	#		|-> user
	#			|-> save
	#			|-> saveMeta
	#
	zip_file="$switch_install_packages_dir/saves-ryujinx.zip"
	if [ -f "$zip_file" ]; then
		unzip_file "$zip_file" "$ryujinx_saves_dir" \
			"Extracting saves_ryujinx.zip to Ryujinx Saves (Restore Saves for Ryujinx)."
	else
		message "log" "$addon_log" "NOT FOUND: [Ryujinx Saves Package] $zip_file"
		message "log" "$addon_log" "*** NOTE **** Ryujinx Saves NOT Restored!"
	fi
}


# UNPACK RYUJINX PACKAGES
unpack_packages_ryujinx() {
	# UNPACK COMMON PACKAGES
	unpack_packages_common

	message "log" "$addon_log" "<<< [ UNPACK RYUJINX PACKAGES ]>>>"

	# UNPACK RYUJINX FIRMWARE PACKAGE
	unpack_packages_ryujinx_firmware

	# UNPACK RYUJINX KEYS PACKAGE
	unpack_packages_ryujinx_keys

	# UNPACK RYUJINX SAVES PACKAGE
	unpack_packages_ryujinx_saves
}


# UNPACK YUZU FIRMWARE PACKAGE
unpack_packages_yuzu_firmware() {
	# COPY & EXTRACT FIRMWARE: YUZU
	zip_file="$switch_install_packages_dir/firmware-yuzu.zip"
	if [ -f "$zip_file" ]; then
	# DELETE CURRENT YUZU FIRMWARE
		if [[ -d "$switch_yuzu_firmware_dir" ]]; then
			rm -rf "$switch_yuzu_firmware_dir/"* 2>>"$stderr_log"
		else
			mkdir -p "$switch_yuzu_firmware_dir" 2>>"$stderr_log"
		fi
		unzip_file "$zip_file" "$switch_yuzu_firmware_dir" \
			"Extracting $zip_file to Firmware Directory for Yuzu."
		create_slink_directory "$switch_yuzu_firmware_dir" "$yuzu_config_firmware_dir"
	else
		message "log" "$addon_log" "NOT FOUND: [Yuzu Firmware Package] $zip_file"
		message "log" "$addon_log" "*** NOTE **** Yuzu Firmware Manual Install Needed!"
	fi
}


# UNPACK YUZU KEYS PACKAGE
unpack_packages_yuzu_keys() {
	# COPY & EXTRACT KEYS: YUZU
	zip_file="$switch_install_packages_dir/keys-yuzu.zip"
	if [ -f "$zip_file" ]; then
	# DELETE CURRENT YUZU KEYS
		if [[ -d "$switch_yuzu_keys_dir" ]]; then
			rm -rf "$switch_yuzu_keys_dir/"* 2>>"$stderr_log"
		else
			mkdir -p "$switch_yuzu_keys_dir" 2>>"$stderr_log"
		fi
		unzip_file "$zip_file" "$switch_yuzu_keys_dir" \
			"Extracting $zip_file to Keys Directory for Yuzu."
		create_slink_directory "$switch_yuzu_keys_dir" "$yuzu_config_keys_dir"
	else
		message "log" "$addon_log" "NOT FOUND: [Yuzu Keys Package] $zip_file"
		message "log" "$addon_log" "*** NOTE **** Yuzu Keys Manual Install Needed!"
	fi
}


# UNPACK YUZU SAVES PACKAGE
unpack_packages_yuzu_saves() {
	# RESTORE SAVES
	#	Yuzu, Eden, Citron
	#	*** Zip File structure
	#		|-> system
	#			|-> save
	#		|-> user
	#			|-> save
	#
	zip_file="$switch_install_packages_dir/saves-yuzu.zip"
	if [ -f "$zip_file" ]; then
		unzip_file "$zip_file" "$yuzu_saves_dir" \
			"Extracting saves_yuzu.zip to Yuzu Saves (Restore Saves for Yuzu)."
	else
		message "log" "$addon_log" "NOT FOUND: [Yuzu Saves Package] $zip_file"
		message "log" "$addon_log" "*** NOTE **** Yuzu Saves NOT Restored!"
	fi
}


# UNPACK COMMON YUZU & FORKS PACKAGES
unpack_packages_common_yuzu() {
	# SOURCE GUARD TO PREVENT REDUNDANCY
	[ -n "$RAN_UNPACK_PACKAGES_COMMON_YUZU" ] && return
	
	# UNPACK COMMON PACKAGES
	unpack_packages_common

	message "log" "$addon_log" "<<< [ UNPACK COMMON YUZU & FORKS PACKAGES ]>>>"

	# UNPACK YUZU & FORKS FIRMWARE PACKAGE
	unpack_packages_yuzu_firmware

	# UNPACK YUZU & FORKS KEYS PACKAGE
	unpack_packages_yuzu_keys

	# UNPACK YUZU & FORKS SAVES PACKAGE
	unpack_packages_yuzu_saves
	
	# SOURCE GUARD TO PREVENT REDUNDANCY
	RAN_UNPACK_PACKAGES_COMMON_YUZU=true
}


# UNPACK YUZU ONLY PACKAGES
unpack_packages_yuzu_only() {
	message "log" "$addon_log" "<<< [ UNPACK YUZU PACKAGES ]>>>"

	# INSTALL THAI LANGUAGE SUPPORT LIBRARY NEEDED BY YUZU
	# DOWNLOAD THAI LANGUAGE SUPPORT LIBRARY IF MISSING
	message "log" "$addon_log" "Installing Thai Language Support (Required by Yuzu)"
	pkg_desc="THAI LANGUAGE SUPPORT LIBRARY"
	lib_file="libthai.so.0.3.1"
	dl_unpack_missing_package "https://archlinux.org/packages/extra/x86_64/libthai/download/" "$switch_install_packages_dir/libthai" "$pkg_desc"
	if [ $wget_exit_code -eq 0 ]; then
		message "log" "$addon_log" "Installing $pkg_desc"
		tar -xf "$tar_file" -C "$switch_lib_dir" "usr/lib/$lib_file" --strip-components 2 2>>"$stderr_log"
		rm "$tar_file" 2>>"$stderr_log"
		create_slink_directory "$switch_lib_dir/$lib_file" "$switch_lib_dir/libthai.so.0"
		create_slink_directory "$switch_lib_dir/$lib_file" "$switch_lib_dir/libthai.so"
	fi
}


# UNPACK YUZU PACKAGES
unpack_packages_yuzu() {
	# UNPACK COMMON YUZU & FORKS PACKAGES
	unpack_packages_common_yuzu

	# UNPACK YUZU ONLY PACKAGES
	unpack_packages_yuzu_only
}


# UNPACK EDEN ONLY PACKAGES
unpack_packages_eden_only() {
	message "log" "$addon_log" "<<< [ UNPACK EDEN PACKAGES ]>>>"
	
	# REPLACE WITH CODE
	message "log" "$addon_log" "N/A"
}


# UNPACK PACKAGES EDEN
unpack_packages_eden() {
	# UNPACK COMMON PACKAGES FOR YUZU & FORKS
	unpack_packages_common_yuzu

	# UNPACK EDEN ONLY PACKAGES
	unpack_packages_eden_only
}


# UNPACK PACKAGES EDEN
unpack_packages_eden_pgo() {
	# UNPACK COMMON PACKAGES FOR YUZU & FORKS
	unpack_packages_common_yuzu

	# UNPACK EDEN ONLY PACKAGES
	unpack_packages_eden_only
}


# UNPACK PACKAGES EDEN
unpack_packages_eden_nightly() {
	# UNPACK COMMON PACKAGES FOR YUZU & FORKS
	unpack_packages_common_yuzu

	# UNPACK EDEN ONLY PACKAGES
	unpack_packages_eden_only
}



# UNPACK CITRON ONLY PACKAGES
unpack_packages_citron_only() {
	message "log" "$addon_log" "<<< [ UNPACK CITRON PACKAGES ]>>>"
	
	# REPLACE WITH CODE
	message "log" "$addon_log" "N/A"
}


# UNPACK PACKAGES CITRON
unpack_packages_citron() {
	# UNPACK COMMON PACKAGES FOR YUZU & FORKS
	unpack_packages_common_yuzu

	# UNPACK CITRON ONLY PACKAGES
	unpack_packages_citron_only
}

