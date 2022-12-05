import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:satuaja/base/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../base/warna.dart';

class ModulPrivacyPolicy extends StatelessWidget {
  final c = Get.find<ApiService>();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            await launchUrl(Uri.parse('${c.baseURL}/privacyPolicy'));
          },
          child: Center(
            child: Text(
              'Dengan menggunakan aplikasi ini maka anda setuju dengan Kebijakan Privasi kami. Klik untuk membuka Kebijakan Privasi',
              textAlign: TextAlign.center,
              style: TextStyle(color: Warna.warnautama, fontSize: 10),
            ),
          ),
        ),
        Padding(padding: EdgeInsets.only(top: 5)),
        Center(
          child: Text(
            '${c.namaAplikasi}',
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ),
        Center(
          child: Text(
            c.versiApkSaarini,
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ),
        Padding(padding: EdgeInsets.only(top: 22)),
      ],
    );
  }
}
