// ROUTE SUDAH DIPERIKSA
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';
import '/base/warna.dart';

class WaitingRegister extends StatefulWidget {
  @override
  _WaitingRegisterState createState() => _WaitingRegisterState();
}

class _WaitingRegisterState extends State<WaitingRegister> {
  final c = Get.find<ApiService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menunggu Verifikasi'),
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
                'Mohon tunggu, berkas kamu sedang dalam proses pemeriksaan ${c.namaAplikasi}. ',
                style: TextStyle(
                  color: Warna.grey,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.only(top: 22)),
              Text(
                'Pemberitahuan melalui Whatsapp akan dikirimkan ke nomor terdaftar apabila pendaftaran driver telah berhasil.',
                style: TextStyle(
                  color: Warna.grey,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}
