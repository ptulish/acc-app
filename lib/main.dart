import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Добавили импорт для работы с системными настройками
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/services/auth_service.dart';

import 'screens/cards_screen.dart';
import 'screens/auth_screen.dart';
import 'services/local_auth_service.dart';

void main() async {
  // Эта строка обязательна перед вызовом платформенных каналов (SystemChrome)
  WidgetsFlutterBinding.ensureInitialized();

  // --- ЖЕСТКО ЗАДАЕМ ГОРИЗОНТАЛЬНУЮ ОРИЕНТАЦИЮ ---
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  // ----------------------------------------------

  runApp(const ProviderScope(
      child: MyApp()
    )
  );
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
      home: StreamBuilder<User?>(
        stream: AuthService().user,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            return const HomeScreen(); // Твой будущий главный экран
          }
          return const AuthScreen();
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = LocalAuthService();

    return StreamBuilder<String?>(
      stream: authService.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          // Убрали userEmail, так как сейчас карточки грузятся у всех одинаково из JSON
          return CardsScreen();
        }
        return const AuthScreen();
      },
    );
  }
}