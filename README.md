# EsyPlayer

EsyPlayer is an open-source desktop media player for Windows and Linux. It uses
Flutter for the interface and media_kit/libmpv for playback.

## License

GPL-3.0-or-later. See [LICENSE](LICENSE).

## Development

```sh
flutter pub get
flutter analyze
flutter test
flutter run -d windows
flutter run -d linux
```

## Linux prerequisites

```sh
sudo apt install mpv libmpv-dev
```

## Windows prerequisites

Install a current stable Flutter SDK and Visual Studio Build Tools with the
Desktop development with C++ workload.

## Known limitations

Platform-specific and unsupported features are documented here as implementation
milestones are completed. This list will be expanded when a feature is known to
depend on the host mpv build or desktop environment.

## Screenshots

Screenshots are not available yet. The first screenshot will be added when the
stable player layout is complete.
