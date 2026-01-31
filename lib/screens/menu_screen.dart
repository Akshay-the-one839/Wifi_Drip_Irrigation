import 'package:flutter/material.dart';
import 'dart:math' as math;

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _floatController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Widget glassButton(String text, IconData icon, VoidCallback onTap) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.0),
      duration: const Duration(milliseconds: 120),
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: const Color(0xFF4ECDC4).withOpacity(0.25),
          onTap: onTap,
          onHighlightChanged: (pressed) {
            // rebuild scale animation
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Stack(
              children: [
                // 🌈 Gradient Border
                Container(
                  padding: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4ECDC4), Color(0xFF3A7BD5)],
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: const Color(0xFF1E3A4C).withOpacity(0.65),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4ECDC4).withOpacity(0.25),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 44,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF4ECDC4,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  icon,
                                  color: const Color(0xFF4ECDC4),
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget animatedBackground() {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: const [
                Color(0xFF0A1828),
                Color(0xFF1A2F3F),
                Color(0xFF2A4555),
              ],
              stops: [0, _bgController.value, 1],
            ),
          ),
        );
      },
    );
  }

  Widget floatingOrbs() {
    return Stack(
      children: List.generate(8, (index) {
        return AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            final offset =
                math.sin(
                  (_floatController.value * 2 * math.pi) + (index * 0.5),
                ) *
                20;
            return Positioned(
              left: (index % 4) * 100.0 + 20,
              top: (index ~/ 4) * 300.0 + offset + 300,
              child: Container(
                width: 60 + (index % 3) * 20.0,
                height: 60 + (index % 3) * 20.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF4ECDC4).withOpacity(0.15),
                      const Color(0xFF4ECDC4).withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget iconDecoration() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final offset1 = math.sin(_floatController.value * 2 * math.pi) * 10;
        final offset2 = math.cos(_floatController.value * 2 * math.pi) * 15;

        return Stack(
          children: [
            Positioned(
              top: 150 + offset1,
              right: 30,
              child: const Opacity(
                opacity: 0.3,
                child: Icon(
                  Icons.wifi_rounded,
                  size: 40,
                  color: Color(0xFF4ECDC4),
                ),
              ),
            ),
            Positioned(
              top: 200 + offset2,
              left: 40,
              child: const Opacity(
                opacity: 0.25,
                child: Icon(
                  Icons.settings_remote_rounded,
                  size: 35,
                  color: Color(0xFF4ECDC4),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1828),
      body: Stack(
        children: [
          animatedBackground(),
          floatingOrbs(),
          iconDecoration(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.02), // Reduced from 30
                  /// 🔥 LOGO
                  SizedBox(
                    height: screenHeight * 0.15, // Responsive height
                    child: Image.asset(
                      "assets/images/main-logo.png",
                      fit: BoxFit.contain,
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.only(left: 50), // ← right indent amount
                    child: Text(
                      "COLLECTION OF BITS FROM AIR ...",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 254, 254),
                        letterSpacing: 1.2,
                        fontSize: 11.8,
                      ),
                    ),
                  ),

                  // ✅ WI-FI LOGO
                  Image.asset(
                    "assets/wi_fi.png",
                    height: screenHeight * 0.12, // Responsive height
                    fit: BoxFit.contain,
                  ),

                  const Text(
                    "WI-FI 3 PHASE MOBILE STARTER",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.015), // Reduced spacing

                  glassButton(
                    "Login",
                    Icons.login_rounded,
                    () => Navigator.pushNamed(context, '/login'),
                  ),
                  glassButton(
                    "Sign Up",
                    Icons.person_add_rounded,
                    () => Navigator.pushNamed(context, '/signup'),
                  ),
                  glassButton(
                    "Smart Settings",
                    Icons.settings_rounded,
                    () => Navigator.pushNamed(context, '/smart'),
                  ),
                  glassButton(
                    "Contact Us",
                    Icons.contact_mail_rounded,
                    () => Navigator.pushNamed(context, '/contact'),
                  ),

                  SizedBox(height: screenHeight * 0.02), // Reduced from 40
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
