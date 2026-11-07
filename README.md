# أديب شات (Adeeb Chat)

تطبيق محادثة عربي مفتوح المصدر مبني بـ Flutter و Firebase.

**تطبيق من تطوير محمد أديب بلال كاش — سوريا، إدلب، بلدة دير الغربي**

## المميزات
- واجهة عربية كاملة (RTL) عصرية.
- تسجيل الدخول عبر حساب جوجل.
- يحصل كل مستخدم عند أول دخول على **رقم حقيقي فريد** (يظهر في الإعدادات).
- البحث عن أي مستخدم برقمه من هاتف آخر وبدء محادثة فورية معه.
- رسائل فورية عبر Cloud Firestore، وقائمة محادثات مرتبة بالأحدث.
- بناء APK تلقائي عبر GitHub Actions.

## هيكل المشروع
```
pubspec.yaml
README.md
firestore.rules
assets/icon.png
.github/workflows/build.yml
lib/main.dart
lib/firebase_options.dart
lib/services/app_service.dart
lib/screens/{login,home,chat,settings}_screen.dart
```
> لا يوجد `main.dart` في الجذر. مجلد `android/` يُولَّد تلقائياً أثناء البناء.

## إعداد Firebase (مرة واحدة)
1. أنشئ مشروعاً في https://console.firebase.google.com
2. أضف تطبيق Android باسم الحزمة: `com.adeeb.adeeb_chat`
3. **Authentication ← Sign-in method**: فعّل Google.
4. **Firestore Database**: أنشئ قاعدة بيانات، ثم الصق محتوى `firestore.rules` في تبويب Rules وانشر.
5. من إعدادات المشروع انسخ `API key` و `App ID` و `Sender ID` و `Project ID` إلى `lib/firebase_options.dart`.
6. من إعدادات Google sign-in في Authentication انسخ **Web client ID** إلى `kWebClientId`.
7. شغّل الـ Workflow مرة، ثم افتح ملخص الخطوة (Summary) وانسخ **SHA-1**، وأضفه في Firebase ← إعدادات التطبيق ← Add fingerprint.
8. أعد تشغيل الـ Workflow ونزّل الـ APK من Artifacts.

## ملاحظات
- المفتاح المستخدم للتوقيع يُحفظ في cache الـ Actions لتبقى بصمة SHA-1 ثابتة.
  إن انتهت صلاحية الـ cache (بعد 7 أيام بلا بناء) قد تتغير البصمة فأضف الجديدة.
