# Project

Ubuntu App Center — Flutter desktop app for managing snaps and debs on Ubuntu. Ships as a snap (`snap-store`). GPL-3.0.

# Setup

```bash
fvm install                    # Flutter version pinned in .fvmrc
dart pub global activate melos
melos bootstrap                # Install deps + link local packages
```

# Commands

```bash
fvm flutter run                # Dev mode
melos build                    # Release build
melos generate                 # Regenerate freezed/riverpod/mockito/json code
melos gen-l10n                 # Regenerate l10n from ARB files
melos test                     # All unit tests
melos coverage                 # Tests + lcov
melos integration_test         # Integration tests (needs xvfb, polkitd)
melos analyze --fatal-infos    # Lint (CI fails on infos)
melos format:exclude           # Format non-generated Dart files
melos protoc                   # Regenerate gRPC protobuf code
```

# Monorepo Layout

- @packages/app_center — Main Flutter app
- @packages/app_center_ratings_client — Generated gRPC client for ratings.ubuntu.com
- @packagekit-session-installer — Meson-based C daemon (D-Bus PackageKit session)

# Generated Files

`.freezed.dart`, `.g.dart`, `.mocks.dart`, `.pb*.dart` are committed but ignored by `.agentignore`. Run `melos generate` after changing models, providers, or `@GenerateNiceMocks` annotations.

# L10n

Only edit @packages/app_center/lib/src/l10n/app_en.arb — translations are managed via Weblate.

# Snap Build

Build with `snapcraft` at repo root. Clean prior build state with `snapcraft clean`.
@snap/snapcraft.yaml

# CI

Runs: analyze, format, coverage, l10n freshness, integration tests. All must pass.

# Env Vars (for local dev without snap)

- `RATINGS_SERVICE_URL` — ratings backend host (default: `localhost`)
- `RATINGS_SERVICE_PORT` — ratings backend port (default: `8080`)
- `RATINGS_SERVICE_USE_TLS` — enable TLS (default: `false`)

In the snap, these are set to `ratings.ubuntu.com:443` with TLS on. See @snap/snapcraft.yaml.

# Linting

Uses `ubuntu_lints` — do not add a custom `analysis_options.yaml`.
