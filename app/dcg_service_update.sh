#!/usr/bin/env bash
# BATOCERA - SWITCH ADD-ON

LOG_DIR="/userdata/DreamerCGToolBox/logs"
LOG="$LOG_DIR/update_toolbox.log"

VERSION_FILE="/userdata/DreamerCGToolBox/configgen-version.txt"
VERSION_URL="https://raw.githubusercontent.com/DreamerCG/dcgtoolbox/main/configgen-version.txt"

echo "[$(date)] Batocera Version   : $VERSION_URL"

# Récupération de la version principale de Batocera
batocera_version=$(batocera-es-swissknife --version | grep -oE '^[0-9]+')

set -u
unset folder_update_version || true

case "$batocera_version" in
	41)
		folder_update_version=41
		;;
	4[2-4])
		folder_update_version=42
		;;
	*)
		echo "Unsupported Batocera version: $batocera_version" >&2
		exit 1
		;;
esac


# Sécurité : création du dossier de logs AVANT toute redirection
mkdir -p "$LOG_DIR"

# Duplication sortie écran + log
exec > >(tee -a "$LOG") 2>&1

echo "[$(date)] ===== START TOOLBOX UPDATE ====="

# Nettoyage de l'ancien système de compatibilité, désormais remplacé par le
# lancement natif de Batocera 44.
DIR_CONFIGGEN_USER="/userdata/system/switch/configgen"
if [ -d "$DIR_CONFIGGEN_USER/compat" ]; then
    if rm -rf "$DIR_CONFIGGEN_USER/compat"; then
        echo "[$(date)] Suppression de l'ancien dossier configgen/compat"
    else
        echo "[$(date)] ERREUR : impossible de supprimer $DIR_CONFIGGEN_USER/compat"
        exit 1
    fi
fi

# Version locale
if [ -f "$VERSION_FILE" ]; then
    toolbox_version_local="$(tr -d '\r\n' < "$VERSION_FILE")"
else
    toolbox_version_local="none"
fi

# Version distante
toolbox_download_version="$(curl -sL "$VERSION_URL" | tr -d '\r\n')"

echo "[$(date)] Version de Batocera Version   : $batocera_version"
echo "[$(date)] Dossier utilisé   : $folder_update_version"
echo "[$(date)] Local Version   : $toolbox_version_local"
echo "[$(date)] Distant Version : $toolbox_download_version"

# Sécurité : si curl échoue
if [ -z "$toolbox_download_version" ]; then
    echo "[$(date)] ERREUR : impossible de récupérer la version distante"
    exit 1
fi

# Installation ou mise à jour
if [ "$toolbox_version_local" != "$toolbox_download_version" ]; then
    if [ -z "$toolbox_version_local" ]; then
        echo "[$(date)] Aucune version détectée, installation des configgens…"
    else
        echo "[$(date)] Mise à jour détectée ($toolbox_version_local → $toolbox_download_version)"
    fi
    echo "[$(date)] Lancement par précautions du téléchargement des configgen…"

    # Configuration des dossiers pour updates
    DIR_TOOLBOX="/userdata/DreamerCGToolBox/"
    DIR_EMULATIONSTATION="/userdata/system/configs/emulationstation"
    DIR_ROM_SWITCH="/userdata/roms/switch"
    DIR_ROM_IMAGES_SWITCH="/userdata/roms/switch/images"
    DIR_ROM_PORT="/userdata/roms/ports"
    DIR_SWITCH="/userdata/system/switch"
    DIR_SWITCH_LOCAL_BIN="/userdata/system/switch/bin"

    # echo "[$(date)] DEBUG folder_version=$folder_update_version"

    ULR_BIN="https://raw.githubusercontent.com/DreamerCG/dcgtoolbox/main/install/$folder_update_version/system/switch/extra/packages"
	URL_ROM_INSTALL="https://raw.githubusercontent.com/DreamerCG/dcgtoolbox/main/install/roms/switch"
    URL_ROM_IMAGE_INSTALL="https://raw.githubusercontent.com/DreamerCG/dcgtoolbox/main/install/roms/switch/images"

    mkdir -p "$DIR_TOOLBOX"
    mkdir -p "$DIR_ROM_IMAGES_SWITCH"

	echo "[$(date)] Switch Local Dir     : $DIR_SWITCH"
	echo "[$(date)] Image Local Dir  : $DIR_ROM_IMAGES_SWITCH"

    # Prépare une copie complète de system/switch depuis le dépôt, sans
    # télécharger appimages : ce dossier appartient à l'utilisateur.
    SWITCH_PREFIX="install/$folder_update_version/system/switch/"
    SWITCH_TREE_URL="https://api.github.com/repos/DreamerCG/dcgtoolbox/git/trees/main?recursive=1"
    SWITCH_TMP="$(mktemp -d /userdata/system/.switch-update.XXXXXX)"
    SWITCH_STAGE="$SWITCH_TMP/switch"
    mkdir -p "$SWITCH_STAGE"

    if ! curl -fsSL "$SWITCH_TREE_URL" -o "$SWITCH_TMP/tree.json"; then
        echo "[$(date)] ERREUR : impossible de récupérer l'arborescence GitHub pour switch"
        rm -rf "$SWITCH_TMP"
        exit 1
    fi

    if ! python3 - "$SWITCH_TMP/tree.json" "$SWITCH_PREFIX" > "$SWITCH_TMP/files.txt" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as tree_file:
    tree = json.load(tree_file)
