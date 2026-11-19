// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  AppSettings(this.preferences);

  final SharedPreferencesAsync preferences;

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
