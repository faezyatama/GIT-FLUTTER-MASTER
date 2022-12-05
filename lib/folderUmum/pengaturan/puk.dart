import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';
import '/base/warna.dart';

class PinUnblock extends StatelessWidget {
  final cpassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(top: 55),
      children: [
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/Gembok.png',
                width: Get.width * 0.3,
              ),
              Padding(padding: EdgeInsets.only(bottom: 10)),
              Text(
                'Menunggu PIN Sementara',
                style: TextStyle(fontSize: 22, color: Warna.grey),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
                child: Text(
                  'Silahkan cek kotak masuk SMS untuk mendapatkan PIN sementara, Setelah itu masukan ke kolom dibawah ini untuk membuat PIN baru',
                  style: TextStyle(fontSize: 14, color: Warna.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              RawMaterialButton(
                onPressed: () {
                  c.pinBlokir.value = 'aktif';
                },
                constraints: BoxConstraints(),
                elevation: 1.0,
                fillColor: Warna.warnautama,
                child: Text(
                  '  Masukan PIN Baru  ',
                  style: TextStyle(color: Warna.putih),
                ),
                padding: EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(22)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  final c = Get.find<ApiService>();
}
