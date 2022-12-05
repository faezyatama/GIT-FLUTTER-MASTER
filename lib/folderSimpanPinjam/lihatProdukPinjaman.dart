import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/warna.dart';
import '/base/api_service.dart';
import 'detailPinjaman.dart';
import 'package:http/http.dart' as https;

import '../base/conn.dart';

class LihatProdukPinjaman extends StatefulWidget {
  @override
  State<LihatProdukPinjaman> createState() => _LihatProdukPinjamanState();
}

class _LihatProdukPinjamanState extends State<LihatProdukPinjaman> {
  final c = Get.find<ApiService>();
  var idproduk = 0;
  var header = "https://tryout.dcn-indonesia.com/img/header/header1.jpg".obs;
  var judul = "Pinjaman Koperasi".obs;
  var subJudul =
      "Koperasi mempunyai produk pinjaman yang sangat menarik untuk para anggota, segera buka rekening pinjaman dan dapatkan berbagai fasilitas menarik"
          .obs;

  @override
  void initState() {
    super.initState();
    produkPinjaman();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.warnautama,
        title: Text('Pinjaman Koperasi'),
      ),
      body: ListView(children: [
        Obx(() => CachedNetworkImage(
            width: Get.width * 0.98,
            imageUrl: header.value,
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
                      subJudul.value,
                      style: TextStyle(fontSize: 14, color: Warna.warnautama),
                    )),
                Padding(padding: EdgeInsets.only(top: 22)),
              ],
            ),
          ),
        ),
        listdaftar()
      ]),
    );
  }

  produkPinjaman() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","idProduk":"$idproduk"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();
    var url = Uri.parse('${c.baseURL}/mobileApps/produkPinjaman');

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
        header.value = hasil['header'];
        judul.value = hasil['judul'];
        subJudul.value = hasil['subJudul'];
        dataMentah = hasil['listProduk'];
        setState(() {});
      } else {
        Get.snackbar("Produk Belum Tersedia",
            'Opps... maaf saat ini produk yang kamu cari belum tersedia');
        Get.back();
      }
    }
  }

  List<dynamic> dataMentah = [];
  List<Container> listProduk = [];
  listdaftar() {
    listProduk = [];

    if (dataMentah.length > 0) {
      for (var i = 0; i < dataMentah.length; i++) {
        var produk = dataMentah[i];

        listProduk.add(
          Container(
              child: GestureDetector(
            onTap: () {
              c.jenisPinjaman = 'Pinjaman Umum';
              c.idpinjaman = produk[0];

              Get.to(DetailProdukPinjaman());
            },
            child: Container(
                child: Card(
              child: Row(
                children: [
                  Image.asset(
                    'images/whitelabelMainMenu/siwa.png',
                    width: Get.width * 0.2,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produk[1], //NAMA SIMPANAN
                        style: TextStyle(fontSize: 18, color: Warna.grey),
                      ),
                      Text(
                        produk[2], //BARIS 1
                        style: TextStyle(fontSize: 14, color: Warna.grey),
                      ),
                      Text(
                        produk[3], //BARIS 2
                        style: TextStyle(fontSize: 14, color: Warna.grey),
                      )
                    ],
                  )
                ],
              ),
            )),
          )),
        );
      }
    }
    return Column(
      children: listProduk,
    );
  }
}
