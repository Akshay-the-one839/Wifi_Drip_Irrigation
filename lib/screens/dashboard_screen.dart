import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi_drip_irrigation/screens/web_page.dart';
import 'dart:math' as math;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  static const String link1ph =
      "https://newqbitronics.org.in/motorv12/motorvoltv12/cdevicelist.php?&customerid=";
  static const String link3ph =
      "https://newqbitronics.org.in/motorpro/motorvoltvpro/cdevicelist.php?&customerid=";
  static const String linkValve =
      "https://newqbitronics.org.in/WIFIVALVE8/wivalve8/cdevicelist.php?&customerid=";
  static const String linkLoraWan =
      "https://qbitronics.com/Lorawan24/motorlora/cdevicelist.php?&customerid=";

  late AnimationController _bgController;
  late AnimationController _floatController;

  bool isLoading = true;
  final Map<String, String> savedIds = {};

  // ---------------- DEVICE CONFIG ----------------

  final List<Map<String, String>> devices = [
    {'title': '1 Phase Motor Controller', 'key': 'id_1ph', 'url': link1ph},
    {'title': '3 Phase Motor Controller', 'key': 'id_3ph', 'url': link3ph},
    {'title': 'WiFi Valve Controller', 'key': 'id_valve', 'url': linkValve},
    {
      'title': 'LoRa-WAN Motor Controller',
      'key': 'id_lora_motor',
      'url': linkLoraWan,
    },
    {
      'title': 'LoRa-WAN Valve Controller',
      'key': 'id_lora_valve',
      'url': linkLoraWan,
    },
  ];

  @override
  void initState() {
    super.initState();
    loadSavedIds();
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
    super.dispose();
  }

  // ---------------- LOAD SAVED IDS ----------------

  Future<void> loadSavedIds() async {
    final prefs = await SharedPreferences.getInstance();

    for (final device in devices) {
      final key = device['key']!;
      final value = prefs.getString(key);

      if (value != null && value.trim().isNotEmpty) {
        savedIds[key] = value;
      }
    }

    setState(() => isLoading = false);
  }

  Future<void> openLink(
    BuildContext context,
    String key,
    String baseUrl,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(key);

    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("ID not saved")));
      return;
    }

    final url = baseUrl + id;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WebPage(url: url)),
    );
  }

  // ---------- UI ELEMENTS ----------

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

  Widget floatingDashboardObjects() {
    final leftIcons = [Icons.electric_meter, Icons.speed, Icons.bolt];
    final rightIcons = [Icons.wifi, Icons.water, Icons.settings];

    return Stack(
      children: [
        // Left side
        ...List.generate(leftIcons.length, (index) {
          return AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              final offset =
                  math.sin((_floatController.value * 2 * math.pi) + index) * 10;
              return Positioned(
                left: 15,
                top: 100.0 + index * 60 + offset,
                child: Opacity(
                  opacity: 0.25,
                  child: Icon(
                    leftIcons[index],
                    size: 40, // smaller
                    color: Colors.white.withOpacity(0.25),
                  ),
                ),
              );
            },
          );
        }),
        // Right side
        ...List.generate(rightIcons.length, (index) {
          return AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              final offset =
                  math.cos((_floatController.value * 2 * math.pi) + index) * 10;
              return Positioned(
                right: 15,
                top: 120.0 + index * 65 + offset,
                child: Opacity(
                  opacity: 0.25,
                  child: Icon(
                    rightIcons[index],
                    size: 40, // smaller
                    color: Colors.white.withOpacity(0.25),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget glowButton(String text, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 280, // smaller width
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 14), // smaller padding
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF4ECDC4), Color(0xFF44A8A0)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4ECDC4).withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14, // smaller font
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget titleBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 8,
      ), // smaller
      decoration: BoxDecoration(
        color: const Color(0xFF4ECDC4).withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18, // smaller
          color: Color(0xFF4ECDC4),
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ---------- BUILD ----------

  // ---------------- BUILD ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1828),
      body: Stack(
        children: [
          animatedBackground(),
          floatingDashboardObjects(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    titleBadge("DASHBOARD"),
                    const SizedBox(height: 30),

                    if (isLoading)
                      const CircularProgressIndicator()
                    else if (savedIds.isEmpty)
                      const Text(
                        "No controllers configured.\nPlease add IDs in Smart Settings.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      )
                    else
                      ...devices
                          .where((d) => savedIds.containsKey(d['key']))
                          .map(
                            (d) => glowButton(
                              d['title']!,
                              () => openLink(context, d['key']!, d['url']!),
                            ),
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
