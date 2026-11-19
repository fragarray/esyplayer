# Contributing

## Requirements

- Stable Flutter channel
- Windows: Visual Studio C++ desktop build tools
- Linux: `sudo apt install mpv libmpv-dev`

## Workflow

1. Keep changes focused and feature-first.
2. Run `dart format .`.
3. Run `flutter analyze`.
4. Run `flutter test`.
5. Build for Linux and/or Windows.
6. Commit with a conventional commit message.

The UI must use providers/services; it must not call mpv or `NativePlayer`
directly.
