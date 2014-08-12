#! /bash/sh

# WiFI configuration
SSID=""
PSK=""

# Configure WiFi adapter
echo "
network={
        ssid=\"$SSID\"
        psk=\"$PSK\"
        scan_ssid=1
        key_mgmt=WPA-PSK
        pairwise=CCMP
        group=CCMP
}
" >> /etc/wpa_supplicant/wpa_supplicant.conf
ifdown wlan0
ifup wlan0

# Disable WiFi adapter's power management
echo "# Disable power management
options 8192cu rtw_power_mgnt=0
" >> /etc/modprobe.d/8192cu.conf

# Enable I2C kernel module
sed -e "s/blacklist i2c-bcm2708/# blacklist i2c-bcm2708/" /etc/modprobe.d/raspi-blacklist.conf > /etc/modprobe.d/raspi-blacklist.conf > 
echo "i2c-dev
" >> /etc/modules

# Install apache2
apt-get update
apt-get install -y apache2

# Install munin and configure its access control
apt-get install -y munin
sed -e "s/        Allow from localhost 127.0.0.0/8 ::1/        # Allow from localhost 127.0.0.0/8 ::1/\n        Allow from all" /etc/munin/apache.conf > /etc/munin/apache.conf
