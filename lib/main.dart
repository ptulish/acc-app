import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart'; // Этот файл появится после flutterfire configure
import 'screens/cards_screen.dart'; // Перенеси свой экран с карточками в этот файл
import 'screens/auth_screen.dart';  // Это наш новый экран логина


void main() async {
  // Обязательная строчка перед запуском Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Подключаемся к Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AAC Cards',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Вместо жесткой ссылки на экран карточек, ставим "вратаря"
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ИСПРАВЛЕНО: тут должен быть snapshot
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ИСПРАВЛЕНО: и тут тоже snapshot
        if (snapshot.hasData) {
          return const CardsScreen();
        }

        return const AuthScreen();
      },
    );
  }
}