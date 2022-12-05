import 'dart:async';
import 'dart:convert';
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
import 'introduction.dart';
import '/screen1/daftar.dart';
import '/screen1/login.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import 'base/conn.dart';
import 'folderUmum/marketplace/outletmarketplace.dart';
import 'folderUmum/payment/listTerpilih.dart';
import 'folderUmum/tokosekitar/outletTS.dart';

class InitializeApp extends StatefulWidget {
  @override
  _InitializeAppState createState() => _InitializeAppState();
}

class _InitializeAppState extends State<InitializeApp> {
  Box dbbox = Hive.box<String>('sasukaDB');
  final c = Get.put(ApiService());

  void loadDataAwal() async {
    Box dbbox = Hive.box<String>('sasukaDB');
    String appid = dbbox.get('appid');

    //PINDAHIN DULU LOGIN AWALNYA
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    dbbox.put('tokenCadangan', token);
    dbbox.put('pidCadangan', pid);
    //----------------------------------
    var bytes = utf8.encode('$appid cbf4aq3');
    var signature = md5.convert(bytes).toString();
    dbbox.put('loginSebagai', 'Tamu');
    dbbox.put('token', signature);
    dbbox.put('apiToken', signature);
    dbbox.put('nama', c.namaAwalPengganti);
    dbbox.put('person_id', appid);
    dbbox.put('kodess', c.ssAwalPengganti);
    dbbox.put('iklanSplash', '');
    dbbox.put('grup', '');

    //STATE MANAGER
    c.namaPenggunaKita.value = c.namaAwalPengganti;
    c.ssPenggunaKita.value = c.ssAwalPengganti;
    c.loginAsPenggunaKita.value = 'Tamu';
    c.pinStatus.value = 0.toString();
    c.pinBlokir.value = '';
    c.btnpokok.value = 'false';
    c.btnwajib.value = 'false';
    c.cl.value = 0;
    c.follower.value = '0';
    c.follow.value = '0';
    c.refferal.value = 0;
    c.foto.value = 'https://sasuka.online/sasuka.online/foto/no-avatar.png';
    c.saldo.value = 'Rp. 0,-';
    c.npwp.value = '000.000.000.000';
    c.autoDebetWajib.value = 0;
    c.clLogo.value = 'sasukakop';
    c.shu.value = 'Rp. 0,-';
    c.pokok.value = 'Rp. 0,-';
    c.wajib.value = 'Rp. 0,-';
    c.bank.value = 'Bank Belum dibuat';
    c.norek.value = '000-000-000-000';
    c.nomorAnggota.value = 'PID-000-000-000';
    c.versiTerbaru = '0';
    c.scrollTextSHU.value = c.scrool;
    c.driverAktif.value = 0;
  }

  Future periksaKebutuhandanLoadPertama() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if ((connectivityResult == ConnectivityResult.mobile) ||
        (connectivityResult == ConnectivityResult.wifi)) {
      initDynamicLinks();
      loadDataAwal();
      Get.offAll(() => Dashboardku());
    } else {
      c.sedangTampilNoInternet.value = true;
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        dismissOnBackKeyPress: false,
        dismissOnTouchOutside: false,
        title: '',
        desc: '',
        btnOkText: 'Reload',
        btnOkOnPress: () async {
          c.sedangTampilNoInternet.value = false;
          periksaKebutuhandanLoadPertama();
        },
        body: Column(
          children: [
            Image.asset('images/nointernet.png'),
            Text('Opps..sepertinya internet tidak ditemukan',
                style: TextStyle(
                    fontSize: 20,
                    color: Warna.grey,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            Container(
              padding: EdgeInsets.fromLTRB(22, 7, 22, 11),
              child: Text(
                'periksa kembali koneksi internet kamu agar ${c.namaAplikasi} bisa mencari data yang kamu perlukan',
                style: TextStyle(fontSize: 14, color: Warna.grey),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 16)),
          ],
        ),
      )..show();
    }
  }

