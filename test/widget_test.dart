// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:esyplayer/main.dart';

void main() {
  testWidgets('shows application title', (tester) async {
    await tester.pumpWidget(const EsyPlayerApp());
    expect(find.text('EsyPlayer'), findsOneWidget);
  });
}
