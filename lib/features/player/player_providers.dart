// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../core/player/mpv_backend.dart';
import '../../core/player/player_backend.dart';
import 'player_controller.dart';

final playerBackendProvider = Provider<PlayerBackend>((ref) {
  final backend = MpvBackend();
  ref.onDispose(backend.dispose);
  return backend;
});

final playerControllerProvider = ChangeNotifierProvider<PlayerController>(
  (ref) => PlayerController(ref.watch(playerBackendProvider)),
);
