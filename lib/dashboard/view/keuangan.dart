import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../base/notifikasiBuatAkun.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import 'package:http/http.dart' as http;

import '../../folderUmum/transaksi/kirim.dart';
import '../../folderUmum/transaksi/terima.dart';
import '../../folderUmum/transaksi/viewTopup.dart';

class Keuangan extends StatefulWidget {
  @override
  _KeuanganState createState() => _KeuanganState();
}

class _KeuanganState extends State<Keuangan> {
  Box dbbox = Hive.box<String>('sasukaDB');
  final c = Get.put(ApiService());
  var myGroup = AutoSizeGroup();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(Get.width * 0.05, 5, Get.width * 0.05, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          (c.loginAsPenggunaKita.value == 'Member')
              ? GestureDetector(
                  onTap: () {
                    if (c.clLogo.value == 'REGULER') {
                      // Get.to(() => ChannellinkREG());
                    } else if (c.clLogo.value == 'SILVER') {
                      // Get.to(() => ChannellinkSIL());
                    } else if (c.clLogo.value == 'GOLD') {
                      // Get.to(() => ChannellinkGOLD());
                    } else if (c.clLogo.value == 'PLATINUM') {
                      //Get.to(() => ChannellinkPLAT());
                    } else if (c.clLogo.value == 'INVINITY') {
                      // Get.to(() => ChannellinkINV());
                    } else {
                      // Get.to(() => ChannellinkREG());
                    }
                  },
                  child: Obx(() => Image.asset(
                        'images/${c.clLogo.value}.png',
                        width: Get.width * 0.1,
                      )),
                )
              : Padding(padding: EdgeInsets.only(right: 5)),
          Obx(() => Container(
              child: (c.loginAsPenggunaKita.value == 'Member')
                  ? GestureDetector(
                      onTap: () {
                        cekSaldokuDulu();
                      },
                      child: SizedBox(
                        width: Get.width * 0.4,
                        child: Obx(() => AutoSizeText(
                              c.saldo.value,
                              style: TextStyle(color: Warna.grey),
                              maxLines: 1,
                              presetFontSizes: [22, 18, 15],
                            )),
                      ),
                    )
                  : (c.cekLoginStatus.value == 'loading')
                      ? SizedBox(
                          width: Get.width * 0.1,
                          child: CircularProgressIndicator(
                            color: Colors.grey,
                          ))
                      : RawMaterialButton(
                          onPressed: () {
                            var judulF = 'Masuk ke Akun';
                            var subJudul =
                                'Untuk masuk ke akun kamu silahkan pilih login atau mulai dengan membuat akun baru dengan langkah yang mudah ';

                            bukaLoginPage(judulF, subJudul);
                          },
                          constraints: BoxConstraints(),
                          fillColor: Colors.white,
                          child: Row(
                            children: [
                              Icon(
                                Icons.login,
                                color: Warna.warnautama,
                              ),
                              Text(
                                ' Masuk ke Akun',
                                style: TextStyle(
                                    color: Warna.warnautama, fontSize: 12),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.fromLTRB(11, 4, 11, 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(19)),
                          ),
                        ))),
          Padding(padding: EdgeInsets.only(right: 5)),
          SizedBox(
            width: Get.width * 0.37,
            child: Row(
              children: [
                SizedBox(
                  width: Get.width * 0.11,
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => KirimSaldo());
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'images/kirim.png',
                          width: Get.width * 0.08,
                        ),
                        AutoSizeText(
                          'Kirim',
                          style: TextStyle(color: Warna.grey),
                          group: myGroup,
                          maxLines: 1,
                        )
                      ],
                    ),
                  ),
                ),
                //
                Padding(padding: EdgeInsets.only(right: 8)),

                SizedBox(
                  width: Get.width * 0.11,
                  child: GestureDetector(
                    onTap: () {
                      if (c.loginAsPenggunaKita.value == 'Member') {
                        Get.to(() => TerimaSaldo());
                      } else {
                        var judulF = 'Terima Saldo';
                        var subJudul =
                            'Cukup Scan QR Code teman kamu dan transfer, Mudah bukan ?, Yuk Buka akun koperasi di aplikasi ${c.namaAplikasi} sekarang';

                        bukaLoginPage(judulF, subJudul);
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'images/terima.png',
                          width: Get.width * 0.08,
                        ),
                        AutoSizeText(
                          'Terima',
                          style: TextStyle(color: Warna.grey),
                          group: myGroup,
                          maxLines: 1,
                        )
                      ],
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(right: 5)),

                SizedBox(
                  width: Get.width * 0.11,
                  child: GestureDetector(
                    onTap: () {
                      if (c.loginAsPenggunaKita.value == 'Member') {
                        Get.to(() => ViewTopup());
                      } else {
                        var judulF = 'Top Up Saldo';
                        var subJudul =
                            'Top up saldo kamu melalui bank dan mulailah bertransaksi bersama ${c.namaAplikasi}, Mudah bukan ?, Yuk Buka akun koperasi di aplikasi ${c.namaAplikasi} sekarang';

                        bukaLoginPage(judulF, subJudul);
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'images/topup.png',
                          width: Get.width * 0.08,
                        ),
                        AutoSizeText(
                          'Topup',
                          style: TextStyle(color: Warna.grey),
                          group: myGroup,
                          maxLines: 1,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    //keuangan
  }

  void cekSaldokuDulu() async {
    bool conn = await cekInternet();
    if (!conn) {
      return;
    }
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/ceksaldo');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
    });
    //print(response.body);

    // EasyLoading.dismiss();
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        c.saldo.value = hasil['saldo'];
        c.saldoInt.value = hasil['saldoInt'];
      }
    }
  }
}
