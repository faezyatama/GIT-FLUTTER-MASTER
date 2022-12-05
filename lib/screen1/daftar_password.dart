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
import '/dashboard/view/dashboard.dart';
import '/screen1/login.dart';

class DaftarkanPassword extends StatefulWidget {
  @override
  DaftarkanPasswordState createState() => DaftarkanPasswordState();
}

class DaftarkanPasswordState extends State<DaftarkanPassword> {
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

  Future registerNow(context, passw) async {
    EasyLoading.instance
      ..userInteractions = false
      ..dismissOnTap = false;
    EasyLoading.show(status: 'Mohon tunggu kami sedang mendaftarkan ...');

    //BODY YANG DIKIRIM
    var nomorhp = Hive.box<String>('sasukaDB').get('regHp');
    var nama = Hive.box<String>('sasukaDB').get('regNama');
    var jk = Hive.box<String>('sasukaDB').get('regJenisKelamin');
    var goldar = Hive.box<String>('sasukaDB').get('reggoldar');
    var referalDari = Hive.box<String>('sasukaDB').get('getPromoFrom');
    var vericode = Hive.box<String>('sasukaDB').get('regVerify').toString();
    var email = Hive.box<String>('sasukaDB').get('regEmail').toString();
    var user = 'Non Registered User';

    var datarequest =
        '{"email":"$email","vericode":"$vericode","referalDari":"$referalDari","hp":"$nomorhp","nama":"$nama","password":"$passw","jk":"$jk","goldar":"$goldar"}';
    var bytes = utf8.encode(datarequest + 'cbf4aq3' + user + c.appid);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/register');

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
        if (cekHP['status'] == 'success') {
          EasyLoading.showSuccess(
              'Pendaftaran Berhasil..! Terima kasih telah menggunakan ${c.namaAplikasi}');
          loginProses();
        } else if (cekHP['status'] == 'wrong code') {
          Get.snackbar('Kode Tidak Valid',
              'Opps... Sepertinya kamu memasukan kode yang salah');
          Get.back();
        }
      } else {
        Get.offAll(LoginPage());
        Get.snackbar('Sambungan terputus',
            'Opps... Sepertinya hubungan ke server kami terputus');
      }
    } catch (e) {
      Get.offAll(LoginPage());
      Get.snackbar('Sambungan terputus',
          'Opps... Sepertinya hubungan ke server kami terputus.');
      print(e);
    }
  }

  Future loginProses() async {
    final c = Get.find<ApiService>();
    Box dbbox = Hive.box<String>('sasukaDB');

    //BODY YANG DIKIRIM
    String appid = dbbox.get('appid');
    String hp = Hive.box<String>('sasukaDB').get('regHp');
    String password = controllerPass2.text;

    var user = 'Non Registered User';
    var datarequest = '{"hp":"$hp","password":"$password","appid":"$appid"}';
    var bytes = utf8.encode(datarequest + 'cbf4aq3' + user + c.appid);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/login');

    try {
      final response = await http.post(url, body: {
        "user": user,
        "appid": c.appid,
        "data_request": datarequest,
        "sign": signature
      });

      if (response.statusCode == 200) {
        EasyLoading.dismiss();
        //CLEAR DATA REGISTER
        Hive.box<String>('sasukaDB').put('regNama', '');
        Hive.box<String>('sasukaDB').put('regEmail', '');
        Hive.box<String>('sasukaDB').put('regHp', '');
        Hive.box<String>('sasukaDB').put('regVerify', '');
        Hive.box<String>('sasukaDB').put('regJenisKelamin', '');
        Hive.box<String>('sasukaDB').put('reggoldar', '');
        //print(response.body);

        Map<String, dynamic> cekLogin = jsonDecode(response.body);
        if (cekLogin['status'] == 'success') {
          EasyLoading.showSuccess('Login Success!');

          Box dbbox = Hive.box<String>('sasukaDB');
          dbbox.put('token', cekLogin['token']);
          dbbox.put('apiToken', cekLogin['apiToken']);
          dbbox.put('nama', cekLogin['nama']);
          dbbox.put('person_id', cekLogin['person_id'].toString());
          dbbox.put('kodess', cekLogin['kodess']);
          dbbox.put('loginSebagai', cekLogin['loginSebagai']);
          dbbox.put('iklanSplash', cekLogin['iklanSplash']);
          dbbox.put('grup', cekLogin['grup'].toString());

          c.namaPenggunaKita.value = cekLogin['nama'];
          c.ssPenggunaKita.value = cekLogin['kodess'];
          c.loginAsPenggunaKita.value = cekLogin['loginSebagai'];

          c.pinStatus.value = cekLogin['pinStatus'].toString();
          c.pinBlokir.value = cekLogin['pinBlokir'];
          c.btnpokok.value = cekLogin['btnpokok'];
          c.btnwajib.value = cekLogin['btnwajib'];
          c.cl.value = cekLogin['cl'];
          c.follower.value = cekLogin['follower'];
          c.follow.value = cekLogin['follow'];
          c.refferal.value = cekLogin['refferal'];
          c.foto.value = cekLogin['foto'];
          c.saldo.value = cekLogin['saldo'];
          c.npwp.value = cekLogin['npwp'];
          c.autoDebetWajib.value = cekLogin['autodebet'];
          c.clLogo.value = cekLogin['clLogo'];
          c.shu.value = cekLogin['shu'];
          c.pokok.value = cekLogin['pokok'];
          c.wajib.value = cekLogin['wajib'];
          c.bank.value = cekLogin['bank'];
          c.norek.value = cekLogin['norek'];
          c.nomorAnggota.value = cekLogin['nomorAnggota'];
          c.versiTerbaru = cekLogin['versiApk'];
          c.scrollTextSHU.value = cekLogin['scroll'];
          c.driverAktif.value = cekLogin['driverAktif'];
          c.pointReward.value = cekLogin['point'];
          c.voucherBelanja.value = cekLogin['voucher'];

          c.cekLoginStatus.value = 'login ok';
          Get.offAll(Dashboardku());
        } else {
          AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.bottomSlide,
              title: 'Pendaftaran Gagal',
              desc: 'Silahkan mengulangi proses pendaftaran kembali, Error 442',
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
        title: Text('Daftar Akun'),
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
                      registerNow(context, controllerPass1.text);
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
              child: Text('Ganti Nomor'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Login'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}
