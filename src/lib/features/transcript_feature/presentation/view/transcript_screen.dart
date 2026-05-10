import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TranscriptScreen extends StatefulWidget {
  const TranscriptScreen({super.key});

  @override
  State<TranscriptScreen> createState() => _TranscriptScreenState();
}

class _TranscriptScreenState extends State<TranscriptScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://ums.asu.edu.eg/Services'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(child: WebViewWidget(controller: controller)),
    );
  }
}
