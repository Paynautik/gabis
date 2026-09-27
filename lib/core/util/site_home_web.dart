import 'package:web/web.dart' as web;

/// A full page load of "/", so the server's rewrite serves the static
/// homepage rather than the app drawing its own old landing screen.
void goToSiteHome() => web.window.location.assign('/');
