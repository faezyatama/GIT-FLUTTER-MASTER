import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/warna.dart';
import 'package:http/http.dart' as https;
import '../base/api_service.dart';
import '../base/conn.dart';
import 'formBukaPinjaman.dart';
import 'simulasiKredit.dart';
import 'sedangDalamProses.dart';

class DetailProdukPinjaman extends StatefulWidget {
  @override
  State<DetailProdukPinjaman> createState() => _DetailProdukPinjamanState();
}

class _DetailProdukPinjamanState extends State<DetailProdukPinjaman> {
  @override
  void initState() {
    super.initState();
    detailSimpanan();
  }

  final c = Get.find<ApiService>();
  var gambar = ''.obs;
  var judul = ''.obs;
  var manfaat = ''.obs;
  var syarat = ''.obs;
  var baris1 = ''.obs;
  var baris2 = ''.obs;
  var baris3 = ''.obs;
  var baris4 = ''.obs;
  var baris5 = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.warnautama,
        title: Text("Detail Produk Pinjaman"),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(5),
        height: Get.height * 0.1,
        color: Color.fromARGB(255, 230, 229, 229),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RawMaterialButton(
              onPressed: () {
                Get.to(SimulasiKredit());
              },
              constraints: BoxConstraints(),
              elevation: 1.0,
              fillColor: Colors.amber,
              child: Text(
                'Simulasi',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Warna.putih),
              ),
              padding: EdgeInsets.fromLTRB(22, 8, 22, 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(33)),
              ),
            ),
            RawMaterialButton(
              onPressed: () {
                cekAdaRequestPermohonanPinjaman();
                // Get.to(FormBukaPinjaman());
              },
              constraints: BoxConstraints(),
              elevation: 1.0,
              fillColor: Warna.warnautama,
              child: Text(
                'Ajukan Pinjaman !',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Warna.putih),
              ),
              padding: EdgeInsets.fromLTRB(33, 8, 33, 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(33)),
              ),
            ),
          ],
        ),
      ),
      body: ListView(children: [
        Obx(() => CachedNetworkImage(
            width: Get.width * 0.9,
            imageUrl: gambar.value,
            errorWidget: (context, url, error) {
              print(error);
              return Icon(Icons.error);
            })),
        Container(
          padding: EdgeInsets.all(12),
          child: Center(
            child: Column(
              children: [
                Obx(() => Text(
                      judul.value,
                      style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w200,
                          color: Warna.warnautama),
                    )),
                Obx(() => Text(
                      manfaat.value,
                      style: TextStyle(fontSize: 14, color: Warna.warnautama),
                    )),
                Padding(padding: EdgeInsets.only(top: 22)),
                Container(
                  child: Row(
                    children: [
                      Image.asset(
                        'images/whitelabelMainMenu/iconsimpanan.png',
                        width: Get.width * 0.2,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            judul.value,
                            style: TextStyle(fontSize: 18, color: Warna.grey),
                          ),
                          Text(
                            baris1.value,
                            style: TextStyle(fontSize: 14, color: Warna.grey),
                          ),
                          Text(
                            baris2.value,
                            style: TextStyle(fontSize: 14, color: Warna.grey),
                          ),
                          Text(
                            baris3.value,
                            style: TextStyle(fontSize: 14, color: Warna.grey),
                          ),
                          Text(
                            baris4.value,
                            style: TextStyle(fontSize: 14, color: Warna.grey),
                          ),
                          Text(
                            baris5.value,
                            style: TextStyle(fontSize: 14, color: Warna.grey),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 22)),
                Text(
                  syarat.value,
                  style: TextStyle(fontSize: 14, color: Warna.warnautama),
                ),
              ],
            ),
          ),
        )
      ]),
    );
  }

  detailSimpanan() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');
    var idproduk = c.idpinjaman;
    var produk = c.jenisPinjaman;

    var datarequest =
        '{"pid":"$pid","idProduk":"$idproduk","produk":"$produk"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();
    var url = Uri.parse('${c.baseURL}/mobileApps/detailProdukPinjaman');

    final response = await https.post(url, body: {
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
        c.simpananPilihan = hasil['judul'];
        gambar.value = hasil['gambar'];
        judul.value = hasil['judul'];
        manfaat.value = hasil['manfaat'];
        syarat.value = hasil['syarat'];
        baris1.value = hasil['baris1'];
        baris2.value = hasil['baris2'];
        baris3.value = hasil['baris3'];
        baris4.value = hasil['baris4'];
        baris5.value = hasil['baris5'];
        setState(() {});
      } else {
        Get.snackbar("Produk Belum Tersedia",
            'Opps... maaf saat ini produk yang kamu cari belum tersedia');
        Get.back();
      }
    }
  }

  cekAdaRequestPermohonanPinjaman() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","idProduk":"${c.idpinjaman}","jenisPinjaman":"${c.jenisPinjaman}"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();
    var url =
        Uri.parse('${c.baseURL}/mobileApps/cekAdaRequestPermohonanPinjaman');

    final response = await https.post(url, body: {
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
        Get.to(FormBukaPinjaman());
      } else if (hasil['status'] == 'waiting approval') {
        Get.to(SedangDalamProses());
      } else {
        Get.snackbar('Tidak dapat membuka rekening',
            'Opps saat ini pembukaan rekening belum dapat dilakukan');
      }
    }
  }
}
