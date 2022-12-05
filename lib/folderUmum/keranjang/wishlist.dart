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
import '../freshmart/outletfreshmart.dart';
import '../marketplace/outletmarketplace.dart';
import '../samakan/outletmakan.dart';

class Wishllist extends StatefulWidget {
  @override
  _WishllistState createState() => _WishllistState();
}

class _WishllistState extends State<Wishllist> {
  final c = Get.find<ApiService>();
  bool dataSiap = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var paginate = 0;
  var nodata = false;

  @override
  void initState() {
    super.initState();
    cekWishListku();
  }

  void _onRefresh() async {
    // monitor network fetch

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    dataOrder = [];
    cekWishListku();
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
              body = Text("Sepertinya semua telah ditampilkan");
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
                          'images/nopaket.png',
                          width: Get.width * 0.65,
                        ),
                        Text(
                          'Sepertinya tidak ada produk di Wishlist kamu',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 22,
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  )
                : Container()
          ],
        ));
  }

  cekWishListku() async {
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

    var url = Uri.parse('${c.baseURL}/mobileApps/cekWishlist');

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
        child: RawMaterialButton(
            onPressed: () {
              if (ord[9] == 'buka') {
                if (ord[7] == 'Marketplace') {
                  c.idOutletpadakeranjangMP.value = '0';
                  c.jumlahItemMP.value = 0;
                  c.hargaKeranjangMP.value = 0;
                  c.jumlahBarangMP.value = 0;

                  c.keranjangMP.clear();
                  c.idOutletPilihanMP.value = ord[8].toString();
                  c.namaoutletpadakeranjangMP.value = 'dalam keranjangmu';

                  c.namaOutlet.value = ord[0];
                  c.namaPreview.value = ord[1];
                  c.gambarPreview.value = ord[2];
                  c.namaoutletPreview.value = ord[0];
                  c.hargaPreview.value = ord[3];
                  c.lokasiPreview.value = ord[4];
                  c.itemidPreview.value = ord[5];
                  c.deskripsiPreview.value = ord[6];
                  Get.to(() => DetailOtletMarketplace());
                } else if (ord[7] == 'Makanan') {
                  c.idOutletpadakeranjangMakan.value = '0';
                  c.jumlahItem.value = 0;
                  c.hargaKeranjang.value = 0;
                  c.keranjangMakan.clear();
                  c.idOutletPilihan.value = ord[8].toString();

                  c.namaoutletpadakeranjang.value = 'dalam keranjangmu';

                  c.namaOutlet.value = ord[0];
                  c.namaPreview.value = ord[1];
                  c.gambarPreview.value = ord[2];
                  c.namaoutletPreview.value = ord[0];
                  c.hargaPreview.value = ord[3];
                  c.lokasiPreview.value = ord[4];
                  c.itemidPreview.value = ord[5];
                  c.deskripsiPreview.value = ord[6];
                  Get.to(() => DetailOtletMakan());
                } else if (ord[7] == 'Freshmart') {
                  c.idOutletpadakeranjangFm.value = '0';
                  c.jumlahItemFm.value = 0;
                  c.hargaKeranjangFm.value = 0;
                  c.keranjangFm.clear();
                  c.idOutletPilihanFm.value = ord[8].toString();
                  c.namaOutletFm.value = ord[1];
                  c.namaoutletpadakeranjangFm.value = 'dalam keranjangmu';
                  c.namaOutlet.value = ord[0];
                  c.namaPreview.value = ord[1];
                  c.gambarPreview.value = ord[2];
                  c.namaoutletPreview.value = ord[0];
                  c.hargaPreview.value = ord[3];
                  c.lokasiPreview.value = ord[4];
                  c.itemidPreview.value = ord[5];
                  c.deskripsiPreview.value = ord[6];
                  Get.to(() => DetailOtletFreshmart());
                }
              } else {
                Get.snackbar('Outlet sedang Tutup',
                    'Maaf saat ini Outlet sedang tutup, kamu bisa mengeceknya beberapa saat kedepan');
              }
            },
            onLongPress: () {
              print('hapus wishlist');
              hapusWishList(ord[5]);
            },
            child: Container(
              margin: EdgeInsets.all(11),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      CachedNetworkImage(
                        imageUrl: ord[2],
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
                          ord[1], //nama produk
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Warna.grey,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(
                        width: Get.width * 0.6,
                        child: Text(
                          ord[3], //harga
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
                          ord[0], //kodetransaksi
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Warna.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        width: Get.width * 0.6,
                        child: Text(
                          'Lokasi : ${ord[4]}', //kodetransaksi
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
                          ord[6], //kode serah terima
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
      ));
    }
    return Column(children: order);
  }

  void hapusWishList(ord) {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: 'PERHATIAN !',
      desc: 'Apakah kamu benar akan menghapus produk ini dari Wishlist ?',
      btnCancelText: 'Ya, Hapus',
      btnCancelColor: Colors.amber,
      btnCancelOnPress: () {
        prosesHapusWishlist(ord);
      },
    )..show();
  }

  void prosesHapusWishlist(ord) async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');

    var datarequest = '{"pid":"$pid","idproduk":"$ord"}';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse('${c.baseURL}/sasuka/hapusWishlist');

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
        paginate = 0;
        if (mounted) {
          setState(() {
            dataOrder = [];
            order = [];
            cekWishListku();
          });
        }
      }
    }
  }
}
