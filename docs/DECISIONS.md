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
