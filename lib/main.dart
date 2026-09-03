import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app/app.dart';
import 'core/firebase/firebase_options.dart';

/// Null when Firebase came up; the reason when it did not. A silent init
/// failure looks like a broken login rather than a missing backend.
String? firebaseInitError;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Clean paths, so /wallet and /privacy are real URLs a visitor can share.
  if (kIsWeb) usePathUrlStrategy();

  // The app still runs without Firebase: points and the business ledger fall
  // back to local storage, so a bad network is a degraded session, not a dead
  // one.
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    await (options == null
        ? Firebase.initializeApp()
        : Firebase.initializeApp(options: options));
  } catch (error, stack) {
    firebaseInitError = '$error';
    debugPrint('Firebase unavailable, running locally: $error\n$stack');
  }

  runApp(const ProviderScope(child: GabisApp()));
}
