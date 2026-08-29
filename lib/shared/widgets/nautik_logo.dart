import 'dart:async';
import 'package:flutter/material.dart';

class NautikLogoMark extends StatelessWidget {
  final double size;
  const NautikLogoMark({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return GabismWordmark(height: size);
  }
}

class GabisLogo extends StatefulWidget {
  final bool? showingPay;
  final double size;
  final bool isWhite;

  const GabisLogo({
    super.key,
    this.showingPay,
    this.size = 36,
    this.isWhite = false,
  });

  @override
  State<GabisLogo> createState() => _GabisLogoState();
}

class _GabisLogoState extends State<GabisLogo> {
  late bool _showingPay;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _showingPay = widget.showingPay ?? true;
    if (widget.showingPay == null) {
      _timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (mounted) {
          setState(() {
            _showingPay = !_showingPay;
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant GabisLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showingPay != null) {
      _showingPay = widget.showingPay!;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectivePay = widget.showingPay ?? _showingPay;
    final payAsset = widget.isWhite ? 'assets/gabis_pay_logo_white.png' : 'assets/gabis_pay_logo.png';
    final mAsset = widget.isWhite ? 'assets/gabism_logo_white.png' : 'assets/gabism_logo.png';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: Image.asset(
        effectivePay ? payAsset : mAsset,
        key: ValueKey<bool>(effectivePay),
        height: widget.size,
        fit: BoxFit.contain,
      ),
    );
  }
}

class GabismWordmark extends StatelessWidget {
  final double height;
  final bool isWhite;
  const GabismWordmark({super.key, this.height = 32, this.isWhite = false});

  @override
  Widget build(BuildContext context) {
    return GabisLogo(size: height, isWhite: isWhite);
  }
}
