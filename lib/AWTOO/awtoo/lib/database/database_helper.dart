import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/car.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

  // =========================================================
  // DATABASE
  // =========================================================
  Future<Map<String, dynamic>?> autoAssignWorker({
    required String bookingDate,
    required String bookingTime,
    required String serviceType,
  }) async {
    final int duration = getDuration(serviceType);

    final List<Map<String, dynamic>> workers = await getAvailableWorkers(
      date: bookingDate,
      time: bookingTime,
      duration: duration,
    );

    if (workers.isEmpty) {
      return null;
    }

    return workers.first;
  }

  Future<List<Map<String, dynamic>>> getAvailableWorkers({
    required String date,
    required String time,
    required int duration,
  }) async {
    final Database db = await database;

    final List<Map<String, dynamic>> workers = await db.query(
      'workers',
      where: 'isActive = ?',
      whereArgs: <Object?>[1],
      orderBy: 'fullName ASC',
    );

    final List<Map<String, dynamic>> bookings = await db.query(
      'bookings',
      where: 'bookingDate = ? AND status != ?',
      whereArgs: <Object?>[date, 'cancelled'],
    );

    final int start = timeToMinutes(time);
    final int end = start + duration;

    return workers.where((w) {
      final int workerId = ((w['id'] as num?) ?? 0).toInt();

      final bool busy = bookings.any((b) {
        final int bookedWorkerId = ((b['workerId'] as num?) ?? 0).toInt();
        if (bookedWorkerId != workerId) return false;

        final String bookingStart = b['bookingTime']?.toString() ?? '00:00';
        final String bookingEnd = b['endTime']?.toString() ?? '00:00';

        final int s = timeToMinutes(bookingStart);
        final int e = timeToMinutes(bookingEnd);

        return start < e && end > s;
      });

      return !busy;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getBookedSlotsForDate(
    String bookingDate,
  ) async {
    final Database db = await database;
    return db.query(
      'bookings',
      columns: <String>[
        'bookingTime',
        'endTime',
        'workerId',
        'workerName',
        'status',
      ],
      where: 'bookingDate = ? AND status != ?',
      whereArgs: <Object?>[bookingDate, 'cancelled'],
      orderBy: 'bookingTime ASC',
    );
  }

  Future<int> getPriceByWashType(String washType) async {
    final Database db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'prices',
      where: 'washType = ?',
      whereArgs: <Object?>[washType],
      limit: 1,
    );

    if (result.isEmpty) return 0;
    return ((result.first['price'] as num?) ?? 0).toInt();
  }

  int getServiceDurationMinutes(String type) {
    return getDuration(type);
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<List<Map<String, dynamic>>> getWorkersWithLiveStatus({
    required String bookingDate,
  }) async {
    final Database db = await database;

    final List<Map<String, dynamic>> workers = await db.query(
      'workers',
      where: 'isActive = ?',
      whereArgs: <Object?>[1],
      orderBy: 'workerCode ASC',
    );

    final List<Map<String, dynamic>> bookings = await db.query(
      'bookings',
      where: 'bookingDate = ? AND status != ?',
      whereArgs: <Object?>[bookingDate, 'cancelled'],
      orderBy: 'bookingTime ASC',
    );

    final int nowMin = DateTime.now().hour * 60 + DateTime.now().minute;
    final String today = DateTime.now().toIso8601String().substring(0, 10);

    return workers.map((worker) {
      final int workerId = ((worker['id'] as num?) ?? 0).toInt();

      Map<String, dynamic>? activeBooking;

      for (final booking in bookings) {
        final int bookedWorkerId = ((booking['workerId'] as num?) ?? 0).toInt();
        if (bookedWorkerId != workerId) continue;

        if (bookingDate == today) {
          final int start = timeToMinutes(
            booking['bookingTime']?.toString() ?? '00:00',
          );
          final int end = timeToMinutes(
            booking['endTime']?.toString() ?? '00:00',
          );

          if (nowMin >= start && nowMin < end) {
            activeBooking = booking;
            break;
          }
        }
      }

      return <String, dynamic>{
        ...worker,
        'liveStatus': activeBooking == null ? 'free' : 'busy',
        'busyUntil': activeBooking == null
            ? ''
            : (activeBooking['endTime']?.toString() ?? ''),
        'currentCustomer': activeBooking == null
            ? ''
            : (activeBooking['customerName']?.toString() ?? ''),
        'currentPlate': activeBooking == null
            ? ''
            : (activeBooking['carPlate']?.toString() ?? ''),
      };
    }).toList();
  }

  Future<int> updateBookingWorker({
    required int bookingId,
    required int workerId,
    required String workerName,
  }) async {
    final Database db = await database;

    return db.update(
      'bookings',
      <String, dynamic>{'workerId': workerId, 'workerName': workerName},
      where: 'id = ?',
      whereArgs: <Object?>[bookingId],
    );
  }

  Future<List<Map<String, dynamic>>> getAvailableWorkersForExistingBooking({
    required int bookingId,
  }) async {
    final Map<String, dynamic>? booking = await getBookingById(bookingId);
    if (booking == null) return <Map<String, dynamic>>[];

    final String bookingDate = booking['bookingDate']?.toString() ?? '';
    final String bookingTime = booking['bookingTime']?.toString() ?? '';
    final String serviceType = booking['serviceType']?.toString() ?? '';
    final int currentWorkerId = ((booking['workerId'] as num?) ?? 0).toInt();

    final int duration = getDuration(serviceType);
    final List<Map<String, dynamic>> freeWorkers = await getAvailableWorkers(
      date: bookingDate,
      time: bookingTime,
      duration: duration,
    );

    final List<Map<String, dynamic>> allWorkers = await getWorkers();

    final List<Map<String, dynamic>> result = List<Map<String, dynamic>>.from(
      freeWorkers,
    );

    final bool hasCurrent = result.any(
      (w) => ((w['id'] as num?) ?? 0).toInt() == currentWorkerId,
    );

    if (!hasCurrent && currentWorkerId != 0) {
      final List<Map<String, dynamic>> current = allWorkers.where((w) {
        return ((w['id'] as num?) ?? 0).toInt() == currentWorkerId;
      }).toList();

      result.addAll(current);
    }

    result.sort((a, b) {
      final String ac = a['workerCode']?.toString() ?? '';
      final String bc = b['workerCode']?.toString() ?? '';
      return ac.compareTo(bc);
    });

    return result;
  }

  Future<Database> _initDB() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, 'shine.db');

    return openDatabase(
      path,
      version: 12,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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
        date TEXT NOT NULL,
        paymentStatus TEXT NOT NULL DEFAULT 'unpaid',
        customerPhone TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE prices(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        washType TEXT NOT NULL UNIQUE,
        price INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE workers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workerCode TEXT NOT NULL UNIQUE,
        fullName TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE customers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        phone TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        carPlate TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE wash_requests(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerName TEXT NOT NULL,
        customerPhone TEXT NOT NULL,
        carPlate TEXT NOT NULL,
        vehicleType TEXT NOT NULL,
        note TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE bookings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerName TEXT NOT NULL,
        phone TEXT NOT NULL,
        carPlate TEXT NOT NULL,
        bookingDate TEXT NOT NULL,
        bookingTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        serviceType TEXT NOT NULL,
        durationMinutes INTEGER NOT NULL,
        workerId INTEGER NOT NULL,
        workerName TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await _seedDefaultPrices(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS prices(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          washType TEXT NOT NULL UNIQUE,
          price INTEGER NOT NULL
        )
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS workers(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          fullName TEXT NOT NULL,
          username TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          isActive INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS customers(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          fullName TEXT NOT NULL,
          phone TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          carPlate TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS wash_requests(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          customerName TEXT NOT NULL,
          customerPhone TEXT NOT NULL,
          carPlate TEXT NOT NULL,
          vehicleType TEXT NOT NULL,
          note TEXT NOT NULL,
          status TEXT NOT NULL,
          createdAt TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS bookings(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          customerName TEXT NOT NULL,
          phone TEXT NOT NULL,
          carPlate TEXT NOT NULL,
          bookingDate TEXT NOT NULL,
          bookingTime TEXT NOT NULL,
          serviceType TEXT NOT NULL,
          status TEXT NOT NULL,
          createdAt TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 7) {
      try {
        await db.execute('''
          ALTER TABLE workers
          ADD COLUMN isActive INTEGER NOT NULL DEFAULT 0
        ''');
      } catch (_) {}

      try {
        await db.execute('''
          ALTER TABLE wash_records
          ADD COLUMN paymentStatus TEXT NOT NULL DEFAULT 'unpaid'
        ''');
      } catch (_) {}
    }

    if (oldVersion < 9) {
      try {
        await db.execute('''
          ALTER TABLE wash_records
          ADD COLUMN customerPhone TEXT
        ''');
      } catch (_) {}
    }

    if (oldVersion < 11) {
      try {
        await db.execute('''
          ALTER TABLE workers
          ADD COLUMN workerCode TEXT
        ''');
      } catch (_) {}

      final List<Map<String, dynamic>> workers = await db.query('workers');

      for (final Map<String, dynamic> worker in workers) {
        final String code = worker['workerCode']?.toString() ?? '';
        if (code.isEmpty) {
          final String newCode = await generateWorkerCode();
          await db.update(
            'workers',
            <String, dynamic>{'workerCode': newCode},
            where: 'id = ?',
            whereArgs: <Object?>[worker['id']],
          );
        }
      }
    }

    if (oldVersion < 12) {
      try {
        await db.execute("ALTER TABLE bookings ADD COLUMN endTime TEXT");
      } catch (_) {}

      try {
        await db.execute(
          "ALTER TABLE bookings ADD COLUMN durationMinutes INTEGER NOT NULL DEFAULT 60",
        );
      } catch (_) {}

      try {
        await db.execute(
          "ALTER TABLE bookings ADD COLUMN workerId INTEGER NOT NULL DEFAULT 0",
        );
      } catch (_) {}

      try {
        await db.execute(
          "ALTER TABLE bookings ADD COLUMN workerName TEXT NOT NULL DEFAULT ''",
        );
      } catch (_) {}
    }

    await _seedDefaultPrices(db);
  }

  Future<void> _seedDefaultPrices(Database db) async {
    await db.insert('prices', <String, dynamic>{
      'washType': 'Ажилтан угаах',
      'price': 25000,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await db.insert('prices', <String, dynamic>{
      'washType': 'Өөрөө угаах',
      'price': 20000,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // =========================================================
  // HELPERS
  // =========================================================

  String normalizePlate(String value) {
    String plate = value.trim().toUpperCase();

    if (plate.contains('/')) {
      plate = plate.split('/').first.trim();
    }

    plate = plate.replaceAll(' ', '');
    plate = plate.replaceAll('-', '');
    return plate;
  }

  int timeToMinutes(String time) {
    final List<String> parts = time.split(':');
    final int hour = int.tryParse(parts[0]) ?? 0;
    final int minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
  }

  String minutesToTime(int totalMinutes) {
    final int hour = totalMinutes ~/ 60;
    final int minute = totalMinutes % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  int getDuration(String type) {
    switch (type) {
      case 'Бүтэн':
        return 60;
      case 'Гадар':
        return 30;
      case 'Дотор':
        return 30;
      case 'Чэнж':
        return 120;
      case 'Тааз':
        return 45;
      case 'Шал':
        return 45;
      case 'Ажилтан угаах':
        return 60;
      case 'Өөрөө угаах':
        return 60;
      default:
        return 60;
    }
  }

  // =========================================================
  // CARS
  // =========================================================

  Future<int> insertCar(Car car) async {
    final Database db = await database;
    return db.insert(
      'cars',
      car.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Car>> getCars() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cars',
      orderBy: 'id DESC',
    );
    return maps.map((Map<String, dynamic> e) => Car.fromMap(e)).toList();
  }

  Future<int> updateCar(Car car) async {
    final Database db = await database;
    return db.update(
      'cars',
      car.toMap(),
      where: 'id = ?',
      whereArgs: <Object?>[car.id],
    );
  }

  Future<int> deleteCar(int id) async {
    final Database db = await database;
    return db.delete('cars', where: 'id = ?', whereArgs: <Object?>[id]);
  }

  // =========================================================
  // WASH RECORDS
  // =========================================================

  Future<int> insertWashRecord(Map<String, dynamic> record) async {
    final Database db = await database;

    if (record['carNumber'] != null) {
      record['carNumber'] = record['carNumber'].toString().trim().toUpperCase();
    }

    record['paymentStatus'] ??= 'unpaid';
    record['customerPhone'] ??= "";

    return db.insert('wash_records', record);
  }

  Future<List<Map<String, dynamic>>> getWashRecords() async {
    final Database db = await database;
    return db.query('wash_records', orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> getWorkerCars(String workerName) async {
    final Database db = await database;
    return db.query(
      'wash_records',
      where: 'workerName = ?',
      whereArgs: <Object?>[workerName],
      orderBy: 'date DESC',
    );
  }

  Future<int> getWorkerTodayWashCount(String workerName) async {
    final Database db = await database;
    final String today = DateTime.now().toIso8601String().substring(0, 10);

    final List<Map<String, Object?>> result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total
      FROM wash_records
      WHERE workerName = ? AND substr(date, 1, 10) = ?
      ''',
      <Object?>[workerName, today],
    );

    return ((result.first['total'] as num?) ?? 0).toInt();
  }

  Future<int> getWorkerTodayIncome(String workerName) async {
    final Database db = await database;
    final String today = DateTime.now().toIso8601String().substring(0, 10);

    final List<Map<String, Object?>> result = await db.rawQuery(
      '''
      SELECT IFNULL(SUM(price), 0) AS total
      FROM wash_records
      WHERE workerName = ? AND substr(date, 1, 10) = ?
      ''',
      <Object?>[workerName, today],
    );

    return ((result.first['total'] as num?) ?? 0).toInt();
  }

  Future<List<Map<String, dynamic>>> getWorkerWashHistory(
    String workerName,
  ) async {
    final Database db = await database;
    return db.query(
      'wash_records',
      where: 'workerName = ?',
      whereArgs: <Object?>[workerName],
      orderBy: 'date DESC',
    );
  }

  Future<int> markAsPaid(int id) async {
    final Database db = await database;
    return db.update(
      'wash_records',
      <String, dynamic>{'paymentStatus': 'paid'},
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  Future<Map<String, int>> getPaymentStats() async {
    final Database db = await database;

    final int paid =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM wash_records WHERE paymentStatus = 'paid'",
          ),
        ) ??
        0;

    final int unpaid =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM wash_records WHERE paymentStatus = 'unpaid'",
          ),
        ) ??
        0;

    return <String, int>{'paid': paid, 'unpaid': unpaid};
  }

  // =========================================================
  // PRICES
  // =========================================================

  Future<void> seedPricesIfEmpty() async {
    final Database db = await database;

    final int count =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM prices'),
        ) ??
        0;

    if (count > 0) return;

    await _seedDefaultPrices(db);
  }

  Future<List<Map<String, dynamic>>> getPrices() async {
    final Database db = await database;
    return db.query('prices', orderBy: 'id ASC');
  }

  Future<int> setPrice(String washType, int price) async {
    final Database db = await database;
    return db.insert('prices', <String, dynamic>{
      'washType': washType,
      'price': price,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // =========================================================
  // SUMMARY / INCOME
  // =========================================================

  Future<Map<String, int>> getTodaySummary() async {
    final Database db = await database;
    final String today = DateTime.now().toIso8601String().substring(0, 10);

    final List<Map<String, Object?>> incomeResult = await db.rawQuery(
      '''
      SELECT IFNULL(SUM(price), 0) AS totalIncome
      FROM wash_records
      WHERE substr(date, 1, 10) = ?
      ''',
      <Object?>[today],
    );

    final List<Map<String, Object?>> countResult = await db.rawQuery(
      '''
      SELECT COUNT(*) AS totalCars
      FROM wash_records
      WHERE substr(date, 1, 10) = ?
      ''',
      <Object?>[today],
    );

    final int totalIncome = ((incomeResult.first['totalIncome'] as num?) ?? 0)
        .toInt();
    final int totalCars = ((countResult.first['totalCars'] as num?) ?? 0)
        .toInt();

    return <String, int>{'totalIncome': totalIncome, 'totalCars': totalCars};
  }

  Future<List<Map<String, dynamic>>> getLast7DaysIncome() async {
    final Database db = await database;
    return db.rawQuery('''
      SELECT substr(date, 1, 10) AS day, IFNULL(SUM(price), 0) AS total
      FROM wash_records
      WHERE substr(date, 1, 10) >= date('now', '-6 day')
      GROUP BY day
      ORDER BY day ASC
    ''');
  }

  Future<List<Map<String, dynamic>>> getDailyIncomeForChart() async {
    final Database db = await database;
    return db.rawQuery('''
      SELECT substr(date, 1, 10) AS day, IFNULL(SUM(price), 0) AS total
      FROM wash_records
      WHERE substr(date, 1, 10) >= date('now', '-6 day')
      GROUP BY day
      ORDER BY day ASC
    ''');
  }

  Future<List<Map<String, dynamic>>> getIncomeBreakdownForChart() async {
    final Database db = await database;

    return db.rawQuery('''
      SELECT
        substr(date, 1, 10) AS day,
        IFNULL(SUM(CASE WHEN workerName = 'Customer Self Wash' THEN price ELSE 0 END), 0) AS selfIncome,
        IFNULL(SUM(CASE WHEN workerName != 'Customer Self Wash' THEN price ELSE 0 END), 0) AS workerIncome,
        IFNULL(SUM(price), 0) AS totalIncome
      FROM wash_records
      WHERE substr(date, 1, 10) >= date('now', '-6 day')
      GROUP BY day
      ORDER BY day ASC
    ''');
  }

  // =========================================================
  // WORKERS
  // =========================================================

  Future<String> generateWorkerCode() async {
    final Database db = await database;

    final int year = DateTime.now().year % 100;
    final String prefix = '${year.toString().padLeft(2, '0')}A';

    final List<Map<String, Object?>> result = await db.rawQuery(
      '''
      SELECT workerCode
      FROM workers
      WHERE workerCode LIKE ?
      ORDER BY workerCode DESC
      LIMIT 1
      ''',
      <Object?>['$prefix%'],
    );

    int nextNumber = 1;

    if (result.isNotEmpty) {
      final String lastCode = result.first['workerCode']?.toString() ?? '';
      if (lastCode.length >= 5) {
        final String numericPart = lastCode.substring(3);
        nextNumber = (int.tryParse(numericPart) ?? 0) + 1;
      }
    }

    return '$prefix${nextNumber.toString().padLeft(2, '0')}';
  }

  Future<int> addWorker({
    required String fullName,
    required String username,
    required String password,
  }) async {
    final Database db = await database;
    final String workerCode = await generateWorkerCode();

    return db.insert('workers', <String, dynamic>{
      'workerCode': workerCode,
      'fullName': fullName,
      'username': username,
      'password': password,
      'isActive': 0,
    }, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<List<Map<String, dynamic>>> getWorkers() async {
    final Database db = await database;
    return db.query('workers', orderBy: 'id DESC');
  }

  Future<int> deleteWorker(int id) async {
    final Database db = await database;
    return db.delete('workers', where: 'id = ?', whereArgs: <Object?>[id]);
  }

  Future<Map<String, dynamic>?> loginWorker({
    required String username,
    required String password,
  }) async {
    final Database db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'workers',
      where: 'LOWER(username) = ? AND password = ?',
      whereArgs: <Object?>[username.toLowerCase(), password],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return result.first;
  }

  Future<int> setWorkerActiveByUsername({
    required String username,
    required bool isActive,
  }) async {
    final Database db = await database;
    return db.update(
      'workers',
      <String, dynamic>{'isActive': isActive ? 1 : 0},
      where: 'LOWER(username) = ?',
      whereArgs: <Object?>[username.toLowerCase()],
    );
  }

  Future<int> setWorkerActiveByFullName({
    required String fullName,
    required bool isActive,
  }) async {
    final Database db = await database;
    return db.update(
      'workers',
      <String, dynamic>{'isActive': isActive ? 1 : 0},
      where: 'fullName = ?',
      whereArgs: <Object?>[fullName],
    );
  }

  Future<List<Map<String, dynamic>>> getActiveWorkers() async {
    final Database db = await database;
    return db.query(
      'workers',
      where: 'isActive = ?',
      whereArgs: <Object?>[1],
      orderBy: 'fullName ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getWorkerOnlineStatus() async {
    final Database db = await database;
    return db.query('workers', orderBy: 'isActive DESC, fullName ASC');
  }

  Future<List<Map<String, dynamic>>> getWorkerWashStats() async {
    final Database db = await database;
    return db.rawQuery('''
      SELECT workerName, COUNT(*) AS totalWashes, IFNULL(SUM(price), 0) AS totalIncome
      FROM wash_records
      WHERE workerName != 'Customer Self Wash'
      GROUP BY workerName
      ORDER BY totalWashes DESC, totalIncome DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getWorkerSalaryReport({
    int percent = 30,
  }) async {
    final Database db = await database;

    final List<Map<String, dynamic>> rows = await db.rawQuery('''
      SELECT workerName, COUNT(*) AS totalWashes, IFNULL(SUM(price), 0) AS totalIncome
      FROM wash_records
      WHERE workerName != 'Customer Self Wash'
      GROUP BY workerName
      ORDER BY totalIncome DESC
    ''');

    return rows.map((Map<String, dynamic> row) {
      final int totalIncome = ((row['totalIncome'] as num?) ?? 0).toInt();
      final int salary = ((totalIncome * percent) / 100).round();

      return <String, dynamic>{
        'workerName': row['workerName'],
        'totalWashes': row['totalWashes'],
        'totalIncome': totalIncome,
        'salaryPercent': percent,
        'salary': salary,
      };
    }).toList();
  }

  Future<List<String>> getSlots({
    required String date,
    required int duration,
  }) async {
    final List<String> slots = <String>[];

    for (int i = 8; i < 22; i++) {
      final String time = '${i.toString().padLeft(2, '0')}:00';

      final List<Map<String, dynamic>> freeWorkers = await getAvailableWorkers(
        date: date,
        time: time,
        duration: duration,
      );

      if (freeWorkers.isNotEmpty) {
        slots.add(time);
      }
    }

    return slots;
  }

  Future<List<Map<String, dynamic>>> getWorkerBookingsForDay({
    required int workerId,
    required String bookingDate,
  }) async {
    final Database db = await database;

    return db.query(
      'bookings',
      where: 'workerId = ? AND bookingDate = ? AND status != ?',
      whereArgs: <Object?>[workerId, bookingDate, 'cancelled'],
      orderBy: 'bookingTime ASC',
    );
  }

  Future<Map<String, dynamic>?> getWorkerCurrentBusyInfo(int workerId) async {
    final Database db = await database;
    final String today = DateTime.now().toIso8601String().substring(0, 10);
    final int nowMin = DateTime.now().hour * 60 + DateTime.now().minute;

    final List<Map<String, dynamic>> bookings = await db.query(
      'bookings',
      where: 'workerId = ? AND bookingDate = ? AND status != ?',
      whereArgs: <Object?>[workerId, today, 'cancelled'],
      orderBy: 'bookingTime ASC',
    );

    for (final booking in bookings) {
      final int start = timeToMinutes(
        booking['bookingTime']?.toString() ?? '00:00',
      );
      final int end = timeToMinutes(booking['endTime']?.toString() ?? '00:00');

      if (nowMin >= start && nowMin < end) {
        return booking;
      }
    }

    return null;
  }

  // =========================================================
  // CUSTOMERS
  // =========================================================

  Future<int> addCustomer({
    required String fullName,
    required String phone,
    required String password,
    required String carPlate,
  }) async {
    final Database db = await database;
    return db.insert('customers', <String, dynamic>{
      'fullName': fullName,
      'phone': phone,
      'password': password,
      'carPlate': carPlate.trim().toUpperCase(),
    }, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<Map<String, dynamic>?> loginCustomer({
    required String phone,
    required String password,
  }) async {
    final Database db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'customers',
      where: 'phone = ? AND password = ?',
      whereArgs: <Object?>[phone, password],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return result.first;
  }

  Future<Map<String, dynamic>?> getCustomerByPhone(String phone) async {
    final Database db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'customers',
      where: 'phone = ?',
      whereArgs: <Object?>[phone],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return result.first;
  }

  Future<int> updateCustomerProfile({
    required int id,
    required String fullName,
    required String phone,
    required String password,
    required String carPlate,
  }) async {
    final Database db = await database;
    return db.update(
      'customers',
      <String, dynamic>{
        'fullName': fullName,
        'phone': phone,
        'password': password,
        'carPlate': carPlate.trim().toUpperCase(),
      },
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  Future<List<Map<String, dynamic>>> getCustomers() async {
    final Database db = await database;
    return db.query('customers', orderBy: 'id DESC');
  }

  Future<int> deleteCustomer(int id) async {
    final Database db = await database;
    return db.delete('customers', where: 'id = ?', whereArgs: <Object?>[id]);
  }

  // =========================================================
  // CUSTOMER HISTORY / STATS
  // =========================================================

  Future<List<Map<String, dynamic>>> getCustomerWashHistoryByPhone(
    String phone,
  ) async {
    final Database db = await database;

    return db.query(
      'wash_records',
      where: 'customerPhone = ?',
      whereArgs: <Object?>[phone],
      orderBy: 'date DESC, id DESC',
    );
  }

  Future<Map<String, dynamic>> getCustomerWashStatsByPhone(String phone) async {
    final List<Map<String, dynamic>> history =
        await getCustomerWashHistoryByPhone(phone);

    int totalWashCount = history.length;
    int totalSpent = 0;
    int paidCount = 0;
    int unpaidCount = 0;

    for (final Map<String, dynamic> item in history) {
      final int price = ((item['price'] as num?) ?? 0).toInt();
      final String paymentStatus =
          item['paymentStatus']?.toString() ?? 'unpaid';

      totalSpent += price;

      if (paymentStatus == 'paid') {
        paidCount++;
      } else {
        unpaidCount++;
      }
    }

    return <String, dynamic>{
      'totalWashCount': totalWashCount,
      'totalSpent': totalSpent,
      'paidCount': paidCount,
      'unpaidCount': unpaidCount,
    };
  }

  Future<List<Map<String, dynamic>>> getCustomerLast7DaysStatsByPhone(
    String phone,
  ) async {
    final Database db = await database;

    final DateTime now = DateTime.now();
    final DateTime start = now.subtract(const Duration(days: 6));
    final String startDate =
        '${start.year.toString().padLeft(4, '0')}-'
        '${start.month.toString().padLeft(2, '0')}-'
        '${start.day.toString().padLeft(2, '0')}';

    return db.rawQuery(
      '''
      SELECT
        substr(date, 1, 10) AS day,
        COUNT(*) AS totalWash,
        IFNULL(SUM(price), 0) AS totalSpent
      FROM wash_records
      WHERE customerPhone = ?
        AND substr(date, 1, 10) >= ?
      GROUP BY substr(date, 1, 10)
      ORDER BY day ASC
      ''',
      <Object?>[phone, startDate],
    );
  }

  Future<Map<String, dynamic>?> getLastWashByPhone(String phone) async {
    final List<Map<String, dynamic>> history =
        await getCustomerWashHistoryByPhone(phone);

    if (history.isEmpty) return null;
    return history.first;
  }

  Future<void> backfillCustomerPhoneIntoWashRecords() async {
    final Database db = await database;

    final List<Map<String, dynamic>> customers = await db.query('customers');
    final List<Map<String, dynamic>> records = await db.query('wash_records');

    for (final Map<String, dynamic> record in records) {
      final String existingPhone = record['customerPhone']?.toString() ?? '';
      if (existingPhone.isNotEmpty) continue;

      final String recordPlate = normalizePlate(
        record['carNumber']?.toString() ?? '',
      );

      for (final Map<String, dynamic> customer in customers) {
        final String customerPhone = customer['phone']?.toString() ?? '';
        final String customerPlate = normalizePlate(
          customer['carPlate']?.toString() ?? '',
        );

        if (customerPhone.isEmpty || customerPlate.isEmpty) continue;

        if (recordPlate == customerPlate ||
            recordPlate.contains(customerPlate) ||
            customerPlate.contains(recordPlate)) {
          await db.update(
            'wash_records',
            <String, dynamic>{'customerPhone': customerPhone},
            where: 'id = ?',
            whereArgs: <Object?>[record['id']],
          );
          break;
        }
      }
    }
  }

  // =========================================================
  // EXTRA ANALYTICS
  // =========================================================

  Future<int> getPendingRequestCount() async {
    final Database db = await database;

    final List<Map<String, Object?>> result = await db.rawQuery('''
      SELECT COUNT(*) AS total
      FROM wash_requests
      WHERE status = 'pending'
    ''');

    return ((result.first['total'] as num?) ?? 0).toInt();
  }

  Future<Map<String, dynamic>> getTopWorkerToday() async {
    final Database db = await database;
    final String today = DateTime.now().toIso8601String().substring(0, 10);

    final List<Map<String, Object?>> result = await db.rawQuery(
      '''
      SELECT workerName, COUNT(*) AS totalWashes, IFNULL(SUM(price), 0) AS totalIncome
      FROM wash_records
      WHERE workerName != 'Customer Self Wash'
        AND substr(date, 1, 10) = ?
      GROUP BY workerName
      ORDER BY totalIncome DESC, totalWashes DESC
      LIMIT 1
      ''',
      <Object?>[today],
    );

    if (result.isEmpty) {
      return <String, dynamic>{
        'workerName': '-',
        'totalWashes': 0,
        'totalIncome': 0,
      };
    }

    return <String, dynamic>{
      'workerName': result.first['workerName']?.toString() ?? '-',
      'totalWashes': ((result.first['totalWashes'] as num?) ?? 0).toInt(),
      'totalIncome': ((result.first['totalIncome'] as num?) ?? 0).toInt(),
    };
  }

  Future<Map<String, dynamic>> getSelfVsWorkerIncomeSummary() async {
    final Database db = await database;

    final List<Map<String, Object?>> result = await db.rawQuery('''
      SELECT
        IFNULL(SUM(CASE WHEN workerName = 'Customer Self Wash' THEN price ELSE 0 END), 0) AS selfIncome,
        IFNULL(SUM(CASE WHEN workerName != 'Customer Self Wash' THEN price ELSE 0 END), 0) AS workerIncome
      FROM wash_records
    ''');

    final int selfIncome = ((result.first['selfIncome'] as num?) ?? 0).toInt();
    final int workerIncome = ((result.first['workerIncome'] as num?) ?? 0)
        .toInt();
    final int total = selfIncome + workerIncome;

    final double selfPercent = total == 0 ? 0 : (selfIncome / total) * 100;
    final double workerPercent = total == 0 ? 0 : (workerIncome / total) * 100;

    return <String, dynamic>{
      'selfIncome': selfIncome,
      'workerIncome': workerIncome,
      'selfPercent': selfPercent,
      'workerPercent': workerPercent,
    };
  }

  // =========================================================
  // WASH REQUESTS
  // =========================================================

  Future<int> createWashRequest({
    required String customerName,
    required String customerPhone,
    required String carPlate,
    required String vehicleType,
    required String note,
  }) async {
    final Database db = await database;
    return db.insert('wash_requests', <String, dynamic>{
      'customerName': customerName,
      'customerPhone': customerPhone,
      'carPlate': carPlate,
      'vehicleType': vehicleType,
      'note': note,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPendingWashRequests() async {
    final Database db = await database;
    return db.query(
      'wash_requests',
      where: 'status = ?',
      whereArgs: <Object?>['pending'],
      orderBy: 'id ASC',
    );
  }

  Future<int> updateWashRequestStatus({
    required int id,
    required String status,
  }) async {
    final Database db = await database;
    return db.update(
      'wash_requests',
      <String, dynamic>{'status': status},
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  // =========================================================
  // BOOKINGS
  // =========================================================

  Future<bool> isTimeSlotAvailable({
    required String bookingDate,
    required String bookingTime,
    required int workerId,
    required int duration,
  }) async {
    final Database db = await database;

    final int start = timeToMinutes(bookingTime);
    final int end = start + duration;

    final List<Map<String, dynamic>> bookings = await db.query(
      'bookings',
      where: 'bookingDate = ? AND workerId = ? AND status != ?',
      whereArgs: <Object?>[bookingDate, workerId, 'cancelled'],
    );

    for (final Map<String, dynamic> booking in bookings) {
      final int bookedStart = timeToMinutes(
        booking['bookingTime']?.toString() ?? '00:00',
      );
      final int bookedEnd = timeToMinutes(
        booking['endTime']?.toString() ?? '00:00',
      );

      if (start < bookedEnd && end > bookedStart) {
        return false;
      }
    }

    return true;
  }

  Future<int> createBooking({
    required String customerName,
    required String phone,
    required String carPlate,
    required String bookingDate,
    required String bookingTime,
    required String serviceType,
    required int workerId,
    required String workerName,
  }) async {
    final Database db = await database;

    final int duration = getDuration(serviceType);
    final int start = timeToMinutes(bookingTime);
    final String endTime = minutesToTime(start + duration);

    return db.insert('bookings', <String, dynamic>{
      'customerName': customerName,
      'phone': phone,
      'carPlate': carPlate,
      'bookingDate': bookingDate,
      'bookingTime': bookingTime,
      'endTime': endTime,
      'serviceType': serviceType,
      'durationMinutes': duration,
      'workerId': workerId,
      'workerName': workerName,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getBookingsByDate(
    String bookingDate,
  ) async {
    final Database db = await database;
    return db.query(
      'bookings',
      where: 'bookingDate = ?',
      whereArgs: <Object?>[bookingDate],
      orderBy: 'bookingTime ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllBookings() async {
    final Database db = await database;
    return db.query('bookings', orderBy: 'bookingDate DESC, bookingTime ASC');
  }

  Future<int> updateBookingStatus({
    required int id,
    required String status,
  }) async {
    final Database db = await database;
    return db.update(
      'bookings',
      <String, dynamic>{'status': status},
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  Future<List<Map<String, dynamic>>> getBookingsByPhone(String phone) async {
    final Database db = await database;
    return db.query(
      'bookings',
      where: 'phone = ?',
      whereArgs: <Object?>[phone],
      orderBy: 'bookingDate DESC, bookingTime DESC',
    );
  }

  Future<String> getWorkerCodeByName(String workerName) async {
    final Database db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'workers',
      columns: <String>['workerCode'],
      where: 'fullName = ?',
      whereArgs: <Object?>[workerName],
      limit: 1,
    );

    if (result.isEmpty) return 'N/A';
    return result.first['workerCode']?.toString() ?? 'N/A';
  }

  Future<Map<String, dynamic>?> getBookingById(int id) async {
    final Database db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'bookings',
      where: 'id = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return result.first;
  }
}
