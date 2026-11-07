import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/app_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: AppService.me(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final me = snap.data!;
          final photo = me['photo'] as String?;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundImage:
                      (photo != null && photo.isNotEmpty) ? NetworkImage(photo) : null,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                  child: Text(me['name'] ?? '',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))),
              Center(child: Text(me['email'] ?? '')),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.tag),
                  title: const Text('رقمك في أديب شات'),
                  subtitle: SelectableText('${me['number']}',
                      style: const TextStyle(fontSize: 20)),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: '${me['number']}'));
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم نسخ الرقم')));
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: Image.asset('assets/icon.png', width: 40),
                  title: const Text('عن التطبيق'),
                  subtitle: const Text(kDeveloperCredit),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  await AppService.signOut();
                  if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
                },
                icon: const Icon(Icons.logout),
                label: const Text('تسجيل الخروج'),
              ),
            ],
          );
        },
      ),
    );
  }
}
