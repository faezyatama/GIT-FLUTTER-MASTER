import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import 'package:http/http.dart' as https;
import 'pembayaranPickup.dart';

class PilihDriverPickup extends StatefulWidget {
  @override
  _PilihDriverPickupState createState() => _PilihDriverPickupState();
}

class _PilihDriverPickupState extends State<PilihDriverPickup> {
  @override
  void initState() {
    super.initState();
    cekDriver();
  }

  final c = Get.find<ApiService>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Driver'),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(11),
        child: RawMaterialButton(
          onPressed: () {
            Get.to(() => PembayaranPerjalananPickup());
          },
          constraints: BoxConstraints(),
          elevation: 1.0,
          fillColor: Colors.blue,
          child: Text(
            'Lanjutkan Pemesanan',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          padding: EdgeInsets.fromLTRB(22, 15, 22, 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.map,
                  size: 33,
                  color: Warna.grey,
                ),
                SizedBox(
                  width: Get.width * 0.6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lokasi Tujuan',
                        style: TextStyle(
                            color: Warna.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        c.alamatTujuanPickup.value,
                        style: TextStyle(
                            color: Warna.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        'Ket : ${c.ketTujuanPickup.value}',
                        style: TextStyle(
                            color: Warna.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                ),
                RawMaterialButton(
                  onPressed: () {
                    Get.back();
                    Get.back();
                  },
                  constraints: BoxConstraints(),
                  elevation: 1.0,
                  fillColor: Colors.amber,
                  child: Text(
                    'Ganti',
                    style: TextStyle(color: Colors.white),
                  ),
                  padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(9)),
                  ),
                )
              ],
            ),
          ),
          Divider(),
          Container(
            padding: EdgeInsets.all(11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.location_city,
                  size: 33,
                  color: Warna.grey,
                ),
                SizedBox(
                  width: Get.width * 0.6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lokasi Penjemputan',
                        style: TextStyle(
                            color: Warna.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        c.alamatJemputPickup.value,
                        style: TextStyle(
                            color: Warna.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        'Ket : ${c.ketJemputPickup.value}',
                        style: TextStyle(
                            color: Warna.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                ),
                RawMaterialButton(
                  onPressed: () {
                    Get.back();
                  },
                  constraints: BoxConstraints(),
                  elevation: 1.0,
                  fillColor: Colors.amber,
                  child: Text(
                    'Ganti',
                    style: TextStyle(color: Colors.white),
                  ),
                  padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(9)),
                  ),
                )
              ],
            ),
          ),
          Divider(),
          Container(
            padding: EdgeInsets.all(11),
            child: Text(
              'Pilih Driver',
              style: TextStyle(
                  color: Warna.grey, fontSize: 14, fontWeight: FontWeight.w400),
            ),
          )
        ],
      ),
    );
  }

  void cekDriver() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var latitude = c.latitude.value;
    var longitude = c.longitude.value;

    var datarequest = '{"pid":"$pid","lat":"$latitude","long":"$longitude"}';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse('${c.baseURL}/sasuka/cekDriver');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    // EasyLoading.dismiss();

    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {}
    }
  }
}
