import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _initialController;
  late Animation<double> _positionAnimation;
  late Animation<double> _bounceAnimation;

  late AnimationController _finalController;
  late Animation<double> _sizeAnimation;
  late Animation<Color?> _textColorAnimation;

  late AnimationController _expandController;

  bool showFinal = false;
  bool expand = false;

  @override
  void initState() {
    super.initState();

    final primary = Colors.deepPurple;

    // Phase 1: Drop & bounce
    _initialController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

    _positionAnimation = Tween<double>(
      begin: -200,
      end: 0,
    ).animate(CurvedAnimation(parent: _initialController, curve: Curves.easeOutBack));

    _bounceAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _initialController, curve: Curves.elasticOut));

    _initialController.forward().then((_) {
      Timer(const Duration(seconds: 1), () {
        setState(() => showFinal = true);
        _finalController.forward();

        // Then after size grows to 220 → expand
        _finalController.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            Timer(const Duration(milliseconds: 500), () {
              setState(() => expand = true);
              _expandController.forward();
            });
          }
        });
      });
    });

    // Phase 2: Circle size to 220 & text color change
    _finalController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _sizeAnimation = Tween<double>(
      begin: 120,
      end: 220,
    ).animate(CurvedAnimation(parent: _finalController, curve: Curves.easeOut));

    _textColorAnimation = ColorTween(
      begin: primary,
      end: Colors.white,
    ).animate(CurvedAnimation(parent: _finalController, curve: Curves.easeIn));

    // Phase 3: Full screen expansion
    _expandController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _initialController.dispose();
    _finalController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final screenSize = MediaQuery.of(context).size;
    final maxSize =
        math.sqrt(
          screenSize.width + 200 * screenSize.width + 200 + screenSize.height + 200 * screenSize.height + 200,
        ) *
        2;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_initialController, _finalController, _expandController]),
        builder: (context, child) {
          double circleSize = 120;

          if (expand) {
            circleSize = Tween<double>(
              begin: 220,
              end: maxSize,
            ).evaluate(CurvedAnimation(parent: _expandController, curve: Curves.easeInOut));
          } else if (showFinal) {
            circleSize = _sizeAnimation.value;
          }

          final textColor = showFinal ? _textColorAnimation.value : primary;

          return Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (expand)
                  Positioned(
                    top: -100,
                    bottom: -100,
                    child: Center(
                      child: Container(
                        width: circleSize + 200,
                        height: circleSize + 200,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: primary),
                      ),
                    ),
                  )
                else
                  Transform.translate(
                    offset: Offset(0, _positionAnimation.value),
                    child: Transform.scale(
                      scale: _bounceAnimation.value,
                      child: Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: primary),
                      ),
                    ),
                  ),
                SizedBox(
                  width: screenSize.width,
                  height: screenSize.height,
                  child: Center(
                    child: Text(
                      "PURPLE",
                      style: TextStyle(fontSize: 40, color: textColor, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
