import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as https;
import 'package:crypto/crypto.dart';
import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/dashboard/view/dashboard.dart';
import '../base/api_service.dart';
import '../base/conn.dart';
import '../base/warna.dart';
import 'lihatProdukPinjaman.dart';
import 'lihatProdukSimpanan.dart';

class ListProdukPinjaman extends StatefulWidget {
  @override
  State<ListProdukPinjaman> createState() => _ListProdukPinjamanState();
}

class _ListProdukPinjamanState extends State<ListProdukPinjaman> {
  final c = Get.find<ApiService>();
  var autoDebet = 'Tidak'.obs;
  var idBayar = 0.obs;
  var intBayarBulanan = 0.obs;
  var bunga = ''.obs;
  var pokok = ''.obs;
  var denda = ''.obs;
  var bayarBulananRp = ''.obs;
  var periode = ''.obs;

  @override
  void initState() {
    super.initState();
    cekFiturAutodebetDanCicilan();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height * 0.2,
      child: Container(
        padding: EdgeInsets.all(12),
        child: Center(
          child: Column(
            children: [
              Text(
                "Pinjaman :",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w200,
                    color: Warna.warnautama),
              ),
              Padding(padding: EdgeInsets.only(top: 11)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(padding: EdgeInsets.only(left: 3)),
                  SizedBox(
                    width: Get.width * 0.23,
                    child: GestureDetector(
                      onTap: () {
                        if (c.loginAsPenggunaKita.value == 'Member') {
                          Get.off(LihatProdukPinjaman());
                        } else {
                          var judulF = 'Produk Pinjaman';
                          var subJudul =
                              'Silahkan membuat akun terlebih dahulu';
                          Get.snackbar(judulF, subJudul);
                        }
                      },
                      child: Column(
                        children: [
                          Image.asset(
                              'images/whitelabelMainMenu/iconpinjaman.png',
                              width: Get.width * 0.12),
                          Text(
                            'Lihat Produk Pinjaman',
                            style: TextStyle(color: Warna.grey, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: Get.width * 0.23,
                    child: GestureDetector(
                      onTap: () {
                        if (c.loginAsPenggunaKita.value == 'Member') {
                          pinDibutuhkanBayarPinjaman();
                        } else {
                          var judulF = 'Produk Simpanan Berjangka';
                          var subJudul =
                              'Silahkan membuat akun terlebih dahulu';
                          Get.snackbar(judulF, subJudul);
                        }
                      },
                      child: Column(
                        children: [
                          Image.asset('images/whitelabelMainMenu/siwa.png',
                              width: Get.width * 0.12),
                          Text(
                            'Bayar Pinjaman',
                            style: TextStyle(color: Warna.grey, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: Get.width * 0.23,
                    child: GestureDetector(
                      onTap: () {
                        if (autoDebet.value == 'Ya') {
                          AwesomeDialog(
                            context: Get.context,
                            dialogType: DialogType.noHeader,
                            animType: AnimType.rightSlide,
                            title: 'AutoDebet Aktif',
                            desc:
                                'Saat ini autodebet telah aktif, pastikan saldo pada rekening cukup pada saat jatuh tempo pembayaran kredit. Terima kasih',
                            btnOkText: 'OK SIAP',
                            btnOkOnPress: () {},
                          )..show();
                        } else {
                          pinDibutuhkanAutoDebet();
                        }
                      },
                      child: Column(
                        children: [
                          Image.asset('images/whitelabelMainMenu/autodebet.png',
                              width: Get.width * 0.12),
                          Text(
                            'AutoDebet Pinjaman',
                            style: TextStyle(color: Warna.grey, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(left: 3)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  cekFiturAutodebetDanCicilan() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","norekPinjaman":"${c.nomorRekeningPilihan}"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();
    var url = Uri.parse('${c.baseURL}/mobileApps/cekFiturAutodebetDanCicilan');

    final response = await https.post(url, body: {
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
        autoDebet.value = hasil['autoDebet'];
        idBayar.value = hasil['idBayar'];
        intBayarBulanan.value = hasil['intBayarBulanan'];
        bunga.value = hasil['bunga'];
        pokok.value = hasil['pokok'];
        denda.value = hasil['denda'];
        bayarBulananRp.value = hasil['bayarBulananRp'];
        periode.value = hasil['periode'];
      } else {
        Get.snackbar('Access Resticted', 'No Access Allowed',
            snackPosition: SnackPosition.BOTTOM);
        Get.back();
      }
    }
  }

  pinDibutuhkanBayarPinjaman() {
    final controllerPin = TextEditingController();
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [],
          ),
          Image.asset(
            'images/whitelabelMainMenu/siwa.png',
            width: Get.width * 0.3,
          ),
          Text('PIN DIBUTUHKAN UNTUK BAYAR CICILAN PINJAMAN',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w600)),
          Padding(padding: EdgeInsets.only(top: 14)),
          Text(
            'Pembayaran Kredit No.',
            style: TextStyle(fontSize: 16, color: Warna.grey),
            textAlign: TextAlign.center,
          ),
          Text(
            '${c.nomorRekeningPilihan}',
            style: TextStyle(
                fontSize: 16, color: Warna.grey, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          Text(
            '$periode',
            style: TextStyle(
                fontSize: 16, color: Warna.grey, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          Divider(),
          Text(
            'Pokok Pinjaman : Rp. ' + pokok.value,
            style: TextStyle(fontSize: 14, color: Warna.grey),
            textAlign: TextAlign.center,
          ),
          Text(
            'Bunga Pinjaman : Rp. ' + bunga.value,
            style: TextStyle(fontSize: 14, color: Warna.grey),
            textAlign: TextAlign.center,
          ),
          (denda.value != '0')
              ? Text(
                  'Denda Terlambat : Rp. ' + denda.value,
                  style: TextStyle(fontSize: 14, color: Warna.grey),
                  textAlign: TextAlign.center,
                )
              : Container(),
          Divider(),
          Text(
            'Rp. ' + bayarBulananRp.value,
            style: TextStyle(fontSize: 20, color: Warna.warnautama),
            textAlign: TextAlign.center,
          ),
          Padding(padding: EdgeInsets.only(top: 14)),
          Text('Silahkan masukan PIN kamu untuk melakukan pembayaran',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center),
          Padding(padding: EdgeInsets.only(top: 16)),
          Container(
            width: Get.width * 0.7,
            child: TextField(
              obscureText: true,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: TextStyle(
                  fontSize: 25, fontWeight: FontWeight.w600, color: Warna.grey),
              controller: controllerPin,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.vpn_key),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RawMaterialButton(
                constraints: BoxConstraints(minWidth: Get.width * 0.7),
                elevation: 1.0,
                fillColor: Warna.warnautama,
                child: Text(
                  'Proses Pembayaran',
                  style: TextStyle(color: Warna.putih, fontSize: 14),
                ),
                padding: EdgeInsets.fromLTRB(18, 9, 18, 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                ),
                onPressed: () {
                  if ((controllerPin.text == '') ||
                      (controllerPin.text.length != 6)) {
                    controllerPin.text = '';
                    Get.snackbar('PERHATIAN...',
                        'Pin tidak dimasukan dengan benar, Pin hanya berisi 6 angka');
                  } else {
                    bayarPinjaman(controllerPin.text);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    )..show();
  }

  bayarPinjaman(pin) async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","pin":"$pin","idBayar":"$idBayar","norekPinjaman":"${c.nomorRekeningPilihan}"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();
    var url = Uri.parse('${c.baseURL}/mobileApps/bayarPinjamanViaSS');

    final response = await https.post(url, body: {
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
        AwesomeDialog(
          context: Get.context,
          dismissOnBackKeyPress: false,
          dismissOnTouchOutside: false,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: 'Pembayaran Berhasil',
          desc: 'Terima kasih telah melakukan pembayaran pinjaman',
          btnOkText: 'OK SIAP',
          btnOkOnPress: () {
            Get.offAll(Dashboardku());
          },
        )..show();
      } else {
        Get.snackbar(
            "Pembayaran Gagal", 'Pembayaran via saldo ss gagal dilakukan');
        Get.to(LihatProdukSimpanan());
      }
    }
  }

  pinDibutuhkanAutoDebet() {
    final controllerPin = TextEditingController();
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [],
          ),
          Image.asset(
            'images/whitelabelMainMenu/autodebet.png',
            width: Get.width * 0.5,
          ),
          Text('PIN DIBUTUHKAN UNTUK AUTODEBET',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w600)),
          Text(
            'AutoDebet akan diaktifkan pada nomor rekening simpanan kamu pada saat awal pencairan pinjaman',
            style: TextStyle(fontSize: 14, color: Warna.grey),
            textAlign: TextAlign.center,
          ),
          Padding(padding: EdgeInsets.only(top: 9)),
          Text('Silahkan masukan PIN kamu untuk mengaktifkan AutoDebet',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center),
          Padding(padding: EdgeInsets.only(top: 16)),
          Container(
            width: Get.width * 0.7,
            child: TextField(
              obscureText: true,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: TextStyle(
                  fontSize: 25, fontWeight: FontWeight.w600, color: Warna.grey),
              controller: controllerPin,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.vpn_key),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RawMaterialButton(
                constraints: BoxConstraints(minWidth: Get.width * 0.7),
                elevation: 1.0,
                fillColor: Warna.warnautama,
                child: Text(
                  'Proses AutoDebet',
                  style: TextStyle(color: Warna.putih, fontSize: 14),
                ),
                padding: EdgeInsets.fromLTRB(18, 9, 18, 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                ),
                onPressed: () {
                  if ((controllerPin.text == '') ||
                      (controllerPin.text.length != 6)) {
                    controllerPin.text = '';
                    Get.snackbar('PERHATIAN...',
                        'Pin tidak dimasukan dengan benar, Pin hanya berisi 6 angka');
                  } else {
                    aktifkanAutoDebet(controllerPin.text);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    )..show();
  }

  aktifkanAutoDebet(pin) async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","norekPinjaman":"${c.nomorRekeningPilihan}","pin":"$pin"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();
    var url = Uri.parse('${c.baseURL}/mobileApps/aktifkanAutoDebetPinjaman');

    final response = await https.post(url, body: {
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
        autoDebet.value = hasil['autoDebet'];
        Get.back();
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: 'AutoDebet Aktif',
          desc:
              'Saat ini autodebet telah aktif, pastikan saldo pada rekening cukup pada saat jatuh tempo pembayaran kredit. Terima kasih',
          btnOkText: 'OK SIAP',
          btnOkOnPress: () {},
        )..show();
      } else {
        Get.back();
        Get.snackbar(hasil['message'],
            'Opps.. sepertinya proses autodebet gagal dilakukan',
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }
}
