import 'package:web/web.dart' as web;

String? readRaw(String key) => web.window.localStorage.getItem(key);

void writeRaw(String key, String value) =>
    web.window.localStorage.setItem(key, value);

void removeRaw(String key) => web.window.localStorage.removeItem(key);
