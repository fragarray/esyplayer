// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
}
