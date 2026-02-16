import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'menu_screen.dart';
import 'dart:math' as math;
import 'device_token_screen.dart';

class SmartSettingsScreen extends StatefulWidget {
  const SmartSettingsScreen({super.key});

  @override
  State<SmartSettingsScreen> createState() => _SmartSettingsScreenState();
}

class _SmartSettingsScreenState extends State<SmartSettingsScreen>
    with TickerProviderStateMixin {
  final id1phController = TextEditingController();
  final id3phController = TextEditingController();
  final idValveController = TextEditingController();
  final loraMotorIdController = TextEditingController();
  final loraValveIdController = TextEditingController();
  final id3phChangeoverController = TextEditingController();

  late AnimationController _bgController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();

    loadSavedIDs();

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
    id1phController.dispose();
    id3phController.dispose();
    idValveController.dispose();
    loraMotorIdController.dispose();
    loraValveIdController.dispose();
    id3phChangeoverController.dispose();
    super.dispose();
  }

  // ---------- Storage ----------

  Future<void> loadSavedIDs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      id1phController.text = prefs.getString('id_1ph') ?? '';
      id3phController.text = prefs.getString('id_3ph') ?? '';
      idValveController.text = prefs.getString('id_valve') ?? '';
      loraMotorIdController.text = prefs.getString('id_lora_motor') ?? '';
      loraValveIdController.text = prefs.getString('id_lora_valve') ?? '';
      id3phChangeoverController.text =
          prefs.getString('id_3ph_changeover') ?? '';
    });
  }

  Future<void> saveSingleID(
    String key,
    TextEditingController controller,
  ) async {
    if (controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Field cannot be empty")));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, controller.text.trim());

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Saved successfully")));

    // Navigate to MenuScreen after saving
   Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => const DeviceTokenScreen()),
);

  }

  Future<void> clearAllIDs() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('id_1ph');
    await prefs.remove('id_3ph');
    await prefs.remove('id_valve');
    await prefs.remove('id_lora_motor');
    await prefs.remove('id_lora_valve');
    await prefs.remove('id_3ph_changeover');

    setState(() {
      id1phController.clear();
      id3phController.clear();
      idValveController.clear();
      loraMotorIdController.clear();
      loraValveIdController.clear();
      id3phChangeoverController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All IDs cleared successfully")),
    );
  }

  void confirmClearAll() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E3A4C),
        title: const Text("Confirm", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to delete all saved IDs?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              clearAllIDs();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
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
      Icons.badge,
      Icons.qr_code,
      Icons.key,
      Icons.settings,
      Icons.storage,
      Icons.account_box,
    ];

    return LayoutBuilder(
      builder: (_, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        final centerTop = screenHeight * 0.25;
        final centerBottom = screenHeight * 0.7;

        return Stack(
          children: List.generate(12, (index) {
            final randX = math.Random().nextDouble() * (screenWidth - 40);
            double randY = index.isEven
                ? math.Random().nextDouble() * centerTop
                : centerBottom +
                      math.Random().nextDouble() *
                          (screenHeight - centerBottom);

            return AnimatedBuilder(
              animation: _floatController,
              builder: (_, __) {
                final offset =
                    math.sin((_floatController.value * 2 * math.pi) + index) *
                    10;
                return Positioned(
                  left: randX,
                  top: randY + offset,
                  child: Opacity(
                    opacity: 0.15 + (index % 3) * 0.05,
                    child: Icon(
                      icons[index % icons.length],
                      size: 25 + (index % 2) * 5,
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
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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

  Widget glowButtonSmall(String text, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF4ECDC4), Color(0xFF44A8A0)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4ECDC4).withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  // ---------- Field with SAVE button ----------

  Widget fieldWithSave(
    String title,
    TextEditingController controller,
    String key,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              flex: 5,
              child: glassField(hint: "", controller: controller),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 80,
              child: glowButtonSmall(
                "SAVE",
                () => saveSingleID(key, controller),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------- Build ----------

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
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
                        "SMART SETTINGS",
                        style: TextStyle(
                          fontSize: 22,
                          color: Color(0xFF4ECDC4),
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    fieldWithSave(
                      "1 - Phase Customer ID",
                      id1phController,
                      'id_1ph',
                    ),
                    const SizedBox(height: 16),
                    fieldWithSave(
                      "3 - Phase Customer ID",
                      id3phController,
                      'id_3ph',
                    ),
                    const SizedBox(height: 16),
                    fieldWithSave(
                      "Valve Customer ID",
                      idValveController,
                      'id_valve',
                    ),
                    const SizedBox(height: 16),
                    fieldWithSave(
                      "LORA-WAN MOTOR ID",
                      loraMotorIdController,
                      'id_lora_motor',
                    ),
                    const SizedBox(height: 16),
                    fieldWithSave(
                      "LORA-WAN VALVE ID",
                      loraValveIdController,
                      'id_lora_valve',
                    ),
                    const SizedBox(height: 16),
                    fieldWithSave(
                      "3-Phase Changeover ID",
                      id3phChangeoverController,
                      'id_3ph_changeover',
                    ),

                    const SizedBox(height: 30),
                    TextButton(
                      onPressed: confirmClearAll,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF4ECDC4),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text("CLEAR FIELDS"),
                    ),
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
