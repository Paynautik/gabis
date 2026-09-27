import 'dart:async';

import 'explore_strip.dart';
import '../../shared/widgets/scan_icon.dart';
import '../points/points_store.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/money.dart';
import '../../shared/models/transaction.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/coming_soon.dart';
import '../../shared/widgets/transaction_tile.dart';
import '../../shared/widgets/user_avatar.dart';
import '../notifications/notifications_store.dart';
import '../scan/scan_screen.dart';
import '../transfers/send_money_screen.dart';
import '../../shared/models/app_contact.dart';
import '../../shared/widgets/glowing_background.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedPeriod = '7D';
  bool _showPromoBanner = true;
  bool _showAllTransactions = false;
  bool _hideBalances = false;
  bool _showSecurityBanner = true;
  bool _isBalanceHidden = false;

  late PageController _pageController;
  int _currentSlide = 0;
  Timer? _carouselTimer;

  /// Kept next to the PageView children below; the autoplay timer reads it.
  static const _slideCount = 4;

  /// Set while the user is driving the carousel, so autoplay does not fight
  /// a manual swipe or a tapped dot.
  DateTime _lastManualNudge = DateTime.fromMillisecondsSinceEpoch(0);

  bool _autoAdvancing = false;

  void _pauseAutoplay() {
    if (_autoAdvancing) return;
    _lastManualNudge = DateTime.now();
  }

  @override
  void initState() {
    super.initState();

    // Points caught on the landing page before signing in land here, so the
    // first thing the user sees is that the catch was kept.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final claimed = ref.read(pointsProvider).justClaimed;
      if (claimed <= 0 || !mounted) return;
      ref.read(pointsProvider.notifier).acknowledgeClaim();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: const Color(0xFF101010),
        duration: const Duration(seconds: 6),
        content: Row(children: [
          const Icon(Icons.auto_awesome_rounded,
              size: 16, color: Color(0xFFD9FF43)),
          const SizedBox(width: 10),
          Expanded(
            child: Text('$claimed gabis points from the orbs added to your wallet.',
                style: const TextStyle(
                    color: Color(0xFFF4F0E8), fontWeight: FontWeight.w600)),
          ),
        ]),
        action: SnackBarAction(
          label: 'View',
          textColor: const Color(0xFFD9FF43),
          onPressed: () => Navigator.pushNamed(context, '/points'),
        ),
      ));
    });

    _pageController = PageController();
    _carouselTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (!_pageController.hasClients) return;
      if (DateTime.now().difference(_lastManualNudge).inSeconds < 10) return;
      // Never start a second animation on top of one already running.
      if (_autoAdvancing) return;
      final page = _pageController.page;
      if (page != null && (page - page.round()).abs() > 0.01) return;

      final next = (_currentSlide + 1) % _slideCount;
      _autoAdvancing = true;
      _pageController
          .animateToPage(
            next,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          )
          .whenComplete(() => _autoAdvancing = false);
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(totalBalanceNgnProvider);
    final accounts = ref.watch(accountsProvider);
    final transactions = ref.watch(transactionsProvider);

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 720;

    return Scaffold(
      body: GlowingBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Header Row (Search, Notifications, Profile)
              _buildHeader(context),
              
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // ================= NET WORTH SECTION =================
                    _buildNetWorthCard(balance),
                    const SizedBox(height: 24),
                    
                    // ================= ACCOUNTS SECTION =================
                    _buildAccountsSection(context, accounts),
                    const SizedBox(height: 24),
                    
                    // ================= PROMO BANNER =================
                    if (_showPromoBanner) ...[
                      _buildCarouselBanner(),
                      const SizedBox(height: 24),
                    ],
                    
                    // ================= QUICK ACTIONS =================
                    _buildQuickActionsSection(context),
                    const SizedBox(height: 24),
                    const ExploreStrip(),
                    const SizedBox(height: 24),
                    
                    // ================= STANDALONE SECURITY BANNER =================
                    if (_showSecurityBanner) ...[
                      _buildRealSecurityBanner(),
                      const SizedBox(height: 24),
                    ],
                    
                    // ================= BUSINESS INSIGHTS GATEWAY =================
                    _buildBusinessInsightsCard(context),
                    const SizedBox(height: 24),
                    
                    // ================= BOTTOM GRID =================
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 6, child: _buildTransactionsCard(transactions)),
                          const SizedBox(width: 24),
                          Expanded(flex: 4, child: _buildSpendingInsightsCard()),
                        ],
                      )
                    else ...[
                      _buildTransactionsCard(transactions),
                      const SizedBox(height: 24),
                      _buildSpendingInsightsCard(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Header ---
  Widget _buildHeader(BuildContext context) {
    final unread = ref.watch(unreadNotificationsProvider);
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: context.colors.scaffoldBg,
        border: Border(bottom: BorderSide(color: context.colors.border, width: 1.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Avatar + Hi, Name
          Row(
            children: [
              GestureDetector(
                onTap: () => showAvatarSheet(context),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: context.colors.bluePrimary.withValues(alpha: 0.3), width: 2),
                  ),
                  child: const UserAvatar(radius: 18),
                ),
              ),
              const SizedBox(width: 10),
              Text('Hi, ${ref.watch(userFirstNameProvider).toUpperCase()}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: context.colors.ink, letterSpacing: -0.3)),
            ],
          ),
          
          // Right side: Icons
          Row(
            children: [
              IconButton(
                onPressed: () => _showHelpSupportSheet(context),
                icon: Icon(Icons.headset_mic_rounded, color: context.colors.ink, size: 24),
              ),
              IconButton(
                onPressed: () => _openScanner(context),
                tooltip: 'Scan to pay',
                icon: ScanIcon(color: context.colors.ink, size: 24),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () => _showNotificationsSheet(context, ref),
                    icon: Icon(Icons.notifications_none_rounded, color: context.colors.ink, size: 26),
                  ),
                  if (unread > 0) Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: context.colors.scaffoldBg, width: 1.5),
                      ),
                      child: Text(unread > 99 ? '99+' : '$unread', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Net Worth Card ---
  Widget _buildNetWorthCard(Money balance) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withValues(alpha: 0.4),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Shield + Available Balance + Eye + History
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => setState(() => _isBalanceHidden = !_isBalanceHidden),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    const Text('Available Balance', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Icon(_isBalanceHidden ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.white, size: 16),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => showComingSoon(context, 'Transaction History'),
                child: Row(
                  children: const [
                    Text('Transaction History', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Middle Row: Big Balance + Add Money Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => setState(() => _isBalanceHidden = !_isBalanceHidden),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _isBalanceHidden ? '****' : balance.format(),
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.0),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 24),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showReceiveSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Text('+ Add Money', style: TextStyle(color: context.colors.bluePrimary, fontWeight: FontWeight.w900, fontSize: 13)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bottom Strip (Business Service)
          GestureDetector(
            onTap: () => _showBusinessInsights(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storefront_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      const Text("Business Service - Today's Sales: ", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                      Text(_isBalanceHidden ? '****' : '₦0.00', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Accounts Section ---
  Widget _buildAccountsSection(BuildContext context, List<dynamic> accounts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Accounts', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: context.colors.ink)),
            TextButton(
              // Accounts is a tab of the shell, not a coming-soon screen.
              onPressed: () =>
                  ref.read(homeTabProvider.notifier).state = HomeTab.accounts,
              child: Text('View all', style: TextStyle(color: context.colors.bluePrimary, fontWeight: FontWeight.w800, fontSize: 13)),
            ),
                      ],
        ),
        const SizedBox(height: 8),
        Row(
          children: accounts.map((a) {
            final isNgn = a.currency == 'NGN';
            final flag = isNgn ? '🇳🇬' : '🇺🇸';
            final name = isNgn ? 'NGN Account' : 'USD Account';
            final subtitle = isNgn ? 'Nigerian Naira' : 'US Dollar';
            final icon = isNgn ? Icon(Icons.wallet_rounded, color: Color(0xFF16A34A), size: 20) : Text('\$', style: TextStyle(color: context.colors.bluePrimary, fontWeight: FontWeight.w900, fontSize: 18));
            final iconBg = isNgn ? Color(0x1A16A34A) : context.colors.blueHighlight;

            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: a == accounts.last ? 0 : 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.colors.bgSoft,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: context.colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(flag, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 8),
                            Text(name, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: context.colors.ink)),
                          ],
                        ),
                        Theme(
                          data: Theme.of(context).copyWith(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                          child: PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.more_vert_rounded, color: context.colors.inkSoft, size: 18),
                            color: context.colors.bgSoft,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            onSelected: (value) {
                              if (value == 'View Statement') {
                                _showStatementSheet(context);
                              } else if (value == 'Hide Balance' || value == 'Show Balance') {
                                setState(() => _hideBalances = !_hideBalances);
                              } else if (value == 'Account Details') {
                                _showReceiveSheet(context);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(value: 'View Statement', child: Row(children: [Icon(Icons.receipt_long_rounded, color: context.colors.inkSoft, size: 18), SizedBox(width: 8), Text('View Statement', style: TextStyle(color: context.colors.ink))])),
                              PopupMenuItem(value: _hideBalances ? 'Show Balance' : 'Hide Balance', child: Row(children: [Icon(_hideBalances ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: context.colors.inkSoft, size: 18), SizedBox(width: 8), Text(_hideBalances ? 'Show Balance' : 'Hide Balance', style: TextStyle(color: context.colors.ink))])),
                              PopupMenuItem(value: 'Account Details', child: Row(children: [Icon(Icons.info_outline_rounded, color: context.colors.inkSoft, size: 18), SizedBox(width: 8), Text('Account Details', style: TextStyle(color: context.colors.ink))])),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_hideBalances ? '****' : a.balance.format(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: context.colors.ink, letterSpacing: -0.5)),
                            const SizedBox(height: 2),
                            Text(subtitle, style: TextStyle(color: context.colors.inkSoft, fontSize: 11.5, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(16)),
                          alignment: Alignment.center,
                          child: icon,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- Consolidated Carousel Banner ---
    // --- Standalone Real Virtual Card / Security Banner ---
  // --- Business Insights Gateway Card ---
  Widget _buildBusinessInsightsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.bgSoft,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F7F0), // Teal/green highlight
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Color(0xFF00B97A), // Official Business Green
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Business Insights',
                style: TextStyle(
                  color: context.colors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Label: Today's Sales
          Text(
            "Today's Sales",
            style: TextStyle(
              color: context.colors.inkSoft,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),

          // Value: ₦0.00
          Text(
            "₦0.00",
            style: TextStyle(
              color: context.colors.ink,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),

          // Grid: Transactions & Customers
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: context.colors.scaffoldBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.colors.border.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transactions',
                        style: TextStyle(
                          color: context.colors.inkSoft,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '0',
                        style: TextStyle(
                          color: context.colors.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: context.colors.scaffoldBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.colors.border.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customers',
                        style: TextStyle(
                          color: context.colors.inkSoft,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '0',
                        style: TextStyle(
                          color: context.colors.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Button: Manage Business
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                ref.read(isBusinessModeProvider.notifier).state = true;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B97A), // Shop Green
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Manage Business',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealSecurityBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: () => setState(() => _showSecurityBanner = false),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8), size: 16),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left text info
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.shield_rounded, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text('Virtual Platinum', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('• Secure & Instant', style: TextStyle(color: context.colors.inkSoft, fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Global Virtual Debit Card',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, letterSpacing: -0.3),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Spend internationally anywhere Visa is accepted with 0% FX fees and bank-grade 3D-Secure protection.',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.35, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/cards'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Manage Cards', style: TextStyle(color: context.colors.bluePrimary, fontSize: 13, fontWeight: FontWeight.w900)),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, color: context.colors.bluePrimary, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Right: Embedded Real 3D Virtual Card
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/cards'),
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(-0.08)
                    ..rotateZ(-0.02),
                  alignment: Alignment.center,
                  child: Container(
                    width: 175,
                    height: 110,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF090D16)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1D4ED8).withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top row: EMV Chip + NFC + Logo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                // Golden EMV Chip
                                Container(
                                  width: 22,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFFDF79), Color(0xFFC79224)],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFFE5B53A), width: 0.5),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.contactless_rounded, color: Colors.white70, size: 14),
                              ],
                            ),
                            const Text(
                              'GABIS',
                              style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                            ),
                          ],
                        ),
                        // Middle Card Number
                        const Text(
                          '•••• •••• •••• 4821',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        // Bottom row: Holder + Visa
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ref.watch(userCardNameProvider), style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 1),
                                const Text('08/29', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 6.5, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            // VISA Logo Mockup
                            const Text(
                              'VISA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildCarouselBanner() {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView(
            controller: _pageController,
            onPageChanged: (idx) {
              setState(() => _currentSlide = idx);
              _pauseAutoplay();
            },
            children: [
              // Slide 1: collections — the reason to switch to Business
              _buildCollectionsSlide(),
              // Slide 2: points and rewards
              _buildPointsSlide(),
              // Slide 3: gabis Promo (Pay Smarter, Live Better)
              _buildGabisPromoSlide(),
              // Slide 4: PayNautik, the parent product — last, so the app's own
              // features are what a signed-in user sees first.
              _buildPayrollSlide(),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slideCount, (index) {
            final isSel = _currentSlide == index;
            return GestureDetector(
              onTap: () {
                _pauseAutoplay();
                if (_pageController.hasClients) {
                  _pageController.jumpToPage(index);
                  setState(() => _currentSlide = index);
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isSel ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSel
                        ? context.colors.bluePrimary
                        : context.colors.inkSoft.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // --- Slide 4: PayNautik, the parent product ---
  Widget _buildPayrollSlide() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0C2C23), Color(0xFF101010)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.45)),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text('GLOBAL PAYROLL',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                              color: Color(0xFF06231B))),
                    ),
                    const SizedBox(width: 8),
                    const Text('paynautik.com',
                        style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 12,
                            fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('Payroll that lands in 150+ countries.',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        height: 1.15,
                        color: Colors.white)),
                const SizedBox(height: 5),
                const Text(
                  'PayNautik is the parent of gabis — smart contracts pay your whole team at once, in their own currency.',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Color(0xB3FFFFFF), fontSize: 11.5, height: 1.4),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final url = Uri.parse('https://paynautik.com');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9FF43),
                    foregroundColor: const Color(0xFF101010),
                    minimumSize: const Size(150, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.launch_rounded, size: 13),
                  label: const Text('Launch PayNautik',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            flex: 3,
            child: _BannerPhoto(
              asset: 'assets/images/usecase_freelancers.jpg',
              scrim: Color(0xFF101010),
            ),
          ),
        ],
      ),
    );
  }


  // --- Slide 2: get paid what you are owed ---
  Widget _buildCollectionsSlide() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF101010), Color(0xFF1C2416)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9FF43),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text('FOR BUSINESS',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                          color: Color(0xFF101010))),
                ),
                const SizedBox(height: 10),
                const Text('Get paid what you are owed.',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        height: 1.15,
                        color: Colors.white)),
                const SizedBox(height: 5),
                const Text(
                  'Connect your business, import your debtors, and let gabis chase them — reminders, a call in their own language, then a payment link.',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Color(0xB3FFFFFF), fontSize: 11.5, height: 1.4),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () =>
                      ref.read(isBusinessModeProvider.notifier).state = true,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9FF43),
                    foregroundColor: const Color(0xFF101010),
                    minimumSize: const Size(150, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.business_center_rounded, size: 13),
                  label: const Text('Open gabis Business',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            flex: 3,
            child: _BannerPhoto(
              asset: 'assets/images/banner_collections.jpg',
              scrim: Color(0xFF101010),
              alignment: Alignment(-0.15, 0),
            ),
          ),
        ],
      ),
    );
  }


  // --- Slide 3: points you can actually spend ---
  Widget _buildPointsSlide() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B2F12), Color(0xFF101010)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD9FF43).withValues(alpha: 0.35)),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9FF43),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text('GABIS POINTS',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                              color: Color(0xFF101010))),
                    ),
                    const SizedBox(width: 8),
                    Consumer(
                      builder: (context, ref, _) => Text(
                        '${ref.watch(pointsProvider).balance} pts',
                        style: const TextStyle(
                            color: Color(0xFFD9FF43),
                            fontSize: 12,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('Earn points. Spend them on real things.',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        height: 1.15,
                        color: Colors.white)),
                const SizedBox(height: 5),
                const Text(
                  'Every transfer, bill and invoice paid earns points — trade them for airtime, data, fee-free transfers and cashback.',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Color(0xB3FFFFFF), fontSize: 11.5, height: 1.4),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/points'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9FF43),
                    foregroundColor: const Color(0xFF101010),
                    minimumSize: const Size(140, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.redeem_rounded, size: 13),
                  label: const Text('Redeem points',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            flex: 3,
            child: _BannerPhoto(
              asset: 'assets/images/african_person_mockup.jpg',
              scrim: Color(0xFF101010),
              alignment: Alignment(0.1, 0),
            ),
          ),
        ],
      ),
    );
  }

  // --- Slide 4: the copilot ---
  Widget _buildGabisPromoSlide() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B1740), Color(0xFF101010)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF4C45FF).withValues(alpha: 0.45)),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4C45FF),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text('AI COPILOT',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                          color: Colors.white)),
                ),
                const SizedBox(height: 10),
                const Text('Ask where your money went.',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        height: 1.15,
                        color: Colors.white)),
                const SizedBox(height: 4),
                const Text(
                  'The copilot answers from your own transactions — what is recurring, what changed, what you can safely spend.',
                  style: TextStyle(
                      color: Color(0xB3FFFFFF),
                      fontSize: 11.5,
                      height: 1.4,
                      fontWeight: FontWeight.w500),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  // Already inside the app — send them somewhere useful rather
                  // than inviting them to visit the site they are standing on.
                  onPressed: () =>
                      ref.read(homeTabProvider.notifier).state = HomeTab.copilot,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9FF43),
                    foregroundColor: const Color(0xFF101010),
                    minimumSize: const Size(140, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.auto_awesome_rounded, size: 13),
                  label: const Text('Ask the copilot', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            flex: 3,
            child: _BannerPhoto(
              asset: 'assets/images/usecase_creators.jpg',
              scrim: Color(0xFF101010),
            ),
          ),
        ],
      ),
    );
  }

  // --- Slide 3: Virtual Platinum Debit Card ---
  Widget _buildVirtualCardSlide() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shield_rounded, color: Colors.white, size: 10),
                          SizedBox(width: 4),
                          Text('Virtual Platinum', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Global Virtual Visa Card',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, letterSpacing: -0.3),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Spend internationally anywhere Visa is accepted with 0% markup and 3D-Secure locks.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, height: 1.3, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed('/cards'),
                  child: Row(
                    children: [
                      Text('Manage Cards', style: TextStyle(color: context.colors.bluePrimary, fontSize: 12, fontWeight: FontWeight.w900)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, color: context.colors.bluePrimary, size: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Embedded Visa Card graphic
          Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(-0.06)
              ..rotateZ(-0.02),
            alignment: Alignment.center,
            child: Container(
              width: 120,
              height: 76,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF090D16)],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 14,
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFFFDF79), Color(0xFFC79224)]),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const Text('GABIS', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const Text('•••• 4821', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(ref.watch(userCardNameProvider), style: const TextStyle(color: Colors.white, fontSize: 5.5, fontWeight: FontWeight.w800)),
                      const Text('VISA', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  // --- Quick Actions Grid ---
  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: context.colors.ink)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
          children: [
            _buildActionCard(
              icon: Icons.north_east_rounded,
              title: 'Send Money',
              subtitle: 'Transfer to anyone',
              color: const Color(0xFF4B45F5),
              bg: const Color(0xFF4B45F5),
              onTap: () => Navigator.of(context).pushNamed('/send'),
            ),
            _buildActionCard(
              icon: Icons.download_rounded,
              title: 'Receive Money',
              subtitle: 'Get paid easily',
              color: const Color(0xFF16123A),
              bg: const Color(0xFF16123A),
              onTap: () => _showReceiveSheet(context),
            ),
            _buildActionCard(
              icon: Icons.credit_card_rounded,
              title: 'Manage Cards',
              subtitle: 'View and freeze',
              color: const Color(0xFF7C6CF0),
              bg: const Color(0xFF7C6CF0),
              onTap: () => Navigator.of(context).pushNamed('/cards'),
            ),
            _buildActionCard(
              icon: Icons.swap_horiz_rounded,
              title: 'Exchange',
              subtitle: 'Convert currency',
              color: const Color(0xFFEF7F5D),
              bg: const Color(0xFFEF7F5D),
              onTap: () => Navigator.of(context).pushNamed('/fx'),
            ),
            _buildActionCard(
              icon: Icons.receipt_long_rounded,
              title: 'Bills',
              subtitle: 'Pay utilities',
              color: const Color(0xFF0F9D6B),
              bg: const Color(0xFF0F9D6B),
              onTap: () => Navigator.of(context).pushNamed('/bills'),
            ),
                      ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            // Solid brand colour with a white icon: a 10% tint on the page's
            // soft background read as grey. The shadow is neutral and tight.
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(color: Color(0x2616123A), blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: context.colors.ink, letterSpacing: -0.2),
          ),
        ],
      ),
    );
  }

  // --- paynautik.com Payroll Banner ---
  Widget _buildSecurityBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: () => setState(() => _showSecurityBanner = false),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8), size: 16),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left text info
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.hub_rounded, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text('GLOBAL PAYROLL', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('• paynautik.com', style: TextStyle(color: context.colors.inkSoft, fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Frictionless Global Payroll',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, letterSpacing: -0.3),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Automate salary disbursements across 150+ countries. Let our smart contracts handle the complexity of multi-currency payouts instantly with zero hidden fees.',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.35, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () async {
                        final url = Uri.parse('https://paynautik.com');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not launch paynautik.com')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Launch PayNautik', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                          SizedBox(width: 4),
                          Icon(Icons.launch_rounded, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Right: Embedded Global Payout / Smart Contract graphic
              Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(-0.06)
                  ..rotateZ(-0.02),
                alignment: Alignment.center,
                child: Container(
                  width: 160,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E1E38), Color(0xFF0F0F1E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Node connection lines
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _PayrollNodesPainter(),
                        ),
                      ),
                      // Overlay currency badges
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.sync_alt_rounded, color: Color(0xFF10B981), size: 24),
                            ),
                            const SizedBox(height: 8),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _CurrencyBadge('USD', Colors.blue),
                                SizedBox(width: 4),
                                _CurrencyBadge('EUR', Colors.purple),
                                SizedBox(width: 4),
                                _CurrencyBadge('NGN', Colors.green),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Transactions feed ---
  Widget _buildTransactionsCard(List<AppTransaction> transactions) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.bgSoft,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Transactions', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: context.colors.ink)),
              TextButton(
                onPressed: () => setState(() => _showAllTransactions = !_showAllTransactions),
                child: Text(_showAllTransactions ? 'View less' : 'View all', style: TextStyle(color: context.colors.bluePrimary, fontWeight: FontWeight.w800, fontSize: 12.5)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...transactions.take(_showAllTransactions ? transactions.length : 3).map((tx) => TransactionTile(transaction: tx)),
        ],
      ),
    );
  }

  // --- Spending Insights ---

  /// What the period chip offers, and how far back each one reaches.
  static const _spendPeriods = ['This week', 'This month', 'Last 3 months', 'This year'];

  DateTime _spendCutoff(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'This week':
        return DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
      case 'Last 3 months':
        return DateTime(now.year, now.month - 2, 1);
      case 'This year':
        return DateTime(now.year, 1, 1);
      case 'This month':
      default:
        return DateTime(now.year, now.month, 1);
    }
  }

  /// Money out, grouped by what it was spent on. Transfers between the user's
  /// own accounts are not spending, and neither is anything that failed.
  List<_SpendSlice> _spendBreakdown(List<AppTransaction> transactions) {
    final cutoff = _spendCutoff(_selectedPeriod);
    final totals = <String, int>{};

    for (final tx in transactions) {
      if (tx.isCredit) continue;
      if (tx.status == TransactionStatus.failed ||
          tx.status == TransactionStatus.reversed) continue;
      if (tx.createdAt.isBefore(cutoff)) continue;

      final label = _spendCategory(tx);
      totals[label] = (totals[label] ?? 0) + tx.amount.minorUnits;
    }

    final slices = totals.entries
        .map((e) => _SpendSlice(e.key, e.value, _spendColor(e.key)))
        .toList()
      ..sort((a, b) => b.minorUnits.compareTo(a.minorUnits));

    return slices;
  }

  String _spendCategory(AppTransaction tx) {
    switch (tx.type) {
      case TransactionType.cardPayment:
        return 'Card spending';
      case TransactionType.billPayment:
        return 'Bills';
      case TransactionType.transfer:
        return 'Transfers';
      case TransactionType.withdrawal:
        return 'Withdrawals';
      case TransactionType.fx:
        return 'Currency swaps';
      case TransactionType.fee:
        return 'Fees';
      case TransactionType.deposit:
        return 'Deposits';
    }
  }

  Color _spendColor(String category) {
    switch (category) {
      case 'Card spending':
        return context.colors.bluePrimary;
      case 'Bills':
        return const Color(0xFF7C4DFF);
      case 'Transfers':
        return const Color(0xFF12B76A);
      case 'Withdrawals':
        return const Color(0xFFF79009);
      case 'Currency swaps':
        return const Color(0xFF06AED4);
      default:
        return const Color(0xFF98A2B3);
    }
  }

  Widget _buildSpendingInsightsCard() {
    final currency = ref.watch(accountsProvider).isEmpty
        ? 'NGN'
        : ref.watch(accountsProvider).first.currency;
    final slices = _spendBreakdown(ref.watch(transactionsProvider));
    final total = slices.fold<int>(0, (sum, s) => sum + s.minorUnits);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.bgSoft,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Spending Insights', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: context.colors.ink)),
              PopupMenuButton<String>(
                tooltip: 'Change period',
                initialValue: _selectedPeriod,
                onSelected: (value) => setState(() => _selectedPeriod = value),
                itemBuilder: (_) => _spendPeriods
                    .map((p) => PopupMenuItem(value: p, child: Text(p)))
                    .toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: context.colors.scaffoldBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: context.colors.border)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_selectedPeriod, style: TextStyle(color: context.colors.inkSoft, fontSize: 11, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, color: context.colors.inkSoft, size: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (slices.isEmpty)
            _buildSpendingEmptyState()
          else
            Row(
              children: [
                SizedBox(
                  width: 110,
                  height: 110,
                  child: CustomPaint(
                    painter: _DonutChartPainter(
                      context: context,
                      slices: slices,
                      total: Money(minorUnits: total, currency: currency),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      // Four categories is as much as this card can show
                      // without the rows becoming unreadable.
                      for (final slice in slices.take(4)) ...[
                        _SpendItemRow(
                          slice.label,
                          Money(minorUnits: slice.minorUnits, currency: currency)
                              .format(),
                          '${((slice.minorUnits / total) * 100).round()}%',
                          slice.color,
                        ),
                        if (slice != slices.take(4).last)
                          const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Nothing spent in this period is a fact worth stating plainly, rather than
  /// a chart of somebody else's numbers.
  Widget _buildSpendingEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.colors.blueHighlight,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.pie_chart_outline_rounded,
                    color: context.colors.bluePrimary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nothing spent ${_selectedPeriod.toLowerCase()}',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            color: context.colors.ink)),
                    const SizedBox(height: 2),
                    Text(
                        'Your categories appear here as soon as money leaves the account.',
                        style: TextStyle(
                            color: context.colors.inkSoft,
                            fontSize: 11.5,
                            height: 1.35)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Add Money sheet ---
  void _showAddMoneySheet(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: '10000');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Money',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black),
              ),
              const SizedBox(height: 8),
              const Text('Enter amount to fund your NGN account', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black),
                decoration: const InputDecoration(
                  prefixText: '₦ ',
                  suffixText: 'NGN',
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: context.colors.blueHighlight, borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.credit_card_rounded, color: context.colors.bluePrimary),
                ),
                title: const Text('Visa Debit **** 4821', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: Colors.black)),
                subtitle: const Text('Instant funding', style: TextStyle(fontSize: 12)),
                trailing: Icon(Icons.check_circle_rounded, color: context.colors.bluePrimary),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final text = controller.text;
                  final amount = double.tryParse(text) ?? 0.0;
                  if (amount > 0) {
                    final minorUnits = (amount * 100).toInt();
                    ref.read(accountsProvider.notifier).addBalance('NGN', minorUnits);
                    ref.read(transactionsProvider.notifier).addTransaction(
                          AppTransaction(
                            id: 'dep_${DateTime.now().millisecondsSinceEpoch}',
                            type: TransactionType.deposit,
                            status: TransactionStatus.completed,
                            amount: Money(minorUnits: minorUnits, currency: 'NGN'),
                            description: 'Card deposit',
                            counterparty: 'Visa **** 4821',
                            createdAt: DateTime.now(),
                            isCredit: true,
                          ),
                        );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: context.colors.success,
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white),
                            const SizedBox(width: 10),
                            Text('Funded ₦${amount.toStringAsFixed(2)} successfully!'),
                          ],
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Confirm Deposit'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBusinessInsights(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFF00B876).withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.storefront_rounded, color: Color(0xFF00B876)),
                  ),
                  const SizedBox(width: 12),
                  const Text('Business Insights', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF101828))),
                ],
              ),
              const SizedBox(height: 24),
              const Text("Today's Sales", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF667085))),
              const SizedBox(height: 8),
              const Text('₦0.00', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF101828))),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Transactions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF667085))),
                          SizedBox(height: 4),
                          Text('0', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF101828))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Customers', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF667085))),
                          SizedBox(height: 4),
                          Text('0', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF101828))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B876),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Manage Business', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }


  // --- Receive Details sheet ---
  void _showStatementSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Account Statements', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black)),
                    IconButton(icon: const Icon(Icons.close_rounded, color: Colors.grey), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatementRow(context, 'August 2026', 'PDF • 124 KB'),
                const Divider(height: 32),
                _buildStatementRow(context, 'July 2026', 'PDF • 140 KB'),
                const Divider(height: 32),
                _buildStatementRow(context, 'June 2026', 'PDF • 118 KB'),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatementRow(BuildContext context, String month, String details) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0x1A1858F2), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF1858F2), size: 20),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(month, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 2),
                Text(details, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading statement for ' + month + '...')));
          },
          icon: const Icon(Icons.download_rounded, color: Color(0xFF1858F2)),
        ),
      ],
    );
  }

