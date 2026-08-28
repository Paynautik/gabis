import 'package:flutter/material.dart';

/// Shows feedback for actions that aren't wired to a backend yet, so every
/// control responds to a tap instead of silently doing nothing.
void showComingSoon(BuildContext context, [String feature = 'This']) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$feature isn\'t wired up yet — coming soon.'),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}
