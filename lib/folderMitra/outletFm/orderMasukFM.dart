import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
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

import 'detailPesananFM.dart';

class OrderMasukFM extends StatefulWidget {
  @override
  _OrderMasukFMState createState() => _OrderMasukFMState();
}

class _OrderMasukFMState extends State<OrderMasukFM> {
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
    paginate = 0;
    dataOrder = [];
    order = [];
    cekOrderBerlangsung();
    if (mounted) setState(() {});
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
                          'images/nofood.png',
                          width: Get.width * 0.6,
                        ),
                        Text(
                          'Sepertinya kamu belum memiliki pesanan terbaru',
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

    var url =
        Uri.parse('${c.baseURLfreshmart}/mobileAppsOutlet/listOrderMasukFM');

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
        //update jumlah orderan
        c.stMasukFM.value = hasil['masuk'];
        c.stProsesFM.value = hasil['proses'];
        c.stKirimFM.value = hasil['kirim'];

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
          child: Card(
              child: GestureDetector(
            onTap: () {
              Get.to(() => DetailBelanjaanFM(kodePesanan: ord[3]));
            },
            child: Container(
              margin: EdgeInsets.all(11),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: Get.width * 0.15,
                        child: CachedNetworkImage(
                            fit: BoxFit.fill,
                            imageUrl: ord[0],
                            errorWidget: (context, url, error) {
                              print(error);
                              return Icon(Icons.error);
                            }),
                      ),
                      Padding(padding: EdgeInsets.only(top: 11)),
                      Text('Pembayaran',
                          style: TextStyle(color: Warna.grey, fontSize: 9)),
                      RawMaterialButton(
                        onPressed: () {},
                        constraints: BoxConstraints(),
                        elevation: 1.0,
                        fillColor: Colors.green,
                        child: Text(
                          ord[5],
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
                  GestureDetector(
                    onTap: () {
                      Get.to(() => DetailBelanjaanFM(kodePesanan: ord[3]));
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nama Pemesan :',
                            style: TextStyle(color: Warna.grey, fontSize: 9)),
                        SizedBox(
                          width: Get.width * 0.6,
                          child: Text(
                            ord[2], //name
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Warna.grey,
                                fontSize: 18,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 11)),
                        Text('Kode Transaksi :',
                            style: TextStyle(color: Warna.grey, fontSize: 9)),
                        SizedBox(
                          width: Get.width * 0.6,
                          child: Text(
                            ord[3], //HARGA
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
                            'Tanggal : ${ord[4]}', //kategori
                            maxLines: 4,
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
                            'Expedisi : ${ord[1]}', //deskripsi
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
                  )
                ],
              ),
            ),
          )),
        ),
      ));
    }
    return Column(children: order);
  }
}
