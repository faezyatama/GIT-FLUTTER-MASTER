import 'dart:convert';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
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

class LaporannOfflineMP extends StatefulWidget {
  @override
  _LaporannOfflineMPState createState() => _LaporannOfflineMPState();
}

class _LaporannOfflineMPState extends State<LaporannOfflineMP> {
  final c = Get.find<ApiService>();
  bool dataSiap = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var paginate = 0;
  var adaDataDitampilkan = 'blank';
  var tanggalView = 'Hari ini'.obs;
  var tanggalSend = 'Hari ini';
  var harian = '0,-'.obs;
  var bulanan = '0,-'.obs;

  @override
  void initState() {
    super.initState();
    cekLaporan();
  }

  void _onRefresh() async {
    // monitor network fetch
    paginate = 0;
    dataOrder = [];
    order = [];
    cekLaporan();
    if (mounted) setState(() {});
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    dataOrder = [];
    cekLaporan();
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(22, 11, 22, 22),
        height: Get.height * 0.17,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tanggal',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: Warna.grey),
                ),
                RawMaterialButton(
                  onPressed: () {
                    DatePicker.showDatePicker(context,
                        showTitleActions: true,
                        minTime: DateTime(2021, 1, 1),
                        maxTime: DateTime(2031, 12, 31), onChanged: (date) {
                      tanggalView.value =
                          '${date.day.toString()}-${date.month.toString()}-${date.year.toString()}';
                      tanggalSend =
                          '${date.year.toString()}-${date.month.toString()}-${date.day.toString()}';
                    }, onConfirm: (date) {
                      tanggalView.value =
                          '${date.day.toString()}-${date.month.toString()}-${date.year.toString()}';
                      tanggalSend =
                          '${date.year.toString()}-${date.month.toString()}-${date.day.toString()}';
                      _onRefresh();
                    }, currentTime: DateTime.now(), locale: LocaleType.id);
                  },
                  constraints: BoxConstraints(),
                  elevation: 1.0,
                  fillColor: Colors.green,
                  child: Obx(() => Text(
                        tanggalView.value,
                        style: TextStyle(color: Warna.putih, fontSize: 16),
                      )),
                  padding: EdgeInsets.fromLTRB(33, 5, 33, 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(9)),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pendapatan Harian',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: Warna.grey),
                ),
                Obx(() => Text(
                      harian.value,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w300,
                          color: Warna.grey),
                    ))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pendapatan Bulanan',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: Warna.grey),
                ),
                Obx(() => Text(
                      bulanan.value,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w300,
                          color: Warna.grey),
                    ))
              ],
            ),
          ],
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
                body = Text("Sepertinya semua produk telah ditampilkan");
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
                            'images/nopaket.png',
                            width: Get.width * 0.6,
                          ),
                          Text(
                            'Sepertinya belum ada transaksi di periode ini',
                            style: TextStyle(fontSize: 22, color: Colors.grey),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    )
                  : Container()
            ],
          )),
    );
  }

  cekLaporan() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var tanggal = tanggalSend;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","skip":"$paginate","tanggal":"$tanggal"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLmp}/mobileAppsOutlet/laporanOfflineMP');

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
        harian.value = hasil['harian'];
        bulanan.value = hasil['bulanan'];
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
          onTap: () {},
          child: Card(
              elevation: 0,
              child: Container(
                margin: EdgeInsets.all(11),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: Get.width * 0.6,
                            child: Text(
                              'Penjualan Offline', //name
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Warna.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300),
                            ),
                          ),
                          Divider(),
                          SizedBox(
                            width: Get.width * 0.6,
                            child: Text(
                              'KodeTrx : ${ord[0]}', //kategori
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
                              'Tanggal : ${ord[1]}', //deskripsi
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
                    ),
                    Text(
                      ord[2], //HARGA
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Warna.grey,
                          fontSize: 22,
                          fontWeight: FontWeight.w200),
                    ),
                  ],
                ),
              )),
        ),
      ));
    }
    return Column(children: order);
  }
}
