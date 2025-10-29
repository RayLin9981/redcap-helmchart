#!/bin/sh

# Name: redcap_install_manual
# Version: 1.4
# Author: Custom (based on APHP original)
# Description:
#   Installs or upgrades REDCap from a manually uploaded ZIP file.
#   Preserves official structure and comments, but replaces online download
#   with manual ZIP upload detection and version check.

#####################
### GLOBAL CONFIG ###
#####################
set -e
REDCAP_INSTALL=1
ZIP_BASE="/tmp/redcap"
INSTALL_PATH="${REDCAP_INSTALL_PATH:-/app/redcap}"
CHECK_INTERVAL=30
CHECK_COUNT=0
REDCAP_PREFIX="redcap_v"

#############################
### FUNCTION DECLARATIONS ###
#############################

# Waits until the correct REDCap ZIP file has been uploaded manually
wait_for_zip () {
    echo "[INFO] Waiting for REDCap package to be uploaded..."
    while [ ! -f "$ZIP_SOURCE" ]; do
        CHECK_COUNT=$((CHECK_COUNT + 1))
        echo "[WAIT] ($CHECK_COUNT) File not found at $ZIP_SOURCE, checking again in ${CHECK_INTERVAL}s..."
        sleep "$CHECK_INTERVAL"
    done
    echo "[INFO] Found REDCap package after $CHECK_COUNT checks."
}

# Installs or upgrades REDCap from the detected ZIP file
install_redcap () {
    if [ "$REDCAP_INSTALL" = 1 ]; then
        echo "[INFO] Installing REDCap version $REDCAP_VERSION from scratch"
        echo "[INFO] Cleaning destination directory"
        rm -rvf "${INSTALL_PATH:?}/*"
    else
        echo "[INFO] Upgrading REDCap, preserving configuration and modules"
    fi

    echo "[INFO] Extracting REDCap package from $ZIP_SOURCE"
    unzip -o "$ZIP_SOURCE" -d "$ZIP_BASE"

    echo "[INFO] Copying extracted files into $INSTALL_PATH"
    cp -rvf "$ZIP_BASE/redcap/"* "$INSTALL_PATH/"

    echo "[INFO] Applying CRLF EOF bugfix"
    find "$INSTALL_PATH" -type f -name '*.php' -print0 | xargs -0 dos2unix || true

    echo "[INFO] Cleaning temporary files"
    rm -rvf "$ZIP_BASE/*"

    echo "[INFO] Installation completed."
}

# Updates database.php from mounted ConfigMap
update_database_config () {
    echo "[INFO] Injecting REDCap database configuration"
    cp -f /tmp/conf/database.php "${INSTALL_PATH}/database.php"
    echo "[INFO] Database configuration updated."
}

##########################
### SCRIPT STARTS HERE ###
##########################

echo "[INFO] Starting REDCap manual installation script v1.4"
echo "[INFO] Target version: ${REDCAP_VERSION}"

# Detect existing installation
CURRENT_VERSION=$(ls -d ${INSTALL_PATH}/${REDCAP_PREFIX}* 2>/dev/null | sort -V | tail -n1 | sed "s/.*${REDCAP_PREFIX}//")
if [ -n "$CURRENT_VERSION" ]; then
    echo "[INFO] Detected existing REDCap version: $CURRENT_VERSION"
else
    echo "[INFO] No existing REDCap installation detected."
fi

# Decide operation type before checking ZIP
if [ "$CURRENT_VERSION" = "$REDCAP_VERSION" ]; then
    echo "[INFO] Same version ($CURRENT_VERSION) already installed, skipping installation."
    exit 0
elif [ -n "$CURRENT_VERSION" ]; then
    echo "[INFO] Preparing to upgrade REDCap from $CURRENT_VERSION to $REDCAP_VERSION"
    REDCAP_INSTALL=0
    ZIP_SOURCE="${ZIP_BASE}/redcap_upgrade_${REDCAP_VERSION}.zip"
else
    echo "[INFO] Preparing to perform a fresh installation of REDCap $REDCAP_VERSION"
    REDCAP_INSTALL=1
    ZIP_SOURCE="${ZIP_BASE}/redcap_full_${REDCAP_VERSION}.zip"
fi

# Now wait for the correct ZIP to be uploaded
wait_for_zip

# Perform installation
install_redcap

# Update database configuration
update_database_config

echo "[INFO] REDCap version $REDCAP_VERSION installation or upgrade completed successfully."
exit 0
