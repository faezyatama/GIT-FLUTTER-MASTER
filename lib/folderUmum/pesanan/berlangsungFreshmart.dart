import 'dart:async';
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as https;
import 'package:cached_network_image/cached_network_image.dart';
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
import '../freshmart/trackingdriver.dart';
import '../marketplace/trackingdriver.dart';
import 'detailBelanjaFreshmart.dart';
import '../samakan/trackingdriver.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../../../folderUmum/chat/view/chatDetailPage.dart';

class PesananBerlangsungFreshmart extends StatefulWidget {
  @override
  _PesananBerlangsungFreshmartState createState() =>
      _PesananBerlangsungFreshmartState();
}

class _PesananBerlangsungFreshmartState
    extends State<PesananBerlangsungFreshmart> {
  final c = Get.find<ApiService>();
  Box dbbox = Hive.box<String>('sasukaDB');
  bool dataSiap = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var paginate = 0;
  var ratingOutlet = 5.0;
  Timer timer;
  var adaDataDitampilkan = 'blank';
  var responseData = '';

  @override
  void initState() {
    super.initState();
    cekOrderBerlangsung();
    //  timer = Timer.periodic(
    //     Duration(seconds: 15), (Timer t) => cekOrderBerlangsung());
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
    return SmartRefresher(
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
                    padding: EdgeInsets.fromLTRB(22, 63, 22, 2),
                    child: Column(
                      children: [
                        Image.asset(
                          'images/nopaket.png',
                          width: Get.width * 0.6,
                        ),
                        Text(
                          'Sepertinya belum ada pesanan yang berlangsung',
                          style: TextStyle(fontSize: 22, color: Colors.grey),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  )
                : Container()
          ],
        ));
  }

  cekOrderBerlangsung() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var fitur = 'freshmart';
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","fitur":"$fitur","skip":"$paginate"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLfreshmart}/mobileAppsUser/pesananBerlangsungFreshmart');

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
        if (responseData != response.body) {
          if (mounted) {
            setState(() {
              dataSiap = true;
              dataOrder.value = hasil['data'];
              if ((paginate == 1) && (dataOrder.length == 0)) {
                adaDataDitampilkan = 'tidak';
              } else {
                adaDataDitampilkan = 'ada';
              }
            });
          }
        }

        responseData = response.body;
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
    order = [];

    for (var a = 0; a < dataOrder.length; a++) {
      var ord = dataOrder[a];

      order.add(Container(
        child: Card(
            child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(11),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      CachedNetworkImage(
                        imageUrl: ord[9],
                        width: Get.width * 0.23,
                        height: Get.width * 0.23,
                      ),
                      Divider(),
                      SizedBox(
                        width: Get.width * 0.23,
                        child: Text(
                          'Metode Pembayaran', //HARGA
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Warna.grey,
                              fontSize: 11,
                              fontWeight: FontWeight.w200),
                        ),
                      ),
                      RawMaterialButton(
                        onPressed: () {},
                        constraints: BoxConstraints(),
                        fillColor: Colors.green,
                        child: Text(
                          ord[7],
                          style: TextStyle(color: Warna.putih),
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
                      SizedBox(
                        width: Get.width * 0.55,
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
                      SizedBox(
                        width: Get.width * 0.55,
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
                        width: Get.width * 0.55,
                        child: Text(
                          'No.Transaksi : ${ord[2]}', //kodetransaksi
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Warna.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w300),
                        ),
                      ),
                      SizedBox(
                        width: Get.width * 0.55,
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
                        width: Get.width * 0.55,
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
                        width: Get.width * 0.55,
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
                        width: Get.width * 0.55,
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
                    ],
                  )
                ],
              ),
            ),
            Divider(),
            Obx(() => Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      (dataOrder[a][13] == true)
                          ? RawMaterialButton(
                              onPressed: () {
                                AwesomeDialog(
                                  context: Get.context,
                                  dialogType: DialogType.warning,
                                  animType: AnimType.rightSlide,
                                  title: 'Pembatalan Pesanan',
                                  desc:
                                      'Apakah kamu akan membatalkan pesanan ini ? Proses ini membutuhkan konfirmasi dari outlet untuk memastikan order belum diproses',
                                  btnCancelText: 'Iya Batalkan',
                                  btnCancelColor: Colors.amber,
                                  btnCancelOnPress: () {
                                    batalkanPesananini('${ord[2]}');
                                  },
                                )..show();
                              },
                              constraints: BoxConstraints(),
                              elevation: 1.0,
                              fillColor: Colors.redAccent,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.highlight_off,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'Batalkan',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 11),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.fromLTRB(7, 4, 7, 4),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(9)),
                              ),
                            )
                          : Padding(padding: EdgeInsets.only(left: 1)),
                      Padding(padding: EdgeInsets.only(left: 2)),
                      (dataOrder[a][14] == true)
                          ? RawMaterialButton(
                              onPressed: () {
                                if (ord[10] == 'freshmart') {
                                  alertPesananSelesaiFM('${ord[2]}');
                                } else {
                                  Get.snackbar(ord[10],
                                      'Maaf tidak dapat menyelesaikan transaksi ini, Hubungi Customer Support');
                                }
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
                                    'Terima',
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
                          Get.to(() => DetailBelanjaanFreshmart(
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
                              size: 14,
                              color: Colors.white,
                            ),
                            Text(
                              'Detail',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 11),
                            )
                          ],
                        ),
                        padding: EdgeInsets.fromLTRB(7, 4, 7, 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9)),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(left: 3)),
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
                              size: 14,
                              color: Colors.white,
                            ),
                            Text(
                              'Chat',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 11),
                            )
                          ],
                        ),
                        padding: EdgeInsets.fromLTRB(7, 4, 7, 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9)),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(left: 3)),
                      (ord[15] == true)
                          ? RawMaterialButton(
                              onPressed: () {
                                if (ord[10] == 'makanan') {
                                  c.kodetransaksimakan.value = ord[2];
                                  Get.to(() => TrackingDriver());
                                } else if (ord[10] == 'freshmart') {
                                  c.kodetransaksiFm.value = ord[2];
                                  Get.to(() => TrackingDriverFM());
                                } else if (ord[10] == 'marketplace') {
                                  c.kodetransaksiMP.value = ord[2];
                                  Get.to(() => TrackingDriverMP());
                                } else {
                                  Get.snackbar(ord[10],
                                      'Maaf tidak dapat melakukan tracking untuk transaksi ini');
                                }
                              },
                              constraints: BoxConstraints(),
                              elevation: 1.0,
                              fillColor: Colors.teal,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.map,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'Track',
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
                          : Container()
                    ],
                  ),
                ))
          ],
        )),
      ));
    }
    return Column(children: order);
  }

  void batalkanPesananini(String kodetrx) async {
    var cekin = await cekInternet();
    if (cekin == true) {
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');
      var user = dbbox.get('loginSebagai');

      var datarequest = '{"pid":"$pid","kodetrx":"$kodetrx"}';
      var bytes = utf8.encode(datarequest + '$token' + user);
      var signature = md5.convert(bytes).toString();

      var url =
          Uri.parse('${c.baseURLfreshmart}/mobileAppsUser/batalkanPesanan');

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
            Get.snackbar('Pembatalan', 'Pesanan kamu berhasil dibatalkan');

            _onRefresh();
          }
        } else if (hasil['status'] == 'failed') {
          Get.snackbar(
              'Pembatalan Gagal', 'Pesanan kamu tidak dapat dibatalkan');

          _onRefresh();
        }
      }
    }
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
            width: Get.width * 0.8,
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
          '${c.baseURLfreshmart}/mobileAppsUser/pesananSelesaiUserMakan');

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

  void alertPesananSelesaiFM(kode) {
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
            width: Get.width * 0.8,
          ),
          Padding(padding: EdgeInsets.only(top: 22)),
          Text('Barang Diterima',
              style: TextStyle(
                  fontSize: 18,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w600)),
          Text(
              'Terima kasih telah berbelanja freshmart bersama kami, Tolong berikan penilaian atas pelayanan kami',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center),
          Padding(padding: EdgeInsets.only(top: 9)),
          SmoothStarRating(
              allowHalfRating: false,
              size: 30,
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
              pesananSelesaiFM(kode);
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

  void pesananSelesaiFM(kode) async {
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
          '${c.baseURLfreshmart}/mobileAppsUser/pesananSelesaiUserFM');

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
          Get.snackbar('Pesanan Freshmart Selesai',
              'Terima kasih telah memesan produk freshmart bersama kami');

          if (mounted) {
            Get.back();
            _onRefresh();
          }
        } else if (hasil['status'] == 'reload') {
          if (mounted) {
            Get.back();
            _onRefresh();
          }
        } else if (hasil['status'] == 'failed') {
          AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.warning,
            animType: AnimType.rightSlide,
            title: 'PERHATIAN !',
            desc: hasil['message'],
          )..show();
          _onRefresh();
        }
      }
    }
  }

  updateState() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var fitur = 'freshmart';
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","fitur":"$fitur","skip":"$paginate"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLfreshmart}/mobileAppsUser/pesananBerlangsungFreshmart');

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
          dataOrder.value = hasil['data'];
        }
      }
    }
  }
}
