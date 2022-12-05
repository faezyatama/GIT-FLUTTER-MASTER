import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import 'ppob-inquiry.dart';
import 'ppob-view.dart';

class PembayaranPPOB extends StatefulWidget {
  @override
  _PembayaranPPOBState createState() => _PembayaranPPOBState();
}

class _PembayaranPPOBState extends State<PembayaranPPOB> {
  // simple usage
  final c = Get.find<ApiService>();
  //SETTINGAN
  var produkPpob = false;
  var detailBayar = false;

  final controllerHp = TextEditingController();

  //SETTINGAN END

  String pdam = 'images/logoppob/pdam.png';
  String pln = 'images/logoppob/pln.png';
  String handphone = 'images/logoppob/handphone.png';
  String internet = 'images/logoppob/internet.png';
  String bpjs = 'images/logoppob/bpjs.png';
  String finance = 'images/logoppob/finance.png';
  String tvberbayar = 'images/logoppob/tv.png';
  String pbb = 'images/logoppob/pbb.png';
  String samsat = 'images/logoppob/samsat.png';

  double lebar = Get.width * 0.27;
  double lebargambar = Get.width * 0.15;
  double paddingd = 3;
  double fontsis = 11;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pembayaran / PPOB'),
        backgroundColor: Warna.warnautama,
      ),
      body: Container(
        child: ListView(
          children: [
            // Image.asset(
            //   'images/tagihan.jpg',
            // ),
            Padding(padding: EdgeInsets.only(top: 22)),
            Text(
              'Payment Point ${c.namaAplikasi}',
              style: TextStyle(
                fontSize: 25,
                color: Warna.warnautama,
              ),
              textAlign: TextAlign.center,
            ),
            Container(
              padding: EdgeInsets.all(15),
              child: Text(
                'Kemudahan membayar berbagai tagihan bulanan melalui aplikasi ${c.namaAplikasi}',
                style: TextStyle(
                  fontSize: 16,
                  color: Warna.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 22)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: lebar,
                  child: Column(
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white, // background
                            onPrimary: Colors.grey, // foreground
                          ),
                          onPressed: () {
                            setState(() {
                              c.kategoriPPOB.value = 'PDAM';
                              c.logoPPOB.value = 'images/logoppob/pdam.png';
                            });
                            Get.to(() => PpobOperator());
                          },
                          child: Container(
                            padding: EdgeInsets.all(paddingd),
                            child: Column(
                              children: [
                                Image.asset(
                                  pdam,
                                  width: lebargambar,
                                ),
                                Padding(padding: EdgeInsets.only(top: 7)),
                                Text(
                                  "PDAM",
                                  style: TextStyle(fontSize: fontsis),
                                )
                              ],
                            ),
                          ))
                    ],
                  ),
                ),
                Container(
                  width: lebar,
                  child: Column(
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white, // background
                            onPrimary: Colors.grey, // foreground
                          ),
                          onPressed: () {
                            setState(() {
                              c.kategoriPPOB.value = 'PLN PASCABAYAR';
                              c.subProduk.value = 'PLN PASCABAYAR';
                              c.logoPPOB.value = 'images/logoppob/pln.png';
                              c.logosubproduk.value =
                                  'https://sasuka.online/icon/PLNpasca.png';
                            });
                            Get.to(() => PpobInquiry());
                          },
                          child: Container(
                            padding: EdgeInsets.all(paddingd),
                            child: Column(
                              children: [
                                Image.asset(
                                  pln,
                                  width: lebargambar,
                                ),
                                Padding(padding: EdgeInsets.only(top: 7)),
                                Text(
                                  "PLN",
                                  style: TextStyle(fontSize: fontsis),
                                )
                              ],
                            ),
                          ))
                    ],
                  ),
                ),
                Container(
                  width: lebar,
                  child: Column(
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white, // background
                            onPrimary: Colors.grey, // foreground
                          ),
                          onPressed: () {
                            setState(() {
                              c.kategoriPPOB.value = 'HP PASCABAYAR';
                              c.logoPPOB.value =
                                  'images/logoppob/handphone.png';
                            });
                            Get.to(() => PpobOperator());
                          },
                          child: Container(
                            padding: EdgeInsets.all(paddingd),
                            child: Column(
                              children: [
                                Image.asset(
                                  handphone,
                                  width: lebargambar,
                                ),
                                Padding(padding: EdgeInsets.only(top: 7)),
                                Text(
                                  "HP PASCA",
                                  style: TextStyle(fontSize: fontsis),
                                )
                              ],
                            ),
                          ))
                    ],
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: lebar,
                  child: Column(
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white, // background
                            onPrimary: Colors.grey, // foreground
                          ),
                          onPressed: () {
                            setState(() {
                              c.kategoriPPOB.value = 'INTERNET PASCABAYAR';
                              c.logoPPOB.value = 'images/logoppob/internet.png';
                            });
                            Get.to(() => PpobOperator());
                          },
                          child: Container(
                            padding: EdgeInsets.all(paddingd),
                            child: Column(
                              children: [
                                Image.asset(internet, width: lebargambar),
                                Padding(padding: EdgeInsets.only(top: 7)),
                                Text(
                                  "INTERNET",
                                  style: TextStyle(fontSize: fontsis),
                                )
                              ],
                            ),
                          ))
                    ],
                  ),
                ),
                Container(
                  width: lebar,
                  child: Column(
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white, // background
                            onPrimary: Colors.grey, // foreground
                          ),
                          onPressed: () {
                            setState(() {
                              c.kategoriPPOB.value = 'BPJS KESEHATAN';
                              c.subProduk.value = 'BPJS KESEHATAN';
                              c.logoPPOB.value = 'images/logoppob/bpjs.png';
                              c.logosubproduk.value =
                                  'https://sasuka.online/icon/BPJS.png';
                            });
                            Get.to(() => PpobInquiry());
                          },
                          child: Container(
                            padding: EdgeInsets.all(paddingd),
                            child: Column(
                              children: [
                                Image.asset(
                                  bpjs,
                                  width: lebargambar,
                                ),
                                Padding(padding: EdgeInsets.only(top: 7)),
                                Text(
                                  "BPJS",
                                  style: TextStyle(fontSize: fontsis),
                                )
                              ],
                            ),
                          ))
                    ],
                  ),
                ),
                Container(
                  width: lebar,
                  child: Column(
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white, // background
                            onPrimary: Colors.grey, // foreground
                          ),
                          onPressed: () {
                            setState(() {
                              c.kategoriPPOB.value = 'MULTIFINANCE';
                              c.logoPPOB.value = 'images/logoppob/finance.png';
                            });
                            Get.to(() => PpobOperator());
                          },
                          child: Container(
                            padding: EdgeInsets.all(paddingd),
                            child: Column(
                              children: [
                                Image.asset(finance, width: lebargambar),
                                Padding(padding: EdgeInsets.only(top: 7)),
                                Text(
                                  "FINANCE",
                                  style: TextStyle(fontSize: fontsis),
                                )
                              ],
                            ),
                          ))
                    ],
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 22)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: lebar,
                  child: Column(
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white, // background
                            onPrimary: Colors.grey, // foreground
                          ),
                          onPressed: () {
                            setState(() {
                              c.kategoriPPOB.value = 'PBB';
                              c.logoPPOB.value = 'images/logoppob/internet.png';
                            });
                            Get.to(() => PpobOperator());
                          },
                          child: Container(
                            padding: EdgeInsets.all(paddingd),
                            child: Column(
                              children: [
                                Image.asset(pbb, width: lebargambar),
                                Padding(padding: EdgeInsets.only(top: 7)),
                                Text(
                                  "PBB",
                                  style: TextStyle(fontSize: fontsis),
                                )
                              ],
                            ),
                          ))
                    ],
                  ),
                ),
                Container(
                  width: lebar,
                  child: Column(
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white, // background
                            onPrimary: Colors.grey, // foreground
                          ),
                          onPressed: () {
                            setState(() {
                              c.kategoriPPOB.value = 'TV PASCABAYAR';
                              c.logoPPOB.value = 'images/logoppob/tv.png';
                            });
                            Get.to(() => PpobOperator());
                          },
                          child: Container(
                            padding: EdgeInsets.all(paddingd),
                            child: Column(
                              children: [
                                Image.asset(
                                  tvberbayar,
                                  width: lebargambar,
                                ),
                                Padding(padding: EdgeInsets.only(top: 7)),
                                Text(
                                  "TV",
                                  style: TextStyle(fontSize: fontsis),
                                )
                              ],
                            ),
                          ))
                    ],
                  ),
                ),
                Container(
                  width: lebar,
                  child: Column(
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white, // background
                            onPrimary: Colors.grey, // foreground
                          ),
                          onPressed: () {
                            Get.snackbar('Comming Soon',
                                "Segera hadir pembayaran Samsat Online, bayar pajak kendaraan jadi mudah..",
                                colorText: Colors.black);
                          },
                          child: Container(
                            padding: EdgeInsets.all(paddingd),
                            child: Column(
                              children: [
                                Image.asset(samsat, width: lebargambar),
                                Padding(padding: EdgeInsets.only(top: 7)),
                                Text(
                                  "SAMSAT",
                                  style: TextStyle(fontSize: fontsis),
                                )
                              ],
                            ),
                          ))
                    ],
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 22)),
          ],
        ),
      ),
    );
  }
}
