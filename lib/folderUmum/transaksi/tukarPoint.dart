import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:crypto/crypto.dart';
import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../base/notifikasiBuatAkun.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import 'package:http/http.dart' as http;

class TukarkanPoint extends StatefulWidget {
  @override
  _TukarkanPointState createState() => _TukarkanPointState();
}

class _TukarkanPointState extends State<TukarkanPoint> {
  final focusNode = FocusNode();

  final controller = TextEditingController();
  final controllerSS = TextEditingController();
  final controllerPin = TextEditingController();

  final c = Get.find<ApiService>();
  //BOTTOM NAVIGATION BAR

  @override
  void initState() {
    super.initState();
    controllerSS.text = c.kirimkeSS.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tukarkan Point'),
        backgroundColor: Warna.warnautama,
      ),
      body: Container(
          padding: EdgeInsets.all(25),
          child: ListView(
            children: [
              Text(
                'Point Transaksi Kamu',
                style: TextStyle(
                    color: Warna.grey,
                    fontSize: 22,
                    fontWeight: FontWeight.w200),
              ),
              Text(
                'Perbanyak transaksi kamu menggunakan aplikasi ${c.namaAplikasi}, dan kumpulkan sebanyak banyaknya point',
                style: TextStyle(color: Warna.grey, fontSize: 14),
              ),
              Padding(padding: EdgeInsets.only(top: 33)),
              Row(
                children: [
                  Column(
                    children: [
                      Image.asset('images/pointgift.png',
                          width: Get.width * 0.15),
                      Obx(() => Text(
                            c.pointReward.value.toString(),
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          )),
                    ],
                  ),
                  Padding(padding: EdgeInsets.only(left: 9)),
                  Container(
                    width: Get.width * 0.65,
                    child: Text(
                      'Kamu bisa tukarkan point kamu pada unit usaha koperasi terdekat, Banyak produk menarik yang bisa kamu tukarkan',
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 33)),
              Text('Scan QR CODE :'),
              Container(
                width: Get.width * 0.7,
                child: TextField(
                  maxLength: 8,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: Warna.grey),
                  controller: controllerSS,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      suffixIcon: GestureDetector(
                          onTap: () {
                            scanQR();
                          },
                          child: Icon(Icons.qr_code)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 12)),
              Text('Jumlah point yang mau ditukarkan :'),
              Container(
                width: Get.width * 0.7,
                child: TextField(
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: Warna.grey),
                  controller: controller,
                  inputFormatters: [
                    TextInputMask(
                        mask: ['999.999.999.999', '999.999.9999.999'],
                        reverse: true)
                  ],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.money),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 12)),
              RawMaterialButton(
                constraints: BoxConstraints(minWidth: Get.width * 0.7),
                elevation: 5.0,
                fillColor: Warna.warnautama,
                child: Text(
                  'Tukarkan Point Sekarang !',
                  style: TextStyle(color: Warna.putih, fontSize: 16),
                ),
                padding: EdgeInsets.fromLTRB(18, 12, 18, 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                ),
                onPressed: () {
                  if (c.loginAsPenggunaKita.value == 'Member') {
                    if (controller.text != '') {
                      periksaKelengkapan();
                    } else {
                      AwesomeDialog(
                        context: Get.context,
                        dialogType: DialogType.noHeader,
                        animType: AnimType.rightSlide,
                        title: 'PERHATIAN !',
                        desc:
                            'Kamu belum memasukan jumlah point yang ingin ditukarkan',
                        btnCancelText: 'OK',
                        btnCancelColor: Colors.amber,
                        btnCancelOnPress: () {},
                      )..show();
                    }
                  } else {
                    var judulF = 'Point Reward';
                    var subJudul =
                        'Kamu belum memiliki point ${c.namaAplikasi}, perbanyak transaksi kamu ya, Yuk Buka akun ${c.namaAplikasi} sekarang';

                    bukaLoginPage(judulF, subJudul);
                  }
                },
              ),
            ],
          )),
    );
  }

  void periksaKelengkapan() {
    var nominal = controller.text.replaceAll('.', '');
    var nom = int.parse(nominal);

    if (nom > c.pointReward.value) {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        title: 'Point Tidak Cukup',
        desc:
            'Opps.. sepertinya point kamu saat ini tidak cukup, Perbanyak transaksi kamu dan kumpulkan pointnya',
        btnCancelText: 'OK',
        btnCancelColor: Colors.amber,
        btnCancelOnPress: () {},
      )..show();
    } else if (nom < 1) {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        title: 'PERHATIAN !',
        desc: 'Minimum penukaran point adalah 1 point',
        btnCancelText: 'OK',
        btnCancelColor: Colors.amber,
        btnCancelOnPress: () {},
      )..show();
    } else if (controllerSS.text.length != 8) {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        title: 'PERHATIAN !',
        desc:
            'Kode Unit Usaha dibutuhkan untuk menukarkan point, Silahkan scan code ',
        btnCancelText: 'OK',
        btnCancelColor: Colors.amber,
        btnCancelOnPress: () {},
      )..show();
    } else {
      periksaSSKonfirmasi();
    }
  }

  void periksaSSKonfirmasi() async {
    focusNode.unfocus();

    EasyLoading.show(status: 'Mohon tunggu...', dismissOnTap: false);

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var ss = controllerSS.text;

    var user = dbbox.get('loginSebagai');
    var datarequest = '{"pid":"$pid", "kodess":"$ss"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/cekSSUnitUsaha');

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
        var data = hasil['data'];
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: NetworkImage(data[2]), fit: BoxFit.cover),
                ),
              ),
              Text(
                data[0],
                style: TextStyle(
                    fontSize: 19,
                    color: Warna.grey,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                '${controller.text} POINT',
                style: TextStyle(
                    fontSize: 18,
                    color: Warna.grey,
                    fontWeight: FontWeight.w600),
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
                  'Kamu akan melakukan menukarkan point reward. Bila sudah sesuai silahkan masukan PIN untuk Menukarkan Point',
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
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: Warna.grey),
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
                  'Tukarkan Point sekarang',
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
                    tukarkanPointSekarang();
                  }
                },
              ),
            ],
          ),
        )..show();
      } else {
        AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.warning,
            animType: AnimType.rightSlide,
            title: 'PERHATIAN !',
            desc: hasil['message'],
            btnCancelText: 'OK',
            btnCancelOnPress: () {},
            btnCancelColor: Colors.amber)
          ..show();
      }
    }
  }

  void tukarkanPointSekarang() async {
    var nominal = controller.text.replaceAll('.', '');
    var nom = int.parse(nominal);
    var pin = controllerPin.text;

    //cek uang ada nggak

    EasyLoading.show(
        status: 'Menukarkan Point, mohon tunggu...', dismissOnTap: false);

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var ss = controllerSS.text;
    var user = dbbox.get('loginSebagai');
    var datarequest = '{"pid":"$pid","ss":"$ss","jumlah":"$nom","pin":"$pin"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/TukarkanPoint');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    controllerPin.text = '';
    Get.back();

    EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> resultnya = jsonDecode(response.body);
      if (resultnya['status'] == 'success') {
        c.pointReward.value = resultnya['pointSisa'];
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'PENUKARAN POINT BERHASIL !',
          desc: resultnya['message'],
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
          title: 'GAGAL TUKAR !',
          desc: resultnya['message'],
          btnCancelText: 'OK',
          btnCancelOnPress: () {},
        )..show();
      }
    }
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', false, ScanMode.QR);

      // print(barcodeScanRes);

      var qr = barcodeScanRes.split(' ');
      controllerSS.text = qr[1];
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    // if (!mounted) return;

    // setState(() {
    //   _scanBarcode = barcodeScanRes;
    // });
  }
}
