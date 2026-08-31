import 'package:flutter/material.dart';
import '../../shared/widgets/nautik_logo.dart';
import '../../shared/widgets/gabis_phone_frame.dart';

class GabisHeroSection extends StatelessWidget {
  const GabisHeroSection({super.key});

  static const purple = Color(0xFF5145E5);
  static const dark = Color(0xFF0D1830);
  static const textGrey = Color(0xFF58677E);
  static const softPurple = Color(0xFFF2F0FF);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1050;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 850),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color(0xFFFCFBFF),
            Color(0xFFF4F1FF),
          ],
          stops: [0, .55, 1],
        ),
      ),
      child: Stack(
        children: [
          // Decorative background glow
          Positioned(
            right: -120,
            top: 90,
            child: Container(
              width: 700,
              height: 700,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    purple.withOpacity(.14),
                    purple.withOpacity(.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64 : 24,
              ),
              child: Column(
                children: [
                  _Navbar(isDesktop: isDesktop),
                  const SizedBox(height: 60),

                  if (isDesktop)
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 10,
                          child: _HeroContent(),
                        ),
                        SizedBox(width: 48),
                        Expanded(
                          flex: 9,
                          child: _HeroVisual(),
                        ),
                      ],
                    )
                  else
                    const Column(
                      children: [
                        _HeroContent(),
                        SizedBox(height: 56),
                        _HeroVisual(),
                      ],
                    ),

                  const SizedBox(height: 46),

                  const _StatsBar(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Navbar extends StatelessWidget {
  final bool isDesktop;

  const _Navbar({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 74,
      child: Row(
        children: [
          const GabisLogo(size: 36),

          if (isDesktop) ...[
            const SizedBox(width: 28),

            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: const [
                    _NavItem('About gabis'),
                    _NavItem('Products'),
                    _NavItem('Cards'),
                    _NavItem('Business'),
                    _NavItem('Support'),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            const _NavItem('Download app'),
            const SizedBox(width: 14),

            const Icon(
              Icons.language_rounded,
              size: 21,
              color: GabisHeroSection.dark,
            ),
            const SizedBox(width: 6),

            const Text(
              'US',
              style: TextStyle(
                color: GabisHeroSection.dark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 16),

            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF1EFFF),
                foregroundColor: GabisHeroSection.purple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 17,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Log in',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),

            const SizedBox(width: 12),

            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: GabisHeroSection.purple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 17,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Sign up',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ] else ...[
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.menu_rounded),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;

  const _NavItem(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: GabisHeroSection.dark,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent();

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 1050;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 17,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: GabisHeroSection.softPurple,
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: GabisHeroSection.purple,
                size: 18,
              ),
              SizedBox(width: 9),
              Text(
                'Modern finance for everyone',
                style: TextStyle(
                  color: GabisHeroSection.purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          ),
        ),

        const SizedBox(height: 25),

        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: desktop ? 72 : 50,
              height: .98,
              letterSpacing: -3.5,
              fontWeight: FontWeight.w800,
              color: GabisHeroSection.dark,
            ),
            children: const [
              TextSpan(text: 'One account.\n'),
              TextSpan(text: 'Every currency.\n'),
              TextSpan(
                text: 'Zero borders.',
                style: TextStyle(
                  color: GabisHeroSection.purple,
                ),
              ),
            ],
          ),
          ),
        ),

        const SizedBox(height: 28),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 630),
          child: Text(
            'One app, every opportunity to build your future. '
            'Send, receive, earn, and spend globally in just a few taps.',
            style: TextStyle(
              color: GabisHeroSection.textGrey,
              fontSize: 19,
              height: 1.6,
            ),
          ),
        ),

        const SizedBox(height: 34),

        const Row(
          children: [
            Expanded(
              child: _Feature(
                icon: Icons.swap_horiz_rounded,
                title: 'Send',
                subtitle: 'Money globally',
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _Feature(
                icon: Icons.file_download_outlined,
                title: 'Receive',
                subtitle: 'Money instantly',
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _Feature(
                icon: Icons.trending_up_rounded,
                title: 'Earn',
                subtitle: 'Grow your money',
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _Feature(
                icon: Icons.wallet_outlined,
                title: 'Spend',
                subtitle: 'Pay anywhere',
              ),
            ),
          ],
        ),

        const SizedBox(height: 38),

        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 28,
          runSpacing: 20,
          children: [
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: GabisHeroSection.purple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 29,
                  vertical: 22,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 10,
                shadowColor:
                    GabisHeroSection.purple.withOpacity(.25),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Open your account',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 14),
                  Icon(Icons.arrow_forward_rounded),
                ],
              ),
            ),

            const _SecurityMiniCard(),
          ],
        ),
      ],
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _Feature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: GabisHeroSection.softPurple,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: GabisHeroSection.purple,
              size: 21,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: GabisHeroSection.dark,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: GabisHeroSection.textGrey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
    );
  }
}

