// File generated manually from google-services.json and GoogleService-Info.plist
// Project: arrienda-seguro-d3d45
//
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA8x8aC-aIMVfti_HJPFC0l_P7VXI3xYMs',
    appId: '1:271119233724:android:9772de2414dc1a3dde56b9',
    messagingSenderId: '271119233724',
    projectId: 'arrienda-seguro-d3d45',
    storageBucket: 'arrienda-seguro-d3d45.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBM6JkJYE2jfgIO0BC1-3-c8bSiHKWXgRQ',
    appId: '1:271119233724:ios:9e6c6d81ddd243acde56b9',
    messagingSenderId: '271119233724',
    projectId: 'arrienda-seguro-d3d45',
    storageBucket: 'arrienda-seguro-d3d45.firebasestorage.app',
    iosBundleId: 'com.arriendaseguro.arriendaSeguro',
  );
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCdIHNAXGkSC72i78zkXC2x-n2xhp2cE4E',
    appId: '1:271119233724:web:14b461435d9f914cde56b9',
    messagingSenderId: '271119233724',
    projectId: 'arrienda-seguro-d3d45',
    authDomain: 'arrienda-seguro-d3d45.firebaseapp.com',
    storageBucket: 'arrienda-seguro-d3d45.firebasestorage.app',
  );
}
