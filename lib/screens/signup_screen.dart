import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'menu_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmController = TextEditingController();

  bool showPass = false;
  bool showConfirm = false;

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
    loadSavedCredentials();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    emailController.dispose();
    passController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    final String? savedEmail = prefs.getString('email');
    final String? savedPassword = prefs.getString('password');

    if (savedEmail != null && savedEmail.isNotEmpty) {
      emailController.text = savedEmail;
    }

    if (savedPassword != null && savedPassword.isNotEmpty) {
      passController.text = savedPassword;
    }
  }

  // ------------------ VALIDATION ------------------
  bool isValidEmail(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    final regex = RegExp(
      r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$',
    );
    return regex.hasMatch(password);
  }

  // ------------------ SAVE USER ------------------
  Future<void> saveUser() async {
    String email = emailController.text.trim();
    String password = passController.text.trim();
    String confirm = confirmController.text.trim();

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      showErrorDialog("All fields are required");
      return;
    }

    if (!isValidEmail(email)) {
      showErrorDialog("Invalid email format");
      return;
    }

    if (!isValidPassword(password)) {
      showErrorDialog(
        "Password must be 8+ chars, include uppercase, number & special char",
      );
      return;
    }

    if (password != confirm) {
      showErrorDialog("Passwords do not match");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MenuScreen()),
    );
  }

  // ------------------ CLEAR FIELDS ------------------
  // ------------------ CLEAR FIELDS ------------------
  Future<void> clearFields() async {
    // Clear text controllers
    emailController.clear();
    passController.clear();
    confirmController.clear();

    // Delete from SharedPreferences - THIS WAS MISSING!
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');

    setState(() {
      showPass = false;
      showConfirm = false;
    });
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E3A4C),
        content: Text(message, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Color(0xFF4ECDC4))),
          ),
        ],
      ),
    );
  }

  // ------------------ UI WIDGETS ------------------
  Widget glassField(TextField field) {
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
      child: field,
    );
  }

  Widget glowButton(String text, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        width: 200,
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

  Widget clearFieldsButton() {
    return TextButton(
      onPressed: () async {
        await clearFields(); // Added async/await
      },
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF4ECDC4),
        textStyle: const TextStyle(
          fontSize: 14,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: const Text("CLEAR FIELDS"),
    );
  }

  Widget animatedBackground() {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (_, __) => Container(
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
      ),
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
                  Icons.person_add,
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
          ],
        );
      },
    );
  }

  // ------------------ BUILD ------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1828),
      body: Stack(
        children: [
          animatedBackground(),
          floatingOrbs(),
          iconDecoration(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                        "SIGN UP",
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
                        TextField(
                          controller: emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Email",
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.email_rounded,
                              color: Color(0xFF4ECDC4),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 320,
                      child: glassField(
                        TextField(
                          controller: passController,
                          obscureText: !showPass,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Password",
                            hintStyle: const TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                            prefixIcon: const Icon(
                              Icons.lock_rounded,
                              color: Color(0xFF4ECDC4),
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                showPass
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                color: const Color(0xFF4ECDC4),
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => showPass = !showPass),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 320,
                      child: glassField(
                        TextField(
                          controller: confirmController,
                          obscureText: !showConfirm,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Confirm Password",
                            hintStyle: const TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                            prefixIcon: const Icon(
                              Icons.lock_rounded,
                              color: Color(0xFF4ECDC4),
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                showConfirm
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                color: const Color(0xFF4ECDC4),
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => showConfirm = !showConfirm),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),
                    glowButton("SIGN UP", saveUser),
                    const SizedBox(height: 10),
                    clearFieldsButton(),
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
