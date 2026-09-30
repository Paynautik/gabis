import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/coming_soon.dart';
import '../../shared/models/payment_card.dart';
import '../../shared/widgets/glowing_background.dart';
import 'metal_card_front.dart';

class CardsScreen extends ConsumerStatefulWidget {
  const CardsScreen({super.key});

  @override
  ConsumerState<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends ConsumerState<CardsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFront = true;
  int _selectedSkinIndex = 0;

  final List<Map<String, dynamic>> _cardSkins = [
    {
      'name': 'Metal Obsidian',
      'gradient': AppTheme.darkMetalGradient,
      'textColor': Colors.white,
      'accentColor': const Color(0xFF94A3B8),
      'isDark': true,
    },
    {
      'name': 'Gold Edition',
      'gradient': AppTheme.goldGradient,
      'textColor': const Color(0xFF3E2723),
      'accentColor': const Color(0xFF5D4037),
      'isDark': false,
    },
    {
      'name': 'Platinum Ultra',
      'gradient': AppTheme.platinumGradient,
      'textColor': const Color(0xFF1E293B),
      'accentColor': const Color(0xFF64748B),
      'isDark': false,
    },
    {
      'name': 'Holo Neon',
      'gradient': const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF007F), Color(0xFF7F00FF), Color(0xFF00F0FF)],
      ),
      'textColor': Colors.white,
      'accentColor': Colors.white70,
      'isDark': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_isFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(cardsProvider);
    if (cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cards')),
        body: const Center(child: Text('No cards active')),
      );
    }
    final card = cards.first; // Upgrade primary card
    final skin = _cardSkins[_selectedSkinIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => showComingSoon(context, 'Virtual Card creation'),
          ),
        ],
      ),
      body: GlowingBackground(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            const SizedBox(height: 12),
          // 3D Flip Card Container
          GestureDetector(
            onTap: _toggleFlip,
            child: AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, child) {
                final angle = _flipAnimation.value;
                final isShowingFront = angle < (pi / 2);

                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // perspective
                    ..rotateY(angle),
                  alignment: Alignment.center,
                  child: isShowingFront
                      ? _buildCardFront(card, skin)
                      : Transform(
                          transform: Matrix4.identity()..rotateY(pi),
                          alignment: Alignment.center,
                          child: _buildCardBack(card, skin),
                        ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          // Card Skins horizontal list
          Text(
            'CARD SKIN',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.inkSoft, letterSpacing: 1.0),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _cardSkins.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedSkinIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSkinIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? context.colors.bluePrimary : context.colors.bgSoft,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? context.colors.bluePrimary : context.colors.border,
                        width: 1.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _cardSkins[index]['name'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : context.colors.ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          // Available Balance Card details
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.colors.bgSoft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.colors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Card balance', style: TextStyle(color: context.colors.inkSoft, fontSize: 13, fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text('Active Spending Limit', style: TextStyle(color: context.colors.inkSoft, fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
                Text(
                  card.balance.format(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: context.colors.ink, letterSpacing: -0.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ref.read(cardsProvider.notifier).toggleFrozen(card.id),
                  icon: Icon(card.frozen ? Icons.lock_open_rounded : Icons.lock_outline_rounded, size: 18),
                  label: Text(card.frozen ? 'Unfreeze Card' : 'Freeze Card'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: card.frozen ? context.colors.bluePrimary : context.colors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => showComingSoon(context, 'Card Management'),
                  icon: const Icon(Icons.settings_suggest_rounded, size: 18),
                  label: const Text('Manage'),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  // Front Card representation
  Widget _buildCardFront(dynamic card, Map<String, dynamic> skin) {
    return MetalCardFront(
      last4: card.last4,
      holder: ref.watch(userCardNameProvider),
      isVisa: card.scheme == CardScheme.visa,
      frozen: card.frozen,
      skin: skin,
    );
  }

  // Back Card representation

  Widget _buildCardBack(dynamic card, Map<String, dynamic> skin) {
    return Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 400), child: AspectRatio(aspectRatio: 1.586, child: Container(
            width: double.infinity,
      decoration: BoxDecoration(
        gradient: skin['gradient'],
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Magnetic strip
          Container(
            height: 44,
            color: Colors.black87,
            width: double.infinity,
          ),
          const SizedBox(height: 20),
          // Signature strip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 38,
                    color: Colors.white70,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      ref.watch(userNameProvider),
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 38,
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: const Text(
                      '324',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
            child: Text(
              'For customer service call +1 (800) 555-0199. Unauthorized use is prohibited.',
              style: TextStyle(
                color: skin['accentColor'],
                fontSize: 7.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ))));
  }

}
