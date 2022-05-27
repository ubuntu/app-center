# Unofficial Ubuntu Store Flutter - WIP

An alternative software store for the Ubuntu Desktop made with Flutter.

![](.github/assets/light.png)
![](.github/assets/dark.png)
![](.github/assets/dialog_light.png)
![](.github/assets/dialog_dark.png)

## First goals

- [ ] Great UX
- [X] Adaptive Layout
- [X] Snap support (https://github.com/canonical/snapd.dart)
  - [X] install
  - [X] search
  - [X] remove
  - [X] filter for sections
  - [X] refresh
  - [X] switch channels
  - [ ] manage plugs and permissions
- [ ] Firmware support (https://github.com/canonical/fwupd.dart & https://github.com/canonical/firmware-updater)
- [ ] deb support (https://github.com/robert-ancell/dpkg.dart)

## Optional long term goals

- [ ]  flatpak support


## Build

### Install flutter

```bash
sudo apt install git curl cmake meson make clang libgtk-3-dev pkg-config
mkdir ~/development
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
```

### run

```
flutter run
```

or press the run icon in vscode.