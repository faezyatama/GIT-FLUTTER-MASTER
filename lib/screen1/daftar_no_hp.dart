import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import '/screen1/daftar_verifikasi.dart';

class DaftarkanHp extends StatefulWidget {
  @override
  _DaftarkanHpState createState() => _DaftarkanHpState();
}

class _DaftarkanHpState extends State<DaftarkanHp> {
  final controllerHp = TextEditingController();
  final controllerEmail = TextEditingController();
  final c = Get.find<ApiService>();

  //SETTING FOCUS NODE
  FocusNode myFocusNode;
  FocusNode myFocusNode2;
  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();
    super.dispose();
  }

  //===================END FOCUS NODE
  Future cekKetersediaanNomor(context, nomorhp, email) async {
    EasyLoading.instance
      ..userInteractions = false
      ..dismissOnTap = false;
    EasyLoading.show(status: 'Wait ...');

    //BODY YANG DIKIRIM
    var user = 'Non Registered User';
    var datarequest = '{"hp":"$nomorhp","email":"$email"}';
    var bytes = utf8.encode(datarequest + 'cbf4aq3' + user + c.appid);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/cekHp');

    try {
      final response = await http.post(url, body: {
        "user": user,
        "appid": c.appid,
        "data_request": datarequest,
        "sign": signature
      });
      EasyLoading.dismiss();
      print(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> cekHP = jsonDecode(response.body);
        if (cekHP['status'] == 'failed') {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.noHeader,
            animType: AnimType.rightSlide,
            title: 'Register',
            desc: 'Opps... Sepertinya nomor HP/email ini sudah terdaftar',
            btnCancelText: 'Login',
            btnOkText: 'Ganti nomor',
            btnOkOnPress: () {},
            btnCancelOnPress: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          )..show();
        } else if (cekHP['status'] == 'success') {
          //OTP SUDAH SIAP
          //NOMOR HP TIDAK ADA DALAM SISTEM DAN FIREBASE AUTH JALANKAN
          c.hpOTP.value = cekHP['hp'];
          Get.to(() => DaftarVerifikasi());
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar('Error Connection',
          'Opps... sepertinya koneksi ke server tidak stabil');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.warnautama,
        title: Text('Daftar Akun'),
      ),
      body: Container(
        margin: EdgeInsets.all(0),
        child: ListView(
          children: [
            Image.asset('images/whitelabelRegister/daftarhp.png'),
            Container(
              margin: EdgeInsets.fromLTRB(22, 22, 22, 22),
              child: Text(
                  'Masukan Nomor HP dan alamat Email Valid kamu, pastikan nomor HP dan email kamu belum terdaftar ya...'),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(22, 0, 22, 5),
              child: TextField(
                controller: controllerHp,
                keyboardType: TextInputType.number,
                focusNode: myFocusNode,
                maxLength: 15,
                decoration: InputDecoration(
                    labelText: 'Nomor HP',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(22, 0, 22, 5),
              child: TextField(
                controller: controllerEmail,
                focusNode: myFocusNode2,
                keyboardType: TextInputType.emailAddress,
                maxLength: 50,
                decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(22, 0, 22, 5),
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Warna.warnautama),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(color: Warna.warnautama)))),
                onPressed: () {
                  if (controllerHp.text == '') {
                    myFocusNode.requestFocus();
                  } else if (controllerEmail.text == '') {
                    myFocusNode2.requestFocus();
                  } else {
                    Hive.box<String>('sasukaDB')
                        .put('regHp', controllerHp.text);
                    Hive.box<String>('sasukaDB')
                        .put('regEmail', controllerEmail.text);

                    cekKetersediaanNomor(
                        context, controllerHp.text, controllerEmail.text);
                  }
                },
                child: Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
