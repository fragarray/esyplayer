// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';

import 'package:esyplayer/core/player/fake_backend.dart';

void main() {
  test('fake backend exposes basic playback operations', () async {
    final backend = FakeBackend();

    await backend.open('test://media');
    await backend.seek(const Duration(seconds: 12));
    await backend.setVolume(175);
    await backend.setMuted(true);

    expect(backend.playing, isTrue);
    expect(backend.position, const Duration(seconds: 12));
    expect(backend.volume, 175);
    expect(await backend.getProperty('mute'), 'yes');

    await backend.dispose();
  });
}
