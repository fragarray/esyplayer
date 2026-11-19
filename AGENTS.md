# EsyPlayer – agent instructions
- Flutter desktop app (Windows + Linux only), playback via media_kit (libmpv). GPL-3.0-or-later.
- Always read TODO.md first and continue from the first unchecked item. Never ask the user questions; decide and log in docs/DECISIONS.md.
- Before every commit: `flutter analyze` clean, `flutter test` green, project builds.
- Commit after each milestone/sub-feature with conventional commits.
- UI never calls mpv directly: use providers/services -> PlayerBackend.
- Do not copy anything from SMPlayer (code, icons, strings).
- Document unsupported/unstable features in README "Known limitations".