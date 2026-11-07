import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/app_service.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('أديب شات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _searchDialog(context, uid),
        child: const Icon(Icons.person_search),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: uid)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('خطأ: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs
              .where((d) => d.data()['lastTime'] != null)
              .toList()
            ..sort((a, b) => (b.data()['lastTime'] as Timestamp)
                .compareTo(a.data()['lastTime'] as Timestamp));
          if (docs.isEmpty) {
            return const Center(
                child: Text('لا توجد محادثات بعد.\nاضغط على الزر للبحث برقم صديقك.',
                    textAlign: TextAlign.center));
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final d = docs[i].data();
              final members = Map<String, dynamic>.from(d['members'] ?? {});
              final peerId =
                  (d['participants'] as List).firstWhere((x) => x != uid);
              final peer = Map<String, dynamic>.from(members[peerId] ?? {});
              peer['uid'] = peerId;
              return ListTile(
                leading: _Avatar(url: peer['photo'], name: peer['name']),
                title: Text(peer['name'] ?? 'مستخدم'),
                subtitle: Text(d['lastMessage'] ?? '',
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ChatScreen(peer: peer))),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _searchDialog(BuildContext context, String myUid) async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (dctx) {
        String? error;
        bool busy = false;
        return StatefulBuilder(builder: (dctx, setS) {
          Future<void> go() async {
            final n = int.tryParse(ctrl.text.trim());
            if (n == null) {
              setS(() => error = 'أدخل رقماً صحيحاً');
              return;
            }
            setS(() {
              busy = true;
              error = null;
            });
            try {
              final u = await AppService.findByNumber(n);
              if (u == null) {
                setS(() {
                  busy = false;
                  error = 'لا يوجد مستخدم بهذا الرقم';
                });
              } else if (u['uid'] == myUid) {
                setS(() {
                  busy = false;
                  error = 'هذا رقمك أنت 🙂';
                });
              } else {
                if (dctx.mounted) Navigator.pop(dctx);
                if (context.mounted) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ChatScreen(peer: u)));
                }
              }
            } catch (e) {
              setS(() {
                busy = false;
                error = 'خطأ: $e';
              });
            }
          }

          return AlertDialog(
            title: const Text('البحث برقم المستخدم'),
            content: TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration:
                  InputDecoration(hintText: 'مثال: 10000001', errorText: error),
              onSubmitted: (_) => go(),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dctx),
                  child: const Text('إلغاء')),
              FilledButton(
                  onPressed: busy ? null : go, child: const Text('بحث')),
            ],
          );
        });
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String? name;
  const _Avatar({this.url, this.name});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: (url != null && url!.isNotEmpty) ? NetworkImage(url!) : null,
      child: (url == null || url!.isEmpty)
          ? Text((name ?? '?').characters.first)
          : null,
    );
  }
}
