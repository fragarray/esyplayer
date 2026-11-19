// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:media_kit_video/media_kit_video.dart';

abstract interface class PlayerBackend {
  VideoController? get videoController;
  Stream<Duration> get positionStream;
  Stream<Duration> get durationStream;
  Stream<bool> get playingStream;
  Stream<double> get volumeStream;

  Future<void> open(String source);
  Future<void> play();
  Future<void> pause();
  Future<void> playOrPause();
  Future<void> stop();
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
  Future<void> dispose();
}
