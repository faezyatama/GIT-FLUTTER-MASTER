import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
// ignore: import_of_legacy_library_into_null_safe
// ignore: import_of_legacy_library_into_null_safe
import 'package:carousel_slider/carousel_slider.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';

class IklanTengah extends StatefulWidget {
  @override
  _IklanTengahState createState() => _IklanTengahState();
}

class _IklanTengahState extends State<IklanTengah> {
  @override
  void initState() {
    super.initState();
    cekIklanTengahOK();
  }

  final c = Get.find<ApiService>();
  var imgList = [];

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
        child: Column(children: <Widget>[
          CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              aspectRatio: 2.8,
              enlargeCenterPage: true,
              scrollDirection: Axis.horizontal,
            ),
            items: imgList
                .map((item) => Container(
                      child: Center(
                          child: Image(
                              image:
                                  CachedNetworkImageProvider(item.toString()))),
                      color: Colors.white,
                    ))
                .toList(),
          )
        ]));
    //end iklan
  }

  void cekIklanTengahOK() async {
    bool conn = await cekInternet();
    if (!conn) {
      return;
    }
    if (c.refiklantengah == '') {
//BODY YANG DIKIRIM
      Box dbbox = Hive.box<String>('sasukaDB');
      var pid = dbbox.get('person_id');

      var user = 'Non Registered User';
      var datarequest = '{"pid":"$pid"}';
      var bytes = utf8.encode(datarequest + 'cbf4aq3' + user + c.appid);
      var signature = md5.convert(bytes).toString();

      var url = Uri.parse('${c.baseURL}/mobileApps/cekIklanTengahWL');

      final response = await http.post(url, body: {
        "user": user,
        "appid": c.appid,
        "data_request": datarequest,
        "sign": signature
      });

      // EasyLoading.dismiss();
      // print(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> hasil = jsonDecode(response.body);
        if (hasil['status'] == 'success') {
          c.refiklanatas = response.body;
          setState(() {
            imgList = hasil['data'];
          });
        }
      }
    } else {
      Map<String, dynamic> hasil = jsonDecode(c.refiklanatas);
      if (hasil['status'] == 'success') {
        setState(() {
          imgList = hasil['data'];
        });
      }
    }
  }
}
