import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../firebase_options.dart';

class AppService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;
  static final _google = GoogleSignIn(serverClientId: kWebClientId);

  static Map<String, dynamic>? _me;

  static Future<void> signInWithGoogle() async {
    final g = await _google.signIn();
    if (g == null) return;
    final ga = await g.authentication;
    final cred = GoogleAuthProvider.credential(
        accessToken: ga.accessToken, idToken: ga.idToken);
    final uc = await _auth.signInWithCredential(cred);
    await _ensureProfile(uc.user!);
  }

  static Future<void> signOut() async {
    _me = null;
    await _google.signOut();
    await _auth.signOut();
  }

  /// ينشئ ملفاً للمستخدم ويعطيه رقماً فريداً (متسلسل) عند أول تسجيل دخول.
  static Future<void> _ensureProfile(User u) async {
    final ref = _db.collection('users').doc(u.uid);
    final counter = _db.collection('meta').doc('counter');
    await _db.runTransaction((tx) async {
      final s = await tx.get(ref);
      if (s.exists) return;
      final c = await tx.get(counter);
      final next = (c.exists ? (c.data()!['value'] as int) : 10000000) + 1;
      tx.set(counter, {'value': next});
      tx.set(ref, {
        'uid': u.uid,
        'number': next,
        'name': u.displayName ?? 'مستخدم',
        'email': u.email,
        'photo': u.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  static Future<Map<String, dynamic>> me() async {
    if (_me != null) return _me!;
    final u = _auth.currentUser!;
    var s = await _db.collection('users').doc(u.uid).get();
    if (!s.exists) {
      await _ensureProfile(u);
      s = await _db.collection('users').doc(u.uid).get();
    }
    return _me = s.data()!;
  }

  static Future<Map<String, dynamic>?> findByNumber(int number) async {
    final q = await _db
        .collection('users')
        .where('number', isEqualTo: number)
        .limit(1)
        .get();
    return q.docs.isEmpty ? null : q.docs.first.data();
  }

  static String chatId(String a, String b) {
    final l = [a, b]..sort();
    return l.join('_');
  }
}
