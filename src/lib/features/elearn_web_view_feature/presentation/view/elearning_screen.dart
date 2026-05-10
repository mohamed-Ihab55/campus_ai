import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ElearningScreen extends StatefulWidget {
  const ElearningScreen({super.key});

  @override
  State<ElearningScreen> createState() => _ElearningScreenState();
}

class _ElearningScreenState extends State<ElearningScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://asu2learn.asu.edu.eg/sciencePG/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(child: WebViewWidget(controller: controller)),
    );
  }
}
