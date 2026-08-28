import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SendSuccessScreen extends StatefulWidget {
  final String recipient;
  final int amountMinor;

  const SendSuccessScreen({super.key, required this.recipient, required this.amountMinor});

  @override
  State<SendSuccessScreen> createState() => _SendSuccessScreenState();
}

class _SendSuccessScreenState extends State<SendSuccessScreen> with SingleTickerProviderStateMixin {
  late List<_ConfettiParticle> _particles;
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(80, (index) => _createParticle());
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        _updateParticles();
      });
    _controller.forward();
  }

  _ConfettiParticle _createParticle() {
    final colors = [
      context.colors.bluePrimary,
      const Color(0xFFFF2D55),
      const Color(0xFFFFCC00),
      const Color(0xFF4CD964),
      const Color(0xFF5AC8FA),
      const Color(0xFFFF9500),
    ];
    
    // Shoot particles upward and outward from bottom-center
    final angle = -pi / 2 + (_random.nextDouble() - 0.5) * (pi / 2.5); // centered upwards
    final speed = 10.0 + _random.nextDouble() * 15.0;

    return _ConfettiParticle(
      x: 0, // Will offset to center screen
      y: 0, // Will offset to center screen
      vx: cos(angle) * speed,
      vy: sin(angle) * speed,
      color: colors[_random.nextInt(colors.length)],
      size: 6.0 + _random.nextDouble() * 8.0,
      angle: _random.nextDouble() * pi * 2,
      spinSpeed: (_random.nextDouble() - 0.5) * 0.3,
    );
  }

  void _updateParticles() {
    setState(() {
      for (final p in _particles) {
        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.4; // gravity
        p.vx *= 0.98; // air resistance
        p.vy *= 0.98;
        p.angle += p.spinSpeed;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Custom Painter for Confetti
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(
                  particles: _particles,
                  centerX: width / 2,
                  centerY: height / 2 - 50,
                ),
              ),
            ),
          ),
          // Main layout content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Animated success icon
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: context.colors.success,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x3300C853),
                                blurRadius: 24,
                                offset: Offset(0, 12),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 54),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  // Amount Sent Info
                  Text(
                    '₦${(widget.amountMinor / 100).toStringAsFixed(2)} sent',
                    style: TextStyle(
                      fontSize: 28, 
                      fontWeight: FontWeight.w900, 
                      letterSpacing: -0.6,
                      color: context.colors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'to ${widget.recipient}',
                    style: TextStyle(color: context.colors.inkSoft, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  final Color color;
  final double size;
  double angle;
  final double spinSpeed;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.angle,
    required this.spinSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double centerX;
  final double centerY;

  _ConfettiPainter({required this.particles, required this.centerX, required this.centerY});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;

      canvas.save();
      // Translate to particle coordinates centered around center point
      canvas.translate(centerX + p.x, centerY + p.y);
      canvas.rotate(p.angle);
      
      // Draw a small decorative rectangle
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 1.8),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
