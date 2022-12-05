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
import 'tiket.dart';

class HistoryTiket extends StatefulWidget {
  @override
  _HistoryTiketState createState() => _HistoryTiketState();
}

class _HistoryTiketState extends State<HistoryTiket> {
  final c = Get.find<ApiService>();
  bool dataSiap = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var paginate = 0;

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
    return Scaffold(
      appBar: AppBar(title: Text('Pesanan Tiket')),
      bottomNavigationBar: Container(
        child: RawMaterialButton(
          onPressed: () {
            c.urlTiket.value = 'https://tiket-sasuka.com';
            Get.off(TiketSatuAja());
          },
          constraints: BoxConstraints(),
          elevation: 1.0,
          fillColor: Colors.blue,
          child: Text('Cari Tiket Baru',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          padding: EdgeInsets.fromLTRB(22, 11, 22, 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(33)),
          ),
        ),
      ),
      body: SmartRefresher(
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
              listdaftar(),
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

    var datarequest = '{"pid":"$pid","skip":"$paginate"}';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse('${c.baseURL}/sasuka/cekHistoryTiket');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    // EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        paginate++;
        if (mounted) {
          setState(() {
            dataSiap = true;
            dataOrder = hasil['transaksi'];
          });
        }
      } else if (hasil['status'] == 'no data') {}
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
            c.urlTiket.value = ord[5];
            Get.off(TiketSatuAja());
          },
          child: Card(
              child: Container(
            margin: EdgeInsets.all(11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Image.network(
                      ord[1],
                      width: Get.width * 0.2,
                    ),
                    RawMaterialButton(
                      onPressed: () {},
                      constraints: BoxConstraints(),
                      elevation: 1.0,
                      fillColor: Colors.green,
                      child: Text(
                        ord[2],
                        style: TextStyle(color: Warna.putih),
                      ),
                      padding: EdgeInsets.fromLTRB(7, 2, 7, 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                      ),
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.only(left: 11)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: Get.width * 0.6,
                      child: Text(
                        'Kode Booking', //sasuka motor
                        maxLines: 1,
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
                        ord[6], //HARGA
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Warna.grey,
                            fontSize: 22,
                            fontWeight: FontWeight.w200),
                      ),
                    ),
                    SizedBox(
                      width: Get.width * 0.6,
                      child: Text(
                        'Nama Penumpang : ${ord[0]}', //kodetransaksi
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
                        'Tanggal : ${ord[4]}', //kode serah terima
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
                        ord[3], // status kurir
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Warna.warnautama,
                            fontSize: 22,
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