void _showReceiveSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Receive Money',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black),
              ),
              const SizedBox(height: 16),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: context.colors.blueHighlight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.bluePrimary, width: 2.0),
                ),
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: 36,
                  itemBuilder: (context, index) {
                    final isFilled = (index * 3 + 7) % 5 == 0 || index % 6 == 0 || index < 6 || index % 6 == 5;
                    return Container(
                      decoration: BoxDecoration(
                        color: isFilled ? context.colors.bluePrimary : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const _DetailRow('Bank Name', 'gabis Partner Bank'),
                    const SizedBox(height: 8),
                    const _DetailRow('Account Number', '9928371102'),
                    const SizedBox(height: 8),
                    _DetailRow('Account Name', ref.watch(userNameProvider)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                    text: 'Bank: gabis Partner Bank\nAcct: 9928371102\n'
                        'Name: ${ref.read(userNameProvider)}',
                  ));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account details copied to clipboard!'),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copy Account Details'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 13)),
        Text(value, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 13.5)),
      ],
    );
  }
}


/// A photograph filling the right of a promo banner, with a scrim on the
/// inner edge so the headline beside it stays readable.
class _BannerPhoto extends StatelessWidget {
  final String asset;
  final Color scrim;
  final Alignment alignment;

  const _BannerPhoto({
    required this.asset,
    required this.scrim,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(asset, fit: BoxFit.cover, alignment: alignment),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  scrim.withValues(alpha: .55),
                  scrim.withValues(alpha: .0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockCard extends StatelessWidget {
  final Color color;
  const _MockCard({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 34,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24),
      ),
    );
  }
}


  // --- Header Modals ---
  void _showHelpSupportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Help & Support', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF101828))),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF1858F2).withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF1858F2))),
                title: const Text('Live Chat', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: const Text('Typically replies in 2 mins', style: TextStyle(fontSize: 11)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF16A34A).withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.article_rounded, color: Color(0xFF16A34A))),
                title: const Text('FAQs', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: const Text('Read our help articles', style: TextStyle(fontSize: 11)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  /// Opens the camera, and on a good code goes straight to the transfer with
  /// the payee filled in.
  Future<void> _openScanner(BuildContext context) async {
    final payee = await Navigator.push<ScannedPayee>(
      context,
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
    if (payee == null || !context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SendMoneyScreen(
          payee: AppContact(
            id: 'scan-${payee.account}',
            name: payee.name ?? 'Account ${payee.account}',
            phone: payee.account,
            hasGabis: true,
          ),
          amountMinor: payee.amountMinor,
        ),
      ),
    );
  }

  /// Real notifications: money that moved, points that landed, and whether the
  /// account still needs verifying. Opening the sheet is what marks them read.
  void _showNotificationsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.scaffoldBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Consumer(
        builder: (sheetContext, ref, _) {
          final items = ref.watch(notificationsProvider);
          final seen = ref.watch(notificationsSeenProvider);

          return SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.7,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Notifications',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: sheetContext.colors.ink)),
                      if (items.any((n) => n.at.isAfter(seen)))
                        TextButton(
                          onPressed: () => ref
                              .read(notificationsSeenProvider.notifier)
                              .markAllRead(),
                          child: const Text('Mark all as read'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: items.isEmpty
                        ? _notificationsEmptyState(sheetContext)
                        : ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 4),
                            itemBuilder: (_, index) {
                              final item = items[index];
                              final isNew = item.at.isAfter(seen);

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: item.tint.withValues(alpha: 0.1),
                                      shape: BoxShape.circle),
                                  child: Icon(item.icon, color: item.tint, size: 20),
                                ),
                                title: Row(
                                  children: [
                                    Flexible(
                                      child: Text(item.title,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: sheetContext.colors.ink)),
                                    ),
                                    if (isNew) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                            color: Color(0xFFEF4444),
                                            shape: BoxShape.circle),
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: Text(item.body,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: sheetContext.colors.inkSoft)),
                                trailing: Text(item.age,
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: sheetContext.colors.inkSoft)),
                                onTap: () =>
                                    _openNotification(sheetContext, ref, item),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).whenComplete(
        () => ref.read(notificationsSeenProvider.notifier).markAllRead());
  }

