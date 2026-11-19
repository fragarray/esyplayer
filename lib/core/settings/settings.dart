// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract interface class SubtitlePreferencesStore {
  Future<Map<String, String>> getSubtitlePreferences();
}

class AppSettings implements SubtitlePreferencesStore {
  AppSettings(this.preferences);

  final SharedPreferencesAsync preferences;

  static const subtitlePreferenceDefaults = <String, String>{
    'sub-pos': '100',
    'secondary-sub-pos': '0',
    'sub-font': 'sans-serif',
    'sub-font-size': '38',
    'sub-scale': '1',
    'sub-bold': 'no',
    'sub-italic': 'no',
    'sub-color': '#FFFFFFFF',
    'sub-outline-color': '#FF000000',
    'sub-outline-size': '1.65',
    'sub-border-style': 'outline-and-shadow',
    'sub-back-color': '#80000000',
    'sub-shadow-offset': '0',
    'sub-margin-x': '19',
    'sub-margin-y': '34',
    'sub-align-x': 'center',
    'sub-align-y': 'bottom',
    'sub-spacing': '0',
    'sub-blur': '0',
    'sub-line-spacing': '0',
    'sub-hinting': 'none',
    'sub-delay': '0',
    'secondary-sub-delay': '0',
    'secondary-sub-scale': '1',
    'sub-codepage': 'auto',
    'sub-ass-override': 'scale',
    'secondary-sub-ass-override': 'strip',
    'sub-use-margins': 'yes',
    'sub-ass-force-margins': 'no',
    'sub-visibility': 'yes',
    'secondary-sub-visibility': 'yes',
  };

  static final _subtitlePreferenceKeys = subtitlePreferenceDefaults.keys
      .toSet();

  @override
  Future<Map<String, String>> getSubtitlePreferences() async {
    final stored = await preferences.getString('subtitle_preferences');
    if (stored == null) {
      return Map<String, String>.of(subtitlePreferenceDefaults);
    }

    final decoded = jsonDecode(stored);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid subtitle preferences.');
    }

    final values = Map<String, String>.of(subtitlePreferenceDefaults);
    for (final entry in decoded.entries) {
      if (_subtitlePreferenceKeys.contains(entry.key)) {
        final value = entry.value;
        if (value is! String) {
          throw FormatException(
            'Invalid subtitle preference value for ${entry.key}.',
          );
        }
        values[entry.key] = value;
      }
    }
    return values;
  }

  Future<void> setSubtitlePreferences(Map<String, String> values) {
    final supportedValues = <String, String>{
      for (final entry in values.entries)
        if (_subtitlePreferenceKeys.contains(entry.key)) entry.key: entry.value,
    };
    return preferences.setString(
      'subtitle_preferences',
      jsonEncode(supportedValues),
    );
  }

  Future<String?> getExtraMpvOptions() =>
      preferences.getString('extra_mpv_options');

  Future<void> setExtraMpvOptions(String value) =>
      preferences.setString('extra_mpv_options', value);

  Future<String?> getLocale() => preferences.getString('locale');

  Future<void> setLocale(String value) =>
      preferences.setString('locale', value);

  Future<bool> getDarkMode() async =>
      await preferences.getBool('dark_mode') ?? false;

  Future<void> setDarkMode(bool value) =>
      preferences.setBool('dark_mode', value);

  Future<List<String>> getFavorites() async =>
      await preferences.getStringList('favorites') ?? [];

  Future<void> addFavorite(String path) async {
    final favorites = await getFavorites();
    if (!favorites.contains(path)) {
      favorites.add(path);
      await preferences.setStringList('favorites', favorites);
    }
  }

  Future<void> removeFavorite(String path) async {
    final favorites = await getFavorites();
    favorites.remove(path);
    await preferences.setStringList('favorites', favorites);
  }

  Future<String?> getOpenSubtitlesApiKey() =>
      preferences.getString('opensubtitles_api_key');

  Future<void> setOpenSubtitlesApiKey(String value) =>
      preferences.setString('opensubtitles_api_key', value);
}
