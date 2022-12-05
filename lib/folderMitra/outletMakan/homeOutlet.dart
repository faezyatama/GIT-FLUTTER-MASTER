import 'dart:convert';
import 'package:badges/badges.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../dashboard/modulDashboard/sliderAtasOk.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import '../../folderUmum/chat/view/homechat.dart';
import 'pesananMakanan.dart';

import 'bukaOutletBaru.dart';
import 'laporanMakanan.dart';
import 'pengaturanOutlet.dart';
import 'produkMakanan.dart';

class DashboardOutlet extends StatefulWidget {
  @override
  _DashboardOutletState createState() => _DashboardOutletState();
}

class _DashboardOutletState extends State<DashboardOutlet> {
  TextStyle styleHuruf1 = TextStyle(
    fontSize: 14,
    color: Warna.grey,
  );
  TextStyle styleHurufBesar = TextStyle(
      fontSize: 20, color: Warna.warnautama, fontWeight: FontWeight.w600);
  TextStyle smallhuruf = TextStyle(
      fontSize: 14, color: Warna.warnautama, fontWeight: FontWeight.w300);
  TextStyle styleHurufkecil = TextStyle(fontSize: 11, color: Warna.grey);

  @override
  void initState() {
    super.initState();
    cekAdaOutletGak();
  }

