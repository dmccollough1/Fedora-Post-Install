# fedora-install

A basic get-up-and-running Fedora install script.

It supposed to give you an easy starting point, with quite a few good tools and a better looking/usable theme, or simple things like reenabling the maximize/minimize buttons for gnome.

These are of course by nature my opinions for how to go about it, to save newcomers twenty pages of clicking in guis that you'd have to do to achieve the same.


If you have Improvements or Issues, contact me!:

https://t.me/wolfshappen


## Things YOU have to do after:
Read the script! Seriously!

There are additions, like if you have an AMD gpu and want to use the much better mesa-aco to render things you need to run steamlike this in a terminal/override then flatpak env:

``` bash
FLATPAK_GL_DRIVERS=mesa-aco flatpak run com.valvesoftware.Steam
```

Or making it permanent for amd so you only need to click the icon:
``` bash
flatpak override --env=FLATPAK_GL_DRIVERS=mesa-aco --user
```

Same goes for allowing access to external harddrives/controllers for it
``` bash
# Allow talking to controllers
flatpak override --user --device=all com.valvesoftware.Steam
# Allow access to /put-your-own-path-here
flatpak override --filesystem=/put-your-own-path-here com.valvesoftware.Steam
```

Or setting a powersave profile for tuned:
``` bash
sudo tuned-adm profile powersave
```

Linux is a journey, this is only the beginning. There's always more to learn if you want to!


## RUN THIS AS YOUR USER!

Seriously, this changes usersettings. root for the entire script will NOT work.
It may require you due to the time it takes to enter your password multiple times.

## For a free, open source only install run it using

``` bash
#installs wget, gets the script, makes it executable and runs it
sudo dnf install -y wget && wget "https://git.furworks.de/tobias/fedora-install/raw/branch/master/install.sh" -O ./install.sh && chmod +x ./install.sh && ./install.sh
```

## To also get nonfree extensions, like rpmfusion nonfree upstream or steam flatpak run it this way instead

``` bash
#installs wget, gets the script, makes it executable and runs it with steam and nonfree repos added for things like nvidia drivers
sudo dnf install -y wget && wget "https://git.furworks.de/tobias/fedora-install/raw/branch/master/install.sh" -O ./install.sh && chmod +x ./install.sh && ./install.sh --nonfree --steam
```
