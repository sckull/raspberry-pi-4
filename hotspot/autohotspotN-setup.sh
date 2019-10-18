#!/bin/bash
#The script is from km4ack's github.
#https://github.com/km4ack

#Functions
checkInstaller() {
    if hash hostapd 2>/dev/null; then
        hostapd "-v";
    else
    	echo "hostapd is not installed!";
        echo "Installing hostapd...";
		apt-get update;
		apt-get install hostapd -y;
    fi
    if hash dnsmasq 2>/dev/null; then
        dnsmasq "-v";
    else
    	echo "dnsmasq is not installed!";
        echo "Installing dnsmasq...";
        apt-get update;
		apt-get install dnsmasq -y;
    fi
}
stopServices(){
	#stop both services
	systemctl disable hostapd
	systemctl disable dnsmasq
}
checkIw(){
	#check if iw installed. install if not
	iwcheck=$(dpkg --get-selections | grep -w "iw")
	if [ -z "iw" ]; then
		apt-get install iw
	fi
}
wifipass () {
	echo;echo;
	echo "This password will be used to connect to the pi"
	echo "when the pi is in hotspot mode"
	read -p "Enter password to use with new hotspot " wifipasswd
	echo
	echo "You entered $wifipasswd"
	read -p "Is this correct? y/n " wifians
	if [ $wifians == "y" ]; then
		echo
	else
		wifipass
	fi
}
shackwifi1 () {
	#get ham's wifi credentials
	echo "¿What wifi SSID name would you like to connect to?"	
	read -p "SSID Name: " shackwifi
	echo "¿What is the password for this wifi?"
	read -p "Password:" shackpass
	echo
	echo "Your shack's current wifi is: $shackwifi"	
	echo "Password: $shackpass"
	echo "¿Is this correct? y/n"
	read shackans
	if [ $shackans == "y" ]; then	
		echo
	else
		shackwifi1
	fi
}

checkInstaller
stopServices

mkdir -p $HOME/temp

wifipass

cd $HOME/temp

wget https://raw.githubusercontent.com/sckull/raspberry-pi-4/master/hotspot/hostapd.txt

#set new hotspot passwd
sed -i "s/wpa_passphrase=1234567890/wpa_passphrase=$wifipasswd/" $HOME/temp/hostapd.txt
#set country to US
sed -i 's/country_code=GB/country_code=US/' $HOME/temp/hostapd.txt

#move hostapd to correct location
mv $HOME/temp/hostapd.txt /etc/hostapd/hostapd.conf

sed -i s'/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/' /etc/default/hostapd
sed -i s'/DAEMON_OPTS=""/#DAEMON_OPTS=""/' /etc/default/hostapd

#add needed info to dnsmasq.conf
echo "#AutoHotspot config" >> /etc/dnsmasq.conf
echo "interface=wlan0" >> /etc/dnsmasq.conf
echo "bind-dynamic" >> /etc/dnsmasq.conf
echo "server=8.8.8.8" >> /etc/dnsmasq.conf
echo "domain-needed" >> /etc/dnsmasq.conf
echo "bogus-priv" >> /etc/dnsmasq.conf
echo "dhcp-range=10.10.10.150,10.10.10.200,255.255.255.0,12h" >> /etc/dnsmasq.conf
echo "#Set up redirect for router.com" >> /etc/dnsmasq.conf
echo "dhcp-option=3,10.10.10.10" >> /etc/dnsmasq.conf
echo "address=/router.com/10.10.10.10" >> /etc/dnsmasq.conf

mv /etc/network/interfaces /etc/network/interfaces.org

echo "source-directory /etc/network/interfaces.d" >> /etc/network/interfaces


echo "nohook wpa_supplicant" >> /etc/dhcpcd.conf

#setup ip forward
sed 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf

cd $HOME/temp

wget https://raw.githubusercontent.com/sckull/raspberry-pi-4/master/hotspot/autohotspot-service.txt

#create autohotspot service file
mv autohotspot-service.txt /etc/systemd/system/autohotspot.service

#start autohotspot service
systemctl enable autohotspot.service
#CheckIW
checkIw

#install autohotspot script
cd $HOME/temp
wget https://raw.githubusercontent.com/sckull/raspberry-pi-4/master/hotspot/autohotspotN.txt
#mod ip address for our custom setup
sed -i 's/192.168.50.5/10.10.10.10/' autohotspotN.txt
mv autohotspotN.txt /usr/bin/autohotspotN
chmod +x /usr/bin/autohotspotN

#run shackwifi function
shackwifi1

#add shack wifi to wpa_supplicant.conf
echo "network={" >> /etc/wpa_supplicant/wpa_supplicant.conf
echo "ssid=\"$shackwifi\"" >> /etc/wpa_supplicant/wpa_supplicant.conf
echo "psk=\"$shackpass\"" >> /etc/wpa_supplicant/wpa_supplicant.conf
echo "key_mgmt=WPA-PSK" >> /etc/wpa_supplicant/wpa_supplicant.conf
echo "}" >> /etc/wpa_supplicant/wpa_supplicant.conf

#remove hostapd masked error on first run of hotspot
systemctl unmask hostapd

echo;echo;
echo "A reboot is required to complete the setup"
echo "Wifi/AutoHotSpot will not work until reboot"
