import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

splashIklan() {
  //timerSplash.cancel();
  final c = Get.find<ApiService>();

  var spl = c.splashTampil;

  if ((spl == '') && (c.splashLink != '')) {
    c.splashTampil = 'sudah tampil';
    AwesomeDialog(
      showCloseIcon: true,
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.scale,
      title: '',
      desc: '',
      body: Column(
        children: [
          GestureDetector(
              onTap: () async {
                Get.back();
                var url = c.splashLink;
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                }
              },
              child: Image.network(c.iklanSplash)),
        ],
      ),
    )..show();
  }
}
