import re

with open('lib/features/landing/gabis_landing_v3.dart', 'r') as f:
    text = f.read()

# Replace _BalanceBubble width and height and fontSize and newline
text = text.replace('width: 116,', 'width: 90,')
text = text.replace('height: 116,', 'height: 90,')
text = text.replace("          '5\\nWALLETS',", "          '5\\nWALLETS',")
text = text.replace('            fontSize: 17,\n            height: .95,\n            fontWeight: FontWeight.w900,\n            color: GabisV3.ink,\n          ),\n        ),\n      ),\n    );\n  }\n}\n\n/// Points earned', '            fontSize: 14,\n            height: .95,\n            fontWeight: FontWeight.w900,\n            color: GabisV3.ink,\n          ),\n        ),\n      ),\n    );\n  }\n}\n\n/// Points earned')

# Update _OrbitGame constructor
text = text.replace(
    'class _OrbitGame extends StatefulWidget {\n  final Animation<double> motion;\n  const _OrbitGame({required this.motion});',
    'class _OrbitGame extends StatefulWidget {\n  final Animation<double> motion;\n  final Offset center;\n  final double radius;\n  const _OrbitGame({\n    required this.motion,\n    required this.center,\n    required this.radius,\n  });'
)

# Update _PointsChip constructor
text = text.replace(
    'class _PointsChip extends StatelessWidget {\n  final bool hint;\n  const _PointsChip({required this.hint});',
    'class _PointsChip extends StatelessWidget {\n  const _PointsChip();'
)

# Update _PointsChip usage of hint
text = text.replace(
    '            Text(\n              hint\n                  ? \'Catch the orbs',
    '            Text(\n              points == 0\n                  ? \'Catch the orbs'
)

# Move _PointsChip to _HeroCopy
text = text.replace(
    '          const SizedBox(height: 52);\n          const _MicroProof();',
    '          const SizedBox(height: 32);\n          const _PointsChip();\n          const SizedBox(height: 20);\n          const _MicroProof();'
)

# Fix _Hero
text = text.replace(
    '''        final width = c.maxWidth;
        final desktop = width >= 980;
        final side = GabisV3.side(width);

        return Container(
          color: GabisV3.cream,
          child: Stack(
            children: [
              Positioned.fill(child: _OrbitGame(motion: motion)),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(side, 18, side, 0),
                    child: const _Nav(),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      side,
                      desktop ? 52 : 40,''',
    '''        final width = c.maxWidth;
        final desktop = width >= 980;
        final side = GabisV3.side(width);
        
        final cw = math.min(width, 1440.0);
        final sideSpace = (width - cw) / 2;
        final centerX = desktop ? sideSpace + cw * (16 / 21) + 4.76 : width / 2;
        final topPadding = desktop ? 150.0 : 80.0;
        final boxHeight = desktop ? 680.0 : (width < 600 ? 520.0 : 600.0);
        final centerY = 18.0 + 72.0 + topPadding + boxHeight / 2;
        
        final center = Offset(centerX, centerY);
        final cwRight = desktop ? (cw - 20) * (10 / 21) : cw;
        final radius = math.min(cwRight, boxHeight) * .65;

        return Container(
          color: GabisV3.cream,
          child: Stack(
            children: [
              Positioned.fill(
                child: _OrbitGame(motion: motion, center: center, radius: radius),
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(side, 18, side, 0),
                    child: const _Nav(),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      side,
                      desktop ? 150 : 80,'''
)

