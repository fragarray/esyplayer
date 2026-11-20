# Project status

## Working

- Windows and Linux desktop scaffolding
- media_kit/libmpv playback backend
- Native mpv property, command, and property observation access
- Fake backend unit-test support
- Play, pause, stop, seek, volume, mute, open file/folder/URL
- Drag-and-drop files and directories
- Fullscreen, always-on-top, and mini-window controls
- Double-click fullscreen with bottom controls that hide after two seconds and
  reappear on pointer movement
- Keyboard play/pause and seek shortcuts
- Drift storage for recent files, resume positions, and named playlists
- Context-menu recent-files submenu capped at six items
- Compact context-menu rows with side-opening, bounds-aware submenus
- M3U load/save helpers
- Nested audio and primary/secondary subtitle menus list available media tracks
- External subtitle loading
- Persistent subtitle font, size, color, outline, margins, alignment, encoding,
  delay, and primary/secondary positioning preferences
- Subtitle preference reset action and ASS border-style override, including a
  migration from the old ASS override default and an mpv-compatible ASS
  `BorderStyle` mapping
- A-B loop property control
- Native libass subtitle rendering with a single bottom playback toolbar
- Raw mpv property dialog and command actions
- Screenshot and frame-step commands
- Media info and stats command actions
- English and Italian localization setup
- Dark/light/system themes
- Extra mpv options setting
- Unit and widget test coverage

## Known limitations

- Dedicated video/equalizer/shader controls are not all represented by bespoke
  widgets; raw mpv properties provide direct access to those controls.
- OpenSubtitles search is not implemented until API credentials and a stable
  API contract are supplied.
- A shortcut editor and log viewer remain planned.
- PLS and M3U parsing is intentionally conservative and M3U metadata is ignored.
- mpv does not expose independent font, color, or border styling for secondary
  subtitles; these share the primary style.

## Run

Linux:

```sh
sudo apt install mpv libmpv-dev
flutter run -d linux
```

Windows:

```sh
flutter run -d windows
```

## Build

```sh
flutter analyze
flutter test
flutter build linux
flutter build windows
```
