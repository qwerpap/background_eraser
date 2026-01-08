import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables/erased_images_table.dart';

part 'eraser_database.g.dart';

@DriftDatabase(tables: [ErasedImages])
class EraserDatabase extends _$EraserDatabase {
  EraserDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'eraser.db'));
    return NativeDatabase(file);
  });
}

