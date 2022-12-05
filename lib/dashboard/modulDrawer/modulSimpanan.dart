import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../base/api_service.dart';
import '../../base/notifikasiBuatAkun.dart';
import '../../base/warna.dart';

class ModulSimpananSipokSiwa extends StatelessWidget {
  final c = Get.find<ApiService>();
  final controllerPinAD = TextEditingController();
  final controllerPin = TextEditingController();
  final controllerPinW = TextEditingController();
  final controllerSS = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(padding: EdgeInsets.only(left: 3)),
        SizedBox(
          width: Get.width * 0.23,
          child: GestureDetector(
            onTap: () {
              if (c.loginAsPenggunaKita.value == 'Member') {
                if (c.btnpokok.value == 'ada') {
                  konfirmasiSimpananPokok();
                } else {
                  AwesomeDialog(
                    context: Get.context,
                    dialogType: DialogType.noHeader,
                    animType: AnimType.rightSlide,
                    title: 'SIMPANAN POKOK',
                    btnOkText: 'Ok',
                    btnOkOnPress: () {},
                    desc:
                        'Simpanan Pokok telah dibayarkan. Terima kasih telah membayarkan simpanan pokok',
                  )..show();
                }
              } else {
                var judulF = 'Simpanan Pokok';
                var subJudul =
                    'Simpanan pokok adalah simpanan yang disetorkan 1x selama menjadi anggota, Simpanan pokok di ${c.namaAplikasi} sangat murah loh... Yuk jadi anggota koperasi dengan banyak keuntungan, Buka akun ${c.namaAplikasi} sekarang';

                bukaLoginPage(judulF, subJudul);
              }
            },
            child: Column(
              children: [
                Image.asset('images/whitelabelMainMenu/sipok.png',
                    width: Get.width * 0.12),
                Text(
                  'Simpanan Pokok Anggota',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
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
                cekSimpananWajib();
              } else {
                var judulF = 'Simpanan Wajib';
                var subJudul =
                    'Simpanan wajib adalah simpanan yang disetorkan setiap bulan, Simpanan wajib di ${c.namaAplikasi} sangat terjangkau loh... Menjadi anggota koperasi aktif akan mendapat banyak keuntungan,  Yuk Buka akun ${c.namaAplikasi} sekarang';

                bukaLoginPage(judulF, subJudul);
              }
            },
            child: Column(
              children: [
                Image.asset('images/whitelabelMainMenu/siwa.png',
                    width: Get.width * 0.12),
                Text(
                  'Simpanan Wajib Anggota',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
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
                autoDebetSimpananWajib();
              } else {
                var judulF = 'Autodebet Simpanan';
                var subJudul =
                    'Tak perlu repot membayar simpanan wajib secara manual, ${c.namaAplikasi} menyiapkan autodebet buat kamu, Simpanan wajib di ${c.namaAplikasi} sangat murah loh...,  Yuk Buka akun ${c.namaAplikasi} sekarang';

                bukaLoginPage(judulF, subJudul);
              }
            },
            child: Column(
              children: [
                Image.asset('images/whitelabelMainMenu/autodebet.png',
                    width: Get.width * 0.12),
                Text(
                  'AutoDebet Simpanan',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        Padding(padding: EdgeInsets.only(left: 3)),
      ],
    );
  }

  void autoDebetSimpananWajib() {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Padding(padding: EdgeInsets.only(top: 22)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    'AUTO DEBET',
                    style: TextStyle(
                        fontSize: 19,
                        color: Warna.grey,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'SIMPANAN WAJIB',
                    style: TextStyle(
                        fontSize: 19,
                        color: Warna.grey,
                        fontWeight: FontWeight.w600),
                  ),
                  Padding(padding: EdgeInsets.only(top: 11)),
                  Text(
                    c.siwaAnggota + ' / Bulan',
                    style: TextStyle(
                        fontSize: 18,
                        color: Warna.warnautama,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(left: 22)),
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 33)),
          Container(
            padding: EdgeInsets.only(left: 7, right: 7),
            child: Text(
              'Dengan mengaktifkan fitur auto debet, bisa memudahkan kamu membayar simpanan wajib setiap bulannya. Pastikan saldo kamu cukup untuk layanan ini',
              textAlign: TextAlign.center,
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 7)),
          Text('PIN DIBUTUHKAN',
              style: TextStyle(
                  fontSize: 18,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w600)),
          Padding(padding: EdgeInsets.only(top: 7)),
          Container(
            width: Get.width * 0.7,
            child: TextField(
              obscureText: true,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: TextStyle(
                  fontSize: 25, fontWeight: FontWeight.w600, color: Warna.grey),
              controller: controllerPinAD,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.vpn_key),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
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
              if ((controllerPinAD.text == '') ||
                  (controllerPinAD.text.length != 6)) {
                controllerPinAD.text = '';
                Get.back();
                AwesomeDialog(
                  context: Get.context,
                  dialogType: DialogType.noHeader,
                  animType: AnimType.rightSlide,
                  title: 'PERHATIAN !',
                  desc:
                      'Pin tidak dimasukan dengan benar, Pin hanya berisi 6 angka',
                  btnCancelText: 'OK',
                  btnCancelColor: Colors.amber,
                  btnCancelOnPress: () {},
                )..show();
              } else {
                prosesAutoDebet();
              }
            },
          ),
        ],
      ),
    )..show();
  }

