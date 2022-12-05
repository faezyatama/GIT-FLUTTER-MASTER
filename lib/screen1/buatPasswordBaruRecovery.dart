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
import '/screen1/login.dart';

class DaftarkanPasswordviaOTP extends StatefulWidget {
  @override
  DaftarkanPasswordviaOTPState createState() => DaftarkanPasswordviaOTPState();
}

class DaftarkanPasswordviaOTPState extends State<DaftarkanPasswordviaOTP> {
  final controllerPass1 = TextEditingController();
  final controllerPass2 = TextEditingController();
  final c = Get.find<ApiService>();

  //SETTING FOCUS NODE
  FocusNode myFocusNode;
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

  Future buatPasswordBaruViaOTP() async {
    final c = Get.find<ApiService>();
    Box dbbox = Hive.box<String>('sasukaDB');
    EasyLoading.instance
      ..userInteractions = false
      ..dismissOnTap = false;
    EasyLoading.show(status: 'Membuat password baru...');

    //BODY YANG DIKIRIM
    String appid = dbbox.get('appid');
    String hp = c.requestPasswordHP.value;
    String password = controllerPass2.text;
    String image = c.requestPassword.value;
    String ootp = c.otpPass;

    print(ootp);

    var user = 'Non Registered User';
    var datarequest =
        '{"hp":"$hp","otp":"$ootp","image":"$image","password":"$password","appid":"$appid"}';
    var bytes = utf8.encode(datarequest + 'cbf4aq3' + user + c.appid);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/buatPsBaruViaOtp');

    try {
      final response = await http.post(url, body: {
        "user": user,
        "appid": c.appid,
        "data_request": datarequest,
        "sign": signature
      });
      print(response.body);

      if (response.statusCode == 200) {
        EasyLoading.dismiss();
        Map<String, dynamic> cekLogin = jsonDecode(response.body);
        if (cekLogin['status'] == 'success') {
          c.requestPassword.value = '';
          EasyLoading.showSuccess(
              'Pembuatan password baru telah Success!, Silahkan login kembali');
          Get.offAll(LoginPage());
        } else if (cekLogin['status'] == 'otp tidak sesuai') {
          AwesomeDialog(
              dismissOnTouchOutside: false,
              dismissOnBackKeyPress: false,
              context: context,
              dialogType: DialogType.noHeader,
              animType: AnimType.bottomSlide,
              title: 'OTP tidak Sesuai',
              desc: 'Sepertinya kode OTP yang dimasukan tidak sesuai',
              btnCancelText: 'Ulangi Proses',
              btnCancelOnPress: () {
                Get.back();
              })
            ..show();
        } else {
          c.requestPassword.value = '';
          AwesomeDialog(
              dismissOnTouchOutside: false,
              dismissOnBackKeyPress: false,
              context: context,
              dialogType: DialogType.noHeader,
              animType: AnimType.bottomSlide,
              title: 'Pembuatan Password Gagal',
              desc: 'Silahkan mengulangi proses proses kembali, Error 442',
              btnCancelText: 'Siap',
              btnCancelOnPress: () {
                Get.offAll(LoginPage());
              })
            ..show();
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar('Error', 'Opss...sepertinya ada error yang terjadi');
      Get.offAll(LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.warnautama,
        title: Text('Membuat Password Baru'),
      ),
      body: Container(
        child: ListView(
          children: [
            Image.asset('images/whitelabelRegister/daftarpassword.png'),
            Container(
              margin: EdgeInsets.fromLTRB(22, 0, 22, 5),
              child: Text('Buat Password kamu'),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(22, 0, 22, 5),
              child: TextField(
                controller: controllerPass1,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: 'Buat Password',
                    prefixIcon: Icon(Icons.vpn_key),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(22, 0, 22, 5),
              child: TextField(
                controller: controllerPass2,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: 'Buat password konfirmasi',
                    prefixIcon: Icon(Icons.vpn_key),
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
                  if (controllerPass1.text != controllerPass2.text) {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.noHeader,
                      animType: AnimType.rightSlide,
                      title: 'Password tidak sesuai',
                      desc:
                          'Opps... Sepertinya password yang dimasukan tidak sama',
                      btnCancelText: 'Atur Ulang',
                      btnCancelOnPress: () {},
                    )..show();
                  } else {
                    if (controllerPass1.text.length < 6) {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.noHeader,
                        animType: AnimType.rightSlide,
                        title: 'Password tidak kuat',
                        desc:
                            'Opps... Sepertinya password yang kamu masukan kurang kuat, Minimal password 6 karakter',
                        btnCancelText: 'Atur Ulang',
                        btnCancelOnPress: () {},
                      )..show();
                    } else {
                      //password terlihat bagus REGISTER NOW
                      buatPasswordBaruViaOTP();
                    }
                  }
                },
                child: Text('Buat Password Baru'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