  Widget _notificationsEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none_rounded,
              size: 44, color: context.colors.inkSoft),
          const SizedBox(height: 12),
          Text('Nothing yet',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: context.colors.ink)),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Money in and out, points you earn and anything about your account will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12, height: 1.4, color: context.colors.inkSoft),
            ),
          ),
        ],
      ),
    );
  }

  /// A notification that leads somewhere takes the user there.
  void _openNotification(
      BuildContext context, WidgetRef ref, AppNotification item) {
    Navigator.pop(context);
    if (item.route != null) {
      Navigator.pushNamed(context, item.route!);
      return;
    }
    if (item.tab != null) {
      ref.read(homeTabProvider.notifier).state = item.tab!;
    }
  }

class _DayLabel extends StatelessWidget {
  final String text;
  const _DayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: context.colors.inkSoft, fontSize: 9, fontWeight: FontWeight.w800),
    );
  }
}

class _SpendItemRow extends StatelessWidget {
  final String label;
  final String value;
  final String percentage;
  final Color color;

  const _SpendItemRow(this.label, this.value, this.percentage, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: context.colors.inkSoft, fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
            Text(percentage, style: TextStyle(color: context.colors.inkSoft, fontSize: 10, fontWeight: FontWeight.w600)),
                      ],
        ),
      ],
    );
  }
}

