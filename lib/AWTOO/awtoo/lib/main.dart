import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'screens/login/splash_router_page.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.instance.database;
  await DatabaseHelper.instance.backfillCustomerPhoneIntoWashRecords();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Шинэ авто угаалга',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashRouterPage(),
    );
  }
}
