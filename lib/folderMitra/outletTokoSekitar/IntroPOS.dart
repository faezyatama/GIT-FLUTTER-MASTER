import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';
import '/base/warna.dart';

class IntroPOS extends StatefulWidget {
  @override
  _IntroPOSState createState() => _IntroPOSState();
}

class _IntroPOSState extends State<IntroPOS> {
  final c = Get.find<ApiService>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Special Promo Freshmart..!'),
        backgroundColor: Warna.warnautama,
      ),
      body: ListView(
        children: [
          Image.asset('images/whitelabelRegister/a.png'),
          Text('Catat pembukuan usaha kamu sekarang',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w200,
                  color: Warna.warnautama),
              textAlign: TextAlign.center),
          Container(
            margin: EdgeInsets.all(12),
            child: Text(
                'Sekarang cukup pakai aplikasi ${c.namaAplikasi}, semua pembukuan usaha kamu menjadi tercatat rapi baik secara online maupun offline',
                style: TextStyle(fontSize: 16, color: Warna.grey),
                textAlign: TextAlign.center),
          ),
          Container(
            margin: EdgeInsets.all(12),
            child: Text(
                'Sistem Point Of Sales (POS) ${c.namaAplikasi} membuat pencatatan transaksi menjadi lebih efektif dan efisien, kamu gak perlu lagi pikirin pembukuan yang terpisah antara penjualan online dan offline, Keuntungan usaha jadi tercatat dengan rapi',
                style: TextStyle(fontSize: 16, color: Warna.grey),
                textAlign: TextAlign.center),
          ),
          Container(
            margin: EdgeInsets.all(12),
            child: Text(
                'Ayo coba dan rasakan manfaat extra dari Fitur Premium aplikasi ${c.namaAplikasi}, Ujicoba Gratis 30 Hari',
                style: TextStyle(fontSize: 16, color: Warna.grey),
                textAlign: TextAlign.center),
          ),
          Padding(padding: EdgeInsets.only(top: 33)),
          Container(
            margin: EdgeInsets.all(22),
            child: RawMaterialButton(
              onPressed: () {},
              constraints: BoxConstraints(),
              elevation: 1.0,
              fillColor: Warna.warnautama,
              child: Text(
                'Coba 30 Hari Gratis',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              padding: EdgeInsets.fromLTRB(22, 12, 22, 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(33)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
