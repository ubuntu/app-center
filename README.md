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

## Flutter customer tests

The customer-test selection uses existing widget tests that do not need
`pumpApp()`, `FontLoader`, GTK, D-Bus, XDG directories, network access or
real-file I/O. It currently covers 16 cases:

| File | Cases |
| --- | --- |
| `test/package_format_dialog_test.dart` | Lists every format without a warning; explains the publisher badge; blocks installing another format; does not warn when the only format is installed; warns when several formats are installed; installs the snap from the picked channel; switches the channel of an installed snap. |
| `test/uninstall_dependents_dialog_test.dart` | Lists every dependent and confirms; cancel declines; shows a scrollbar only when the list overflows; package names are selectable; scrolls a long list. |
| `test/markdown_description_test.dart` | `markdown follows the dark theme and selection color`. |
| `test/material_localizations_test.dart` | Markdown selection menu uses `en`, `fr` and `dz` Material labels. |

### Entry points

Run the customer-test selection locally with the FVM-pinned SDK:

```bash
melos customer:test
```

The Flutter Customer Test Registry supplies its own Flutter SDK. With that SDK's
`dart` and `flutter` on `PATH`, run the same phases from the repository root,
with the registry's update phase between them:

```bash
dart scripts/customer_testing.dart prepare
# registry update: flutter packages get and dart fix --apply in each update path
dart scripts/customer_testing.dart test
```

`prepare` is for disposable checkouts only. It resolves the root tool lockfile
with `--enforce-lockfile` and uses the repository's locked Melos, so a global
Melos installation is not required. It temporarily relaxes the bootstrap
`enforceLockfile` setting, lets Melos link the in-repo ratings client and
resolve dependencies, restores `melos.yaml` byte-for-byte, and then runs the
`generate` and `gen-l10n` tasks. The registry keeps ownership of its update
phase. `test` runs `generate` and `gen-l10n` again and then executes one
`flutter test --no-pub --machine` invocation per selected case in
`customer_tests.json`.

`melos run run-flutter-registry-test` reproduces the registry flow on Flutter
`main`. It selects main with `fvm use main`, restores the previous FVM state on
exit, copies the worktree to a temporary directory, and runs prepare, update,
regeneration and tests there. This is the non-required nightly Flutter-main CI
job.

Set `REGISTRY_EVIDENCE_DIR` to save per-case output and SDK details. The
executor returns a failure if any selected case fails, is skipped, or does not
run.

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
