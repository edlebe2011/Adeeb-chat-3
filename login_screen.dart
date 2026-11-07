import 'package:flutter/material.dart';

import '../services/app_service.dart';

const String kDeveloperCredit =
    'تطبيق من تطوير محمد أديب بلال كاش\nسوريا - إدلب - بلدة دير الغربي';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await AppService.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('تعذر تسجيل الدخول: $e')));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Image.asset('assets/icon.png', width: 220),
              const SizedBox(height: 16),
              const Text('مرحباً بك في أديب شات',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              _loading
                  ? const CircularProgressIndicator()
                  : FilledButton.icon(
                      onPressed: _login,
                      icon: const Icon(Icons.login),
                      label: const Text('تسجيل الدخول عبر جوجل'),
                      style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52)),
                    ),
              const Spacer(),
              Text(kDeveloperCredit,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
