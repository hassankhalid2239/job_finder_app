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
        return macos;
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
    apiKey: 'AIzaSyANkUz2jSOdRn9N4JHDvJhwn25B6u3xKnM',
    appId: '1:2879264052:web:fd6f09ad504d05f8548161',
    messagingSenderId: '2879264052',
    projectId: 'jobfinderapp-82d58',
    authDomain: 'jobfinderapp-82d58.firebaseapp.com',
    storageBucket: 'jobfinderapp-82d58.appspot.com',
    measurementId: 'G-E92XNGZJT6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC_rHiQUG9d9ALuTH8LpJwBY6hl_GbeLps',
    appId: '1:2879264052:android:661d13958a75c9c2548161',
    messagingSenderId: '2879264052',
    projectId: 'jobfinderapp-82d58',
    storageBucket: 'jobfinderapp-82d58.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCOSssl5cwP8lVULZJ3npkYBJDyISHVaw0',
    appId: '1:2879264052:ios:65fe3d299a85ba5f548161',
    messagingSenderId: '2879264052',
    projectId: 'jobfinderapp-82d58',
    storageBucket: 'jobfinderapp-82d58.appspot.com',
    iosBundleId: 'com.eyet.jobFinderApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCOSssl5cwP8lVULZJ3npkYBJDyISHVaw0',
    appId: '1:2879264052:ios:65fe3d299a85ba5f548161',
    messagingSenderId: '2879264052',
    projectId: 'jobfinderapp-82d58',
    storageBucket: 'jobfinderapp-82d58.appspot.com',
    iosBundleId: 'com.eyet.jobFinderApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyANkUz2jSOdRn9N4JHDvJhwn25B6u3xKnM',
    appId: '1:2879264052:web:e6573e52b8529f19548161',
    messagingSenderId: '2879264052',
    projectId: 'jobfinderapp-82d58',
    authDomain: 'jobfinderapp-82d58.firebaseapp.com',
    storageBucket: 'jobfinderapp-82d58.appspot.com',
    measurementId: 'G-949TYM81QK',
  );
}
