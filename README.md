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
| `snap://<snap-name>` | Details for the named snap (for example, `snap://firefox`) |
| `appcenter://addons` | Add-ons |
| `appcenter://addons/media-support` | Media Support |

Open links with `xdg-open`, for example:

```bash
xdg-open 'snap://firefox'
xdg-open 'appcenter://addons/media-support'
```

Links work on launch and while App Center is running, without starting an
installation.

## Get involved

This is an [open source](LICENSE) project and we warmly welcome community contributions, suggestions, and constructive feedback. If you're interested in contributing, please take a look at our [Contribution guidelines](CONTRIBUTING.md) first.
