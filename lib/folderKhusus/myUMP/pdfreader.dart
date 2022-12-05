import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PdfReader extends StatefulWidget {
  @override
  _PdfReaderState createState() => _PdfReaderState();
}

class _PdfReaderState extends State<PdfReader> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Syarat & Ketentuan'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        padding: EdgeInsets.only(top: 22),
        child: WebView(
          initialUrl: 'https://syarat-ketentuan.satuaja.id',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {},
        ),
      ),
    );
  }
}
