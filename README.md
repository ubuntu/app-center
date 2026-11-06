# Welcome to App Center

[actions-image]: https://github.com/ubuntu/app-center/actions/workflows/ci.yaml/badge.svg
[actions-url]: https://github.com/ubuntu/app-center/actions/workflows/ci.yaml

[license-image]: https://img.shields.io/badge/License-GPL3.0-blue.svg

[codecov-image]: https://codecov.io/gh/ubuntu/app-center/graph/badge.svg?token=E7rXg31KRk
[codecov-url]: https://codecov.io/gh/ubuntu/app-center

[weblate-image]: https://hosted.weblate.org/widget/ubuntu-desktop-translations/app-center/svg-badge.svg
[weblate-url]: https://hosted.weblate.org/projects/ubuntu-desktop-translations/app-center/

[snap-image]: https://snapcraft.io/snap-store/badge.svg
[snap-url]: https://snapcraft.io/snap-store


[![snap-store][snap-image]][snap-url]
[![Code quality][actions-image]][actions-url]
[![License][license-image]](LICENSE)
[![Code coverage][codecov-image]][codecov-url]
[![Translation status][weblate-image]][weblate-url]

This is the code repository for **App Center**

## Deep links

App Center supports these navigation links:

| URI | Destination |
| --- | --- |
| `appcenter://addons` | Add-ons |
| `appcenter://addons/media-support` | Media Support |

Open a link through the desktop with, for example:

```bash
xdg-open 'appcenter://addons/media-support'
```

These links work on launch and while App Center is running. They open pages
without starting an installation and preserve existing navigation history.
An optional trailing slash is accepted; query strings and fragments are ignored.
Unknown paths under `appcenter://addons` open Add-ons. Unknown hosts leave the
current page unchanged, or show the home page on a fresh launch.

The public URLs are independent of internal route names. Existing `snap://` links,
command-line options, and local `.deb` file opening remain supported.

## Get involved

This is an [open source](LICENSE) project and we warmly welcome community contributions, suggestions, and constructive feedback. If you're interested in contributing, please take a look at our [Contribution guidelines](CONTRIBUTING.md) first.
