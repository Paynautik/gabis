import 'dart:convert';
import '../business/business_dashboard_screen.dart';
import '../../shared/widgets/nautik_logo.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../accounts/accounts_screen.dart';
import '../cards/cards_screen.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';
import 'sidebar_screens.dart';
import '../copilot/copilot_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/app_providers.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    AccountsScreen(),
    CardsScreen(),
    ProfileScreen(),
    TransactionsScreen(),
    AnalyticsScreen(),
    BeneficiariesScreen(),
    SettingsScreen(),
    SupportScreen(),
    CopilotScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isBusinessMode = ref.watch(isBusinessModeProvider);
    if (isBusinessMode) {
      return const BusinessDashboardScreen();
    }
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 720;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // NextJS-style Sidebar Navigation
            Container(
              width: 260,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A), // Dark obsidian sidebar
                border: Border(right: BorderSide(color: context.colors.border, width: 1.0)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: NautikLogoMark(size: 34, isWhite: true),
                    ),
                  ),
                  const SizedBox(height: 36),
                  
                  // Navigation Items
                  Expanded(
                    child: ListView(
                      children: [
                        _buildSidebarItem(0, Icons.home_rounded, 'Dashboard'),
                        _buildSidebarItem(9, Icons.auto_awesome_rounded, 'Copilot'),
                        _buildSidebarItem(1, Icons.wallet_rounded, 'Accounts'),
                        _buildSidebarItem(2, Icons.credit_card_rounded, 'Cards'),
                        _buildSidebarItem(4, Icons.receipt_long_rounded, 'Transactions'),
                        _buildSidebarItem(5, Icons.bar_chart_rounded, 'Analytics'),
                        _buildSidebarItem(6, Icons.people_rounded, 'Beneficiaries'),
                        _buildSidebarItem(7, Icons.settings_rounded, 'Settings'),
                        _buildSidebarItem(8, Icons.help_outline_rounded, 'Support'),
                        
                        const SizedBox(height: 24),
                        // Invite card inside sidebar
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E283F), Color(0xFF0F172A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Invite & Earn',
                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(color: context.colors.bluePrimary, shape: BoxShape.circle),
                                    child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Invite friends and earn rewards',
                                style: TextStyle(color: context.colors.inkSoft, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => _showInviteDialog(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.colors.bluePrimary,
                                  minimumSize: const Size.fromHeight(36),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Invite Now', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // User Details Box (Collapsible)
                  Theme(
                    data: Theme.of(context).copyWith(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                    child: PopupMenuButton<String>(
                      offset: const Offset(0, -100),
                      color: const Color(0xFF1E283F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      onSelected: (value) {
                        if (value == 'settings') {
                          _showSettingsDialog(context);
                        } else if (value == 'logout') {
                          ref.read(authStateProvider.notifier).state = false;
                          Navigator.of(context).pushReplacementNamed('/landing');
                        } else if (value == 'business') {
                          ref.read(isBusinessModeProvider.notifier).state = true;
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'settings',
                          child: Row(
                            children: [
                              Icon(Icons.settings_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'business',
                          child: Row(
                            children: [
                              Icon(Icons.business_center_rounded, color: Colors.white70, size: 18),
                              SizedBox(width: 8),
                              Text('Switch to Business', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(height: 1),
                        PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                              SizedBox(width: 8),
                              Text('Log Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E283F),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: context.colors.bluePrimary.withValues(alpha: 0.2),
                              backgroundImage: ref.watch(userAvatarProvider) != null
                                  ? MemoryImage(base64Decode(ref.watch(userAvatarProvider)!))
                                  : null,
                              child: ref.watch(userAvatarProvider) == null
                                  ? const Text('R', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900))
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Raphael Momoh',
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white),
                                  ),
                                  // Premium user removed and hidden in settings per request
                                ],
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_up_rounded, color: const Color(0xFF94A3B8), size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Centered Main Content Area
            Expanded(
              child: Container(
                color: context.colors.scaffoldBg,
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 1000),
                  child: _screens[_index],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Mobile navigation bottom bar
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Accounts',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined),
            selectedIcon: Icon(Icons.credit_card),
            label: 'Cards',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }


  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: context.colors.bgSoft,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Settings', style: TextStyle(color: context.colors.ink, fontSize: 20, fontWeight: FontWeight.w900)),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: context.colors.inkSoft),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.bluePrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.colors.bluePrimary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.workspace_premium_rounded, color: context.colors.bluePrimary, size: 32),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Premium User', style: TextStyle(color: context.colors.bluePrimary, fontWeight: FontWeight.w900, fontSize: 16)),
                          const SizedBox(height: 2),
                          Text('All features unlocked', style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: Icon(Icons.dark_mode_rounded, color: context.colors.ink),
                  title: Text('Dark Mode', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700)),
                  trailing: Switch(
                    value: ref.watch(themeModeProvider) == ThemeMode.dark,
                    onChanged: (val) {
                      ref.read(themeModeProvider.notifier).state = val ? ThemeMode.dark : ThemeMode.light;
                    },
                    activeThumbColor: context.colors.bluePrimary,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.business_center_rounded, color: context.colors.ink),
                  title: Text('Business Account', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(isBusinessModeProvider.notifier).state = true;
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgSoft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: context.colors.bluePrimary.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.card_giftcard_rounded, color: context.colors.bluePrimary, size: 22),
            ),
            const SizedBox(width: 12),
            Text('Invite & Earn', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Share your referral code with friends and earn ₦5,000 / \$5 for every friend who signs up and funds their account!',
                style: TextStyle(color: context.colors.inkSoft, fontSize: 13)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.colors.scaffoldBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('RAPHAEL2026', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5, color: Color(0xFF10B981))),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Referral link copied to clipboard!')));
                    },
                    child: Row(
                      children: [
                        Text('Copy', style: TextStyle(color: context.colors.bluePrimary, fontWeight: FontWeight.w800, fontSize: 13)),
                        const SizedBox(width: 4),
                        Icon(Icons.copy_rounded, color: context.colors.bluePrimary, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String label) {
    final isSelected = _index == index;
    return GestureDetector(
      onTap: () => setState(() => _index = index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.bluePrimary.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.scaffoldBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction_rounded, size: 64, color: context.colors.bluePrimary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              '$title',
              style: TextStyle(color: context.colors.ink, fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'This module is being built.',
              style: TextStyle(color: context.colors.inkSoft, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
