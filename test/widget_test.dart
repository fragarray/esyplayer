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
import 'package:esyplayer/features/player/player_providers.dart';

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
    expect(find.text('00:00:00 / 00:00:00'), findsOneWidget);
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
}
