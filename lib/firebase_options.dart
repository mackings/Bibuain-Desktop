// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyAZWJ-fnF2K7bZf6B1tkPfEgUvlTJnZIAk',
    appId: '1:1044761303456:web:d39cb2d2bc67753b042cc5',
    messagingSenderId: '1044761303456',
    projectId: 'bibuain-de956',
    authDomain: 'bibuain-de956.firebaseapp.com',
    storageBucket: 'bibuain-de956.appspot.com',
    measurementId: 'G-M42TC0DMWX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDrsN002y0Q2MOIX4ojVfW7aQLV9OAcyjw',
    appId: '1:1044761303456:android:63cabad3490953d1042cc5',
    messagingSenderId: '1044761303456',
    projectId: 'bibuain-de956',
    storageBucket: 'bibuain-de956.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCXoe80Gpk68QDuNfh3xmapuxhPEfKYrI8',
    appId: '1:1044761303456:ios:a35da518f05a7830042cc5',
    messagingSenderId: '1044761303456',
    projectId: 'bibuain-de956',
    storageBucket: 'bibuain-de956.appspot.com',
    iosClientId: '1044761303456-7ohcknsb4ke5satvqrq6e45lnt0dib0n.apps.googleusercontent.com',
    iosBundleId: 'com.example.bdesktop',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCXoe80Gpk68QDuNfh3xmapuxhPEfKYrI8',
    appId: '1:1044761303456:ios:a41b91548ffe803b042cc5',
    messagingSenderId: '1044761303456',
    projectId: 'bibuain-de956',
    storageBucket: 'bibuain-de956.appspot.com',
    iosClientId: '1044761303456-prp9brls68aib9m09nk3r2v590f2atei.apps.googleusercontent.com',
    iosBundleId: 'com.example.bdesktop.RunnerTests',
  );
}
