// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
}
