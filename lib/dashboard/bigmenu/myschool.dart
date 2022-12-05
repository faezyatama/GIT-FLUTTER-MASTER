import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../base/api_service.dart';
import '../../base/warna.dart';

// ignore: must_be_immutable
class MyschoolMenu extends StatelessWidget {
  var lebar = 0.25;
  var myGroup = AutoSizeGroup();
  final c = Get.find<ApiService>();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width * lebar,
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              var ss = Hive.box<String>('sasukaDB').get('kodess');
              var apiToken = Hive.box<String>('sasukaDB').get('apiToken');

              String encoded = base64.encode(utf8.encode(ss));
              String encoded2 = base64.encode(utf8.encode(encoded));
              String packageName = c.packageName;
              var url =
                  'sisuka://sisuka.cloud/user/login_satuaja/$encoded2/$apiToken/$packageName';
              // print(url);
              try {
                await launchUrl(Uri.parse(url));
              } catch (error) {
                await launchUrl(Uri.parse(
                    'https://play.google.com/store/apps/details?id=id.sisuka.app'));
              }
            },
            child: Column(
              children: [
                Image.asset(
                  'images/whitelabelMainMenu/myschool.png',
                  width: Get.width * 0.18,
                ),
                AutoSizeText(
                  'My School',
                  style: TextStyle(color: Warna.grey),
                  group: myGroup,
                  maxLines: 1,
                )
              ],
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 10)),
        ],
      ),
    );
  }
}
