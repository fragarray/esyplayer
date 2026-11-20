// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';

import 'package:esyplayer/core/player/fake_backend.dart';
import 'package:esyplayer/core/settings/settings.dart';
import 'package:esyplayer/features/player/player_controller.dart';

class _MemorySettings implements SubtitlePreferencesStore {
  @override
  Future<Map<String, String>> getSubtitlePreferences() async => {
    ...AppSettings.subtitlePreferenceDefaults,
    'sub-font': 'Test Font',
  };
}

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

  test(
    'controller applies persisted subtitle settings when opening media',
    () async {
      final backend = FakeBackend();
      final controller = PlayerController(backend, settings: _MemorySettings());

      await controller.open('test://media');

      expect(backend.properties['sub-pos'], '100');
      expect(backend.properties['secondary-sub-pos'], '0');
      expect(backend.properties['sub-font'], 'Test Font');
      expect(backend.properties['sub-ass-override'], 'force');
      expect(backend.properties.keys.take(2).toList(), [
        'sub-ass-override',
        'secondary-sub-ass-override',
      ]);
      controller.dispose();
    },
  );
}
