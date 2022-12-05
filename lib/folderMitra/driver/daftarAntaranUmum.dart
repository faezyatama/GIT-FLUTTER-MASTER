//ROUTE SUDAH DIPERIKSA
import 'dart:async';
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as https;
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import 'DashboardUmum.dart';
import 'DetailPesananBarangUmum.dart';
import 'trackingUmum.dart';

import '../../../folderUmum/chat/view/chatDetailPage.dart';

class DaftarAntaranUmum extends StatefulWidget {
  @override
  _DaftarAntaranUmumState createState() => _DaftarAntaranUmumState();
}

class _DaftarAntaranUmumState extends State<DaftarAntaranUmum> {
  final c = Get.find<ApiService>();
  Box dbbox = Hive.box<String>('sasukaDB');
  bool dataSiap = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var paginate = 0;
  var ratingOutlet = 5.0;
  Timer timer;
  var adaDataDitampilkan = 'blank';
  var kodeTransaksi = ''.obs;
  var tahapan = ''.obs;
  var keteranganButton = ''.obs;
  var responseData = '';
  @override
  void initState() {
    super.initState();
    cekOrderBerlangsung();
    timer = Timer.periodic(
        Duration(seconds: 10), (Timer t) => cekOrderBerlangsung());
  }

  void _onRefresh() async {
    // monitor network fetch
    paginate = 0;
    dataOrder.value = [];
    order = [];
    responseData = '';

    cekOrderBerlangsung();
    // if failed,use refreshFailed()
    if (mounted) {
      setState(() {
        _refreshController.refreshCompleted();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Antaran Berlangsung'),
        backgroundColor: Warna.warnautama,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.shopping_cart)),
          GestureDetector(
            onTap: () {},
            child: Center(
              child: Obx(() => Text(
                    c.antaranIntegrasi.value.toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w300),
                  )),
            ),
          ),
          Padding(padding: EdgeInsets.all(8))
        ],
      ),
      bottomNavigationBar: Obx(() => Container(
            margin: EdgeInsets.fromLTRB(22, 8, 22, 8),
            height: Get.height * 0.06,
            child: (c.buttonTerimaOrderKurir.value == true)
                ? RawMaterialButton(
                    onPressed: () {
                      if (tahapan.value == '2') {
                        kurirMenujuKeOutlet();
                      } else if (tahapan.value == '3') {
                        alertMenungguOutletProses('Menunggu Proses Outlet',
                            'Saat ini Outlet belum konfirmasi tahapan order, Bila kamu sudah di outlet, minta Outlet untuk konfirmasi tahapan selanjutnya proses pesanan');
                      } else if (tahapan.value == '4') {
                        alertMenungguOutletProses('Menunggu Proses Outlet',
                            'Saat ini Outlet belum konfirmasi tahapan order, Bila kamu sudah di outlet, minta Outlet untuk konfirmasi tahapan selanjutnya proses pesanan');
                      } else if (tahapan.value == '5') {
                        serahkanBarangKeKonsumen();
                      } else if (tahapan.value == '6') {
                        AwesomeDialog(
                          context: Get.context,
                          dialogType: DialogType.noHeader,
                          animType: AnimType.rightSlide,
                          dismissOnBackKeyPress: false,
                          dismissOnTouchOutside: false,
                          title: 'PESANAN TELAH SELESAI',
                          desc:
                              'Terima kasih telah mengantar pesanan ini sampai di tujuan',
                          btnCancelText: 'Siap',
                          btnCancelColor: Colors.green,
                          btnCancelOnPress: () {
                            Get.back();
                          },
                        )..show();
                      }
                    },
                    constraints: BoxConstraints(),
                    elevation: 1.0,
                    fillColor: Warna.warnautama,
                    child: Obx(() => Text(
                          keteranganButton.value,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        )),
                    padding: EdgeInsets.fromLTRB(22, 6, 22, 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(33)),
                    ),
                  )
                : Center(),
          )),
      body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: WaterDropHeader(),
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
          //onLoading: _onLoading,
          child: ListView(
            children: [
              (adaDataDitampilkan == 'ada') ? listdaftar() : Container(),
              (adaDataDitampilkan == 'tidak')
                  ? Container(
                      padding: EdgeInsets.fromLTRB(22, 111, 22, 2),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'images/nopaket.png',
                              width: Get.width * 0.6,
                            ),
                            Text(
                              'Sepertinya kamu belum memiliki daftar barang yang perlu diantar ke pelanggan',
                              style:
                                  TextStyle(fontSize: 22, color: Colors.grey),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    )
                  : Container()
            ],
          )),
    );
  }

  cekOrderBerlangsung() async {
    // print('cek order berlangsung');
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var kodeJual = c.kodeJualPengantaranDriver.value;
    var user = dbbox.get('loginSebagai');

    //print(kodeJual);
    var datarequest =
        '{"pid":"$pid","skip":"$paginate","kodeJual":"$kodeJual"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLdriver}/mobileAppsMitraDriver/AntaranKurirUmum');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    // EasyLoading.dismiss();
    print(response.body);
    paginate++;
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        c.telahTerimaOrder.value = true;
        if (responseData != response.body) {
          if (mounted) {
            setState(() {
              dataSiap = true;
              dataOrder.value = hasil['data'];
              kodeTransaksi.value = hasil['kodetrx'];
              c.kodeTransaksiKurirUmum.value = hasil['kodetrx'];
              tahapan.value = hasil['tahapan'];

              //keterangan button
              if (tahapan.value == '2') {
                keteranganButton.value = 'Menuju ke Outlet'; //merubah menjadi 3
              } else if (tahapan.value == '3') {
                keteranganButton.value = 'Menunggu Outlet Memproses';
              } else if (tahapan.value == '4') {
                keteranganButton.value = 'Menunggu Serahterima dari Outlet';
              } else if (tahapan.value == '5') {
                keteranganButton.value = 'Selesaikan Pesanan';
              } else if (tahapan.value == '6') {
                keteranganButton.value = 'Pesanan telah Selesai';
              }

              c.antaranIntegrasi.value = dataOrder.length;
              if ((paginate == 1) && (dataOrder.length == 0)) {
                adaDataDitampilkan = 'tidak';
                c.buttonTerimaOrderKurir.value = false;
                c.telahTerimaOrder.value = false;
              } else {
                adaDataDitampilkan = 'ada';
                c.telahTerimaOrder.value = true;
                c.buttonTerimaOrderKurir.value = true;
              }
            });
          }
        }
        responseData = response.body;
      } else {
        c.buttonTerimaOrderKurir.value = false;
        c.antaranIntegrasi.value = 0;
        setState(() {
          adaDataDitampilkan = 'tidak';
        });
        Get.back();
      }
    }
  }

  var dataOrder = [].obs;
  List<Container> order = [];

  listdaftar() {
    order = [];
    for (var a = 0; a < dataOrder.length; a++) {
      var ord = dataOrder[a];

      order.add(Container(
        child: Container(
            child: Container(
          margin: EdgeInsets.all(11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Padding(padding: EdgeInsets.all(11)),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 35.0,
                        backgroundImage: NetworkImage(ord[9]),
                        backgroundColor: Colors.transparent,
                      ),
                      Padding(padding: EdgeInsets.all(5)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pembelanjaan pada Outlet :',
                            style: TextStyle(
                              color: Warna.grey,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            width: Get.width * 0.6,
                            child: Text(
                              ord[3], //warung
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Warna.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          SizedBox(
                            width: Get.width * 0.6,
                            child: Text(
                              ord[16], //alamat
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Warna.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300),
                            ),
                          ),
                          SizedBox(
                            width: Get.width * 0.6,
                            child: Text(
                              ord[17], //kabupaten
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Warna.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 35.0,
                        backgroundImage: NetworkImage(ord[18]),
                        backgroundColor: Colors.transparent,
                      ),
                      Padding(padding: EdgeInsets.all(7)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pemesan :',
                            style: TextStyle(
                              color: Warna.grey,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            width: Get.width * 0.6,
                            child: Text(
                              ord[0], //pemesan
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Warna.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(left: 12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: Get.width * 0.6,
                    child: Obx(() => Text(
                          dataOrder[a][5], // status kurir
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Warna.warnautama,
                              fontSize: 16,
                              fontWeight: FontWeight.w300),
                        )),
                  ),
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          RawMaterialButton(
                            onPressed: () {
                              c.idChatLawan.value = ord[12];
                              c.namaChatLawan.value = ord[0];
                              c.fotoChatLawan.value = ord[18];
                              Get.to(() => ChatDetailPage());
                            },
                            constraints: BoxConstraints(),
                            elevation: 1.0,
                            fillColor: Colors.indigo,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.chat_bubble,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                Text(
                                  ' Chat',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                )
                              ],
                            ),
                            padding: EdgeInsets.fromLTRB(7, 4, 7, 4),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(9)),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(left: 2)),
                          (dataOrder[a][14] == true)
                              ? RawMaterialButton(
                                  onPressed: () {
                                    serahkanBarangKeKonsumen();
                                  },
                                  constraints: BoxConstraints(),
                                  elevation: 1.0,
                                  fillColor: Colors.green,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        'Serahkan Barang',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 11),
                                      )
                                    ],
                                  ),
                                  padding: EdgeInsets.fromLTRB(7, 4, 7, 4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(9)),
                                  ),
                                )
                              : Container(),
                          Padding(padding: EdgeInsets.only(left: 3)),
                          RawMaterialButton(
                            onPressed: () {
                              Get.to(() => DaftarPesananDriverUmum(
                                    kodePesanan: ord[2],
                                  ));
                            },
                            constraints: BoxConstraints(),
                            elevation: 1.0,
                            fillColor: Warna.warnautama,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.shopping_cart,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                Text(
                                  ' Detail',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                )
                              ],
                            ),
                            padding: EdgeInsets.fromLTRB(7, 4, 7, 4),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(9)),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(left: 6)),
                          Padding(padding: EdgeInsets.only(left: 6)),
                          RawMaterialButton(
                            onPressed: () {
                              c.kodeTransaksiKurirUmum.value = ord[2];
                              Get.to(() => PetaKurirUmum());
                            },
                            constraints: BoxConstraints(),
                            elevation: 1.0,
                            fillColor: Colors.green[700],
                            child: Row(
                              children: [
                                Icon(
                                  Icons.map,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                Text(
                                  ' Peta',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                )
                              ],
                            ),
                            padding: EdgeInsets.fromLTRB(7, 4, 7, 4),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(9)),
                            ),
                          ),
                        ],
                      )),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nomor Transaksi  ',
                        style: TextStyle(
                          color: Warna.grey,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        ord[2], //NOMOR TRANSAKSI
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Warna.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tanggal Transaksi ',
                        style: TextStyle(
                          color: Warna.grey,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        ord[4], //tanggal
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Warna.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Metode Pembayaran ',
                        style: TextStyle(
                          color: Warna.grey,
                          fontSize: 14,
                        ),
                      ),
                      RawMaterialButton(
                        onPressed: () {},
                        constraints: BoxConstraints(),
                        elevation: 0.0,
                        fillColor: Colors.green,
                        child: Text(
                          ord[7],
                          style: TextStyle(
                              color: Warna.putih, fontWeight: FontWeight.w600),
                        ),
                        padding: EdgeInsets.fromLTRB(18, 11, 18, 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9)),
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                ],
              )
            ],
          ),
        )),
      ));
    }
    return Column(children: order);
  }

  void serahkanBarangKeKonsumen() {
    final controllerKode = TextEditingController();
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Image.asset(
            'images/secure.png',
            width: Get.width * 0.3,
          ),
          Text('Penyerahan Barang',
              style: TextStyle(
                  fontSize: 18,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w600)),
          Padding(padding: EdgeInsets.only(top: 16)),
          Text(
              'Untuk menyelesaikan order ini silahkan masukan Kode Serah Terima',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center),
          Text(
            'Silahkan minta kode serah terima dari Konsumen',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Warna.grey),
            textAlign: TextAlign.center,
          ),
          Padding(padding: EdgeInsets.only(top: 9)),
          Padding(padding: EdgeInsets.only(top: 16)),
          Container(
            width: Get.width * 0.7,
            child: TextField(
              textAlign: TextAlign.center,
              maxLength: 5,
              style: TextStyle(
                  fontSize: 25, fontWeight: FontWeight.w600, color: Warna.grey),
              controller: controllerKode,
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
              'Serahkan Barang',
              style: TextStyle(color: Warna.putih, fontSize: 14),
            ),
            padding: EdgeInsets.fromLTRB(18, 9, 18, 9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            onPressed: () {
              if ((controllerKode.text == '') ||
                  (controllerKode.text.length != 5)) {
                controllerKode.text = '';
                Get.back();
                AwesomeDialog(
                  context: Get.context,
                  dialogType: DialogType.noHeader,
                  animType: AnimType.rightSlide,
                  title: 'PERHATIAN !',
                  desc:
                      'Kode tidak dimasukan dengan benar, Kode hanya berisi 5 angka',
                  btnCancelText: 'OK',
                  btnCancelColor: Colors.amber,
                  btnCancelOnPress: () {},
                )..show();
              } else {
                selesaikanPengantaran(controllerKode.text);
              }
            },
          ),
        ],
      ),
    )..show();
  }

  void selesaikanPengantaran(String kodeST) async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var kodetrx = kodeTransaksi.value;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","kodetrx":"$kodetrx","kodeSerahTerima":"$kodeST"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLdriver}/mobileAppsMitraDriver/SelesaikanPengantaranViaKurirUmum');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    // EasyLoading.dismiss();
    print(response.body);

    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        c.telahTerimaOrder.value = false;
        AwesomeDialog(
          context: Get.context,
          dismissOnBackKeyPress: false,
          dismissOnTouchOutside: false,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'Pengantaran Selesai',
          desc: 'Pengantaran telah berhasil diselesaikan',
          btnCancelText: 'OK',
          btnCancelColor: Colors.green,
          btnCancelOnPress: () {
            Get.back();
            Get.back();
            Get.back();
            Get.to(() => DashboardDriverUmum());
          },
        )..show();
      } else if (hasil['status'] == 'kode salah') {
        Get.back();
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: 'Kode Salah',
          desc: 'Opps... sepertinya kamu memasukan kode yang salah',
          btnCancelText: 'OK',
          btnCancelColor: Colors.red,
          btnCancelOnPress: () {},
        )..show();
      }
    }
  }

  updateState() async {
    //  print('update state');
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    if (c.timerDaftarAntaranIntegrasi.value == false) {
      return;
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","skip":"$paginate"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLdriver}/mobileAppsMitraDriver/AntaranKurirStatusUmum');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    // EasyLoading.dismiss();
    //print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        if (mounted) {
          if (c.antaranIntegrasi.value == dataOrder.length) {
            dataOrder.value = hasil['data'];
          } else {
            _onRefresh();
          }
        }
      }
    }
  }

  void kurirMenujuKeOutlet() async {
    // print('kurir menuju outlet');
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var kj = kodeTransaksi.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","kodetrx":"$kj"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLdriver}/mobileAppsMitraDriver/kurirMenujuKeOutlet');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        _onRefresh();
      }
    }
  }

  void alertMenungguOutletProses(String headerss, String isi) {
    AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.warning,
        animType: AnimType.rightSlide,
        title: headerss,
        desc: isi,
        btnOkText: 'Ok',
        btnOkColor: Colors.amber)
      ..show();
  }
}
