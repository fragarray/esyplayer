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

class _OrderedBackend extends FakeBackend {
  final operations = <String>[];

  @override
  Future<void> setProperty(String name, String value) {
    operations.add('property:$name');
    return super.setProperty(name, value);
  }

  @override
  Future<void> open(String source) async {
    operations.add('open');
    await super.open(source);
  }
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
      final backend = _OrderedBackend();
      final controller = PlayerController(backend, settings: _MemorySettings());

      await controller.open('test://media');

      expect(backend.operations.first, 'property:options/sub-ass-override');
      expect(backend.operations.last, 'open');
      expect(backend.properties['options/sub-pos'], '100');
      expect(backend.properties['options/secondary-sub-pos'], '0');
      expect(backend.properties['options/sub-font'], 'Test Font');
      expect(
        backend.properties['options/sub-border-style'],
        'outline-and-shadow',
      );
      expect(backend.properties['options/sub-ass-override'], 'force');
      expect(backend.properties.keys.take(2).toList(), [
        'options/sub-ass-override',
        'options/secondary-sub-ass-override',
      ]);
      controller.dispose();
    },
  );

  test(
    'changing subtitle border refreshes active tracks without losing them',
    () async {
      final backend = _OrderedBackend()
        ..properties['sid'] = '2'
        ..properties['secondary-sid'] = '3';
      final controller = PlayerController(backend);
      final preferences = Map<String, String>.of(
        AppSettings.subtitlePreferenceDefaults,
      )..['sub-border-style'] = 'opaque-box';

      await controller.applySubtitlePreferences(
        preferences,
        refreshActiveTracks: true,
      );

      expect(backend.properties['options/sub-border-style'], 'opaque-box');
      expect(backend.properties['sid'], '2');
      expect(backend.properties['secondary-sid'], '3');
      expect(
        backend.operations,
        containsAllInOrder([
          'property:sid',
          'property:secondary-sid',
          'property:sid',
          'property:secondary-sid',
        ]),
      );
      controller.dispose();
    },
  );
}
