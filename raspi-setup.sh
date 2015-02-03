#! /bash/sh

#
# WiFi configuration
#
SSID=""
PSK=""

#
# IP notification configuration
#
MAIL=""
PASSWORD=""

#
# Configure WiFi adapter
#
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

#
# Setup IP notification script
#
cd
mkdir Python
cd Python
git clone https://github.com/takagi/rpip.git
sed -i -e "s/foo@example\.com/$MAIL/" rpip/rpip.py
sed -i -e "s/password/$PASSWORD/" rpip/rpip.py
sed -i -e "/exit 0/i # Notify the IP address\npython \/home\/pi\/Python\/rpip\/rpip.py\n" /etc/rc.local
cd

#
# Enable I2C kernel module
#
sed -i -e "s/blacklist i2c-bcm2708/# blacklist i2c-bcm2708/" /etc/modprobe.d/raspi-blacklist.conf
echo "i2c-dev
" >> /etc/modules

#
# Install apache2
#
apt-get update
apt-get install -y apache2

#
# Install munin and configure its access control
#
apt-get install -y munin
sed -i -e "s/        Allow from localhost 127.0.0.0\/8 ::1/        # Allow from localhost 127.0.0.0\/8 ::1\n        Allow from all/" /etc/munin/apache.conf
/etc/init.d/apache2 restart

#
# Build am2321 and setup munin plugins
#
cd
git clone https://github.com/takagi/am2321.git
cd am2321
sed -i -e "s/\/dev\/i2c-0/\/dev\/i2c-1/"
gcc -o am2321 am2321.c
cp temperature /etc/munin/plugins/
cp humidity /etc/munin/plugins/
chmod +x /etc/munin/plugins/temperature
chmod +x /etc/munin/plugins/humidity
echo "[temperature]
user root" > /etc/munin/plugin-conf.d/temperature
echo "[humidity]
user root" > /etc/munin/plugin-conf.d/humidity
/etc/init.d/munin-node restart
sudo -u munin munin-cron
cd

exit 0

