import 'package:flutter/material.dart';
import '../services/auth_repository.dart';
import '../services/local_auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Работаем через интерфейс
  final IAuthRepository _authService = LocalAuthService();

  bool _isLogin = true;
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

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
      // После успешного входа Navigator перенаправит пользователя
      // благодаря стриму в main.dart (который мы настроим на следующем шаге)
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                Text(_isLogin ? 'Pieslēgties' : 'Reģistrācija', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), // Вход : Регистрация
                const SizedBox(height: 30),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'E-pasts', border: OutlineInputBorder()), // Email
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || !value.contains('@') ? 'Ievadiet derīgu e-pastu' : null, // Введите корректный email
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Parole', border: OutlineInputBorder()), // Пароль
                  obscureText: true,
                  validator: (value) => value == null || value.length < 6 ? 'Parolei jābūt vismaz 6 simbolus garai' : null, // Пароль должен быть от 6 символов
                ),
                const SizedBox(height: 24),

                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: Text(_isLogin ? 'Pieslēgties' : 'Izveidot kontu'), // Войти : Создать аккаунт
                ),

                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(_isLogin ? 'Nav konta? Reģistrēties' : 'Jau ir konts? Pieslēgties'), // Нет аккаунта? Регистрация : Уже есть аккаунт? Войти
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}