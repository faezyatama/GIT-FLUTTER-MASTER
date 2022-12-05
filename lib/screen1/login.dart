import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import '/dashboard/view/dashboard.dart';
import '/screen1/buatPasswordBaruRecovery.dart';
import '/screen1/daftar.dart';
import '/screen1/lupa_password.dart';
import 'package:http/http.dart' as http;
// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';

import '../../folderUmum/chat/view/chatDariLuar.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Box dbbox = Hive.box<String>('sasukaDB');
  final c = Get.find<ApiService>();
  bool pass = true;
  bool pass2 = true;
  //end timer
  final controllerHp = TextEditingController();
  final controllerPass = TextEditingController();
  final controllerOtp = TextEditingController();
  DateTime currentBackPressTime;

  Future loginProses(context) async {
    //BODY YANG DIKIRIM
    String hp = controllerHp.text;
    String password = controllerPass.text;

    var user = 'Non Registered User';
    var datarequest = '{"hp":"$hp","password":"$password","appid":"$c.appid"}';
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

      print(response.body);
      // print('login-get-response');

      if (response.statusCode == 200) {
        EasyLoading.dismiss();

        Map<String, dynamic> cekLogin = jsonDecode(response.body);
        if (cekLogin['status'] == 'success') {
          EasyLoading.showSuccess('Login Success!');

          Box dbbox = Hive.box<String>('sasukaDB');
          //LOGIN SEBAGAI
          dbbox.put('loginSebagai', cekLogin['loginSebagai']);
          dbbox.put('token', cekLogin['token']);
          dbbox.put('apiToken', cekLogin['apiToken']);
          dbbox.put('nama', cekLogin['nama']);
          dbbox.put('person_id', cekLogin['person_id'].toString());
          dbbox.put('kodess', cekLogin['kodess']);
          dbbox.put('iklanSplash', cekLogin['iklanSplash']);
          dbbox.put('grup', cekLogin['grup'].toString());

          //STATE MANAGER
          c.splashLink = cekLogin['splashLink'];
          c.iklanSplash = cekLogin['iklanSplash'];

          c.namaPenggunaKita.value = cekLogin['nama'];
          c.ssPenggunaKita.value = cekLogin['kodess'];
          c.loginAsPenggunaKita.value = cekLogin['loginSebagai'];
          c.pinStatus.value = cekLogin['pinStatus'].toString();

          c.pinBlokir.value = cekLogin['pinBlokir'];
          c.btnpokok.value = cekLogin['btnpokok'];
          c.btnwajib.value = cekLogin['btnwajib'];
          c.sipokAnggota = cekLogin['sipokAnggota'];
          c.siwaAnggota = cekLogin['siwaAnggota'];

          c.cl.value = cekLogin['cl'];
          c.follower.value = cekLogin['follower'];
          c.follow.value = cekLogin['follow'];
          c.refferal.value = cekLogin['refferal'];
          c.foto.value = cekLogin['foto'];
          c.saldo.value = cekLogin['saldo'];
          c.saldoInt.value = cekLogin['saldoInt'];
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
          Get.off(Dashboardku());
        } else {
          AwesomeDialog(
              context: context,
              dialogType: DialogType.noHeader,
              animType: AnimType.bottomSlide,
              title: 'Akses Ditolak',
              desc:
                  'Maaf nomor hp dan password yang kamu masukan tidak cocok, Silahkan mengulangi lagi',
              btnCancelText: 'Siap',
              btnCancelOnPress: () {})
            ..show();
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar(
          'Gagal memproses data', 'Pastikan koneksi internet kamu stabil ya');
      print(e);
    }
  }

  Future loginProsesWithOTP(context) async {
    //BODY YANG DIKIRIM
    String hp = controllerHp.text;
    c.otpPass = controllerOtp.text;
    String ootpp = controllerOtp.text;
    String kodeValidasi = c.requestPassword.value;

    var user = 'Non Registered User';
    var datarequest =
        '{"hp":"$hp","password":"$ootpp","image":"$kodeValidasi","appid":"$c.appid"}';
    var bytes = utf8.encode(datarequest + 'cbf4aq3' + user + c.appid);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/loginWithOtp');

    try {
      final response = await http.post(url, body: {
        "user": user,
        "appid": c.appid,
        "data_request": datarequest,
        "sign": signature
      });
      controllerOtp.text = '';
      print(response.body);
      // print('login-get-response');

      if (response.statusCode == 200) {
        EasyLoading.dismiss();

        Map<String, dynamic> cekLogin = jsonDecode(response.body);

        if (cekLogin['status'] == 'success') {
          EasyLoading.showSuccess(
              'OTP berhasil di validasi, Silahkan mengganti password');
          c.requestPasswordHP.value = hp;
          Get.to(DaftarkanPasswordviaOTP());
        } else if (cekLogin['status'] == 'gagal membuat password') {
          c.requestPassword.value = '';
          AwesomeDialog(
              context: context,
              dialogType: DialogType.noHeader,
              animType: AnimType.bottomSlide,
              title: 'Pembuatan password gagal',
              desc: 'Silahkan melakukan proses recovery password kembali,',
              btnCancelText: 'Siap',
              btnCancelOnPress: () {})
            ..show();
        } else {
          AwesomeDialog(
              context: context,
              dialogType: DialogType.noHeader,
              animType: AnimType.bottomSlide,
              title: 'Akses Ditolak',
              desc:
                  'Maaf NOMOR HP dan atau OTP yang kamu masukan tidak cocok, Silahkan mengulangi lagi',
              btnCancelText: 'Siap',
              btnCancelOnPress: () {})
            ..show();
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar(
          'Gagal memproses data', 'Pastikan koneksi internet kamu stabil ya');
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        bottomNavigationBar: Container(
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Warna.warnautama),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                        side: BorderSide(color: Warna.warnautama)))),
            onPressed: () {
              // print('disini ob');
              loginAsTamu();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Klik disini untuk Masuk tanpa pendaftaran',
                  style: TextStyle(color: Warna.putih),
                ),
                Text(
                  'kamu bisa mendaftar akun ${c.namaAplikasi} nanti',
                  style: TextStyle(color: Warna.putih, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          width: Get.width * 1,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/whitelabelUtama/background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              ListView(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 33),
                    child: Card(
                      color: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      margin: EdgeInsets.all(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'images/whitelabelUtama/iconlogo.png',
                            width: Get.width * 0.4,
                          ),
                          Container(
                            child: Column(
                              children: [
                                Padding(padding: EdgeInsets.only(top: 22)),
                                Text('Sudah Punya Akun ??',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                        color: Warna.warnautama)),
                                Text('Cukup masukan nomor hp dan password',
                                    style: TextStyle(
                                        fontSize: 12, color: Warna.warnautama)),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(25, 25, 25, 0),
                            child: TextField(
                              style: TextStyle(fontSize: 25),
                              keyboardType: TextInputType.phone,
                              controller: controllerHp,
                              decoration: InputDecoration(
                                  labelText: 'Nomor HP / Username',
                                  labelStyle: TextStyle(fontSize: 15),
                                  prefixIcon: Icon(Icons.person),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                          Obx(() => Column(
                                children: [
                                  (c.requestPassword.value == '')
                                      ? Container(
                                          margin: EdgeInsets.fromLTRB(
                                              25, 10, 25, 0),
                                          child: TextField(
                                            style: TextStyle(fontSize: 25),
                                            controller: controllerPass,
                                            obscureText: pass,
                                            keyboardType:
                                                TextInputType.visiblePassword,
                                            decoration: InputDecoration(
                                                labelText: 'Password',
                                                labelStyle:
                                                    TextStyle(fontSize: 15),
                                                prefixIcon: Icon(Icons.vpn_key),
                                                suffixIcon: IconButton(
                                                    icon: Icon(
                                                        Icons.remove_red_eye),
                                                    onPressed: () {
                                                      setState(() {
                                                        if (pass == true) {
                                                          pass = false;
                                                        } else {
                                                          pass = true;
                                                        }
                                                      });
                                                    }),
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10))),
                                          ),
                                        )
                                      : Padding(
                                          padding: EdgeInsets.only(top: 1)),
                                  (c.requestPassword.value != '')
                                      ? Container(
                                          margin: EdgeInsets.fromLTRB(
                                              25, 10, 25, 0),
                                          child: TextField(
                                            style: TextStyle(fontSize: 25),
                                            controller: controllerOtp,
                                            obscureText: pass2,
                                            keyboardType:
                                                TextInputType.visiblePassword,
                                            decoration: InputDecoration(
                                                labelText:
                                                    'Kode OTP via SMS/Whatsapp',
                                                labelStyle:
                                                    TextStyle(fontSize: 15),
                                                prefixIcon: Icon(Icons.vpn_key),
                                                suffixIcon: IconButton(
                                                    icon: Icon(
                                                        Icons.remove_red_eye),
                                                    onPressed: () {
                                                      setState(() {
                                                        if (pass2 == true) {
                                                          pass2 = false;
                                                        } else {
                                                          pass2 = true;
                                                        }
                                                      });
                                                    }),
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10))),
                                          ),
                                        )
                                      : Padding(
                                          padding: EdgeInsets.only(top: 2)),
                                ],
                              )),
                          Container(
                            margin: EdgeInsets.fromLTRB(25, 0, 25, 0),
                            child: Row(
                              children: [
                                Column(
                                  children: [],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(25, 0, 25, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(() => Column(
                                      children: [
                                        (c.requestPassword.value == '')
                                            ? RawMaterialButton(
                                                onPressed: () {
                                                  Get.to(() => LupaPassword());
                                                },
                                                constraints: BoxConstraints(),
                                                elevation: 1.0,
                                                fillColor: Warna.putih,
                                                child: Text(
                                                  'Password Recovery',
                                                  style: TextStyle(
                                                      color: Warna.grey,
                                                      fontSize: 11),
                                                ),
                                                padding: EdgeInsets.fromLTRB(
                                                    11, 2, 11, 2),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(9)),
                                                ),
                                              )
                                            : Padding(
                                                padding:
                                                    EdgeInsets.only(top: 1)),
                                      ],
                                    )),
                                Obx(() => Column(
                                      children: [
                                        (c.requestPassword.value == '')
                                            ? ElevatedButton(
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty.all<Color>(
                                                            Warna.warnautama),
                                                    shape: MaterialStateProperty.all<
                                                            RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    18),
                                                            side: BorderSide(
                                                                color: Warna
                                                                    .warnautama)))),
                                                onPressed: () {
                                                  if ((controllerHp.text ==
                                                          '') ||
                                                      (controllerPass.text ==
                                                          '')) {
                                                    AwesomeDialog(
                                                      context: Get.context,
                                                      dialogType:
                                                          DialogType.noHeader,
                                                      animType:
                                                          AnimType.rightSlide,
                                                      title: 'Login',
                                                      desc:
                                                          'Opps... sepertinya nomor HP dan Password belum dimasukan dengan benar',
                                                      btnCancelText: 'OK SIAP',
                                                      btnCancelOnPress: () {},
                                                    )..show();
                                                  } else {
                                                    EasyLoading.instance
                                                      ..userInteractions = false
                                                      ..dismissOnTap = false;
                                                    EasyLoading.show(
                                                        status:
                                                            'Memeriksa login...');

                                                    loginProses(context);
                                                  }
                                                },
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.login),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 11)),
                                                    Text('Login'),
                                                  ],
                                                ),
                                              )
                                            : ElevatedButton(
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.green),
                                                    shape: MaterialStateProperty.all<
                                                            RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    18),
                                                            side: BorderSide(
                                                                color: Warna.warnautama)))),
                                                onPressed: () {
                                                  if ((controllerHp.text ==
                                                          '') ||
                                                      (controllerOtp.text ==
                                                          '')) {
                                                    AwesomeDialog(
                                                      context: Get.context,
                                                      dialogType:
                                                          DialogType.noHeader,
                                                      animType:
                                                          AnimType.rightSlide,
                                                      title:
                                                          'Recovery Password',
                                                      desc:
                                                          'Opps... sepertinya nomor HP dan kode OTP belum dimasukan dengan benar',
                                                      btnCancelText: 'OK SIAP',
                                                      btnCancelOnPress: () {},
                                                    )..show();
                                                  } else {
                                                    EasyLoading.instance
                                                      ..userInteractions = false
                                                      ..dismissOnTap = false;
                                                    EasyLoading.show(
                                                        status:
                                                            'Memeriksa kode OTP...');

                                                    loginProsesWithOTP(context);
                                                  }
                                                },
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.login),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 11)),
                                                    Text('Buat Password Baru'),
                                                  ],
                                                ),
                                              )
                                      ],
                                    )),
                              ],
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 55)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                child: GestureDetector(
                                  onTap: () {
                                    Get.to(() => DaftarAplikasi());
                                  },
                                  child: Column(
                                    children: [
                                      Text('Belum punya akun ??',
                                          style: TextStyle(
                                            fontSize: 14,
                                          )),
                                      RawMaterialButton(
                                        onPressed: () {
                                          Get.to(() => DaftarAplikasi());
                                        },
                                        constraints: BoxConstraints(),
                                        elevation: 1.0,
                                        fillColor: Warna.warnautama,
                                        child: Text('Daftar Disini',
                                            style: TextStyle(
                                                color: Warna.putih,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700)),
                                        padding:
                                            EdgeInsets.fromLTRB(22, 4, 22, 4),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(9)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(padding: EdgeInsets.only(left: 22)),
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => LuarLiveSupportChatDetailPage());
                                },
                                child: Column(
                                  children: [
                                    Icon(Icons.chat_rounded,
                                        color: Warna.warnautama, size: 28),
                                    Text('Live Support',
                                        style: TextStyle(
                                          color: Warna.warnautama,
                                          fontSize: 12,
                                        ))
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void loginAsTamu() async {
    //BODY YANG DIKIRIM
    String appid = dbbox.get('appid');

    var user = 'Non Registered User';
    var datarequest = '{"appid":"$appid"}';
    var bytes = utf8.encode(datarequest + 'cbf4aq3' + user + c.appid);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/loginAsTamu');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });
    print(response.body);

    if (response.statusCode == 200) {
      EasyLoading.dismiss();
      print(response.body);
      Map<String, dynamic> cekLogin = jsonDecode(response.body);
      if (cekLogin['status'] == 'success') {
        Box dbbox = Hive.box<String>('sasukaDB');
        //LOGIN SEBAGAI
        dbbox.put('loginSebagai', cekLogin['loginSebagai']);
        dbbox.put('token', cekLogin['token']);
        dbbox.put('apiToken', cekLogin['apiToken']);
        dbbox.put('nama', cekLogin['nama']);
        dbbox.put('person_id', cekLogin['person_id'].toString());
        dbbox.put('kodess', cekLogin['kodess']);
        dbbox.put('iklanSplash', cekLogin['iklanSplash']);
        dbbox.put('grup', cekLogin['grup'].toString());

        //STATE MANAGER
        c.splashLink = cekLogin['splashLink'];
        c.iklanSplash = cekLogin['iklanSplash'];

        c.namaPenggunaKita.value = cekLogin['nama'];
        c.ssPenggunaKita.value = cekLogin['kodess'];
        c.loginAsPenggunaKita.value = cekLogin['loginSebagai'];

        c.pinStatus.value = cekLogin['pinStatus'].toString();
        c.pinBlokir.value = cekLogin['pinBlokir'];
        c.btnpokok.value = cekLogin['btnpokok'];
        c.btnwajib.value = cekLogin['btnwajib'];

        c.sipokAnggota = cekLogin['sipokAnggota'];
        c.siwaAnggota = cekLogin['siwaAnggota'];

        c.cl.value = cekLogin['cl'];
        c.follower.value = cekLogin['follower'];
        c.follow.value = cekLogin['follow'];
        c.refferal.value = cekLogin['refferal'];
        c.foto.value = cekLogin['foto'];
        c.saldo.value = cekLogin['saldo'];
        c.saldoInt.value = cekLogin['saldoInt'];
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

        Get.off(Dashboardku());
      } else {
        AwesomeDialog(
            context: context,
            dialogType: DialogType.noHeader,
            animType: AnimType.bottomSlide,
            title: 'Akses Ditolak',
            desc:
                'Maaf sepertinya terjadi kesalahan saat masuk ke aplikasi, Silahkan mengulangi lagi',
            btnCancelText: 'Siap',
            btnCancelOnPress: () {})
          ..show();
      }
    }
  }
}
