import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/warna.dart';

import 'dataAgen.dart';
import 'tambahAgen.dart';

class PerformaAgensi extends StatefulWidget {
  @override
  _PerformaAgensiState createState() => _PerformaAgensiState();
}

class _PerformaAgensiState extends State<PerformaAgensi> {
  final c = Get.find<ApiService>();
  var myGroup = AutoSizeGroup();
  var myGroup2 = AutoSizeGroup();

  var namaAgen1 = ''.obs;
  var namaAgen2 = ''.obs;
  var namaAgen3 = ''.obs;
  var namaAgen4 = ''.obs;
  var namaAgen5 = ''.obs;

  var jumAgen1 = ''.obs;
  var jumAgen2 = ''.obs;
  var jumAgen3 = ''.obs;
  var jumAgen4 = ''.obs;
  var jumAgen5 = ''.obs;

  var grupAgen1 = ''.obs;
  var grupAgen2 = ''.obs;
  var grupAgen3 = ''.obs;
  var grupAgen4 = ''.obs;
  var grupAgen5 = ''.obs;

  var omsetAgen1 = ''.obs;
  var omsetAgen2 = ''.obs;
  var omsetAgen3 = ''.obs;
  var omsetAgen4 = ''.obs;
  var omsetAgen5 = ''.obs;

  var bulan = ''.obs;

