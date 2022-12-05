import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:crypto/crypto.dart';
import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../base/api_service.dart';
import '../../base/conn.dart';
import '../../base/warna.dart';
import '../../folderSimpanPinjam/homepinjaman.dart';
import '../../folderSimpanPinjam/homesimpanan.dart';
import '../../folderSimpanPinjam/lihatProdukPinjaman.dart';
import '../../folderSimpanPinjam/lihatProdukSimpanan.dart';

// ignore: must_be_immutable
class KspMenu extends StatelessWidget {
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
              pilihSimpanPinjam();
            },
            child: Column(
              children: [
                Image.asset(
                  'images/whitelabelMainMenu/simpanpinjam.png',
                  width: Get.width * 0.18,
                ),
                AutoSizeText(
                  'Layanan Simpan Pinjam',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Warna.grey),
                  group: myGroup,
                  maxLines: 4,
                )
              ],
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 10)),
        ],
      ),
    );
  }

  pilihSimpanPinjam() {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Text(
            c.namaAplikasi,
            style: TextStyle(fontSize: 18, color: Warna.grey),
          ),
          Text(
            'Unit Simpan Pinjam (USP)',
            style: TextStyle(fontSize: 12, color: Warna.grey),
          ),
          Container(
            padding: EdgeInsets.all(11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: Get.width * 0.33,
                  child: GestureDetector(
                    onTap: () {
                      if (c.loginAsPenggunaKita.value == 'Member') {
                        cekPunyaSimpananTidak();
                      } else {
                        Get.snackbar('Akun dibutuhkan',
                            'Silahkan membuat akun terlebih dahulu untuk mengakses fitur ini');
                      }
                    },
                    child: Column(
                      children: [
                        Image.asset(
                            'images/whitelabelMainMenu/iconsimpanan.png',
                            width: Get.width * 0.12),
                        Text(
                          'Produk Simpanan',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: Get.width * 0.33,
                  child: GestureDetector(
                    onTap: () {
                      if (c.loginAsPenggunaKita.value == 'Member') {
                        cekPunyaPinjamanTidak();
                      } else {
                        Get.snackbar('Akun Dibutuhkan',
                            'Silahkan login terlebihdahulu untuk mengakses layanan ini');
                      }
                    },
                    child: Column(
                      children: [
                        Image.asset(
                            'images/whitelabelMainMenu/iconpinjaman.png',
                            width: Get.width * 0.12),
                        Text(
                          'Produk Pinjaman',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )..show();
  }

  cekPunyaSimpananTidak() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();
    var url = Uri.parse('${c.baseURL}/mobileApps/cekPunyaSimpananTidak');

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
        Get.back();
        Get.to(HomeSimpanan());
      } else {
        Get.back();
        Get.to(LihatProdukSimpanan());
      }
    }
  }

  cekPunyaPinjamanTidak() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();
    var url = Uri.parse('${c.baseURL}/mobileApps/cekPunyaPinjamanTidak');

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
        Get.back();
        Get.to(HomePinjaman());
      } else {
        Get.back();
        Get.to(LihatProdukPinjaman());
      }
    }
  }
}
