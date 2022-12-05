import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import 'cekOut.dart';
import 'header.dart';

class HomeRitzuka extends StatefulWidget {
  @override
  _HomeRitzukaState createState() => _HomeRitzukaState();
}

class _HomeRitzukaState extends State<HomeRitzuka> {
  final c = Get.find<ApiService>();

  @override
  void initState() {
    super.initState();
    daftarRitzuka();
  }

  var myGroup = AutoSizeGroup();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Text(
          'Beli UMP',
        ),
      ),
      body: ListView(
        children: [
          IklanRitzuka(),
          Container(
            margin: EdgeInsets.fromLTRB(6, 6, 6, 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    child: Text(
                      'UMP ${c.namaAplikasi} adalah Pilihan Mitra Bisnis Visioner',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                        color: Warna.grey,
                      ),
                      textAlign: TextAlign.center,
                    )),
                Text(
                    'Ayo kembangkan usahamu dimana saja bersama ${c.namaAplikasi} dengan fitur MyUMP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Warna.grey,
                    )),
                Padding(padding: EdgeInsets.only(top: 15)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: Get.width * 0.3,
                      child: GestureDetector(
                        onTap: () {
                          var imageFitur =
                              'https://sasuka.co.id/assets/images/shop/Hybrid%20Concept.png';
                          var judulFitur = 'Hybrid Concept Terbaik';
                          var detailFitur =
                              'Menggabungkan Bisnis Konvensional & Digital ke dalam Aplikasi Multi-Fungsi';
                          popUpFitur(imageFitur, judulFitur, detailFitur);
                        },
                        child: Column(
                          children: [
                            CachedNetworkImage(
                                width: Get.width * 0.12,
                                height: Get.width * 0.12,
                                imageUrl:
                                    'https://sasuka.co.id/assets/images/shop/Hybrid%20Concept.png',
                                errorWidget: (context, url, error) {
                                  print(error);
                                  return Icon(Icons.error);
                                }),
                            Padding(padding: EdgeInsets.only(top: 8)),
                            Text('Hybrid Concept Terbaik',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Warna.grey,
                                )),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: Get.width * 0.3,
                      child: GestureDetector(
                        onTap: () {
                          var imageFitur =
                              'https://sasuka.co.id/assets/images/shop/Full%20Ritel%20Management.png';
                          var judulFitur = 'Full Bisnis Management';
                          var detailFitur =
                              'Retail Consultant yang Menawarkan Kemudahan Pengelolaan Bisnis Anda';
                          popUpFitur(imageFitur, judulFitur, detailFitur);
                        },
                        child: Column(
                          children: [
                            CachedNetworkImage(
                                width: Get.width * 0.12,
                                height: Get.width * 0.12,
                                imageUrl:
                                    'https://sasuka.co.id/assets/images/shop/Full%20Ritel%20Management.png',
                                errorWidget: (context, url, error) {
                                  print(error);
                                  return Icon(Icons.error);
                                }),
                            Padding(padding: EdgeInsets.only(top: 8)),
                            Text('Full Bisnis Management',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Warna.grey,
                                )),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: Get.width * 0.3,
                      child: GestureDetector(
                        onTap: () {
                          var imageFitur =
                              'https://sasuka.co.id/assets/images/shop/Terintegrasi%20dengan%20App%20SaSuka.png';
                          var judulFitur = 'Terintegrasi SatuAja';
                          var detailFitur =
                              'Menghubungkan Pebisnis dan Konsumen dalam Satu Jaringan Pasar Digital yang Adaptif';
                          popUpFitur(imageFitur, judulFitur, detailFitur);
                        },
                        child: Column(
                          children: [
                            CachedNetworkImage(
                                width: Get.width * 0.12,
                                height: Get.width * 0.12,
                                imageUrl:
                                    'https://sasuka.co.id/assets/images/shop/Terintegrasi%20dengan%20App%20SaSuka.png',
                                errorWidget: (context, url, error) {
                                  print(error);
                                  return Icon(Icons.error);
                                }),
                            Padding(padding: EdgeInsets.only(top: 8)),
                            Text('Terintegrasi SatuAja',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Warna.grey,
                                )),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Padding(padding: EdgeInsets.only(top: 22)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: Get.width * 0.3,
                      child: GestureDetector(
                        onTap: () {
                          var imageFitur =
                              'https://sasuka.co.id/assets/images/shop/Ekosistem%20Pasar%20Digital.png';
                          var judulFitur = 'Ekosistem Pasar Digital';
                          var detailFitur =
                              'Terkoneksi dengan Pengguna Aplikasi SaSuka dan ${c.namaAplikasi} yang Terus Berkembang di Seluruh Indonesia';
                          popUpFitur(imageFitur, judulFitur, detailFitur);
                        },
                        child: Column(
                          children: [
                            CachedNetworkImage(
                                width: Get.width * 0.12,
                                height: Get.width * 0.12,
                                imageUrl:
                                    'https://sasuka.co.id/assets/images/shop/Ekosistem%20Pasar%20Digital.png',
                                errorWidget: (context, url, error) {
                                  print(error);
                                  return Icon(Icons.error);
                                }),
                            Padding(padding: EdgeInsets.only(top: 8)),
                            Text('Ekosistem Pasar Digital',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Warna.grey,
                                )),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: Get.width * 0.3,
                      child: GestureDetector(
                        onTap: () {
                          var imageFitur =
                              'https://sasuka.co.id/assets/images/shop/Sharing%20Profit.png';
                          var judulFitur = 'Banyak CashBack Realtime';
                          var detailFitur =
                              'Prospek yang Cemerlang untuk Mendapatkan Keuntungan Tanpa Batas Secara Real-Time';
                          popUpFitur(imageFitur, judulFitur, detailFitur);
                        },
                        child: Column(
                          children: [
                            CachedNetworkImage(
                                width: Get.width * 0.12,
                                height: Get.width * 0.12,
                                imageUrl:
                                    'https://sasuka.co.id/assets/images/shop/Sharing%20Profit.png',
                                errorWidget: (context, url, error) {
                                  print(error);
                                  return Icon(Icons.error);
                                }),
                            Padding(padding: EdgeInsets.only(top: 8)),
                            Text('Banyak CashBack Realtime',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Warna.grey,
                                )),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: Get.width * 0.3,
                      child: GestureDetector(
                        onTap: () {
                          var imageFitur =
                              'https://sasuka.co.id/assets/images/shop/Murah%20dan%20Terjangkau.png';
                          var judulFitur = 'Murah dan Terjangkau';
                          var detailFitur =
                              'Mengutamakan Kemudahan untuk Dapat Membangun Bisnis Ritel Secara Berkelanjutan';
                          popUpFitur(imageFitur, judulFitur, detailFitur);
                        },
                        child: Column(
                          children: [
                            CachedNetworkImage(
                                width: Get.width * 0.12,
                                height: Get.width * 0.12,
                                imageUrl:
                                    'https://sasuka.co.id/assets/images/shop/Murah%20dan%20Terjangkau.png',
                                errorWidget: (context, url, error) {
                                  print(error);
                                  return Icon(Icons.error);
                                }),
                            Padding(padding: EdgeInsets.only(top: 8)),
                            Text('Murah dan Terjangkau',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Warna.grey,
                                )),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Padding(padding: EdgeInsets.only(top: 22)),
                Container(
                    margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    child: Text('Pilih UMP-mu sekarang !',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Warna.grey,
                        ))),
                (dataRitzuka.length > 0) ? buatdataRitzuka() : Container()
              ],
            ),
          )
        ],
      ),
    );
  }

  popUpFitur(String imageFitur, String judulFitur, String detailFitur) {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          CachedNetworkImage(
              width: Get.width * 0.3,
              height: Get.width * 0.3,
              imageUrl: imageFitur,
              errorWidget: (context, url, error) {
                print(error);
                return Icon(Icons.error);
              }),
          Text(judulFitur,
              style: TextStyle(
                  fontSize: 24,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w200)),
          Padding(padding: EdgeInsets.only(top: 11)),
          Text(detailFitur,
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center),
          Padding(padding: EdgeInsets.only(top: 9)),
          Divider(),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(Icons.highlight_off, color: Colors.grey)),
              Text(
                'Tutup',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    )..show();
  }

  daftarRitzuka() async {
    bool conn = await cekInternet();
    if (conn) {
      Box dbbox = Hive.box<String>('sasukaDB');
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');

      var datarequest = '{"pid":"$pid"}';
      var bytes = utf8.encode(datarequest + '$token');
      var signature = md5.convert(bytes).toString();
      var user = dbbox.get('loginSebagai');

      var url = Uri.parse('${c.baseURL}/sasuka/dataRitzuka');

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
          if (mounted) {
            dataRitzuka = hasil['data'];
            setState(() {});
          }
        } else if (hasil['status'] == 'no data') {}
      }
    }
  }

  List dataRitzuka = [];
  List<Container> ritzukaContainer = [];
  buatdataRitzuka() {
    for (var a = 0; a < dataRitzuka.length; a++) {
      var data = dataRitzuka[a];

      ritzukaContainer.add(Container(
        child: Card(
          elevation: 0.0,
          child: Container(
            margin: EdgeInsets.all(5),
            child: Column(
              children: [
                Row(
                  children: [
                    CachedNetworkImage(
                        width: Get.width * 0.3,
                        height: Get.width * 0.3,
                        imageUrl: data[1], // foto
                        errorWidget: (context, url, error) {
                          print(error);
                          return Icon(Icons.error);
                        }),
                    Padding(padding: EdgeInsets.only(left: 22)),
                    SizedBox(
                      width: Get.width * 0.55,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            data[2], // nama
                            style: TextStyle(
                              fontSize: 18,
                              color: Warna.grey,
                            ),
                            maxLines: 2,
                          ),
                          Text(data[3], // alamat
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: Warna.grey,
                              )),
                          AutoSizeText(
                            data[4], // foto,
                            style: TextStyle(
                              fontSize: 24,
                              color: Warna.grey,
                            ),
                            maxLines: 1,
                          ),
                          AutoSizeText(
                            'Harga unit modal penyertaan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              color: Warna.grey,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: Get.width * 0.23,
                      child: RawMaterialButton(
                        onPressed: () {},
                        constraints: BoxConstraints(),
                        elevation: 0.0,
                        fillColor: Colors.grey,
                        child: AutoSizeText(data[5], // progrea
                            group: myGroup,
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center),
                        padding: EdgeInsets.fromLTRB(2, 4, 2, 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9)),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(left: 5)),
                    SizedBox(
                      width: Get.width * 0.18,
                      child: RawMaterialButton(
                        onPressed: () {},
                        constraints: BoxConstraints(),
                        elevation: 0.0,
                        fillColor: Colors.grey,
                        child: AutoSizeText(data[6], // umpmasuk
                            group: myGroup,
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center),
                        padding: EdgeInsets.fromLTRB(2, 4, 2, 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9)),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(left: 5)),
                    SizedBox(
                      width: Get.width * 0.12,
                      child: RawMaterialButton(
                        onPressed: () {},
                        constraints: BoxConstraints(),
                        elevation: 0.0,
                        fillColor: Colors.grey,
                        child: AutoSizeText(data[7], // sisa hari
                            group: myGroup,
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center),
                        padding: EdgeInsets.fromLTRB(2, 4, 2, 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9)),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(left: 5)),
                    SizedBox(
                      width: Get.width * 0.23,
                      child: RawMaterialButton(
                        onPressed: () {
                          c.idCekOutRitzuka.value = data[0];

                          c.fotoCekOutRitzuka.value = data[1];
                          c.namaCekOutRitzuka.value = data[2];
                          c.alamatCekOutRitzuka.value = data[3];
                          c.hargaDevCekOutRitzuka.value = data[8];
                          c.persenCekOutRitzuka.value = data[5];
                          c.satuanCekOutRitzuka.value = data[4];
                          c.umpmasukCekOutRitzuka.value = data[6];
                          c.tahapanCekOutRitzuka.value = data[9];
                          c.maxCekOutRitzuka.value = data[10];
                          c.hargaIntCekOutRitzuka.value = data[11];
                          c.totalBayarCekoutRitzuka.value = data[11];
                          Get.to(() => CekOutRitzuka());
                        },
                        constraints: BoxConstraints(),
                        elevation: 1.0,
                        fillColor: Colors.green,
                        child: AutoSizeText('Detail', //unit
                            group: myGroup,
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center),
                        padding: EdgeInsets.fromLTRB(2, 4, 2, 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9)),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ));
    }
    return Column(
      children: ritzukaContainer,
    );
  }
}
