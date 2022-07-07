#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "You must be root to do this." 1>&2
   exit 1
fi

apt update
apt upgrade -y
apt install -u apt-transport-https ca-certificates software-properties-common make fish
chsh -s /usr/bin/fish
curl -fsSL https://starship.rs/install.sh | sh
mkdir -p ~/.config/fish
echo "starship init fish | source" >>  ~/.config/fish/config.fish
mkdir -p ~/.config && touch ~/.config/starship.toml
printf "[hostname]\ndisabled = true" >>  ~/.config/starship.toml

curl -LJO https://github.com/r-darwish/topgrade/releases/download/v9.0.1/topgrade-v9.0.1-aarch64-unknown-linux-gnu.tar.gz
tar zvxf topgrade-v9.0.1-aarch64-unknown-linux-gnu.tar.gz
rm -f topgrade-v9.0.1-aarch64-unknown-linux-gnu.tar.gz
sudo mv topgrade /usr/local/bin

#
# https://github.com/linuxserver/docker-radarr/issues/118
#

# wget http://ftp.us.debian.org/debian/pool/main/libs/libseccomp/libseccomp2_2.4.4-1~bpo10+1_armhf.deb
# dpkg -i libseccomp2_2.4.4-1~bpo10+1_armhf.deb
# rm -f libseccomp2_2.4.4-1~bpo10+1_armhf.deb

#
# Mounts and directories
#

mkdir /media/Media
sudo echo "192.168.115.136:/mnt/md0/media /media/Media  nfs      defaults    0       0" >> /etc/fstab
mount /media/Media

mkdir /media/Backup
echo "192.168.115.136:/mnt/md0/backup /media/Backup  nfs      defaults    0       0" >> /etc/fstab
mount /media/Backup

mkdir -p /var/media/{plex,sonarr,tautulli,jackett,transmission,torrents,watch}

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

sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/^UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config

#
# Homebridge
#

# NodeJS
curl -sL https://deb.nodesource.com/setup_16.x | bash -
apt install -y nodejs gcc g++ python net-tools

# Needed for Ecovac
apt install -y build-essential libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev

# Install Homebridge
sudo npm install --location=global --unsafe-perm homebridge homebridge-config-ui-x
sudo npm install --location=global homebridge-pihole homebridge-deebotecovacs homebridge-webos-tv homebridge-cmdswitch2 homebridge-sony-audio
sudo hb-service install --user homebridge

# edit homebridge-sony-audio/dist/discoverer.js, add explicitSocketBind: true to node_ssdp_1.Client()

#
# Profile
#

rm -f $HOME/.bash_prompt $HOME/.profile $HOME/.bashrc $HOME/.dircolors
ln -s $HOME/rpi4/shell/.bash_prompt $HOME/.bash_prompt
ln -s $HOME/rpi4/shell/.profile $HOME/.profile
ln -s $HOME/rpi4/shell/.bashrc $HOME/.bashrc
ln -s $HOME/rpi4/shell/.dircolors $HOME/.dircolors
