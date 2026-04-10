import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Добавили импорт для работы с системными настройками

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
      home: const AuthGate(),
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
          return CardsScreen(userEmail: snapshot.data!);
        }
        return const AuthScreen();
      },
    );
  }
}