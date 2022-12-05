import 'dart:async';
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../folderKhusus/gabunganFitur/menuAngkutan.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import '/dashboard/bigmenu/ksp.dart';

import 'package:auto_size_text/auto_size_text.dart';

import '../../folderSimpanPinjam/homepinjaman.dart';
import '../../folderSimpanPinjam/homesimpanan.dart';
import '../../folderSimpanPinjam/lihatProdukPinjaman.dart';
import '../../folderSimpanPinjam/lihatProdukSimpanan.dart';
import '../../folderUmum/freshmart/etalase.dart';
import '../../folderUmum/marketplace/etalase.dart';
import '../../folderUmum/mobil/trackingdriverMobil.dart';
import '../../folderUmum/mobil/tujuanPerjalananMobil.dart';
import '../../folderUmum/motor/trackingdriver.dart';
import '../../folderUmum/motor/tujuanPerjalanan.dart';
import '../../folderUmum/pickup/trackingdriverPickup.dart';
import '../../folderUmum/pickup/tujuanPerjalananPickup.dart';
import '../../folderUmum/samakan/etalase.dart';
import '../../folderUmum/tokosekitar/etalase.dart';
import '../../folderUmum/transaksi/emoney.dart';
import '../../folderUmum/transaksi/game.dart';
import '../../folderUmum/transaksi/ppob.dart';
import '../../folderUmum/transaksi/pulsa.dart';
import '../../folderUmum/transaksi/tokenpln.dart';
import '../../folderUmum/transaksi/tvprabayar.dart';

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  static double ukuranicon = 43;
  var lebar = 0.25;
  var myGroup = AutoSizeGroup();
  final c = Get.find<ApiService>();
  Timer timerMainMenu;

  @override
  void initState() {
    super.initState();
    timerMainMenu =
        Timer.periodic(Duration(seconds: 4), (Timer t) => loadDataMainMenu());
  }

  @override
  void dispose() {
    timerMainMenu.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(width: 8.0),
          (c.bigMenu == true)
              ? KspMenu()
              : Container(
                  color: Color.fromARGB(255, 255, 255, 255),
                  height: Get.height * 0.17,
                  width: 2,
                ),
          Container(
            margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
            color: Colors.grey,
            height: Get.height * 0.17,
            width: 2,
          ),
          Padding(padding: EdgeInsets.only(left: 0)),
          loadMainMenu(),
        ],
      ),
      //row
    );
  }

  // void cekHistoryTiket() async {
  //   bool conn = await cekInternet();
  //   if (!conn) {
  //     return noInternetConnection();
  //   }
  //   Box dbbox = Hive.box<String>('sasukaDB');
  //   var token = dbbox.get('token');
  //   var pid = dbbox.get('person_id');

  //   var datarequest = '{"pid":"$pid"}';
  //   var bytes = utf8.encode(datarequest + '$token');
  //   var signature = md5.convert(bytes).toString();
  //   var user = dbbox.get('loginSebagai');

  //   var url = Uri.parse('${c.baseURL}/sasuka/cekTiket');

  //   final response = await http.post(url, body: {
  //     "user": user,
  //     "appid": c.appid,
  //     "data_request": datarequest,
  //     "sign": signature
  //   });

  //   // print(response.body);
  //   if (response.statusCode == 200) {
  //     Map<String, dynamic> hasil = jsonDecode(response.body);
  //     if (hasil['status'] == 'success') {
  //       var trx = hasil['transaksi'];
  //       if (trx > 0) {
  //         Get.to(() => HistoryTiket());
  //       } else {
  //         Get.to(() => TiketSatuAja());
  //       }
  //     }
  //   }
  // }

  void tampilkanBesar(s, a, f) {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Image.asset(
            s,
            width: Get.width * 0.75,
          ),
          Container(
            padding: EdgeInsets.all(11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: Get.width * 0.6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a,
                          style: TextStyle(
                              fontSize: 18,
                              color: Warna.warnautama,
                              fontWeight: FontWeight.w600)),
                      Text(
                        f,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Padding(padding: EdgeInsets.only(top: 9)),
                    ],
                  ),
                ),
                GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Icon(
                      Icons.cancel,
                      size: 27,
                      color: Colors.grey,
                    ))
              ],
            ),
          ),
        ],
      ),
    )..show();
  }

  mainMenu1(img, fitur) {
    return GestureDetector(
      onTap: () {
        if (fitur == c.nNamafitPulsa) {
          Get.to(() => PulsaTrx());
        } else if (fitur == c.nNamafitTv) {
          Get.to(() => TVPrabayar());
        } else if (fitur == c.nNamafitPln) {
          Get.to(() => TokenPln());
        } else if (fitur == c.nNamafitEmoney) {
          Get.to(() => EmoneyTrx());
        } else if (fitur == c.nNamafitPPob) {
          Get.to(() => PembayaranPPOB());
        } else if (fitur == c.nNamafitGame) {
          Get.to(() => VoucherGame());
        } else if (fitur == c.nNamafitTosek) {
          Get.to(() => EtalaseTokoSekitar());
        } else if (fitur == c.nNamafitMobil) {
          cekDuluTransaksiMobil();
        } else if (fitur == c.nNamafitMotor) {
          cekDuluTransaksiMotor();
        } else if (fitur == c.nNamafitPickup) {
          cekDuluTransaksiPickup();
        } else if (fitur == c.nNamafitMakan) {
          Get.to(() => EtalaseMakanan());
        } else if (fitur == c.nNamafitMarketplace) {
          Get.to(() => EtalaseMarketplace());
        } else if (fitur == c.nNamafitFreshmart) {
          Get.to(() => EtalaseFreshmart());
        } else if (fitur == c.nNamafitSiPi) {
          pilihSimpanPinjam();
        } else if (fitur == c.nNamafitGabungAngkutan) {
          Get.to(() => GabunganFiturAngkutan());
        } else if (fitur == c.nNamafitGabungMarketplace) {
          menuGabunganMarketplace();
        }
      },
      child: Column(
        children: [
          Image.asset(
            'images/whitelabelMainMenu/' + img,
            width: ukuranicon,
          ),
          AutoSizeText(
            fitur,
            style: TextStyle(color: Warna.grey),
            group: myGroup,
            maxLines: 2,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  void loadDataMainMenu() async {
    Box dbbox = Hive.box<String>('sasukaDB');
    var pid = dbbox.get('person_id');
    var user = 'Non Registered User';
    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + 'cbf4aq3' + user + c.appid);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/loadDataMainMenu');
    if (c.mainmenuloaddata == '') {
      final response = await http.post(url, body: {
        "user": user,
        "appid": c.appid,
        "data_request": datarequest,
        "sign": signature
      });
      if (response.statusCode == 200) {
        Map<String, dynamic> hasil = jsonDecode(response.body);
        if (hasil['status'] == 'success') {
          c.mainmenuloaddata = response.body;
          setState(() {
            c.daftarMenuUtama = hasil['daftarMenuUtama'];
            c.mitraFreshmart.value = hasil['mitraFreshmart'].toString();
            c.mitraTokosekitar.value = hasil['mitraTokosekitar'].toString();
            c.mitraTransportasi.value = hasil['mitraTransportasi'].toString();
            c.mitraMarketplace.value = hasil['mitraMarketplace'].toString();
            c.mitraMakanan.value = hasil['mitraMakanan'].toString();
            c.mitraReferal.value = hasil['mitraReferal'].toString();
          });
        }
      }
    } else {
      timerMainMenu.cancel();
      Map<String, dynamic> hasil = jsonDecode(c.mainmenuloaddata);
      setState(() {
        c.daftarMenuUtama = hasil['daftarMenuUtama'];
        c.mitraFreshmart.value = hasil['mitraFreshmart'].toString();
        c.mitraTokosekitar.value = hasil['mitraTokosekitar'].toString();
        c.mitraTransportasi.value = hasil['mitraTransportasi'].toString();
        c.mitraMarketplace.value = hasil['mitraMarketplace'].toString();
        c.mitraMakanan.value = hasil['mitraMakanan'].toString();
        c.mitraReferal.value = hasil['mitraReferal'].toString();
      });
    }
  }

  List<Container> mainMenuContainer = [];

  loadMainMenu() {
    var dataMenu = c.daftarMenuUtama;
    mainMenuContainer = [];

    if (dataMenu.length > 0) {
      for (var i = 0; i < dataMenu.length; i++) {
        var logo1 = dataMenu[i][0];
        var fitur1 = dataMenu[i][1];

        var logo2 = dataMenu[i][2];
        var fitur2 = dataMenu[i][3];

        mainMenuContainer.add(
          Container(
            height: Get.height * 0.23,
            width: Get.width * lebar,
            child: Column(
              children: [
                SizedBox(
                  height: Get.height * 0.11,
                  child: mainMenu1(logo1, fitur1),
                ),
                Padding(padding: EdgeInsets.all(1)),
                SizedBox(
                  height: Get.height * 0.11,
                  child: mainMenu1(logo2, fitur2),
                ),
              ],
            ),
          ),
        );
      }
    }
    return Row(
      children: mainMenuContainer,
    );
  }

  pilihSimpanPinjam() {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Text(
            c.namaAplikasi,
            style: TextStyle(fontSize: 18, color: Warna.grey),
          ),
          Text(
            'Unit Simpan Pinjam (USP)',
            style: TextStyle(fontSize: 12, color: Warna.grey),
          ),
          Container(
            padding: EdgeInsets.all(11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: Get.width * 0.33,
                  child: GestureDetector(
                    onTap: () {
                      if (c.loginAsPenggunaKita.value == 'Member') {
                        cekPunyaSimpananTidak();
                      } else {
                        Get.snackbar('Akun Dibutuhkan',
                            'Silahkan login terlebihdahulu untuk mengakses layanan ini');
                      }
                    },
                    child: Column(
                      children: [
                        Image.asset(
                            'images/whitelabelMainMenu/iconsimpanan.png',
                            width: Get.width * 0.12),
                        Text(
                          'Produk Simpanan',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: Get.width * 0.33,
                  child: GestureDetector(
                    onTap: () {
                      if (c.loginAsPenggunaKita.value == 'Member') {
                        cekPunyaPinjamanTidak();
                      } else {
                        Get.snackbar('Akun Dibutuhkan',
                            'Silahkan login terlebihdahulu untuk mengakses layanan ini');
                      }
                    },
                    child: Column(
                      children: [
                        Image.asset(
                            'images/whitelabelMainMenu/iconpinjaman.png',
                            width: Get.width * 0.12),
                        Text(
                          'Produk Pinjaman',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )..show();
  }

  menuGabunganMarketplace() {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      isDense: true,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Text(
            c.namaAplikasi,
            style: TextStyle(fontSize: 18, color: Warna.grey),
          ),
          Text(
            'Belanja Apapun kini makin mudah',
            style: TextStyle(fontSize: 12, color: Warna.grey),
          ),
          Container(
            padding: EdgeInsets.all(11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: Get.width * 0.25,
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => EtalaseMakanan());
                    },
                    child: Column(
                      children: [
                        Image.asset('images/whitelabelMainMenu/makan.png',
                            width: Get.width * 0.12),
                        Text(
                          c.nNamafitMakan,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: Get.width * 0.25,
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => EtalaseFreshmart());
                    },
                    child: Column(
                      children: [
                        Image.asset('images/whitelabelMainMenu/freshmart.png',
                            width: Get.width * 0.12),
                        Text(
                          c.nNamafitFreshmart,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: Get.width * 0.25,
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => EtalaseMarketplace());
                    },
                    child: Column(
                      children: [
                        Image.asset('images/whitelabelMainMenu/mall.png',
                            width: Get.width * 0.12),
                        Text(
                          c.nNamafitMarketplace,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )..show();
  }

  cekPunyaSimpananTidak() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();
    var url = Uri.parse('${c.baseURL}/mobileApps/cekPunyaSimpananTidak');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    // EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        Get.back();
        Get.to(HomeSimpanan());
      } else {
        Get.back();
        Get.to(LihatProdukSimpanan());
      }
    }
  }

  cekPunyaPinjamanTidak() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();
    var url = Uri.parse('${c.baseURL}/mobileApps/cekPunyaPinjamanTidak');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    // EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        Get.back();
        Get.to(HomePinjaman());
      } else {
        Get.back();
        Get.to(LihatProdukPinjaman());
      }
    }
  }
}

void cekDuluTransaksiMobil() async {
  final c = Get.find<ApiService>();

  bool conn = await cekInternet();
  if (!conn) {
    return noInternetConnection();
  }
  Box dbbox = Hive.box<String>('sasukaDB');
  var token = dbbox.get('token');
  var pid = dbbox.get('person_id');
  var user = dbbox.get('loginSebagai');

  var datarequest = '{"pid":"$pid"}';
  var bytes = utf8.encode(datarequest + '$token' + user);
  var signature = md5.convert(bytes).toString();

  var url =
      Uri.parse('${c.baseURLdriver}/mobileAppsUser/cekAdaPerjalananGakMobil');

  final response = await http.post(url, body: {
    "user": user,
    "appid": c.appid,
    "data_request": datarequest,
    "sign": signature,
    "package": c.packageName
  });

  //print(response.body);
  if (response.statusCode == 200) {
    Map<String, dynamic> hasil = jsonDecode(response.body);
    if (hasil['status'] == 'success') {
      var trx = hasil['transaksi'];
      if (trx > 0) {
        Get.to(() => TrackingDriverMobil());
      } else {
        Get.to(() => TujuanPerjalananMobil());
      }
    }
  }
}

void cekDuluTransaksiPickup() async {
  final c = Get.find<ApiService>();
  bool conn = await cekInternet();
  if (!conn) {
    return noInternetConnection();
  }
  Box dbbox = Hive.box<String>('sasukaDB');
  var token = dbbox.get('token');
  var pid = dbbox.get('person_id');
  var user = dbbox.get('loginSebagai');

  var datarequest = '{"pid":"$pid"}';
  var bytes = utf8.encode(datarequest + '$token' + user);
  var signature = md5.convert(bytes).toString();

  var url =
      Uri.parse('${c.baseURLdriver}/mobileAppsUser/cekAdaPerjalananGakPickup');

  final response = await http.post(url, body: {
    "user": user,
    "appid": c.appid,
    "data_request": datarequest,
    "sign": signature,
    "package": c.packageName
  });

  //print(response.body);
  if (response.statusCode == 200) {
    Map<String, dynamic> hasil = jsonDecode(response.body);
    if (hasil['status'] == 'success') {
      var trx = hasil['transaksi'];
      if (trx > 0) {
        Get.to(() => TrackingDriverPickup());
      } else {
        Get.to(() => TujuanPerjalananPickup());
      }
    }
  }
}

void cekDuluTransaksiMotor() async {
  final c = Get.find<ApiService>();

  bool conn = await cekInternet();
  if (!conn) {
    return noInternetConnection();
  }
  Box dbbox = Hive.box<String>('sasukaDB');
  var token = dbbox.get('token');
  var pid = dbbox.get('person_id');
  var user = dbbox.get('loginSebagai');

  var datarequest = '{"pid":"$pid"}';
  var bytes = utf8.encode(datarequest + '$token' + user);
  var signature = md5.convert(bytes).toString();

  var url = Uri.parse('${c.baseURLdriver}/mobileAppsUser/cekAdaPerjalananGak');

  final response = await http.post(url, body: {
    "user": user,
    "appid": c.appid,
    "data_request": datarequest,
    "sign": signature,
    "package": c.packageName
  });

  print(response.body);
  if (response.statusCode == 200) {
    Map<String, dynamic> hasil = jsonDecode(response.body);
    if (hasil['status'] == 'success') {
      var trx = hasil['transaksi'];
      if (trx > 0) {
        Get.to(() => TrackingDriverMotor());
      } else {
        Get.to(() => TujuanPerjalananMotor());
      }
    }
  }
}
