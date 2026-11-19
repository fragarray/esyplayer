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
import '../../core/settings/settings_providers.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  Future<void> _openFile(PlayerController controller) async {
    final file = await FilePicker.pickFile(type: FileType.media);
    final path = file?.path;
    if (path != null) {
      await controller.open(path);
    }
  }

  Future<void> _openFolder(PlayerController controller) async {
    final directory = await FilePicker.pickDirectory();
    final path = directory?.toFilePath();
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

  Future<void> _trackDialog(
    BuildContext context,
    PlayerController controller,
    String title,
    Future<void> Function(String id) apply,
  ) async {
    final textController = TextEditingController(text: '0');
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Track ID'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, textController.text.trim()),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    if (value != null) {
      await apply(value);
    }
  }

  Future<void> _propertyDialog(
    BuildContext context,
    PlayerController controller,
  ) async {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Set mpv property'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'property'),
            ),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(hintText: 'value'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    if (result == true &&
        nameController.text.trim().isNotEmpty &&
        valueController.text.trim().isNotEmpty) {
      await controller.setProperty(
        nameController.text.trim(),
        valueController.text.trim(),
      );
    }
  }

  Future<void> _extraOptionsDialog(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(appSettingsProvider);
    final controller = TextEditingController(
      text: await settings.getExtraMpvOptions() ?? '',
    );
    if (!context.mounted) {
      return;
    }
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Extra mpv options'),
        content: TextField(
          controller: controller,
          minLines: 4,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'key=value, one per line',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == true) {
      await settings.setExtraMpvOptions(controller.text);
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
                PopupMenuButton<String>(
                  tooltip: 'Advanced playback',
                  onSelected: (value) async {
                    switch (value) {
                      case 'subtitle':
                        await _trackDialog(
                          context,
                          controller,
                          'Subtitle track',
                          controller.setSubtitleTrack,
                        );
                      case 'secondary':
                        await _trackDialog(
                          context,
                          controller,
                          'Secondary subtitle track',
                          controller.setSecondarySubtitleTrack,
                        );
                      case 'audio':
                        await _trackDialog(
                          context,
                          controller,
                          'Audio track',
                          controller.setAudioTrack,
                        );
                      case 'load_sub':
                        final file = await FilePicker.pickFile(
                          type: FileType.custom,
                          allowedExtensions: const [
                            'srt',
                            'ass',
                            'ssa',
                            'vtt',
                            'sub',
                          ],
                        );
                        final path = file?.path;
                        if (path != null) {
                          await controller.loadSubtitle(path);
                        }
                      case 'property':
                        await _propertyDialog(context, controller);
                      case 'screenshot':
                        await controller.command(['screenshot', 'subtitles']);
                      case 'frame':
                        await controller.command(['frame-step']);
                      case 'chapter_next':
                        await controller.command(['add', 'chapter', '1']);
                      case 'ab_loop':
                        await controller.setABLoop(true);
                      case 'hwdec':
                        await _propertyDialog(context, controller);
                      case 'stats':
                        await controller.setProperty('osc', 'no');
                        await controller.setProperty('osd-level', '1');
                        await controller.command([
                          'script-binding',
                          'stats/display-stats-toggle',
                        ]);
                      case 'media_info':
                        final title = await controller.getProperty(
                          'media-title',
                        );
                        final duration = await controller.getProperty(
                          'duration',
                        );
                        if (context.mounted) {
                          await showDialog<void>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Media info'),
                              content: Text(
                                'Title: $title\nDuration: $duration',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        }
                      case 'extra_options':
                        await _extraOptionsDialog(context, ref);
                      case 'dark_theme':
                        ref.read(themeModeProvider.notifier).state =
                            ThemeMode.dark;
                        await ref.read(appSettingsProvider).setDarkMode(true);
                      case 'light_theme':
                        ref.read(themeModeProvider.notifier).state =
                            ThemeMode.light;
                        await ref.read(appSettingsProvider).setDarkMode(false);
                      case 'english':
                        ref.read(localeProvider.notifier).state = 'en';
                        await ref.read(appSettingsProvider).setLocale('en');
                      case 'italian':
                        ref.read(localeProvider.notifier).state = 'it';
                        await ref.read(appSettingsProvider).setLocale('it');
                      case 'about':
                        showAboutDialog(
                          context: context,
                          applicationName: 'EsyPlayer',
                          applicationVersion: '1.0.0',
                          applicationLegalese: 'GPL-3.0-or-later',
                        );
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'subtitle',
                      child: Text('Subtitle track'),
                    ),
                    PopupMenuItem(
                      value: 'secondary',
                      child: Text('Secondary subtitle track'),
                    ),
                    PopupMenuItem(value: 'audio', child: Text('Audio track')),
                    PopupMenuItem(
                      value: 'load_sub',
                      child: Text('Load external subtitle'),
                    ),
                    PopupMenuItem(
                      value: 'property',
                      child: Text('Set mpv property'),
                    ),
                    PopupMenuItem(
                      value: 'screenshot',
                      child: Text('Screenshot'),
                    ),
                    PopupMenuItem(value: 'frame', child: Text('Frame step')),
                    PopupMenuItem(
                      value: 'chapter_next',
                      child: Text('Next chapter'),
                    ),
                    PopupMenuItem(
                      value: 'ab_loop',
                      child: Text('A-B loop start/end'),
                    ),
                    PopupMenuItem(
                      value: 'hwdec',
                      child: Text('Hardware decoder property'),
                    ),
                    PopupMenuItem(
                      value: 'stats',
                      child: Text('Toggle stats overlay'),
                    ),
                    PopupMenuItem(
                      value: 'media_info',
                      child: Text('Media info'),
                    ),
                    PopupMenuItem(
                      value: 'extra_options',
                      child: Text('Extra mpv options'),
                    ),
                    PopupMenuItem(
                      value: 'dark_theme',
                      child: Text('Dark theme'),
                    ),
                    PopupMenuItem(
                      value: 'light_theme',
                      child: Text('Light theme'),
                    ),
                    PopupMenuItem(value: 'english', child: Text('English')),
                    PopupMenuItem(value: 'italian', child: Text('Italiano')),
                    PopupMenuItem(
                      value: 'about',
                      child: Text('About EsyPlayer'),
                    ),
                  ],
                ),
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
              onDragDone: (details) {
                if (details.files.isNotEmpty) {
                  controller.open(details.files.first.path);
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
