#!/bin/bash

if [ $(id -u) = 0 ]; then
   echo "This script changes your users gsettings and should thus not be run as root!"
   echo "You may need to enter your password multiple times!"
   exit 1
fi


while test $# -gt 0
do
    case "$1" in
        --nonfree) 
			echo "Nonfree Additions will be added"
			NONFREE=true
            ;;
        --steam) 
			echo "Adding Steam as flatpak to avoid fedora lib misaligment issues for games"
			STEAMFLAT=true
            ;;
    esac
    shift
done


# Some Kernel/Usability Improvements
sudo tee -a /etc/sysctl.d/40-max-user-watches.conf > /dev/null  <<EOF
fs.inotify.max_user_watches=524288
EOF

# Some Kernel/Usability Improvements
sudo tee -a /etc/sysctl.d/99-network.conf > /dev/null  <<EOF
net.ipv4.ip_forward=0
net.ipv4.tcp_ecn=1
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF

sudo tee -a /etc/sysctl.d/99-swappiness.conf > /dev/null  <<EOF
vm.swappiness=1
EOF


###
# Optionally clean all dnf temporary files
###

sudo dnf clean all

###
# RpmFusion Free Repo
# This is holding only open source, vetted applications - fedora just cant legally distribute them themselves thanks to 
# Software patents
###

sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm 

###
# RpmFusion NonFree Repo
# This includes Nvidia Drivers and more
###

if [ ! -z "$NONFREE" ]; then
	sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
fi


###
# Disable the Modular Repos
# Given the added load at updates, and the issues to keep modules updated, in check and listed from the awful cli for it - remove entirely.
###

sudo sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-updates-modular.repo
sudo sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-modular.repo

# Testing Repos should be disabled anyways
sudo sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-updates-testing-modular.repo
sudo sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/rpmfusion-free-updates-testing.repo

# Rpmfusion makes this obsolete
sudo sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-cisco-openh264.repo

