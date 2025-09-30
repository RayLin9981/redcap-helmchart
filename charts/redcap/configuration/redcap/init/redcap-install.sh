#!/bin/sh

# Name: redcap_install_manual
# Version: 1.0
# Author: Custom
# Description: Installs REDCap from a manually uploaded ZIP file.

#####################
### GLOBAL CONFIG ###
#####################
set -e
REDCAP_INSTALL=1
ZIP_SOURCE="/tmp/redcap/redcap.zip"
CHECK_INTERVAL=60   # 每次檢查間隔秒數
CHECK_COUNT=0       # 檢查次數計數器

#############################
### FUNCTION DECLARATIONS ###
#############################

# 等待使用者上傳 redcap.zip
wait_for_zip () {
    echo "[INFO] Waiting for REDCap package to be uploaded at $ZIP_SOURCE"

    while [ ! -f "$ZIP_SOURCE" ]; do
        CHECK_COUNT=$((CHECK_COUNT + 1))
        echo "[WAIT] ($CHECK_COUNT) File not found, checking again in ${CHECK_INTERVAL}s..."
        sleep "$CHECK_INTERVAL"
    done

    echo "[INFO] Found REDCap package after $CHECK_COUNT checks."
}

# 安裝 REDCap
install_redcap () {
    if [ "$REDCAP_INSTALL" = 1 ]; then
        echo "[INFO] Installing REDCap version $REDCAP_VERSION from scratch"
        echo "[INFO] Cleaning destination dir"
        rm -rvf "${REDCAP_INSTALL_PATH:?}/*"
    else
        echo "[INFO] Upgrading REDCap, preserving existing installation"
    fi

    echo "[INFO] Extracting REDCap package from $ZIP_SOURCE"
    unzip -o "$ZIP_SOURCE" -d /tmp/redcap
    cp -rvf /tmp/redcap/redcap/* "${REDCAP_INSTALL_PATH}/"

    echo "[INFO] Applying CRLF EOF bugfix to installed REDCap package"
    find "${REDCAP_INSTALL_PATH}" -type f -name '*.php' -print0 | xargs -0 dos2unix

    echo "[INFO] Cleaning temporary files"
    rm -rvf "/tmp/redcap/*"

    echo "[INFO] Installation done!"
}

# 更新 database.php
update_database_config () {
    echo "[INFO] Injecting REDCap database configuration"
    cp -f /tmp/conf/database.php "${REDCAP_INSTALL_PATH}/database.php"
    echo "[INFO] REDCap Database configuration updated!"
}

##########################
### SCRIPT STARTS HERE ###
##########################
echo "[INFO] Starting REDCap manual installation script v1.0"

wait_for_zip
install_redcap
update_database_config

echo "[INFO] REDCap version $REDCAP_VERSION has been correctly installed."
exit 0

