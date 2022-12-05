import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import '../payment/historyPayment.dart';

class PaymentPointVoucher extends StatefulWidget {
  @override
  _PaymentPointVoucherState createState() => _PaymentPointVoucherState();
}

class _PaymentPointVoucherState extends State<PaymentPointVoucher> {
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
  var emblemStatus = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Pembayaran Via Voucher'),
          backgroundColor: Warna.warnautama,
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
                                  maxLines: 3,
                                  style: TextStyle(
                                      fontSize: 18, color: Warna.grey),
                                )),
                            Obx(() => Text(
                                  alamat.value,
                                  maxLines: 3,
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

                        Text(
                          'Deskripsi Pembayaran :',
                          style:
                              TextStyle(fontSize: 14, color: Warna.warnautama),
                          textAlign: TextAlign.center,
                        ),
                        Padding(padding: EdgeInsets.only(top: 10)),
                        Obx(() => Text(
                              deskripsi.value,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Warna.grey,
                                  fontWeight: FontWeight.w500),
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
        bottomNavigationBar:
            ((adaData.value == true) && (statusPembayaran.value == 'WAITING'))
                ? Container(
                    padding: EdgeInsets.all(5),
                    child: RawMaterialButton(
                      onPressed: () {
                        pinDibutuhkan();
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
                    ),
                  )
                : Padding(padding: EdgeInsets.only(top: 5)));
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
    var kodeBayar = c.kodePembayaranVoucher;

    var datarequest = '{"pid":"$pid","kodeBayar":"$kodeBayar"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/cekPembayaranVoucher');

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
        emblemStatus.value = hasil['emblemStatus'];

        setState(() {
          adaData.value = true;
        });
      } else {
        Get.snackbar('Kode Pembayaran Tidak Valid',
            'Opps.. sepertinya kode pembayaran tidak ditemukan',
            snackPosition: SnackPosition.BOTTOM);
        Get.off(() => HistoryPembayaran());
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
            height: Get.width * 0.25,
            decoration: BoxDecoration(
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

    var url = Uri.parse('${c.baseURL}/mobileApps/prosesPembayaranViaVoucher');

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
        c.voucherBelanja.value = resultnya['voucher'];

        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          dismissOnBackKeyPress: false,
          dismissOnTouchOutside: false,
          title: 'PEMBAYARAN BERHASIL !',
          desc: resultnya['message'],
          btnOkText: 'OK',
          btnOkOnPress: () {
            Get.back();
            Get.to(() => PaymentPointVoucher());
          },
        )..show();
      } else {
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.error,
          dismissOnBackKeyPress: false,
          dismissOnTouchOutside: false,
          animType: AnimType.rightSlide,
          title: 'PEMBAYARAN GAGAL !',
          desc: resultnya['message'],
          btnCancelText: 'OK',
          btnCancelOnPress: () {
            Get.off(() => PaymentPointVoucher());
          },
        )..show();
      }
    }
  }
}
