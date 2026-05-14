import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCaLP4Ng0pe8AlX_0KUxgkfg7Kv9YA3nhY',
    appId: '1:230335947923:web:d677f108b0cc9914519966',
    messagingSenderId: '230335947923',
    projectId: 'devops-roadmap-x3',
    authDomain: 'devops-roadmap-x3.firebaseapp.com',
    storageBucket: 'devops-roadmap-x3.firebasestorage.app',
    measurementId: 'G-YPE10L62ZC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBLEcPQOgPLsL7lzKSLwabet0FwCNyo00k',
    appId: '1:230335947923:android:efad94b6139d5f48519966',
    messagingSenderId: '230335947923',
    projectId: 'devops-roadmap-x3',
    storageBucket: 'devops-roadmap-x3.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyATqUT11hs_J-N2PvwYBxnAiuVyOX-VpSw',
    appId: '1:230335947923:ios:707449d249e1c156519966',
    messagingSenderId: '230335947923',
    projectId: 'devops-roadmap-x3',
    storageBucket: 'devops-roadmap-x3.firebasestorage.app',
    iosClientId: '230335947923-amv3ga12bhchg29uv5kr00tc03ip33jf.apps.googleusercontent.com',
    iosBundleId: 'com.example.kareemFinal',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: '1:YOUR_APP_ID:macos:YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'lumo-ai-medical',
    storageBucket: 'lumo-ai-medical.appspot.com',
    iosBundleId: 'com.lumoai.medical',
  );
}