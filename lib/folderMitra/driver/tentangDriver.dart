// ROUTE SUDAH DIPERIKSA
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';
import '/base/warna.dart';

import 'daftarDriver.dart';

class TentangDriver extends StatefulWidget {
  @override
  _TentangDriverState createState() => _TentangDriverState();
}

class _TentangDriverState extends State<TentangDriver> {
  final c = Get.find<ApiService>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver/Kurir'),
        backgroundColor: Warna.warnautama,
      ),
      bottomNavigationBar: RawMaterialButton(
        onPressed: () {
          Get.off(DaftarMenjadiDriver());

          //BILA HARUS ANGGOTA UNTUK MENJADI DRIVER
          // if (c.cl.value > 0) {
          //   Get.off(DaftarMenjadiDriver());
          // } else {
          //   AwesomeDialog(
          //     context: Get.context,
          //     dialogType: DialogType.warning,
          //     animType: AnimType.rightSlide,
          //     title: 'Fitur Khusus !',
          //     desc:
          //         'Fitur ini hanya untuk anggota koperasi aktif, Menjadi anggota koperasi aktif sangat mudah loh... Cukup membayar simpanan pokok dan simpanan wajib, dan kamu bisa menikmati Fitur ini',
          //     btnCancelText: 'OK',
          //     btnCancelColor: Colors.amber,
          //     btnCancelOnPress: () {},
          //   )..show();
          // }
        },
        constraints: BoxConstraints(),
        elevation: 1.0,
        fillColor: Warna.warnautama,
        child: Text(
          'Aktifkan Akun Driver Sekarang !',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        padding: EdgeInsets.fromLTRB(22, 11, 22, 11),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(33)),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(22),
        child: ListView(
          children: [
            Text(
              'Driver / Kurir',
              style: TextStyle(
                  fontSize: 22,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w600),
            ),
            Container(
              child: Text(
                'Yuk jadikan usaha kamu lebih besar, di fitur ini kamu bisa mendapatkan banyak kesempatan untuk lebih dekat dengan pelanggan kamu. Fitur ini memungkinkan kamu untuk :',
                style: TextStyle(
                  fontSize: 16,
                  color: Warna.grey,
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 22)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1.  Menjadi driver online',
                  style: TextStyle(
                    fontSize: 18,
                    color: Warna.warnautama,
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(22, 5, 5, 22),
                  child: Text(
                    'Punya mobil / motor yang nganggur di rumah? kamu bisa manfaatkan untuk pemasukan di waktu senggang, menjadi Driver Online di ${c.namaAplikasi} sangat mudah loh',
                    style: TextStyle(
                      fontSize: 16,
                      color: Warna.grey,
                    ),
                  ),
                ),
                Text(
                  '2.  Menjadi Kurir online',
                  style: TextStyle(
                    fontSize: 18,
                    color: Warna.warnautama,
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(22, 5, 5, 22),
                  child: Text(
                    'Menjadi kurir online di ${c.namaAplikasi} sangat mudah, cukup ikuti beberapa langkah dan Akun Kurir kamu segera aktif',
                    style: TextStyle(
                      fontSize: 16,
                      color: Warna.grey,
                    ),
                  ),
                ),
                Text(
                  '3.  Membuat Layanan antar sendiri / Kurir Integrasi',
                  style: TextStyle(
                    fontSize: 18,
                    color: Warna.warnautama,
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(22, 5, 5, 22),
                  child: Text(
                    'Ingin membuat layanan antar gratis untuk pelanggan kamu? dengan fitur Kurir Integrasi di sini kamu bisa dengan mudah melayani pelanggan dan sekaligus memberikan layanan antar yang bisa kamu atur sendiri mulai dari pemilihan kurir dan pengaturan harga',
                    style: TextStyle(
                      fontSize: 16,
                      color: Warna.grey,
                    ),
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 22)),
          ],
        ),
      ),
    );
  }
}
