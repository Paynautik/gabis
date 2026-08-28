import re

filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# 1. Add timer import if not present
if "import 'dart:async';" not in content:
    content = "import 'dart:async';\n" + content

# 2. Add controller state variables, initState, and dispose
old_state_top = """class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedPeriod = '7D';
  bool _showPromoBanner = true;
  bool _showAllTransactions = false;
  bool _hideBalances = false;
  bool _showSecurityBanner = true;
  bool _isBalanceHidden = false;"""

new_state_top = """class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedPeriod = '7D';
  bool _showPromoBanner = true;
  bool _showAllTransactions = false;
  bool _hideBalances = false;
  bool _showSecurityBanner = true;
  bool _isBalanceHidden = false;
  
  late PageController _pageController;
  int _currentSlide = 0;
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _carouselTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (_pageController.hasClients) {
        final next = (_currentSlide + 1) % 3;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }"""

content = content.replace(old_state_top, new_state_top)

# 3. Replace _buildPromoBanner with _buildCarouselBanner
# Let's find _buildPromoBanner in the file and replace it entirely with our new PageView slider.

old_promo_method_start = content.find("  // --- Promo Banner ---")
if old_promo_method_start == -1:
    old_promo_method_start = content.find("  Widget _buildPromoBanner()")

# Find the end of _buildPromoBanner by looking for the next method
next_method_idx = content.find("  // --- Quick Actions Grid ---", old_promo_method_start)

# Now define our new _buildCarouselBanner method
new_carousel_method = """  // --- Consolidated Carousel Banner ---
  Widget _buildCarouselBanner() {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _currentSlide = idx),
            children: [
              // Slide 1: PayNautik Global Payroll
              _buildPayrollSlide(),
              // Slide 2: Elumo Promo (Pay Smarter, Live Better)
              _buildElumoPromoSlide(),
              // Slide 3: Elumo Virtual Visa Card
              _buildVirtualCardSlide(),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final isSel = _currentSlide == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isSel ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isSel ? context.colors.bluePrimary : context.colors.inkSoft.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  // --- Slide 1: Payroll ---
  Widget _buildPayrollSlide() {
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.hub_rounded, color: Colors.white, size: 10),
                          SizedBox(width: 4),
                          Text('GLOBAL PAYROLL', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('• paynautik.com', style: TextStyle(color: context.colors.inkSoft, fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Frictionless Global Payroll',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, letterSpacing: -0.3),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Automate salary disbursements across 150+ countries via smart contracts instantly.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, height: 1.3, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final url = Uri.parse('https://paynautik.com');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Launch PayNautik', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      SizedBox(width: 4),
                      Icon(Icons.launch_rounded, size: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Center(
              child: CustomPaint(
                size: const Size(120, 90),
                painter: _PayrollNodesPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Slide 2: Elumo Promo ---
  Widget _buildElumoPromoSlide() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2856E8), Color(0xFF4949E8)],
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
                const Text('Pay smarter. Live better.', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.white)),
                const SizedBox(height: 4),
                const Text(
                  'Make seamless payments, send money, and manage your finances effortlessly on Elumo.',
                  style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.3, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: context.colors.bluePrimary,
                    minimumSize: const Size(120, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.arrow_outward_rounded, size: 12),
                  label: const Text('Visit Elumo.com', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Overlapping card mockup
          const SizedBox(
            width: 80,
            height: 50,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 6,
                  child: _MockCard(color: Color(0xFF1761E9)),
                ),
                Positioned(
                  left: 15,
                  top: 0,
                  child: _MockCard(color: Colors.white10),
                ),
              ],
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
                      const Text('ELUMO', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const Text('•••• 4821', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('RAPHAEL M.', style: TextStyle(color: Colors.white, fontSize: 5.5, fontWeight: FontWeight.w800)),
                      Text('VISA', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
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
"""

if old_promo_method_start != -1 and next_method_idx != -1:
    content = content[:old_promo_method_start] + new_carousel_method + "\n\n" + content[next_method_idx:]

with open(filepath, 'w') as f:
    f.write(content)

