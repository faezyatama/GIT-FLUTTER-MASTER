import 'dart:convert';
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

class NotifInfoSatuaja extends StatefulWidget {
  @override
  _NotifInfoSatuajaState createState() => _NotifInfoSatuajaState();
}

class _NotifInfoSatuajaState extends State<NotifInfoSatuaja> {
  final c = Get.find<ApiService>();
  bool dataSiap = false;
  bool nodata = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var paginate = 0;
  var adaDataDitampilkan = 'blank';
  @override
  void initState() {
    super.initState();
    cekNotifikasi();
  }

  void _onRefresh() async {
    // monitor network fetch

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    dataOrder = [];
    cekNotifikasi();
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
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
        onLoading: _onLoading,
        child: ListView(
          children: [
            (adaDataDitampilkan == 'ada') ? listdaftar() : Container(),
            (adaDataDitampilkan == 'tidak')
                ? Container(
                    padding: EdgeInsets.only(top: 55, left: 33, right: 33),
                    child: Column(
                      children: [
                        Image.asset(
                          'images/nonotif.png',
                          width: Get.width * 0.6,
                        ),
                        Text(
                          'Sepertinya belum ada pemberitahuan terbaru',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Warna.grey, fontSize: 22),
                        ),
                      ],
                    ),
                  )
                : Container()
          ],
        ));
  }

  cekNotifikasi() async {
    if (c.loginAsPenggunaKita.value != 'Member') {
      setState(() {
        nodata = true;
        adaDataDitampilkan = 'tidak';
      });
      return;
    }

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

    var url = Uri.parse('${c.baseURL}/mobileApps/cekNotifikasiSatuAja');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
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
            dataOrder = hasil['data'];
            if ((paginate == 1) && (dataOrder.length == 0)) {
              adaDataDitampilkan = 'tidak';
            } else {
              adaDataDitampilkan = 'ada';
            }
          });
        }
      } else if (hasil['status'] == 'no data') {
        setState(() {
          nodata = true;
          if ((paginate == 1) && (dataOrder.length == 0)) {
            adaDataDitampilkan = 'tidak';
          } else {
            adaDataDitampilkan = 'ada';
          }
        });
      }
    }
  }

  List dataOrder = [];
  List<Container> order = [];
  listdaftar() {
    for (var a = 0; a < dataOrder.length; a++) {
      var ord = dataOrder[a];

      order.add(Container(
        child: GestureDetector(
          onTap: () {},
          child: Card(
              child: Container(
            margin: EdgeInsets.all(11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Image.asset(
                      'images/${ord[5]}',
                      width: Get.width * 0.2,
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
                        ord[1], //judul
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Warna.grey,
                            fontSize: 18,
                            fontWeight: FontWeight.w300),
                      ),
                    ),
                    SizedBox(
                      width: Get.width * 0.6,
                      child: Text(
                        ord[2], //subjudul
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
                        ord[3], //pesan1
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
                        ord[4], //pesan2
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Warna.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w300),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 11)),
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
