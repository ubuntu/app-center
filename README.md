# Unofficial Ubuntu Store Flutter - WIP

An alternative software store for the Ubuntu Desktop made with Flutter.

![1](.github/assets/01.png)
![2](.github/assets/02.png)
![3](.github/assets/03.png)
![4](.github/assets/04.png)
![5](.github/assets/05.png)
![6](.github/assets/06.png)

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
  - [ ] manage permissions
    - [X] list permissions
    - [ ] activate/deactive permissions
- [X] deb/rpm (packagekit) support (https://github.com/canonical/packagekit.dart)
  - [X] install from file-explorer
  - [X] list installed debs/rpms
  - [X] remove
  - [X] update
  - [X] search for debs/rpms (TBD if wanted)

## Firmware updater

For the firmware updates the flutter linux desktop, yaru-designed application [firmware-updater](https://github.com/canonical/firmware-updater) is recommended


## Build

### Install flutter

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