// --- Custom Painters for Charts ---

class _SvgTrendLinePainter extends CustomPainter {
  final Color lineColor;
  _SvgTrendLinePainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final fillPath = Path();

    // Map the NextJS SVG coordinates dynamically to the size of the canvas
    // Width map: 0 to 1100 -> size.width
    // Height map: 12 to 130 -> size.height (reversing scale: 12 is top, 130 is bottom)
    
    double getX(double x) => (x / 1100.0) * size.width;
    double getY(double y) => size.height - ((130.0 - y) / 130.0) * size.height * 0.9 - size.height * 0.05;

    path.moveTo(getX(0), getY(95));
    fillPath.moveTo(getX(0), size.height);
    fillPath.lineTo(getX(0), getY(95));

    // NextJS exact Cubic curves:
    // C 70 96 85 96 130 90
    path.cubicTo(getX(70), getY(96), getX(85), getY(96), getX(130), getY(90));
    fillPath.cubicTo(getX(70), getY(96), getX(85), getY(96), getX(130), getY(90));

    // S 230 80 280 84 (S is smooth cubic; implies control point is reflection of previous)
    path.cubicTo(getX(175), getY(84), getX(230), getY(80), getX(280), getY(84));
    fillPath.cubicTo(getX(175), getY(84), getX(230), getY(80), getX(280), getY(84));

