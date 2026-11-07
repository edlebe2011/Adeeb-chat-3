import 'package:firebase_core/firebase_core.dart';

/// املأ هذه القيم من إعدادات مشروعك في Firebase (راجع README.md).
const String kWebClientId =
    'ضع_هنا_Web_client_ID.apps.googleusercontent.com';

class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'ضع_API_KEY',
    appId: 'ضع_APP_ID', // مثل 1:1234567890:android:abcdef
    messagingSenderId: 'ضع_SENDER_ID',
    projectId: 'ضع_PROJECT_ID',
  );
}
