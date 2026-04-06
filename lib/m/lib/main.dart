import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // kIsWeb-д зориулж
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/manual_wash/screens/wash_list_screen.dart'; // эндээс эхэл

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey:
            "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", // ← Firebase console-оос ав
        appId: "1:123456789012:web:abcdef1234567890", // ← жишээ
        messagingSenderId: "123456789012",
        projectId: "your-project-id", // ← заавал
        storageBucket: "your-project-id.appspot.com", // optional
        authDomain: "your-project-id.firebaseapp.com", // optional
      ),
    );
  } else {
    await Firebase.initializeApp(); // mobile-д options шаардлагагүй
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Авто Угаалга Удирдлага',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,   ← түр comment хий (байхгүй бол)
      themeMode: ThemeMode.light, // darkTheme байхгүй бол light ашигла
      home: const WashListScreen(), // шууд жагсаалтаас эхэл
    );
  }
}
