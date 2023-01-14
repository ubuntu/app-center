# Ubuntu Software

[![codecov](https://codecov.io/gh/ubuntu-flutter-community/software/branch/main/graph/badge.svg)](https://codecov.io/gh/ubuntu-flutter-community/software)
[![Translation status](https://hosted.weblate.org/widgets/ubuntu-software/-/svg-badge.svg)](https://hosted.weblate.org/engage/ubuntu-software/)

### An alternative software store for the Ubuntu Desktop made with Flutter.

<a href="https://snapcraft.io/snap-store">
<img border="0" align="middle" alt="Snap Store Badge" src="https://snapcraft.io/static/images/badges/en/snap-store-black.svg" width=200>
</a>

Test Ubuntu Software in the **preview/edge** channel of the snap-store snap

## Explore the snapcraft.io from your Ubuntu machine

![](.github/assets/explore_dark.png)

## Search and find snaps _and_ debian packages

![](.github/assets/search_dark.png)

## Install and remove apps and manage snap apps' channels

![](.github/assets/apppage_dark.png)

## Update your snap apps

![](.github/assets/snapupdates_dark.png)


## And your debian packages

![](.github/assets/check_deb_updates_dark.png)

![](.github/assets/deb_updates_dark.png)

## We even have a light theme ;) and a layout for small windows

![](.github/assets/explore_small_window_light.png)

## And for wide windows

![](.github/assets/explore_wide_window_light.png)

## You can also install and update local debian package files from your file manager

![](.github/assets/package_installer_light.png)

## Goals

- [X] Great UX
- [X] Fast
- [X] Adaptive Layout
- [X] Snap support (https://github.com/canonical/snapd.dart)
  - [X] install
  - [X] search
  - [X] remove
  - [X] filter for sections
  - [X] refresh
  - [X] switch channels
    - [X] list permissions
- [X] deb/rpm (packagekit) support (https://github.com/canonical/packagekit.dart)
  - [X] install from file-explorer
  - [X] list installed debs/rpms
  - [X] remove
  - [X] update all debs/rpms on the system via the updates tab
  - [X] search and install for debs/rpms

## Firmware updater

For the firmware updates the flutter linux desktop, yaru-designed application [firmware-updater](https://github.com/canonical/firmware-updater) is recommended


## Build

### Install flutter

Either with

```bash
sudo snap install flutter --classic
```

Or with

```bash
sudo apt install git curl cmake meson make clang libgtk-3-dev pkg-config
mkdir -p ~/development
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
```

OR a one-liner top copy & paste - CAUTION: it won't stop after you entered your password :)

```bash
sudo apt -y install git curl cmake meson make clang libgtk-3-dev pkg-config && mkdir -p ~/development && cd ~/development && git clone https://github.com/flutter/flutter.git -b stable && echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.bashrc && source ~/.bashrc
```

### run

```
flutter run
```

or press the run icon in vscode.

## Contributing

See our [contributor guidelines](CONTRIBUTING.md).

## License

This application is licensed under the [GNU General Public License version 3](LICENSE).
