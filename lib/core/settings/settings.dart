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

  Future<String?> getOpenSubtitlesApiKey() =>
      preferences.getString('opensubtitles_api_key');

  Future<void> setOpenSubtitlesApiKey(String value) =>
      preferences.setString('opensubtitles_api_key', value);
}
