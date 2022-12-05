import 'dart:convert';

// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:crypto/crypto.dart';
// ignore: import_of_legacy_library_into_null_safe
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

class KirimSaldo extends StatefulWidget {
  @override
  _KirimSaldoState createState() => _KirimSaldoState();
}

class _KirimSaldoState extends State<KirimSaldo> {
  final focusNode = FocusNode();

  final controller = TextEditingController();
  final controllerSS = TextEditingController();
  final controllerPin = TextEditingController();
  final controllerpesan = TextEditingController();

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
        title: Text('Kirim Saldo'),
        backgroundColor: Warna.warnautama,
      ),
      body: Container(
          padding: EdgeInsets.all(25),
          child: ListView(
            children: [
              Row(
                children: [
                  Image.asset('images/kirim.png', width: Get.width * 0.15),
                  Padding(padding: EdgeInsets.only(left: 9)),
                  Container(
                    width: Get.width * 0.65,
                    child: Text(
                      'Cara mudah mengirimkan saldo ke teman kamu, Gunakan fitur kirim saldo di aplikasi ${c.namaAplikasi}',
                      style: TextStyle(color: Warna.grey, fontSize: 16),
                    ),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 33)),
              Text('Masukan kode akun teman kamu :'),
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
                            if (c.loginAsPenggunaKita.value == 'Member') {
                              scanQR();
                            } else {
                              var judulF = 'Scan QR Kode';
                              var subJudul =
                                  'Cukup Scan QR Code teman kamu dan transfer, Mudah bukan ?, Yuk Buka akun koperasi di aplikasi ${c.namaAplikasi} sekarang';

                              bukaLoginPage(judulF, subJudul);
                            }
                          },
                          child: Icon(Icons.qr_code)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 33)),
              Text('Jumlah yang mau dikirimkan :'),
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
              Text('Pesan :'),
              Container(
                width: Get.width * 0.7,
                child: TextField(
                  maxLength: 50,
                  maxLines: 2,
                  style: TextStyle(fontSize: 18, color: Warna.grey),
                  controller: controllerpesan,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.chat),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
              RawMaterialButton(
                constraints: BoxConstraints(minWidth: Get.width * 0.7),
                elevation: 5.0,
                fillColor: Warna.warnautama,
                child: Text(
                  'Lanjutkan',
                  style: TextStyle(color: Warna.putih, fontSize: 16),
                ),
                padding: EdgeInsets.fromLTRB(18, 9, 18, 9),
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
                        desc: 'Nominal tranfer saldo minimal Rp. 1.000,-',
                        btnCancelText: 'OK',
                        btnCancelColor: Colors.amber,
                        btnCancelOnPress: () {},
                      )..show();
                    }
                  } else {
                    var judulF = 'Transfer saldo antar anggota';
                    var subJudul =
                        'Kamu tidak memiliki saldo untuk ditransferkan, Yuk Buka akun koperasi di aplikasi ${c.namaAplikasi} sekarang';

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
    print(nom);
    print(c.saldoInt.value);
    if (nom > c.saldoInt.value) {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        title: 'Saldo Tidak Cukup',
        desc:
            'Opps.. sepertinya saldo kamu saat ini tidak cukup, Nominal tranfer saldo adalah Rp. 100,-',
        btnCancelText: 'OK',
        btnCancelColor: Colors.amber,
        btnCancelOnPress: () {},
      )..show();
    } else if (nom < 1000) {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        title: 'PERHATIAN !',
        desc: 'Nominal tranfer saldo adalah Rp. 1000,-',
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
        desc: 'Kode akun dibutuhkan untuk melakukan transfer ke teman kamu',
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

    EasyLoading.show(status: 'Memeriksa Pengguna...', dismissOnTap: false);

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var ss = controllerSS.text;
    var datarequest = '{"pid":"$pid", "kodess":"$ss"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/cekSSpengguna');

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
                'Rp. ${controller.text},-',
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
                  'Kamu akan melakukan transfer saldo ke ${data[0]}. Periksa kembali tujuan transfer kamu, Bila sudah sesuai silahkan masukan PIN untuk Mengirimkan Saldo',
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
                  'Kirim saldo sekarang',
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
                    kirimSaldoSekarang();
                  }
                },
              ),
            ],
          ),
        )..show();
      } else {
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'PERHATIAN !',
          desc: hasil['message'],
          btnCancelText: 'OK',
          btnCancelOnPress: () {},
        )..show();
      }
    }
  }

  void kirimSaldoSekarang() async {
    var nominal = controller.text.replaceAll('.', '');
    var nom = int.parse(nominal);
    var pin = controllerPin.text;
    var pesan = controllerpesan.text;

    //cek uang ada nggak

    EasyLoading.show(
        status: 'Mengirim Saldo, mohon tunggu...', dismissOnTap: false);

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var ss = controllerSS.text;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","kodess":"$ss","jumlah":"$nom","pin":"$pin","pesan":"$pesan"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/kirimSaldo');

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
        c.pinBlokir.value = resultnya['pinBlokir'];
        c.saldo.value = resultnya['saldo'];
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'TRANSFER BERHASIL !',
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
          title: 'GAGAL TRANSFER !',
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
