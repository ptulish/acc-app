import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем данные текущего пользователя, чтобы поприветствовать его
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AAC Cards'),
        actions: [
          // Кнопка выхода для тестирования логики AuthGate
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            Text(
              'Вы успешно вошли!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text('Email: ${user?.email ?? "Неизвестно"}'),
            const SizedBox(height: 30),
            const Text(
              'Здесь будет сетка с твоими карточками AAC.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}