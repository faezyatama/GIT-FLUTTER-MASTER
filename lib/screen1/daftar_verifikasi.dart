import 'dart:async';
import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as https;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'daftar_password.dart';

class DaftarVerifikasi extends StatefulWidget {
  @override
  _DaftarVerifikasiState createState() => _DaftarVerifikasiState();
}

class _DaftarVerifikasiState extends State<DaftarVerifikasi> {
  final controllerVerify = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  final c = Get.find<ApiService>();
  var verificationID = '';
  var otpVia = 'ViaFirebase';

  var nomorhp = Hive.box<String>('sasukaDB').get('regHp');

  //SETTING FOCUS NODE
  FocusNode myFocusNode;
  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
    // verifikasiNomorHP(); //via firebase
    setState(() {
      _start = 45;
    });
    startTimer();
    otpVia = 'Whatsapp';
    verifikasiWhatsapp();
    startTimer();
  }

  //timer
  Timer _timer;
  int _start = 30;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            EasyLoading.dismiss();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();
    _timer.cancel();
    super.dispose();
  }

  //end timer
  //===================END FOCUS NODE
  Future verifikasiNomorHP() async {
    EasyLoading.instance
      ..userInteractions = false
      ..dismissOnTap = false;
    EasyLoading.show(status: 'Mengirimkan kode OTP ...');
    //BODY YANG DIKIRIM
    await _auth.verifyPhoneNumber(
        phoneNumber: c.hpOTP.value,
        verificationCompleted: (phoneAuthCredential) async {},
        verificationFailed: (verificationFailed) {
          Get.snackbar('Failed !', 'Verification Failed');
          EasyLoading.dismiss();
        },
        codeSent: (verificationId, resendingToken) async {
          EasyLoading.dismiss();
          verificationID = verificationId;
        },
        codeAutoRetrievalTimeout: (verificationId) async {});
  }

  void signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    EasyLoading.instance
      ..userInteractions = false
      ..dismissOnTap = false;
    EasyLoading.show(status: 'Memeriksa OTP ...');
    try {
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);
      EasyLoading.dismiss();
      if (authCredential.user != null) {
        await _auth.signOut();
        Get.to(() => DaftarkanPassword());
      }
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar('Error !', e.message, snackPosition: SnackPosition.BOTTOM);
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
        child: ListView(
          children: [
            Image.asset('images/daftarverifikasi.png'),
            Container(
              margin: EdgeInsets.fromLTRB(22, 10, 22, 5),
              child: Center(child: Text('SMS Kode Verifikasi dikirim ke:')),
            ),
            Center(
              child: Text(nomorhp,
                  style: TextStyle(
                      color: Warna.grey,
                      fontSize: 25,
                      fontWeight: FontWeight.w200)),
            ),
            Padding(padding: EdgeInsets.only(top: 22)),
            Container(
              margin: EdgeInsets.fromLTRB(22, 0, 22, 5),
              child: TextField(
                focusNode: myFocusNode,
                keyboardType: TextInputType.number,
                controller: controllerVerify,
                decoration: InputDecoration(
                    labelText: 'Masukan Kode Verifikasi',
                    prefixIcon: Icon(Icons.check),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            Container(
                margin: EdgeInsets.fromLTRB(22, 0, 22, 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Belum terima sms konfimasi ?'),
                    (_start > 0)
                        ? ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        side: BorderSide(
                                            color: Warna.warnautama)))),
                            onPressed: () {
                              startTimer();
                            },
                            child: Text(
                              '$_start',
                              style: TextStyle(color: Warna.warnautama),
                            ),
                          )
                        : ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Warna.warnautama),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        side: BorderSide(
                                            color: Warna.warnautama)))),
                            onPressed: () {
                              setState(() {
                                _start = 45;
                              });
                              startTimer();
                              otpVia = 'Whatsapp';
                              verifikasiWhatsapp();
                            },
                            child: Text('via Whatsapp'),
                          )
                  ],
                )),
            Padding(padding: EdgeInsets.fromLTRB(0, 22, 0, 0)),
            Container(
              margin: EdgeInsets.fromLTRB(22, 0, 22, 5),
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Warna.warnautama),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(color: Warna.warnautama)))),
                onPressed: () async {
                  //KALO SAMA OTP NYA
                  //phoneAuthCredential
                  if (otpVia == 'ViaFirebase') {
                    Hive.box<String>('sasukaDB')
                        .put('regVerify', 'ViaFirebase');

                    PhoneAuthCredential phoneAuthCredential =
                        PhoneAuthProvider.credential(
                            verificationId: verificationID,
                            smsCode: controllerVerify.text);

                    signInWithPhoneAuthCredential(phoneAuthCredential);
                  } else {
                    if (controllerVerify.text ==
                        Hive.box<String>('sasukaDB').get('regVerify')) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return DaftarkanPassword();
                      }));
                    } else {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.noHeader,
                        animType: AnimType.rightSlide,
                        title: 'Verifikasi HP',
                        desc:
                            'Nomor yang kamu masukan tidak sesuai, kode ini dikirimkan melalui Whatsapp',
                        btnCancelText: 'Ulangi masukan kode',
                        btnCancelOnPress: () {
                          myFocusNode.requestFocus();
                        },
                      )..show();
                    }
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

  void verifikasiWhatsapp() async {
    EasyLoading.instance
      ..userInteractions = false
      ..dismissOnTap = false;
    EasyLoading.show(status: 'Mengirim OTP Whatsapp ...');
    //BODY YANG DIKIRIM
    var user = 'Non Registered User';

    var datarequest = '{"hp":"$nomorhp"}';
    var bytes = utf8.encode(datarequest + 'cbf4aq3' + user + c.appid);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/cekHPVerify');
    try {
      final response = await https.post(url, body: {
        "user": user,
        "appid": c.appid,
        "data_request": datarequest,
        "sign": signature
      });
      print(response.body);

      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        Map<String, dynamic> cekHP = jsonDecode(response.body);
        if (cekHP['status'] == 'success') {
          Hive.box<String>('sasukaDB').put('regVerify', cekHP['verify']);
        } else {}
      } else {}
    } catch (e) {
      Get.snackbar('Error Connection', 'Opps... connection error');
    }
  }
}

Future alertku(BuildContext context, pesan, hp) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(hp),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(pesan),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ulangi Pengisian kode'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}
