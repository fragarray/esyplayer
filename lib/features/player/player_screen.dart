// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:nativeapi/nativeapi.dart' as nativeapi;
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:window_manager/window_manager.dart';

import 'player_controller.dart';
import 'player_providers.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  Future<void> _openFile(PlayerController controller) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.media,
    );
    final path = result?.files.single.path;
    if (path != null) {
      await controller.open(path);
    }
  }

  Future<void> _openFolder(PlayerController controller) async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      await controller.open(path);
    }
  }

  Future<void> _openUrl(
    BuildContext context,
    PlayerController controller,
  ) async {
    final urlController = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Open URL'),
        content: TextField(
          controller: urlController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'https://'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, urlController.text.trim()),
            child: const Text('Open'),
          ),
        ],
      ),
    );
    if (url != null && url.isNotEmpty) {
      await controller.open(url);
    }
  }

  String _format(Duration value) {
    final totalSeconds = value.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(playerControllerProvider);
    final videoController = controller.backend.videoController;

    final durationSeconds = controller.duration.inMilliseconds / 1000;
    final positionSeconds = controller.position.inMilliseconds / 1000;
    final double seekMax = durationSeconds > 0 ? durationSeconds : 1;
    final seekValue = positionSeconds.clamp(0, seekMax).toDouble();

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.arrowLeft): _SeekIntent(
          Duration(seconds: -10),
        ),
        SingleActivator(LogicalKeyboardKey.arrowRight): _SeekIntent(
          Duration(seconds: 10),
        ),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => controller.playOrPause(),
          ),
          _SeekIntent: CallbackAction<_SeekIntent>(
            onInvoke: (intent) {
              final target = controller.position + intent.offset;
              return controller.seek(
                target.isNegative ? Duration.zero : target,
              );
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('EsyPlayer'),
              actions: [
                IconButton(
                  tooltip: 'Open file',
                  onPressed: () => _openFile(controller),
                  icon: const Icon(Icons.folder_open),
                ),
                IconButton(
                  tooltip: 'Open folder',
                  onPressed: () => _openFolder(controller),
                  icon: const Icon(Icons.drive_folder_upload),
                ),
                IconButton(
                  tooltip: 'Open URL',
                  onPressed: () => _openUrl(context, controller),
                  icon: const Icon(Icons.link),
                ),
                IconButton(
                  tooltip: 'Stop',
                  onPressed: controller.stop,
                  icon: const Icon(Icons.stop),
                ),
                IconButton(
                  tooltip: 'Always on top',
                  onPressed: () async {
                    final window = WindowManager.instance.getCurrent();
                    if (window != null) {
                      window.isAlwaysOnTop = !window.isAlwaysOnTop;
                    }
                  },
                  icon: const Icon(Icons.push_pin),
                ),
                IconButton(
                  tooltip: 'Fullscreen',
                  onPressed: () async {
                    final window = WindowManager.instance.getCurrent();
                    if (window != null) {
                      window.isFullScreen = !window.isFullScreen;
                    }
                  },
                  icon: const Icon(Icons.fullscreen),
                ),
                IconButton(
                  tooltip: 'Mini mode',
                  onPressed: () => WindowManager.instance.getCurrent()?.setSize(
                    const nativeapi.Size(width: 480, height: 270),
                    true,
                  ),
                  icon: const Icon(Icons.picture_in_picture_alt),
                ),
              ],
            ),
            body: DropTarget(
              onDrop: (details) {
                for (final item in details.items) {
                  if (item is DropFileItem) {
                    final path = item.localPath ?? item.name;
                    controller.open(path);
                    return;
                  }
                  if (item is DropDirectoryItem) {
                    final path = item.localPath;
                    if (path != null) {
                      controller.open(path);
                    }
                    return;
                  }
                  if (item is DropStringItem && item.value.trim().isNotEmpty) {
                    controller.open(item.value.trim());
                    return;
                  }
                }
              },
              child: Column(
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
                        Text(_format(controller.position)),
                        Expanded(
                          child: Slider(
                            value: seekValue,
                            min: 0,
                            max: seekMax,
                            label: _format(
                              Duration(seconds: seekValue.round()),
                            ),
                            onChanged: (value) => controller.seek(
                              Duration(seconds: value.round()),
                            ),
                          ),
                        ),
                        Text(_format(controller.duration)),
                      ],
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
                            controller.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                        ),
                        IconButton(
                          tooltip: controller.isMuted ? 'Unmute' : 'Mute',
                          onPressed: controller.toggleMute,
                          icon: Icon(
                            controller.isMuted
                                ? Icons.volume_off
                                : Icons.volume_up,
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
            ),
          ),
        ),
      ),
    );
  }
}

class _SeekIntent extends Intent {
  const _SeekIntent(this.offset);

  final Duration offset;
}