if tree.get("truncated"):
    raise SystemExit("GitHub a retourné une arborescence tronquée")
prefix = sys.argv[2]
files = [(item["mode"], item["path"]) for item in tree.get("tree", [])
         if item.get("type") == "blob"
         and item.get("path", "").startswith(prefix)
         and not item["path"].startswith(prefix + "appimages/")]
if not files:
    raise SystemExit("Aucun fichier trouvé dans " + prefix)
print("\n".join(mode + "\t" + path for mode, path in files))
PY
    then
        echo "[$(date)] ERREUR : impossible de lister les fichiers du dossier switch"
        rm -rf "$SWITCH_TMP"
        exit 1
    fi

    while IFS=$'\t' read -r switch_mode switch_file; do
        switch_relative="${switch_file#"$SWITCH_PREFIX"}"
        switch_target="$SWITCH_STAGE/$switch_relative"
        mkdir -p "$(dirname "$switch_target")"
        if ! curl -fsSL "https://raw.githubusercontent.com/DreamerCG/dcgtoolbox/main/$switch_file" -o "$switch_target"; then
            echo "[$(date)] ERREUR : téléchargement impossible pour $switch_file"
            rm -rf "$SWITCH_TMP"
            exit 1
        fi
        if [ "$switch_mode" = "100755" ]; then
            chmod a+x "$switch_target"
        fi
    done < "$SWITCH_TMP/files.txt"

    # Conserve appimages, met de côté l'ancien dossier, puis installe la
    # nouvelle arborescence. En cas d'échec, restaure l'ancien dossier.
    if [ -d "$DIR_SWITCH/appimages" ]; then
        mv "$DIR_SWITCH/appimages" "$SWITCH_TMP/appimages" || {
            echo "[$(date)] ERREUR : impossible de préserver $DIR_SWITCH/appimages"
            rm -rf "$SWITCH_TMP"
            exit 1
        }
    fi
    if [ -e "$DIR_SWITCH" ]; then
        mv "$DIR_SWITCH" "$SWITCH_TMP/old-switch" || {
            [ ! -d "$SWITCH_TMP/appimages" ] || mv "$SWITCH_TMP/appimages" "$DIR_SWITCH/appimages"
            echo "[$(date)] ERREUR : impossible de mettre de côté $DIR_SWITCH"
            rm -rf "$SWITCH_TMP"
            exit 1
        }
    fi
    if ! mv "$SWITCH_STAGE" "$DIR_SWITCH"; then
        [ ! -e "$SWITCH_TMP/old-switch" ] || mv "$SWITCH_TMP/old-switch" "$DIR_SWITCH"
        [ ! -d "$SWITCH_TMP/appimages" ] || mv "$SWITCH_TMP/appimages" "$DIR_SWITCH/appimages"
        echo "[$(date)] ERREUR : impossible d'installer le nouveau dossier switch"
        rm -rf "$SWITCH_TMP"
        exit 1
    fi
    if [ -d "$SWITCH_TMP/appimages" ]; then
        if ! mv "$SWITCH_TMP/appimages" "$DIR_SWITCH/appimages"; then
            rm -rf "$DIR_SWITCH"
            mv "$SWITCH_TMP/old-switch" "$DIR_SWITCH"
            mv "$SWITCH_TMP/appimages" "$DIR_SWITCH/appimages"
            echo "[$(date)] ERREUR : impossible de restaurer appimages après la mise à jour"
            rm -rf "$SWITCH_TMP"
            exit 1
        fi
    fi
    rm -rf "$SWITCH_TMP"
    echo "[$(date)] Remplacement complet de system/switch effectué (appimages préservé)"

    # Ces scripts sont lancés directement par Batocera, même si Git les marque
    # comme fichiers non exécutables.
    chmod a+x "$DIR_SWITCH/configgen/switchlauncher.py"
    chmod a+x "$DIR_SWITCH/configgen/generators/edenGenerator.py"
    chmod a+x "$DIR_SWITCH/configgen/generators/ryujinxGenerator.py"
    chmod a+x "$DIR_SWITCH/configgen/generators/ryujinxloadfirmware.sh"

    mkdir -p "$DIR_SWITCH_LOCAL_BIN/xdgfix"

    curl -sL "$ULR_BIN/folder-open" -o "$DIR_SWITCH_LOCAL_BIN/xdgfix/xdg-open"
    echo "[$(date)] Mise à jour de bin/xdgfix/xdg-open"

    curl -sL "$VERSION_URL" -o "$DIR_TOOLBOX/configgen-version.txt"
    echo "[$(date)] Mise à jour de configgen-version.txt"

    # Mise à jour du BSA
    curl -fsL \
    "https://raw.githubusercontent.com/DreamerCG/dcgtoolbox/refs/heads/main/BSA.sh" \
    -o "$DIR_TOOLBOX/BSA.sh"
    chmod a+x "$DIR_TOOLBOX/BSA.sh"

    # Mise à jour du Switch Features
    curl -fsL \
    "https://raw.githubusercontent.com/DreamerCG/dcgtoolbox/main/install/$folder_update_version/system/configs/emulationstation/es_features_switch.cfg" \
    -o "$DIR_EMULATIONSTATION/es_features_switch.cfg"

    echo "[$(date)] Mise à jour de es_features_switch"

    # Mise à jour du Switch System
    curl -fsL \
    "https://raw.githubusercontent.com/DreamerCG/dcgtoolbox/main/install/$folder_update_version/system/configs/emulationstation/es_systems_switch.cfg" \
    -o "$DIR_EMULATIONSTATION/es_systems_switch.cfg"

    echo "[$(date)] Mise à jour de es_systems_switch"

    chmod a+x "$DIR_SWITCH_LOCAL_BIN/xdgfix/xdg-open"

    #On Verifie si les roms suivants existe dans /userdata/roms/switch/
	gamelist_file="/userdata/roms/switch/gamelist.xml"
	# Ensure the gamelist.xml exists
	if [ ! -f "$gamelist_file" ]; then
		echo '<?xml version="1.0" encoding="UTF-8"?><gameList></gameList>' > "$gamelist_file"
	fi

    FILES=(
        "citron_config.xci_config"
        "eden_config.xci_config"
        "ryujinx_config.xci_config"
        "eden_qlaunch.xci_config"
    )


    # Noms personnalisés
    declare -A NOMS_PERSONNALISES
    NOMS_PERSONNALISES=(
        ["citron_config.xci_config"]="Configuration de Citron Toolbox"
        ["eden_config.xci_config"]="Configuration de Eden Toolbox"
        ["ryujinx_config.xci_config"]="Configuration de Ryujinx Toolbox"
        ["eden_qlaunch.xci_config"]="Eden QLauncher"
    )

