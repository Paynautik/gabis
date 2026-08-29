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

class GabisLogo extends StatelessWidget {
  final double size;
  final bool isWhite;

  const GabisLogo({
    super.key,
    dynamic showingPay,
    this.size = 36,
    this.isWhite = false,
  });

  @override
  Widget build(BuildContext context) {
    final assetName = isWhite ? 'assets/gabis_logo_white.png' : 'assets/gabis_logo.png';
    return Image.asset(
      assetName,
      height: size,
      fit: BoxFit.contain,
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
