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
import 'tambahSupplier.dart';

class SupplierPOS extends StatefulWidget {
  @override
  _SupplierPOSState createState() => _SupplierPOSState();
}

class _SupplierPOSState extends State<SupplierPOS> {
  final c = Get.find<ApiService>();
  bool dataSiap = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var paginate = 0;
  var adaDataDitampilkan = 'blank';

  @override
  void initState() {
    super.initState();
    cekSupplier();
  }

  void _onRefresh() async {
    // monitor network fetch
    paginate = 0;
    dataSupplier = [];
    dijual = [];
    order = [];
    cekSupplier();
    if (mounted) setState(() {});
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    dataSupplier = [];
    cekSupplier();
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supplier'),
        backgroundColor: Colors.green,
        actions: [
          Container(
            margin: EdgeInsets.fromLTRB(1, 1, 11, 1),
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      Get.off(TambahSupplier());
                    },
                    icon: Icon(Icons.person_add, color: Colors.white)),
                GestureDetector(
                  onTap: () {
                    Get.off(TambahSupplier());
                  },
                  child: Text(
                    'Tambah',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          )
        ],
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
                            'images/nofood.png',
                            width: Get.width * 0.6,
                          ),
                          Text(
                            'Sepertinya kamu belum memiliki produk yang akan dijual',
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

  cekSupplier() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var fitur = 'Toko Sekitar';
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","fitur":"$fitur","skip":"$paginate"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLtokosekitar}/mobileAppsOutlet/cekSupplierTS');

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
            dataSupplier = hasil['data'];
            if ((paginate == 1) && (dataSupplier.length == 0)) {
              adaDataDitampilkan = 'tidak';
            } else {
              adaDataDitampilkan = 'ada';
            }
          });
        }
      } else if (hasil['status'] == 'no data') {
        setState(() {
          if ((paginate == 1) && (dataSupplier.length == 0)) {
            adaDataDitampilkan = 'tidak';
          } else {
            adaDataDitampilkan = 'ada';
          }
        });
      }
    }
  }

  List dataSupplier = [];
  List dijual = [].obs;
  List<Container> order = [];
  listdaftar() {
    for (var a = 0; a < dataSupplier.length; a++) {
      var ord = dataSupplier[a];

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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.0), //or 15.0
                      child: Container(
                          height: Get.width * 0.12,
                          width: Get.width * 0.12,
                          color: Color(0xffFF0E58),
                          child: Center(
                            child: Text(
                              '${ord[5]}',
                              style: (TextStyle(
                                  color: Colors.white, fontSize: 18)),
                            ),
                          )),
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.only(left: 12)),
                GestureDetector(
                  onTap: () {
                    c.pilihanSupplierTS.value = ord[1];
                    Get.back();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: Get.width * 0.55,
                        child: Text(
                          ord[1], //name
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Warna.grey,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        width: Get.width * 0.55,
                        child: Text(
                          ord[2], //HARGA
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Warna.grey,
                              fontSize: 15,
                              fontWeight: FontWeight.w200),
                        ),
                      ),
                      SizedBox(
                        width: Get.width * 0.55,
                        child: Text(
                          '${ord[3]}', //kategori
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Warna.grey,
                              fontSize: 15,
                              fontWeight: FontWeight.w300),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            color: Colors.green,
                            size: 18,
                          ),
                          SizedBox(
                            width: Get.width * 0.55,
                            child: Text(
                              '${ord[4]}', //deskripsi
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Warna.grey,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                    onPressed: () {
                      konfirmasiHapusSupplier(ord[0], ord[1]);
                    },
                    icon: Icon(Icons.delete),
                    color: Colors.grey),
              ],
            ),
          )),
        ),
      ));
    }
    return Column(children: order);
  }

  void konfirmasiHapusSupplier(idsupplier, namaSupplier) {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: 'Hapus Supplier',
      desc:
          'Apakah benar kamu akan menghapus supplier $namaSupplier dari daftar ini?',
      btnCancelText: 'Hapus',
      btnCancelColor: Colors.red,
      btnCancelOnPress: () {
        hapusSupplier(idsupplier);
      },
    )..show();
  }

  void hapusSupplier(idSupplier) async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var fitur = 'Toko Sekitar';

    //PARAMETER BUKA OUTLET
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","idSupplier":"$idSupplier","fitur":"$fitur"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLtokosekitar}/mobileAppsOutlet/hapusSupplierTS');

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
        Get.snackbar('Berhasil', hasil['message']);
        _onRefresh();
      } else {
        Get.snackbar('Gagal dihapus', hasil['message']);
        _onRefresh();
      }
    }
  }
}
