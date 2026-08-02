import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCPPUyo7oOyvDlnlcRLEAaR-mkf6i9qS3g',
    appId: '1:450196185438:web:da98b6f38d6b224882e9f3', // Placeholder, replace with actual Web App ID
    messagingSenderId: '450196185438',
    projectId: 'promart-9bf8f',
    authDomain: 'promart-9bf8f.firebaseapp.com',
    storageBucket: 'promart-9bf8f.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCPPUyo7oOyvDlnlcRLEAaR-mkf6i9qS3g',
    appId: '1:450196185438:android:8d6b224882e9f3f158afcf',
    messagingSenderId: '450196185438',
    projectId: 'promart-9bf8f',
    storageBucket: 'promart-9bf8f.firebasestorage.app',
  );
}
