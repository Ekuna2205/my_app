import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_db.dart';

part 'db_providers.g.dart';

@riverpod
AppDatabase database(DatabaseRef ref) {
  return AppDatabase();
}

@riverpod
Future<int> todayIncome(TodayIncomeRef ref) async {
  final db = ref.watch(databaseProvider);
  return db.getTodayIncome();
}

@riverpod
Future<List<WashRecord>> todayRecords(TodayRecordsRef ref) async {
  final db = ref.watch(databaseProvider);
  return db.getTodayRecords();
}
