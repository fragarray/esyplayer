# Architecture decisions

- 2026-11-19: EsyPlayer targets Windows and Linux only.
- 2026-11-19: media_kit/libmpv is the sole playback backend.
- 2026-11-19: Riverpod owns application services and state.
- 2026-11-19: Native mpv access is confined to `MpvBackend`; UI code uses
  `PlayerBackend`.
- 2026-11-19: Drift is used for recent files and resume data, while
  shared_preferences stores lightweight settings.
- 2026-11-19: English and Italian are shipped as the initial locales.
- 2026-11-19: All libmpv property, command, and observation access is exposed
  through `MpvBackend`; the UI has no direct `NativePlayer` dependency.
- 2026-11-19: Drift stores recent media, resume offsets, and playlist entries;
  shared_preferences remains reserved for lightweight preferences.
- 2026-11-20: `file_picker` 13.x uses `cross_file` 0.3.x; keep `desktop_drop`
  on 0.8.x because 0.9.x requires incompatible `cross_file` 0.4.x.
- 2026-11-20: Player commands are organized in nested menus opened by
  right-clicking the playback surface; settings are grouped by functional area.
  The player surface remains free of branding and app-bar command clutter.
- 2026-11-21: Subtitle styling is persisted through shared_preferences and
  applied through PlayerBackend. Primary subtitles default to the bottom and
  secondary subtitles to the top; per mpv's API, their font and color styling
  is shared, while position, scale, delay, visibility, and ASS override can be
  configured independently.
