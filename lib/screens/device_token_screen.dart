import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

import 'dashboard_screen.dart'; // change if your home screen name is different

class DeviceTokenScreen extends StatefulWidget {
  const DeviceTokenScreen({super.key});

  @override
  State<DeviceTokenScreen> createState() => _DeviceTokenScreenState();
}

class _DeviceTokenScreenState extends State<DeviceTokenScreen>
    with TickerProviderStateMixin {
  final deviceIdController = TextEditingController();
  final tokenIdController = TextEditingController();

  late AnimationController _bgController;
  late AnimationController _floatController;

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
  }

  @override
  void dispose() {
    _bgController.dispose();
    _floatController.dispose();
    deviceIdController.dispose();
    tokenIdController.dispose();
    super.dispose();
  }

  // ---------- SAVE + API ----------

  Future<void> saveAndSend() async {
    if (deviceIdController.text.trim().isEmpty ||
        tokenIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // Save locally
    await prefs.setString('device_id', deviceIdController.text.trim());
    await prefs.setString('token_id', tokenIdController.text.trim());

    // Call API in background (do not await)
    sendToServer(
      deviceIdController.text.trim(),
      tokenIdController.text.trim(),
    );

    // Go to Dashboard / Home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

 Future<void> sendToServer(
  String deviceId,
  String tokenId,
) async {
  final prefs = await SharedPreferences.getInstance();

  // Get customer IDs
  final loraMotor = prefs.getString('id_lora_motor');
  final valve = prefs.getString('id_valve');
  final onePh = prefs.getString('id_1ph');
  final threePh = prefs.getString('id_3ph');

  // Decide which customer ID to use
  String customerId = '';

  if (loraMotor != null && loraMotor.isNotEmpty) {
    customerId = loraMotor;
  } else if (valve != null && valve.isNotEmpty) {
    customerId = valve;
  } else if (threePh != null && threePh.isNotEmpty) {
    customerId = threePh;
  } else if (onePh != null && onePh.isNotEmpty) {
    customerId = onePh;
  } else {
    debugPrint("No customer ID found");
    return;
  }

  // Build dynamic URL
  final url = Uri.parse(
    "https://newqbitronics.org.in/motorpro/motorvoltvpro/sample.php"
    "?deviceid=$deviceId"
    "&tokenid=$tokenId"
    "&customerid=$customerId",
  );

  try {
    await http.get(url); // GET request
    debugPrint("API called: $url");
  } catch (e) {
    debugPrint("API error: $e");
  }
}


  // ---------- UI helpers (same style) ----------

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

  Widget floatingObjects() {
    final icons = [
      Icons.qr_code,
      Icons.key,
      Icons.cloud_done,
      Icons.security,
    ];

    return LayoutBuilder(
      builder: (_, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          children: List.generate(10, (i) {
            final x = math.Random().nextDouble() * (w - 40);
            final y = math.Random().nextDouble() * h;

            return AnimatedBuilder(
              animation: _floatController,
              builder: (_, __) {
                final offset =
                    math.sin((_floatController.value * 2 * math.pi) + i) * 10;
                return Positioned(
                  left: x,
                  top: y + offset,
                  child: Opacity(
                    opacity: 0.15,
                    child: Icon(
                      icons[i % icons.length],
                      size: 28,
                      color: const Color(0xFF4ECDC4),
                    ),
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }

  Widget glassField({
    required String hint,
    required TextEditingController controller,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A4C).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4ECDC4).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget glowButton(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Color(0xFF4ECDC4), Color(0xFF44A8A0)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4ECDC4).withOpacity(0.5),
              blurRadius: 10,
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  // ---------- BUILD ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1828),
      body: Stack(
        children: [
          animatedBackground(),
          floatingObjects(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "DEVICE REGISTRATION",
                      style: TextStyle(
                        fontSize: 22,
                        color: Color(0xFF4ECDC4),
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 30),
                    glassField(
                      hint: "Device ID",
                      controller: deviceIdController,
                    ),
                    glassField(
                      hint: "Token ID",
                      controller: tokenIdController,
                    ),
                    const SizedBox(height: 30),
                    glowButton("SAVE & CONTINUE", saveAndSend),
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
