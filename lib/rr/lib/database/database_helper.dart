import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/car.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'kk.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cars(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            plateNumber TEXT NOT NULL,
            model TEXT NOT NULL,
            price INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE wash_records(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            carNumber TEXT NOT NULL,
            workerName TEXT NOT NULL,
            washType TEXT NOT NULL,
            price INTEGER NOT NULL,
            date TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE prices(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            washType TEXT NOT NULL UNIQUE,
            price INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS prices(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              washType TEXT NOT NULL UNIQUE,
              price INTEGER NOT NULL
            )
          ''');
        }
      },
    );
  }

  // -------------------- CAR CRUD --------------------
  Future<int> insertCar(Car car) async {
    final db = await database;
    return db.insert(
      'cars',
      car.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Car>> getCars() async {
    final db = await database;
    final maps = await db.query('cars', orderBy: 'id DESC');
    return maps.map((m) => Car.fromMap(m)).toList();
  }

  Future<int> updateCar(Car car) async {
    final db = await database;
    return db.update('cars', car.toMap(), where: 'id = ?', whereArgs: [car.id]);
  }

  Future<int> deleteCar(int id) async {
    final db = await database;
    return db.delete('cars', where: 'id = ?', whereArgs: [id]);
  }

  // -------------------- WASH RECORDS --------------------
  Future<int> insertWashRecord(Map<String, dynamic> record) async {
    final db = await database;
    return db.insert('wash_records', record);
  }

  Future<List<Map<String, dynamic>>> getWashRecords() async {
    final db = await database;
    return db.query('wash_records', orderBy: 'id DESC');
  }

  // -------------------- PRICES (Customer / Admin) --------------------
  Future<void> seedPricesIfEmpty() async {
    final db = await database;

    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM prices'),
    );

    if ((count ?? 0) > 0) return;

    await db.insert('prices', {'washType': 'Гадна', 'price': 10000});
    await db.insert('prices', {'washType': 'Дотор', 'price': 12000});
    await db.insert('prices', {'washType': 'Бүтэн', 'price': 18000});
    await db.insert('prices', {'washType': 'Вакум', 'price': 5000});
  }

  Future<List<Map<String, dynamic>>> getPrices() async {
    final db = await database;
    return db.query('prices', orderBy: 'id ASC');
  }

  Future<int> setPrice(String washType, int price) async {
    final db = await database;
    return db.insert('prices', {
      'washType': washType,
      'price': price,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // -------------------- REPORTS (Admin income) --------------------
  // Өнөөдрийн орлого + өнөөдөр хэдэн машин угаагдсан
  Future<Map<String, int>> getTodaySummary() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(
      0,
      10,
    ); // YYYY-MM-DD

    final incomeResult = await db.rawQuery(
      '''
      SELECT IFNULL(SUM(price), 0) AS totalIncome
      FROM wash_records
      WHERE substr(date, 1, 10) = ?
      ''',
      [today],
    );

    final countResult = await db.rawQuery(
      '''
      SELECT COUNT(*) AS totalCars
      FROM wash_records
      WHERE substr(date, 1, 10) = ?
      ''',
      [today],
    );

    final totalIncome = (incomeResult.first['totalIncome'] as int?) ?? 0;
    final totalCars = (countResult.first['totalCars'] as int?) ?? 0;

    return {'totalIncome': totalIncome, 'totalCars': totalCars};
  }

  // Сүүлийн 7 хоногийн орлого (өдөр бүрээр)
  Future<List<Map<String, dynamic>>> getLast7DaysIncome() async {
    final db = await database;

    final rows = await db.rawQuery('''
      SELECT substr(date, 1, 10) AS day, IFNULL(SUM(price), 0) AS total
      FROM wash_records
      WHERE substr(date, 1, 10) >= date('now', '-6 day')
      GROUP BY day
      ORDER BY day ASC
    ''');

    return rows; // [{day: '2026-03-01', total: 120000}, ...]
  }
}
