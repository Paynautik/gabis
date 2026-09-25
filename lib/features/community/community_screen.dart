import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'ajo_screen.dart';
import 'escrow_screen.dart';
import 'resolution_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Community & Trust', style: TextStyle(fontWeight: FontWeight.w700)),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Ajo (Savings)'),
              Tab(text: 'Escrow'),
              Tab(text: 'Resolution'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AjoScreen(),
            EscrowScreen(),
            ResolutionScreen(),
          ],
        ),
      ),
    );
  }
}