  Future cekSesion() async {
    var pid = dbbox.get('person_id');
    var token = dbbox.get('token');
    var user =
        dbbox.get('loginSebagai'); // KALO MEMBER TOKEN NYA DI TARUH DI SIGN

    var url = Uri.parse('');
    if (user == 'Member') {
      url = Uri.parse('${c.baseURL}/sasuka/sesion');
    } else if (user == 'Tamu') {
      url = Uri.parse('${c.baseURL}/sasuka/sesionTamu');
    } else if (user == 'Non Registered User') {
      url = Uri.parse('${c.baseURL}/sasuka/sesion');
    } else {
      url = Uri.parse('${c.baseURL}/sasuka/sesion');
    }
    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + token); //signature
    var signature = md5.convert(bytes).toString(); //signature

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> cekLogin = jsonDecode(response.body);
      if (cekLogin['status'] == 'success') {
        Box dbbox = Hive.box<String>('sasukaDB');
        dbbox.put('loginSebagai', cekLogin['loginSebagai']);
        dbbox.put('token', cekLogin['token']);
        dbbox.put('apiToken', cekLogin['apiToken']);

        dbbox.put('nama', cekLogin['nama']);
        dbbox.put('person_id', cekLogin['person_id'].toString());
        dbbox.put('kodess', cekLogin['kodess']);
        dbbox.put('iklanSplash', cekLogin['iklanSplash']);
        dbbox.put('grup', cekLogin['grup'].toString());

        //STATE MANAGER
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

        Get.off(Dashboardku());
      } else {
        if ((dbbox.get('introScreen') == null) ||
            (dbbox.get('introScreen') == '')) {
          Get.off(App());
        } else {
          Get.off(LoginPage());
        }
      }
    } else {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Error Connection',
        desc: 'Sepertinya terjadi masalah pada koneksi data. Ulangi lagi ya',
        btnCancelText: 'Reload',
        btnCancelOnPress: () {
          cekInternet();
        },
      )..show();
    }
  }

  void initState() {
    super.initState();
    periksaKebutuhandanLoadPertama();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        builder: EasyLoading.init(),
        home: Scaffold(
            backgroundColor: Warna.putih,
            body: Stack(
              children: [
                SizedBox(
                  width: Get.width * 1,
                  height: Get.height * 1,
                  child: FittedBox(
                    child:
                        Image.asset('images/whitelabelUtama/iklansplash.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                // Image.asset(
                //   'images/whitelabelUtama/iklansplash.png',
                //   width: Get.width * 1,
                // ),
                Container(
                  padding: EdgeInsets.only(top: Get.height * 0.85),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          '${c.namaAplikasi}',
                          style: TextStyle(color: Warna.grey, fontSize: 12),
                        ),
                        Text(
                          'Ver : ${c.versiApkSaarini}',
                          style: TextStyle(color: Warna.grey, fontSize: 11),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )));
  }
}

FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
Future<void> initDynamicLinks() async {
  final c = Get.find<ApiService>();

  dynamicLinks.onLink.listen((dynamicLinkData) {
    final Uri deepLink = dynamicLinkData?.link;
    if (deepLink != null) {
      c.debug1aja.value = 'deeplink ditemukan';
      var urString = deepLink.toString();

      if (urString.contains('payCode=')) {
        var paycode = deepLink.queryParameters['payCode'];
        c.paymentID.value = paycode;
        Get.to(() => PaymentPointTerpilih());
      } else if (urString.contains('product=')) {
        //SET DATA BARANG DULU
        var produkID = deepLink.queryParameters['product'].toString();
        var promoSS = deepLink.queryParameters['promo'];
        Box dbbox = Hive.box<String>('sasukaDB');
        if (dbbox.get('loginSebagai') != 'Member') {
          dbbox.put('getPromoFrom', promoSS);
        }
        bukaProdukDeepLink(produkID);
      } else if (urString.contains('tokosekitar=')) {
        //SET DATA BARANG DULU
        var dataID = deepLink.queryParameters['tokosekitar'].toString();
        var promoSS = deepLink.queryParameters['promo'];
        Box dbbox = Hive.box<String>('sasukaDB');
        if (dbbox.get('loginSebagai') != 'Member') {
          dbbox.put('getPromoFrom', promoSS);
        }
        c.idPilihanOutletTS.value = int.parse(dataID);
        Get.to(() => DetailOtletTS());
      } else if (urString.contains('promo=')) {
        var promoSS = deepLink.queryParameters['promo'];
        Box dbbox = Hive.box<String>('sasukaDB');

        if (dbbox.get('loginSebagai') != 'Member') {
          dbbox.put('getPromoFrom', promoSS);
          Get.to(() => DaftarAplikasi());
        }
      }
    }
  }).onError((error) {
    print('onLink error');
    print(error.message);
  });
  final PendingDynamicLinkData data =
      await FirebaseDynamicLinks.instance.getInitialLink();
  final Uri deepLink = data?.link;

  if (deepLink != null) {
    c.debug1aja.value = 'deeplink ditemukan';
    var urString = deepLink.toString();

    if (urString.contains('payCode=')) {
      var paycode = deepLink.queryParameters['payCode'];
      c.paymentID.value = paycode;
      Get.to(() => PaymentPointTerpilih());
    } else if (urString.contains('product=')) {
      //SET DATA BARANG DULU
      var produkID = deepLink.queryParameters['product'].toString();
      var promoSS = deepLink.queryParameters['promo'];
      Box dbbox = Hive.box<String>('sasukaDB');
      if (dbbox.get('loginSebagai') != 'Member') {
        dbbox.put('getPromoFrom', promoSS);
      }
      bukaProdukDeepLink(produkID);
    } else if (urString.contains('tokosekitar=')) {
      //SET DATA BARANG DULU
      var dataID = deepLink.queryParameters['tokosekitar'].toString();
      var promoSS = deepLink.queryParameters['promo'];
      Box dbbox = Hive.box<String>('sasukaDB');
      if (dbbox.get('loginSebagai') != 'Member') {
        dbbox.put('getPromoFrom', promoSS);
      }
      c.idPilihanOutletTS.value = int.parse(dataID);
      Get.to(() => DetailOtletTS());
    } else if (urString.contains('promo=')) {
      var promoSS = deepLink.queryParameters['promo'];
      Box dbbox = Hive.box<String>('sasukaDB');

      if (dbbox.get('loginSebagai') != 'Member') {
        dbbox.put('getPromoFrom', promoSS);
        Get.to(() => DaftarAplikasi());
      }
    }
  }
}

void bukaProdukDeepLink(String produkID) async {
  Box dbbox = Hive.box<String>('sasukaDB');
  final c = Get.find<ApiService>();
  var pid = dbbox.get('person_id');
  var token = dbbox.get('token');
  var latitude = c.latitude.value;
  var longitude = c.longitude.value;

  var url = Uri.parse('${c.baseURL}/sasuka/deeplinkProduk');
  var user =
      dbbox.get('loginSebagai'); // KALO MEMBER TOKEN NYA DI TARUH DI SIGN
  var datarequest =
      '{"pid":"$pid","lat":"$latitude","long":"$longitude","produkID":"$produkID"}';
  var bytes = utf8.encode(datarequest + token); //signature
  var signature = md5.convert(bytes).toString(); //signature

  final response = await http.post(url, body: {
    "user": user,
    "appid": c.appid,
    "data_request": datarequest,
    "sign": signature
  });
  print(response.body);
  if (response.statusCode == 200) {
    Map<String, dynamic> arrr = jsonDecode(response.body);
    if (arrr['status'] == 'success') {
      var valHistory = arrr['data'];
      var fitur = arrr['fitur'];
      if (fitur == 'Sasuka Mall') {
        c.idOutletPilihanMP.value = valHistory[1].toString();

        if ((c.idOutletpadakeranjangMP.value == c.idOutletPilihanMP.value) ||
            (c.idOutletpadakeranjangMP.value == '0')) {
          c.namaOutletMP.value = valHistory[7];
          c.namaOutletMP.value = valHistory[7];
          c.tagIdMPC.value = valHistory[1].toString();
          c.namaMPC.value = valHistory[2];
          c.gambarMPC.value = valHistory[3];
          c.namaoutletMPC.value = valHistory[7];
          c.hargaMPC.value = valHistory[5].toString();
          c.lokasiMPC.value = valHistory[4];
          c.deskripsiMPC.value = valHistory[10];
          c.hargaIntMPC.value = valHistory[8];
          c.idOutletMPC.value = valHistory[1].toString();
          c.itemIdMPC.value = valHistory[11].toString();

          Get.to(() => DetailOtletMarketplace());
        } else {
          AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.noHeader,
            animType: AnimType.bottomSlide,
            title: '',
            desc: '',
            body: Column(
              children: [
                Image.asset('images/nofood.png'),
                Text('Pindah ke Outlet lain',
                    style: TextStyle(
                        fontSize: 20,
                        color: Warna.grey,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center),
                Container(
                  padding: EdgeInsets.fromLTRB(22, 7, 22, 11),
                  child: Text(
                    'Sepertinya kamu ingin berpindah ke outlet lain, Boleh kok, keranjang di outlet sebelumnya kami hapus ya...',
                    style: TextStyle(fontSize: 14, color: Warna.grey),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 16)),
                Container(
                  padding: EdgeInsets.only(left: 22, right: 22),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: Text('Tidak jadi')),
                      ElevatedButton(
                          onPressed: () {
                            /*
                              c.idOutletpadakeranjangMP.value = '0';
                              c.jumlahItemMP.value = 0;
                              c.hargaKeranjangMP.value = 0;
                              c.jumlahBarangMP.value = 0;

                              c.keranjangMP.clear();
                              c.idOutletPilihanMP.value =
                                  valHistory[1].toString();
                              c.namaoutletpadakeranjangMP.value =
                                  'dalam keranjangmu';

                              c.namaOutletMP.value = valHistory[7];
                              c.tagIdMPC.value = valHistory[1].toString();
                              c.namaMPC.value = valHistory[2];
                              c.gambarMPC.value = valHistory[3];
                              c.namaoutletMPC.value = valHistory[7];
                              c.hargaMPC.value = valHistory[5];
                              c.lokasiMPC.value = valHistory[4];
                              c.deskripsiMPC.value = valHistory[10];
                              c.hargaIntMPC.value = valHistory[8];
                              c.idOutletMPC.value = valHistory[1].toString();
                              c.itemIdMPC.value = valHistory[11].toString();

                              //Get.off(DetailOtletMarketplace());
                              */
                          },
                          child: Text('Ok Ganti')),
                    ],
                  ),
                )
              ],
            ),
          )..show();
        }

        Get.to(() => DetailOtletMarketplace());
      }
    }
  }
}
