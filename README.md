# Unofficial Ubuntu Store Flutter - WIP

An alternative software store for the Ubuntu Desktop made with Flutter.

![image_2022-06-07_19-10-39](https://user-images.githubusercontent.com/15329494/172443561-cd3871cd-d892-4a0f-b656-03076fd81bcd.png)
![image_2022-06-07_19-10-39 (4)](https://user-images.githubusercontent.com/15329494/172443572-63f73577-ad49-4359-9307-cef2b389394b.png)
![image_2022-06-07_19-10-39 (5)](https://user-images.githubusercontent.com/15329494/172443573-f38a6b0a-6926-433c-b13a-b4bb6e5ee611.png)
![image_2022-06-07_19-10-39 (3)](https://user-images.githubusercontent.com/15329494/172443577-8ac6d34f-bf56-49ca-b359-e4cf8e459aee.png)
![image_2022-06-07_19-10-39 (2)](https://user-images.githubusercontent.com/15329494/172443580-2875cc5b-b4de-49f7-bc01-632adfa91627.png)


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
  - [ ] manage plugs and permissions
- [ ] deb support (https://github.com/canonical/packagekit.dart)
  - [ ] install from file-explorer
  - [ ] remove

## Firmware updater

For the firmware updates the flutter linux desktop, yaru-designed application [firmware-updater](https://github.com/canonical/firmware-updater) is recommended


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
