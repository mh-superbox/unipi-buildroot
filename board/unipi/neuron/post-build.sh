#!/bin/sh

set -u
set -e

# Add a console on tty1
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
	sed -i '/GENERIC_SERIAL/a\
tty1::respawn:/sbin/getty -L  tty1 0 vt100 # HDMI console' ${TARGET_DIR}/etc/inittab
fi

mkdir -p ${TARGET_DIR}/boot

# Init systemd
mkdir -p ${TARGET_DIR}/etc/systemd/system/multi-user.target.wants

# Enable resize root systemd service
ln -fs ../resize-root.service ${TARGET_DIR}/etc/systemd/system/multi-user.target.wants/resize-root.service

# Enable wifi check
#ln -fs /usr/lib/systemd/system/wpa_supplicant@.service ${TARGET_DIR}/etc/systemd/system/multi-user.target.wants/wpa_supplicant@wlan0.service

# Change Loglevel
grep -qE ' loglevel=3' ${BINARIES_DIR}/rpi-firmware/cmdline.txt || sed -i '$ s/$/ loglevel=3/' ${BINARIES_DIR}/rpi-firmware/cmdline.txt

# Update Systemd Journald
sed -i 's/#Storage=auto/Storage=volatile/g' ${TARGET_DIR}/etc/systemd/journald.conf

# Set ZSH for root user
sed -i '/^root:/s,:/bin/dash$,:/bin/zsh,' ${TARGET_DIR}/etc/passwd

# Permit ssh root login
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' ${TARGET_DIR}/etc/ssh/sshd_config

mkdir -p ${TARGET_DIR}/data