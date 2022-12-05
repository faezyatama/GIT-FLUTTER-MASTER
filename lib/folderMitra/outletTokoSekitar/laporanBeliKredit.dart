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
import 'package:date_ranger/date_ranger.dart';
import 'laporanBeliDetail.dart';

class LaporanBeliKredit extends StatefulWidget {
  @override
  _LaporanBeliKreditState createState() => _LaporanBeliKreditState();
}

class _LaporanBeliKreditState extends State<LaporanBeliKredit> {
  final c = Get.find<ApiService>();
  bool dataSiap = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var paginate = 0;
  var adaDataDitampilkan = 'blank';
  var rentangWaktu = 'Hari ini'.obs;
  var initialDate = DateTime.now();
  var initialDateRange =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());

  var harian = '0,-'.obs;
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
            Divider(),
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
                    pilihRentangWaktu();
                  },
                  constraints: BoxConstraints(),
                  elevation: 1.0,
                  fillColor: Colors.green,
                  child: Obx(() => Text(
                        rentangWaktu.value,
                        style: TextStyle(color: Warna.putih, fontSize: 16),
                      )),
                  padding: EdgeInsets.fromLTRB(22, 5, 22, 5),
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
                  'Total Pembelian Kredit',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: Warna.grey),
                ),
                Obx(() => Text(
                      harian.value,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
                            'images/nofreshmart.png',
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
    var tanggal = rentangWaktu.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","skip":"$paginate","tanggal":"$tanggal"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLtokosekitar}/mobileAppsOutlet/laporanPembelianKredit');

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
            c.kodePembelianTokoSekitar.value = ord[0];
            Get.to(() => LaporanDetailLunas());
          },
          child: Card(
              elevation: 0,
              child: Container(
                margin: EdgeInsets.all(11),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: Get.width * 0.55,
                            child: Text(
                              ord[3], //name
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Warna.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 7)),
                          SizedBox(
                            width: Get.width * 0.55,
                            child: Text(
                              '${ord[0]}', //kategori
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Warna.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300),
                            ),
                          ),
                          SizedBox(
                            width: Get.width * 0.55,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          ord[2], //HARGA
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Warna.grey,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Kredit', //HARGA
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.w200),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        ),
      ));
    }
    return Column(children: order);
  }

  void pilihRentangWaktu() {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: DateRanger(
          initialRange: initialDateRange,
          onRangeChanged: (range) {
            setState(() {
              initialDateRange = range;
              var dstart = initialDateRange.start.day.toString();
              var mstart = initialDateRange.start.month.toString();
              var ystart = initialDateRange.start.year.toString();
              var dend = initialDateRange.end.day.toString();
              var mend = initialDateRange.end.month.toString();
              var yend = initialDateRange.end.year.toString();
              rentangWaktu.value =
                  '$dstart-$mstart-$ystart s/d $dend-$mend-$yend';
            });
          },
        ),
      ),
      btnOkColor: Colors.green,
      btnOkText: 'Pilih tanggal ini',
      btnOkOnPress: () {
        _onRefresh();
      },
    )..show();
  }
}
