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
// ignore: import_of_legacy_library_into_null_safe
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:http/http.dart' as http;

class PulsaReguler extends StatefulWidget {
  @override
  _PulsaRegulerState createState() => _PulsaRegulerState();
}

class _PulsaRegulerState extends State<PulsaReguler> {
  @override
  void initState() {
    super.initState();
    c.kodepulsa.value = '';
    c.operatorpilihan.value = '';
  }

  final controllerHp = TextEditingController();
  final controllerPin = TextEditingController();

  final c = Get.find<ApiService>();

  var namacontactdipilih = ''.obs;
  var nocontact = ''.obs;

  var war1 = Colors.white;
  var war2 = Colors.white;
  var war3 = Colors.white;
  var war4 = Colors.white;
  var war5 = Colors.white;
  var war6 = Colors.white;
  var war7 = Colors.white;

  void alloffwarna() {
    war1 = Colors.white;
    war2 = Colors.white;
    war3 = Colors.white;
    war4 = Colors.white;
    war5 = Colors.white;
    war6 = Colors.white;
    war7 = Colors.white;
  }

  var tinggi = 0.32;
  cekPulsaTersedia() async {
    //LOAD DATA TOPUP
    setState(() {
      dataHistory = [];
    });

    EasyLoading.show(status: 'Cek Pulsa...');

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var operator = c.operatorpilihan.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","operator":"$operator","jenis":"Pulsa"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/cekpulsatersedia');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        setState(() {
          dataHistory = hasil['data'];
          listdaftar();
        });
      }
    }
    //END LOAD DATA TOP UP
  }

  List dataHistory = [];
  listdaftar() {
    List<Container> listbank = [];
    if (dataHistory.length > 0) {
      for (var i = 0; i < dataHistory.length; i++) {
        var valHistory = dataHistory[i];

        listbank.add(
          Container(
              padding: EdgeInsets.only(left: 11, right: 11, bottom: 11),
              child: SizedBox(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white, // background
                    onPrimary: Colors.grey, // foreground
                  ),
                  onPressed: () {
                    //TAMU OR MEMBER
                    if (c.loginAsPenggunaKita.value == 'Member') {
                      if (controllerHp.text == '') {
                        AwesomeDialog(
                          context: Get.context,
                          dialogType: DialogType.noHeader,
                          animType: AnimType.rightSlide,
                          title: 'Nomor Tujuan Belum Diisi',
                          desc:
                              'Opps... sepertinya nomor tujuan pengisian pulsa belum kamu masukan',
                          btnCancelText: 'Ok',
                          btnCancelColor: Colors.amber,
                          btnCancelOnPress: () {},
                        )..show();
                      } else {
                        c.kodepulsa.value = valHistory[5];
                        c.detailpulsa.value = valHistory[3];
                        prosesPengisianPulsa();
                      }
                    } else {
                      var judulF = 'Akun ${c.namaAplikasi} Dibutuhkan ?';
                      var subJudul =
                          'Yuk Buka akun ${c.namaAplikasi} sekarang, hanya beberapa langkah akun kamu sudah aktif loh...';
                      bukaLoginPage(judulF, subJudul);
                    }
                    //END TAMU OR MEMBER
                  },
                  child: Container(
                    margin: EdgeInsets.all(5),
                    child: Container(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            valHistory[1],
                            width: Get.width * 0.2,
                          ),
                          Container(
                            width: Get.width * 0.45,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  valHistory[4],
                                  style: TextStyle(
                                      fontSize: 12, color: Warna.grey),
                                ),
                                Text(
                                  valHistory[2],
                                  style: TextStyle(
                                      fontSize: 20, color: Warna.grey),
                                ),
                                Padding(padding: EdgeInsets.only(top: 4)),
                                Text(
                                  valHistory[3],
                                  maxLines: 4,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
        );
      }
    } else {
      listbank.add(
        Container(
          padding: EdgeInsets.only(top: 55),
          child: Column(children: [
            Image.asset('images/nodata.png', width: Get.width * 0.45),
            Container(
              padding: EdgeInsets.only(left: 44, right: 44, bottom: 120),
              child: Text(
                'Pilih operator untuk melihat nominal pulsa yang tersedia',
                style: TextStyle(fontSize: 18, color: Warna.grey),
                textAlign: TextAlign.center,
              ),
            )
          ]),
        ),
      );
    }
    return Column(
      children: listbank,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(c.pulsadetail.value),
          backgroundColor: Warna.warnautama,
        ),
        body: ListView(
          children: [
            Container(
              // padding: EdgeInsets.only(left: 22, right: 22),
              child: Column(
                children: [
                  Padding(padding: EdgeInsets.only(top: 22)),
                  Text('Masukan Nomor HP pelanggan :',
                      style: TextStyle(color: Warna.grey, fontSize: 16)),
                  Container(
                    margin: EdgeInsets.fromLTRB(25, 8, 25, 0),
                    child: TextField(
                      onChanged: (text) {
                        if (controllerHp.text != nocontact.value) {
                          setState(() {
                            namacontactdipilih.value = '';
                          });
                        }
                      },
                      style: TextStyle(fontSize: 25),
                      keyboardType: TextInputType.phone,
                      controller: controllerHp,
                      decoration: InputDecoration(
                          labelText: namacontactdipilih.value,
                          labelStyle: TextStyle(fontSize: 15),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.phone_android),
                            onPressed: () async {
                              PhoneContact contact =
                                  await FlutterContactPicker.pickPhoneContact();

                              // ignore: unnecessary_null_comparison
                              if (contact != null) {
                                String clear =
                                    contact.phoneNumber.number.toString();
                                String clear2 = clear.replaceAll(' ', '');
                                String clear3 = clear2.replaceAll('-', '');
                                String clear4 = clear3.replaceAll('+62', '0');
                                setState(() {
                                  controllerHp.text = clear4;
                                  nocontact.value = clear4;
                                  namacontactdipilih.value =
                                      contact.fullName.toString();
                                });
                              }
                            },
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 25)),
                  Text(
                    'Pilih Operator :',
                    style: TextStyle(color: Warna.grey, fontSize: 16),
                  ),
                  Padding(padding: EdgeInsets.only(top: 11)),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            c.operatorpilihan.value = 'TELKOMSEL';
                            cekPulsaTersedia();
                            setState(() {
                              alloffwarna();
                              war1 = Colors.grey[200];
                            });
                          },
                          child: SizedBox(
                            width: Get.width * 0.3,
                            height: Get.width * tinggi,
                            child: Card(
                                color: war1,
                                margin: EdgeInsets.all(3),
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'images/logopulsa/TELKOMSEL.png',
                                        width: Get.width * 0.2,
                                        height: Get.width * 0.2,
                                        fit: BoxFit.contain,
                                      ),
                                      Padding(padding: EdgeInsets.only(top: 3)),
                                      Text(
                                        'Telkomsel',
                                        style: TextStyle(
                                            fontSize: 15, color: Warna.grey),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            c.operatorpilihan.value = 'INDOSAT';
                            cekPulsaTersedia();

                            setState(() {
                              alloffwarna();
                              war2 = Colors.grey[200];
                            });
                          },
                          child: SizedBox(
                            width: Get.width * 0.3,
                            height: Get.width * tinggi,
                            child: Card(
                                color: war2,
                                margin: EdgeInsets.all(3),
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'images/logopulsa/INDOSAT.png',
                                        width: Get.width * 0.2,
                                        height: Get.width * 0.2,
                                        fit: BoxFit.contain,
                                      ),
                                      Padding(padding: EdgeInsets.only(top: 3)),
                                      Text(
                                        'Indosat',
                                        style: TextStyle(
                                            fontSize: 15, color: Warna.grey),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            c.operatorpilihan.value = 'XL';
                            cekPulsaTersedia();

                            setState(() {
                              alloffwarna();
                              war3 = Colors.grey[200];
                            });
                          },
                          child: SizedBox(
                            width: Get.width * 0.3,
                            height: Get.width * tinggi,
                            child: Card(
                                color: war3,
                                margin: EdgeInsets.all(3),
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'images/logopulsa/XL.png',
                                        width: Get.width * 0.2,
                                        height: Get.width * 0.2,
                                        fit: BoxFit.contain,
                                      ),
                                      Padding(padding: EdgeInsets.only(top: 3)),
                                      Text(
                                        'XL',
                                        style: TextStyle(
                                            fontSize: 15, color: Warna.grey),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            c.operatorpilihan.value = 'TRI';
                            cekPulsaTersedia();

                            setState(() {
                              alloffwarna();
                              war4 = Colors.grey[200];
                            });
                          },
                          child: SizedBox(
                            width: Get.width * 0.3,
                            height: Get.width * tinggi,
                            child: Card(
                                color: war4,
                                margin: EdgeInsets.all(3),
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'images/logopulsa/TRI.png',
                                        width: Get.width * 0.2,
                                        height: Get.width * 0.2,
                                        fit: BoxFit.contain,
                                      ),
                                      Padding(padding: EdgeInsets.only(top: 3)),
                                      Text(
                                        'Tri',
                                        style: TextStyle(
                                            fontSize: 15, color: Warna.grey),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            c.operatorpilihan.value = 'SMART';
                            cekPulsaTersedia();

                            setState(() {
                              alloffwarna();
                              war5 = Colors.grey[200];
                            });
                          },
                          child: SizedBox(
                            width: Get.width * 0.3,
                            height: Get.width * tinggi,
                            child: Card(
                                color: war5,
                                margin: EdgeInsets.all(3),
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'images/logopulsa/SMART.png',
                                        width: Get.width * 0.2,
                                        height: Get.width * 0.2,
                                        fit: BoxFit.contain,
                                      ),
                                      Padding(padding: EdgeInsets.only(top: 3)),
                                      Text(
                                        'Smart',
                                        style: TextStyle(
                                            fontSize: 15, color: Warna.grey),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            c.operatorpilihan.value = 'AXIS';
                            cekPulsaTersedia();

                            setState(() {
                              alloffwarna();
                              war6 = Colors.grey[200];
                            });
                          },
                          child: SizedBox(
                            width: Get.width * 0.27,
                            height: Get.width * tinggi,
                            child: Card(
                                color: war6,
                                margin: EdgeInsets.all(3),
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'images/logopulsa/AXIS.png',
                                        width: Get.width * 0.2,
                                        height: Get.width * 0.2,
                                        fit: BoxFit.contain,
                                      ),
                                      Padding(padding: EdgeInsets.only(top: 3)),
                                      Text(
                                        'Axis',
                                        style: TextStyle(
                                            fontSize: 15, color: Warna.grey),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            c.operatorpilihan.value = 'BYU';
                            cekPulsaTersedia();

                            setState(() {
                              alloffwarna();
                              war7 = Colors.grey[200];
                            });
                          },
                          child: SizedBox(
                            width: Get.width * 0.27,
                            height: Get.width * tinggi,
                            child: Card(
                                color: war7,
                                margin: EdgeInsets.all(3),
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'images/logopulsa/BYU.png',
                                        width: Get.width * 0.2,
                                        height: Get.width * 0.2,
                                        fit: BoxFit.contain,
                                      ),
                                      Padding(padding: EdgeInsets.only(top: 3)),
                                      Text(
                                        'by.U',
                                        style: TextStyle(
                                            fontSize: 15, color: Warna.grey),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child: listdaftar(),
                    color: Colors.grey[200],
                  )
                ],
              ),
            ),
          ],
        ));
  }

  void prosesPengisianPulsa() {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Image.asset(
            'images/logopulsa/${c.operatorpilihan.value}.png',
            // width: Get.width * 0.6,
          ),
          Text(
              'Apakah kamu benar akan mengisi pulsa ke nomor tujuan dan nominal ini ?',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center),
          Padding(padding: EdgeInsets.only(top: 9)),
          Text(controllerHp.text,
              style: TextStyle(
                  fontSize: 20, color: Warna.grey, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
          Text(c.detailpulsa.value,
              style: TextStyle(fontSize: 14, color: Warna.grey),
              textAlign: TextAlign.center),
          Divider(
            color: Warna.grey,
          ),
          Padding(padding: EdgeInsets.only(top: 8)),
          Text('PIN DIBUTUHKAN',
              style: TextStyle(
                  fontSize: 18,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w600)),
          Padding(padding: EdgeInsets.only(top: 7)),
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
              'Proses Transaksi Ini',
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
                prosesBeliPulsa();
              }
            },
          ),
        ],
      ),
    )..show();
  }

  void prosesBeliPulsa() async {
    EasyLoading.show(status: 'Mohon tunggu transaksi...', dismissOnTap: false);
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var pin = controllerPin.text;
    var kodepulsa = c.kodepulsa.value;
    var tujuan = controllerHp.text;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","kodepulsa":"$kodepulsa","tujuan":"$tujuan","pin":"$pin"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/beliPulsa');

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
        c.saldo.value = hasil['saldo'];
        c.pinBlokir.value = hasil['pinBlokir'];

        AwesomeDialog(
          context: Get.context,
          dismissOnBackKeyPress: false,
          dismissOnTouchOutside: false,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'TRANSAKSI DIPROSES',
          desc:
              'Mohon tunggu beberapa saat, kami sedang memproses transaksi kamu',
          btnOkText: 'OK',
          btnOkOnPress: () {
            Get.back();
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
