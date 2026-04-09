import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart'; // Не забудь создать этот файл

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLogin = true;
  bool _isLoading = false;

  Future<void> _submit() async {
    // Валидация полей
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await _authService.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await _authService.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Произошла ошибка';
      if (e.code == 'user-not-found') message = 'Пользователь не найден';
      else if (e.code == 'wrong-password') message = 'Неверный пароль';
      else if (e.code == 'email-already-in-use') message = 'Этот Email уже занят';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? message)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Icon(Icons.record_voice_over, size: 80, color: Theme.of(context).primaryColor),
                const SizedBox(height: 30),
                Text(_isLogin ? 'Вход' : 'Регистрация', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || !value.contains('@') ? 'Введите корректный email' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Пароль', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) => value == null || value.length < 6 ? 'Пароль должен быть от 6 символов' : null,
                ),
                const SizedBox(height: 24),

                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: Text(_isLogin ? 'Войти' : 'Создать аккаунт'),
                ),

                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(_isLogin ? 'Нет аккаунта? Регистрация' : 'Уже есть аккаунт? Войти'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}