  @override
  void initState() {
    super.initState();
    bukaPerformance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Performa Agensi'), backgroundColor: Colors.amber),
      bottomNavigationBar: SizedBox(
        height: Get.height * 0.1,
        child: Container(
          padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(
              children: [
                Center(
                  child: Obx(() => Text(
                        c.jumlahAgen.value,
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber),
                      )),
                ),
                Center(
                  child: Text(
                    'Agen',
                    style: TextStyle(fontSize: 11, color: Warna.grey),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Center(
                  child: Obx(() => Text(
                        c.akumulasiPendapatanAgensi.value,
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber),
                      )),
                ),
                Center(
                  child: Text(
                    'Total Akumulasi Pendapatan Agensi',
                    style: TextStyle(fontSize: 11, color: Warna.grey),
                  ),
                ),
              ],
            )
          ]),
        ),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(22, 22, 22, 22),
        child: ListView(children: [
          Column(
            children: [
              Center(
                child: Text(
                  c.namaAgensi.value,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Warna.grey),
                ),
              ),
              Center(
                child: Text(
                  c.kodeAgensi.value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w200,
                      color: Warna.grey),
                ),
              ),
              Center(
                child: Text(
                  c.alamatAgensi.value,
                  style: TextStyle(fontSize: 12, color: Warna.grey),
                ),
              ),
              Center(
                child: Text(
                  c.kotaAgensi.value,
                  style: TextStyle(fontSize: 12, color: Warna.grey),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 22)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.off(DataAgenku());
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          'images/agensi/AgenGrey.png',
                          width: Get.width * 0.15,
                        ),
                        Center(
                          child: Text(
                            'Data Agen',
                            style: TextStyle(fontSize: 12, color: Warna.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.off(TambahAgen());
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          'images/agensi/TambahAgenGrey.png',
                          width: Get.width * 0.15,
                        ),
                        Center(
                          child: Text(
                            'Tambah Agen',
                            style: TextStyle(fontSize: 12, color: Warna.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Column(
                      children: [
                        Image.asset(
                          'images/agensi/Performa.png',
                          width: Get.width * 0.15,
                        ),
                        Center(
                          child: Text(
                            'Performa',
                            style: TextStyle(fontSize: 12, color: Warna.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 22)),
          Obx(() => Text(
                bulan.value,
                style: TextStyle(
                    color: Warna.warnautama,
                    fontWeight: FontWeight.w600,
                    fontSize: 22),
              )),
          Obx(() => Card(
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Image.asset(
                            'images/whitelabelMainMenu/samotor.png',
                            width: Get.width * 0.1,
                          ),
                          AutoSizeText(
                            jumAgen1.value,
                            group: myGroup,
                            style: TextStyle(
                                color: Warna.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: 22),
                          ),
                          Text(
                            'Agen',
                            style: TextStyle(color: Warna.grey, fontSize: 9),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.all(11)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AutoSizeText(
                            namaAgen1.value,
                            group: myGroup,
                            style: TextStyle(
                                color: Warna.grey,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                          AutoSizeText(
                            grupAgen1.value,
                            group: myGroup2,
                            style: TextStyle(
                              color: Warna.grey,
                            ),
                          ),
                          AutoSizeText(
                            omsetAgen1.value,
                            group: myGroup2,
                            style: TextStyle(
                              color: Warna.grey,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )),
          Obx(() => Card(
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Image.asset(
                            'images/whitelabelMainMenu/mall.png',
                            width: Get.width * 0.1,
                          ),
                          AutoSizeText(
                            jumAgen2.value,
                            group: myGroup,
                            style: TextStyle(
                                color: Warna.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: 22),
                          ),
                          Text(
                            'Agen',
                            style: TextStyle(color: Warna.grey, fontSize: 9),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.all(11)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AutoSizeText(
                            namaAgen2.value,
                            group: myGroup,
                            style: TextStyle(
                                color: Warna.grey,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                          AutoSizeText(
                            grupAgen2.value,
                            group: myGroup2,
                            style: TextStyle(
                              color: Warna.grey,
                            ),
                          ),
                          AutoSizeText(
                            omsetAgen2.value,
                            group: myGroup2,
                            style: TextStyle(
                              color: Warna.grey,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )),
          Obx(() => Card(
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Image.asset(
                            'images/whitelabelMainMenu/emoney.png',
                            width: Get.width * 0.1,
                          ),
                          AutoSizeText(
                            jumAgen3.value,
                            group: myGroup,
                            style: TextStyle(
                                color: Warna.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: 22),
                          ),
                          Text(
                            'Agen',
                            style: TextStyle(color: Warna.grey, fontSize: 9),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.all(11)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AutoSizeText(
                            namaAgen3.value,
                            style: TextStyle(
                                color: Warna.grey,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                          AutoSizeText(
                            grupAgen3.value,
                            group: myGroup2,
                            style: TextStyle(
                              color: Warna.grey,
                            ),
                          ),
                          AutoSizeText(
                            omsetAgen3.value,
                            group: myGroup2,
                            style: TextStyle(
                              color: Warna.grey,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )),
          Obx(() => Card(
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Image.asset(
                            'images/whitelabelMainMenu/myschool.png',
                            width: Get.width * 0.1,
                          ),
                          AutoSizeText(
                            jumAgen4.value,
                            group: myGroup,
                            style: TextStyle(
                                color: Warna.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: 22),
                          ),
                          Text(
                            'Agen',
                            style: TextStyle(color: Warna.grey, fontSize: 9),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.all(11)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AutoSizeText(
                            namaAgen4.value,
                            group: myGroup,
                            style: TextStyle(
                                color: Warna.grey,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                          AutoSizeText(
                            grupAgen4.value,
                            group: myGroup2,
                            style: TextStyle(
                              color: Warna.grey,
                            ),
                          ),
                          AutoSizeText(
                            omsetAgen4.value,
                            group: myGroup2,
                            style: TextStyle(
                              color: Warna.grey,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )),
          Obx(() => Card(
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Image.asset(
                            'images/whitelabelMainMenu/tokosekitar.png',
                            width: Get.width * 0.1,
                          ),
                          AutoSizeText(
                            jumAgen5.value,
                            group: myGroup,
                            style: TextStyle(
                                color: Warna.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: 22),
                          ),
                          Text(
                            'Agen',
                            style: TextStyle(color: Warna.grey, fontSize: 9),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.all(11)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AutoSizeText(
                            namaAgen5.value,
                            group: myGroup,
                            style: TextStyle(
                                color: Warna.grey,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                          AutoSizeText(
                            grupAgen5.value,
                            group: myGroup2,
                            style: TextStyle(
                              color: Warna.grey,
                            ),
                          ),
                          AutoSizeText(
                            omsetAgen5.value,
                            group: myGroup2,
                            style: TextStyle(
                              color: Warna.grey,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )),
        ]),
      ),
    );
  }

  void bukaPerformance() async {
    EasyLoading.show(status: 'Mohon tunggu kami membuka performa...');
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');

    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse('${c.baseURL}/agensi/performaAgensi');

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
        bulan.value = hasil['bulan'];
        c.jumlahAgen.value = hasil['totalAgen'];
        c.akumulasiPendapatanAgensi.value = hasil['totalPendapatan'];

        namaAgen1.value = hasil['namaAgen1'];
        namaAgen2.value = hasil['namaAgen2'];
        namaAgen3.value = hasil['namaAgen3'];
        namaAgen4.value = hasil['namaAgen4'];
        namaAgen5.value = hasil['namaAgen5'];

        jumAgen1.value = hasil['jumAgen1'];
        jumAgen2.value = hasil['jumAgen2'];
        jumAgen3.value = hasil['jumAgen3'];
        jumAgen4.value = hasil['jumAgen4'];
        jumAgen5.value = hasil['jumAgen5'];

        grupAgen1.value = hasil['grupAgen1'];
        grupAgen2.value = hasil['grupAgen2'];
        grupAgen3.value = hasil['grupAgen3'];
        grupAgen4.value = hasil['grupAgen4'];
        grupAgen5.value = hasil['grupAgen5'];

        omsetAgen1.value = hasil['omsetAgen1'];
        omsetAgen2.value = hasil['omsetAgen2'];
        omsetAgen3.value = hasil['omsetAgen3'];
        omsetAgen4.value = hasil['omsetAgen4'];
        omsetAgen5.value = hasil['omsetAgen5'];
      }
    }
  }
}
