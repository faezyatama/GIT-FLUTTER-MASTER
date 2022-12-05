import 'dart:convert';

// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../base/notifikasiBuatAkun.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import 'package:http/http.dart' as http;
import '/screen1/login.dart';

class SettingPassword extends StatefulWidget {
  @override
  _SettingPasswordState createState() => _SettingPasswordState();
}

class _SettingPasswordState extends State<SettingPassword> {
  final controllerPsw1 = TextEditingController();
  final controllerPsw2 = TextEditingController();
  final controllerPswLama = TextEditingController();

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
                    Text('Pengaturan Password',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black54)),
                    Text('Atur password dan amankan akunmu'),
                  ],
                ),
                Image.asset(
                  'images/Gembok.png',
                  width: Get.width * 0.12,
                )
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 22)),
            Text(
                'Untuk alasan keamanan jangan memberitahukan password ini kepada siapapun termasuk pihak ${c.namaAplikasi}'),
            Padding(padding: EdgeInsets.only(top: 33)),
            Container(
              // margin: EdgeInsets.fromLTRB(25, 25, 25, 0),
              child: TextField(
                obscureText: true,
                controller: controllerPsw1,
                decoration: InputDecoration(
                    labelText: 'Password Baru',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            Container(
              // margin: EdgeInsets.fromLTRB(25, 25, 25, 0),
              child: TextField(
                obscureText: true,
                controller: controllerPsw2,
                decoration: InputDecoration(
                    labelText: 'Password Baru untuk konfirmasi',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 22)),
            Center(
                child: Text(
              'Kami mebutuhkan password lama',
              style: TextStyle(fontSize: 11, color: Warna.grey),
            )),
            Container(
              // margin: EdgeInsets.fromLTRB(25, 25, 25, 0),
              child: TextField(
                obscureText: true,
                controller: controllerPswLama,
                decoration: InputDecoration(
                    labelText: 'Password lama',
                    prefixIcon: Icon(Icons.lock_open),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Warna.warnautama),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: Warna.warnautama)))),
              onPressed: () {
                if (c.loginAsPenggunaKita.value == 'Member') {
                  updatePassword(controllerPsw1.text, controllerPsw2.text,
                      controllerPswLama.text);
                } else {
                  var judulF = 'Pengaturan Password';
                  var subJudul =
                      'Kamu bisa mengatur password disini namun dibutuhkan akun ${c.namaAplikasi} untuk memanfaatkan fitur ini, Yuk Buka akun ${c.namaAplikasi} sekarang';

                  bukaLoginPage(judulF, subJudul);
                }
              },
              child: Text(
                'Update Password',
                style: TextStyle(color: Warna.putih),
              ),
            ),
          ],
        ));
    //
  }
}

final c = Get.find<ApiService>();
void updatePassword(String pBaru, String pBaru2, String pLama) async {
  if ((pBaru == '') || (pBaru == '') || (pBaru == '')) {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: 'Update Password',
      desc: 'Opps... sepertinya Password belum dimasukan dengan benar',
      btnCancelText: 'OK SIAP',
      btnCancelOnPress: () {},
    )..show();
  } else if (pBaru != pBaru2) {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: 'Update Password',
      desc:
          'Opps... sepertinya Password baru tidak sesuai. Masukan password baru di form pertama dan konfirmasikan di form kedua',
      btnCancelText: 'OK SIAP',
      btnCancelOnPress: () {},
    )..show();
  } else if (pBaru.length < 6) {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: 'Update Password',
      desc:
          'Opps... sepertinya Password yang kamu masukan kurang kuat, Password minimal 6 karakter ya',
      btnCancelText: 'OK SIAP',
      btnCancelOnPress: () {},
    )..show();
  } else {
    //PROSES UPDATE BANK
    EasyLoading.instance
      ..userInteractions = false
      ..dismissOnTap = false;
    EasyLoading.show(status: 'Wait ...');
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","passwordbaru":"$pBaru","passwordlama":"$pLama"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/updatePassword');
    try {
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
          AwesomeDialog(
              context: Get.context,
              dialogType: DialogType.success,
              animType: AnimType.rightSlide,
              title: 'Update Password',
              desc:
                  'Password kamu telah berhasil di rubah, Untuk memastikan perubahan kamu bisa mencoba login kembali',
              btnOkText: 'Login',
              btnOkOnPress: () {
                Box dbbox = Hive.box<String>('sasukaDB');
                dbbox.put('token', 'NoToken');
                Get.offAll(LoginPage());
              },
              btnCancelText: 'Tidak',
              btnCancelOnPress: () {
                Get.back();
              })
            ..show();
        } else {
          AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.error,
            animType: AnimType.rightSlide,
            title: 'Update Password',
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
          title: 'Update Password',
          desc:
              'Opps.. sepertinya update password gagal dilakukan, kamu bisa mencobanya lagi',
          btnCancelText: 'Ok',
          btnCancelOnPress: () {},
        )..show();
      }
    } catch (e) {
      Get.snackbar('Error Terjadi',
          'Opps Sepertinya error terjadi, silahkan ulangi proses');
    }
  }
}
