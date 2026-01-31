import 'package:flutter/material.dart';
import 'dart:math' as math;

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen>
    with TickerProviderStateMixin {
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

  Widget animatedBackground() {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0A1828),
                const Color(0xFF1A2F3F),
                const Color(0xFF2A4555),
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
      children: List.generate(6, (index) {
        return AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            final offset =
                math.sin(
                  (_floatController.value * 2 * math.pi) + (index * 0.5),
                ) *
                20;
            return Positioned(
              left: (index % 3) * 120.0 + 30,
              top: (index ~/ 3) * 250.0 + offset + 100,
              child: Container(
                width: 70 + (index % 3) * 15.0,
                height: 70 + (index % 3) * 15.0,
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
              top: 100 + offset1,
              right: 40,
              child: Opacity(
                opacity: 0.2,
                child: Icon(
                  Icons.phone_iphone_rounded,
                  size: 40,
                  color: const Color(0xFF4ECDC4),
                ),
              ),
            ),
            Positioned(
              top: 150 + offset2,
              left: 50,
              child: Opacity(
                opacity: 0.25,
                child: Icon(
                  Icons.email_rounded,
                  size: 35,
                  color: const Color(0xFF4ECDC4),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget glassCard(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A4C).withOpacity(0.5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF4ECDC4).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4ECDC4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.01), // Responsive spacing

                  AnimatedBuilder(
                    animation: _glowController,
                    builder: (_, __) => Container(
                      width: screenHeight * 0.08, // Responsive size
                      height: screenHeight * 0.08,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF4ECDC4).withOpacity(0.4),
                            const Color(0xFF4ECDC4).withOpacity(0.2),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF4ECDC4,
                            ).withOpacity(0.3 + (_glowController.value * 0.2)),
                            blurRadius: 30 + (_glowController.value * 20),
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.contact_page_rounded,
                          color: Color(0xFF4ECDC4),
                          size: 50,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02), // Responsive spacing

                  const Text(
                    "CONTACT US",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xFF4ECDC4),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.04), // Responsive spacing

                  glassCard(
                    "Address",
                    "#1156-A, Behind Sungam Sindamani Bus Stop,\n"
                        "Trichy Main Road, Ramanathapuram (Po),\n"
                        "Coimbatore-641045, Tamil Nadu, India.",
                  ),

                  glassCard("Phone", "+91-422-3593306\n(+91) 96296 59111"),

                  glassCard(
                    "Email",
                    "inquire@qbitronics.com\nqbitinquire@gmail.com",
                  ),

                  glassCard("Website", "www.qbitronics.com"),

                  SizedBox(height: screenHeight * 0.04), // Responsive spacing
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
