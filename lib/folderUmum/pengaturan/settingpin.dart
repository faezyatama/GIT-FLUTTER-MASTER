import 'dart:convert';

// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import 'package:http/http.dart' as http;
import 'lupapin.dart';

class SettingPin extends StatefulWidget {
  @override
  _SettingPinState createState() => _SettingPinState();
}

class _SettingPinState extends State<SettingPin> {
  final cpinbaru = TextEditingController();
  final cpinbaru2 = TextEditingController();
  final cpinlama = TextEditingController();
  final cpassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(22),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pengaturan PIN',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black54)),
                    Text('(Personal Identification Number)'),
                  ],
                ),
                Image.asset(
                  'images/secure.png',
                  width: Get.width * 0.2,
                )
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 22)),
            Text(
                'Untuk alasan keamanan jangan memberitahukan PIN ini kepada siapapun termasuk pihak ${c.namaAplikasi}'),
            Padding(padding: EdgeInsets.only(top: 33)),
            Container(
              // margin: EdgeInsets.fromLTRB(25, 25, 25, 0),
              child: TextField(
                controller: cpinbaru,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: 'PIN Baru',
                    prefixIcon: Icon(Icons.security),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            Container(
              // margin: EdgeInsets.fromLTRB(25, 25, 25, 0),
              child: TextField(
                controller: cpinbaru2,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: 'PIN Baru 1x lagi',
                    prefixIcon: Icon(Icons.security),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            Obx(() => Container(
                  // margin: EdgeInsets.fromLTRB(25, 25, 25, 0),
                  child: TextField(
                    controller: cpinlama,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: c.pinUnblock.value,
                        prefixIcon: Icon(Icons.lock_open),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                )),
            Padding(padding: EdgeInsets.only(top: 11)),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Warna.warnautama),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: Warna.putih)))),
              onPressed: () {
                updatePinSaya(cpinbaru.text, cpinbaru2.text, cpinlama.text);
              },
              child: Text(
                'Update PIN Sekarang',
                style: TextStyle(color: Warna.putih),
              ),
            ),
            (c.pinUnblock.value == 'Pin lama')
                ? ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.redAccent),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    side: BorderSide(color: Warna.putih)))),
                    onPressed: () {
                      AwesomeDialog(
                          context: Get.context,
                          dialogType: DialogType.warning,
                          animType: AnimType.rightSlide,
                          customHeader: Center(
                              child: Icon(
                            Icons.lock,
                            size: Get.width * 0.15,
                            color: Warna.warnautama,
                          )),
                          title: '',
                          desc: '',
                          body: Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Text(
                                    'Password dibutuhkan untuk Reset PIN, Silahkan masukan password kamu'),
                                Padding(padding: EdgeInsets.only(top: 8)),
                                TextField(
                                  controller: cpassword,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      labelText: 'Password Dibutuhkan',
                                      prefixIcon: Icon(Icons.vpn_key),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                              ],
                            ),
                          ),
                          btnOkText: 'Reset PIN Sekarang',
                          btnOkColor: Warna.warnautama,
                          btnOkOnPress: () {
                            if (cpassword.text == '') {
                              AwesomeDialog(
                                context: Get.context,
                                dialogType: DialogType.noHeader,
                                animType: AnimType.rightSlide,
                                title: 'Reset PIN',
                                desc:
                                    'Opps... Password dibutuhkan untuk Reset PIN',
                                btnCancelText: 'OK',
                                btnCancelOnPress: () {},
                              )..show();
                            } else {
                              cekPassword(cpassword.text);
                            }
                          })
                        ..show();
                    },
                    child: Text(
                      'Saya Lupa PIN',
                      style: TextStyle(color: Warna.putih),
                    ),
                  )
                : Padding(padding: EdgeInsets.all(11))
          ],
        ));
    //
  }

  final c = Get.find<ApiService>();

  void updatePinSaya(pin1, pin2, pinlama) async {
    if ((pin1.length != 6) || (pin2.length != 6) || (pinlama.length != 6)) {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        title: 'Update PIN',
        desc:
            'Opps... sepertinya PIN belum dimasukan dengan benar, PIN hanya berisi 6 angka saja',
        btnCancelText: 'OK SIAP',
        btnCancelOnPress: () {},
      )..show();
    } else if (pin1 != pin2) {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        title: 'Update PIN',
        desc: 'PIN pertama dan kedua tidak sesuai. Ulangi ya',
        btnCancelText: 'OK SIAP',
        btnCancelOnPress: () {},
      )..show();
    } else {
//BODY YANG DIKIRIM
      EasyLoading.instance
        ..userInteractions = false
        ..dismissOnTap = false;
      EasyLoading.show(status: 'Wait ...');

      Box dbbox = Hive.box<String>('sasukaDB');
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');
      var user = dbbox.get('loginSebagai');

      var datarequest = '{"pid":"$pid","pinbaru":"$pin1","pinlama":"$pinlama"}';
      var bytes = utf8.encode(datarequest + '$token' + user);
      var signature = md5.convert(bytes).toString();

      var url = Uri.parse('${c.baseURL}/mobileApps/updatePin');

      final response = await http.post(url, body: {
        "user": user,
        "appid": c.appid,
        "data_request": datarequest,
        "sign": signature
      });
      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        Map<String, dynamic> resultnya = jsonDecode(response.body);
        if (resultnya['status'] == 'success') {
          print(response.body);
          dbbox.put('pinBlokir', resultnya['pinBlokir']);
          c.pinBlokir.value = resultnya['pinBlokir'];
          c.pinUnblock.value = 'Pin lama';
          AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.noHeader,
            animType: AnimType.rightSlide,
            title: 'Update PIN',
            desc: 'Update PIN telah berhasil dilakukan, PIN kamu telah berubah',
            btnOkText: 'Ok',
            btnOkOnPress: () {
              Get.back();
            },
          )..show();
        } else if (resultnya['status'] == 'terblokir') {
          dbbox.put('pinBlokir', resultnya['pinBlokir']);
          c.pinBlokir.value = resultnya['pinBlokir'];

          AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.noHeader,
            animType: AnimType.rightSlide,
            title: 'Update PIN Gagal',
            desc: resultnya['message'],
            btnCancelText: 'Ok',
            btnCancelOnPress: () {},
          )..show();
        } else {
          AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.noHeader,
            animType: AnimType.rightSlide,
            title: 'Update PIN Gagal',
            desc: resultnya['message'],
            btnCancelText: 'Ok',
            btnCancelOnPress: () {},
          )..show();

          print(response.body);
        }
      } else {
        print(response.body);
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'Update PIN Gagal',
          desc:
              'Opps.. sepertinya update PIN gagal dilakukan, kamu bisa mencobanya lagi',
          btnCancelText: 'Ok',
          btnCancelOnPress: () {},
        )..show();
      }
    }
  }

  void cekPassword(password) async {
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","password":"$password"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/cekPassword');

    try {
      final response = await http.post(url, body: {
        "user": user,
        "appid": c.appid,
        "data_request": datarequest,
        "sign": signature
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> resultnya = jsonDecode(response.body);
        if (resultnya['status'] == 'success') {
          //print(response.body);
          c.pinUnblock.value = 'PIN sementara dari SMS';
          c.pertanyaanKeamanan.value = resultnya['pertanyaan'];
          Get.to(() => LupaPIN());
        } else {
          AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.noHeader,
            animType: AnimType.rightSlide,
            title: 'Password salah',
            desc: resultnya['message'],
            btnCancelText: 'Ok',
            btnCancelOnPress: () {},
          )..show();

          print(response.body);
        }
      }
    } catch (e) {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        title: 'Reset PIN',
        desc:
            'Opps.. sepertinya proses reset gagal dilakukan, kamu bisa mencobanya lagi',
        btnCancelText: 'Ok',
        btnCancelOnPress: () {},
      )..show();
    }
  }
}
