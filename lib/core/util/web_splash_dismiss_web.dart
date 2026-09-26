import 'dart:js_interop';
import 'package:web/web.dart' as web;

void dismissSplash() {
  final splash = web.document.getElementById('gabis-splash');
  if (splash != null) {
    splash.classList.add('is-done');
    web.window.setTimeout(
      (() {
        splash.remove();
      }).toJS,
      400.toJS,
    );
  }
}
