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
import '../freshmart/cekoutKeranjang.dart';
import '../marketplace/cekoutKeranjang.dart';
import '../samakan/cekoutKeranjang.dart';

class KeranjangDetail extends StatefulWidget {
  @override
  _KeranjangDetailState createState() => _KeranjangDetailState();
}

class _KeranjangDetailState extends State<KeranjangDetail> {
  final c = Get.find<ApiService>();
  bool dataSiap = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var paginate = 0;
  var nodata = false;
  var fitur = '';

  @override
  void initState() {
    super.initState();
    cekOrderBerlangsung();
  }

  void _onRefresh() async {
    // monitor network fetch

    // if failed,use refreshFailed()
    paginate = 0;
    dataOrder = [];
    order = [];
    cekOrderBerlangsung();
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
            listdaftar(),
            (nodata == true)
                ? Container(
                    padding: EdgeInsets.only(top: 55),
                    child: Column(
                      children: [
                        Image.asset(
                          'images/nocart.png',
                          width: Get.width * 0.6,
                        ),
                        Text(
                          'Sepertinya belum ada barang di keranjang kamu',
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

  cekOrderBerlangsung() async {
    if (c.loginAsPenggunaKita.value != 'Member') {
      setState(() {
        nodata = true;
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

    var url = Uri.parse('${c.baseURL}/mobileApps/keranjangku');

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
            dataOrder = hasil['data'];
            fitur = hasil['fitur'];
          });
        }
      } else if (hasil['status'] == 'no data') {
        setState(() {
          nodata = true;
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
        child: Card(
            child: Container(
          margin: EdgeInsets.all(11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  CachedNetworkImage(
                    imageUrl: ord[1],
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
                      ord[2], //NAMA OUTLET
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Warna.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(
                    width: Get.width * 0.6,
                    child: Text(
                      'Lokasi : ${ord[3]}', //kodetransaksi
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Warna.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w300),
                    ),
                  ),
                  Text(
                    ord[4], //HARGA
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Warna.grey,
                      fontSize: 18,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RawMaterialButton(
                        onPressed: () {
                          //buka atau tutup outletnya
                          if (ord[7] == 'buka') {
                            if (ord[6] == 'Makanan') {
                              c.keranjangMakan.value = ord[5];
                              Get.to(() => LokasidanKeranjangMK());
                            } else if (ord[6] == 'Sasuka Fresh Mart') {
                              c.keranjangFm.value = ord[5];
                              Get.to(() => LokasidanKeranjangFM());
                            } else if (ord[6] == 'Sasuka Mall') {
                              c.keranjangMP.value = ord[5];
                              Get.to(() => LokasidanKeranjangMP());
                            } else if (ord[6] == 'Marketplace') {
                              c.keranjangMP.value = ord[5];
                              Get.to(() => LokasidanKeranjangMP());
                            }
                          } else {
                            Get.snackbar('Outlet sedang Tutup',
                                'Maaf saat ini Outlet sedang tutup, kamu bisa mengeceknya beberapa saat kedepan');
                          }
                        },
                        constraints: BoxConstraints(),
                        elevation: 1.0,
                        fillColor: Colors.green,
                        child: Text(
                          'CekOut',
                          style: TextStyle(color: Warna.putih, fontSize: 12),
                        ),
                        padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9)),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(left: 22)),
                      RawMaterialButton(
                        onPressed: () {
                          hapusdarikeranjang(ord[0]);
                        },
                        constraints: BoxConstraints(),
                        elevation: 1.0,
                        fillColor: Colors.redAccent,
                        child: Text(
                          'Hapus',
                          style: TextStyle(color: Warna.putih, fontSize: 12),
                        ),
                        padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9)),
                        ),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        )),
      ));
    }
    return Column(children: order);
  }

  void hapusdarikeranjang(idoutlet) async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","idoutlet":"$idoutlet"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/hapusKeranjang');

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
        Get.snackbar(
            'Hapus Keranjang', 'Berhasil menghapus produk di keranjang belanja',
            colorText: Colors.white);
        dataOrder = [];
        order = [];
        cekOrderBerlangsung();
      }
    }
  }
}
