// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCUk3_Dl2uCEPgE2qg-Oxra9lLQ1UfUs1M',
    appId: '1:770375361892:web:04193428057f6d6e1c8671',
    messagingSenderId: '770375361892',
    projectId: 'security-e8972',
    authDomain: 'security-e8972.firebaseapp.com',
    storageBucket: 'security-e8972.firebasestorage.app',
    measurementId: 'G-LQ0F9D7DNB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDfmGqeWudHxM7xC2HsKlb1KCL-g7UtOEE',
    appId: '1:770375361892:android:f45c97b1bafc35721c8671',
    messagingSenderId: '770375361892',
    projectId: 'security-e8972',
    storageBucket: 'security-e8972.firebasestorage.app',
  );
}
