import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InAppBrowserScreen extends StatefulWidget {
  final String url;
  final String title;

  const InAppBrowserScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<InAppBrowserScreen> createState() => _InAppBrowserScreenState();
}

class _InAppBrowserScreenState extends State<InAppBrowserScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<bool> _onWillPop() async {
    final canGoBack = await _controller.canGoBack();
    if (canGoBack) {
      await _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                if (await _controller.canGoBack()) {
                  await _controller.goBack();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () async {
                if (await _controller.canGoForward()) {
                  await _controller.goForward();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _controller.reload(),
            ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading) const LinearProgressIndicator(minHeight: 2),
          ],
        ),
      ),
    );
  }
}
