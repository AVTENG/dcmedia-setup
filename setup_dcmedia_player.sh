#!/usr/bin/env bash
#
# setup_dcmedia_player.sh
# Installs and launches the DC Media player in one go.
#
# Usage:
#   chmod +x setup_dcmedia_player.sh
#   ./setup_dcmedia_player.sh
#
# Run it as the normal user (not with sudo); it will ask for your
# sudo password when it needs root.

set -euo pipefail

# ---- Settings (change these if your username or path differs) ----
USERNAME="dcmedia"
INSTALL_DIR="/home/${USERNAME}/dcmedia_player"
INSTALLER_URL="https://www.dcmediads.com/support/downloads/install_ump.sh"
DISTRO="debian"
# -----------------------------------------------------------------

echo "==> Creating ${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}"
cd "${INSTALL_DIR}"

echo "==> Downloading installer"
wget -O install_ump.sh "${INSTALLER_URL}"
chmod +x install_ump.sh

echo "==> Running installer (sudo required)"
sudo ./install_ump.sh -u "${USERNAME}" -c "${DISTRO}" -p "${INSTALL_DIR}/"

echo "==> Setting ownership of ${INSTALL_DIR} to ${USERNAME}"
sudo chown -R "${USERNAME}" "${INSTALL_DIR}/"

cd "${INSTALL_DIR}"

if [[ ! -f chrome-sandbox ]]; then
    echo "ERROR: chrome-sandbox not found in ${INSTALL_DIR}. The installer may have failed." >&2
    exit 1
fi

echo "==> Fixing chrome-sandbox permissions"
sudo chown root:root chrome-sandbox
sudo chmod 4755 chrome-sandbox
ls -l chrome-sandbox

echo "==> Setting up autostart on login"
AUTOSTART_DIR="/home/${USERNAME}/.config/autostart"
mkdir -p "${AUTOSTART_DIR}"
cat > "${AUTOSTART_DIR}/dcmedia.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=DC Media
Exec=${INSTALL_DIR}/dcmediaplayer
Path=${INSTALL_DIR}
Terminal=false
EOF
chmod +x "${AUTOSTART_DIR}/dcmedia.desktop"
echo "    Created ${AUTOSTART_DIR}/dcmedia.desktop"

echo "==> Setup complete. Launching player..."
./dcmediaplayer