# Disable Machine Counting for all repos
sudo sed -i 's/countme=1/countme=0/g' /etc/yum.repos.d/*

# vscodium, an open source fork of vscode
sudo tee -a /etc/pki/rpm-gpg/vscodium > /dev/null <<EOF
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQINBFu8c8sBEACrPcX4UB0rGFObGzIpa3fqJy0K//W5XENNBrGlk6DS68SwkSza
QFoD+ZoGiwGZWy+X5m2bm6A0j8ff61uKLZFx4turikggdqey6RL3NIQOmhzbz9jc
90ZtVG3W2VHwP1Oy2sITJBD1UdCtnRR7ONfoLVJbavPrjHL0VEJqV6kF7ki45DAK
yVbEGjsg668l8FmfMIYyoqV8HQ+JosXQ6ItOH2QlGwvD5RvBmIRzIXSS159+UHBj
jrk81Pb1RLWUafoh8Geh4VZHQrvqkLmds/74KZQg47zDr1atKeIRe/p7UPZIEJsr
puOQP+4yfW8CKN/du62mO37xyJBcQpdsk+27/AAbpluwwzfrRAZcI9wqlmE7CRie
tARI3eLA/BVeLm0U5Jxemc1asTAptQTij9BvzFfZcpkwK+AcVmaicQhJ9iaa8bQ2
oTTE5keewHgVdun+XfeMPPuRcF5QxeVK9dZQVI3nSObOXrehulkYXusMQ4vq8bh7
GktI5n1O2qehnSn/Is7kdLBWDy8xGlgYEWe9oStQ5NSXo4PR7YWDzPs5aXBz9LOa
zthJqM1Ah41q5/rSgfhM3e+vXtF3M8phLoJTE5mlb370XVH1ZLNbXVvIuHO0L+Lh
ruZc/tREFWThOiS+FIGv/MDs4DieWEwr9+/598pFERo7cJEo5AZNgPy8SQARAQAB
tCRQYXZsbyBSdWR5aSA8cGF1bGNhcnJvdHlAcmlzZXVwLm5ldD6JAk4EEwEIADgW
IQQTAt5gIxiJ/h66ytxUZ4z3WieNnAUCW7xzywIbAwULCQgHAgYVCgkICwIEFgID
AQIeAQIXgAAKCRBUZ4z3WieNnPDyD/oCSpzl4uua0r/T4cL0rEhHVg82HounlTs2
BxI0ZhJpjdqIE2ytIFiwdV47yAkt04ow0zEBHbZQldvixfsM3tDYrC6iiC4pRMMc
W6oVGf18r8nKKRmYTaOSPWL5yhLgO/IkQ/kCBsu3Wf0bp3GbHQ4wny+rmP745oG9
npGPPW7EiUcFYPIM/YX2YqSH/FOGcMOwlp1QEvVqypQqaogyUmDRP+6bpKYMuq/c
GuPxHuwPmS7a3Zd6ybAtYBNumC/lNYbfxAZA1NK4WViVGB/P5GBWC0HSfLPsBu7D
/GqoqYCDTYYtSpnw2kUpkGWqOaWZc9S5Jvp26Hw+VoVGBdJUe7s7qJyeNmdjM/cR
/dNY9+fW3w9zWgJZcXTnScmpi0vzA7BLmFfsphPBZ7J1Sc+N72uV/W9A70yyNhSw
DQ20/4D2AHNozmq881LhBlOIw24jb0LlbrA7CFoR10zkpXsS/Vh1EWReV1z4zJDv
H1SKUzXaOJUpqqW0EpblEpH4qg5hknnnW4XjvlWZO/ICkKTi0LxXK9Lmcbhtzg9t
Wh7bfDXHXoQYS4QooJbzUhAHwXvQp03R0qu6UhEVhO42y5PVQ/+18FlhgBd+zP1Q
7Urb93f+7YbSa8e34ANcVvJZc7gP2oRTuVyKVjO/Q9l6+Qzg9DTFVPGYLvYJKIpK
odUkTbb/ArkCDQRbvHPLARAA3zMxF1XX4tLaz/0U7p381AXmtMA2L63mRQ3YGZxg
fVxyVx6FdLujxJHytIGnLb9FYQZkxjYyMVc8/7ukrPUTHDUHm2ab4mG0SvhDI3nx
2qeXE2dYMkpLoBqvFLekFAU129w9BLm9lbHfN+JbbdMmoqlyiufuPM6gz0gBV6ce
oXUtu8Q2/ixshSfvcdHx21ZD2HuNqSyworbzkA+0B0F51QRp1tqYJ7wQm3n82rQ+
YFS97Un+7VWgJrX4aofUxRiDx0VHIYkEN8QcDZTQywT4zkj6tDMyKEp40axvZ6zM
AlaTI1GVrGMUHH7bnZXiF2ZyKHOF6XjTuEfotHXm8fzEHLdhtdUxiQ4+GK5ajQN2
ay/v5JEtsc3FSAmjfTW9r6jEAiDn5TbeKHtLpeGmtPqvgK/Nzo5rRRx0NgymymeF
q7Ir4ATu9x8KKYXa/tFd2Qe8rtxNqhYjUh+W7FpMMNXYa18G+PbwNqpEGMdp51rS
9/Lq2GSYcuCV/jD2QbySUX5wHe9zDNiOuovBFhJZS8H2OGl6aep6zEpV/Q7FcWEG
9fz4RHADSGB6RFFI8hyV0/YaVU9rB4fAOZzybuJ4DSadOAsVVfkk2WdnUM6x1z24
XhRdakH+ekGDg+nqs8wUc4u4ouo7dPTPaxbrUas5gdzjbtwoYXoKaIUnisPRranz
EjsAEQEAAYkCNgQYAQgAIBYhBBMC3mAjGIn+HrrK3FRnjPdaJ42cBQJbvHPLAhsM
AAoJEFRnjPdaJ42cEq8QAKJ1YUzQsgzUWSzkPgSZJwOAujWkDdhw+YbNvjHAgRZA
DrNbIyIYkJ/IevubOnteJgwGP/6qaMJwemM+VJ3e/YHvcvAmIilmH33tnnMRqWsj
xqG021SuX3FGdMXR7WwINZaToh+Lqaj4YXpanjPzGMGKZlzaSdj6avm7KT3HGHjO
Gk/nz0rAsqXfuzQBkHZ+JozUMqrh30+POcvkyFhqmTQ9juECFzOtegbEWYdDFBMA
tig1whBccebZ0W+Sva+e1AKktwHNtweaofCg8zQ39Nx1KOz9FoH4B2QF+dYU/yMQ
BpPYTRQPfbaf2/t5JJaoplWrE2gP+JS8ET11J7U4xtzqs7QprcCurTZv42PjwPKu
Hc8uwE1VaeX+d7zRGXD9ooR+u+BWKiwxD9p54/QHu/qh/x/4evrETTIZGsheojgm
srMYT2mW1hLFcOANAgvxuIm+O51+XYviQCGPqg8J2jm5zmxMNwEhVx0ObYcnJqve
klJniYNw9Ja9gnXxXWycChhmGM/QFLE0yrN7di7oDeN/JUhPPgppCken/xFihoxz
hlNM8vyJMQiddIBiEcz0zcAbbT74+qFJv9KRsfWAU0MEy3a66H/hybEJu140qTNw
d7e/dbqns8bDX1BP/x5/QKfxbZNoH2QWmCdv/b5dJ97OXFBtPM/VnOYaaFG5y2gX
=LCWI
-----END PGP PUBLIC KEY BLOCK-----
EOF

printf "[vscodium]\nname=vscodium\nbaseurl=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/repos/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=file:///etc/pki/rpm-gpg/vscodium" |sudo tee -a /etc/yum.repos.d/vscodium.repo

###
# Force update the whole system to the latest and greatest
###

sudo dnf upgrade --best --allowerasing --refresh -y

# And also remove any packages without a source backing them
sudo dnf distro-sync -y

###
# Install base packages and applications
###

sudo dnf install \
-y \
arc-theme `#A more comfortable GTK/Gnome-Shell Theme` \
blender `#3D Software Powerhouse` \
breeze-cursor-theme `#A more comfortable Cursor Theme from KDE` \
calibre `#Ebook management` \
chromium-freeworld `#Comes with hardware acceleration and all Codecs` \
codium `#A nice editor`\
darktable `#Easy RAW Editor` \
evolution-spamassassin `#Helps you deal with spam in Evolution` \
exfat-utils `#Allows managing exfat (android sd cards and co)` \
ffmpeg `#Adds Codec Support to Firefox, and in general` \
file-roller-nautilus `#More Archives supported in nautilus` \
filezilla `#S/FTP Access` \
fuse-exfat `#Allows mounting exfat` \
fuse-sshfs `#Allows mounting servers via sshfs` \
gimp `#The Image Editing Powerhouse - and its plugins` \
gimp-data-extras \
gimp-dbp \
gimp-dds-plugin \
gimp-elsamuko \
gimp-focusblur-plugin \
gimp-fourier-plugin \
gimpfx-foundry.noarch \
gimp-high-pass-filter \
gimp-layer-via-copy-cut \
gimp-lensfun \
gimp-lqr-plugin \
gimp-luminosity-masks \
gimp-paint-studio \
gimp-resynthesizer \
gimp-save-for-web \
gimp-wavelet-decompose \
gimp-wavelet-denoise-plugin \
git `#VCS done right` \
glances `#Nice Monitor for your System` \
gmic-gimp \
gnome-shell-extension-dash-to-dock `#dash for gnome` \
gnome-shell-extension-user-theme `#Enables theming the gnome shell` \
gnome-tweaks `#Your central place to make gnome like you want` \
GREYCstoration-gimp \
gtkhash-nautilus `#To get a file has via gui` \
gvfs-fuse `#gnome<>fuse` \
gvfs-mtp `#gnome<>android` \
gvfs-nfs `#gnome<>ntfs` \
gvfs-smb `#gnome<>samba` \
htop `#Cli process monitor` \
inkscape  `#Working with .svg files` \
kdenlive  `#Advanced Video Editor` \
keepassxc  `#Password Manager` \
krita  `#Painting done right` \
lm_sensors `#Show your systems Temparature` \
'mozilla-fira-*' `#A nice font family` \
mpv `#The best media player (with simple gui)` \
mumble `#Talk with your friends` \
nautilus-extensions `#What it says on the tin` \
nautilus-image-converter \
nautilus-search-tool \
NetworkManager-openvpn-gnome `#To enforce that its possible to import .ovpn files in the settings` \
openshot `#Simple Video Editor` \
openssh-askpass `#Base Lib to let applications request ssh pass via gui` \
p7zip `#Archives` \
p7zip-plugins `#Even more of them` \
papirus-icon-theme `#A quite nice icon theme` \
pv `#pipe viewer - see what happens between the | with output | pv | receiver ` \
pulseeffects `#Tweak your Music!` \
python3-devel `#Python Development Gear` \
python3-neovim `#Python Neovim Libs` \
rawtherapee `#Professional RAW Editor` \
spamassassin `#Dep to make sure it is locally installed for Evolution` \
telegram-desktop `#Chatting, with newer openssl and qt base!` \
tilix `#The best terminal manager i know of` \
tilix-nautilus `#Adds right click open in tilix to nautilus` \
transmission `#Torrent Client` \
tuned `#Tuned can optimize your performance according to metrics. tuned-adm profile powersave can help you on laptops, alot` \
unar `#free rar decompression` \
vagrant `#Virtual Machine management and autodeployment` \
vagrant-libvirt `#integration with libvirt` \
virt-manager `#A gui to manage virtual machines` \
wavemon `#a cli wifi status tool` \
youtube-dl `#Allows you to download and save youtube videos but also to open their links by dragging them into mpv!` \
ansible `#Awesome to manage multiple machines or define states for systems` \
adobe-source-code-pro-fonts `#The most beautiful monospace font around` \
borgbackup `#If you need backups, this is your tool for it` \
gitg `#a gui for git, a little slow on larger repos sadly` \
iotop  `#disk usage cli monitor` \
meld `#Quick Diff Tool` \
nano `#Because pressing i is too hard sometimes` \
neovim `#the better vim` \
nethogs `#Whats using all your traffic? Now you know!` \
nload `#Network Load Monitor` \
tig `#cli git tool` \
vim-enhanced `#full vim` \
zsh `#Best shell` \
zsh-syntax-highlighting `#Now with syntax highlighting` \
cantata `#A beautiful mpd control` \
caddy `#A quick webserver that can be used to share a directory with others in <10 seconds` \
cockpit `#A An awesome local and remote management tool` \
cockpit-bridge \
fortune-mod `#Inspiring Quotes` \
hexchat `#Irc Client` \
libguestfs-tools `#Resize Vm Images and convert them` \
ncdu `#Directory listing CLI tool. For a gui version take a look at "baobab"` \
nextcloud-client `#Nextcloud Integration for Fedora` \
nextcloud-client-nautilus `#Also for the File Manager, shows you file status` \
sqlite-analyzer `#If you work with sqlite databases` \
sqlitebrowser `#These two help alot`

# Pulseeffects: Autoenable
tee -a ~/.config/autostart/pulseeffects-service.desktop > /dev/null <<EOF
[Desktop Entry]
Name=PulseEffects
Comment=PulseEffects Service
Exec=pulseeffects --gapplication-service
Icon=pulseeffects
StartupNotify=false
Terminal=false
Type=Application
EOF

# Pulse: Quality+++
tee -a ~/.config/pulse/daemon.conf > /dev/null <<EOF
default-sample-format = float32ne
default-sample-rate = 48000
alternate-sample-rate = 44100
resample-method = speex-float-10
high-priority = yes
nice-level = -18
realtime-scheduling = no
realtime-priority = 9
rlimit-rtprio = 9
avoid-resampling = yes
EOF

###
# Remove some un-needed stuff
###

sudo dnf remove \
-y \
gnome-shell-extension-background-logo `#Tasteful but nah` \
totem `#With mpv installed totem became a little useless` \
chromium `#Using Chromium resets chromium-vaapi so remove it if installed, userprofiles will be kept and can be used in -vaapi`

###
# Enable some of the goodies, but not all
# Its the users responsibility to choose and enable zsh, with oh-my-zsh for example
# or set a more specific tuned profile
###

sudo systemctl enable --now tuned
sudo tuned-adm profile balanced

#Performance:
#sudo tuned-adm profile desktop

#Virtual Machine Host:
#sudo tuned-adm profile virtual-host

#Virtual Machine Guest:
#sudo tuned-adm profile virtual-guest

#Battery Saving:
#sudo tuned-adm profile powersave

# Virtual Machines
sudo systemctl enable --now libvirtd

# Management of local/remote system(s) - available via http://localhost:9090
sudo systemctl enable --now cockpit.socket

###
# Theming and GNOME Options
###


# Tilix Dark Theme
gsettings set com.gexperts.Tilix.Settings theme-variant 'dark'

#Gnome Shell Theming
gsettings set org.gnome.desktop.interface gtk-theme 'Arc-Dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Breeze_Snow'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.shell.extensions.user-theme name 'Arc-Dark-solid'

#Set SCP as Monospace (Code) Font
gsettings set org.gnome.desktop.interface monospace-font-name 'Source Code Pro Semi-Bold 12'

#Set Extensions for gnome
gsettings set org.gnome.shell enabled-extensions "['user-theme@gnome-shell-extensions.gcampax.github.com', 'dash-to-dock@micxgx.gmail.com']"

#Better Font Smoothing
gsettings set org.gnome.settings-daemon.plugins.xsettings antialiasing 'rgba'

#Usability Improvements
gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'adaptive'
gsettings set org.gnome.desktop.sound allow-volume-above-100-percent true
gsettings set org.gnome.desktop.calendar show-weekdate true
gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
gsettings set org.gnome.shell.overrides workspaces-only-on-primary false

#Dash to Dock Theme
gsettings set org.gnome.shell.extensions.dash-to-dock apply-custom-theme false
gsettings set org.gnome.shell.extensions.dash-to-dock custom-background-color false
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-customize-running-dots true
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-running-dots-color '#729fcf'
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed true
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true
gsettings set org.gnome.shell.extensions.dash-to-dock force-straight-corner false
gsettings set org.gnome.shell.extensions.dash-to-dock icon-size-fixed true
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide-mode 'ALL_WINDOWS'
gsettings set org.gnome.shell.extensions.dash-to-dock isolate-workspaces true
gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top true
gsettings set org.gnome.shell.extensions.dash-to-dock unity-backlit-items false
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-style 'SEGMENTED'
gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.70000000000000000
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false

#This indexer is nice, but can be detrimental for laptop users battery life
gsettings set org.freedesktop.Tracker.Miner.Files index-on-battery false
gsettings set org.freedesktop.Tracker.Miner.Files index-on-battery-first-time false
gsettings set org.freedesktop.Tracker.Miner.Files throttle 15

#Nautilus (File Manager) Usability
gsettings set org.gnome.nautilus.icon-view default-zoom-level 'standard'
gsettings set org.gnome.nautilus.preferences executable-text-activation 'ask'
gsettings set org.gtk.Settings.FileChooser sort-directories-first true
gsettings set org.gnome.nautilus.list-view use-tree-view trueC

#Gnome Night Light (Like flux/redshift)
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic false
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to 9.0
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from 18.0

# Basic Music Example Tweaks
gsettings set com.github.wwmm.pulseeffects.sinkinputs.bassenhancer post-messages true
gsettings set com.github.wwmm.pulseeffects.sinkinputs.bassenhancer state true
gsettings set com.github.wwmm.pulseeffects.sinkinputs.bassenhancer amount 4.0
gsettings set com.github.wwmm.pulseeffects.sinkinputs.bassenhancer harmonics 10.0
gsettings set com.github.wwmm.pulseeffects.sinkinputs.bassenhancer scope 75.0
gsettings set com.github.wwmm.pulseeffects.sinkinputs.bassenhancer floor 10.0
gsettings set com.github.wwmm.pulseeffects.sinkinputs.bassenhancer blend -10.0
gsettings set com.github.wwmm.pulseeffects.sinkinputs.bassenhancer input-gain -3.0
gsettings set com.github.wwmm.pulseeffects.sinkinputs.stereotools post-messages true
gsettings set com.github.wwmm.pulseeffects.sinkinputs.stereotools state true
gsettings set com.github.wwmm.pulseeffects.sinkinputs.stereotools sc-level 1.0
gsettings set com.github.wwmm.pulseeffects.sinkinputs.stereotools delay 0.10000000000000000
gsettings set com.github.wwmm.pulseeffects.sinkinputs.stereotools stereo-base 0.10000000000000000
gsettings set com.github.wwmm.pulseeffects.sinkinputs.stereotools stereo-phase 0.10000000000000000


# Steam games (32bit) have issues with the too new 32bit compat libs in fedora
# Flatpak is the better option here
if [ ! -z "$STEAMFLAT" ]; then
	sudo dnf install -y flatpak
    flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install --user flathub com.valvesoftware.Steam

    flatpak remote-add --if-not-exists --user freedesktop-sdk https://cache.sdk.freedesktop.org/freedesktop-sdk.flatpakrepo

    # Mesa-ACO makes steam render WAY better under amd cards.
    flatpak install --user freedesktop-sdk \
        org.freedesktop.Platform.GL.mesa-aco//19.08 \
        org.freedesktop.Platform.GL32.mesa-aco//19.08

    flatpak update --user

    #To run it with mesa-aco:
    #FLATPAK_GL_DRIVERS=mesa-aco flatpak run com.valvesoftware.Steam
	# Installed but not displayed? Check with: flatpak run com.valvesoftware.Steam
fi

#The user needs to reboot to apply all changes.
echo "Please Reboot" && exit 0