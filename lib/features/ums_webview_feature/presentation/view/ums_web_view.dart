import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UmsWebView extends StatefulWidget {
  const UmsWebView({super.key});

  @override
  State<UmsWebView> createState() => _UmsWebViewState();
}

class _UmsWebViewState extends State<UmsWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://ums.asu.edu.eg/App/Login_Form'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Expanded(child: WebViewWidget(controller: controller)),
      ),
    );
  }
}
