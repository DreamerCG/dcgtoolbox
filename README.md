# DreamerCG Toolbox

**REQUIRED**
- Batocera x86_64
- File System (*userdata*) supporting **symlinking (EXT4, BTRFS)**

<br></br>

**CREDITS**

Based on the works of:
- ordovice
- foclabroc
- Batocera Nation
- uureel
- TronFNBlow

<br></br>

## HOW-TO TOOLBOX
- Terminal:
<pre>
curl -k -sL https://dreamercg.s.gy/switch | bash
</pre>
- Put Firmware, Keys in /bios/switch/keys and /bios/switch/firmware
<br></br>

**INITIAL CHANGES FROM CODE BASE**

- Introduced Text-Base Menu (dialog)
- Completely Offline Option (if you wish)
- Switched to AppImage for All Emulators
- Emulator AppImage Not Found Locally will Attempt to Get Remotely
- Ability to Select Individual Emulators to Install
- Update Emulator AppImage
- Citron downloads the latest nightly Linux x86_64_v3 AppImage when no local
  AppImage is available. The remote update option downloads the latest release;
  otherwise, an existing local AppImage is reused for offline installations.
- Separate Firmware & Keys for Ryujinx & Yuzu (+Forks)
- Changed Saves to now reflect NAND structure for easier backup
- Backup Saves from Menu (working on restore function)
- Uninstall BSA from Menu
- See File Structures Below

<br></br>
 
**NOTE**

DOES NOT INCLUDE
- Firmware
- Keys
- ROMs
- Emulators

<br></br>
<br></br>
