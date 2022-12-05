import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../base/notifikasiBuatAkun.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import '../payment/historyPayment.dart';

class PaymentPointTerpilih extends StatefulWidget {
  @override
  _PaymentPointTerpilihState createState() => _PaymentPointTerpilihState();
}

class _PaymentPointTerpilihState extends State<PaymentPointTerpilih> {
  @override
  void initState() {
    super.initState();
    cekPembayaranTerbaru();
  }

  final controller = TextEditingController();
  final controllerPin = TextEditingController();
  final c = Get.find<ApiService>();
  var penerbit = ''.obs;
  var alamat = ''.obs;
  var logoPenerbit = ''.obs;
  var statusPembayaran = ''.obs;
  var paymentID = ''.obs;
  var tanggal = ''.obs;
  var jumlahPembayaran = ''.obs;
  var deskripsi = ''.obs;
  var adaData = false.obs;
  var jumlahPembayaranINT = 0.obs;
  var paymentIDInvoice = ''.obs;

  var metodeBayar = ''.obs;
  var bankLogo = ''.obs;
  var norek = ''.obs;
  var an = ''.obs;
  var emblemStatus = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Pembayaran'),
          backgroundColor: Warna.warnautama,
          actions: [
            IconButton(
                onPressed: () {
                  c.paymentID.value = '';
                  Get.off(HistoryPembayaran());
                },
                icon: Icon(Icons.search)),
            IconButton(
                onPressed: () {
                  if (c.loginAsPenggunaKita.value == 'Member') {
                    scanQRCekPembayaran();
                  } else {
                    var judulF = 'Bayar Tagihan ?';
                    var subJudul =
                        'Berbagai tagihan dengan mudah dibayarkan dengan aplikasi ${c.namaAplikasi}, Yuk Buka akun ${c.namaAplikasi} sekarang';

                    bukaLoginPage(judulF, subJudul);
                  }
                },
                icon: Icon(Icons.qr_code_2))
          ],
        ),
        body: (adaData.value == true)
            ? Stack(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(33, 1, 22, 22),
                    child: ListView(
                      children: [
                        //LOGO PENERBIT PEMBAYARAN
                        Padding(padding: EdgeInsets.only(top: 55)),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Permintaan pembayaran dari :',
                              style: TextStyle(
                                  fontSize: 14, color: Warna.warnautama),
                            ),
                            Obx(() => Text(
                                  penerbit.value,
                                  style: TextStyle(
                                      fontSize: 18, color: Warna.grey),
                                )),
                            Obx(() => Text(
                                  alamat.value,
                                  style: TextStyle(
                                      fontSize: 11, color: Warna.grey),
                                )),
                          ],
                        ),

                        Padding(padding: EdgeInsets.only(top: 22)),
                        Obx(() => CachedNetworkImage(
                            width: Get.width * 0.4,
                            imageUrl: logoPenerbit.value,
                            errorWidget: (context, url, error) {
                              print(error);
                              return Icon(Icons.error);
                            })),
                        Padding(padding: EdgeInsets.only(top: 22)),
                        Text(
                          'Payment ID / Invoice No :',
                          style:
                              TextStyle(fontSize: 14, color: Warna.warnautama),
                          textAlign: TextAlign.center,
                        ),
                        Obx(() => Text(
                              paymentIDInvoice.value,
                              style: TextStyle(fontSize: 18, color: Warna.grey),
                              textAlign: TextAlign.center,
                            )),
                        Obx(() => Text(
                              tanggal.value,
                              style: TextStyle(fontSize: 18, color: Warna.grey),
                              textAlign: TextAlign.center,
                            )),
                        Padding(padding: EdgeInsets.only(top: 15)),

                        Text(
                          'Total Tagihan Pembayaran',
                          style:
                              TextStyle(fontSize: 14, color: Warna.warnautama),
                          textAlign: TextAlign.center,
                        ),
                        Obx(() => Text(
                              jumlahPembayaran.value,
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Warna.grey,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            )),
                        Padding(padding: EdgeInsets.only(top: 15)),

                        Text(
                          'Status Pembayaran',
                          style:
                              TextStyle(fontSize: 14, color: Warna.warnautama),
                          textAlign: TextAlign.center,
                        ),
                        Obx(() => Text(
                              statusPembayaran.value,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Warna.grey,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            )),
                        Divider(),
                        (metodeBayar.value == 'TRANSFER')
                            ? Column(
                                children: [
                                  Image.network(bankLogo.value,
                                      width: Get.width * 0.3),
                                  Text(
                                    norek.value,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Warna.grey,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    an.value,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Warna.grey,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            : Padding(padding: EdgeInsets.only(top: 1)),

                        Padding(padding: EdgeInsets.only(top: 15)),
                        Text(
                          'Deskripsi Pembayaran :',
                          style:
                              TextStyle(fontSize: 14, color: Warna.warnautama),
                          textAlign: TextAlign.center,
                        ),
                        Obx(() => Text(
                              deskripsi.value,
                              style: TextStyle(fontSize: 18, color: Warna.grey),
                              textAlign: TextAlign.center,
                            )),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset('images/pay/' + emblemStatus.value,
                          width: Get.width * 0.35)
                    ],
                  )
                ],
              )
            : Container(),
        bottomNavigationBar: (adaData.value == true)
            ? Container(
                padding: EdgeInsets.all(5),
                //height: Get.height * 0.08,
                child: (metodeBayar.value == 'SALDO APK')
                    ? RawMaterialButton(
                        onPressed: () {
                          if (c.saldoInt.value >= jumlahPembayaranINT.value) {
                            pinDibutuhkan();
                          } else {
                            Get.snackbar('Saldo Tidak Mencukupi..!',
                                'Oppss... Sepertinya saldo kamu tidak mencukupi untuk menyelesaikan transaksi ini',
                                snackPosition: SnackPosition.BOTTOM);
                          }
                        },
                        constraints: BoxConstraints(),
                        elevation: 1.0,
                        fillColor: Warna.warnautama,
                        child: Text(
                          'Proses Pembayaran ini',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: Warna.putih),
                        ),
                        padding: EdgeInsets.fromLTRB(22, 11, 22, 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(33)),
                        ),
                      )
                    : RawMaterialButton(
                        onPressed: () {
                          if ((statusPembayaran.value == 'WAITING')) {
                            konfirmasiTransferTanpaberkas(
                                paymentIDInvoice.value);
                          } else {
                            Get.snackbar('Mohon Menunggu',
                                'Mohon tunggu pembayaran kamu sedang diproses, Silahkan menghubungi CS bila ada kendala');
                          }
                        },
                        constraints: BoxConstraints(),
                        elevation: 1.0,
                        fillColor: Warna.warnautama,
                        child: ((statusPembayaran.value == 'WAITING'))
                            ? Text(
                                'Konfirmasi Sudah Transfer',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                    color: Warna.putih),
                              )
                            : Text(
                                'Sedang dalam Proses',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                    color: Warna.putih),
                              ),
                        padding: EdgeInsets.fromLTRB(22, 11, 22, 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(33)),
                        ),
                      ))
            : Container());
  }

  Future<void> scanQRCekPembayaran() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', false, ScanMode.QR);

      // print(barcodeScanRes);

      var qr = barcodeScanRes.split(' ');

      if (qr[0] == 'send') {
        c.kirimkeSS.value = qr[1];
        Get.to(() => cekAdaTagihanBayarDisiniTak());
      } else {
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: 'SCAN CODE GAGAL !',
          desc: 'Kode yang discan tidak ada dalam kode pembayaran',
          btnCancelText: 'OK',
          btnCancelColor: Colors.amber,
          btnCancelOnPress: () {},
        )..show();
      }
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

  void cekPembayaranTerbaru() async {
    if (c.loginAsPenggunaKita.value != 'Member') {
      return;
    }
    //LOAD DATA TOPUP
    EasyLoading.show(status: 'Membuka Pembayaran...');

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');
    var idTerpilih = c.paymentID.value;

    var datarequest = '{"pid":"$pid","idTerpilih":"$idTerpilih"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/pilihIDPembayaran');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        penerbit.value = hasil['penerbit'];
        alamat.value = hasil['alamat'];
        logoPenerbit.value = hasil['logoPenerbit'];
        statusPembayaran.value = hasil['statusPembayaran'];
        paymentID.value = hasil['paymentID'];
        tanggal.value = hasil['tanggal'];
        jumlahPembayaran.value = hasil['jumlahPembayaran'];
        deskripsi.value = hasil['deskripsi'];
        jumlahPembayaranINT.value = hasil['jumlahPembayaranINT'];
        paymentIDInvoice.value = hasil['paymentIDPenerbit'];

        metodeBayar.value = hasil['metode'];
        bankLogo.value = hasil['bank'];
        norek.value = hasil['norek'];
        an.value = hasil['an'];
        emblemStatus.value = hasil['emblemStatus'];

        setState(() {
          adaData.value = true;
        });
      } else {
        Get.off(HistoryPembayaran());
      }
    }
    //END LOAD DATA TOP UP
  }

  void pinDibutuhkan() {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Container(
            width: Get.width * 0.25,
            height: Get.width * 0.25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                  image: NetworkImage(logoPenerbit.value), fit: BoxFit.cover),
            ),
          ),
          Text(
            penerbit.value,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 17, color: Warna.grey, fontWeight: FontWeight.w600),
          ),
          Text(
            jumlahPembayaran.value,
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
              'Kamu akan melakukan pembayaran ini, Periksa kembali tujuan pembayaran kamu, Bila sudah sesuai silahkan masukan PIN untuk Memproses transaksi',
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
              'Proses Pembayaran sekarang',
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
                prosesTransaksiIni();
              }
            },
          ),
        ],
      ),
    )..show();
  }

  void prosesTransaksiIni() async {
    var pin = controllerPin.text;

    //cek uang ada nggak
    EasyLoading.show(
        status: 'Memproses pembayaran, mohon tunggu...', dismissOnTap: false);

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var idTransaksi = paymentID.value;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","pin":"$pin","idTransaksi":"$idTransaksi"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/prosesPembayaranSekarang');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
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
          dismissOnBackKeyPress: false,
          dismissOnTouchOutside: false,
          context: Get.context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'PEMBAYARAN BERHASIL !',
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
          title: 'PEMBAYARAN GAGAL !',
          desc: resultnya['message'],
          btnCancelText: 'OK',
          btnCancelOnPress: () {},
        )..show();
      }
    }
  }

  void konfirmasiTransferTanpaberkas(String kode) async {
    //LOAD DATA TOPUP
    EasyLoading.show(status: 'Membuka Pembayaran...');

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","kode":"$kode"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURL}/mobileApps/konfirmasiTransferTanpaberkas');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        cekPembayaranTerbaru();
      } else {
        Get.off(HistoryPembayaran());
      }
    }
  }
}

