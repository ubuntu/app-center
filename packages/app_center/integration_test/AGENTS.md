# Integration Tests

## Running

Requires a real system environment (snapd, PackageKit, PolicyKit, display server):

```bash
melos integration_test
# or manually:
xvfb-run -a -s '-screen 0 1024x768x24 +extension GLX' fvm flutter test integration_test
```

## What They Test

- Snap search, install, and remove (using the real `hello` snap)
- Local `.deb` install (using test packages in `assets/`)

## Test Assets

`assets/` contains two test `.deb` packages (`appcenter-testdeb` v0.9 and v1.0) built with `dpkg-buildpackage`.
