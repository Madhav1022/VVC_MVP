import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }


  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCe9qwhrD-wJpyT3sRSZ8oBNZqtmMhEvIQ',
    appId: '1:69846252325:android:88c4eac6fb4f1435ddb8cc',
    messagingSenderId: '69846252325',
    projectId: 'virtual-visiting-card-mvp',
    storageBucket: 'virtual-visiting-card-mvp.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCHElDEvCDxlMVodXx1aeSrsbv-StLE3Hk',
    appId: '1:69846252325:ios:48ee2baf2fc80b32ddb8cc',
    messagingSenderId: '69846252325',
    projectId: 'virtual-visiting-card-mvp',
    storageBucket: 'virtual-visiting-card-mvp.firebasestorage.app',
    iosBundleId: 'com.example.virtualVisitingCardMvp',
  );
}