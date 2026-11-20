// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart' show Tracks;

import '../../core/player/player_backend.dart';
import '../../core/settings/settings.dart';
import '../../core/storage/app_database.dart';

class PlayerController extends ChangeNotifier {
  PlayerController(this.backend, {this.database, this.settings}) {
    _subscriptions.addAll([
      backend.positionStream.listen((value) {
        position = value;
        notifyListeners();
      }),
      backend.durationStream.listen((value) {
        duration = value;
        notifyListeners();
      }),
      backend.playingStream.listen((value) {
        isPlaying = value;
        notifyListeners();
      }),
      backend.volumeStream.listen((value) {
        volume = value;
        notifyListeners();
      }),
      backend.tracksStream.listen((value) {
        tracks = value;
        notifyListeners();
      }),
    ]);
  }

  final PlayerBackend backend;
  final AppDatabase? database;
  final SubtitlePreferencesStore? settings;
  String? currentSource;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  Tracks tracks = const Tracks(video: [], audio: [], subtitle: []);
  bool isPlaying = false;
  double volume = 100;
  bool isMuted = false;

  Future<void> open(String source) async {
    currentSource = source;
    tracks = const Tracks(video: [], audio: [], subtitle: []);
    notifyListeners();
    await database?.addRecentFile(source);
    final subtitlePreferences =
        await settings?.getSubtitlePreferences() ??
        AppSettings.subtitlePreferenceDefaults;
    await backend.open(source);
    await applySubtitlePreferences(subtitlePreferences);
    final resume = await database?.resumePosition(source);
    if (resume != null && resume > Duration.zero) {
      await backend.seek(resume);
    }
  }

  Future<void> playOrPause() => backend.playOrPause();
  Future<void> stop() async {
    if (currentSource != null) {
      await database?.saveResumePosition(currentSource!, position);
    }
    await backend.stop();
  }

  Future<void> seek(Duration value) => backend.seek(value);
  Future<void> addToPlaylist(String source) => backend.addToPlaylist(source);
  Future<void> next() => backend.next();
  Future<void> previous() => backend.previous();
  Future<void> setSubtitleTrack(String id) => backend.setSubtitleTrack(id);
  Future<void> setSecondarySubtitleTrack(String id) =>
      backend.setSecondarySubtitleTrack(id);
  Future<void> loadSubtitle(String path) => backend.loadSubtitle(path);
  Future<void> setSubtitleDelay(Duration delay) =>
      backend.setSubtitleDelay(delay);
  Future<void> setSubtitleSize(int percent) => backend.setSubtitleSize(percent);
  Future<void> setAudioTrack(String id) => backend.setAudioTrack(id);
  Future<void> setAudioDelay(Duration delay) => backend.setAudioDelay(delay);
  Future<void> setRate(double rate) => backend.setRate(rate);
  Future<void> setABLoop(bool enabled) => backend.setABLoop(enabled);
  Future<void> setProperty(String name, String value) =>
      backend.setProperty(name, value);

  Future<void> applySubtitlePreferences(Map<String, String> preferences) async {
    const overrideKeys = ['sub-ass-override', 'secondary-sub-ass-override'];
    for (final key in overrideKeys) {
      final value = preferences[key];
      if (value != null) {
        await backend.setProperty(key, value);
      }
    }
    for (final entry in preferences.entries) {
      if (!overrideKeys.contains(entry.key)) {
        await backend.setProperty(entry.key, entry.value);
      }
    }
  }

  Future<String> getProperty(String name) => backend.getProperty(name);
  Future<void> command(List<String> arguments) => backend.command(arguments);

  Future<void> setVolume(double value) async {
    volume = value;
    await backend.setVolume(value);
  }

  Future<void> toggleMute() async {
    isMuted = !isMuted;
    await backend.setMuted(isMuted);
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    if (currentSource != null) {
      database?.saveResumePosition(currentSource!, position);
    }
    backend.dispose();
    super.dispose();
  }
}
