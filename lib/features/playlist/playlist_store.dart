// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

class PlaylistStore {
  static Future<List<String>> load(String path) async {
    final file = File(path);
    final lines = await file.readAsLines();
    return lines
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('#'))
        .where((line) => !line.startsWith('['))
        .toList();
  }

  static Future<void> save(String path, List<String> sources) async {
    final file = File(path);
    await file.writeAsString(
      '#EXTM3U\n${sources.map((source) => '#EXTINF:-1,\n$source').join('\n')}\n',
    );
  }
}
