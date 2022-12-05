//ROUTE SUDA DIPERIKSA
import 'dart:async';
import 'dart:convert';
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

import 'DetailPesananBarang.dart';

class RiwayatAntaran extends StatefulWidget {
  @override
  _RiwayatAntaranState createState() => _RiwayatAntaranState();
}

class _RiwayatAntaranState extends State<RiwayatAntaran> {
  final c = Get.find<ApiService>();
  Box dbbox = Hive.box<String>('sasukaDB');
  bool dataSiap = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var paginate = 0;
  var ratingOutlet = 5.0;
  Timer timer;
  var adaDataDitampilkan = 'blank';

  @override
  void initState() {
    super.initState();
    cekRiwayat();
  }

  void _onRefresh() async {
    // monitor network fetch
    paginate = 0;
    dataOrder.value = [];
    order = [];
    cekRiwayat();
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
        title: Text('Riwayat Pengantaran Pesanan'),
        backgroundColor: Warna.warnautama,
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

  cekRiwayat() async {
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
        '${c.baseURLdriver}/mobileAppsMitraDriver/AntaranKurirHistory');

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
        child: InkWell(
          onTap: () {
            Get.to(() => DaftarPesananDriver(
                  kodePesanan: ord[2],
                ));
          },
          child: Card(
              child: Container(
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
                  ],
                ),
                Padding(padding: EdgeInsets.only(left: 12)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Padding(padding: EdgeInsets.only(left: 12)),
                    SizedBox(
                      width: Get.width * 0.6,
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
                  ],
                )
              ],
            ),
          )),
        ),
      ));
    }
    return Column(children: order);
  }
}
