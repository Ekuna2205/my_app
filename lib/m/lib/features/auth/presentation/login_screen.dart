import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.local_car_wash,
                size: 80,
                color: Color(0xFF1565C0),
              ),
              const SizedBox(height: 24),
              const Text(
                'Авто Угаалга',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Хэрэглэгчийн нэр эсвэл утас',
                  prefixIcon: Icon(Icons.person),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Нууц үг',
                  prefixIcon: Icon(Icons.lock),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleLogin(),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _handleLogin,
                child: const Text('Нэвтрэх', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  // мартсан нууц үг эсвэл бүртгүүлэх хэсэг
                },
                child: const Text('Нууц үг мартсан уу?'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    // Энд Firebase Auth эсвэл dummy шалгалт хийнэ
    // Түр зуур home руу шилжүүлье
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }
}
