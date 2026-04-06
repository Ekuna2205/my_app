import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_db.g.dart';

class ServiceTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()(); // жишээ: "Гадна угаалга"
  TextColumn get vehicleType => text()(); // "Суудлын", "Жийп" г.м.
  IntColumn get price => integer()(); // төгрөг
}

class WashRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get plate => text()(); // машины дугаар
  IntColumn get serviceId => integer().references(ServiceTypes, #id)();
  IntColumn get workerId => integer()(); // одоохондоо 1 = worker1 гэж жишээ
  DateTimeColumn get time => dateTime()(); // бүртгэсэн цаг
  IntColumn get amount => integer()(); // төлсөн үнэ
}

@DriftDatabase(tables: [ServiceTypes, WashRecords])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Өнөөдрийн нийт орлого
  // lib/database/app_db.dart доторх функц

  Future<int> getTodayIncome() async {
    final todayStart = DateTime.now().copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );

    final records = await (select(washRecords)
          ..where((r) => r.time.isBiggerOrEqualValue(todayStart)))
        .get();

    // fold-ийн төрлийг хүчээр зааж өгч байна
    return records.fold<int>(
      0,
      (int sum, WashRecord r) => sum + r.amount,
    );
  }

  // Өнөөдрийн бүх бүртгэл
  Future<List<WashRecord>> getTodayRecords() async {
    final todayStart = DateTime.now().copyWith(hour: 0, minute: 0, second: 0);
    return (select(washRecords)
          ..where((r) => r.time.isBiggerOrEqualValue(todayStart))
          ..orderBy([(r) => OrderingTerm.desc(r.time)]))
        .get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'wash.db'));
    return NativeDatabase.createInBackground(file);
  });
}
