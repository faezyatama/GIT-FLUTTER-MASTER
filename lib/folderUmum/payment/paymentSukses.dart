import 'dart:convert';
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

class PaymentPointSukses extends StatefulWidget {
  @override
  _PaymentPointSuksesState createState() => _PaymentPointSuksesState();
}

class _PaymentPointSuksesState extends State<PaymentPointSukses> {
  @override
  void initState() {
    super.initState();
    cekPembayaranTerpilih();
  }

  final c = Get.find<ApiService>();

  final controller = TextEditingController();
  final controllerPin = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Bukti Pembayaran'),
          backgroundColor: Warna.warnautama,
          actions: [
            IconButton(
                onPressed: () {
                  c.paymentID.value = '';
                  Get.off(HistoryPembayaran());
                },
                icon: Icon(Icons.search)),
          ],
        ),
        body: (adaData.value == true)
            ? Stack(
                children: [
                  Container(
                    child: Image.asset('images/pembayaran/StrukPembayaran.png'),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(33, 22, 22, 22),
                    child: ListView(
                      children: [
                        //LOGO PENERBIT PEMBAYARAN
                        Padding(padding: EdgeInsets.only(top: 55)),

                        Column(
                          children: [
                            Text(
                              'Struk Pelunasan Tagihan :',
                              style: TextStyle(
                                  fontSize: 14, color: Warna.warnautama),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Obx(() => Text(
                              penerbit.value,
                              style: TextStyle(fontSize: 18, color: Warna.grey),
                              textAlign: TextAlign.center,
                            )),
                        Obx(() => Text(
                              alamat.value,
                              style: TextStyle(fontSize: 11, color: Warna.grey),
                              textAlign: TextAlign.center,
                            )),
                        Padding(padding: EdgeInsets.only(top: 22)),
                        Obx(() => CachedNetworkImage(
                            width: Get.width * 0.25,
                            height: Get.width * 0.25,
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
                                  fontSize: 22,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            )),
                        Obx(() => Text(
                              paymentID.value,
                              style: TextStyle(fontSize: 12, color: Warna.grey),
                              textAlign: TextAlign.center,
                            )),
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
                  Container(
                    padding: EdgeInsets.fromLTRB(2, 14, 8, 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(padding: EdgeInsets.all(1)),
                        Image.asset(
                          'images/pembayaran/PAID.png',
                          width: Get.width * 0.25,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Container(),
        bottomNavigationBar: (adaData.value == true)
            ? Container(
                padding: EdgeInsets.all(5),
                //height: Get.height * 0.08,
                child: RawMaterialButton(
                  onPressed: () {
                    Get.snackbar('Pembayaran Telah Berhasil',
                        'Pembayaran tagihan ini telah berhasil dilaksanakan',
                        snackPosition: SnackPosition.BOTTOM);
                  },
                  constraints: BoxConstraints(),
                  elevation: 1.0,
                  fillColor: Colors.green,
                  child: Text(
                    'Pembayaran Sukses',
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
            : Container());
  }

  void cekPembayaranTerpilih() async {
    //LOAD DATA TOPUP
    EasyLoading.show(status: 'Membuka Pembayaran...');

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var idTerpilih = c.paymentID.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","idTerpilih":"$idTerpilih"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/pilihIDPembayaranSukses');

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

        setState(() {
          adaData.value = true;
        });
      } else {
        Get.off(HistoryPembayaran());
      }
    }
    //END LOAD DATA TOP UP
  }
}
