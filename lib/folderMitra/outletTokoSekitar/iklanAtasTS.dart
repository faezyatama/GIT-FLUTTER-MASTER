import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';

class IklanAtasTS extends StatefulWidget {
  @override
  _IklanAtasTSState createState() => _IklanAtasTSState();
}

class _IklanAtasTSState extends State<IklanAtasTS> {
  var imgList = [];
  final c = Get.find<ApiService>();

  @override
  void initState() {
    super.initState();
    iklantengah();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(5, 11, 5, 5),
        child: CarouselSlider(
          options: CarouselOptions(
            //height: 400,
            aspectRatio: 10 / 4,
            viewportFraction: 1,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 3),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            //onPageChanged: callbackFunction,
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
        ));
    //end iklan
  }

  void iklantengah() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/cekIklanAtasWL');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
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
