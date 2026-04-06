// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$databaseHash() => r'64e68ef891caef3da1e4e2621a495f73a5ce2a50';

/// See also [database].
@ProviderFor(database)
final databaseProvider = AutoDisposeProvider<AppDatabase>.internal(
  database,
  name: r'databaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$databaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DatabaseRef = AutoDisposeProviderRef<AppDatabase>;
String _$todayIncomeHash() => r'c29c36e25a02a0befbf573798820036599219b34';

/// See also [todayIncome].
@ProviderFor(todayIncome)
final todayIncomeProvider = AutoDisposeFutureProvider<int>.internal(
  todayIncome,
  name: r'todayIncomeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$todayIncomeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayIncomeRef = AutoDisposeFutureProviderRef<int>;
String _$todayRecordsHash() => r'b50a02c206e5f74ecec80afce56d125295c1978f';

/// See also [todayRecords].
@ProviderFor(todayRecords)
final todayRecordsProvider =
    AutoDisposeFutureProvider<List<WashRecord>>.internal(
  todayRecords,
  name: r'todayRecordsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$todayRecordsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayRecordsRef = AutoDisposeFutureProviderRef<List<WashRecord>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
