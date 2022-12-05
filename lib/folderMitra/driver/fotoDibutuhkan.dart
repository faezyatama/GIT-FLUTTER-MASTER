import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/warna.dart';
import 'daftarDriver.dart';

class FotoProfilDibuthkan extends StatefulWidget {
  @override
  _FotoProfilDibuthkanState createState() => _FotoProfilDibuthkanState();
}

class _FotoProfilDibuthkanState extends State<FotoProfilDibuthkan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Berkas tidak lengkap'),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.fromLTRB(22, 0, 22, 55),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'images/antarinmotor.png',
                width: Get.width * 0.7,
              ),
              Text(
                'Opps... Sepertinya berkas yang kamu masukan belum lengkap, Kamu bisa mengulangi pengisian formulir ya..',
                style: TextStyle(
                  color: Warna.grey,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.all(11)),
              Text(
                'Pastikan semua berkas sesuai dengan persyaratan yang dibutuhkan untuk menjadi Driver/Kurir',
                style: TextStyle(
                  color: Warna.grey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.all(22)),
              ElevatedButton(
                onPressed: () {
                  Get.off(() => DaftarMenjadiDriver());
                },
                child: Text('Masukan Berkas Ulang'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
