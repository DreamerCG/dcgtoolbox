#!/usr/bin/python
# -*- coding: utf-8 -*-
import re
import sys
import os
from pathlib import Path
from importlib import import_module

import xml.etree.ElementTree as ET
import yaml
import configgen
from configgen.emulatorlauncher import launch

# Chargemnet des LIB SDL3 pour switch
paths_to_check = ["/usr/lib/libSDL3.so", "/usr/lib/libSDL3.so.0"]
target_lib = "/userdata/system/switch/lib/libSDL3.so.0.2.26"

for path in paths_to_check:
    if not os.path.exists(path):
        # Supprime le symlink si il existe mais est cassé
        if os.path.islink(path):
            os.unlink(path)
        # Création du symlink
        os.symlink(target_lib, path)
        print(f"Symlink créé : {path} -> {target_lib}")
    else:
        print(f"{path} existe déjà.")

# Chargement personnalisé de la config switch
_old_get_system_config = configgen.emulatorlauncher.Emulator.get_system_config

def _new_get_system_config(system, defaultyml, defaultarchyml):
    # --- charge le YAML par défaut ---
    cfg_defaults = {}
    if os.path.exists(defaultyml):
        with open(defaultyml, "r") as f:
            cfg_defaults_all = yaml.safe_load(f)
            if cfg_defaults_all and "default" in cfg_defaults_all:
                cfg_defaults = cfg_defaults_all["default"].copy()
            if cfg_defaults_all and system in cfg_defaults_all:
                configgen.emulatorlauncher.Emulator.dict_merge(cfg_defaults, cfg_defaults_all[system])

    # --- charge ton YAML personnalisé ---
    custom_file = "/userdata/system/switch/configgen/configgen-defaults.yml"
    cfg_custom = {}
    if os.path.exists(custom_file):
        with open(custom_file, "r") as f:
            cfg_custom_all = yaml.safe_load(f)
            if cfg_custom_all and system in cfg_custom_all:
                cfg_custom = cfg_custom_all[system]

    # --- fusionne custom > defaults ---
    configgen.emulatorlauncher.Emulator.dict_merge(cfg_defaults, cfg_custom)

    # --- construit dict_result ---
    dict_result = {
        "emulator": cfg_defaults.get("emulator", ""),
        "core": cfg_defaults.get("core", "")
    }
    if "options" in cfg_defaults:
        configgen.emulatorlauncher.Emulator.dict_merge(dict_result, cfg_defaults["options"])

    return dict_result

# --- patch ---
configgen.emulatorlauncher.Emulator.get_system_config = _new_get_system_config

rom = None
if "-rom" in sys.argv:
    rom = sys.argv[sys.argv.index("-rom") + 1]

def _new_get_generator(emulator: str):
    
    yuzuemu = {}
    yuzuemu['eden-emu'] = 1
    yuzuemu['citron-emu'] = 1
    yuzuemu['eden-pgo'] = 1
    yuzuemu['eden-nighlty'] = 1
    
    rom_nameq = os.path.basename(rom)
    if rom_nameq == 'ryujinx_config.xci_config':
        emulator = 'ryujinx-emu'    
    
    print(f"Selected emulator: {emulator}", file=sys.stderr)    
    print(f"Selected Rom : {rom_nameq}", file=sys.stderr)    
    
    if emulator in yuzuemu:
        from generators.edenGenerator import EdenGenerator
        return EdenGenerator()

    if emulator == 'ryujinx-emu':
        from generators.ryujinxGenerator import RyujinxGenerator
        return RyujinxGenerator()

    #fallback to batocera generators
    return get_generator(emulator)

configgen.emulatorlauncher.get_generator = _new_get_generator

if __name__ == "__main__":
    sys.argv[0] = re.sub(r"(-script\.pyw|\.exe)?$", "", sys.argv[0])
    sys.exit(launch())