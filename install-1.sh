#!/bin/bash

sudo dnf update -y

#egpu setup
# remove for reinstallation
# sudo rm -f /etc/X11/xorg.conf.internal /etc/X11/xorg.conf.internal /etc/systemd/system/egpu.service /usr/local/bin/egpu
for FILE in "/usr/local/bin/egpu" "/etc/systemd/system/egpu.service" "/etc/X11/xorg.conf.egpu" "/etc/X11/xorg.conf.internal"; do
    
    FILE_BASENAME=$(sudo basename $FILE)

    if [ ! -f $FILE ]; then
        echo "Installing $FILE from https://raw.githubusercontent.com/claudio-walser/egpu-setup/master/${FILE_BASENAME}"
        sudo curl https://raw.githubusercontent.com/claudio-walser/egpu-setup/master/${FILE_BASENAME} -o $FILE $>/dev/null
    else
        echo "$FILE already installed"
    fi
done

if [ ! -x /usr/local/bin/egpu ]; then
    echo "chmod +x /usr/local/bin/egpu"
    sudo chmod +x /usr/local/bin/egpu
fi

systemctl status egpu.service $>/dev/null

if [ $? = 3 ]; then
    sudo systemctl daemon-reload
fi

systemctl status egpu.service | grep disabled
if [ $? = 0 ]; then
    sudo systemctl enable egpu.service
fi


# install rpmfusion shizzle
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# install nvidia driver
sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda

#echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf

# install some flatpaks
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.sublimetext.three
flatpak install -y flathub org.videolan.VLC
flatpak install -y flathub com.slack.Slack


# install yubikey
sudo dnf install -y pam_yubico
sudo dnf install -y yubikey-manager.noarch

sudo dnf install -y gstreamer1-plugins-bad-free gstreamer1-plugin-openh264

# install nice themes
sudo dnf install -y arc-theme gnome-tweak-tool gtk-murrine-engine
cd /tmp
git clone https://github.com/horst3180/arc-icon-theme && cd arc-icon-theme
mv ./Arc ~/.icons
cd ..
rm -rf ./arc-icon-theme
