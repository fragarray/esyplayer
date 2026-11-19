// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'player_backend.dart';

class FakeBackend implements PlayerBackend {
  final _position = StreamController<Duration>.broadcast();
  final _duration = StreamController<Duration>.broadcast();
  final _playing = StreamController<bool>.broadcast();
  final _volume = StreamController<double>.broadcast();
  final _tracks = StreamController<Tracks>.broadcast();

  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool playing = false;
  double volume = 100;
  Tracks availableTracks = const Tracks(video: [], audio: [], subtitle: []);
  final Map<String, String> properties = {};

  @override
  VideoController? get videoController => null;

  @override
  Stream<Duration> get positionStream => _position.stream;

  @override
  Stream<Duration> get durationStream => _duration.stream;

  @override
  Stream<bool> get playingStream => _playing.stream;

  @override
  Stream<double> get volumeStream => _volume.stream;

  @override
  Stream<Tracks> get tracksStream => _tracks.stream;

  @override
  Future<void> open(String source) async {
    playing = true;
    _playing.add(true);
    _tracks.add(availableTracks);
  }

  void setAvailableTracks(Tracks value) {
    availableTracks = value;
    _tracks.add(value);
  }

  @override
  Future<void> play() async {
    playing = true;
    _playing.add(true);
  }

  @override
  Future<void> pause() async {
    playing = false;
    _playing.add(false);
  }

  @override
  Future<void> playOrPause() async {
    playing = !playing;
    _playing.add(playing);
  }

  @override
  Future<void> stop() async {
    playing = false;
    position = Duration.zero;
    _playing.add(false);
    _position.add(position);
  }

  @override
  Future<void> addToPlaylist(String source) async {}

  @override
  Future<void> next() async {}

  @override
  Future<void> previous() async {}

  @override
  Future<void> seek(Duration position) async {
    this.position = position;
    _position.add(position);
  }

  @override
  Future<void> setVolume(double volume) async {
    this.volume = volume;
    _volume.add(volume);
  }

  @override
  Future<void> setMuted(bool muted) async {
    properties['mute'] = muted ? 'yes' : 'no';
  }

  @override
  Future<void> setProperty(String name, String value) async {
    properties[name] = value;
  }

  @override
  Future<String> getProperty(String name) async => properties[name] ?? '';

  @override
  Future<void> command(List<String> arguments) async {}

  @override
  Future<void> observeProperty(
    String name,
    Future<void> Function(String value) listener,
  ) async {}

  @override
  Future<void> setSubtitleTrack(String id) async => setProperty('sid', id);
  @override
  Future<void> setSecondarySubtitleTrack(String id) async =>
      setProperty('secondary-sid', id);
  @override
  Future<void> loadSubtitle(String path) async =>
      command(['sub-add', path, 'select']);
  @override
  Future<void> setSubtitleDelay(Duration delay) async =>
      setProperty('sub-delay', '${delay.inMilliseconds / 1000}');
  @override
  Future<void> setSubtitleSize(int percent) async =>
      setProperty('sub-scale', '${percent / 100}');
  @override
  Future<void> setAudioTrack(String id) async => setProperty('aid', id);
  @override
  Future<void> setAudioDelay(Duration delay) async =>
      setProperty('audio-delay', '${delay.inMilliseconds / 1000}');
  @override
  Future<void> setRate(double rate) async => setProperty('speed', '$rate');
  @override
  Future<void> setABLoop(bool enabled) async =>
      setProperty('ab-loop-a', enabled ? '1' : '0');
  @override
  Future<void> setPropertyPreset(String name) async =>
      setProperty('profile', name);

  @override
  Future<void> dispose() async {
    await _position.close();
    await _duration.close();
    await _playing.close();
    await _volume.close();
    await _tracks.close();
  }
}