  void prosesAutoDebet() async {
    EasyLoading.show(
        status: 'Mohon tunggu permintaan diproses...', dismissOnTap: false);

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var pin = controllerPinAD.text;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","pin":"$pin"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/autodebet');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });
    controllerPinAD.text = '';

    EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        c.btnwajib.value = 'tidak';
        c.autoDebetWajib.value = 1;
        AwesomeDialog(
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          context: Get.context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'Auto Debet Berhasil',
          desc: hasil['message'],
          btnOkText: 'OK',
          btnOkOnPress: () {
            Get.back();
          },
        )..show();
      } else {
        AwesomeDialog(
          context: Get.context,
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: 'PERHATIAN !',
          desc: hasil['message'],
          btnCancelText: 'OK',
          btnCancelOnPress: () {
            Get.back();
          },
        )..show();
      }
    }
  }

  void konfirmasiSimpananPokok() {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Padding(padding: EdgeInsets.only(top: 22)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    'SIMPANAN POKOK',
                    style: TextStyle(
                        fontSize: 19,
                        color: Warna.grey,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    c.sipokAnggota,
                    style: TextStyle(
                        fontSize: 18,
                        color: Warna.grey,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(left: 22)),
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 33)),
          Text('PIN DIBUTUHKAN',
              style: TextStyle(
                  fontSize: 18,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w600)),
          Padding(padding: EdgeInsets.only(top: 7)),
          Container(
            padding: EdgeInsets.only(left: 7, right: 7),
            child: Text(
              'Simpanan Pokok adalah simpanan yang dibayarkan kepada koperasi saat masuk menjadi anggota, Masukan PIN kamu untuk melakukan proses ini',
              textAlign: TextAlign.center,
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 7)),
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
          RawMaterialButton(
            constraints: BoxConstraints(minWidth: Get.width * 0.7),
            elevation: 1.0,
            fillColor: Warna.warnautama,
            child: Text(
              'Setor Simpanan Pokok',
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
                Get.back();
                AwesomeDialog(
                  context: Get.context,
                  dialogType: DialogType.noHeader,
                  animType: AnimType.rightSlide,
                  title: 'PERHATIAN !',
                  desc:
                      'Pin tidak dimasukan dengan benar, Pin hanya berisi 6 angka',
                  btnCancelText: 'OK',
                  btnCancelColor: Colors.amber,
                  btnCancelOnPress: () {},
                )..show();
              } else {
                bayarSimpananPokok();
              }
            },
          ),
        ],
      ),
    )..show();
  }

  void cekSimpananWajib() async {
    EasyLoading.show(status: 'Pengecekan Simpanan...', dismissOnTap: false);

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var datarequest = '{"pid":"$pid"}';
    var user = dbbox.get('loginSebagai');

    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/cekSimpananWajib');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        var bulan = hasil['bulan'];
        var rp = hasil['rp'];

        if (bulan == 0) {
          AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.warning,
            animType: AnimType.rightSlide,
            title: 'SIMPANAN WAJIB',
            desc: 'Opss. sepertinya simpanan wajib telah lunas, Terima kasih',
            btnOkText: 'OK',
            btnOkColor: Colors.amber,
            btnOkOnPress: () {
              Get.back();
            },
          )..show();
        } else {
          AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.noHeader,
            animType: AnimType.rightSlide,
            title: '',
            desc: '',
            body: Column(
              children: [
                Padding(padding: EdgeInsets.only(top: 22)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          'SIMPANAN WAJIB',
                          style: TextStyle(
                              fontSize: 19,
                              color: Warna.grey,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          rp,
                          style: TextStyle(
                              fontSize: 18,
                              color: Warna.grey,
                              fontWeight: FontWeight.w600),
                        ),
                        Text('$bulan Bulan Pembayaran Simpanan')
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(left: 22)),
                  ],
                ),
                Padding(padding: EdgeInsets.only(top: 33)),
                Text('PIN DIBUTUHKAN',
                    style: TextStyle(
                        fontSize: 18,
                        color: Warna.warnautama,
                        fontWeight: FontWeight.w600)),
                Padding(padding: EdgeInsets.only(top: 7)),
                Container(
                  padding: EdgeInsets.only(left: 7, right: 7),
                  child: Text(
                    'Simpanan Wajib adalah simpanan yang wajib dibayar anggota kepada koperasi setiap bulannya dan tidak dapat diambil kembali selama masih menjadi anggota, Masukan PIN kamu untuk melakukan proses ini',
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 7)),
                Container(
                  width: Get.width * 0.7,
                  child: TextField(
                    obscureText: true,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Warna.grey),
                    controller: controllerPinW,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.vpn_key),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
                RawMaterialButton(
                  constraints: BoxConstraints(minWidth: Get.width * 0.7),
                  elevation: 1.0,
                  fillColor: Warna.warnautama,
                  child: Text(
                    'Setor Simpanan Wajib',
                    style: TextStyle(color: Warna.putih, fontSize: 14),
                  ),
                  padding: EdgeInsets.fromLTRB(18, 9, 18, 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                  ),
                  onPressed: () {
                    if ((controllerPinW.text == '') ||
                        (controllerPinW.text.length != 6)) {
                      controllerPinW.text = '';
                      Get.back();
                      AwesomeDialog(
                        context: Get.context,
                        dialogType: DialogType.noHeader,
                        animType: AnimType.rightSlide,
                        title: 'PERHATIAN !',
                        desc:
                            'Pin tidak dimasukan dengan benar, Pin hanya berisi 6 angka',
                        btnCancelText: 'OK',
                        btnCancelColor: Colors.amber,
                        btnCancelOnPress: () {},
                      )..show();
                    } else {
                      bayarSimpananWajib(bulan);
                    }
                  },
                ),
              ],
            ),
          )..show();
        }
      } else if (hasil['status'] == 'simpanan pokok') {
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: 'SIMPANAN POKOK BELUM DIBAYARKAN',
          desc:
              'Opps.. sepertinya kamu belum membayar simpanan pokok, lakukan pembayaran simpanan pokok terlebih dahulu dan melakukan pembayaran simpanan wajib, ',
          btnOkText: 'OK',
          btnOkColor: Colors.amber,
          btnOkOnPress: () {
            Get.back();
          },
        )..show();
      } else {
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'ERROR',
          desc: 'Opss. sepertinya terjadi masalah dalam koneksi server',
          btnOkText: 'OK',
          btnOkColor: Colors.redAccent,
          btnOkOnPress: () {
            Get.back();
          },
        )..show();
      }
    }
  }

  void bayarSimpananWajib(bulan) async {
    EasyLoading.show(
        status: 'Mohon tunggu pembayaran sedang diproses...',
        dismissOnTap: false);

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var pin = controllerPinW.text;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","pin":"$pin","bulan":"$bulan"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/bayarWajib');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });
    controllerPinW.text = '';

    EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        c.btnwajib.value = 'tidak';
        c.wajib.value = hasil['wajib'];
        c.saldo.value = hasil['saldo'];
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'PEMBAYARAN BERHASIL',
          desc: hasil['message'],
          btnOkText: 'OK',
          btnOkOnPress: () {
            Get.back();
          },
        )..show();
      } else {
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: 'PERHATIAN !',
          desc: hasil['message'],
          btnCancelText: 'OK',
          btnCancelOnPress: () {
            Get.back();
          },
        )..show();
      }
    }
  }

  void bayarSimpananPokok() async {
    EasyLoading.show(
        status: 'Mohon tunggu pembayaran sedang diproses...',
        dismissOnTap: false);

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var pin = controllerPin.text;
    var user = dbbox.get('loginSebagai');
    var datarequest = '{"pid":"$pid","pin":"$pin"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/bayarPokok');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });
    controllerPin.text = '';

    EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        c.btnpokok.value = 'tidak';
        c.pokok.value = hasil['pokok'];
        c.saldo.value = hasil['saldo'];
        c.cl.value = 10;

        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'PEMBAYARAN BERHASIL',
          desc: hasil['message'],
          btnOkText: 'OK',
          btnOkOnPress: () {
            Get.back();
          },
        )..show();
      } else {
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: 'PERHATIAN !',
          desc: hasil['message'],
          btnCancelText: 'OK',
          btnCancelOnPress: () {
            Get.back();
          },
        )..show();
      }
    }
  }
}
