// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
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
import '../subtitles/subtitle_preferences_dialog.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key, this.enableDropTarget = true});

  final bool enableDropTarget;

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

  Future<void> _addFileToQueue(PlayerController controller) async {
    final file = await FilePicker.pickFile(type: FileType.media);
    final path = file?.path;
    if (path != null) {
      await controller.addToPlaylist(path);
    }
  }

  Future<void> _openPlaylist(PlayerController controller) async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['m3u', 'm3u8', 'pls'],
    );
    final path = file?.path;
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

  String _trackLabel({
    required String id,
    String? title,
    String? language,
    String? codec,
    bool? isDefault,
  }) {
    if (id == 'auto') {
      return 'Automatico';
    }
    if (id == 'no') {
      return 'Disattivato';
    }

    return [
      if (title?.trim().isNotEmpty == true) title!.trim(),
      if (language?.trim().isNotEmpty == true) language!.trim(),
      if (codec?.trim().isNotEmpty == true) codec!.trim(),
      'ID $id',
      if (isDefault == true) 'predefinita',
    ].join(' · ');
  }

  List<Widget> _audioTrackItems(PlayerController controller) {
    final tracks = controller.tracks.audio;
    if (tracks.isEmpty) {
      return [
        const MenuItemButton(
          onPressed: null,
          child: Text('Nessuna traccia disponibile'),
        ),
      ];
    }
    return [
      for (final track in tracks)
        MenuItemButton(
          onPressed: () => controller.setAudioTrack(track.id),
          child: Text(
            _trackLabel(
              id: track.id,
              title: track.title,
              language: track.language,
              codec: track.codec,
              isDefault: track.isDefault,
            ),
          ),
        ),
    ];
  }

  List<Widget> _subtitleTrackItems(
    PlayerController controller, {
    required bool secondary,
  }) {
    final tracks = controller.tracks.subtitle;
    if (tracks.isEmpty) {
      return [
        const MenuItemButton(
          onPressed: null,
          child: Text('Nessuna traccia disponibile'),
        ),
      ];
    }
    return [
      for (final track in tracks)
        MenuItemButton(
          onPressed: () => secondary
              ? controller.setSecondarySubtitleTrack(track.id)
              : controller.setSubtitleTrack(track.id),
          child: Text(
            _trackLabel(
              id: track.id,
              title: track.title,
              language: track.language,
              codec: track.codec,
              isDefault: track.isDefault,
            ),
          ),
        ),
    ];
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

  Future<void> _showRecentFiles(
    BuildContext context,
    PlayerController controller,
  ) async {
    final files = await controller.database?.recentFilesList() ?? [];
    if (!context.mounted) {
      return;
    }
    final path = await _choosePath(
      context,
      'File recenti',
      files.map((e) => e.path).toList(),
    );
    if (path != null) {
      await controller.open(path);
    }
  }

  Future<void> _showFavorites(
    BuildContext context,
    WidgetRef ref,
    PlayerController controller,
  ) async {
    final favorites = await ref.read(appSettingsProvider).getFavorites();
    if (!context.mounted) {
      return;
    }
    final path = await _choosePath(context, 'Preferiti', favorites);
    if (path != null) {
      await controller.open(path);
    }
  }

  Future<String?> _choosePath(
    BuildContext context,
    String title,
    List<String> paths,
  ) {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 480,
          child: paths.isEmpty
              ? const Text('Nessun elemento disponibile.')
              : ListView(
                  shrinkWrap: true,
                  children: [
                    for (final path in paths)
                      ListTile(
                        dense: true,
                        title: Text(path, overflow: TextOverflow.ellipsis),
                        onTap: () => Navigator.pop(dialogContext, path),
                      ),
                  ],
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  Future<void> _showMediaInfo(
    BuildContext context,
    PlayerController controller,
  ) async {
    final title = await controller.getProperty('media-title');
    final duration = await controller.getProperty('duration');
    final dimensions = await controller.getProperty('video-params');
    if (!context.mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Informazioni media'),
        content: Text('Titolo: $title\nDurata: $duration\nVideo: $dimensions'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  Future<void> _commandDialog(
    BuildContext context,
    PlayerController controller,
  ) async {
    final commandController = TextEditingController();
    final command = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Comando mpv'),
        content: TextField(
          controller: commandController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'es. cycle deinterlace'),
          onSubmitted: (value) => Navigator.pop(dialogContext, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, commandController.text.trim()),
            child: const Text('Esegui'),
          ),
        ],
      ),
    );
    if (command != null && command.trim().isNotEmpty) {
      await controller.command(command.trim().split(RegExp(r'\s+')));
    }
  }

  Future<void> _loadSubtitle(PlayerController controller) async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['srt', 'ass', 'ssa', 'vtt', 'sub'],
    );
    final path = file?.path;
    if (path != null) {
      await controller.loadSubtitle(path);
    }
  }

  Future<void> _subtitlePreferencesDialog(
    BuildContext context,
    WidgetRef ref,
    PlayerController controller,
  ) async {
    final settings = ref.read(appSettingsProvider);
    final currentValues = await settings.getSubtitlePreferences();
    if (!context.mounted) {
      return;
    }

    final values = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) =>
          SubtitlePreferencesDialog(initialValues: currentValues),
    );
    if (values == null) {
      return;
    }

    for (final entry in values.entries) {
      await controller.setProperty(entry.key, entry.value);
    }
    await settings.setSubtitlePreferences(values);
  }

  List<Widget> _contextMenu(
    BuildContext context,
    WidgetRef ref,
    PlayerController controller,
  ) {
    final window = WindowManager.instance.getCurrent();
    final currentSource = controller.currentSource;
    MenuItemButton item(String label, VoidCallback? onPressed) =>
        MenuItemButton(onPressed: onPressed, child: Text(label));
    SubmenuButton submenu(String label, List<Widget> children) =>
        SubmenuButton(menuChildren: children, child: Text(label));

    return [
      submenu('Apri', [
        item('File…', () => _openFile(controller)),
        item('Cartella…', () => _openFolder(controller)),
        item('URL o stream…', () => _openUrl(context, controller)),
        item('Playlist M3U/PLS…', () => _openPlaylist(controller)),
        item('File recenti', () => _showRecentFiles(context, controller)),
      ]),
      submenu('Riproduci', [
        item(
          controller.isPlaying ? 'Pausa' : 'Riproduci',
          controller.playOrPause,
        ),
        item('Stop', controller.stop),
        item('Elemento precedente', controller.previous),
        item('Elemento successivo', controller.next),
        item('Indietro di 10 secondi', () {
          final target = controller.position - const Duration(seconds: 10);
          controller.seek(target.isNegative ? Duration.zero : target);
        }),
        item('Avanti di 10 secondi', () {
          controller.seek(controller.position + const Duration(seconds: 10));
        }),
        item(
          'Avanza di un fotogramma',
          () => controller.command(['frame-step']),
        ),
        submenu('Velocità', [
          for (final rate in [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 4.0])
            item('$rate×', () => controller.setRate(rate)),
        ]),
        item('Imposta punto A del loop', () {
          final seconds = controller.position.inMilliseconds / 1000;
          controller.setProperty('ab-loop-a', '$seconds');
        }),
        item('Imposta punto B del loop', () {
          final seconds = controller.position.inMilliseconds / 1000;
          controller.setProperty('ab-loop-b', '$seconds');
        }),
        item('Disattiva loop A-B', () async {
          await controller.setProperty('ab-loop-a', 'no');
          await controller.setProperty('ab-loop-b', 'no');
        }),
      ]),
      submenu('Video', [
        item(
          'Schermata',
          () => controller.command(['screenshot', 'subtitles']),
        ),
        item(
          'Capitolo successivo',
          () => controller.command(['add', 'chapter', '1']),
        ),
        submenu('Proporzioni', [
          item(
            'Automatiche',
            () => controller.setProperty('video-aspect-override', '-1'),
          ),
          item(
            '16:9',
            () => controller.setProperty('video-aspect-override', '1.7778'),
          ),
          item(
            '4:3',
            () => controller.setProperty('video-aspect-override', '1.3333'),
          ),
        ]),
        submenu('Accelerazione hardware', [
          for (final decoder in ['auto', 'no', 'vaapi', 'nvdec', 'd3d11va'])
            item(decoder, () => controller.setProperty('hwdec', decoder)),
        ]),
        item(
          'Proprietà e filtri video…',
          () => _propertyDialog(context, controller),
        ),
      ]),
      submenu('Audio', [
        submenu('Traccia audio', _audioTrackItems(controller)),
        item('Muto / attiva audio', controller.toggleMute),
        submenu('Volume', [
          for (final volume in [50, 100, 150, 200])
            item('$volume%', () => controller.setVolume(volume.toDouble())),
        ]),
        item(
          'Proprietà e filtri audio…',
          () => _propertyDialog(context, controller),
        ),
      ]),
      submenu('Sottotitoli', [
        submenu(
          'Sottotitolo primario',
          _subtitleTrackItems(controller, secondary: false),
        ),
        submenu(
          'Sottotitolo secondario',
          _subtitleTrackItems(controller, secondary: true),
        ),
        item('Carica file esterno…', () => _loadSubtitle(controller)),
        submenu('Dimensione', [
          for (final size in [75, 100, 125, 150, 200])
            item('$size%', () => controller.setSubtitleSize(size)),
        ]),
        item(
          'Preferenze sottotitoli…',
          () => _subtitlePreferencesDialog(context, ref, controller),
        ),
      ]),
      submenu('Preferiti', [
        item(
          'Aggiungi file corrente',
          currentSource == null
              ? null
              : () => ref.read(appSettingsProvider).addFavorite(currentSource),
        ),
        item('Apri preferito…', () => _showFavorites(context, ref, controller)),
        item(
          'Rimuovi file corrente',
          currentSource == null
              ? null
              : () =>
                    ref.read(appSettingsProvider).removeFavorite(currentSource),
        ),
      ]),
      submenu('Playlist', [
        item('Aggiungi file alla coda…', () => _addFileToQueue(controller)),
        item('Apri playlist M3U/PLS…', () => _openPlaylist(controller)),
        item('Elemento precedente', controller.previous),
        item('Elemento successivo', controller.next),
      ]),
      submenu('Visualizza', [
        item('Schermata intera', () {
          if (window != null) {
            window.isFullScreen = !window.isFullScreen;
          }
        }),
        item('Sempre in primo piano', () {
          if (window != null) {
            window.isAlwaysOnTop = !window.isAlwaysOnTop;
          }
        }),
        item(
          'Modalità compatta',
          () => window?.setSize(
            const nativeapi.Size(width: 480, height: 270),
            true,
          ),
        ),
        item(
          'Statistiche mpv',
          () => controller.command([
            'script-binding',
            'stats/display-stats-toggle',
          ]),
        ),
        item('Informazioni media…', () => _showMediaInfo(context, controller)),
      ]),
      submenu('Opzioni', [
        submenu('Generali', [
          item(
            'Opzioni mpv aggiuntive…',
            () => _extraOptionsDialog(context, ref),
          ),
          item('Comando mpv…', () => _commandDialog(context, controller)),
          item('Proprietà mpv…', () => _propertyDialog(context, controller)),
        ]),
        submenu('Aspetto e lingua', [
          item('Tema di sistema', () {
            ref.read(themeModeProvider.notifier).state = ThemeMode.system;
          }),
          item('Tema chiaro', () async {
            ref.read(themeModeProvider.notifier).state = ThemeMode.light;
            await ref.read(appSettingsProvider).setDarkMode(false);
          }),
          item('Tema scuro', () async {
            ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
            await ref.read(appSettingsProvider).setDarkMode(true);
          }),
          item('Lingua: Italiano', () async {
            ref.read(localeProvider.notifier).state = 'it';
            await ref.read(appSettingsProvider).setLocale('it');
          }),
          item('Language: English', () async {
            ref.read(localeProvider.notifier).state = 'en';
            await ref.read(appSettingsProvider).setLocale('en');
          }),
        ]),
        submenu('Riproduzione', [
          submenu('Velocità predefinita', [
            for (final rate in [0.5, 0.75, 1.0, 1.25, 1.5, 2.0])
              item('$rate×', () => controller.setRate(rate)),
          ]),
          item('Riprendi da posizione salvata', () async {
            final resume = await controller.database?.resumePosition(
              currentSource ?? '',
            );
            if (resume != null) {
              await controller.seek(resume);
            }
          }),
        ]),
        submenu('Video', [
          item(
            'Decoder, proporzioni, filtri…',
            () => _propertyDialog(context, controller),
          ),
          item(
            'Deinterlacciamento',
            () => controller.command(['cycle', 'deinterlace']),
          ),
        ]),
        submenu('Audio', [
          item('Ritardo audio…', () => _propertyDialog(context, controller)),
          item(
            'Equalizzatore e normalizzazione…',
            () => _propertyDialog(context, controller),
          ),
        ]),
        submenu('Sottotitoli', [
          item(
            'Preferenze sottotitoli…',
            () => _subtitlePreferencesDialog(context, ref, controller),
          ),
        ]),
      ]),
      item('Informazioni su EsyPlayer', () {
        showAboutDialog(
          context: context,
          applicationName: 'EsyPlayer',
          applicationVersion: '1.0.0',
          applicationLegalese: 'GPL-3.0-or-later',
        );
      }),
    ];
  }

  String _format(Duration value) {
    final totalSeconds = value.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
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
    final window = WindowManager.instance.getCurrent();
    final playerBody = Column(
      children: [
        Expanded(
          child: ColoredBox(
            color: Colors.black,
            child: videoController == null
                ? const Center(
                    child: Text(
                      'Nessun media caricato',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : Video(controller: videoController, controls: NoVideoControls),
          ),
        ),
        Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF829099), Color(0xFF56636B), Color(0xFF344149)],
            ),
            border: Border(top: BorderSide(color: Colors.white38)),
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: controller.isPlaying ? 'Pausa' : 'Riproduci',
                visualDensity: VisualDensity.compact,
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0x33232C31),
                  minimumSize: const Size(40, 40),
                ),
                onPressed: controller.playOrPause,
                icon: Icon(
                  controller.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 25,
                ),
              ),
              IconButton(
                tooltip: 'Stop',
                visualDensity: VisualDensity.compact,
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0x33232C31),
                  minimumSize: const Size(40, 40),
                ),
                onPressed: controller.stop,
                icon: const Icon(Icons.stop, size: 24),
              ),
              IconButton(
                tooltip: 'Elemento precedente',
                visualDensity: VisualDensity.compact,
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0x33232C31),
                  minimumSize: const Size(40, 40),
                ),
                onPressed: controller.previous,
                icon: const Icon(Icons.skip_previous, size: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    activeTrackColor: const Color(0xFFB7E3FF),
                    inactiveTrackColor: Colors.white38,
                    thumbColor: Colors.white,
                    overlayColor: Colors.white24,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 5,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                  ),
                  child: Slider(
                    value: seekValue,
                    min: 0,
                    max: seekMax,
                    label: _format(Duration(seconds: seekValue.round())),
                    onChanged: (value) =>
                        controller.seek(Duration(seconds: value.round())),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Elemento successivo',
                visualDensity: VisualDensity.compact,
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0x33232C31),
                  minimumSize: const Size(40, 40),
                ),
                onPressed: controller.next,
                icon: const Icon(Icons.skip_next, size: 24),
              ),
              IconButton(
                tooltip: 'Schermo intero',
                visualDensity: VisualDensity.compact,
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0x33232C31),
                  minimumSize: const Size(40, 40),
                ),
                onPressed: window == null
                    ? null
                    : () => window.isFullScreen = !window.isFullScreen,
                icon: const Icon(Icons.fullscreen, size: 24),
              ),
              IconButton(
                tooltip: controller.isMuted
                    ? 'Attiva audio'
                    : 'Disattiva audio',
                visualDensity: VisualDensity.compact,
                color: Colors.white,
                onPressed: controller.toggleMute,
                icon: Icon(
                  controller.isMuted ? Icons.volume_off : Icons.volume_up,
                  size: 22,
                ),
              ),
              SizedBox(
                width: 82,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white38,
                    thumbColor: Colors.white,
                    overlayColor: Colors.white24,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 5,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 10,
                    ),
                  ),
                  child: Slider(
                    value: controller.volume.clamp(0, 200).toDouble(),
                    min: 0,
                    max: 200,
                    onChanged: controller.setVolume,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${_format(controller.position)} / '
                '${_format(controller.duration)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );

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
            body: MenuAnchor(
              menuChildren: _contextMenu(context, ref, controller),
              builder: (context, menuController, child) => Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (event) {
                  if (event.kind != ui.PointerDeviceKind.touch &&
                      event.buttons == kSecondaryMouseButton) {
                    menuController.open(position: event.position);
                  }
                },
                child: child,
              ),
              child: enableDropTarget
                  ? DropTarget(
                      onDragDone: (details) {
                        if (details.files.isNotEmpty) {
                          controller.open(details.files.first.path);
                        }
                      },
                      child: playerBody,
                    )
                  : playerBody,
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
