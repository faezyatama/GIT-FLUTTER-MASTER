import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import 'package:http/http.dart' as https;

class AturStokProduk extends StatefulWidget {
  @override
  _AturStokProdukState createState() => _AturStokProdukState();
}

class _AturStokProdukState extends State<AturStokProduk> {
  var gunakanStok = false.obs;
  var stokdibawah0 = false.obs;
  final c = Get.find<ApiService>();

  @override
  void initState() {
    super.initState();
    cekMetodeStok();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Atur Stok Produk'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(22, 11, 22, 11),
        child: ListView(
          children: [
            Text(
              'Mudahnya mengatur stok di POS Toko Sekitar',
              style: TextStyle(
                  color: Colors.green,
                  fontSize: 23,
                  fontWeight: FontWeight.w200),
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            Text(
              'Sistem stok memudahkan kamu dalam menghitung jumlah barang yang tersedia dan jumlah barang yang terjual.',
              style: TextStyle(color: Warna.grey, fontSize: 14),
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            Text(
              'Dengan mengaktifkan perhitungan stok, maka kamu bisa mendapatkan laporan Stok Barang secara terperinci.',
              style: TextStyle(color: Warna.grey, fontSize: 14),
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            Text(
              'Metode perhitungan yang digunakan adalah metode FIFO/First In First Out dari setiap produk untuk menentukan nilai HPP/Harga Pokok Pembelian/Harga Modal',
              style: TextStyle(color: Warna.grey, fontSize: 14),
            ),
            Padding(padding: EdgeInsets.only(top: 33)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: Get.width * 0.65,
                  child: Text('Gunakan perhitungan stok',
                      style: TextStyle(color: Warna.grey, fontSize: 18)),
                ),
                Obx(() => Checkbox(
                      value: gunakanStok.value,
                      onChanged: (newValue) {
                        gunakanHitunganStok(newValue);
                      },
                    )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: Get.width * 0.65,
                  child: Text('Ijinkan stok dibawah 0 untuk tetap dapat dijual',
                      style: TextStyle(color: Warna.grey, fontSize: 18)),
                ),
                Obx(() => Checkbox(
                      value: stokdibawah0.value,
                      onChanged: (newValue) {
                        stok0dijual(newValue);
                      },
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void gunakanHitunganStok(bool newValue) async {
    //  print(newValue);
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');

    //PARAMETER BUKA OUTLET
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","value":"$newValue"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLtokosekitar}/mobileAppsOutlet/gunakanStok');

    final response = await https.post(url, body: {
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
        Get.snackbar('Berhasil..!!', 'Pengaturan stok produk telah di set');
        var hasilnya = hasil['value'];
        if (hasilnya == 'true') {
          gunakanStok.value = true;
        } else {
          gunakanStok.value = false;
        }
      }
    }
  }

  void stok0dijual(bool newValue) async {
    //  print(newValue);
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');

    //PARAMETER BUKA OUTLET
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","value":"$newValue"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLtokosekitar}/mobileAppsOutlet/dibawahNol');

    final response = await https.post(url, body: {
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
        Get.snackbar('Berhasil..!!', 'Pengaturan stok produk telah di set');
        var hasilnya = hasil['value'];
        if (hasilnya == 'true') {
          stokdibawah0.value = true;
        } else {
          stokdibawah0.value = false;
        }
      }
    }
  }

  void cekMetodeStok() async {
    //  print(newValue);
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');

    //PARAMETER BUKA OUTLET
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLtokosekitar}/mobileAppsOutlet/loadMetodeStok');

    final response = await https.post(url, body: {
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
        gunakanStok.value = hasil['gunakanStok'];
        stokdibawah0.value = hasil['dibawahNol'];
      }
    }
  }
}
