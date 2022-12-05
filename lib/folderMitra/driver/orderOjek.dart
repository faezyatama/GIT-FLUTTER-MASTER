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
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import 'petaPengantaranOjek.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../../../folderUmum/chat/view/chatDetailPage.dart';

class OrderPengantaranOjek extends StatefulWidget {
  @override
  _OrderPengantaranOjekState createState() => _OrderPengantaranOjekState();
}

class _OrderPengantaranOjekState extends State<OrderPengantaranOjek> {
  final c = Get.find<ApiService>();
  Box dbbox = Hive.box<String>('sasukaDB');
  bool dataSiap = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var paginate = 0;
  var ratingOutlet = 5.0;
  Timer timer;
  var adaDataDitampilkan = 'blank';
  var tahap = ''.obs;
  var namaPemesan = ''.obs;
  var idchat = ''.obs;
  var foto = 'https://sasuka.online/sasuka.online/foto/no-avatar.png'.obs;
  var tujuan = ''.obs;
  var jemput = ''.obs;
  var pembayaranVia = ''.obs;
  var tarif = ''.obs;
  var buttonKonfirmasi = ''.obs;
  var tanggal = ''.obs;
  var rating = 5.0;

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
        title: Text('Pengantaran penumpang'),
        backgroundColor: Warna.warnautama,
      ),
      bottomNavigationBar: Obx(() => Container(
          margin: EdgeInsets.fromLTRB(22, 8, 22, 8),
          height: Get.height * 0.06,
          child: (c.buttonTerimaOrderKurir.value == true)
              ? RawMaterialButton(
                  onPressed: () {
                    c.buttonTerimaOrderKurir.value = false;
                    if (c.tahapanOjek.value == '1') {
                      driverMenujuKePenjemputan();
                    } else if (c.tahapanOjek.value == '2') {
                      sampaiDiLokasiPenjemputan();
                    } else if (c.tahapanOjek.value == '3') {
                      menujuLokasiTujuan();
                    } else if (c.tahapanOjek.value == '4') {
                      alertSelesaiPengantaran();
                    } else if (c.tahapanOjek.value == '5') {}
                  },
                  constraints: BoxConstraints(),
                  elevation: 1.0,
                  fillColor: Warna.warnautama,
                  child: Obx(() => Text(
                        c.keteranganButtonOjek.value,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      )),
                  padding: EdgeInsets.fromLTRB(22, 6, 22, 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(33)),
                  ),
                )
              : RawMaterialButton(
                  onPressed: () {
                    Get.snackbar('Menunggu...',
                        'Silahkan menuju lokasi untuk tahapan selanjutnya',
                        snackPosition: SnackPosition.BOTTOM);
                  },
                  constraints: BoxConstraints(),
                  elevation: 0.0,
                  fillColor: Colors.grey[300],
                  child: Obx(() => Text(
                        c.keteranganButtonOjek.value,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      )),
                  padding: EdgeInsets.fromLTRB(22, 6, 22, 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(33)),
                  ),
                ))),
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
              (adaDataDitampilkan == 'ada')
                  ? Container(
                      child: Column(
                      children: [
                        Container(
                          color: Colors.grey[200],
                          padding: EdgeInsets.fromLTRB(22, 22, 22, 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Kode Pengantaran',
                                    style: TextStyle(color: Warna.grey),
                                  ),
                                  Obx(() => Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            c.kodeTransaksiOjek.value,
                                            style: TextStyle(
                                                color: Warna.warnautama,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            tanggal.value,
                                            style: TextStyle(
                                                color: Warna.grey,
                                                fontSize: 11),
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.grey[200],
                          padding: EdgeInsets.fromLTRB(22, 0, 22, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Status',
                                    style: TextStyle(color: Warna.grey),
                                  ),
                                  SizedBox(
                                    width: Get.width * 0.6,
                                    child: Obx(() => Text(
                                          tahap.value,
                                          overflow: TextOverflow.clip,
                                          maxLines: 3,
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              color: Warna.grey, fontSize: 16),
                                        )),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 5, bottom: 11),
                          height: 7,
                          color: Colors.grey[200],
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(22, 0, 22, 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Obx(() => CircleAvatar(
                                      radius: Get.width * 0.1,
                                      backgroundImage:
                                          NetworkImage(foto.value))),
                                  SizedBox(
                                    width: Get.width * 0.65,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Nama Pemesan :',
                                          style: TextStyle(
                                              color: Warna.grey, fontSize: 11),
                                        ),
                                        Obx(() => Text(
                                              namaPemesan.value,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: TextStyle(
                                                  color: Warna.grey,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500),
                                            )),
                                        Padding(
                                            padding: EdgeInsets.only(top: 11)),
                                        Text(
                                          'Lokasi Tujuan :',
                                          style: TextStyle(
                                              color: Warna.grey, fontSize: 11),
                                        ),
                                        Obx(() => Text(
                                              tujuan.value,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 4,
                                              style: TextStyle(
                                                  color: Warna.grey,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500),
                                            )),
                                        Padding(
                                            padding: EdgeInsets.only(top: 11)),
                                        Text(
                                          'Lokasi Penjemputan :',
                                          style: TextStyle(
                                              color: Warna.grey, fontSize: 11),
                                        ),
                                        Obx(() => Text(
                                              jemput.value,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 4,
                                              style: TextStyle(
                                                  color: Warna.grey,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500),
                                            )),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            RawMaterialButton(
                                              onPressed: () {
                                                Get.to(() => ChatDetailPage());
                                              },
                                              constraints: BoxConstraints(),
                                              elevation: 0,
                                              fillColor: Colors.green[800],
                                              child: Row(
                                                children: [
                                                  Icon(Icons.chat,
                                                      color: Colors.white,
                                                      size: 17),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 6)),
                                                  Text(
                                                    'Chat',
                                                    style: TextStyle(
                                                        color: Warna.putih,
                                                        fontSize: 16),
                                                  ),
                                                ],
                                              ),
                                              padding: EdgeInsets.fromLTRB(
                                                  14, 5, 14, 5),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(9)),
                                              ),
                                            ),
                                            RawMaterialButton(
                                              onPressed: () {
                                                Get.to(() =>
                                                    PetaPengantaranOjek());
                                              },
                                              constraints: BoxConstraints(),
                                              elevation: 0,
                                              fillColor: Colors.green[800],
                                              child: Row(
                                                children: [
                                                  Icon(Icons.map,
                                                      color: Colors.white,
                                                      size: 17),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 6)),
                                                  Text(
                                                    'Lihat peta',
                                                    style: TextStyle(
                                                        color: Warna.putih,
                                                        fontSize: 16),
                                                  ),
                                                ],
                                              ),
                                              padding: EdgeInsets.fromLTRB(
                                                  14, 5, 14, 5),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(9)),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 11, bottom: 11),
                          height: 7,
                          color: Colors.grey[200],
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(22, 0, 22, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Pembayaran via',
                                    style: TextStyle(color: Warna.grey),
                                  ),
                                  RawMaterialButton(
                                    onPressed: () {},
                                    constraints: BoxConstraints(),
                                    elevation: 0,
                                    fillColor: Colors.blue,
                                    child: Obx(() => Text(
                                          pembayaranVia.value,
                                          style: TextStyle(
                                              color: Warna.putih, fontSize: 16),
                                        )),
                                    padding: EdgeInsets.fromLTRB(14, 4, 14, 4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(9)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 7,
                          color: Colors.grey[200],
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(22, 0, 22, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tarif Pengantaran',
                                    style: TextStyle(color: Warna.grey),
                                  ),
                                  RawMaterialButton(
                                    onPressed: () {},
                                    constraints: BoxConstraints(),
                                    elevation: 0,
                                    fillColor: Colors.blue,
                                    child: Obx(() => Text(
                                          tarif.value,
                                          style: TextStyle(
                                              color: Warna.putih, fontSize: 16),
                                        )),
                                    padding: EdgeInsets.fromLTRB(14, 4, 14, 4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(9)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 7,
                          color: Colors.grey[200],
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(22, 11, 22, 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ))
                  : Container(),
              (adaDataDitampilkan == 'tidak')
                  ? Container(
                      padding: EdgeInsets.fromLTRB(22, 111, 22, 2),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'images/notrip.png',
                              width: Get.width * 0.6,
                            ),
                            Text(
                              'Sepertinya kamu belum memiliki order pengantaran penumpang saat ini',
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
    print('cekOrderBerlangsung-OrderOjek');

    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var kodetrx = c.kodeTransaksiOjek.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","kodetrx":"$kodetrx"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLdriver}/mobileAppsMitraDriver/DetailAntaranOjek');

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
        c.kodeTransaksiOjek.value = hasil['kodetrx'];
        tahap.value = hasil['tahap'];
        namaPemesan.value = hasil['namaPemesan'];
        foto.value = hasil['foto'];
        tujuan.value = hasil['tujuan'];
        jemput.value = hasil['jemput'];
        pembayaranVia.value = hasil['pembayaranVia'];
        tarif.value = hasil['tarif'];
        tanggal.value = hasil['tanggal'];
        c.idChatLawan.value = hasil['idchat'];
        c.namaChatLawan.value = hasil['namaPemesan'];
        c.fotoChatLawan.value = hasil['foto'];
        c.tahapanOjek.value = hasil['tahapanButton'];
        c.buttonTerimaOrderKurir.value = hasil['nextStep'];
        c.keteranganButtonOjek.value = hasil['textButton'];
        setState(() {
          // dataSiap = true;
          adaDataDitampilkan = 'ada';
        });
      } else {
        c.telahTerimaOrder.value = false;
        setState(() {
          adaDataDitampilkan = 'tidak';
        });
      }
    }
  }

  void alertSelesaiPengantaran() {
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
          Text('Selesai Pengantaran',
              style: TextStyle(
                  fontSize: 18,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w600)),
          Padding(padding: EdgeInsets.only(top: 16)),
          Text('Terima kasih telah mengantarkan pelanggan ke tempat tujuannya',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center),
          Text(
            'Berikan ratting kepada pelanggan yuk',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Warna.grey),
            textAlign: TextAlign.center,
          ),
          Padding(padding: EdgeInsets.only(top: 9)),
          SmoothStarRating(
              allowHalfRating: false,
              onRated: (v) {
                rating = v;
              },
              starCount: 5,
              rating: rating,
              size: 45.0,
              isReadOnly: false,
              color: Colors.green,
              borderColor: Colors.green,
              spacing: 0.0),
          Padding(padding: EdgeInsets.only(top: 16)),
          RawMaterialButton(
            constraints: BoxConstraints(minWidth: Get.width * 0.7),
            elevation: 1.0,
            fillColor: Warna.warnautama,
            child: Text(
              'Selesaikan Pengantaran',
              style: TextStyle(color: Warna.putih, fontSize: 14),
            ),
            padding: EdgeInsets.fromLTRB(18, 9, 18, 9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            onPressed: () {
              selesaikanPengantaran();
            },
          ),
        ],
      ),
    )..show();
  }

  void selesaikanPengantaran() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var kj = c.kodeTransaksiOjek.value;

    var datarequest = '{"pid":"$pid","kodetrx":"$kj","rating":"$rating"}';
    var user = dbbox.get('loginSebagai');

    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLdriver}/mobileAppsMitraDriver/SelesaikanPengantaranOjekViaDriver');

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
          dismissOnBackKeyPress: false,
          dismissOnTouchOutside: false,
          context: Get.context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'Pengantaran Selesai',
          desc: 'Pengantaran telah berhasil diselesaikan',
          btnCancelText: 'OK',
          btnCancelColor: Colors.green,
          btnCancelOnPress: () {
            Get.back();
            Get.back();
          },
        )..show();
      }
    }
  }

  updateState() async {
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
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {}
    }
  }

  void driverMenujuKePenjemputan() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var kj = c.kodeTransaksiOjek.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","kodetrx":"$kj"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLdriver}/mobileAppsMitraDriver/driverMenujuKePenjemputan');

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
        _onRefresh();
      } else if (hasil['status'] == 'expire') {
        AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.noHeader,
            animType: AnimType.scale,
            title: 'Pembatalan Order',
            desc:
                'Opps... sepertinya order ini telah dibatalkan oleh pelanggan, Order berikutnya akan segera datang, Segera buka order dan menerima pengantaran ya...',
            btnOkText: 'Tutup',
            btnOkOnPress: () {
              Get.back();
              Get.back();
            })
          ..show();
      }
    }
  }

  void sampaiDiLokasiPenjemputan() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var kj = c.kodeTransaksiOjek.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","kodetrx":"$kj"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLdriver}/mobileAppsMitraDriver/sampaiDiLokasiPenjemputan');

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
        _onRefresh();
      }
    }
  }

  void menujuLokasiTujuan() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var kj = c.kodeTransaksiOjek.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","kodetrx":"$kj"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLdriver}/mobileAppsMitraDriver/menujuLokasiTujuan');

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
        _onRefresh();
      }
    }
  }
}