class _SecurityMiniCard extends StatelessWidget {
  const _SecurityMiniCard();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: GabisHeroSection.softPurple,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.verified_user_rounded,
            color: GabisHeroSection.purple,
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your money is safe',
              style: TextStyle(
                color: GabisHeroSection.dark,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Bank-level security',
              style: TextStyle(
                color: GabisHeroSection.textGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    // The composition is laid out at a fixed 520x600; scale it down rather
    // than letting the phone and card run past a narrow viewport.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
      width: 520,
      height: 600,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Purple circle behind everything
          Container(
            width: 520,
            height: 520,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: GabisHeroSection.purple.withOpacity(.07),
            ),
          ),

          // Bank card behind phone
          Positioned(
            right: 10,
            top: 185,
            child: Transform.rotate(
              angle: .16,
              child: const _BankCard(),
            ),
          ),

          // Phone
          Positioned(
            left: 40,
            top: 20,
            child: Transform.rotate(
              angle: .10,
              child: const _PhoneMockup(),
            ),
          ),

        ],
      ),
      ),
    );
  }
}

class _BankCard extends StatelessWidget {
  const _BankCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 185,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF907EFF),
            Color(0xFF5546D9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: GabisHeroSection.purple.withOpacity(.25),
            blurRadius: 35,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: GabisLogo(size: 26, isWhite: true),
          ),
          SizedBox(height: 14),
          Icon(
            Icons.memory_rounded,
            color: Color(0xFFFFD561),
            size: 31,
          ),
          Spacer(),
          Text(
            '••••  ••••  ••••  5678',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CARDHOLDER',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 7.5,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'RAPHAEL GABRIELS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Text(
                'VISA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhoneMockup extends StatelessWidget {
  const _PhoneMockup();

  @override
  Widget build(BuildContext context) {
    return GabisPhoneFrame(
      width: 310,
      height: 560,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(
          children: [
            const Text(
              'Total Balance',
              style: TextStyle(
                color: GabisHeroSection.textGrey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              '\u20A614,850.50',
              style: TextStyle(
                color: GabisHeroSection.dark,
                fontSize: 29,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 24),

            const Row(
              children: [
                Expanded(
                  child: _PhoneAction(
                    icon: Icons.arrow_upward_rounded,
                    label: 'Send',
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _PhoneAction(
                    icon: Icons.arrow_downward_rounded,
                    label: 'Receive',
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _PhoneAction(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Transfer',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Activity',
                style: TextStyle(
                  color: GabisHeroSection.dark,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),

            const SizedBox(height: 12),

            const _Transaction(
              icon: Icons.phone_android_rounded,
              title: 'MTN Top-up',
              amount: '-\u20A62,000.00',
            ),

            const Divider(height: 24),

            const _Transaction(
              icon: Icons.people_outline_rounded,
              title: 'Funds Received',
              amount: '+\u20A65,000.00',
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PhoneAction({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6B45C7),
            Color(0xFF4A2A9D),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 19),
          const SizedBox(height: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _Transaction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String amount;

  const _Transaction({
    required this.icon,
    required this.title,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFFE9F9EE),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: const Color(0xFF44B868),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: GabisHeroSection.dark,
            ),
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: GabisHeroSection.dark,
          ),
        ),
      ],
    );
  }
}

class _StatsBar extends StatelessWidget {
  const _StatsBar();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 820),
        padding: const EdgeInsets.symmetric(
          horizontal: 27,
          vertical: 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.88),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white,
          ),
          boxShadow: [
            BoxShadow(
              color: GabisHeroSection.purple.withOpacity(.07),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),

        // Notice: the 100K+ metric is completely removed.
        child: const Wrap(
          spacing: 34,
          runSpacing: 20,
          children: [
            _Stat(
              icon: Icons.public_rounded,
              title: '180+',
              subtitle: 'Countries supported',
            ),
            _Stat(
              icon: Icons.verified_user_rounded,
              title: 'Secure',
              subtitle: 'Your trust, our priority',
            ),
            _Stat(
              icon: Icons.bolt_rounded,
              title: 'Fast',
              subtitle: 'Transactions in seconds',
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _Stat({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Row(
        children: [
          Container(
            width: 49,
            height: 49,
            decoration: BoxDecoration(
              color: GabisHeroSection.softPurple,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: GabisHeroSection.purple,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: GabisHeroSection.dark,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: GabisHeroSection.textGrey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
