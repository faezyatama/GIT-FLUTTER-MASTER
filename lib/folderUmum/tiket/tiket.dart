import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as https;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TiketSatuAja extends StatefulWidget {
  @override
  _TiketSatuAjaState createState() => _TiketSatuAjaState();
}

class _TiketSatuAjaState extends State<TiketSatuAja> {
  final c = Get.find<ApiService>();

  final String cookieValue = 'some-cookie-value';
  final String domain = 'tiket-sasuka.com';
  final String cookieName = 'some_cookie_name';

  get http => null;

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
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(top: 22),
            child: WebView(
              initialUrl: c.urlTiket.value,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
              onPageStarted: (String url) {
                print('Page started loading: $url');
              },
              onPageFinished: (String url) {
                analisaURLuntukTiket(url);
              },
            ),
          ),
        ],
      ),
    );
  }

  void analisaURLuntukTiket(String urlKirimA) async {
    var urlkirim = urlKirimA;
    //base64Encode(bytesUrl);
    var cek1 = urlKirimA.contains('&code=');
    var cek2 = urlKirimA.contains('process=Cek+Pemesanan');
    var cek3 = urlKirimA.contains('https://tiket-sasuka.com/cek-pemesanan');

    if ((cek1 == true) && (cek2 == true) && (cek3 == true)) {
      print('booking berhasil dilakukan');
      bool conn = await cekInternet();
      if (!conn) {
        return noInternetConnection();
      }
      Box dbbox = Hive.box<String>('sasukaDB');
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');

      var datarequest = '{"pid":"$pid","urlKirim":"$urlkirim"}';
      var bytes = utf8.encode(datarequest + '$token');
      var signature = md5.convert(bytes).toString();
      var user = dbbox.get('loginSebagai');

      var url = Uri.parse('${c.baseURL}/sasuka/booking');

      final response = await https.post(url, body: {
        "user": user,
        "appid": c.appid,
        "data_request": datarequest,
        "sign": signature
      });

      print(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> hasil = jsonDecode(response.body);
        if (hasil['status'] == 'success') {
          print(hasil['message']);
        }
      }
    }
  }
}
