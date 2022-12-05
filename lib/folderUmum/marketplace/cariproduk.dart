import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:anim_search_bar/anim_search_bar.dart';
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
import 'outletmarketplace.dart';

class EtalaseMarketplace extends StatefulWidget {
  @override
  _EtalaseMarketplaceState createState() => _EtalaseMarketplaceState();
}

class _EtalaseMarketplaceState extends State<EtalaseMarketplace> {
  final c = Get.find<ApiService>();

  TextEditingController textController = TextEditingController();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var paginate = 0;
  var loaddata = false;
  var filtercari = '';
  var filterkategori = '';
  var loadkategori = '';

  @override
  void initState() {
    super.initState();
    cekDataBarang();
    referensiProduk();
  }

  void _onRefresh() async {
    listdatabarang = [];
    paginate = 0;
    // cekDataBarang();
    _refreshController.refreshCompleted();
  }

  void _onLoading() {
    // monitor network fetch
    // cekDataBarang();
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Marketplace'),
          backgroundColor: Warna.warnautama,
          actions: [
            AnimSearchBar(
              suffixIcon: Icon(
                Icons.search,
                color: Warna.warnautama,
              ),
              autoFocus: true,
              closeSearchOnSuffixTap: true,
              prefixIcon: Icon(
                Icons.search,
                color: Warna.warnautama,
              ),
              width: Get.width * 0.5,
              textController: textController,
              onSuffixTap: () {
                if (textController.text != '') {
                  paginate = 0;
                  filtercari = textController.text;
                  filterkategori = '';
                  listdatabarang = [];
                  cekDataBarang();
                  // print(textController.text);
                }
              },
            ),
          ],
        ),
        body: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            header: WaterDropHeader(
              waterDropColor: Warna.warnautama,
            ),
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
            child: ListView(children: [
              Container(
                padding: EdgeInsets.fromLTRB(22, 1, 22, 1),
                child: Text(
                  'Cari apa aja mudah disini kamu bisa mendapat barang kesukaan kamu',
                  style: TextStyle(
                      color: Warna.warnautama,
                      fontSize: 29,
                      fontWeight: FontWeight.w300),
                ),
              ),
              Column(
                children: (loaddata == true) ? listdaftar() : listdaftar(),
              )
            ])));
  }

  cekDataBarang() async {
    jsonDataBarang = [];
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var latitude = c.latitude.value;
    var longitude = c.longitude.value;

    var datarequest =
        '{"pid":"$pid","skip":"$paginate","cari":"$filtercari","kategori":"$filterkategori","lat":"$latitude","long":"$longitude","loadKategori":"$loadkategori"}';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse('${c.baseURL}/sasuka/cekProdukMarketplace');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    paginate++;

    // EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        if (mounted) {
          setState(() {
            loaddata = true;
            jsonDataBarang = hasil['data'];
            kategori = hasil['kategori'];
            loadkategori = 'sudah';
          });
        }
      }
    }
  }

  List kategori = [];
  List jsonDataBarang = [];
  List<Container> listdatabarang = [];
  List<Container> listKategori = [];
  List<Container> finalList = [];

  List jsonReff1 = [];
  var jsonKateg1 = '';
  List<Container> listReferensi1 = [];

  List jsonReff2 = [];
  var jsonKateg2 = '';
  List<Container> listReferensi2 = [];

  List jsonReff3 = [];
  var jsonKateg3 = '';
  List<Container> listReferensi3 = [];

  listdaftar() {
    if (jsonDataBarang.length > 0) {
      for (var i = 0; i < jsonDataBarang.length; i++) {
        var valHistory = jsonDataBarang[i];

        listdatabarang.add(
          Container(
              // width: Get.width * 0.45,
              child: GestureDetector(
            onTap: () {
              if (valHistory[9] == 'buka') {
                c.idOutletPilihanMP.value = valHistory[1].toString();

                if ((c.idOutletpadakeranjangMP.value ==
                        c.idOutletPilihanMP.value) ||
                    (c.idOutletpadakeranjangMP.value == '0')) {
                  c.namaOutletMP.value = valHistory[7];
                  c.tagIdMPC.value = valHistory[1].toString();
                  c.namaMPC.value = valHistory[2];
                  c.gambarMPC.value = valHistory[3];
                  c.namaoutletMPC.value = valHistory[7];
                  c.hargaMPC.value = valHistory[5];
                  c.lokasiMPC.value = valHistory[4];
                  c.deskripsiMPC.value = valHistory[10];
                  c.hargaIntMPC.value = valHistory[8];
                  c.idOutletMPC.value = valHistory[1].toString();
                  c.itemIdMPC.value = valHistory[11].toString();

                  Get.to(() => DetailOtletMarketplace());
                } else {
                  AwesomeDialog(
                    context: Get.context,
                    dialogType: DialogType.noHeader,
                    animType: AnimType.bottomSlide,
                    title: '',
                    desc: '',
                    body: Column(
                      children: [
                        Image.asset('images/nofood.png'),
                        Text('Pindah ke Otlet lain',
                            style: TextStyle(
                                fontSize: 20,
                                color: Warna.grey,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center),
                        Container(
                          padding: EdgeInsets.fromLTRB(22, 7, 22, 11),
                          child: Text(
                            'Sepertinya kamu ingin berpindah ke outlet lain, Boleh kok, keranjang di outlet sebelumnya kami hapus ya...',
                            style: TextStyle(fontSize: 14, color: Warna.grey),
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 16)),
                        Container(
                          padding: EdgeInsets.only(left: 22, right: 22),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: Text('Tidak jadi')),
                              ElevatedButton(
                                  onPressed: () {
                                    c.idOutletpadakeranjangMP.value = '0';
                                    c.jumlahItemMP.value = 0;
                                    c.hargaKeranjangMP.value = 0;
                                    c.keranjangMP.clear();
                                    c.idOutletPilihanMP.value =
                                        valHistory[1].toString();
                                    c.namaOutletMP.value = valHistory[7];
                                    c.namaoutletpadakeranjangMP.value =
                                        'dalam keranjangmu';
                                    c.namaPreviewFM.value = valHistory[2];
                                    c.gambarPreviewFM.value = valHistory[3];
                                    c.namaoutletPreviewFM.value = valHistory[7];
                                    c.hargaPreviewFM.value = valHistory[5];
                                    c.lokasiPreviewFM.value = valHistory[4];
                                    c.itemidPreviewFM.value = valHistory[10];
                                    c.deskripsiPreviewFM.value = valHistory[11];

                                    Get.off(DetailOtletFreshmart());
                                  },
                                  child: Text('Ok Ganti')),
                            ],
                          ),
                        )
                      ],
                    ),
                  )..show();
                }
              } else {
                Get.snackbar('Outlet Tutup',
                    'Sepertinya outlet ini sedang tutup, kunjungi beberapa saat lagi ya');
              }
            },
            child: Card(
                elevation: 1,
                //color: Colors.lightGreen[50],
                margin: EdgeInsets.all(5),
                child: Container(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      CachedNetworkImage(
                          width: Get.width * 0.35,
                          height: Get.width * 0.35,
                          imageUrl: valHistory[3],
                          errorWidget: (context, url, error) {
                            print(error);
                            return Icon(Icons.error);
                          }),
                      Padding(padding: EdgeInsets.only(left: Get.width * 0.01)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: Get.width * 0.5,
                            child: Text(
                              valHistory[2],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(fontSize: 19, color: Warna.grey),
                            ),
                          ),
                          SizedBox(
                            width: Get.width * 0.5,
                            child: Text(
                              valHistory[7],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(fontSize: 12, color: Warna.grey),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 22)),
                          Text(
                            valHistory[5],
                            style: TextStyle(
                                fontSize: 16,
                                color: Warna.grey,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(
                            width: Get.width * 0.35,
                            child: Text(
                              valHistory[4],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 10, color: Warna.grey),
                            ),
                          ),
                          Row(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    color: Warna.grey,
                                    size: 14,
                                  ),
                                  Padding(padding: EdgeInsets.only(left: 3)),
                                  Text(
                                    valHistory[6],
                                    style: TextStyle(
                                        fontSize: 10, color: Warna.grey),
                                  ),
                                ],
                              ),
                              Padding(padding: EdgeInsets.only(left: 11)),
                              Row(
                                children: [
                                  Icon(
                                    Icons.watch,
                                    color: Warna.grey,
                                    size: 11,
                                  ),
                                  Padding(padding: EdgeInsets.only(left: 3)),
                                  Text(
                                    valHistory[9],
                                    style: TextStyle(
                                        fontSize: 10, color: Warna.grey),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          )),
        );
      }
    }
    return listdatabarang;
  }

  listkategori() {
    if (kategori.length > 0) {
      for (var i = 0; i < kategori.length; i++) {
        var valKate = kategori[i];

        listKategori.add(
          Container(
            margin: EdgeInsets.all(5),
            padding: EdgeInsets.fromLTRB(0, 2, 2, 2),
            // width: Get.width * 0.45,
            child: Row(
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(27),
                              side: BorderSide(color: Warna.warnautama)))),
                  onPressed: () {
                    paginate = 0;
                    filtercari = '';
                    textController.text = '';
                    filterkategori = valKate['kategori'];
                    listdatabarang = [];
                    cekDataBarang();
                  },
                  child: Row(
                    children: [
                      ClipOval(
                        child: CachedNetworkImage(
                          imageUrl:
                              "https://sasuka.online/icon/kategori/${valKate['kategori']}.jpg",
                          width: 50.0,
                          height: 50.0,
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(left: 11)),
                      Text(
                        valKate['kategori'],
                        style: TextStyle(
                            fontSize: 18,
                            color: Warna.warnautama,
                            fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    return Row(
      children: listKategori,
    );
  }

  void referensiProduk() async {
    jsonDataBarang = [];
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var latitude = c.latitude.value;
    var longitude = c.longitude.value;

    var datarequest =
        '{"pid":"$pid","skip":"$paginate","lat":"$latitude","long":"$longitude" }';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse('${c.baseURL}/sasuka/referensiMarketplace');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    paginate++;

    // EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        if (mounted) {
          setState(() {
            jsonReff1 = hasil['referensi1'];
            jsonKateg1 = hasil['kategori1'];

            jsonReff2 = hasil['referensi2'];
            jsonKateg2 = hasil['kategori2'];

            jsonReff3 = hasil['referensi3'];
            jsonKateg3 = hasil['kategori3'];
          });
        }
      }
    }
  }
}
