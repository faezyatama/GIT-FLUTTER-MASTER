import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:crypto/crypto.dart';
import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../base/api_service.dart';
import '../../base/warna.dart';
import '../../folderKhusus/agency/homeAgency.dart';
import '../../folderKhusus/agency/performaAgen.dart';

class ModulAgensi extends StatefulWidget {
  @override
  State<ModulAgensi> createState() => _ModulAgensiState();
}

class _ModulAgensiState extends State<ModulAgensi> {
  final c = Get.find<ApiService>();
  //AGENCY ATAU BUKAN
  var agensi = false.obs;
  var agen = false.obs;
  var formIkutiAgen = false.obs;
  var kodeAgenKu = ''.obs;
  final controllerAgen = TextEditingController();
  final controllerSS = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() => Container(
              child: (agen.value == true)
                  ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Agen ${c.namaAplikasi} :',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w200,
                                  color: Warna.grey),
                            ),
                            Obx(() => Text(
                                  kodeAgenKu.value,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Warna.grey),
                                )),
                          ],
                        ),
                        Padding(padding: EdgeInsets.only(top: 5)),

                        Text(
                          'Saat ini kamu sudah terdaftar menjadi Agen ${c.namaAplikasi}, Kembangkan bisnisnya dan perbanyak sumber generator income',
                          style: TextStyle(color: Warna.grey),
                        ),
                        Padding(padding: EdgeInsets.only(top: 11)),
                        //apakah saya seorang agen ?
                        RawMaterialButton(
                          onPressed: () {
                            Get.to(() => PerformaAgen());
                          },
                          constraints: BoxConstraints(),
                          elevation: 1.0,
                          fillColor: Warna.warnautama,
                          child: Text(
                            'Lihat Perkembangan myAgen',
                            style: TextStyle(color: Warna.putih),
                          ),
                          padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(9)),
                          ),
                        ),
                        Divider(),
                      ],
                    )
                  : Container(),
            )),
        Obx(() => Container(
            padding: EdgeInsets.fromLTRB(12, 2, 12, 2),
            child: (agensi.value == true)
                ? ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    side:
                                        BorderSide(color: Warna.warnautama)))),
                    onPressed: () {
                      Get.back();
                      Get.to(() => HomeAgency());
                    },
                    child: Text(
                      'Dashboard Agensi',
                      style: TextStyle(color: Warna.warnautama),
                    ),
                  )
                : Container())),
      ],
    );
  }

  void cekApakahAgency() async {
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse('${c.baseURL}/agensi/cekAgensiAtauBukan');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'AGENSI') {
        agensi.value = true;
        agen.value = false;
        formIkutiAgen.value = false;

        c.namaAgensi.value = hasil['nama'];
        c.kodeAgensi.value = hasil['kode'];
        c.alamatAgensi.value = hasil['alamat'];
        c.kotaAgensi.value = hasil['kota'];
        c.jumlahAgen.value = hasil['jumlahAgen'].toString();
        c.akumulasiPendapatanAgensi.value = hasil['akumulasiPendapatan'];
      } else if (hasil['status'] == 'AGEN') {
        agensi.value = false;
        agen.value = true;
        formIkutiAgen.value = false;
        kodeAgenKu.value = hasil['kodeAgen'];
      } else if (hasil['status'] == 'IKUTI AGEN') {
        agensi.value = false;
        agen.value = false;
        formIkutiAgen.value = true;
      } else if (hasil['status'] == 'PENGGUNA BARU') {
        agensi.value = false;
        agen.value = false;
        formIkutiAgen.value = false;
      } else {
        agensi.value = false;
        agen.value = false;
        formIkutiAgen.value = false;
      }
    }
  }

  void periksaKodeAgen() async {
    var kodeAgen = controllerAgen.text;

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    //item search

    var datarequest = '{"pid":"$pid","kodeAgen":"$kodeAgen"}';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse('${c.baseURL}/agensi/cekKodeAgen');

    final response = await http.post(url, body: {
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
        controllerAgen.text = '';
        var nama = hasil['nama'];
        var kodeAgn = hasil['kode'];
        var foto = hasil['foto'];

        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: '',
          desc: '',
          body: Column(
            children: [
              Image.network(
                foto,
                width: Get.width * 0.3,
              ),
              Padding(padding: EdgeInsets.only(top: 9)),
              Text(nama,
                  style: TextStyle(
                      fontSize: 18,
                      color: Warna.grey,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
              Text(
                kodeAgn,
                style: TextStyle(fontSize: 14, color: Warna.grey),
              ),
              Divider(
                color: Warna.grey,
              ),
              Text(
                  'Apakah kamu bersedia dibimbing agen ini untuk mendapatkan manfaat lebih dari penggunaan aplikasi ${c.namaAplikasi} ???',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center),
              Padding(padding: EdgeInsets.only(top: 8)),
              ElevatedButton(
                  onPressed: () {
                    prosesIkutiAgen(kodeAgn);
                  },
                  child: Text('Ok, Proses Sekarang !')),
            ],
          ),
        )..show();
      } else {
        controllerSS.text = '';
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.warning,
          animType: AnimType.rightSlide,
          title: 'Pencarian Gagal',
          desc: 'Opps... sepertinya kode Agen yang kamu masukan tidak sesuai',
          btnCancelText: 'OK SIAP',
          btnCancelColor: Colors.amber,
          btnCancelOnPress: () {},
        )..show();
      }
    }
  }

  void prosesIkutiAgen(kodeAgn) async {
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    //item search

    var datarequest = '{"pid":"$pid","kodeAgen":"$kodeAgn"}';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse('${c.baseURL}/agensi/ikutiAgenIni');

    final response = await http.post(url, body: {
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
        formIkutiAgen.value = false;
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'PROSES BERHASIL',
          desc: hasil['message'],
          btnCancelText: 'OK SIAP',
          btnCancelColor: Colors.green,
          btnCancelOnPress: () {
            Get.back();
            Get.back();
          },
        )..show();
      } else {
        Get.back();
        Get.back();
        Get.snackbar('Error...!', hasil['message'],
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }
}
