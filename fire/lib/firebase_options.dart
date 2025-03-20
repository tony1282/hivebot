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
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyAoddH_cnEC8WOJdUVkNXJ6wvLGufGfa7E',
    appId: '1:782360004864:web:8b56de92f6e4fde0180be5',
    messagingSenderId: '782360004864',
    projectId: 'hivebot-251af',
    authDomain: 'hivebot-251af.firebaseapp.com',
    databaseURL: 'https://hivebot-251af-default-rtdb.firebaseio.com',
    storageBucket: 'hivebot-251af.firebasestorage.app',
    measurementId: 'G-LEDL9C91J1',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAR6tXgJjcAW-irG2VoZyGB1lhCsTTsfv4',
    appId: '1:782360004864:android:290b2cfa80c33e11180be5',
    messagingSenderId: '782360004864',
    projectId: 'hivebot-251af',
    databaseURL: 'https://hivebot-251af-default-rtdb.firebaseio.com',
    storageBucket: 'hivebot-251af.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDLWxGfFgchz5tu7c5tKkeB59gaq8TuqEA',
    appId: '1:782360004864:ios:4316215aa5d6b8ea180be5',
    messagingSenderId: '782360004864',
    projectId: 'hivebot-251af',
    databaseURL: 'https://hivebot-251af-default-rtdb.firebaseio.com',
    storageBucket: 'hivebot-251af.firebasestorage.app',
    iosBundleId: 'com.example.fire',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAoddH_cnEC8WOJdUVkNXJ6wvLGufGfa7E',
    appId: '1:782360004864:web:899f7af2c5f73095180be5',
    messagingSenderId: '782360004864',
    projectId: 'hivebot-251af',
    authDomain: 'hivebot-251af.firebaseapp.com',
    databaseURL: 'https://hivebot-251af-default-rtdb.firebaseio.com',
    storageBucket: 'hivebot-251af.firebasestorage.app',
    measurementId: 'G-0Z5G42H8XP',
  );
}
