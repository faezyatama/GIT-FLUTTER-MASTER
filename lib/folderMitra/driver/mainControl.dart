//ROUTE SUDAH DIPERIKSA
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as https;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import 'DashboardUmum.dart';
import 'dashboardIntegrasi.dart';
import 'fotoDibutuhkan.dart';
import 'tentangDriver.dart';
import 'waitingRegister.dart';

class DashboardDriver extends StatefulWidget {
  @override
  _DashboardDriverState createState() => _DashboardDriverState();
}

class _DashboardDriverState extends State<DashboardDriver> {
  final c = Get.find<ApiService>();

  var driverAktif = ''.obs;
  var judulAppBar = 'Driver Online'.obs;

  @override
  void initState() {
    super.initState();
    cekAkunDriver();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  void cekAkunDriver() async {
    EasyLoading.show(status: 'Mohon tunggu...');

    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLdriver}/mobileAppsMitraDriver/terdaftarDriver');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        if (hasil['driverAktif'] == 'Tidak Aktif') {
          Get.off(() => TentangDriver());
        } else if (hasil['driverAktif'] == 'Sukses') {
          if (hasil['integrasi'] == 'Integrasi') {
            Get.off(() => DashboardIntegrasi());
          } else {
            Get.off(() => DashboardDriverUmum());
          }
        } else if (hasil['driverAktif'] == 'Waiting') {
          Get.off(() => WaitingRegister());
        } else if (hasil['driverAktif'] == 'Foto Profil Dibutuhkan') {
          Get.off(() => FotoProfilDibuthkan());
        } else {
          Get.off(() => TentangDriver());
        }
      }
    }
  }
}