# Fix _OrbitGameState
text = text.replace(
    '''    return LayoutBuilder(
      builder: (context, c) {
        final size = Size(c.maxWidth, c.maxHeight);
        final screenSize = MediaQuery.of(context).size;
        final center = Offset(size.width * .72, size.height * .5);
        final radius = math.min(size.width, size.height) * .40;
        final inner = radius * .68;

        return AnimatedBuilder(
          animation: Listenable.merge([widget.motion, _spin]),
          builder: (context, _) {
            final theta = _spin.value * math.pi * 2 * _speed;
            final outerAt = Offset(center.dx + math.cos(theta) * radius,
                center.dy + math.sin(theta) * radius);
            final innerAt = Offset(
                center.dx + math.cos(-theta + math.pi) * inner,
                center.dy + math.sin(-theta + math.pi) * inner);

            return Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: const _OrbitRingsPainter()),
                  ),
                ),
                _orb(outerAt, 13, GabisV3.electric, 5),
                _orb(innerAt, 10, GabisV3.coral, 10),
                for (final pop in _pops) _popLabel(pop),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 14,
                  child: Center(child: _PointsChip(hint: !_played)),
                ),
              ],
            );
          },
        );
      },
    );''',
    '''    return LayoutBuilder(
      builder: (context, c) {
        final screenSize = MediaQuery.of(context).size;
        final center = widget.center;
        final radius = widget.radius;
        final inner = radius * .88;
        final innermost = radius * .65;

        return AnimatedBuilder(
          animation: Listenable.merge([widget.motion, _spin]),
          builder: (context, _) {
            final theta = _spin.value * math.pi * 2 * _speed;
            final outerAt = Offset(center.dx + math.cos(theta) * radius,
                center.dy + math.sin(theta) * radius);
            final innerAt = Offset(
                center.dx + math.cos(-theta + math.pi) * inner,
                center.dy + math.sin(-theta + math.pi) * inner);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _OrbitRingsPainter(center, radius)),
                  ),
                ),
                _orb(outerAt, 13, GabisV3.electric, 5),
                _orb(innerAt, 10, GabisV3.coral, 10),
                for (final pop in _pops) _popLabel(pop),
              ],
            );
          },
        );
      },
    );'''
)

# Fix _OrbitRingsPainter
text = text.replace(
    '''class _OrbitRingsPainter extends CustomPainter {
  const _OrbitRingsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .72, size.height * .5);
    final radius = math.min(size.width, size.height) * .40;

    for (final r in [radius, radius * .68]) {''',
    '''class _OrbitRingsPainter extends CustomPainter {
  final Offset center;
  final double radius;
  const _OrbitRingsPainter(this.center, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    for (final r in [radius, radius * .88, radius * .65]) {'''
)

# Desktop Layout _BalanceBubble
text = text.replace(
    '''                                  Expanded(
                                    flex: 10,
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.center,
                                      children: [
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: _HeroProduct(motion: motion),
                                        ),
                                        const Positioned(
                                          left: -42,
                                          top: 24,
                                          child: _BalanceBubble(),
                                        ),
                                      ],
                                    ),
                                  ),''',
    '''                                  Expanded(
                                    flex: 10,
                                    child: LayoutBuilder(
                                      builder: (context, c) {
                                        final radius = math.min(c.maxWidth, c.maxHeight) * .65;
                                        final innermost = radius * .65;
                                        return Stack(
                                          clipBehavior: Clip.none,
                                          alignment: Alignment.center,
                                          children: [
                                            IgnorePointer(
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: _HeroProduct(motion: motion),
                                              ),
                                            ),
                                            Positioned(
                                              left: c.maxWidth / 2 + innermost * math.cos(-math.pi / 6) - 45,
                                              top: c.maxHeight / 2 + innermost * math.sin(-math.pi / 6) - 45,
                                              child: const _BalanceBubble(),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),'''
)

# Mobile Layout _BalanceBubble
text = text.replace(
    '''                                SizedBox(
                                  height: width < 600 ? 520 : 600,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.center,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: _HeroProduct(motion: motion),
                                      ),
                                      const Positioned(
                                        left: -32,
                                        top: 24,
                                        child: _BalanceBubble(),
                                      ),
                                    ],
                                  ),
                                ),''',
    '''                                SizedBox(
                                  height: width < 600 ? 520 : 600,
                                  child: LayoutBuilder(
                                    builder: (context, c) {
                                      final radius = math.min(c.maxWidth, c.maxHeight) * .65;
                                      final innermost = radius * .65;
                                      return Stack(
                                        clipBehavior: Clip.none,
                                        alignment: Alignment.center,
                                        children: [
                                          IgnorePointer(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: _HeroProduct(motion: motion),
                                            ),
                                          ),
                                          Positioned(
                                            left: c.maxWidth / 2 + innermost * math.cos(-math.pi / 6) - 45,
                                            top: c.maxHeight / 2 + innermost * math.sin(-math.pi / 6) - 45,
                                            child: const _BalanceBubble(),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),'''
)


with open('lib/features/landing/gabis_landing_v3.dart', 'w') as f:
    f.write(text)

print("done")
