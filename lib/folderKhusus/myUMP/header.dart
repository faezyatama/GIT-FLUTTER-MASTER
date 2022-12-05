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

class IklanRitzuka extends StatefulWidget {
  @override
  _IklanRitzukaState createState() => _IklanRitzukaState();
}

class _IklanRitzukaState extends State<IklanRitzuka> {
  @override
  void initState() {
    super.initState();
    cekIklanAtas();
  }

  final c = Get.find<ApiService>();
  var imgList = [];

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
        child: Column(children: <Widget>[
          CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              aspectRatio: 2.65,
              enlargeCenterPage: true,
              scrollDirection: Axis.vertical,
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

  void cekIklanAtas() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');

    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse('${c.baseURL}/sasuka/cekIklanRitz');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    // EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        setState(() {
          imgList = hasil['data'];
        });
      }
    }
  }
}