cekAdaTagihanBayarDisiniTak() async {
  final c = Get.find<ApiService>();
  EasyLoading.show(
      status: 'Mencari Pembayaran, mohon tunggu...', dismissOnTap: true);

  //BODY YANG DIKIRIM
  Box dbbox = Hive.box<String>('sasukaDB');
  var token = dbbox.get('token');
  var pid = dbbox.get('person_id');
  var ssPenerbit = c.kirimkeSS.value;
  var user = dbbox.get('loginSebagai');

  var datarequest = '{"pid":"$pid","ssPenerbit":"$ssPenerbit"}';
  var bytes = utf8.encode(datarequest + '$token' + user);
  var signature = md5.convert(bytes).toString();

  var url = Uri.parse('${c.baseURL}/mobileApps/cekAdaPembayaranTidak');

  final response = await http.post(url, body: {
    "user": user,
    "appid": c.appid,
    "data_request": datarequest,
    "sign": signature,
    "package": c.packageName
  });

  EasyLoading.dismiss();
  print(response.body);
  if (response.statusCode == 200) {
    Map<String, dynamic> resultnya = jsonDecode(response.body);
    if (resultnya['status'] == 'success') {
      c.paymentID.value = resultnya['paymentID'];
      Get.off(PaymentPointTerpilih());
    } else {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'TIDAK DITEMUKAN !',
        desc: resultnya['message'],
        btnCancelText: 'OK',
        btnCancelOnPress: () {},
      )..show();
    }
  }
}
