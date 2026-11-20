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
    await applySubtitlePreferences(subtitlePreferences);
    await backend.open(source);
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

  Future<void> applySubtitlePreferences(
    Map<String, String> preferences, {
    bool refreshActiveTracks = false,
  }) async {
    const overrideKeys = ['sub-ass-override', 'secondary-sub-ass-override'];
    const borderStyleValues = {
      'outline-and-shadow': '1',
      'opaque-box': '3',
      'background-box': '4',
    };
    final borderStyle = preferences['sub-border-style'];
    final nativeBorderStyle = await backend.getProperty(
      'options/sub-border-style',
    );
    final supportsNativeBorderStyle = nativeBorderStyle.isNotEmpty;
    final legacyOutlineAndShadow =
        !supportsNativeBorderStyle && borderStyle == 'outline-and-shadow';
    for (final key in overrideKeys) {
      final value = preferences[key];
      if (value != null) {
        await backend.setProperty('options/$key', value);
      }
    }
    for (final entry in preferences.entries) {
      if (!overrideKeys.contains(entry.key) &&
          entry.key != 'sub-border-style') {
        if (legacyOutlineAndShadow && entry.key == 'sub-back-color') {
          await backend.setProperty('options/sub-back-color', '#00000000');
          await backend.setProperty('options/sub-shadow-color', entry.value);
        } else {
          await backend.setProperty('options/${entry.key}', entry.value);
        }
      }
    }
    if (supportsNativeBorderStyle && borderStyle != null) {
      await backend.setProperty('options/sub-border-style', borderStyle);
    } else if (borderStyle != null) {
      final assBorderStyle = borderStyleValues[borderStyle];
      if (assBorderStyle == null) {
        return;
      }
      await backend.setProperty(
        'options/sub-ass-force-style',
        'BorderStyle=$assBorderStyle',
      );
    }
    if (refreshActiveTracks) {
      await _refreshActiveSubtitleTracks();
    }
  }

  Future<void> _refreshActiveSubtitleTracks() async {
    final primaryTrack = await backend.getProperty('sid');
    final secondaryTrack = await backend.getProperty('secondary-sid');
    final hasPrimaryTrack = primaryTrack.isNotEmpty && primaryTrack != 'no';
    final hasSecondaryTrack =
        secondaryTrack.isNotEmpty && secondaryTrack != 'no';

    if (hasPrimaryTrack) {
      await backend.setProperty('sid', 'no');
    }
    if (hasSecondaryTrack) {
      await backend.setProperty('secondary-sid', 'no');
    }
    if (hasPrimaryTrack) {
      await backend.setProperty('sid', primaryTrack);
    }
    if (hasSecondaryTrack) {
      await backend.setProperty('secondary-sid', secondaryTrack);
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
