// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:esyplayer/features/player/player_controller.dart';
import 'package:esyplayer/features/player/player_screen.dart';
import 'package:esyplayer/main.dart';
import 'package:esyplayer/core/player/fake_backend.dart';
import 'package:esyplayer/core/settings/settings.dart';
import 'package:esyplayer/features/player/player_providers.dart';
import 'package:esyplayer/features/subtitles/subtitle_preferences_dialog.dart';

void main() {
  testWidgets('shows application title', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [playerBackendProvider.overrideWithValue(FakeBackend())],
        child: const EsyPlayerApp(home: Scaffold(body: Text('EsyPlayer'))),
      ),
    );
    expect(find.text('EsyPlayer'), findsOneWidget);
  });

  testWidgets('right click opens grouped player menu', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerControllerProvider.overrideWith(
            (ref) => PlayerController(FakeBackend()),
          ),
        ],
        child: const MaterialApp(home: PlayerScreen(enableDropTarget: false)),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Nessun media caricato')),
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await tester.pumpAndSettle();
    expect(find.text('Apri'), findsOneWidget);
    expect(find.text('Video'), findsOneWidget);
    expect(find.text('Opzioni'), findsOneWidget);

    await tester.tap(find.text('Opzioni'));
    await tester.pumpAndSettle();
    expect(find.text('Aspetto e lingua'), findsOneWidget);

    await gesture.up();
  });

  testWidgets('recent files are nested under Open', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerControllerProvider.overrideWith(
            (ref) => PlayerController(FakeBackend()),
          ),
        ],
        child: const MaterialApp(home: PlayerScreen(enableDropTarget: false)),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Nessun media caricato')),
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apri'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('File recenti'));
    await tester.pumpAndSettle();

    expect(find.text('Nessun file recente'), findsOneWidget);
    await gesture.up();
  });

  testWidgets('submenus remain vertically reachable from their trigger', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerControllerProvider.overrideWith(
            (ref) => PlayerController(FakeBackend()),
          ),
        ],
        child: const MaterialApp(home: PlayerScreen(enableDropTarget: false)),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Nessun media caricato')),
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await tester.pumpAndSettle();
    final triggerItem = tester.getRect(
      find.ancestor(
        of: find.text('Video'),
        matching: find.byType(SubmenuButton),
      ),
    );
    final openItem = tester.getRect(
      find.ancestor(
        of: find.text('Apri'),
        matching: find.byType(SubmenuButton),
      ),
    );
    final optionsItem = tester.getRect(
      find.ancestor(
        of: find.text('Opzioni'),
        matching: find.byType(SubmenuButton),
      ),
    );
    final mainMenu = Rect.fromLTRB(
      openItem.left,
      openItem.top,
      openItem.right,
      optionsItem.bottom,
    );
    await tester.tap(find.text('Video'));
    await tester.pumpAndSettle();

    final firstItem = tester.getRect(
      find.ancestor(
        of: find.text('Schermata'),
        matching: find.byType(MenuItemButton),
      ),
    );
    final lastItem = tester.getRect(
      find.ancestor(
        of: find.text('Proprietà e filtri video…'),
        matching: find.byType(MenuItemButton),
      ),
    );
    expect(
      firstItem.top <= triggerItem.center.dy &&
          triggerItem.center.dy <= firstItem.bottom,
      isTrue,
    );
    expect(triggerItem.center.dy, lessThanOrEqualTo(lastItem.bottom));
    expect(
      firstItem.left >= mainMenu.right || lastItem.right <= mainMenu.left,
      isTrue,
    );
    expect(firstItem.height, lessThan(48));
    expect(triggerItem.height, lessThan(48));

    await gesture.up();
  });

  testWidgets('submenus flip to the free side at the window edge', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerControllerProvider.overrideWith(
            (ref) => PlayerController(FakeBackend()),
          ),
        ],
        child: const MaterialApp(home: PlayerScreen(enableDropTarget: false)),
      ),
    );

    final gesture = await tester.startGesture(
      const Offset(996, 350),
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await tester.pumpAndSettle();

    final openItem = tester.getRect(
      find.ancestor(
        of: find.text('Apri'),
        matching: find.byType(SubmenuButton),
      ),
    );
    final optionsItem = tester.getRect(
      find.ancestor(
        of: find.text('Opzioni'),
        matching: find.byType(SubmenuButton),
      ),
    );
    final videoItem = tester.getRect(
      find.ancestor(
        of: find.text('Video'),
        matching: find.byType(SubmenuButton),
      ),
    );
    await tester.tap(find.text('Video'));
    await tester.pumpAndSettle();

    final lastItem = tester.getRect(
      find.ancestor(
        of: find.text('Proprietà e filtri video…'),
        matching: find.byType(MenuItemButton),
      ),
    );
    expect(openItem.left, greaterThanOrEqualTo(0));
    expect(optionsItem.right, lessThanOrEqualTo(1000));
    expect(videoItem.top, greaterThanOrEqualTo(0));
    expect(videoItem.bottom, lessThanOrEqualTo(700));
    expect(lastItem.right, lessThanOrEqualTo(openItem.left));
    expect(lastItem.bottom, lessThanOrEqualTo(700));

    await gesture.up();
  });

  testWidgets('playback controls are confined to the bottom toolbar', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerControllerProvider.overrideWith(
            (ref) => PlayerController(FakeBackend()),
          ),
        ],
        child: const MaterialApp(home: PlayerScreen(enableDropTarget: false)),
      ),
    );

    expect(find.byTooltip('Stop'), findsOneWidget);
    expect(find.byTooltip('Elemento precedente'), findsOneWidget);
    expect(find.byTooltip('Elemento successivo'), findsOneWidget);
    expect(find.byTooltip('Schermo intero'), findsOneWidget);
    expect(find.text('00:00 / 00:00'), findsOneWidget);
  });

  testWidgets('track menus list and select available media tracks', (
    tester,
  ) async {
    final backend = FakeBackend()
      ..availableTracks = const Tracks(
        video: [],
        audio: [
          AudioTrack('auto', null, null),
          AudioTrack('no', null, null),
          AudioTrack('1', 'English', 'en', codec: 'aac', isDefault: true),
        ],
        subtitle: [
          SubtitleTrack('auto', null, null),
          SubtitleTrack('no', null, null),
          SubtitleTrack('2', 'Italian', 'it', codec: 'subrip', isDefault: true),
          SubtitleTrack('3', 'French', 'fr', codec: 'subrip'),
        ],
      );
    final controller = PlayerController(backend);
    await controller.open('test://media');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [playerControllerProvider.overrideWith((ref) => controller)],
        child: const MaterialApp(home: PlayerScreen(enableDropTarget: false)),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> openContextMenu() async {
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Nessun media caricato')),
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await tester.pumpAndSettle();
      await gesture.up();
      await tester.pumpAndSettle();
    }

    await openContextMenu();
    await tester.tap(find.text('Audio'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Traccia audio'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English · en · aac · ID 1 · predefinita'));
    await tester.pumpAndSettle();
    expect(backend.properties['aid'], '1');

    await openContextMenu();
    await tester.tap(find.text('Sottotitoli'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sottotitolo primario'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Italian · it · subrip · ID 2 · predefinita'));
    await tester.pumpAndSettle();
    expect(backend.properties['sid'], '2');

    await openContextMenu();
    await tester.tap(find.text('Sottotitoli'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sottotitolo secondario'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('French · fr · subrip · ID 3'));
    await tester.pumpAndSettle();
    expect(backend.properties['secondary-sid'], '3');
  });

  testWidgets('subtitle preferences restore their defaults', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    late Future<Map<String, String>?> result;
    final initialValues = Map<String, String>.of(
      AppSettings.subtitlePreferenceDefaults,
    )..['sub-font'] = 'Custom font';

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () {
                  result = showDialog<Map<String, String>>(
                    context: context,
                    builder: (_) =>
                        SubtitlePreferencesDialog(initialValues: initialValues),
                  );
                },
                child: const Text('Open preferences'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open preferences'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ripristina predefinite'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    expect(await result, AppSettings.subtitlePreferenceDefaults);
  });

  testWidgets('changing subtitle border forces ASS style overrides', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    late Future<Map<String, String>?> result;
    final initialValues = Map<String, String>.of(
      AppSettings.subtitlePreferenceDefaults,
    )..['sub-ass-override'] = 'no';

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () {
                  result = showDialog<Map<String, String>>(
                    context: context,
                    builder: (_) =>
                        SubtitlePreferencesDialog(initialValues: initialValues),
                  );
                },
                child: const Text('Open preferences'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open preferences'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bordo e ombra'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Riquadro opaco').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Riquadro opaco'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bordo e ombra').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    final savedValues = await result;
    expect(savedValues?['sub-border-style'], 'outline-and-shadow');
    expect(savedValues?['sub-ass-override'], 'force');
  });
}
