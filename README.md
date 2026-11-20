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

Right-click the playback surface to open the grouped command and settings menus.

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

## Packaging

### Linux

```sh
flutter build linux
```

The release bundle is in `build/linux/x64/release/bundle`. Package that bundle
with an AppImage or Debian packaging tool. Debian package dependencies include
`mpv` and `libmpv-dev` at build time.

### Windows

```sh
flutter build windows
```

The release bundle is in `build/windows/x64/runner/Release`. The bundle can be
distributed as an installer-created package or ZIP archive. A Windows installer
can place EsyPlayer in Program Files and register file associations.

## Known limitations

- Some mpv features depend on the mpv/libmpv build shipped with the operating
  system or bundled by the media_kit native libraries.
- Hardware decoding choices are passed to mpv and may vary by GPU and driver.
- Subtitles are rendered by mpv/libass to apply the selected style once; the
  in-video subtitle widget and controls are disabled to prevent duplicate
  overlays.
- Subtitle appearance and encoding options are persisted. mpv does not expose
  independent fonts, colors, or borders for secondary subtitles; the secondary
  track shares the primary style, but supports separate position, scale, delay,
  visibility, and ASS override.
- OpenSubtitles integration is not enabled by default and requires an API
  implementation and account credentials supplied by the user.
- Playlist M3U/PLS support and advanced features are progressively exposed;
  the advanced mpv property/command menu provides direct access where a dedicated
  control is not yet present.
