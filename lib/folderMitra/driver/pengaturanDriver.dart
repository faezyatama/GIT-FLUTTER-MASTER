//ROUTE SUDAH DIPERIKSA
import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import 'pengaturanUlangDriver.dart';
import 'package:http/http.dart' as https;

class PengaturanDriver extends StatefulWidget {
  @override
  _PengaturanDriverState createState() => _PengaturanDriverState();
}

class _PengaturanDriverState extends State<PengaturanDriver> {
  final c = Get.find<ApiService>();
  final controllerPin = TextEditingController();

  var nama = ''.obs;
  var foto = ''.obs;
  var ss = ''.obs;
  var pids = ''.obs;
  var onoff = ''.obs;
  var layanan = ''.obs;
  var kendaraan = ''.obs;
  var merek = ''.obs;
  var platnomor = ''.obs;
  var terimaKurir = ''.obs;
  var maksimalorder = ''.obs;
  var metode = ''.obs;

  @override
  void initState() {
    super.initState();
    cekDataDriver();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan Driver'),
        backgroundColor: Warna.warnautama,
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.fromLTRB(22, 8, 22, 8),
        height: Get.height * 0.06,
        child: RawMaterialButton(
          onPressed: () {
            Get.to(() => AturUlangDriver());
          },
          constraints: BoxConstraints(),
          elevation: 1.0,
          fillColor: Warna.warnautama,
          child: Text(
            'Atur ulang / Pindah layanan',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          padding: EdgeInsets.fromLTRB(22, 6, 22, 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(33)),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(22),
        child: ListView(
          children: [
            Padding(padding: EdgeInsets.only(top: 11)),
            Obx(() => Container(
                  width: Get.width * 0.3,
                  height: Get.width * 0.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: NetworkImage(foto.value), fit: BoxFit.fitHeight),
                  ),
                )),
            Obx(() => Text(
                  nama.value,
                  style: TextStyle(color: Warna.grey, fontSize: 22),
                  textAlign: TextAlign.center,
                )),
            Obx(() => Text(
                  '${ss.value} / ${pids.value}',
                  style: TextStyle(color: Warna.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                )),
            Padding(padding: EdgeInsets.only(top: 15)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status',
                  style: TextStyle(color: Warna.grey),
                ),
                Row(
                  children: [
                    Obx(() => RawMaterialButton(
                          onPressed: () {
                            onlineOffline();
                          },
                          constraints: BoxConstraints(),
                          elevation: 0,
                          fillColor: (c.btnOnlineOffline.value == 'Online')
                              ? Warna.warnautama
                              : Colors.grey,
                          child: Text(
                            c.btnOnlineOffline.value,
                            style: TextStyle(color: Warna.putih, fontSize: 14),
                          ),
                          padding: EdgeInsets.fromLTRB(8, 1, 8, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(9)),
                          ),
                        )),
                    Icon(
                      Icons.edit,
                      color: Warna.warnautama,
                      size: 18,
                    )
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Layanan Driver',
                  style: TextStyle(color: Warna.grey),
                ),
                Obx(() => Text(
                      layanan.value,
                      style: TextStyle(
                          color: Warna.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    )),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kendaraan',
                  style: TextStyle(color: Warna.grey),
                ),
                Obx(() => Text(
                      kendaraan.value,
                      style: TextStyle(
                          color: Warna.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    )),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Merek / Type',
                  style: TextStyle(color: Warna.grey),
                ),
                Obx(() => Text(
                      merek.value,
                      style: TextStyle(
                          color: Warna.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    )),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Plat Nomor',
                  style: TextStyle(color: Warna.grey),
                ),
                Obx(() => Text(
                      platnomor.value,
                      style: TextStyle(
                          color: Warna.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    )),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            Padding(padding: EdgeInsets.only(top: 33)),
            Obx(() => Container(
                child: (layanan.value != 'Integrasi')
                    ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Terima Order Belanja / Kurir',
                                style: TextStyle(color: Warna.grey),
                              ),
                              Row(
                                children: [
                                  Obx(() => RawMaterialButton(
                                        onPressed: () {
                                          terimaOrderKurirTidak();
                                        },
                                        constraints: BoxConstraints(),
                                        elevation: 0,
                                        fillColor:
                                            (terimaKurir.value == 'Aktif')
                                                ? Warna.warnautama
                                                : Colors.grey,
                                        child: Text(
                                          terimaKurir.value,
                                          style: TextStyle(
                                              color: Warna.putih, fontSize: 14),
                                        ),
                                        padding:
                                            EdgeInsets.fromLTRB(8, 1, 8, 1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(9)),
                                        ),
                                      )),
                                  Icon(
                                    Icons.edit,
                                    color: Warna.warnautama,
                                    size: 18,
                                  )
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Maksimal Order Belanja',
                                style: TextStyle(color: Warna.grey),
                              ),
                              Row(
                                children: [
                                  Obx(() => RawMaterialButton(
                                        onPressed: () {
                                          setBelanjaMaksimal();
                                        },
                                        constraints: BoxConstraints(),
                                        elevation: 0,
                                        fillColor:
                                            (terimaKurir.value == 'Aktif')
                                                ? Warna.warnautama
                                                : Colors.grey,
                                        child: Text(
                                          maksimalorder.value,
                                          style: TextStyle(
                                              color: Warna.putih, fontSize: 14),
                                        ),
                                        padding:
                                            EdgeInsets.fromLTRB(8, 1, 8, 1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(9)),
                                        ),
                                      )),
                                  Icon(
                                    Icons.edit,
                                    color: Warna.warnautama,
                                    size: 18,
                                  )
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'AutoBid',
                                style: TextStyle(color: Warna.grey),
                              ),
                              Row(
                                children: [
                                  Obx(() => RawMaterialButton(
                                        onPressed: () {
                                          autoBid();
                                        },
                                        constraints: BoxConstraints(),
                                        elevation: 0,
                                        fillColor: (metode.value == 'Aktif')
                                            ? Warna.warnautama
                                            : Colors.grey,
                                        child: Text(
                                          metode.value,
                                          style: TextStyle(
                                              color: Warna.putih, fontSize: 14),
                                        ),
                                        padding:
                                            EdgeInsets.fromLTRB(8, 1, 8, 1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(9)),
                                        ),
                                      )),
                                  Icon(
                                    Icons.edit,
                                    color: Warna.warnautama,
                                    size: 18,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    : Container())),
          ],
        ),
      ),
    );
  }

  void cekDataDriver() async {
    bool conn = await cekInternet();
    if (!conn) {
      return;
    }

    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLdriver}/mobileAppsMitraDriver/CekPengaturanDriver');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    // EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        nama.value = hasil['status'];
        foto.value = hasil['foto'];
        nama.value = hasil['nama'];
        ss.value = hasil['kodepromo'];
        pids.value = hasil['person_id'];
        c.btnOnlineOffline.value = hasil['onoff'];
        layanan.value = hasil['layanan'];
        kendaraan.value = hasil['kendaraan'];
        merek.value = hasil['merek'];
        platnomor.value = hasil['platnomor'];
        terimaKurir.value = hasil['kurir'];
        maksimalorder.value = hasil['maxorder'];
        metode.value = hasil['autobid'];
      }
    }
  }

  void onlineOffline() async {
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var onoff = c.btnOnlineOffline.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","onoff":"$onoff"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLdriver}/mobileAppsMitraDriver/onlineOffline');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        c.btnOnlineOffline.value = hasil['onoff'];
      } else {
        Get.snackbar('Belum dapat online', hasil['message']);
      }
    }
  }

  void terimaOrderKurirTidak() async {
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var terima = terimaKurir.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","onoff":"$terima"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLdriver}/mobileAppsMitraDriver/onoffKurir');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        terimaKurir.value = hasil['onoff'];
      }
    }
  }

  void autoBid() async {
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var metodeKurir = metode.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","onoff":"$metodeKurir"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLdriver}/mobileAppsMitraDriver/onoffAutobid');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        metode.value = hasil['onoff'];
      }
    }
  }

  void setBelanjaMaksimal() {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Text('Atur batas maksimal pembelanjaan yang dapat kamu terima',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center),
          Padding(padding: EdgeInsets.only(top: 9)),
          Padding(padding: EdgeInsets.only(top: 16)),
          Container(
            width: Get.width * 0.7,
            child: TextField(
              textAlign: TextAlign.center,
              maxLength: 7,
              style: TextStyle(
                  fontSize: 25, fontWeight: FontWeight.w600, color: Warna.grey),
              controller: controllerPin,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.money),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          RawMaterialButton(
            constraints: BoxConstraints(minWidth: Get.width * 0.7),
            elevation: 1.0,
            fillColor: Warna.warnautama,
            child: Text(
              'Atur batas maksimal',
              style: TextStyle(color: Warna.putih, fontSize: 14),
            ),
            padding: EdgeInsets.fromLTRB(18, 9, 18, 9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            onPressed: () {
              if ((controllerPin.text == '')) {
                controllerPin.text = '';
                Get.back();
                AwesomeDialog(
                  context: Get.context,
                  dialogType: DialogType.noHeader,
                  animType: AnimType.rightSlide,
                  title: 'PERHATIAN !',
                  desc: 'Nilai tidak dimasukan dengan benar',
                  btnCancelText: 'OK',
                  btnCancelColor: Colors.amber,
                  btnCancelOnPress: () {},
                )..show();
              } else {
                Get.back();
                aturMaksimalBelanja(controllerPin.text);
              }
            },
          ),
        ],
      ),
    )..show();
  }

  void aturMaksimalBelanja(nilai) async {
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","nilai":"$nilai"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLdriver}/mobileAppsMitraDriver/onoffMaksimalBelanja');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        maksimalorder.value = hasil['nilai'];
      }
    }
  }
}
