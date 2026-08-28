import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class InAppNotification {
  static void show(BuildContext context, {required String title, required String message}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: -100.0, end: 0.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, value),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.bgSoft,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.colors.bluePrimary.withValues(alpha: 0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: context.colors.bluePrimary.withValues(alpha: 0.15), blurRadius: 24, offset: Offset(0, 8)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.colors.blueHighlight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person_add_alt_1_rounded, color: context.colors.bluePrimary, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: context.colors.ink)),
                            const SizedBox(height: 4),
                            Text(message, style: TextStyle(color: context.colors.inkSoft, fontSize: 12.5, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: context.colors.inkSoft, size: 18),
                        onPressed: () => entry.remove(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 5), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }
}
