import 'dart:convert';
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

import '../motor/trackingdriver.dart';

class AntaranBerlangsung extends StatefulWidget {
  @override
  _AntaranBerlangsungState createState() => _AntaranBerlangsungState();
}

class _AntaranBerlangsungState extends State<AntaranBerlangsung> {
  final c = Get.find<ApiService>();
  bool dataSiap = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var paginate = 0;
  var adaDataDitampilkan = 'blank';

  @override
  void initState() {
    super.initState();
    cekOrderBerlangsung();
  }

  void _onRefresh() async {
    // monitor network fetch

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    dataOrder = [];
    cekOrderBerlangsung();
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
              body = Text("Sepertinya semua transaksi telah ditampilkan");
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
                    padding: EdgeInsets.fromLTRB(22, 63, 22, 2),
                    child: Column(
                      children: [
                        Image.asset(
                          'images/notrip.png',
                          width: Get.width * 0.6,
                        ),
                        Text(
                          'Sepertinya belum ada perjalanan yang berlangsung',
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
    var user = dbbox.get('loginSebagai');
    var datarequest = '{"pid":"$pid","skip":"$paginate"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();
    var url = Uri.parse('${c.baseURLdriver}/mobileAppsUser/AntaranBerlangsung');
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
          onTap: () {
            Get.to(() => TrackingDriverMotor());
          },
          child: Card(
              child: Container(
            margin: EdgeInsets.all(11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Image.asset(
                      ord[8],
                      width: Get.width * 0.2,
                    ),
                    RawMaterialButton(
                      onPressed: () {},
                      constraints: BoxConstraints(),
                      elevation: 1.0,
                      fillColor: Colors.green,
                      child: Text(
                        ord[0],
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
                      width: Get.width * 0.6,
                      child: Text(
                        ord[2], //sasuka motor
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
                        ord[4], //HARGA
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
                        'No.Transaksi : ${ord[1]}', //kodetransaksi
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
                        'Tanggal : ${ord[3]}', //kode serah terima
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Warna.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w300),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 11)),
                    SizedBox(
                      width: Get.width * 0.6,
                      child: Text(
                        'Dari :', // tanggal
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Warna.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.w300),
                      ),
                    ),
                    SizedBox(
                      width: Get.width * 0.6,
                      child: Text(
                        ord[6], // dari
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Warna.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w300),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 11)),
                    SizedBox(
                      width: Get.width * 0.6,
                      child: Text(
                        'Tujuan :', // tanggal
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Warna.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.w300),
                      ),
                    ),
                    SizedBox(
                      width: Get.width * 0.6,
                      child: Text(
                        ord[7], // dari
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
                      child: Text(
                        ord[5], // status kurir
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Warna.warnautama,
                            fontSize: 16,
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
