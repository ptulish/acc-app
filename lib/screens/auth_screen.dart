import 'package:flutter/material.dart';
import 'package:firebase_auth/package:firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Контроллеры для считывания текста из полей
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true; // Переключатель: Вход или Регистрация
  bool _isLoading = false; // Крутилка загрузки

  // Главная функция авторизации
  Future<void> _submitAuth() async {
    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // Попытка входа
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // Попытка регистрации
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      // Если всё успешно, StreamBuilder в main.dart сам перекинет нас на главный экран!
    } on FirebaseAuthException catch (e) {
      // Если ошибка (неверный пароль, мыло занято) - показываем всплывашку
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Произошла ошибка авторизации')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Логотип или заголовок
              Icon(Icons.record_voice_over, size: 80, color: Theme.of(context).primaryColor),
              const SizedBox(height: 30),
              Text(
                _isLogin ? 'Добро пожаловать' : 'Создать аккаунт',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Поле Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),

              // Поле Пароль
              TextField(
                controller: _passwordController,
                obscureText: true, // Скрывает пароль звездочками
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),

              // Кнопка Входа/Регистрации
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitAuth,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(_isLogin ? 'Войти' : 'Зарегистрироваться', style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 16),

              // Кнопка переключения режимов (Вход <-> Регистрация)
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(_isLogin
                    ? 'Нет аккаунта? Зарегистрируйтесь'
                    : 'Уже есть аккаунт? Войти'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}