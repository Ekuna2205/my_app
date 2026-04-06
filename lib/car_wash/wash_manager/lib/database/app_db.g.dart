// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// ignore_for_file: type=lint
class $ServiceTypesTable extends ServiceTypes
    with TableInfo<$ServiceTypesTable, ServiceType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vehicleTypeMeta =
      const VerificationMeta('vehicleType');
  @override
  late final GeneratedColumn<String> vehicleType = GeneratedColumn<String>(
      'vehicle_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<int> price = GeneratedColumn<int>(
      'price', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, vehicleType, price];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_types';
  @override
  VerificationContext validateIntegrity(Insertable<ServiceType> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('vehicle_type')) {
      context.handle(
          _vehicleTypeMeta,
          vehicleType.isAcceptableOrUnknown(
              data['vehicle_type']!, _vehicleTypeMeta));
    } else if (isInserting) {
      context.missing(_vehicleTypeMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServiceType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServiceType(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      vehicleType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vehicle_type'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}price'])!,
    );
  }

  @override
  $ServiceTypesTable createAlias(String alias) {
    return $ServiceTypesTable(attachedDatabase, alias);
  }
}

class ServiceType extends DataClass implements Insertable<ServiceType> {
  final int id;
  final String name;
  final String vehicleType;
  final int price;
  const ServiceType(
      {required this.id,
      required this.name,
      required this.vehicleType,
      required this.price});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['vehicle_type'] = Variable<String>(vehicleType);
    map['price'] = Variable<int>(price);
    return map;
  }

  ServiceTypesCompanion toCompanion(bool nullToAbsent) {
    return ServiceTypesCompanion(
      id: Value(id),
      name: Value(name),
      vehicleType: Value(vehicleType),
      price: Value(price),
    );
  }

  factory ServiceType.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServiceType(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      vehicleType: serializer.fromJson<String>(json['vehicleType']),
      price: serializer.fromJson<int>(json['price']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'vehicleType': serializer.toJson<String>(vehicleType),
      'price': serializer.toJson<int>(price),
    };
  }

  ServiceType copyWith(
          {int? id, String? name, String? vehicleType, int? price}) =>
      ServiceType(
        id: id ?? this.id,
        name: name ?? this.name,
        vehicleType: vehicleType ?? this.vehicleType,
        price: price ?? this.price,
      );
  ServiceType copyWithCompanion(ServiceTypesCompanion data) {
    return ServiceType(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      vehicleType:
          data.vehicleType.present ? data.vehicleType.value : this.vehicleType,
      price: data.price.present ? data.price.value : this.price,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServiceType(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('vehicleType: $vehicleType, ')
          ..write('price: $price')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, vehicleType, price);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceType &&
          other.id == this.id &&
          other.name == this.name &&
          other.vehicleType == this.vehicleType &&
          other.price == this.price);
}

class ServiceTypesCompanion extends UpdateCompanion<ServiceType> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> vehicleType;
  final Value<int> price;
  const ServiceTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.vehicleType = const Value.absent(),
    this.price = const Value.absent(),
  });
  ServiceTypesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String vehicleType,
    required int price,
  })  : name = Value(name),
        vehicleType = Value(vehicleType),
        price = Value(price);
  static Insertable<ServiceType> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? vehicleType,
    Expression<int>? price,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (vehicleType != null) 'vehicle_type': vehicleType,
      if (price != null) 'price': price,
    });
  }

  ServiceTypesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? vehicleType,
      Value<int>? price}) {
    return ServiceTypesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      vehicleType: vehicleType ?? this.vehicleType,
      price: price ?? this.price,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (vehicleType.present) {
      map['vehicle_type'] = Variable<String>(vehicleType.value);
    }
    if (price.present) {
      map['price'] = Variable<int>(price.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServiceTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('vehicleType: $vehicleType, ')
          ..write('price: $price')
          ..write(')'))
        .toString();
  }
}

