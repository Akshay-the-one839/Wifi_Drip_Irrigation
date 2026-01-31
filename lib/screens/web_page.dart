import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebPage extends StatefulWidget {
  final String url;
  const WebPage({super.key, required this.url});

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  late final WebViewController _controller;
  bool isLoading = true;
  bool hasReloaded = false;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      _launchInBrowser(widget.url);
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => isLoading = true),
          onPageFinished: (_) => setState(() => isLoading = false),

          onWebResourceError: (error) async {
            debugPrint("WebView error: ${error.description}");

            // 🔴 Fix ERR_CACHE_MISS by force reload once
            if (!hasReloaded &&
                error.description.toLowerCase().contains("cache")) {
              hasReloaded = true;

              await _controller.clearCache();

              await _controller.loadRequest(
                Uri.parse(widget.url),
                headers: const {
                  'Cache-Control': 'no-cache, no-store, must-revalidate',
                  'Pragma': 'no-cache',
                  'Expires': '0',
                },
              );
            }
          },
        ),
      )
      ..clearCache()
      ..loadRequest(
        Uri.parse(widget.url),
        headers: const {
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      );
  }

  Future<void> _launchInBrowser(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const Scaffold(body: Center(child: Text("Opened in browser")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
