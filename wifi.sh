#!/bin/bash

BACKTITLE="Void Linux Installer - Connect to wifi"

SSID=$(dialog --backtitle "$BACKTITLE" \
                     --title "SSID" \
                     --inputbox "Enter the network ssid" 10 60 3>&1 1>&2 2>&3)

PSK=$(dialog --backtitle "$BACKTITLE" \
                     --title "PSK" \
                     --inputbox "Enter the network passphrase" 10 60 3>&1 1>&2 2>&3)



(
    echo "Generating /etc/wpa_supplicant/wpa_supplicant.conf"
    cat <<EOF > /etc/wpa_supplicant/wpa_supplicant.conf
ctrl_interface=/run/wpa_supplicant
ctrl_interface_group=wheel
eapol_version=1
ap_scan=1
fast_reauth=1
update_config=1

network={
  ssid="$SSID"
  psk="$PSK"
}
EOF
    echo "Restarting wpa_supplicant service"
    sv restart wpa_supplicant

    echo "Waiting 10 seconds for connection to be up"
    sleep 10
    
    echo "Updating xbps and installing git and dialog"
    xbps-install -Syu xbps git dialog

    echo "Cloning void-scripts into /root/void-scripts"
    git clone https://github.com/Wragdan/void-scripts.git /root/void-scripts
) 2>&1 | dialog --title "$TITLE" --progressbox 30 70

