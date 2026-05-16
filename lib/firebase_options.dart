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
    apiKey: 'AIzaSyCCLRowonwKlSx1_zY43MYH8Hu-qcDz2FQ',
    appId: '1:783937682466:web:6cf1cb9341f4020f6a5e7b',
    messagingSenderId: '783937682466',
    projectId: 'lumo-flutter-app',
    authDomain: 'lumo-flutter-app.firebaseapp.com',
    storageBucket: 'lumo-flutter-app.firebasestorage.app',
    measurementId: 'G-DZT3D782TS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC_FxWDNbaK6NLe-WYRAu7c7GKyGD4cO20',
    appId: '1:783937682466:android:4fceee502e78ca916a5e7b',
    messagingSenderId: '783937682466',
    projectId: 'lumo-flutter-app',
    storageBucket: 'lumo-flutter-app.firebasestorage.app',
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
    apiKey: 'AIzaSyBthbaJafp5W3dSJbOTfAWsvpvOxQJ8vYE',
    appId: '1:783937682466:ios:04df6e07c0a896116a5e7b',
    messagingSenderId: '783937682466',
    projectId: 'lumo-flutter-app',
    storageBucket: 'lumo-flutter-app.firebasestorage.app',
    iosClientId: '783937682466-c5doq74m7528m7mr3q2vdcka9ca6f8q8.apps.googleusercontent.com',
    iosBundleId: 'com.example.kareemFinal',
  );

}