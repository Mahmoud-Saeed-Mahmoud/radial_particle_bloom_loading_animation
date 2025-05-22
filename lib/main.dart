import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, primarySwatch: Colors.blue),
      home: const RadialParticleBloomScreen(),
    );
  }
}

class RadialParticleBloomAnimationPainter extends CustomPainter {
  final double progress;
  final double mainScale;
  final double mainRotation;
  final double secondPhaseContainerRotation;
  final double secondPhaseContainerScale;
  final List<double> firstPhaseScales;
  final List<double> firstPhaseOpacities;
  final List<double> firstPhaseRotations;
  final List<double> secondPhaseScales;
  final List<double> secondPhaseOpacities;
  final List<double> secondPhaseRotations;
  final Color color;

  RadialParticleBloomAnimationPainter({
    required this.progress,
    required this.mainScale,
    required this.mainRotation,
    required this.secondPhaseContainerRotation,
    required this.secondPhaseContainerScale,
    required this.firstPhaseScales,
    required this.firstPhaseOpacities,
    required this.firstPhaseRotations,
    required this.secondPhaseScales,
    required this.secondPhaseOpacities,
    required this.secondPhaseRotations,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final shortRadius = size.width * 0.25;
    final longRadius = size.width * 0.4;

    // Paint for the dots
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // First phase (0-50% of animation)
    if (progress < 0.5) {
      // Save the canvas state
      canvas.save();

      // Move to center and apply main rotation and scale
      canvas.translate(center.dx, center.dy);
      canvas.scale(mainScale);
      canvas.rotate(mainRotation);

      // Draw first phase dots (small dots)
      for (int i = 0; i < firstPhaseScales.length; i++) {
        if (firstPhaseOpacities[i] <= 0 || firstPhaseScales[i] <= 0) continue;

        // Save state for this dot
        canvas.save();

        // Position the dot along the circle
        canvas.rotate(firstPhaseRotations[i]);

        // Draw the dot
        paint.color = color.withValues(alpha: firstPhaseOpacities[i]);
        final dotRadius = 10.0 * firstPhaseScales[i];
        canvas.drawCircle(Offset(shortRadius, 0), dotRadius, paint);

        // Restore state for next dot
        canvas.restore();
      }

      // Restore the canvas to its original state
      canvas.restore();
    }

    // Second phase (50-100% of animation)
    if (progress >= 0.5) {
      // Save the canvas state
      canvas.save();

      // Move to center and apply second phase rotation and scale
      canvas.translate(center.dx, center.dy);
      canvas.scale(secondPhaseContainerScale);
      canvas.rotate(secondPhaseContainerRotation);

      // Draw second phase dots (dots on longer arms)
      for (int i = 0; i < secondPhaseScales.length; i++) {
        if (secondPhaseOpacities[i] <= 0 || secondPhaseScales[i] <= 0) continue;

        // Save state for this dot
        canvas.save();

        // Position the dot along the circle
        canvas.rotate(secondPhaseRotations[i]);

        // Draw the dot
        paint.color = color.withValues(alpha: secondPhaseOpacities[i]);
        final dotRadius = 10.0 * secondPhaseScales[i];

        // Draw a dot at the end of a longer line
        canvas.drawCircle(Offset(longRadius, 0), dotRadius, paint);

        // Restore state for next dot
        canvas.restore();
      }

      // Restore the canvas
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(RadialParticleBloomAnimationPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.mainScale != mainScale ||
        oldDelegate.mainRotation != mainRotation ||
        oldDelegate.secondPhaseContainerRotation !=
            secondPhaseContainerRotation ||
        oldDelegate.secondPhaseContainerScale != secondPhaseContainerScale ||
        oldDelegate.firstPhaseScales != firstPhaseScales ||
        oldDelegate.firstPhaseOpacities != firstPhaseOpacities ||
        oldDelegate.firstPhaseRotations != firstPhaseRotations ||
        oldDelegate.secondPhaseScales != secondPhaseScales ||
        oldDelegate.secondPhaseOpacities != secondPhaseOpacities ||
        oldDelegate.secondPhaseRotations != secondPhaseRotations;
  }
}

class RadialParticleBloomScreen extends StatefulWidget {
  const RadialParticleBloomScreen({super.key});

  @override
  State<RadialParticleBloomScreen> createState() =>
      _RadialParticleBloomScreenState();
}

class _RadialParticleBloomScreenState extends State<RadialParticleBloomScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  // First phase - small dots
  final List<Animation<double>> _firstPhaseScales = [];
  final List<Animation<double>> _firstPhaseOpacities = [];
  final List<Animation<double>> _firstPhaseRotations = [];

  // Second phase - dots on longer arms
  final List<Animation<double>> _secondPhaseScales = [];
  final List<Animation<double>> _secondPhaseOpacities = [];
  final List<Animation<double>> _secondPhaseRotations = [];

  // Main container animations
  late Animation<double> _mainScale;
  late Animation<double> _mainRotation;
  late Animation<double> _secondPhaseContainerRotation;
  late Animation<double> _secondPhaseContainerScale;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(300, 300),
              painter: RadialParticleBloomAnimationPainter(
                color: Colors.cyan,
                progress: _controller.value,
                mainScale: _mainScale.value,
                mainRotation: _mainRotation.value,
                secondPhaseContainerRotation:
                    _secondPhaseContainerRotation.value,
                secondPhaseContainerScale: _secondPhaseContainerScale.value,
                firstPhaseScales: _firstPhaseScales
                    .map((a) => a.value)
                    .toList(),
                firstPhaseOpacities: _firstPhaseOpacities
                    .map((a) => a.value)
                    .toList(),
                firstPhaseRotations: _firstPhaseRotations
                    .map((a) => a.value)
                    .toList(),
                secondPhaseScales: _secondPhaseScales
                    .map((a) => a.value)
                    .toList(),
                secondPhaseOpacities: _secondPhaseOpacities
                    .map((a) => a.value)
                    .toList(),
                secondPhaseRotations: _secondPhaseRotations
                    .map((a) => a.value)
                    .toList(),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Main controller for the entire animation sequence (240 frames at 60fps = 4 seconds)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    // Main container scale animation (0-50% of animation)
    _mainScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOutBack),
      ),
    );

