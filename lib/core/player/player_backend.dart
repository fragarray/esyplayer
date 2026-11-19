// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit/media_kit.dart' show Tracks;

abstract interface class PlayerBackend {
  VideoController? get videoController;
  Stream<Duration> get positionStream;
  Stream<Duration> get durationStream;
  Stream<bool> get playingStream;
  Stream<double> get volumeStream;
  Stream<Tracks> get tracksStream;

  Future<void> open(String source);
  Future<void> play();
  Future<void> pause();
  Future<void> playOrPause();
  Future<void> stop();
  Future<void> addToPlaylist(String source);
  Future<void> next();
  Future<void> previous();
  Future<void> seek(Duration position);
  Future<void> setVolume(double volume);
  Future<void> setMuted(bool muted);
  Future<void> setProperty(String name, String value);
  Future<String> getProperty(String name);
  Future<void> command(List<String> arguments);
  Future<void> observeProperty(
    String name,
    Future<void> Function(String value) listener,
  );
  Future<void> setSubtitleTrack(String id);
  Future<void> setSecondarySubtitleTrack(String id);
  Future<void> loadSubtitle(String path);
  Future<void> setSubtitleDelay(Duration delay);
  Future<void> setSubtitleSize(int percent);
  Future<void> setAudioTrack(String id);
  Future<void> setAudioDelay(Duration delay);
  Future<void> setRate(double rate);
  Future<void> setABLoop(bool enabled);
  Future<void> setPropertyPreset(String name);
  Future<void> dispose();
}
