import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:satuaja/folderUmum/payment/voucherPayment.dart';
import '../../base/conn.dart';
import '../../base/notifikasiBuatAkun.dart';
import '../transaksi/kirim.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import '../payment/listTerpilih.dart';
import '../payment/paymentSukses.dart';
import 'saldoPayment.dart';
//import 'package:bottom_picker/bottom_picker.dart';

class HistoryPembayaran extends StatefulWidget {
  @override
  _HistoryPembayaranState createState() => _HistoryPembayaranState();
}

class _HistoryPembayaranState extends State<HistoryPembayaran> {
  final c = Get.find<ApiService>();
  var paginate = 0;
  var dataBayar = true;

  @override
  void initState() {
    super.initState();
    loadDataPembayaran(paginate);
  }

  loadDataPembayaran(halaman) async {
    if (c.loginAsPenggunaKita.value != 'Member') {
      return;
    }

    //LOAD DATA TOPUP
    EasyLoading.show(status: 'Mencari Riwayat Pembayaran...');

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","skip":"$halaman"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/listPayment');

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
        paginate = paginate + 1;
        setState(() {
          dataFollowers = hasil['data'];
          // listdaftar();
        });
      }
    }
    //END LOAD DATA TOP UP
  }

  List<dynamic> dataFollowers = [].obs;
  List<Container> listbank = [];
  listdaftar() {
    listbank = [];
    if (dataFollowers.length > 0) {
      for (var i = 0; i < dataFollowers.length; i++) {
        var foll = dataFollowers[i];
        listbank.add(
          Container(
            child: GestureDetector(
              onTap: () {
                print(foll[5]);
                if ((foll[5] == 'WAITING') || (foll[5] == 'REQUEST CHECK')) {
                  c.paymentID.value = foll[7];
                  Get.off(PaymentPointTerpilih());
                } else if (foll[5] == 'APPROVE') {
                  AwesomeDialog(
                      context: Get.context,
                      dialogType: DialogType.noHeader,
                      animType: AnimType.rightSlide,
                      title: 'PEMBAYARAN TELAH BERHASIL',
                      desc:
                          'Pembayaran untuk transaksi ini telah berhasil dilakukan',
                      btnOkColor: Colors.green,
                      btnOkText: 'Buka Detail',
                      btnOkOnPress: () {
                        c.paymentID.value = foll[7];
                        Get.off(PaymentPointSukses());
                      })
                    ..show();
                } else if (foll[5] == 'EXPIRE') {
                  AwesomeDialog(
                      context: Get.context,
                      dialogType: DialogType.noHeader,
                      animType: AnimType.rightSlide,
                      title: 'PEMBAYARAN EXIPRE',
                      desc: 'Pembayaran untuk transaksi ini telah expire.',
                      btnOkColor: Colors.red,
                      btnOkOnPress: () {})
                    ..show();
                }
              },
              child: SizedBox(
                  child: Card(
                elevation: 0.3,
                child: Container(
                  padding: EdgeInsets.fromLTRB(2, 0, 2, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image(
                              width: Get.width * 0.12,
                              image: CachedNetworkImageProvider(
                                '${foll[1]}',
                              )),
                          Padding(padding: EdgeInsets.only(left: 11)),
                          Container(
                            width: Get.width * 0.55,
                            padding: EdgeInsets.fromLTRB(2, 5, 2, 5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  foll[0],
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Warna.grey,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  foll[2],
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Warna.grey,
                                      fontWeight: FontWeight.w600),
                                ),
                                Padding(padding: EdgeInsets.only(top: 4)),
                                Text(
                                  'Deskripsi :',
                                  style: TextStyle(
                                      fontSize: 10, color: Warna.grey),
                                ),
                                Text(
                                  foll[3],
                                  style: TextStyle(
                                      fontSize: 11, color: Warna.grey),
                                ),
                                Text(
                                  foll[4],
                                  style: TextStyle(
                                      fontSize: 11, color: Warna.warnautama),
                                ),
                              ],
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(left: 9)),
                        ],
                      ),
                      Image.asset(
                        'images/pay/${foll[8]}',
                        width: Get.width * 0.18,
                      ),
                    ],
                  ),
                ),
              )),
            ),
          ),
        );
      }
    } else {
      //kalo Nodata
      listbank.add(Container(
        child: GestureDetector(
          onTap: () {
            scanQRCekPembayaran();
          },
          child: Center(
            child: Column(
              children: [
                Padding(padding: EdgeInsets.only(top: Get.height * 0.1)),
                Image.asset(
                  'images/whitelabelNewAsset/scanqr.jpg',
                  width: Get.width * 0.8,
                ),
                Text('PAYMENT POINT',
                    style: TextStyle(
                        color: Warna.warnautama,
                        fontSize: 28,
                        fontWeight: FontWeight.w100)),
                Text('Belum ada data pembayaran yang tersedia'),
                Text('Tap gambar untuk lakukan scan QR Code'),
              ],
            ),
          ),
        ),
      ));
    }
    return Column(
      children: listbank,
    );
  }

  var bisnisku = [];
  var dataku = [];
  var follbackangka = 0.obs;
  var indexing = 0;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    paginate = 0;
    listbank = [];
    dataFollowers = [];
    await loadDataPembayaran(paginate);
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    //  await loadDataPembayaran(paginate);

    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(actions: [
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
        ], title: Text('Daftar Pembayaran'), backgroundColor: Warna.warnautama),
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: WaterDropHeader(
            waterDropColor: Warna.warnautama,
          ),
          footer: CustomFooter(
            builder: (BuildContext context, LoadStatus mode) {
              Widget body;
              if (mode == LoadStatus.idle) {
                body = Text("Sepertinya semua data telah ditampilkan");
              } else if (mode == LoadStatus.loading) {
                body = CupertinoActivityIndicator();
              } else if (mode == LoadStatus.failed) {
                body = Text("Gagal memuat ! Silahkan ulangi lagi !");
              } else if (mode == LoadStatus.canLoading) {
                body = Text("release to load more");
              } else {
                body = Text("No more Data");
              }
              return Container(
                height: 55.0,
                child: Center(child: body),
              );
            },
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: ListView(
            children: [
              listdaftar(),
            ],
          ),
        ));
  }

  // from 1.5.0, it is not necessary to add this line
  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> scanQRCekPembayaran() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', false, ScanMode.QR);
      var qr = barcodeScanRes.split(' ');
      print(barcodeScanRes);

      if (qr[0] == 'send') {
        c.kirimkeSS.value = qr[1];
        Get.off(KirimSaldo());
        //cekAdaTagihanBayarDisiniTak();
      } else if (qr[0] == 'voucher') {
        c.kodePembayaranVoucher = qr[1];
        Get.off(() => PaymentPointVoucher());
      } else if (qr[0] == 'payViaSaldo') {
        c.kodePembayaranVoucher = qr[1];
        Get.off(() => PaymentPointSaldo());
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
  }
}

void cekPembayaranVoucher(String kodeBayar) async {
  final c = Get.find<ApiService>();
  bool conn = await cekInternet();
  if (!conn) {
    return;
  }
  //BODY YANG DIKIRIM
  Box dbbox = Hive.box<String>('sasukaDB');
  var token = dbbox.get('token');
  var pid = dbbox.get('person_id');
  var user = dbbox.get('loginSebagai');

  var datarequest = '{"pid":"$pid","kodeBayar":"$kodeBayar"}';
  var bytes = utf8.encode(datarequest + '$token' + user);
  var signature = md5.convert(bytes).toString();

  var url = Uri.parse('${c.baseURL}/mobileApps/cekPembayaranVoucher');

  final response = await http.post(url, body: {
    "user": user,
    "appid": c.appid,
    "data_request": datarequest,
    "sign": signature,
  });
  //print(response.body);

  // EasyLoading.dismiss();
  if (response.statusCode == 200) {
    Map<String, dynamic> hasil = jsonDecode(response.body);
    if (hasil['status'] == 'success') {
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
}
