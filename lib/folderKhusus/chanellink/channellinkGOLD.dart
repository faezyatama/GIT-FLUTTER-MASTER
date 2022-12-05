import 'dart:convert';

// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../base/notifikasiBuatAkun.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'chanellinkPLAT.dart';
import 'chanellinkREG.dart';
import 'channellinkINV.dart';
import 'channellinkSIL.dart';

class ChannellinkGOLD extends StatefulWidget {
  @override
  _ChannellinkGOLDState createState() => _ChannellinkGOLDState();
}

class _ChannellinkGOLDState extends State<ChannellinkGOLD> {
  final c = Get.find<ApiService>();
  final controllerPin = TextEditingController();
  String cl = 'GOLD';
  var grade = 3;
  String harga = 'Rp.2.500.000,-';
  String gambar = 'images/GOLD.png';
  String judul = 'Chanellink Gold';
  String subJudul =
      'Channellink Adalah program koperasi yang ditujukan untuk anggota yang membeli Paket Kemitraan Exclusive dan berhak mendapatkan imbal jasa dari koperasi';
  String deskripsi =
      'Dengan membeli paket channellink kamu bisa mendapatkan imbal jasa dan SHU loh, SHU adalah sisa hasil usaha yang bisa kamu dapatkan dari keuntungan Koperasi. Tingkatkan transaksi di Aplikasi ini untuk dapatkan SHU yang lebih besar';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Channellink'),
        backgroundColor: Colors.red[900],
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(left: 25, right: 25),
            child: ListView(
              children: [
                Container(
                  padding: EdgeInsets.only(right: Get.width * 0.26),
                  child: SizedBox(
                    width: Get.width * 0.6,
                    height: Get.width * 0.6,
                    child: new Hero(
                        tag: 'GOLD',
                        child: new Material(
                            child: new InkWell(
                          child: ElasticInLeft(
                              child: Image.asset(
                            gambar,
                          )),
                        ))),
                  ),
                ),
                Text(
                  judul,
                  style: TextStyle(fontSize: 29, color: Warna.grey),
                ),
                Padding(padding: EdgeInsets.only(top: 12)),
                Text(
                  subJudul,
                  style: TextStyle(fontSize: 18, color: Warna.grey),
                ),
                Padding(padding: EdgeInsets.only(top: 12)),
                ((c.cl.value < grade) || (c.cl.value == 10))
                    ? RawMaterialButton(
                        onPressed: () {
                          if (c.loginAsPenggunaKita.value == 'Member') {
                            konfirmasiDanPin();
                          } else {
                            var judulF = 'Fitur Premium';
                            var subJudul =
                                'Fitur premium ini hanya ditujukan bagi anggota koperasi, Yuk Buka akun koperasi di aplikasi ${c.namaAplikasi} sekarang';

                            bukaLoginPage(judulF, subJudul);
                          }
                        },
                        constraints: BoxConstraints(),
                        elevation: 1.0,
                        fillColor: Warna.warnautama,
                        child: Text(
                          'Beli Paket Kemitraan $judul',
                          style: TextStyle(color: Warna.putih),
                        ),
                        padding: EdgeInsets.all(4.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9)),
                        ),
                      )
                    : Padding(padding: EdgeInsets.only(top: 45)),
                Text(
                  deskripsi,
                  style: TextStyle(fontSize: 12, color: Warna.grey),
                ),
                Padding(padding: EdgeInsets.only(top: 12)),
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FadeInDown(
                          child: GestureDetector(
                            onTap: () {
                              Get.off(ChannellinkREG());
                            },
                            child: Card(
                                child: Container(
                              width: 100,
                              padding: EdgeInsets.all(9),
                              child: Column(
                                children: [
                                  Container(
                                    child: new Hero(
                                        tag: 'REGULER',
                                        child: new Material(
                                            child: new InkWell(
                                          child: Image.asset(
                                            'images/REGULER.png',
                                            width: 100,
                                          ),
                                        ))),
                                  ),
                                  Text(
                                    'Reguler',
                                    style: TextStyle(color: Warna.grey),
                                  )
                                ],
                              ),
                            )),
                          ),
                        ),
                        FadeInDown(
                          child: GestureDetector(
                            onTap: () {
                              Get.off(ChannellinkSIL());
                            },
                            child: Card(
                                child: Container(
                              width: 100,
                              padding: EdgeInsets.all(9),
                              child: Column(
                                children: [
                                  Container(
                                    child: new Hero(
                                        tag: 'SILVER',
                                        child: new Material(
                                            child: new InkWell(
                                          child: Image.asset(
                                            'images/SILVER.png',
                                            width: 100,
                                          ),
                                        ))),
                                  ),
                                  Text(
                                    'Silver',
                                    style: TextStyle(color: Warna.grey),
                                  )
                                ],
                              ),
                            )),
                          ),
                        ),
                        FadeInDown(
                          child: GestureDetector(
                            onTap: () {
                              // Get.off(ChanellinkGOLD());
                            },
                            child: Card(
                                child: Container(
                              width: 100,
                              padding: EdgeInsets.all(9),
                              child: Column(
                                children: [
                                  Container(
                                    child: new Hero(
                                        tag: 'xGOLD',
                                        child: new Material(
                                            child: new InkWell(
                                          child: Image.asset(
                                            'images/GOLD.png',
                                            width: 100,
                                          ),
                                        ))),
                                  ),
                                  Text(
                                    'Gold',
                                    style: TextStyle(color: Warna.grey),
                                  )
                                ],
                              ),
                            )),
                          ),
                        ),
                        FadeInDown(
                          child: GestureDetector(
                            onTap: () {
                              Get.off(ChannellinkPLAT());
                            },
                            child: Card(
                                child: Container(
                              width: 100,
                              padding: EdgeInsets.all(9),
                              child: Column(
                                children: [
                                  Container(
                                    child: new Hero(
                                        tag: 'PLATINUM',
                                        child: new Material(
                                            child: new InkWell(
                                          child: Image.asset(
                                            'images/PLATINUM.png',
                                            width: 100,
                                          ),
                                        ))),
                                  ),
                                  Text(
                                    'Platinum',
                                    style: TextStyle(color: Warna.grey),
                                  )
                                ],
                              ),
                            )),
                          ),
                        ),
                        FadeInDown(
                          child: GestureDetector(
                            onTap: () {
                              Get.off(ChannellinkINV());
                            },
                            child: Card(
                                child: Container(
                              width: 100,
                              padding: EdgeInsets.all(9),
                              child: Column(
                                children: [
                                  Container(
                                    child: new Hero(
                                        tag: 'INVINITY',
                                        child: new Material(
                                            child: new InkWell(
                                          child: Image.asset(
                                            'images/INVINITY.png',
                                            width: 100,
                                          ),
                                        ))),
                                  ),
                                  Text(
                                    'Invinity',
                                    style: TextStyle(color: Warna.grey),
                                  )
                                ],
                              ),
                            )),
                          ),
                        )
                      ],
                    )),
              ],
            ),
          ),
          FadeInDownBig(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  'images/3.png',
                  width: Get.width * 0.4,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void konfirmasiDanPin() {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Container(
            width: Get.width * 0.35,
            height: Get.width * 0.35,
            child: Image.asset(gambar),
          ),
          Text(
            judul,
            style: TextStyle(
                fontSize: 19, color: Warna.grey, fontWeight: FontWeight.w600),
          ),
          Text(
            harga,
            style: TextStyle(
                fontSize: 18, color: Warna.grey, fontWeight: FontWeight.w600),
          ),
          Padding(padding: EdgeInsets.only(top: 33)),
          Text('PIN DIBUTUHKAN',
              style: TextStyle(
                  fontSize: 18,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w600)),
          Padding(padding: EdgeInsets.only(top: 7)),
          Container(
            padding: EdgeInsets.only(left: 7, right: 7),
            child: Text(
              'Kamu akan membeli $judul, Bila sudah sesuai silahkan masukan PIN untuk melakukan transaksi ini',
              textAlign: TextAlign.center,
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 7)),
          Container(
            width: Get.width * 0.7,
            child: TextField(
              obscureText: true,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: TextStyle(
                  fontSize: 25, fontWeight: FontWeight.w600, color: Warna.grey),
              controller: controllerPin,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.vpn_key),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          RawMaterialButton(
            constraints: BoxConstraints(minWidth: Get.width * 0.7),
            elevation: 1.0,
            fillColor: Warna.warnautama,
            child: Text(
              'Beli $judul',
              style: TextStyle(color: Warna.putih, fontSize: 14),
            ),
            padding: EdgeInsets.fromLTRB(18, 9, 18, 9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            onPressed: () {
              if ((controllerPin.text == '') ||
                  (controllerPin.text.length != 6)) {
                controllerPin.text = '';
                Get.back();
                AwesomeDialog(
                  context: Get.context,
                  dialogType: DialogType.noHeader,
                  animType: AnimType.rightSlide,
                  title: 'PERHATIAN !',
                  desc:
                      'Pin tidak dimasukan dengan benar, Pin hanya berisi 6 angka',
                  btnCancelText: 'OK',
                  btnCancelColor: Colors.amber,
                  btnCancelOnPress: () {},
                )..show();
              } else {
                prosesBeliCL();
              }
            },
          ),
        ],
      ),
    )..show();
  }

  void prosesBeliCL() async {
    EasyLoading.show(status: 'Mohon tunggu transaksi...', dismissOnTap: false);
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var pin = controllerPin.text;
    var datarequest = '{"pid":"$pid", "cl":"$cl", "pin":"$pin"}';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse('${c.baseURL}/sasuka/beliCl');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    EasyLoading.dismiss();
    controllerPin.text = '';

    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        c.clLogo.value = hasil['cl'];
        c.cl.value = hasil['grade'];
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'TRANSAKSI BERHASIL !',
          desc: 'Terima kasih telah mengaktifkan Chanellink',
          btnOkText: 'OK',
          btnOkOnPress: () {
            Get.back();
          },
        )..show();
      } else {
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'PERHATIAN !',
          desc: hasil['message'],
          btnCancelText: 'OK',
          btnCancelOnPress: () {
            Get.back();
          },
        )..show();
      }
    } else {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'PERHATIAN !',
        desc: 'Connection error.. Please check your connection',
        btnCancelText: 'OK',
        btnCancelOnPress: () {
          Get.back();
        },
      )..show();
    }
  }
}