# Boucle sur chaque fichier
for FILE in "${FILES[@]}"; do
    FILEPATH="$DIR_ROM_SWITCH/$FILE"
    URL="$URL_ROM_INSTALL/$FILE"
    BASENAME="${FILE%.*}"
    # Si un nom personnalisé existe, on le prend, sinon fallback sur BASENAME
    NOM="${NOMS_PERSONNALISES[$FILE]:-$BASENAME}"

    if [ -f "$FILEPATH" ]; then
        echo "[$(date)] Le fichier '$FILE' existe déjà, téléchargement ignoré."
    else
        echo "Téléchargement de '$FILE'..."
        curl -fsL "$URL" -o "$FILEPATH"
        if [ $? -eq 0 ]; then
            echo "[$(date)] Téléchargement de '$FILE' terminé avec succès."

            xmlstarlet ed -L \
                -d "/gameList/game[path='./$FILE']" \
                -s "/gameList" -t elem -n "game" -v "" \
                -s "/gameList/game[last()]" -t elem -n "path" -v "./$FILE" \
                -s "/gameList/game[last()]" -t elem -n "name" -v "$NOM" \
                -s "/gameList/game[last()]" -t elem -n "desc" -v "$NOM" \
                -s "/gameList/game[last()]" -t elem -n "developer" -v "$NOM" \
                -s "/gameList/game[last()]" -t elem -n "publisher" -v "$NOM" \
                -s "/gameList/game[last()]" -t elem -n "genre" -v "Toolbox" \
                -s "/gameList/game[last()]" -t elem -n "rating" -v "1.00" \
                -s "/gameList/game[last()]" -t elem -n "region" -v "eu" \
                -s "/gameList/game[last()]" -t elem -n "lang" -v "fr" \
                -s "/gameList/game[last()]" -t elem -n "image" -v "./images/$BASENAME-image.png" \
                -s "/gameList/game[last()]" -t elem -n "marquee" -v "./images/$BASENAME-logo.png" \
                -s "/gameList/game[last()]" -t elem -n "thumbnail" -v "./images/$BASENAME.png" \
                "$gamelist_file"

            echo "[$(date)] - Ajout de $NOM dans la game list $gamelist_file"
        else
            echo "[$(date)] Erreur lors du téléchargement de '$FILE' !"
        fi
    fi
