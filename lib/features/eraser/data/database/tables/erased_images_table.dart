import 'package:drift/drift.dart';

class ErasedImages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get originalPath => text()();
  TextColumn get resultPath => text()();
  DateTimeColumn get createdAt => dateTime()();
}

