import 'dart:convert';

// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:crypto/crypto.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import 'package:http/http.dart' as http;

import '../pengaturan/setting2.dart';

class PenarikanDana extends StatefulWidget {
  @override
  _PenarikanDanaState createState() => _PenarikanDanaState();
}

class _PenarikanDanaState extends State<PenarikanDana> {
  final c = Get.find<ApiService>();
  Box dbbox = Hive.box<String>('sasukaDB');

  final controller = TextEditingController();
  final controllerPin = TextEditingController();
  var jamPenarikan = false;
  var pesanText = 'Batas waktu penarikan dana belum tersedia'.obs;

  @override
  void initState() {
    super.initState();
    cekPenarikanBisaGak();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(33, 33, 33, 33),
              child: Text(
                'Penarikan dana di ${c.namaAplikasi} sangat mudah loh... cukup masukan jumlah nominal yang mau ditarik',
                style: TextStyle(fontSize: 16, color: Warna.grey),
              ),
            ),
            Text(
              'Penarikan ke Rekening :',
              style: TextStyle(color: Warna.grey),
            ),
            Image.network(
                'https://sasuka.online/icon/bank/${c.bank.value}.png'),
            Text(
              'Bank : ${c.bank.value}',
              style: TextStyle(
                  color: Warna.grey, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              'No.Rekening : ${c.norek.value}',
              style: TextStyle(
                  color: Warna.grey, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              dbbox.get('nama'),
              style: TextStyle(
                  color: Warna.grey, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Padding(padding: EdgeInsets.only(top: 33)),
            Text(
              'Jumlah Penarikan :',
              style: TextStyle(color: Warna.grey),
            ),
            Container(
              width: Get.width * 0.7,
              child: TextField(
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    color: Warna.grey),
                controller: controller,
                inputFormatters: [
                  TextInputMask(
                      mask: ['999.999.999.999', '999.999.9999.999'],
                      reverse: true)
                ],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    // prefixIcon: Icon(Icons.vpn_key),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 33)),
            (jamPenarikan == true)
                ? RawMaterialButton(
                    constraints: BoxConstraints(minWidth: Get.width * 0.7),
                    elevation: 1.0,
                    fillColor: Warna.warnautama,
                    child: Text(
                      'Buat Penarikan Dana',
                      style: TextStyle(color: Warna.putih, fontSize: 16),
                    ),
                    padding: EdgeInsets.fromLTRB(18, 9, 18, 9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                    onPressed: () {
                      if (controller.text == '') {
                        AwesomeDialog(
                          context: Get.context,
                          dialogType: DialogType.noHeader,
                          animType: AnimType.rightSlide,
                          title: 'Penarikan',
                          desc:
                              'Silahkan masukan jumlah yang diinginkan untuk melakukan penarikan. Jumlah minimal penarikan adalah Rp.20.000,-',
                          btnCancelText: 'OK',
                          btnCancelColor: Colors.amber,
                          btnCancelOnPress: () {},
                        )..show();
                      } else {
                        print(controller.text);
                        penarikanDana(controller.text);
                      }
                    },
                  )
                : Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 55,
                          color: Warna.warnautama,
                        ),
                        Padding(padding: EdgeInsets.only(left: 11)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Perhatian !!!',
                                style: TextStyle(
                                    color: Warna.warnautama,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600)),
                            SizedBox(
                              width: Get.width * 0.55,
                              child: Obx(() => Text(pesanText.value,
                                  overflow: TextOverflow.clip,
                                  maxLines: 3,
                                  style: TextStyle(
                                    color: Warna.warnautama,
                                    fontSize: 14,
                                  ))),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
            Padding(padding: EdgeInsets.only(top: 22))
          ],
        ),
      ],
    );
  }

  void penarikanDana(String jumlah) {
    var nominal = jumlah.replaceAll('.', '');
    var nom = int.parse(nominal);
    if ((nom + 6500) > c.saldoInt.value) {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        title: 'Saldo Tidak Cukup !',
        desc:
            'Opps sepertinya saldo kamu tidak cukup, Minimal penarikan dana adalah Rp. 20.000,- dan dikenakan biaya Rp.6.500,-',
        btnCancelText: 'OK',
        btnCancelColor: Colors.amber,
        btnCancelOnPress: () {},
      )..show();
    } else if (nom >= 20000) {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        customHeader: Center(
            child: Image.asset(
          'images/Gembok.png',
          width: Get.width * 0.16,
        )),
        title: '',
        desc: '',
        body: Column(
          children: [
            Text('PIN DIBUTUHKAN',
                style: TextStyle(
                    fontSize: 18,
                    color: Warna.warnautama,
                    fontWeight: FontWeight.w600)),
            Container(
              padding: EdgeInsets.only(left: 7, right: 7),
              child: Text(
                  'Silahkan masukan PIN kamu untuk melakukan transaksi penarikan dana sebesar '),
            ),
            Text(
              'Rp. $jumlah,-',
              style: TextStyle(
                  fontSize: 25, color: Warna.grey, fontWeight: FontWeight.w600),
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            Container(
              width: Get.width * 0.7,
              child: TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    color: Warna.grey),
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
                'Proses Penarikan Dana',
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
                  prosesPenarikanDanaSekarang(nom, controllerPin.text);
                }
              },
            ),
          ],
        ),
      )..show();
    } else {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        title: 'PERHATIAN !',
        desc:
            'Minimal penarikan dana adalah Rp. 20.000,- dan dikenakan biaya Rp.6.500,-',
        btnCancelText: 'OK',
        btnCancelColor: Colors.amber,
        btnCancelOnPress: () {},
      )..show();
    }
  }

  void prosesPenarikanDanaSekarang(nom, pin) async {
    EasyLoading.instance
      ..userInteractions = false
      ..dismissOnTap = false;
    EasyLoading.show(status: 'Wait ...');
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","pin":"$pin","jumlah":"$nom"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/requestPenarikan');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      controllerPin.text = '';
      Map<String, dynamic> resultnya = jsonDecode(response.body);
      if (resultnya['status'] == 'success') {
        c.pinBlokir.value = resultnya['pinBlokir'];
        c.saldo.value = resultnya['saldo'];
        //print(response.body);
        Get.back();
        AwesomeDialog(
          dismissOnBackKeyPress: false,
          dismissOnTouchOutside: false,
          context: Get.context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'Penarikan Berhasil',
          desc:
              'Terima kasih telah melakukan penarikan dana, Kami akan segera memproses transaksi kamu',
          btnOkText: 'Ok',
          btnOkOnPress: () {
            Get.back();
          },
        )..show();
      } else if (resultnya['status'] == 'failed') {
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: 'Penarikan Gagal',
          desc: 'Opps.. Penarikan Gagal dilakukan. ${resultnya['message']}',
          btnCancelText: 'Ok',
          btnCancelOnPress: () {
            Get.back();
          },
        )..show();
      } else {
        c.pinBlokir.value = resultnya['pinBlokir'];
        print(response.body);
        if (resultnya['pinBlokir'] == 'terblokir') {
          AwesomeDialog(
            dismissOnBackKeyPress: false,
            dismissOnTouchOutside: false,
            context: Get.context,
            dialogType: DialogType.noHeader,
            animType: AnimType.rightSlide,
            title: 'TERBLOKIR',
            desc:
                'Maaf PIN kamu saat ini terblokir, Apabila kamu lupa PIN ini Silahkan lakukan request untuk reset PIN',
            btnCancelText: 'Reset',
            btnCancelOnPress: () {
              Get.off(PengaturanUmumPin());
            },
            btnOkText: 'Tidak',
            btnOkOnPress: () {
              Get.back();
              Get.back();
            },
          )..show();
        } else {
          AwesomeDialog(
            context: Get.context,
            dismissOnBackKeyPress: false,
            dismissOnTouchOutside: false,
            dialogType: DialogType.noHeader,
            animType: AnimType.rightSlide,
            title: 'Penarikan Gagal',
            desc: 'Opps.. Penarikan Gagal dilakukan. ${resultnya['message']}',
            btnCancelText: 'Ok',
            btnCancelOnPress: () {
              Get.back();
            },
          )..show();
        }
      }
    } else {
      print(response.body);
      AwesomeDialog(
        context: Get.context,
        dismissOnBackKeyPress: false,
        dismissOnTouchOutside: false,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        title: 'Penarikan Gagal',
        desc: 'Opps.. Penarikan Gagal dilakukan',
        btnCancelText: 'Ok',
        btnCancelOnPress: () {},
      )..show();
    }
  }

  void cekPenarikanBisaGak() async {
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/cekPenarikanBisa');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    if (response.statusCode == 200) {
      controllerPin.text = '';
      Map<String, dynamic> resultnya = jsonDecode(response.body);
      if (resultnya['status'] == 'success') {
        jamPenarikan = resultnya['penarikan'];
        pesanText.value = resultnya['message'];
        setState(() {});
      }
    }
  }
}