    // S 365 89 410 80
    path.cubicTo(getX(330), getY(88), getX(365), getY(89), getX(410), getY(80));
    fillPath.cubicTo(getX(330), getY(88), getX(365), getY(89), getX(410), getY(80));

    // S 500 70 550 72
    path.cubicTo(getX(455), getY(71), getX(500), getY(70), getX(550), getY(72));
    fillPath.cubicTo(getX(455), getY(71), getX(500), getY(70), getX(550), getY(72));

    // S 630 78 680 70
    path.cubicTo(getX(600), getY(74), getX(630), getY(78), getX(680), getY(70));
    fillPath.cubicTo(getX(600), getY(74), getX(630), getY(78), getX(680), getY(70));

    // S 750 45 820 48
    path.cubicTo(getX(730), getY(62), getX(750), getY(45), getX(820), getY(48));
    fillPath.cubicTo(getX(730), getY(62), getX(750), getY(45), getX(820), getY(48));

    // S 900 48 960 41
    path.cubicTo(getX(890), getY(51), getX(900), getY(48), getX(960), getY(41));
    fillPath.cubicTo(getX(890), getY(51), getX(900), getY(48), getX(960), getY(41));

    // S 1030 22 1080 12
    path.cubicTo(getX(1020), getY(34), getX(1030), getY(22), getX(1080), getY(12));
    fillPath.cubicTo(getX(1020), getY(34), getX(1030), getY(22), getX(1080), getY(12));