  final c = Get.find<ApiService>();
  var detailOutlet = [];
  var bukatutup = 'false';
  var showButton = false.obs;
  var dataReady = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Outlet Makananmu'),
            actions: [
              Obx(() => Badge(
                    elevation: 0,
                    position: BadgePosition.bottomEnd(bottom: 15, end: 7),
                    animationDuration: Duration(milliseconds: 300),
                    animationType: BadgeAnimationType.fade,
                    badgeColor: (c.chatIndexBar.value == '')
                        ? Colors.transparent
                        : Colors.red,
                    badgeContent: Text(
                      c.chatIndexBar.value,
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    child: IconButton(
                        onPressed: () {
                          Get.to(() => ChatApp());
                        },
                        icon: Icon(
                          Icons.chat,
                          size: 27,
                        )),
                  )),
            ],
            backgroundColor: Warna.warnautama),
        bottomNavigationBar: Obx(() => Container(
              padding: EdgeInsets.only(
                left: 11,
                right: 11,
              ),
              child: (c.adaOutletMakan.value == 'Ada')
                  ? RawMaterialButton(
                      onPressed: () {
                        if (bukatutup == 'false') {
                          bukaToko('true');
                        } else {
                          bukaToko('false');
                        }
                      },
                      constraints: BoxConstraints(),
                      elevation: 1.0,
                      fillColor: (showButton.value == false)
                          ? Colors.grey
                          : (bukatutup == 'false')
                              ? Colors.grey
                              : Warna.warnautama,
                      child: (bukatutup == 'false')
                          ? Text('Offline / Tutup',
                              style:
                                  TextStyle(color: Warna.putih, fontSize: 16))
                          : Text(
                              'Online / Buka',
                              style:
                                  TextStyle(color: Warna.putih, fontSize: 16),
                            ),
                      padding: EdgeInsets.fromLTRB(22, 11, 22, 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                      ),
                    )
                  : (dataReady == true)
                      ? RawMaterialButton(
                          onPressed: () {
                            Get.to(() => BuatOutletBaru());
                          },
                          constraints: BoxConstraints(),
                          elevation: 1.0,
                          fillColor: Warna.warnautama,
                          child: Text(
                            'Buka Outlet Sekarang !',
                            style: TextStyle(color: Warna.putih, fontSize: 16),
                          ),
                          padding: EdgeInsets.fromLTRB(22, 11, 22, 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(9)),
                          ),
                        )
                      : Text(
                          'Membuka Data... !',
                          style: TextStyle(color: Warna.grey, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
            )),
        body: Obx(() => Container(
              child: (c.adaOutletMakan.value == 'Ada')
                  ? Column(
                      children: [
                        IklanAtas(),
                        //IklanAtasMK(),
                        Center(
                          child: Column(
                            children: [
                              Obx(() => Text(
                                    c.namaOutletMakan.value,
                                    style: styleHurufBesar,
                                    textAlign: TextAlign.center,
                                  )),
                              Obx(() => Text(
                                    c.alamatOutletMakan.value,
                                    style: styleHuruf1,
                                    textAlign: TextAlign.center,
                                  )),
                              Obx(() => Text(
                                    c.kabupatenMakan.value,
                                    style: styleHuruf1,
                                    textAlign: TextAlign.center,
                                  )),
                            ],
                          ),
                        ),
                        Divider(),
                        Center(
                          child: Obx(() => Text(
                                c.deskripsiMakan.value,
                                style: styleHuruf1,
                                textAlign: TextAlign.center,
                              )),
                        ),
                        Container(
                          margin: EdgeInsets.all(22),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.pets,
                                    color: Warna.warnautama,
                                    size: 22.0,
                                  ),
                                  Obx(() => Text(
                                        c.kunjunganMakan.value,
                                        style: smallhuruf,
                                      )),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.stars,
                                    color: Warna.warnautama,
                                    size: 22.0,
                                  ),
                                  Obx(() => Text(
                                        c.terjualMakan.value,
                                        style: smallhuruf,
                                      )),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.loyalty,
                                    color: Warna.warnautama,
                                    size: 22.0,
                                  ),
                                  Obx(() => Text(
                                        c.produkMakan.value,
                                        style: smallhuruf,
                                      )),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 22)),
                        Container(
                          margin: EdgeInsets.all(22),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => ProdukMakanan());
                                },
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'images/iconmitra/produkMK.png',
                                      width: 55,
                                    ),
                                    Text(
                                      'Produk',
                                      style: styleHurufkecil,
                                    )
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  c.selectedIndexOrderMakanan.value = 0;
                                  Get.to(() => PesananMakanan());
                                },
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'images/iconmitra/orderMK.png',
                                      width: 55,
                                    ),
                                    Text(
                                      'Order Online',
                                      style: styleHurufkecil,
                                    )
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.snackbar('Comming soon',
                                      'Fitur ini akan segera hadir');
                                },
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'images/iconmitra/OrderOffline.png',
                                      width: 55,
                                    ),
                                    Text(
                                      'Order Offline',
                                      style: styleHurufkecil,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(22),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => LaporanMakanan());
                                },
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'images/iconmitra/Laporan.png',
                                      width: 55,
                                    ),
                                    Text(
                                      'Laporan',
                                      style: styleHurufkecil,
                                    )
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => ChatApp());
                                },
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'images/iconmitra/chatmitra.png',
                                      width: 55,
                                    ),
                                    Text(
                                      'Chat',
                                      style: styleHurufkecil,
                                    )
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => PengaturanOutlet());
                                },
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'images/iconmitra/editmitra.png',
                                      width: 55,
                                    ),
                                    Text(
                                      'Pengaturan',
                                      style: styleHurufkecil,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : (dataReady == true)
                      ? Container(
                          padding: EdgeInsets.all(28),
                          child: Center(
                            child: Column(
                              children: [
                                Image.asset(
                                  'images/nofood.png',
                                  width: Get.width * 0.6,
                                ),
                                Text(
                                  'Sepertinya kamu belum memiliki Outlet Makanan',
                                  style: styleHurufBesar,
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  'Mudah loh berjualan Makanan di ${c.namaAplikasi}, Cukup ikuti beberapa langkah mudah dan Warung Online kamu akan segera aktif',
                                  style: styleHuruf1,
                                  textAlign: TextAlign.center,
                                ),
                                Padding(padding: EdgeInsets.only(top: 22)),
                                Text(
                                  'Ayo jadikan Toko kamu bisa melayani Online dan Offline dalam Satu Aplikasi',
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w200,
                                      color: Warna.warnautama),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(),
            )));
  }

  void cekAdaOutletGak() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLmakan}/mobileAppsOutlet/punyaOutletTidak');

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
        if (hasil['outlet'] == 'Ada') {
          setState(() {
            dataReady = true;
            c.adaOutletMakan.value = hasil['outlet'];
            detailOutlet = hasil['detailOutlet'];

            c.namaOutletMakan.value = detailOutlet[0];
            c.alamatOutletMakan.value = detailOutlet[1];
            c.kabupatenMakan.value = detailOutlet[2];
            c.deskripsiMakan.value = detailOutlet[3];
            c.kunjunganMakan.value = detailOutlet[4];
            c.terjualMakan.value = detailOutlet[5];
            c.produkMakan.value = detailOutlet[6];
            bukatutup = detailOutlet[7];
            showButton.value = true;
          });
        } else {
          setState(() {
            dataReady = true;
            c.adaOutletMakan.value = hasil['outlet'];
          });
        }
      }
    }
  }

  void bukaToko(String s) async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","bukatutup":"$s"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLmakan}/mobileAppsOutlet/bukaTutup');

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
        showButton.value = true;
        setState(() {
          if (hasil['message'] == 'true') {
            bukatutup = 'true';
          } else {
            bukatutup = 'false';
          }
        });
      }
    }
  }
}