class $WashRecordsTable extends WashRecords
    with TableInfo<$WashRecordsTable, WashRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WashRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _plateMeta = const VerificationMeta('plate');
  @override
  late final GeneratedColumn<String> plate = GeneratedColumn<String>(
      'plate', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serviceIdMeta =
      const VerificationMeta('serviceId');
  @override
  late final GeneratedColumn<int> serviceId = GeneratedColumn<int>(
      'service_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES service_types (id)'));
  static const VerificationMeta _workerIdMeta =
      const VerificationMeta('workerId');
  @override
  late final GeneratedColumn<int> workerId = GeneratedColumn<int>(
      'worker_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
      'time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, plate, serviceId, workerId, time, amount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wash_records';
  @override
  VerificationContext validateIntegrity(Insertable<WashRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plate')) {
      context.handle(
          _plateMeta, plate.isAcceptableOrUnknown(data['plate']!, _plateMeta));
    } else if (isInserting) {
      context.missing(_plateMeta);
    }
    if (data.containsKey('service_id')) {
      context.handle(_serviceIdMeta,
          serviceId.isAcceptableOrUnknown(data['service_id']!, _serviceIdMeta));
    } else if (isInserting) {
      context.missing(_serviceIdMeta);
    }
    if (data.containsKey('worker_id')) {
      context.handle(_workerIdMeta,
          workerId.isAcceptableOrUnknown(data['worker_id']!, _workerIdMeta));
    } else if (isInserting) {
      context.missing(_workerIdMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WashRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WashRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      plate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plate'])!,
      serviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}service_id'])!,
      workerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}worker_id'])!,
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}time'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
    );
  }

  @override
  $WashRecordsTable createAlias(String alias) {
    return $WashRecordsTable(attachedDatabase, alias);
  }
}

class WashRecord extends DataClass implements Insertable<WashRecord> {
  final int id;
  final String plate;
  final int serviceId;
  final int workerId;
  final DateTime time;
  final int amount;
  const WashRecord(
      {required this.id,
      required this.plate,
      required this.serviceId,
      required this.workerId,
      required this.time,
      required this.amount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plate'] = Variable<String>(plate);
    map['service_id'] = Variable<int>(serviceId);
    map['worker_id'] = Variable<int>(workerId);
    map['time'] = Variable<DateTime>(time);
    map['amount'] = Variable<int>(amount);
    return map;
  }

  WashRecordsCompanion toCompanion(bool nullToAbsent) {
    return WashRecordsCompanion(
      id: Value(id),
      plate: Value(plate),
      serviceId: Value(serviceId),
      workerId: Value(workerId),
      time: Value(time),
      amount: Value(amount),
    );
  }

  factory WashRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WashRecord(
      id: serializer.fromJson<int>(json['id']),
      plate: serializer.fromJson<String>(json['plate']),
      serviceId: serializer.fromJson<int>(json['serviceId']),
      workerId: serializer.fromJson<int>(json['workerId']),
      time: serializer.fromJson<DateTime>(json['time']),
      amount: serializer.fromJson<int>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'plate': serializer.toJson<String>(plate),
      'serviceId': serializer.toJson<int>(serviceId),
      'workerId': serializer.toJson<int>(workerId),
      'time': serializer.toJson<DateTime>(time),
      'amount': serializer.toJson<int>(amount),
    };
  }

