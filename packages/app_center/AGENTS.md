# Main App Package

## Run a Single Test

```bash
cd packages/app_center
fvm flutter test test/snap_page_test.dart
```

After modifying test mocks or model classes, regenerate first: `melos generate`

## Entry Point

@lib/main.dart → `StoreApp` (@lib/store/store_app.dart) wrapped in a Riverpod `ProviderScope`.

## Architecture

- **State**: Riverpod + `riverpod_generator` for providers, Freezed for immutable models
- **Services**: D-Bus backed — `SnapdService`, `PackageKitService`, `AppstreamService`; gRPC backed — `RatingsService`
- **UI**: Yaru theme, `YaruMasterDetailPage` sidebar, `ResponsiveLayout` grid
- **Routing**: @lib/store/store_routes.dart

## Feature Directories

- @lib/snapd — Snap operations, caching, change watching, snap detail pages
- @lib/deb — Debian package models and install UI
- @lib/manage — Installed apps list, updates, local deb management
- @lib/packagekit — PackageKit D-Bus service wrapper for deb operations
- @lib/appstream — Desktop app metadata, icons, categories
- @lib/ratings — gRPC ratings client integration
- @lib/explore — Category browsing pages
- @lib/search — Search functionality
- @lib/games — Games category page
- @lib/gstreamer — GStreamer codec installer
- @lib/store — App shell, routing, navigation, top-level providers
- @lib/widgets — Shared UI components (app cards, banners, screenshot gallery)
- @lib/error — Error handling and display
- @lib/providers — Cross-cutting Riverpod providers
- @lib/about — About dialog
- @lib/apps — App detail page, title bar
- @lib/extensions — String utilities

## Testing

Tests live flat in `test/` (no subdirectories) — see @test/AGENTS.md. Integration tests in `integration_test/` — see @integration_test/AGENTS.md.

## Key Patterns

- Services registered via `ubuntu_service` (`registerService`/`getService`) and injected into Riverpod providers
- `SnapdService` extends `SnapdClient` with `SnapdCache` (in-memory caching) and `SnapdWatcher` (change polling)
- `PackageKitService` wraps the `PackageKitClient` D-Bus interface
- `@freezed` models for data classes, `@riverpod` annotation for provider generation
- Riverpod providers live alongside their feature code (not centralized)
