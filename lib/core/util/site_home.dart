import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../features/landing/gabis_landing_v3.dart';
import 'site_home_stub.dart' if (dart.library.js_interop) 'site_home_web.dart';

/// What the app shows for "/" and "/landing".
///
/// On the web the homepage is the static page in web/landing, served at "/"
/// by the server. Leaving the app (signing out, tapping the logo, going back)
/// must load that page, not the app's own older landing screen.
///
/// Flutter builds "/" underneath deep links like /login, so this redirects only
/// when it is the route actually on screen, never while buried in the stack.
class SiteHome extends StatelessWidget {
  const SiteHome({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const LandingScreen();
    final route = ModalRoute.of(context);
    if (route?.isCurrent ?? true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ModalRoute.of(context)?.isCurrent ?? true) goToSiteHome();
      });
    }
    return const Scaffold(
      backgroundColor: Color(0xFFF6F3EE),
      body: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))),
    );
  }
}
