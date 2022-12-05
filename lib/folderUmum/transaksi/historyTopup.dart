import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import 'package:http/http.dart' as http;

class HistoryTopup extends StatefulWidget {
  @override
  _HistoryTopupState createState() => _HistoryTopupState();
}

class _HistoryTopupState extends State<HistoryTopup> {
  @override
  void initState() {
    super.initState();

    cekHistory();
  }

  final c = Get.find<ApiService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      children: [
        listdaftar(),
      ],
    ));
  }

  cekHistory() async {
    //LOAD DATA TOPUP

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/cekHistoryTopup');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        setState(() {
          dataHistory = hasil['data'];
          listdaftar();
        });
      }
    }
    //END LOAD DATA TOP UP
  }

  List dataHistory = [];
  listdaftar() {
    List<Container> listbank = [];
    if (dataHistory.length > 0) {
      for (var i = 0; i < dataHistory.length; i++) {
        var valHistory = dataHistory[i];

        listbank.add(
          Container(
            padding: EdgeInsets.only(left: 11, right: 11),
            child: SizedBox(
                height: Get.height * 0.12,
                child: Card(
                  child: Container(
                    padding: EdgeInsets.only(left: 5, right: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.network(
                          valHistory[0],
                          width: Get.width * 0.2,
                        ),
                        Container(
                          width: Get.width * 0.45,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Top up saldo',
                                style:
                                    TextStyle(fontSize: 12, color: Warna.grey),
                              ),
                              Text(
                                valHistory[1],
                                style:
                                    TextStyle(fontSize: 20, color: Warna.grey),
                              ),
                              Padding(padding: EdgeInsets.only(top: 4)),
                              Text(
                                valHistory[2],
                                style:
                                    TextStyle(fontSize: 11, color: Warna.grey),
                              ),
                            ],
                          ),
                        ),
                        Image.asset(
                          'images/${valHistory[3]}',
                          width: Get.width * 0.16,
                        )
                      ],
                    ),
                  ),
                )),
          ),
        );
      }
    } else {
      listbank.add(
        Container(
          padding: EdgeInsets.only(top: 55),
          child: Column(children: [
            Image.asset('images/nodata.png', width: Get.width * 0.75),
            Container(
              padding: EdgeInsets.only(left: 44, right: 44),
              child: Text(
                'Opps... Sepertinya belum ada topup yang dilakukan',
                style: TextStyle(fontSize: 18, color: Warna.grey),
                textAlign: TextAlign.center,
              ),
            )
          ]),
        ),
      );
    }
    return Column(
      children: listbank,
    );
  }
}
