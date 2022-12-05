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
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../../../../folderUmum/chat/view/chatDetailPage.dart';
import 'DetailPesananBarang.dart';
import 'DetailPesananBarangTS.dart';
import 'trackingIntegrasi.dart';

class DaftarAntaran extends StatefulWidget {
  @override
  _DaftarAntaranState createState() => _DaftarAntaranState();
}

class _DaftarAntaranState extends State<DaftarAntaran> {
  final c = Get.find<ApiService>();
  Box dbbox = Hive.box<String>('sasukaDB');
  bool dataSiap = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var paginate = 0;
  var ratingOutlet = 5.0;
  Timer timer;
  var adaDataDitampilkan = 'blank';
  var responseBody = '';

  @override
  void initState() {
    super.initState();
    cekOrderBerlangsung();
    timer = Timer.periodic(Duration(seconds: 15), (Timer t) => updateState());
  }

  void _onRefresh() async {
    // monitor network fetch
    paginate = 0;
    dataOrder.value = [];
    order = [];
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
        title: Text('Daftar Antaran'),
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
          GestureDetector(
            onTap: () {},
            child: Center(
              child: Text(
                ' Antaran',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w300),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.all(8))
        ],
      ),
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
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","skip":"$paginate"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLdriver}/mobileAppsMitraDriver/AntaranKurirBerlangsung');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    print(response.body);
    paginate++;
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        if (mounted) {
          setState(() {
            dataSiap = true;
            dataOrder.value = hasil['data'];
            c.antaranIntegrasi.value = dataOrder.length;
            if ((paginate == 1) && (dataOrder.length == 0)) {
              adaDataDitampilkan = 'tidak';
            } else {
              adaDataDitampilkan = 'ada';
            }
          });
        }
      } else {
        setState(() {
          adaDataDitampilkan = 'tidak';
        });
      }
    }
  }

  var dataOrder = [].obs;
  List<Container> order = [];

  listdaftar() {
    for (var a = 0; a < dataOrder.length; a++) {
      var ord = dataOrder[a];

      order.add(Container(
        child: Card(
            child: Container(
          margin: EdgeInsets.all(11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  // CachedNetworkImage(
                  //   imageUrl: ord[9],
                  //   width: Get.width * 0.23,
                  //   height: Get.width * 0.23,
                  // ),
                  RawMaterialButton(
                    onPressed: () {},
                    constraints: BoxConstraints(),
                    elevation: 1.0,
                    fillColor: Colors.green,
                    child: Column(
                      children: [
                        Text(
                          'Pembayaran :',
                          style: TextStyle(color: Warna.putih, fontSize: 9),
                        ),
                        Text(
                          ord[7],
                          style: TextStyle(color: Warna.putih),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(7, 2, 7, 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                    ),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(left: 12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nama Pemesan :',
                    style: TextStyle(color: Colors.grey, fontSize: 9),
                  ),
                  SizedBox(
                    width: Get.width * 0.6,
                    child: Text(
                      ord[0], //NAMA OUTLET
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Warna.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.w300),
                    ),
                  ),
                  Text(
                    'Harga Pesanan :',
                    style: TextStyle(color: Colors.grey, fontSize: 9),
                  ),
                  SizedBox(
                    width: Get.width * 0.6,
                    child: Text(
                      ord[1], //HARGA
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Warna.grey,
                          fontSize: 22,
                          fontWeight: FontWeight.w200),
                    ),
                  ),
                  Divider(),
                  SizedBox(
                    width: Get.width * 0.6,
                    child: Text(
                      'No.Trx : ${ord[2]}', //kodetransaksi
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
                      ord[3], //kode serah terima
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
                      ord[4], // tanggal
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Warna.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w300),
                    ),
                  ),
                  Divider(),
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
                  SizedBox(
                    width: Get.width * 0.6,
                    child: Text(
                      ord[8], // status kurir
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Warna.warnautama,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Obx(() => Row(
                        children: [
                          Padding(padding: EdgeInsets.only(left: 2)),
                          (dataOrder[a][14] == true)
                              ? RawMaterialButton(
                                  onPressed: () {
                                    alertPesananSelesai('${ord[2]}');
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
                              if (ord[10] == 'tokosekitar') {
                                Get.to(() => DaftarPesananTS(
                                      kodePesanan: ord[2],
                                    ));
                              } else {
                                Get.to(() => DaftarPesananDriver(
                                      kodePesanan: ord[2],
                                    ));
                              }
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
                          RawMaterialButton(
                            onPressed: () {
                              c.idChatLawan.value = ord[12];
                              c.namaChatLawan.value = ord[0];
                              c.fotoChatLawan.value = ord[9];
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
                          Padding(padding: EdgeInsets.only(left: 6)),
                          RawMaterialButton(
                            onPressed: () {
                              c.kodeTransaksiIntegrasi.value = ord[2];
                              Get.to(() => TrackingIntegrasi());
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
                      ))
                ],
              )
            ],
          ),
        )),
      ));
    }
    return Column(children: order);
  }

  void alertPesananSelesai(kode) {
    var rating = 0.0;
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Image.asset(
            'images/whitelabelRegister/d.png',
            width: Get.width * 0.5,
          ),
          Text('Barang Diterima',
              style: TextStyle(
                  fontSize: 18,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w600)),
          Text(
              'Terima kasih telah memesan makanan bersama kami, Tolong berikan penilaian atas pelayanan kami',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center),
          Padding(padding: EdgeInsets.only(top: 9)),
          SmoothStarRating(
              allowHalfRating: false,
              color: Colors.amber,
              borderColor: Colors.amber,
              onRated: (v) {
                ratingOutlet = v;
              },
              rating: rating,
              isReadOnly: false,
              filledIconData: Icons.star,
              halfFilledIconData: Icons.star_half,
              defaultIconData: Icons.star_border,
              starCount: 5,
              spacing: 0.0),
          Padding(padding: EdgeInsets.only(top: 9)),
          RawMaterialButton(
            onPressed: () {
              pesananSelesai(kode);
              Get.back();
            },
            constraints: BoxConstraints(),
            elevation: 1.0,
            fillColor: Warna.warnautama,
            child: Text(
              'Pesanan Sudah Sesuai',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Warna.putih),
            ),
            padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(33)),
            ),
          ),
        ],
      ),
    )..show();
  }

  void pesananSelesai(kode) async {
    var cekin = await cekInternet();
    if (cekin == true) {
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');
      var kodetrx = kode;
      var v = ratingOutlet;
      var user = dbbox.get('loginSebagai');

      var datarequest = '{"pid":"$pid","kodetrx":"$kodetrx","rating":"$v"}';
      var bytes = utf8.encode(datarequest + '$token' + user);
      var signature = md5.convert(bytes).toString();

      var url = Uri.parse(
          '${c.baseURLdriver}/mobileAppsMitraDriver/pesananSelesaiUserMakan');

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
          if (mounted) {
            Get.back();
          }
        } else if (hasil['status'] == 'failed') {
          AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.warning,
            animType: AnimType.rightSlide,
            title: 'PERHATIAN !',
            desc: hasil['message'],
          )..show();
        }
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
        '${c.baseURLdriver}/mobileAppsMitraDriver/AntaranKurirBerlangsung');

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
        if (responseBody != response.body) {
          if (mounted) {
            if (c.antaranIntegrasi.value == dataOrder.length) {
              dataOrder.value = hasil['data'];
            } else {
              _onRefresh();
            }
          }
        }
        responseBody = response.body;
      }
    }
  }
}
