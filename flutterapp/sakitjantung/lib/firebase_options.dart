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
    apiKey: 'AIzaSyAeLgDNfe2kgoLUhKjn-Tr49DfJVsCx1Ac',
    appId: '1:1067382796201:web:da0c12f13b929c5b77deb8',
    messagingSenderId: '1067382796201',
    projectId: 'sakitjantung-5af49',
    authDomain: 'sakitjantung-5af49.firebaseapp.com',
    storageBucket: 'sakitjantung-5af49.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDGBnevuiU5m4u18rtEbwtrPq6R1ygiLnY',
    appId: '1:1067382796201:android:f480739985db0bfd77deb8',
    messagingSenderId: '1067382796201',
    projectId: 'sakitjantung-5af49',
    storageBucket: 'sakitjantung-5af49.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDd2qzcocusc21OWQ09ER-COSjkjLYMQm0',
    appId: '1:1067382796201:ios:d6dac693edd08bf177deb8',
    messagingSenderId: '1067382796201',
    projectId: 'sakitjantung-5af49',
    storageBucket: 'sakitjantung-5af49.appspot.com',
    iosBundleId: 'com.example.sakitjantung',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDd2qzcocusc21OWQ09ER-COSjkjLYMQm0',
    appId: '1:1067382796201:ios:a077ff3df086734477deb8',
    messagingSenderId: '1067382796201',
    projectId: 'sakitjantung-5af49',
    storageBucket: 'sakitjantung-5af49.appspot.com',
    iosBundleId: 'com.example.sakitjantung.RunnerTests',
  );
}
