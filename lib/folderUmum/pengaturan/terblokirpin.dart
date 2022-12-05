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
import 'lupapin.dart';
import 'package:http/http.dart' as http;

class Terblokir extends StatelessWidget {
  final cpassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(top: 55),
      children: [
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/Gembok.png',
                width: Get.width * 0.3,
              ),
              Padding(padding: EdgeInsets.only(bottom: 10)),
              Text(
                'PIN Kamu Terblokir',
                style: TextStyle(fontSize: 22, color: Warna.grey),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
                child: Text(
                  'Saat ini PIN kamu tidak dapat digunakan (Terblokir Sementara), kamu bisa melakukan permintaan reset PIN untuk mengembalikan PIN',
                  style: TextStyle(fontSize: 14, color: Warna.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              RawMaterialButton(
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
                      body: Column(
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
                                    borderRadius: BorderRadius.circular(10))),
                          ),
                        ],
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
                            desc: 'Opps... Password dibutuhkan untuk Reset PIN',
                            btnCancelText: 'OK',
                            btnCancelOnPress: () {},
                          )..show();
                        } else {
                          cekPassword(cpassword.text);
                        }
                      })
                    ..show();
                },
                constraints: BoxConstraints(),
                elevation: 1.0,
                fillColor: Warna.warnautama,
                child: Text(
                  '  Reset PIN  ',
                  style: TextStyle(color: Warna.putih),
                ),
                padding: EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(22)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  final c = Get.find<ApiService>();
  void cekPassword(password) async {
    EasyLoading.instance
      ..userInteractions = false
      ..dismissOnTap = false;
    EasyLoading.show(status: 'Wait ...');

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');

    var datarequest = '{"pid":"$pid","password":"$password"}';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse('${c.baseURL}/sasuka/cekPassword');

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
        //print(response.body);
        c.pertanyaanKeamanan.value = resultnya['pertanyaan'];
        Get.off(LupaPIN());
      } else {
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'Password salah',
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
        title: 'Reset PIN',
        desc:
            'Opps.. sepertinya proses reset gagal dilakukan, kamu bisa mencobanya lagi',
        btnCancelText: 'Ok',
        btnCancelOnPress: () {},
      )..show();
    }
  }
}
