// Firebase config for the gabis web app.
//
// Lives in the existing `paynautic` project because the account is at its
// Google Cloud project quota; gabis keeps its own Firestore collections under
// users/{uid}, so nothing here touches the other app's data.
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAGiYLeJ_VcZPjlKoGp_7_ne4HRXNFmxic',
    appId: '1:153854878177:web:bd4208784f8467e229b2a0',
    messagingSenderId: '153854878177',
    projectId: 'paynautic',
    authDomain: 'paynautic.firebaseapp.com',
    storageBucket: 'paynautic.firebasestorage.app',
    measurementId: 'G-EC1XJXM07Z',
  );

  /// Android reads android/app/google-services.json through the Gradle plugin
  /// rather than values compiled in here, so passing it web's options would
  /// point the phone at the wrong app record. Null lets the native SDK use the
  /// file it already has.
  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) return web;
    return defaultTargetPlatform == TargetPlatform.android ? null : web;
  }
}