    // Main container rotation animation (0-50% of animation)
    _mainRotation = Tween<double>(begin: 0.0, end: 2.5 * pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOutCubic),
      ),
    );

    // Second phase container rotation (50-100% of animation)
    _secondPhaseContainerRotation = Tween<double>(begin: 0.0, end: pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    // Second phase container scale (50-100% of animation)
    _secondPhaseContainerScale = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    // First phase - 4 dots appearing in sequence with precise timing from the JSON
    final firstPhaseDelays = [
      0.0,
      0.02,
      0.0375,
      0.0525,
    ]; // Staggered start times
    final firstPhaseDurations = [0.2, 0.2, 0.2, 0.2]; // Duration of scale up
    final firstPhaseRotationStarts = [
      0.16,
      0.33,
      0.38,
      0.42,
    ]; // When rotation starts
    final firstPhaseRotationEnds = [
      0.33,
      0.38,
      0.42,
      0.45,
    ]; // When rotation ends
    final firstPhaseFadeStarts = [
      0.33,
      0.38,
      0.42,
      0.45,
    ]; // When fade out starts
    final firstPhaseFadeEnds = [0.35, 0.4, 0.44, 0.47]; // When fade out ends

    for (int i = 0; i < 4; i++) {
      // Scale animations with staggered start times
      _firstPhaseScales.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              firstPhaseDelays[i],
              firstPhaseDelays[i] + firstPhaseDurations[i],
              curve: Curves.easeOutBack,
            ),
          ),
        ),
      );

      // Opacity animations for fade out
      _firstPhaseOpacities.add(
        Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              firstPhaseFadeStarts[i],
              firstPhaseFadeEnds[i],
              curve: Curves.easeOut,
            ),
          ),
        ),
      );

      // Individual rotation animations
      _firstPhaseRotations.add(
        Tween<double>(begin: i * pi / 2, end: (i + 1) * pi / 2).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              firstPhaseRotationStarts[i],
              firstPhaseRotationEnds[i],
              curve: Curves.easeInOut,
            ),
          ),
        ),
      );
    }

    // Second phase - 4 dots appearing in sequence
    final secondPhaseDelays = [0.5, 0.53, 0.56, 0.59]; // Staggered start times
    final secondPhaseDurations = [0.2, 0.2, 0.2, 0.2]; // Duration of scale up
    final secondPhaseFadeStarts = [
      0.83,
      0.86,
      0.89,
      0.92,
    ]; // When fade out starts
    final secondPhaseFadeEnds = [0.87, 0.9, 0.93, 0.96]; // When fade out ends

    for (int i = 0; i < 4; i++) {
      // Scale animations with staggered start times
      _secondPhaseScales.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              secondPhaseDelays[i],
              secondPhaseDelays[i] + secondPhaseDurations[i],
              curve: Curves.easeOutBack,
            ),
          ),
        ),
      );

      // Opacity animations for fade out
      _secondPhaseOpacities.add(
        Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              secondPhaseFadeStarts[i],
              secondPhaseFadeEnds[i],
              curve: Curves.easeOut,
            ),
          ),
        ),
      );

      // Fixed rotation positions for second phase
      _secondPhaseRotations.add(
        Tween<double>(begin: i * pi / 2, end: i * pi / 2).animate(
          CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)),
        ),
      );
    }

    // Start the animation
    _controller.repeat();
  }
}
