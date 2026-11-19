// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class RecentFiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get path => text()();
  DateTimeColumn get openedAt => dateTime().withDefault(currentDateAndTime)();
}

class ResumePositions extends Table {
  TextColumn get path => text()();
  IntColumn get positionMilliseconds => integer()();

  @override
  Set<Column<Object>> get primaryKey => {path};
}

class PlaylistEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get playlistName => text()();
  TextColumn get source => text()();
  IntColumn get position => integer()();
}

@DriftDatabase(tables: [RecentFiles, ResumePositions, PlaylistEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<void> addRecentFile(String path) async {
    await into(recentFiles).insert(
      RecentFilesCompanion.insert(path: path),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<List<RecentFile>> recentFilesList({int limit = 20}) =>
      (select(recentFiles)
            ..orderBy([
              (row) => OrderingTerm(
                expression: row.openedAt,
                mode: OrderingMode.desc,
              ),
            ])
            ..limit(limit))
          .get();

  Future<void> saveResumePosition(String path, Duration position) =>
      into(resumePositions).insertOnConflictUpdate(
        ResumePositionsCompanion.insert(
          path: path,
          positionMilliseconds: position.inMilliseconds,
        ),
      );

  Future<Duration?> resumePosition(String path) async {
    final row = await (select(
      resumePositions,
    )..where((table) => table.path.equals(path))).getSingleOrNull();
    return row == null
        ? null
        : Duration(milliseconds: row.positionMilliseconds);
  }

  Future<void> savePlaylist(String name, List<String> sources) async {
    await (delete(
      playlistEntries,
    )..where((table) => table.playlistName.equals(name))).go();
    await batch((batch) {
      batch.insertAll(playlistEntries, [
        for (var i = 0; i < sources.length; i++)
          PlaylistEntriesCompanion.insert(
            playlistName: name,
            source: sources[i],
            position: i,
          ),
      ]);
    });
  }

  Future<List<String>> loadPlaylist(String name) async {
    final rows =
        await (select(playlistEntries)
              ..where((table) => table.playlistName.equals(name))
              ..orderBy([
                (table) => OrderingTerm(
                  expression: table.position,
                  mode: OrderingMode.asc,
                ),
              ]))
            .get();
    return rows.map((row) => row.source).toList();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, 'esyplayer.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
