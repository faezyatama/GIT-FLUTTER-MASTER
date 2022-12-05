// ignore: import_of_legacy_library_into_null_safe
import 'package:app_settings/app_settings.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';

import 'warna.dart';

Future<bool> cekInternet() async {
  bool conn = true;
  var connectivityResult = await (Connectivity().checkConnectivity());
  if ((connectivityResult == ConnectivityResult.mobile) ||
      (connectivityResult == ConnectivityResult.wifi)) {
    conn = true;
  } else {
    conn = false;
  }
  return conn;
}

Future<dynamic> determinePosition() async {
  final c = Get.find<ApiService>();

  Box dbbox = Hive.box<String>('sasukaDB');
  bool serviceEnabled;
  LocationPermission permission;
  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    c.sedangTampilButuhGPS.value = true;
    AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.warning,
        animType: AnimType.rightSlide,
        title: 'GPS DIBUTUHKAN',
        desc:
            'Sepertinya layanan lokasi pada perangkat ini belum diaktifkan, Silahkan Aktifkan GPS/Lokasi di bagian pengaturan',
        btnCancelText: 'Tanpa GPS',
        btnCancelColor: Colors.amber,
        btnCancelOnPress: () {
          c.sedangTampilButuhGPS.value = false;
        },
        btnOkText: 'Aktifkan GPS',
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        btnOkOnPress: () {
          c.sedangTampilButuhGPS.value = false;
          AppSettings.openLocationSettings();
        })
      ..show();

    dbbox.put('izinLokasi', 'false');
    return 'Location services are disabled.';
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'IJIN DIBUTUHKAN',
        desc:
            'Untuk menampilkan referensi terbaik di sekitar kamu mohon ijinkan sasuka untuk mengakses lokasi kamu',
        btnCancelText: 'Tidak',
        btnCancelOnPress: () {
          Get.snackbar("Lokasi tidak ditemukan",
              "beberapa fitur dalam aplikasi mungkin tidak dapat dipergunakan");
        },
        btnOkText: 'Aktifkan',
        btnOkOnPress: () {
          determinePosition();
        },
      )..show();
      dbbox.put('izinLokasi', 'false');
      return 'Location permissions are permanently denied, we cannot request permissions.';
    }

    if (permission == LocationPermission.denied) {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.warning,
        animType: AnimType.rightSlide,
        title: 'IJIN DIBUTUHKAN',
        desc:
            'Untuk menampilkan referensi terbaik di sekitar kamu mohon ijinkan sasuka untuk mengakses lokasi kamu',
        btnCancelText: 'OK SIAP',
        btnCancelColor: Colors.amber,
        btnCancelOnPress: () {},
      )..show();
      dbbox.put('izinLokasi', 'false');
      return 'Location permissions are denied';
    }
  }

  var hasil = await Geolocator.getCurrentPosition();
  c.latitude.value = hasil.latitude;
  c.longitude.value = hasil.longitude;
  dbbox.put('latLogin', hasil.latitude.toString());
  dbbox.put('longLogin', hasil.longitude.toString());
  return 'Lokasi ditemukan';
}

noInternetConnection() {
  final c = Get.find<ApiService>();

  if (c.sedangTampilNoInternet.value == false) {
    c.sedangTampilNoInternet.value = true;
    return AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
      title: '',
      desc: '',
      btnOkOnPress: () async {
        print(c.sedangTampilNoInternet.value);
        c.sedangTampilNoInternet.value = false;
        bool conn = await cekInternet();
        if (!conn) {
          return noInternetConnection();
        }
      },
      body: Column(
        children: [
          Image.asset('images/nointernet.png'),
          Text('Opps..sepertinya internet tidak ditemukan',
              style: TextStyle(
                  fontSize: 20, color: Warna.grey, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
          Container(
            padding: EdgeInsets.fromLTRB(22, 7, 22, 11),
            child: Text(
              'periksa kembali koneksi internet kamu agar ${c.namaAplikasi} bisa mencari data yang kamu perlukan',
              style: TextStyle(fontSize: 14, color: Warna.grey),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 16)),
        ],
      ),
    )..show();
  } else {
    print('dialog sedang ditampilkan');
  }
}