    fillPath.lineTo(getX(1080), size.height);
    fillPath.close();

    // Paint line
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    
    // Paint gradient area
    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [lineColor.withValues(alpha: 0.16), lineColor.withValues(alpha: 0.0)],
    );
    final fillPaint = Paint()
      ..shader = fillGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw end circle point
    final pointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final pointStrokePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(Offset(getX(1080), getY(12)), 5.0, pointPaint);
    canvas.drawCircle(Offset(getX(1080), getY(12)), 5.0, pointStrokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// One category's share of what was spent.
class _SpendSlice {
  final String label;
  final int minorUnits;
  final Color color;

  const _SpendSlice(this.label, this.minorUnits, this.color);
}

class _DonutChartPainter extends CustomPainter {
  final BuildContext context;
  final List<_SpendSlice> slices;
  final Money total;

  _DonutChartPainter({
    required this.context,
    required this.slices,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total.minorUnits <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius - 7);

    double startAngle = -pi / 2; // 12 o'clock
    for (final slice in slices) {
      paint.color = slice.color;
      final sweep = 2 * pi * (slice.minorUnits / total.minorUnits);
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }

    final label = TextPainter(
      text: TextSpan(
        text: 'Total spent',
        style: TextStyle(color: context.colors.inkSoft, fontSize: 10, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // The amount is rounded to whole units: the pennies do not fit, and this
    // is a summary rather than a statement.
    final value = TextPainter(
      text: TextSpan(
        text: '${total.symbol}${intl.NumberFormat('#,##0').format(total.major)}',
        style: TextStyle(color: context.colors.ink, fontSize: 13, fontWeight: FontWeight.w900),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    label.paint(canvas, center - Offset(label.width / 2, 12));
    value.paint(canvas, center - Offset(value.width / 2, -4));
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter old) =>
      old.total.minorUnits != total.minorUnits ||
      old.slices.length != slices.length;
}

class _CurrencyBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _CurrencyBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _PayrollNodesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Draw grid nodes
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.3), paint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), paint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.7, size.height), paint);

    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.3), 3, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.3), 3, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.7), 3, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.7), 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
