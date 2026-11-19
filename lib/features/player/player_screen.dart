// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'player_providers.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(playerControllerProvider);
    final videoController = controller.backend.videoController;

    return Scaffold(
      appBar: AppBar(
        title: const Text('EsyPlayer'),
        actions: [
          IconButton(
            tooltip: 'Stop',
            onPressed: controller.stop,
            icon: const Icon(Icons.stop),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ColoredBox(
              color: Colors.black,
              child: videoController == null
                  ? const Center(
                      child: Text(
                        'No media loaded',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : Video(controller: videoController),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  tooltip: controller.isPlaying ? 'Pause' : 'Play',
                  onPressed: controller.playOrPause,
                  icon: Icon(
                    controller.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                ),
                IconButton(
                  tooltip: controller.isMuted ? 'Unmute' : 'Mute',
                  onPressed: controller.toggleMute,
                  icon: Icon(
                    controller.isMuted ? Icons.volume_off : Icons.volume_up,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: controller.volume.clamp(0, 200).toDouble(),
                    min: 0,
                    max: 200,
                    onChanged: (value) => controller.setVolume(value),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
