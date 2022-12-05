import 'dart:convert';

// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:http/http.dart' as http;

class PpobListrik extends StatefulWidget {
  @override
  _PpobListrikState createState() => _PpobListrikState();
}

class _PpobListrikState extends State<PpobListrik> {
  @override
  void initState() {
    super.initState();
    c.kodepulsa.value = 'PLN';
    c.operatorpilihan.value = 'PASCABAYAR';
  }

  final controllerHp = TextEditingController();
  final controllerPin = TextEditingController();

  final c = Get.find<ApiService>();

  var namacontactdipilih = ''.obs;
  var nocontact = ''.obs;
  var namapelanggan = '';
  var golongan = '';

  var war1 = Colors.white;
  var war2 = Colors.white;
  var war3 = Colors.white;
  var war4 = Colors.white;
  var war5 = Colors.white;
  var war6 = Colors.white;
  var war7 = Colors.white;
  var war8 = Colors.white;
  var war9 = Colors.white;
  var war10 = Colors.white;

  void alloffwarna() {
    war1 = Colors.white;
    war2 = Colors.white;
    war3 = Colors.white;
    war4 = Colors.white;
    war5 = Colors.white;
    war6 = Colors.white;
    war7 = Colors.white;
    war8 = Colors.white;
    war9 = Colors.white;
    war10 = Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Token PLN'),
          backgroundColor: Warna.warnautama,
        ),
        body: ListView(
          children: [
            Container(
              child: Column(
                children: [
                  Padding(padding: EdgeInsets.only(top: 22)),
                  Image.asset(
                    'images/logoppob/pln.png',
                    width: Get.width * 0.3,
                  ),
                  Padding(padding: EdgeInsets.only(top: 22)),
                  Text('Masukan ID Pelanggan / No METER :',
                      style: TextStyle(color: Warna.grey, fontSize: 16)),
                  Container(
                    padding: EdgeInsets.only(left: 22, top: 22, right: 22),
                    child: Container(
                      width: Get.width * 0.8,
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
                                    await FlutterContactPicker
                                        .pickPhoneContact();

                                // ignore: unnecessary_null_comparison
                                if (contact != null) {
                                  String clear =
                                      contact.phoneNumber.number.toString();
                                  String clear2 = clear.replaceAll(' ', '');
                                  String clear3 = clear2.replaceAll('-', '');

                                  setState(() {
                                    controllerHp.text = clear3;
                                    nocontact.value = clear3;
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
                  ),
                  ElevatedButton(
                      onPressed: () {}, child: Text('Cek Tagihan PLN'))
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
              'Apakah kamu benar akan membeli Token PLN ke nomor tujuan dan nominal ini ?',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center),
          Padding(padding: EdgeInsets.only(top: 9)),
          Text(controllerHp.text,
              style: TextStyle(
                  fontSize: 20, color: Warna.grey, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
          Text(
            c.detailpulsa.value,
            style: TextStyle(fontSize: 14, color: Warna.grey),
          ),
          Padding(padding: EdgeInsets.only(top: 16)),
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

    var datarequest =
        '{"pid":"$pid","kodepulsa":"$kodepulsa","tujuan":"$tujuan","pin":"$pin"}';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse('${c.baseURL}/sasuka/beliPulsa');

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

  void cekNomorMeter() async {
    EasyLoading.show(status: 'Cek Pelanggan...');

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var pelanggan = controllerHp.text;

    var datarequest = '{"pid":"$pid","nopelanggan":"$pelanggan"}';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse('${c.baseURL}/sasuka/cekpelangganpln');

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
        if (mounted) {
          setState(() {
            namapelanggan = hasil['nama'];
            golongan = hasil['golongan'];
          });
        }
      }
    }
  }
}
