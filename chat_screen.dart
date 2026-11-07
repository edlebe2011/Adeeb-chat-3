import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/app_service.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> peer;
  const ChatScreen({super.key, required this.peer});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  late final DocumentReference<Map<String, dynamic>> _chat;
  bool _ready = false;
  Map<String, dynamic> _me = {};

  Map<String, dynamic> _member(Map<String, dynamic> u) =>
      {'name': u['name'], 'photo': u['photo'], 'number': u['number']};

  @override
  void initState() {
    super.initState();
    _chat = FirebaseFirestore.instance
        .collection('chats')
        .doc(AppService.chatId(_uid, widget.peer['uid']));
    _init();
  }

  Future<void> _init() async {
    _me = await AppService.me();
    await _chat.set({
      'participants': [_uid, widget.peer['uid']],
      'members': {
        _uid: _member(_me),
        widget.peer['uid']: _member(widget.peer),
      },
    }, SetOptions(merge: true));
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || !_ready) return;
    _ctrl.clear();
    final batch = FirebaseFirestore.instance.batch();
    batch.set(
        _chat,
        {
          'lastMessage': text,
          'lastTime': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true));
    batch.set(_chat.collection('messages').doc(), {
      'text': text,
      'from': _uid,
      'time': FieldValue.serverTimestamp(),
    });
    try {
      await batch.commit();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('فشل الإرسال: $e')));
      }
    }
  }

  String _time(Timestamp? t) {
    if (t == null) return '';
    final d = t.toDate();
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.peer['name'] ?? 'مستخدم',
                style: const TextStyle(fontSize: 17)),
            Text('${widget.peer['number'] ?? ''}',
                style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: !_ready
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _chat
                        .collection('messages')
                        .orderBy('time', descending: true)
                        .limit(200)
                        .snapshots(),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return Center(child: Text('خطأ: ${snap.error}'));
                      }
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snap.data!.docs;
                      return ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(12),
                        itemCount: docs.length,
                        itemBuilder: (context, i) {
                          final m = docs[i].data();
                          final mine = m['from'] == _uid;
                          return Align(
                            alignment: mine
                                ? AlignmentDirectional.centerStart
                                : AlignmentDirectional.centerEnd,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * .75),
                              decoration: BoxDecoration(
                                color: mine
                                    ? cs.primaryContainer
                                    : cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(m['text'] ?? '',
                                      style: const TextStyle(fontSize: 16)),
                                  Text(_time(m['time'] as Timestamp?),
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالة...',
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
