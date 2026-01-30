import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  // Энэ бол Flutter-ийн стандарт widget factory юм.
  // Input болон алдааг зохицуулахын тулд stateful байх шаардлагатай.
  // Анхаарах зүйл: энгийн widget үүсгэлт.
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // Email/password ашиглан нэвтрэх функц.
  // Auth логбийг дэлгэцэнд ойр байлгах үүднээс энд бичсэн.
  // Анхаарах зүйл: буруу мэдээлэл хийвэл UI дээр алдааг харуулна.
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      if (user != null) {
        ref.read(authStateProvider.notifier).state = user.uid;
      }
      // Navigation handled by Router Guard
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Хурдан тест хийхэд зориулсан бүртгүүлэх функц.
  // Админ хэсэгт дата харагдуулахын тулд энд үлдээв.
  // Анхаарах зүйл: сул нууц үг эсвэл давхардсан мэйл байвал Firebase алдаа өгнө.
  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .register(
            uid: DateTime.now().millisecondsSinceEpoch.toString(),
            email: _emailController.text.trim(),
            isAdmin:
                true, // Тест хийхэд хялбар байлгах үүднээс админ эрхтэй үүсгэж байна
            displayName: "Test Admin",
            password: _passwordController.text.trim(),
          );
      // Бүртгүүлсний дараа шууг нэвтрүүлж болно
      await _login();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Нэвтрэх болон бүртгүүлэх UI-г угсрах.
  // Админ апп учраас загварыг энгийн бөгөөд ойлгомжтой байлгав.
  // Анхаарах зүйл: зөвхөн алдаа гарсан үед л анхааруулга харуулна.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.red.shade100,
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: _login, child: const Text('Login')),
                  TextButton(
                    onPressed: _register,
                    child: const Text('Register (Test)'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
