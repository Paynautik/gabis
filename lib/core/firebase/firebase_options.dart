// Firebase config for the gabis web app.
//
// Lives in the existing `paynautic` project because the account is at its
// Google Cloud project quota; gabis keeps its own Firestore collections under
// users/{uid}, so nothing here touches the other app's data.
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

  /// Web is the shipping target today; mobile builds fall back to the same
  /// project once their app records exist.
  static FirebaseOptions get currentPlatform => web;
}
