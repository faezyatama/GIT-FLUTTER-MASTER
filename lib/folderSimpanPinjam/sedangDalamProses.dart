import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/warna.dart';
import '/dashboard/view/dashboard.dart';

class SedangDalamProses extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dalam Proses'),
        backgroundColor: Warna.warnautama,
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(22, 55, 22, 11),
        child: ListView(children: [
          CachedNetworkImage(
              width: Get.width * 0.7,
              imageUrl: 'https://images.sasuka.online/umum/onproses.png',
              errorWidget: (context, url, error) {
                print(error);
                return Icon(Icons.error);
              }),
          Padding(padding: EdgeInsets.only(top: 33)),
          Text(
            'Sedang Dalam Proses',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w200,
                color: Warna.warnautama),
          ),
          Text(
            'Mohon tunggu saat ini berkas kamu sedang dalam pemeriksaan, apabila disetujui kamu akan mendapatkan pemberitahuan. Terima Kasih.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Warna.grey),
          ),
        ]),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(5),
        height: Get.height * 0.08,
        child: RawMaterialButton(
          onPressed: () {
            Get.offAll(Dashboardku());
          },
          constraints: BoxConstraints(),
          elevation: 1.0,
          fillColor: Warna.warnautama,
          child: Text(
            'Kembali Ke Menu Utama',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w300, color: Warna.putih),
          ),
          padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(33)),
          ),
        ),
      ),
    );
  }
}
