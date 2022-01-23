#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "You must be root to do this." 1>&2
   exit 1
fi

apt update
apt upgrade -y
apt install -u apt-transport-https ca-certificates software-properties-common make fish
chsh -s /usr/bin/fish
curl -fsSL https://starship.rs/install.sh | bash
mkdir -p ~/.config/fish
echo "starship init fish | source" >>  ~/.config/fish/config.fish
#mkdir -p ~/.config && touch ~/.config/starship.toml
#eprintf "[hostname]\ndisabled = true" >>  ~/.config/starship.toml

#
# https://github.com/linuxserver/docker-radarr/issues/118
#

wget http://ftp.us.debian.org/debian/pool/main/libs/libseccomp/libseccomp2_2.4.4-1~bpo10+1_armhf.deb
dpkg -i libseccomp2_2.4.4-1~bpo10+1_armhf.deb
rm -f libseccomp2_2.4.4-1~bpo10+1_armhf.deb

#
# Mounts and directories
#

apt install -u cifs-utils postfix samba samba-common-bin smbclient
# add disable netbios = yes to [global] section of /etc/samba/smb.conf
#sudo systemctl stop nmbd.service
#sudo systemctl mask nmbd.service
#sudo systemctl disable nmbd.service
mkdir /media/NFS
echo "192.168.1.162:/mnt/md0/media /media/NFS  nfs      defaults    0       0" >> /etc/fstab
mount /media/NFS

mkdir /media/Backup
echo "//192.168.1.162/backup /media/Backup  cifs  username=admin,password=??????,iocharset=utf8,uid=1000,gid=1000,file_mode=0777,dir_mode=0777,nodfs  0  0" >> /etc/fstab
mount /media/Backup

# mkdir /media/Torrents
# echo "192.168.1.112:/nfs/Torrents /media/Torrents  nfs      defaults    0       0" >> /etc/fstab
# mount /media/Torrents

# Disable zeroconf to stop RPI appearing in Finder
#sudo systemctl stop avahi-daemon.socket avahi-daemon.service
#sudo systemctl mask avahi-daemon.socket avahi-daemon.service
#sudo systemctl disable avahi-daemon.socket avahi-daemon.service

mkdir -p /var/media/{plex,sonarr,tautulli}

wget -O /var/media/tautulli/tautulli2trakt.sh https://raw.githubusercontent.com/Generator/tautulli2trakt/master/tautulli2trakt.sh
chmod +x /var/media/tautulli/tautulli2trakt.sh

#
# Docker
#
curl -sSL https://get.docker.com | sh
usermod -aG docker pi

#
# Docker compose
#

apt install -y libffi-dev libssl-dev python3 python3-pip sqlite3
pip3 install docker-compose

#
# Cronjobs for backing up data and updating
#

# (crontab -l 2>/dev/null; echo '30 3 * * * PATH=$PATH:/usr/local/bin /home/pi/rpi4/media-center/update.sh') | crontab -
# (crontab -l 2>/dev/null; echo '30 4 * * * PATH=$PATH:/usr/local/bin /home/pi/rpi4/media-center/backup.sh') | crontab -

#
# Disable Password Login via SSH
#

# sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
# sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
# sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
# sed -i 's/^UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config

#
# Homebridge
#

# NodeJS
curl -sL https://deb.nodesource.com/setup_12.x | bash -
apt install -y nodejs gcc g++ python net-tools

# Needed for Bluetooth for Govee
# apt install -y pi-bluetooth
apt install -y bluetooth bluez libbluetooth-dev libudev-dev

# Needed for Ecovac
apt install -y build-essential libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev

# Install Homebridge
npm install -g --unsafe-perm homebridge homebridge-config-ui-x @abandonware/noble
sudo hb-service install --user homebridge

#
# Internet Monitoring
#

mkdir -p /var/lib/{prometheus,grafana}

#
# Profile
#

rm -f $HOME/.bash_prompt $HOME/.profile $HOME/.bashrc $HOME/.dircolors
ln -s $HOME/rpi4/shell/.bash_prompt $HOME/.bash_prompt
ln -s $HOME/rpi4/shell/.profile $HOME/.profile
ln -s $HOME/rpi4/shell/.bashrc $HOME/.bashrc
ln -s $HOME/rpi4/shell/.dircolors $HOME/.dircolors
mkdir $HOME/.ssh
