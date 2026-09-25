import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ResolutionScreen extends StatelessWidget {
  const ResolutionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.gavel_rounded, size: 64, color: context.colors.inkSoft),
          const SizedBox(height: 16),
          const Text('No active disputes.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Your transactions are running smoothly.', style: TextStyle(color: context.colors.inkSoft)),
        ],
      ),
    );
  }
}
