// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eraser_database.dart';

// ignore_for_file: type=lint
class $ErasedImagesTable extends ErasedImages
    with TableInfo<$ErasedImagesTable, ErasedImage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ErasedImagesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _originalPathMeta = const VerificationMeta(
    'originalPath',
  );
  @override
  late final GeneratedColumn<String> originalPath = GeneratedColumn<String>(
    'original_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultPathMeta = const VerificationMeta(
    'resultPath',
  );
  @override
  late final GeneratedColumn<String> resultPath = GeneratedColumn<String>(
    'result_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    originalPath,
    resultPath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'erased_images';
  @override
  VerificationContext validateIntegrity(
    Insertable<ErasedImage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('original_path')) {
      context.handle(
        _originalPathMeta,
        originalPath.isAcceptableOrUnknown(
          data['original_path']!,
          _originalPathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalPathMeta);
    }
    if (data.containsKey('result_path')) {
      context.handle(
        _resultPathMeta,
        resultPath.isAcceptableOrUnknown(data['result_path']!, _resultPathMeta),
      );
    } else if (isInserting) {
      context.missing(_resultPathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ErasedImage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ErasedImage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      originalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_path'],
      )!,
      resultPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_path'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ErasedImagesTable createAlias(String alias) {
    return $ErasedImagesTable(attachedDatabase, alias);
  }
}

class ErasedImage extends DataClass implements Insertable<ErasedImage> {
  final int id;
  final String originalPath;
  final String resultPath;
  final DateTime createdAt;
  const ErasedImage({
    required this.id,
    required this.originalPath,
    required this.resultPath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['original_path'] = Variable<String>(originalPath);
    map['result_path'] = Variable<String>(resultPath);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ErasedImagesCompanion toCompanion(bool nullToAbsent) {
    return ErasedImagesCompanion(
      id: Value(id),
      originalPath: Value(originalPath),
      resultPath: Value(resultPath),
      createdAt: Value(createdAt),
    );
  }

  factory ErasedImage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ErasedImage(
      id: serializer.fromJson<int>(json['id']),
      originalPath: serializer.fromJson<String>(json['originalPath']),
      resultPath: serializer.fromJson<String>(json['resultPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'originalPath': serializer.toJson<String>(originalPath),
      'resultPath': serializer.toJson<String>(resultPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ErasedImage copyWith({
    int? id,
    String? originalPath,
    String? resultPath,
    DateTime? createdAt,
  }) => ErasedImage(
    id: id ?? this.id,
    originalPath: originalPath ?? this.originalPath,
    resultPath: resultPath ?? this.resultPath,
    createdAt: createdAt ?? this.createdAt,
  );
  ErasedImage copyWithCompanion(ErasedImagesCompanion data) {
    return ErasedImage(
      id: data.id.present ? data.id.value : this.id,
      originalPath: data.originalPath.present
          ? data.originalPath.value
          : this.originalPath,
      resultPath: data.resultPath.present
          ? data.resultPath.value
          : this.resultPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ErasedImage(')
          ..write('id: $id, ')
          ..write('originalPath: $originalPath, ')
          ..write('resultPath: $resultPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, originalPath, resultPath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ErasedImage &&
          other.id == this.id &&
          other.originalPath == this.originalPath &&
          other.resultPath == this.resultPath &&
          other.createdAt == this.createdAt);
}

class ErasedImagesCompanion extends UpdateCompanion<ErasedImage> {
  final Value<int> id;
  final Value<String> originalPath;
  final Value<String> resultPath;
  final Value<DateTime> createdAt;
  const ErasedImagesCompanion({
    this.id = const Value.absent(),
    this.originalPath = const Value.absent(),
    this.resultPath = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ErasedImagesCompanion.insert({
    this.id = const Value.absent(),
    required String originalPath,
    required String resultPath,
    required DateTime createdAt,
  }) : originalPath = Value(originalPath),
       resultPath = Value(resultPath),
       createdAt = Value(createdAt);
  static Insertable<ErasedImage> custom({
    Expression<int>? id,
    Expression<String>? originalPath,
    Expression<String>? resultPath,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (originalPath != null) 'original_path': originalPath,
      if (resultPath != null) 'result_path': resultPath,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ErasedImagesCompanion copyWith({
    Value<int>? id,
    Value<String>? originalPath,
    Value<String>? resultPath,
    Value<DateTime>? createdAt,
  }) {
    return ErasedImagesCompanion(
      id: id ?? this.id,
      originalPath: originalPath ?? this.originalPath,
      resultPath: resultPath ?? this.resultPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (originalPath.present) {
      map['original_path'] = Variable<String>(originalPath.value);
    }
    if (resultPath.present) {
      map['result_path'] = Variable<String>(resultPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ErasedImagesCompanion(')
          ..write('id: $id, ')
          ..write('originalPath: $originalPath, ')
          ..write('resultPath: $resultPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$EraserDatabase extends GeneratedDatabase {
  _$EraserDatabase(QueryExecutor e) : super(e);
  $EraserDatabaseManager get managers => $EraserDatabaseManager(this);
  late final $ErasedImagesTable erasedImages = $ErasedImagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [erasedImages];
}

typedef $$ErasedImagesTableCreateCompanionBuilder =
    ErasedImagesCompanion Function({
      Value<int> id,
      required String originalPath,
      required String resultPath,
      required DateTime createdAt,
    });
typedef $$ErasedImagesTableUpdateCompanionBuilder =
    ErasedImagesCompanion Function({
      Value<int> id,
      Value<String> originalPath,
      Value<String> resultPath,
      Value<DateTime> createdAt,
    });

class $$ErasedImagesTableFilterComposer
    extends Composer<_$EraserDatabase, $ErasedImagesTable> {
  $$ErasedImagesTableFilterComposer({
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

  ColumnFilters<String> get originalPath => $composableBuilder(
    column: $table.originalPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultPath => $composableBuilder(
    column: $table.resultPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ErasedImagesTableOrderingComposer
    extends Composer<_$EraserDatabase, $ErasedImagesTable> {
  $$ErasedImagesTableOrderingComposer({
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

  ColumnOrderings<String> get originalPath => $composableBuilder(
    column: $table.originalPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultPath => $composableBuilder(
    column: $table.resultPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ErasedImagesTableAnnotationComposer
    extends Composer<_$EraserDatabase, $ErasedImagesTable> {
  $$ErasedImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get originalPath => $composableBuilder(
    column: $table.originalPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resultPath => $composableBuilder(
    column: $table.resultPath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ErasedImagesTableTableManager
    extends
        RootTableManager<
          _$EraserDatabase,
          $ErasedImagesTable,
          ErasedImage,
          $$ErasedImagesTableFilterComposer,
          $$ErasedImagesTableOrderingComposer,
          $$ErasedImagesTableAnnotationComposer,
          $$ErasedImagesTableCreateCompanionBuilder,
          $$ErasedImagesTableUpdateCompanionBuilder,
          (
            ErasedImage,
            BaseReferences<_$EraserDatabase, $ErasedImagesTable, ErasedImage>,
          ),
          ErasedImage,
          PrefetchHooks Function()
        > {
  $$ErasedImagesTableTableManager(_$EraserDatabase db, $ErasedImagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ErasedImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ErasedImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ErasedImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> originalPath = const Value.absent(),
                Value<String> resultPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ErasedImagesCompanion(
                id: id,
                originalPath: originalPath,
                resultPath: resultPath,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String originalPath,
                required String resultPath,
                required DateTime createdAt,
              }) => ErasedImagesCompanion.insert(
                id: id,
                originalPath: originalPath,
                resultPath: resultPath,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ErasedImagesTableProcessedTableManager =
    ProcessedTableManager<
      _$EraserDatabase,
      $ErasedImagesTable,
      ErasedImage,
      $$ErasedImagesTableFilterComposer,
      $$ErasedImagesTableOrderingComposer,
      $$ErasedImagesTableAnnotationComposer,
      $$ErasedImagesTableCreateCompanionBuilder,
      $$ErasedImagesTableUpdateCompanionBuilder,
      (
        ErasedImage,
        BaseReferences<_$EraserDatabase, $ErasedImagesTable, ErasedImage>,
      ),
      ErasedImage,
      PrefetchHooks Function()
    >;

class $EraserDatabaseManager {
  final _$EraserDatabase _db;
  $EraserDatabaseManager(this._db);
  $$ErasedImagesTableTableManager get erasedImages =>
      $$ErasedImagesTableTableManager(_db, _db.erasedImages);
}
