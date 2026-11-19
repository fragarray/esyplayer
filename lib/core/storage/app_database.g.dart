// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RecentFilesTable extends RecentFiles
    with TableInfo<$RecentFilesTable, RecentFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, path, openedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecentFile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecentFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentFile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_at'],
      )!,
    );
  }

  @override
  $RecentFilesTable createAlias(String alias) {
    return $RecentFilesTable(attachedDatabase, alias);
  }
}

class RecentFile extends DataClass implements Insertable<RecentFile> {
  final int id;
  final String path;
  final DateTime openedAt;
  const RecentFile({
    required this.id,
    required this.path,
    required this.openedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['path'] = Variable<String>(path);
    map['opened_at'] = Variable<DateTime>(openedAt);
    return map;
  }

  RecentFilesCompanion toCompanion(bool nullToAbsent) {
    return RecentFilesCompanion(
      id: Value(id),
      path: Value(path),
      openedAt: Value(openedAt),
    );
  }

  factory RecentFile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentFile(
      id: serializer.fromJson<int>(json['id']),
      path: serializer.fromJson<String>(json['path']),
      openedAt: serializer.fromJson<DateTime>(json['openedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'path': serializer.toJson<String>(path),
      'openedAt': serializer.toJson<DateTime>(openedAt),
    };
  }

  RecentFile copyWith({int? id, String? path, DateTime? openedAt}) =>
      RecentFile(
        id: id ?? this.id,
        path: path ?? this.path,
        openedAt: openedAt ?? this.openedAt,
      );
  RecentFile copyWithCompanion(RecentFilesCompanion data) {
    return RecentFile(
      id: data.id.present ? data.id.value : this.id,
      path: data.path.present ? data.path.value : this.path,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentFile(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('openedAt: $openedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, path, openedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentFile &&
          other.id == this.id &&
          other.path == this.path &&
          other.openedAt == this.openedAt);
}

class RecentFilesCompanion extends UpdateCompanion<RecentFile> {
  final Value<int> id;
  final Value<String> path;
  final Value<DateTime> openedAt;
  const RecentFilesCompanion({
    this.id = const Value.absent(),
    this.path = const Value.absent(),
    this.openedAt = const Value.absent(),
  });
  RecentFilesCompanion.insert({
    this.id = const Value.absent(),
    required String path,
    this.openedAt = const Value.absent(),
  }) : path = Value(path);
  static Insertable<RecentFile> custom({
    Expression<int>? id,
    Expression<String>? path,
    Expression<DateTime>? openedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (path != null) 'path': path,
      if (openedAt != null) 'opened_at': openedAt,
    });
  }

  RecentFilesCompanion copyWith({
    Value<int>? id,
    Value<String>? path,
    Value<DateTime>? openedAt,
  }) {
    return RecentFilesCompanion(
      id: id ?? this.id,
      path: path ?? this.path,
      openedAt: openedAt ?? this.openedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentFilesCompanion(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('openedAt: $openedAt')
          ..write(')'))
        .toString();
  }
}

class $ResumePositionsTable extends ResumePositions
    with TableInfo<$ResumePositionsTable, ResumePosition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResumePositionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMillisecondsMeta =
      const VerificationMeta('positionMilliseconds');
  @override
  late final GeneratedColumn<int> positionMilliseconds = GeneratedColumn<int>(
    'position_milliseconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [path, positionMilliseconds];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'resume_positions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResumePosition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('position_milliseconds')) {
      context.handle(
        _positionMillisecondsMeta,
        positionMilliseconds.isAcceptableOrUnknown(
          data['position_milliseconds']!,
          _positionMillisecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_positionMillisecondsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {path};
  @override
  ResumePosition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResumePosition(
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      positionMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_milliseconds'],
      )!,
    );
  }

  @override
  $ResumePositionsTable createAlias(String alias) {
    return $ResumePositionsTable(attachedDatabase, alias);
  }
}

class ResumePosition extends DataClass implements Insertable<ResumePosition> {
  final String path;
  final int positionMilliseconds;
  const ResumePosition({
    required this.path,
    required this.positionMilliseconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['path'] = Variable<String>(path);
    map['position_milliseconds'] = Variable<int>(positionMilliseconds);
    return map;
  }

  ResumePositionsCompanion toCompanion(bool nullToAbsent) {
    return ResumePositionsCompanion(
      path: Value(path),
      positionMilliseconds: Value(positionMilliseconds),
    );
  }

  factory ResumePosition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResumePosition(
      path: serializer.fromJson<String>(json['path']),
      positionMilliseconds: serializer.fromJson<int>(
        json['positionMilliseconds'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'path': serializer.toJson<String>(path),
      'positionMilliseconds': serializer.toJson<int>(positionMilliseconds),
    };
  }

  ResumePosition copyWith({String? path, int? positionMilliseconds}) =>
      ResumePosition(
        path: path ?? this.path,
        positionMilliseconds: positionMilliseconds ?? this.positionMilliseconds,
      );
  ResumePosition copyWithCompanion(ResumePositionsCompanion data) {
    return ResumePosition(
      path: data.path.present ? data.path.value : this.path,
      positionMilliseconds: data.positionMilliseconds.present
          ? data.positionMilliseconds.value
          : this.positionMilliseconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResumePosition(')
          ..write('path: $path, ')
          ..write('positionMilliseconds: $positionMilliseconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(path, positionMilliseconds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResumePosition &&
          other.path == this.path &&
          other.positionMilliseconds == this.positionMilliseconds);
}

class ResumePositionsCompanion extends UpdateCompanion<ResumePosition> {
  final Value<String> path;
  final Value<int> positionMilliseconds;
  final Value<int> rowid;
  const ResumePositionsCompanion({
    this.path = const Value.absent(),
    this.positionMilliseconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResumePositionsCompanion.insert({
    required String path,
    required int positionMilliseconds,
    this.rowid = const Value.absent(),
  }) : path = Value(path),
       positionMilliseconds = Value(positionMilliseconds);
  static Insertable<ResumePosition> custom({
    Expression<String>? path,
    Expression<int>? positionMilliseconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (path != null) 'path': path,
      if (positionMilliseconds != null)
        'position_milliseconds': positionMilliseconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResumePositionsCompanion copyWith({
    Value<String>? path,
    Value<int>? positionMilliseconds,
    Value<int>? rowid,
  }) {
    return ResumePositionsCompanion(
      path: path ?? this.path,
      positionMilliseconds: positionMilliseconds ?? this.positionMilliseconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (positionMilliseconds.present) {
      map['position_milliseconds'] = Variable<int>(positionMilliseconds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResumePositionsCompanion(')
          ..write('path: $path, ')
          ..write('positionMilliseconds: $positionMilliseconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistEntriesTable extends PlaylistEntries
    with TableInfo<$PlaylistEntriesTable, PlaylistEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _playlistNameMeta = const VerificationMeta(
    'playlistName',
  );
  @override
  late final GeneratedColumn<String> playlistName = GeneratedColumn<String>(
    'playlist_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, playlistName, source, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('playlist_name')) {
      context.handle(
        _playlistNameMeta,
        playlistName.isAcceptableOrUnknown(
          data['playlist_name']!,
          _playlistNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_playlistNameMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      playlistName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_name'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $PlaylistEntriesTable createAlias(String alias) {
    return $PlaylistEntriesTable(attachedDatabase, alias);
  }
}

class PlaylistEntry extends DataClass implements Insertable<PlaylistEntry> {
  final int id;
  final String playlistName;
  final String source;
  final int position;
  const PlaylistEntry({
    required this.id,
    required this.playlistName,
    required this.source,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['playlist_name'] = Variable<String>(playlistName);
    map['source'] = Variable<String>(source);
    map['position'] = Variable<int>(position);
    return map;
  }

  PlaylistEntriesCompanion toCompanion(bool nullToAbsent) {
    return PlaylistEntriesCompanion(
      id: Value(id),
      playlistName: Value(playlistName),
      source: Value(source),
      position: Value(position),
    );
  }

  factory PlaylistEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistEntry(
      id: serializer.fromJson<int>(json['id']),
      playlistName: serializer.fromJson<String>(json['playlistName']),
      source: serializer.fromJson<String>(json['source']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'playlistName': serializer.toJson<String>(playlistName),
      'source': serializer.toJson<String>(source),
      'position': serializer.toJson<int>(position),
    };
  }

  PlaylistEntry copyWith({
    int? id,
    String? playlistName,
    String? source,
    int? position,
  }) => PlaylistEntry(
    id: id ?? this.id,
    playlistName: playlistName ?? this.playlistName,
    source: source ?? this.source,
    position: position ?? this.position,
  );
  PlaylistEntry copyWithCompanion(PlaylistEntriesCompanion data) {
    return PlaylistEntry(
      id: data.id.present ? data.id.value : this.id,
      playlistName: data.playlistName.present
          ? data.playlistName.value
          : this.playlistName,
      source: data.source.present ? data.source.value : this.source,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistEntry(')
          ..write('id: $id, ')
          ..write('playlistName: $playlistName, ')
          ..write('source: $source, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, playlistName, source, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistEntry &&
          other.id == this.id &&
          other.playlistName == this.playlistName &&
          other.source == this.source &&
          other.position == this.position);
}

class PlaylistEntriesCompanion extends UpdateCompanion<PlaylistEntry> {
  final Value<int> id;
  final Value<String> playlistName;
  final Value<String> source;
  final Value<int> position;
  const PlaylistEntriesCompanion({
    this.id = const Value.absent(),
    this.playlistName = const Value.absent(),
    this.source = const Value.absent(),
    this.position = const Value.absent(),
  });
  PlaylistEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String playlistName,
    required String source,
    required int position,
  }) : playlistName = Value(playlistName),
       source = Value(source),
       position = Value(position);
  static Insertable<PlaylistEntry> custom({
    Expression<int>? id,
    Expression<String>? playlistName,
    Expression<String>? source,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playlistName != null) 'playlist_name': playlistName,
      if (source != null) 'source': source,
      if (position != null) 'position': position,
    });
  }

  PlaylistEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? playlistName,
    Value<String>? source,
    Value<int>? position,
  }) {
    return PlaylistEntriesCompanion(
      id: id ?? this.id,
      playlistName: playlistName ?? this.playlistName,
      source: source ?? this.source,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (playlistName.present) {
      map['playlist_name'] = Variable<String>(playlistName.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistEntriesCompanion(')
          ..write('id: $id, ')
          ..write('playlistName: $playlistName, ')
          ..write('source: $source, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RecentFilesTable recentFiles = $RecentFilesTable(this);
  late final $ResumePositionsTable resumePositions = $ResumePositionsTable(
    this,
  );
  late final $PlaylistEntriesTable playlistEntries = $PlaylistEntriesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    recentFiles,
    resumePositions,
    playlistEntries,
  ];
}

typedef $$RecentFilesTableCreateCompanionBuilder =
    RecentFilesCompanion Function({
      Value<int> id,
      required String path,
      Value<DateTime> openedAt,
    });
typedef $$RecentFilesTableUpdateCompanionBuilder =
    RecentFilesCompanion Function({
      Value<int> id,
      Value<String> path,
      Value<DateTime> openedAt,
    });

class $$RecentFilesTableFilterComposer
    extends Composer<_$AppDatabase, $RecentFilesTable> {
  $$RecentFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecentFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecentFilesTable> {
  $$RecentFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecentFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecentFilesTable> {
  $$RecentFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);
}

class $$RecentFilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecentFilesTable,
          RecentFile,
          $$RecentFilesTableFilterComposer,
          $$RecentFilesTableOrderingComposer,
          $$RecentFilesTableAnnotationComposer,
          $$RecentFilesTableCreateCompanionBuilder,
          $$RecentFilesTableUpdateCompanionBuilder,
          (
            RecentFile,
            BaseReferences<_$AppDatabase, $RecentFilesTable, RecentFile>,
          ),
          RecentFile,
          PrefetchHooks Function()
        > {
  $$RecentFilesTableTableManager(_$AppDatabase db, $RecentFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecentFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> path = const Value.absent(),
            Value<DateTime> openedAt = const Value.absent(),
          }) => RecentFilesCompanion(id: id, path: path, openedAt: openedAt),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String path,
                Value<DateTime> openedAt = const Value.absent(),
              }) => RecentFilesCompanion.insert(
                id: id,
                path: path,
                openedAt: openedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecentFilesTable, RecentFile>(table),
                  BaseReferences<_$AppDatabase, $RecentFilesTable, RecentFile>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecentFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecentFilesTable,
      RecentFile,
      $$RecentFilesTableFilterComposer,
      $$RecentFilesTableOrderingComposer,
      $$RecentFilesTableAnnotationComposer,
      $$RecentFilesTableCreateCompanionBuilder,
      $$RecentFilesTableUpdateCompanionBuilder,
      (
        RecentFile,
        BaseReferences<_$AppDatabase, $RecentFilesTable, RecentFile>,
      ),
      RecentFile,
      PrefetchHooks Function()
    >;
typedef $$ResumePositionsTableCreateCompanionBuilder =
    ResumePositionsCompanion Function({
      required String path,
      required int positionMilliseconds,
      Value<int> rowid,
    });
typedef $$ResumePositionsTableUpdateCompanionBuilder =
    ResumePositionsCompanion Function({
      Value<String> path,
      Value<int> positionMilliseconds,
      Value<int> rowid,
    });

class $$ResumePositionsTableFilterComposer
    extends Composer<_$AppDatabase, $ResumePositionsTable> {
  $$ResumePositionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMilliseconds => $composableBuilder(
    column: $table.positionMilliseconds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ResumePositionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ResumePositionsTable> {
  $$ResumePositionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMilliseconds => $composableBuilder(
    column: $table.positionMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ResumePositionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResumePositionsTable> {
  $$ResumePositionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<int> get positionMilliseconds => $composableBuilder(
    column: $table.positionMilliseconds,
    builder: (column) => column,
  );
}

class $$ResumePositionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResumePositionsTable,
          ResumePosition,
          $$ResumePositionsTableFilterComposer,
          $$ResumePositionsTableOrderingComposer,
          $$ResumePositionsTableAnnotationComposer,
          $$ResumePositionsTableCreateCompanionBuilder,
          $$ResumePositionsTableUpdateCompanionBuilder,
          (
            ResumePosition,
            BaseReferences<
              _$AppDatabase,
              $ResumePositionsTable,
              ResumePosition
            >,
          ),
          ResumePosition,
          PrefetchHooks Function()
        > {
  $$ResumePositionsTableTableManager(
    _$AppDatabase db,
    $ResumePositionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResumePositionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResumePositionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResumePositionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> path = const Value.absent(),
                Value<int> positionMilliseconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResumePositionsCompanion(
                path: path,
                positionMilliseconds: positionMilliseconds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String path,
                required int positionMilliseconds,
                Value<int> rowid = const Value.absent(),
              }) => ResumePositionsCompanion.insert(
                path: path,
                positionMilliseconds: positionMilliseconds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ResumePositionsTable, ResumePosition>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ResumePositionsTable,
                    ResumePosition
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ResumePositionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResumePositionsTable,
      ResumePosition,
      $$ResumePositionsTableFilterComposer,
      $$ResumePositionsTableOrderingComposer,
      $$ResumePositionsTableAnnotationComposer,
      $$ResumePositionsTableCreateCompanionBuilder,
      $$ResumePositionsTableUpdateCompanionBuilder,
      (
        ResumePosition,
        BaseReferences<_$AppDatabase, $ResumePositionsTable, ResumePosition>,
      ),
      ResumePosition,
      PrefetchHooks Function()
    >;
typedef $$PlaylistEntriesTableCreateCompanionBuilder =
    PlaylistEntriesCompanion Function({
      Value<int> id,
      required String playlistName,
      required String source,
      required int position,
    });
typedef $$PlaylistEntriesTableUpdateCompanionBuilder =
    PlaylistEntriesCompanion Function({
      Value<int> id,
      Value<String> playlistName,
      Value<String> source,
      Value<int> position,
    });

class $$PlaylistEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistEntriesTable> {
  $$PlaylistEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playlistName => $composableBuilder(
    column: $table.playlistName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaylistEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistEntriesTable> {
  $$PlaylistEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playlistName => $composableBuilder(
    column: $table.playlistName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistEntriesTable> {
  $$PlaylistEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get playlistName => $composableBuilder(
    column: $table.playlistName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$PlaylistEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistEntriesTable,
          PlaylistEntry,
          $$PlaylistEntriesTableFilterComposer,
          $$PlaylistEntriesTableOrderingComposer,
          $$PlaylistEntriesTableAnnotationComposer,
          $$PlaylistEntriesTableCreateCompanionBuilder,
          $$PlaylistEntriesTableUpdateCompanionBuilder,
          (
            PlaylistEntry,
            BaseReferences<_$AppDatabase, $PlaylistEntriesTable, PlaylistEntry>,
          ),
          PlaylistEntry,
          PrefetchHooks Function()
        > {
  $$PlaylistEntriesTableTableManager(
    _$AppDatabase db,
    $PlaylistEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> playlistName = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => PlaylistEntriesCompanion(
                id: id,
                playlistName: playlistName,
                source: source,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String playlistName,
                required String source,
                required int position,
              }) => PlaylistEntriesCompanion.insert(
                id: id,
                playlistName: playlistName,
                source: source,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlaylistEntriesTable, PlaylistEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PlaylistEntriesTable,
                    PlaylistEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaylistEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistEntriesTable,
      PlaylistEntry,
      $$PlaylistEntriesTableFilterComposer,
      $$PlaylistEntriesTableOrderingComposer,
      $$PlaylistEntriesTableAnnotationComposer,
      $$PlaylistEntriesTableCreateCompanionBuilder,
      $$PlaylistEntriesTableUpdateCompanionBuilder,
      (
        PlaylistEntry,
        BaseReferences<_$AppDatabase, $PlaylistEntriesTable, PlaylistEntry>,
      ),
      PlaylistEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RecentFilesTableTableManager get recentFiles =>
      $$RecentFilesTableTableManager(_db, _db.recentFiles);
  $$ResumePositionsTableTableManager get resumePositions =>
      $$ResumePositionsTableTableManager(_db, _db.resumePositions);
  $$PlaylistEntriesTableTableManager get playlistEntries =>
      $$PlaylistEntriesTableTableManager(_db, _db.playlistEntries);
}