  WashRecord copyWith(
          {int? id,
          String? plate,
          int? serviceId,
          int? workerId,
          DateTime? time,
          int? amount}) =>
      WashRecord(
        id: id ?? this.id,
        plate: plate ?? this.plate,
        serviceId: serviceId ?? this.serviceId,
        workerId: workerId ?? this.workerId,
        time: time ?? this.time,
        amount: amount ?? this.amount,
      );
  WashRecord copyWithCompanion(WashRecordsCompanion data) {
    return WashRecord(
      id: data.id.present ? data.id.value : this.id,
      plate: data.plate.present ? data.plate.value : this.plate,
      serviceId: data.serviceId.present ? data.serviceId.value : this.serviceId,
      workerId: data.workerId.present ? data.workerId.value : this.workerId,
      time: data.time.present ? data.time.value : this.time,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WashRecord(')
          ..write('id: $id, ')
          ..write('plate: $plate, ')
          ..write('serviceId: $serviceId, ')
          ..write('workerId: $workerId, ')
          ..write('time: $time, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, plate, serviceId, workerId, time, amount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WashRecord &&
          other.id == this.id &&
          other.plate == this.plate &&
          other.serviceId == this.serviceId &&
          other.workerId == this.workerId &&
          other.time == this.time &&
          other.amount == this.amount);
}

class WashRecordsCompanion extends UpdateCompanion<WashRecord> {
  final Value<int> id;
  final Value<String> plate;
  final Value<int> serviceId;
  final Value<int> workerId;
  final Value<DateTime> time;
  final Value<int> amount;
  const WashRecordsCompanion({
    this.id = const Value.absent(),
    this.plate = const Value.absent(),
    this.serviceId = const Value.absent(),
    this.workerId = const Value.absent(),
    this.time = const Value.absent(),
    this.amount = const Value.absent(),
  });
  WashRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String plate,
    required int serviceId,
    required int workerId,
    required DateTime time,
    required int amount,
  })  : plate = Value(plate),
        serviceId = Value(serviceId),
        workerId = Value(workerId),
        time = Value(time),
        amount = Value(amount);
  static Insertable<WashRecord> custom({
    Expression<int>? id,
    Expression<String>? plate,
    Expression<int>? serviceId,
    Expression<int>? workerId,
    Expression<DateTime>? time,
    Expression<int>? amount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plate != null) 'plate': plate,
      if (serviceId != null) 'service_id': serviceId,
      if (workerId != null) 'worker_id': workerId,
      if (time != null) 'time': time,
      if (amount != null) 'amount': amount,
    });
  }

  WashRecordsCompanion copyWith(
      {Value<int>? id,
      Value<String>? plate,
      Value<int>? serviceId,
      Value<int>? workerId,
      Value<DateTime>? time,
      Value<int>? amount}) {
    return WashRecordsCompanion(
      id: id ?? this.id,
      plate: plate ?? this.plate,
      serviceId: serviceId ?? this.serviceId,
      workerId: workerId ?? this.workerId,
      time: time ?? this.time,
      amount: amount ?? this.amount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (plate.present) {
      map['plate'] = Variable<String>(plate.value);
    }
    if (serviceId.present) {
      map['service_id'] = Variable<int>(serviceId.value);
    }
    if (workerId.present) {
      map['worker_id'] = Variable<int>(workerId.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WashRecordsCompanion(')
          ..write('id: $id, ')
          ..write('plate: $plate, ')
          ..write('serviceId: $serviceId, ')
          ..write('workerId: $workerId, ')
          ..write('time: $time, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ServiceTypesTable serviceTypes = $ServiceTypesTable(this);
  late final $WashRecordsTable washRecords = $WashRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [serviceTypes, washRecords];
}

typedef $$ServiceTypesTableCreateCompanionBuilder = ServiceTypesCompanion
    Function({
  Value<int> id,
  required String name,
  required String vehicleType,
  required int price,
});
typedef $$ServiceTypesTableUpdateCompanionBuilder = ServiceTypesCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> vehicleType,
  Value<int> price,
});

final class $$ServiceTypesTableReferences
    extends BaseReferences<_$AppDatabase, $ServiceTypesTable, ServiceType> {
  $$ServiceTypesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WashRecordsTable, List<WashRecord>>
      _washRecordsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.washRecords,
              aliasName: $_aliasNameGenerator(
                  db.serviceTypes.id, db.washRecords.serviceId));

  $$WashRecordsTableProcessedTableManager get washRecordsRefs {
    final manager = $$WashRecordsTableTableManager($_db, $_db.washRecords)
        .filter((f) => f.serviceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_washRecordsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ServiceTypesTableFilterComposer
    extends Composer<_$AppDatabase, $ServiceTypesTable> {
  $$ServiceTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vehicleType => $composableBuilder(
      column: $table.vehicleType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  Expression<bool> washRecordsRefs(
      Expression<bool> Function($$WashRecordsTableFilterComposer f) f) {
    final $$WashRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.washRecords,
        getReferencedColumn: (t) => t.serviceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WashRecordsTableFilterComposer(
              $db: $db,
              $table: $db.washRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ServiceTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $ServiceTypesTable> {
  $$ServiceTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vehicleType => $composableBuilder(
      column: $table.vehicleType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));
}

class $$ServiceTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServiceTypesTable> {
  $$ServiceTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get vehicleType => $composableBuilder(
      column: $table.vehicleType, builder: (column) => column);

  GeneratedColumn<int> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  Expression<T> washRecordsRefs<T extends Object>(
      Expression<T> Function($$WashRecordsTableAnnotationComposer a) f) {
    final $$WashRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.washRecords,
        getReferencedColumn: (t) => t.serviceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WashRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.washRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ServiceTypesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ServiceTypesTable,
    ServiceType,
    $$ServiceTypesTableFilterComposer,
    $$ServiceTypesTableOrderingComposer,
    $$ServiceTypesTableAnnotationComposer,
    $$ServiceTypesTableCreateCompanionBuilder,
    $$ServiceTypesTableUpdateCompanionBuilder,
    (ServiceType, $$ServiceTypesTableReferences),
    ServiceType,
    PrefetchHooks Function({bool washRecordsRefs})> {
  $$ServiceTypesTableTableManager(_$AppDatabase db, $ServiceTypesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServiceTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServiceTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServiceTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> vehicleType = const Value.absent(),
            Value<int> price = const Value.absent(),
          }) =>
              ServiceTypesCompanion(
            id: id,
            name: name,
            vehicleType: vehicleType,
            price: price,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String vehicleType,
            required int price,
          }) =>
              ServiceTypesCompanion.insert(
            id: id,
            name: name,
            vehicleType: vehicleType,
            price: price,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ServiceTypesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({washRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (washRecordsRefs) db.washRecords],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (washRecordsRefs)
                    await $_getPrefetchedData<ServiceType, $ServiceTypesTable,
                            WashRecord>(
                        currentTable: table,
                        referencedTable: $$ServiceTypesTableReferences
                            ._washRecordsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ServiceTypesTableReferences(db, table, p0)
                                .washRecordsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.serviceId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ServiceTypesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ServiceTypesTable,
    ServiceType,
    $$ServiceTypesTableFilterComposer,
    $$ServiceTypesTableOrderingComposer,
    $$ServiceTypesTableAnnotationComposer,
    $$ServiceTypesTableCreateCompanionBuilder,
    $$ServiceTypesTableUpdateCompanionBuilder,
    (ServiceType, $$ServiceTypesTableReferences),
    ServiceType,
    PrefetchHooks Function({bool washRecordsRefs})>;
typedef $$WashRecordsTableCreateCompanionBuilder = WashRecordsCompanion
    Function({
  Value<int> id,
  required String plate,
  required int serviceId,
  required int workerId,
  required DateTime time,
  required int amount,
});
typedef $$WashRecordsTableUpdateCompanionBuilder = WashRecordsCompanion
    Function({
  Value<int> id,
  Value<String> plate,
  Value<int> serviceId,
  Value<int> workerId,
  Value<DateTime> time,
  Value<int> amount,
});

final class $$WashRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $WashRecordsTable, WashRecord> {
  $$WashRecordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ServiceTypesTable _serviceIdTable(_$AppDatabase db) =>
      db.serviceTypes.createAlias(
          $_aliasNameGenerator(db.washRecords.serviceId, db.serviceTypes.id));

  $$ServiceTypesTableProcessedTableManager get serviceId {
    final $_column = $_itemColumn<int>('service_id')!;

    final manager = $$ServiceTypesTableTableManager($_db, $_db.serviceTypes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_serviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$WashRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $WashRecordsTable> {
  $$WashRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plate => $composableBuilder(
      column: $table.plate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get workerId => $composableBuilder(
      column: $table.workerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  $$ServiceTypesTableFilterComposer get serviceId {
    final $$ServiceTypesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.serviceId,
        referencedTable: $db.serviceTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ServiceTypesTableFilterComposer(
              $db: $db,
              $table: $db.serviceTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WashRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WashRecordsTable> {
  $$WashRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plate => $composableBuilder(
      column: $table.plate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get workerId => $composableBuilder(
      column: $table.workerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  $$ServiceTypesTableOrderingComposer get serviceId {
    final $$ServiceTypesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.serviceId,
        referencedTable: $db.serviceTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ServiceTypesTableOrderingComposer(
              $db: $db,
              $table: $db.serviceTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WashRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WashRecordsTable> {
  $$WashRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get plate =>
      $composableBuilder(column: $table.plate, builder: (column) => column);

  GeneratedColumn<int> get workerId =>
      $composableBuilder(column: $table.workerId, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  $$ServiceTypesTableAnnotationComposer get serviceId {
    final $$ServiceTypesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.serviceId,
        referencedTable: $db.serviceTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ServiceTypesTableAnnotationComposer(
              $db: $db,
              $table: $db.serviceTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WashRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WashRecordsTable,
    WashRecord,
    $$WashRecordsTableFilterComposer,
    $$WashRecordsTableOrderingComposer,
    $$WashRecordsTableAnnotationComposer,
    $$WashRecordsTableCreateCompanionBuilder,
    $$WashRecordsTableUpdateCompanionBuilder,
    (WashRecord, $$WashRecordsTableReferences),
    WashRecord,
    PrefetchHooks Function({bool serviceId})> {
  $$WashRecordsTableTableManager(_$AppDatabase db, $WashRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WashRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WashRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WashRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> plate = const Value.absent(),
            Value<int> serviceId = const Value.absent(),
            Value<int> workerId = const Value.absent(),
            Value<DateTime> time = const Value.absent(),
            Value<int> amount = const Value.absent(),
          }) =>
              WashRecordsCompanion(
            id: id,
            plate: plate,
            serviceId: serviceId,
            workerId: workerId,
            time: time,
            amount: amount,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String plate,
            required int serviceId,
            required int workerId,
            required DateTime time,
            required int amount,
          }) =>
              WashRecordsCompanion.insert(
            id: id,
            plate: plate,
            serviceId: serviceId,
            workerId: workerId,
            time: time,
            amount: amount,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$WashRecordsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({serviceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (serviceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.serviceId,
                    referencedTable:
                        $$WashRecordsTableReferences._serviceIdTable(db),
                    referencedColumn:
                        $$WashRecordsTableReferences._serviceIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$WashRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WashRecordsTable,
    WashRecord,
    $$WashRecordsTableFilterComposer,
    $$WashRecordsTableOrderingComposer,
    $$WashRecordsTableAnnotationComposer,
    $$WashRecordsTableCreateCompanionBuilder,
    $$WashRecordsTableUpdateCompanionBuilder,
    (WashRecord, $$WashRecordsTableReferences),
    WashRecord,
    PrefetchHooks Function({bool serviceId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ServiceTypesTableTableManager get serviceTypes =>
      $$ServiceTypesTableTableManager(_db, _db.serviceTypes);
  $$WashRecordsTableTableManager get washRecords =>
      $$WashRecordsTableTableManager(_db, _db.washRecords);
}
