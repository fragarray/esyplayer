// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'player_backend.dart';

class MpvBackend implements PlayerBackend {
  MpvBackend() {
    _player = Player();
    _videoController = VideoController(_player);
  }

  late final Player _player;
  late final VideoController _videoController;

  NativePlayer get _nativePlayer => _player.platform as NativePlayer;

  @override
  VideoController get videoController => _videoController;

  @override
  Stream<Duration> get positionStream => _player.stream.position;

  @override
  Stream<Duration> get durationStream => _player.stream.duration;

  @override
  Stream<bool> get playingStream => _player.stream.playing;

  @override
  Stream<double> get volumeStream => _player.stream.volume;

  @override
  Future<void> open(String source) async {
    await _player.open(Media(source));
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> playOrPause() => _player.playOrPause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setVolume(double volume) =>
      _player.setVolume(volume.clamp(0, 200).toDouble());

  @override
  Future<void> setMuted(bool muted) =>
      _nativePlayer.setProperty('mute', muted ? 'yes' : 'no');

  @override
  Future<void> setProperty(String name, String value) =>
      _nativePlayer.setProperty(name, value);

  @override
  Future<String> getProperty(String name) => _nativePlayer.getProperty(name);

  @override
  Future<void> command(List<String> arguments) =>
      _nativePlayer.command(arguments);

  @override
  Future<void> observeProperty(
    String name,
    Future<void> Function(String value) listener,
  ) => _nativePlayer.observeProperty(name, listener);

  @override
  Future<void> dispose() => _player.dispose();
}