done

# Ajout des images
    FILES_IMAGES=(
        "citron_config.png"
        "citron_config-logo.png"
        "citron_config-image.png"
        "eden_config.png"
        "eden_config-logo.png"
        "eden_config-image.png"
        "eden_qlaunch.png"
        "eden_qlaunch-logo.png"
        "eden_qlaunch-image.png"        
        "ryujinx_config.png"
        "ryujinx_config-logo.png"
        "ryujinx_config-image.png"
    )

    # Boucle sur chaque fichier
    for FILE in "${FILES_IMAGES[@]}"; do
        FILEPATH="$DIR_ROM_IMAGES_SWITCH/$FILE"
        URL="$URL_ROM_IMAGE_INSTALL/$FILE"

        if [ -f "$FILEPATH" ]; then
            echo "[$(date)]Le fichier '$FILE' existe déjà, téléchargement ignoré."
        else
            echo "[$(date)] Téléchargement de '$FILE'..."
            curl -fsL "$URL" -o "$FILEPATH"
            if [ $? -eq 0 ]; then
                echo "[$(date)] Téléchargement de '$FILE' terminé avec succès."
            else
                echo "[$(date)] Erreur lors du téléchargement de '$FILE' à partir de $URL  !"
            fi
        fi
    done

    # Suppression des anciens Ports Configs
    FILES_CONFIG_SH=(
        "ryujinx_config.sh"
        "ryujinx_config.sh.keys"
        "citron_config.sh"
        "citron_config.sh.keys"
        "yuzu_config.sh"
        "yuzu_config.sh.keys"
    )

    # Boucle sur chaque fichier
    for FILE in "${FILES_CONFIG_SH[@]}"; do
        FILEPATH="$DIR_ROM_PORT/$FILE"

        if [ -f "$FILEPATH" ]; then
             echo "[$(date)] Suppression de $FILE"
             rm $FILEPATH
            
        fi
    done

    # Nettoyage complementaire
        if [ -f "$DIR_SWITCH/configgen/generators/gamecontroller_ryujinx.txt" ]; then
             echo "[$(date)] Suppression de $DIR_SWITCH/configgen/generators/gamecontroller_ryujinx.txt"
             rm "$DIR_SWITCH/configgen/generators/gamecontroller_ryujinx.txt"
        fi  

        if [ -f "$DIR_SWITCH_LOCAL_BIN/folder-open" ]; then
             echo "[$(date)] Suppression de $DIR_SWITCH_LOCAL_BIN/folder-open"
             rm $DIR_SWITCH_LOCAL_BIN/folder-open
        fi            
          
    echo "[$(date)] Nettoyage de fichier divers"
    
else
    echo "[$(date)] Toolbox déjà à jour (version $toolbox_version_local)"
fi

echo "[$(date)] ===== END TOOLBOX UPDATE ====="
