import 'package:flutter/material.dart';
import 'nautik_logo.dart';

/// Single source of truth for every phone mockup in the product.
/// Dark rounded bezel, white screen, iOS status bar with dynamic island,
/// gabis wordmark + status pill header, and a home indicator.
class GabisPhoneFrame extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;

  /// Small pill shown at the top-right of the in-app header (e.g. "Live").
  final String? statusLabel;

  /// Whether to show the gabis wordmark + status pill header row.
  final bool showAppHeader;

  const GabisPhoneFrame({
    super.key,
    required this.child,
    this.width = 295,
    this.height = 570,
    this.statusLabel = 'Live',
    this.showAppHeader = true,
  });

  static const _ink = Color(0xFF0F172A);
  static const _bezel = Color(0xFF1E293B);
  static const _green = Color(0xFF00C16A);
  static const _deepGreen = Color(0xFF006D44);

  @override
  Widget build(BuildContext context) {
    final scale = height / 570;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(48 * scale),
        border: Border.all(color: _bezel, width: 5.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 36,
            spreadRadius: 1,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: _green.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(42 * scale),
        child: Column(
          children: [
            // Status bar + dynamic island
            Container(
              height: 36 * scale,
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20 * scale),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '9:41',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 11 * scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    width: 74 * scale,
                    height: 18 * scale,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 6 * scale,
                          height: 6 * scale,
                          margin: EdgeInsets.only(right: 6 * scale),
                          decoration: const BoxDecoration(
                            color: _bezel,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(width: 2, height: 4 * scale, color: _ink),
                          const SizedBox(width: 1),
                          Container(width: 2, height: 6 * scale, color: _ink),
                          const SizedBox(width: 1),
                          Container(width: 2, height: 8 * scale, color: _ink),
                          const SizedBox(width: 1),
                          Container(width: 2, height: 10 * scale, color: _ink),
                        ],
                      ),
                      SizedBox(width: 6 * scale),
                      Container(
                        width: 18 * scale,
                        height: 9 * scale,
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          border: Border.all(color: _ink, width: 1),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 12 * scale,
                          decoration: BoxDecoration(
                            color: _green,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // In-app header: official gabis wordmark + status pill
            if (showAppHeader)
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * scale,
                  vertical: 6 * scale,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GabismWordmark(height: 22 * scale),
                    if (statusLabel != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8 * scale,
                          vertical: 3 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: _green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _green.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          statusLabel!,
                          style: TextStyle(
                            color: _deepGreen,
                            fontSize: 10 * scale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // Screen content
            Expanded(
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: child,
                ),
              ),
            ),

            // Home indicator
            Container(
              height: 16 * scale,
              color: Colors.white,
              alignment: Alignment.center,
              child: Container(
                width: 100 * scale,
                height: 4,
                decoration: BoxDecoration(
                  color: _ink.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
