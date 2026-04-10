import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacypolicyController extends GetxController {
  WebViewController? webViewController;

  final isLoading = true.obs;
  final isReady = false.obs;
  final loadingProgress = 0.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initWebView();
    });
  }

  void _initWebView() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => isLoading.value = true,
        onProgress: (p) => loadingProgress.value = p,
        onPageFinished: (_) => isLoading.value = false,
        onWebResourceError: (_) => isLoading.value = false,

        onNavigationRequest: (NavigationRequest request) async {
          final url = request.url;

          if (url.startsWith('https://wa.me') ||
              url.startsWith('https://api.whatsapp.com') ||
              url.startsWith('whatsapp://')) {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
            return NavigationDecision.prevent;
          }

          if (url.startsWith('tel:')) {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
            return NavigationDecision.prevent;
          }

          if (url.startsWith('mailto:')) {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
            return NavigationDecision.prevent;
          }

          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(
        Uri.parse('https://veloxsolution.com/velox_export/privacy_policy'),
      );

    isReady.value = true;
  }
}