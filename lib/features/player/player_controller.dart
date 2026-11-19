// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/player/player_backend.dart';

class PlayerController extends ChangeNotifier {
  PlayerController(this.backend) {
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
    ]);
  }

  final PlayerBackend backend;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool isPlaying = false;
  double volume = 100;
  bool isMuted = false;

  Future<void> open(String source) => backend.open(source);
  Future<void> playOrPause() => backend.playOrPause();
  Future<void> stop() => backend.stop();
  Future<void> seek(Duration value) => backend.seek(value);

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
    backend.dispose();
    super.dispose();
  }
}
