import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'smart_settings_screen.dart';
import 'dashboard_screen.dart';
import 'dart:math' as math;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  bool showPass = false;

  late AnimationController _bgController;
  late AnimationController _floatController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    loadSavedCredentials(); // load email only

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
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  Future<void> loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    emailController.text = prefs.getString('email') ?? '';
    passController.text = prefs.getString('password') ?? '';
  }

  void clearFields() {
    emailController.clear();
    passController.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Fields cleared")));
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final pass = passController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and password cannot be empty")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPass = prefs.getString('password');

    if (savedEmail == null || savedPass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No account found. Please sign up first."),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SmartSettingsScreen()),
      );
      return;
    }

    if (email == savedEmail && pass == savedPass) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid email or password")),
      );
    }
  }

  // ---------- UI ----------

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

  Widget loginIcons() {
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
                  Icons.key,
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
                  Icons.lock_rounded,
                  size: 35,
                  color: const Color(0xFF4ECDC4),
                ),
              ),
            ),
            Positioned(
              top: 200 + offset1,
              right: 80,
              child: Opacity(
                opacity: 0.15,
                child: Icon(
                  Icons.email_rounded,
                  size: 30,
                  color: const Color(0xFF4ECDC4),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget glassField({
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    Widget? suffix,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A4C).withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF4ECDC4).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: const Color(0xFF4ECDC4), size: 20),
          suffixIcon: suffix,
        ),
      ),
    );
  }

  Widget glowButton(String text, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            colors: [Color(0xFF4ECDC4), Color(0xFF44A8A0)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4ECDC4).withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1828),
      body: Stack(
        children: [
          animatedBackground(),
          floatingOrbs(),
          loginIcons(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ECDC4).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF4ECDC4).withOpacity(0.3),
                        ),
                      ),
                      child: const Text(
                        "LOGIN",
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF4ECDC4),
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: 320,
                      child: glassField(
                        hint: "Email",
                        controller: emailController,
                        icon: Icons.email_rounded,
                      ),
                    ),

                    SizedBox(
                      width: 320,
                      child: glassField(
                        hint: "Password",
                        controller: passController,
                        obscure: !showPass,
                        icon: Icons.lock_rounded,
                        suffix: IconButton(
                          icon: Icon(
                            showPass
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: const Color(0xFF4ECDC4),
                          ),
                          onPressed: () => setState(() => showPass = !showPass),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    glowButton("LOGIN", login),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
