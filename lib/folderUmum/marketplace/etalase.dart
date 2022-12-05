import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:carousel_slider/carousel_slider.dart';
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
  var pencarian = false;
  var datakategori = false;
  var loaddataPencarian = false;
  var fungsiPencarian = false;
  var filtercari = '';
  var filterkategori = '';
  var filtertoko = '';
  var loadkategori = '';
  var waitCari = DateTime.now().add(const Duration(seconds: 2));
  @override
  void initState() {
    super.initState();
    textController.addListener(_pencarianFungsi);

    // Box dbbox = Hive.box<String>('sasukaDB');
    //var dataLama = dbbox.get('dataLama');
    // var dataLamaBarang = dbbox.get('dataLamaBarang');

    cekKategori();
    cekDataBarang();
    referensiProduk();

    // if (dataLama == 'sudah ada') {
    //   Map<String, dynamic> hasil = jsonDecode(dataLamaBarang);

    //   jsonReff1 = hasil['referensi1'];
    //   jsonKateg1 = hasil['kategori1'];
    //   jsonReff2 = hasil['referensi2'];
    //   jsonKateg2 = hasil['kategori2'];
    //   jsonReff3 = hasil['referensi3'];
    //   jsonKateg3 = hasil['kategori3'];
    //   referensiProdukforSave();
    // } else {
    //   referensiProduk();
    // }
  }

  void _onRefresh() async {
    listdatabarang = [];
    paginate = 0;
    cekDataBarang();
    _refreshController.refreshCompleted();
  }

  void _onLoading() {
    // monitor network fetch
    cekDataBarang();
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  var yangDIcari = '';
  void _pencarianFungsi() {
    if (textController.text == '') {
      fungsiPencarian = false;
    } else {
      if (textController.text.length > 2) {
        assert(DateTime.now().isAfter(waitCari) == true);
        print(textController.text);
        waitCari = DateTime.now().add(const Duration(seconds: 2));
        if (textController.text != yangDIcari) {
          queryPencarian();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Marketplace'),
          backgroundColor: Warna.warnautama,
          actions: [
            AnimSearchBar(
              helpText: '',
              suffixIcon: Icon(
                Icons.close,
                color: Warna.warnautama,
              ),
              autoFocus: true,
              closeSearchOnSuffixTap: true,
              prefixIcon: Icon(
                Icons.search,
                color: Warna.warnautama,
              ),
              width: Get.width * 0.8,
              textController: textController,
              onSuffixTap: () {
                setState(() {
                  textController.clear();
                  fungsiPencarian = false;
                });
              },
            ),
          ],
        ),
        body: (fungsiPencarian == false)
            ? SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
                header: WaterDropHeader(
                  waterDropColor: Warna.warnautama,
                ),
                footer: CustomFooter(
                  builder: (BuildContext context, LoadStatus mode) {
                    Widget body;
                    if (mode == LoadStatus.idle) {
                      body = Text("Mencari produk ...");
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
                  (pencarian == false)
                      ? Container(
                          padding: EdgeInsets.fromLTRB(22, 1, 22, 1),
                          child: Text(
                            'Cari apa aja mudah disini kamu bisa mendapat barang kesukaan kamu',
                            style: TextStyle(
                                color: Warna.warnautama,
                                fontSize: 29,
                                fontWeight: FontWeight.w300),
                          ),
                        )
                      : Container(),
                  (pencarian == false)
                      ? Container(
                          padding: EdgeInsets.fromLTRB(5, 11, 5, 5),
                          child: CarouselSlider(
                              options: CarouselOptions(
                                //height: 400,
                                aspectRatio: 10 / 4.3,
                                viewportFraction: 1,
                                initialPage: 0,
                                enableInfiniteScroll: true,
                                reverse: false,
                                autoPlay: true,
                                autoPlayInterval: Duration(seconds: 5),
                                autoPlayAnimationDuration:
                                    Duration(milliseconds: 800),
                                autoPlayCurve: Curves.fastOutSlowIn,
                                enlargeCenterPage: true,
                                //onPageChanged: callbackFunction,
                                scrollDirection: Axis.horizontal,
                              ),
                              items: (datakategori == true)
                                  ? listkategori()
                                  : listkategori()))
                      : Container(),
                  (pencarian == false)
                      ? (loaddata == true)
                          ? tampilkanReff1()
                          : tampilkanReff1()
                      : Container(),
                  Padding(padding: EdgeInsets.only(top: 16)),
                  (pencarian == false)
                      ? (loaddata == true)
                          ? tampilkanReff2()
                          : tampilkanReff2()
                      : Container(),
                  Padding(padding: EdgeInsets.only(top: 16)),
                  (pencarian == false)
                      ? (loaddata == true)
                          ? tampilkanReff3()
                          : tampilkanReff2()
                      : Container(),
                  Container(
                    padding: EdgeInsets.only(left: 11, top: 16, right: 11),
                    child: Row(
                      children: [
                        Icon(Icons.home, size: 27, color: Colors.amber),
                        Padding(padding: EdgeInsets.only(left: 11)),
                        Text('Produk pilihan buat kamu',
                            style:
                                TextStyle(color: Colors.amber, fontSize: 17)),
                      ],
                    ),
                  ),
                  Column(
                    children: (loaddataPencarian == true)
                        ? listdaftar()
                        : listdaftar(),
                  )
                ]))
            : Container(
                padding: EdgeInsets.fromLTRB(3, 12, 3, 12),
                child: ListView(
                  children: [
                    Column(
                      children: listTokoTampil(),
                    ),
                    Column(children: listProdukTampil()),
                  ],
                ),
              ));
  }

  cekDataBarang() async {
    // jsonDataBarang = [];
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
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","skip":"$paginate","toko":"$filtertoko","cari":"$filtercari","kategori":"$filterkategori","lat":"$latitude","long":"$longitude","loadKategori":"$loadkategori"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLmp}/mobileAppsUser/cekProdukMarketplace');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    paginate++;

    // EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        if (mounted) {
          jsonDataBarang = hasil['data'];

          loadkategori = 'sudah';
          setState(() {
            loaddataPencarian = true;
          });
        }
      }
    }
  }

  cekKategori() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLmp}/mobileAppsUser/kategoriMarketplace');

    final response = await http.post(url, body: {
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
        kategori = hasil['kategori'];
        dbbox.put('kategoriMP', response.body);
        if (mounted) {
          setState(() {
            datakategori = true;
          });
        }
      }
    }
    //END LOAD DATA TOP UP
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
              c.idOutletPilihanMP.value = valHistory[1].toString();

              if ((c.idOutletpadakeranjangMP.value ==
                      c.idOutletPilihanMP.value) ||
                  (c.idOutletpadakeranjangMP.value == '0')) {
                c.namaOutletMP.value = valHistory[7];
                c.tagIdMPC.value = valHistory[1].toString();
                c.namaMPC.value = valHistory[2];
                c.gambarMPC.value = valHistory[12];
                c.gambarMPChiRess.value = valHistory[13];

                c.namaoutletMPC.value = valHistory[7];
                c.hargaMPC.value = valHistory[5];
                c.lokasiMPC.value = valHistory[4];
                c.deskripsiMPC.value = valHistory[10];
                c.hargaIntMPC.value = int.parse(valHistory[8]);
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
                      Text('Pindah ke Outlet lain',
                          style: TextStyle(
                              fontSize: 20,
                              color: Warna.grey,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center),
                      Container(
                        padding: EdgeInsets.fromLTRB(22, 7, 22, 11),
                        child: Text(
                          'Sepertinya kamu ingin berpindah ke outlet lain, Boleh kok, Apakah keranjang di outlet sebelumnya mau kamu simpan ?',
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
                                  var order = c.keranjangMP.toList();
                                  var idoutl = c.idOutletMPC.value;
                                  simpankekeranjang(order, idoutl);

                                  c.idOutletpadakeranjangMP.value = '0';
                                  c.jumlahItemMP.value = 0;
                                  c.hargaKeranjangMP.value = 0;
                                  c.jumlahBarangMP.value = 0;

                                  c.keranjangMP.clear();
                                  c.idOutletPilihanMP.value =
                                      valHistory[1].toString();
                                  c.namaoutletpadakeranjangMP.value =
                                      'dalam keranjangmu';

                                  c.namaOutletMP.value = valHistory[7];
                                  c.tagIdMPC.value = valHistory[1].toString();
                                  c.namaMPC.value = valHistory[2];
                                  c.gambarMPC.value = valHistory[12];
                                  c.gambarMPChiRess.value = valHistory[13];
                                  c.namaoutletMPC.value = valHistory[7];
                                  c.hargaMPC.value = valHistory[5];
                                  c.lokasiMPC.value = valHistory[4];
                                  c.deskripsiMPC.value = valHistory[10];
                                  c.hargaIntMPC.value =
                                      int.parse(valHistory[8]);
                                  c.idOutletMPC.value =
                                      valHistory[1].toString();
                                  c.itemIdMPC.value = valHistory[11].toString();

                                  Get.off(DetailOtletMarketplace());
                                },
                                child: Text('Simpan Keranjang')),
                            ElevatedButton(
                                onPressed: () {
                                  c.idOutletpadakeranjangMP.value = '0';
                                  c.jumlahItemMP.value = 0;
                                  c.hargaKeranjangMP.value = 0;
                                  c.jumlahBarangMP.value = 0;

                                  c.keranjangMP.clear();
                                  c.idOutletPilihanMP.value =
                                      valHistory[1].toString();
                                  c.namaoutletpadakeranjangMP.value =
                                      'dalam keranjangmu';

                                  c.namaOutletMP.value = valHistory[7];
                                  c.tagIdMPC.value = valHistory[1].toString();
                                  c.namaMPC.value = valHistory[2];
                                  c.gambarMPC.value = valHistory[12];
                                  c.gambarMPChiRess.value = valHistory[13];
                                  c.namaoutletMPC.value = valHistory[7];
                                  c.hargaMPC.value = valHistory[5];
                                  c.lokasiMPC.value = valHistory[4];
                                  c.deskripsiMPC.value = valHistory[10];
                                  c.hargaIntMPC.value =
                                      int.parse(valHistory[8]);
                                  c.idOutletMPC.value =
                                      valHistory[1].toString();
                                  c.itemIdMPC.value = valHistory[11].toString();

                                  Get.off(DetailOtletMarketplace());
                                },
                                child: Text('Pindah')),
                          ],
                        ),
                      )
                    ],
                  ),
                )..show();
              }
            },
            child: Card(
                elevation: 0,
                //color: Colors.lightGreen[50],
                margin: EdgeInsets.all(5),
                child: Container(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: CachedNetworkImage(
                              width: Get.width * 0.35,
                              height: Get.width * 0.35,
                              imageUrl: valHistory[3],
                              errorWidget: (context, url, error) {
                                print(error);
                                return Icon(Icons.error);
                              }),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(left: Get.width * 0.01)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: Get.width * 0.5,
                            child: Text(
                              valHistory[2],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(fontSize: 19, color: Warna.grey),
                            ),
                          ),
                          SizedBox(
                            width: Get.width * 0.5,
                            child: Text(
                              valHistory[7],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
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
    jsonDataBarang = [];
    return listdatabarang;
  }

  tampilkanReff1() {
    if (jsonReff1.length > 0) {
      for (var i = 0; i < jsonReff1.length; i++) {
        var valHistory = jsonReff1[i];

        listReferensi1.add(
          Container(
              width: Get.width * 0.42,
              child: GestureDetector(
                onTap: () {
                  c.idOutletPilihanMP.value = valHistory[1].toString();

                  if ((c.idOutletpadakeranjangMP.value ==
                          c.idOutletPilihanMP.value) ||
                      (c.idOutletpadakeranjangMP.value == '0')) {
                    c.namaOutletMP.value = valHistory[7];
                    c.namaOutletMP.value = valHistory[7];
                    c.tagIdMPC.value = valHistory[1].toString();
                    c.namaMPC.value = valHistory[2];
                    c.gambarMPC.value = valHistory[12];
                    c.gambarMPChiRess.value = valHistory[13];
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
                          Text('Pindah ke Outlet lain',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Warna.grey,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center),
                          Container(
                            padding: EdgeInsets.fromLTRB(22, 7, 22, 11),
                            child: Text(
                              'Sepertinya kamu ingin berpindah ke outlet lain, Boleh kok, Apakah keranjang di outlet sebelumnya mau kamu simpan ?',
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
                                      var order = c.keranjangMP.toList();
                                      var idoutl = c.idOutletMPC.value;
                                      simpankekeranjang(order, idoutl);

                                      c.idOutletpadakeranjangMP.value = '0';
                                      c.jumlahItemMP.value = 0;
                                      c.hargaKeranjangMP.value = 0;
                                      c.jumlahBarangMP.value = 0;

                                      c.keranjangMP.clear();
                                      c.idOutletPilihanMP.value =
                                          valHistory[1].toString();
                                      c.namaoutletpadakeranjangMP.value =
                                          'dalam keranjangmu';

                                      c.namaOutletMP.value = valHistory[7];
                                      c.tagIdMPC.value =
                                          valHistory[1].toString();
                                      c.namaMPC.value = valHistory[2];
                                      c.gambarMPC.value = valHistory[12];
                                      c.gambarMPChiRess.value = valHistory[13];
                                      c.namaoutletMPC.value = valHistory[7];
                                      c.hargaMPC.value = valHistory[5];
                                      c.lokasiMPC.value = valHistory[4];
                                      c.deskripsiMPC.value = valHistory[10];
                                      c.hargaIntMPC.value = (valHistory[8]);
                                      c.idOutletMPC.value =
                                          valHistory[1].toString();
                                      c.itemIdMPC.value =
                                          valHistory[11].toString();

                                      Get.off(DetailOtletMarketplace());
                                    },
                                    child: Text('Simpan Keranjang')),
                                ElevatedButton(
                                    onPressed: () {
                                      c.idOutletpadakeranjangMP.value = '0';
                                      c.jumlahItemMP.value = 0;
                                      c.hargaKeranjangMP.value = 0;
                                      c.jumlahBarangMP.value = 0;

                                      c.keranjangMP.clear();
                                      c.idOutletPilihanMP.value =
                                          valHistory[1].toString();
                                      c.namaoutletpadakeranjangMP.value =
                                          'dalam keranjangmu';

                                      c.namaOutletMP.value = valHistory[7];
                                      c.tagIdMPC.value =
                                          valHistory[1].toString();
                                      c.namaMPC.value = valHistory[2];
                                      c.gambarMPC.value = valHistory[12];
                                      c.gambarMPChiRess.value = valHistory[13];
                                      c.namaoutletMPC.value = valHistory[7];
                                      c.hargaMPC.value = valHistory[5];
                                      c.lokasiMPC.value = valHistory[4];
                                      c.deskripsiMPC.value = valHistory[10];
                                      c.hargaIntMPC.value = (valHistory[8]);
                                      c.idOutletMPC.value =
                                          valHistory[1].toString();
                                      c.itemIdMPC.value =
                                          valHistory[11].toString();

                                      Get.off(DetailOtletMarketplace());
                                    },
                                    child: Text('Pindah')),
                              ],
                            ),
                          )
                        ],
                      ),
                    )..show();
                  }
                },
                child: Card(
                    elevation: 1,
                    //color: Colors.lightGreen[50],
                    margin: EdgeInsets.all(5),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: CachedNetworkImage(
                                  width: Get.width * 0.38,
                                  height: Get.width * 0.38,
                                  imageUrl: valHistory[3],
                                  errorWidget: (context, url, error) {
                                    print(error);
                                    return Icon(Icons.error);
                                  }),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(left: Get.width * 0.01)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: Get.width * 0.50,
                                child: Text(
                                  valHistory[2],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 19, color: Warna.grey),
                                ),
                              ),
                              SizedBox(
                                width: Get.width * 0.55,
                                child: Text(
                                  valHistory[7],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 12, color: Warna.grey),
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
                                  style: TextStyle(
                                      fontSize: 10, color: Warna.grey),
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
                                      Padding(
                                          padding: EdgeInsets.only(left: 3)),
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
                                      Padding(
                                          padding: EdgeInsets.only(left: 3)),
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
    jsonReff1 = [];
    return Container(
      padding: EdgeInsets.only(left: 11, right: 11),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.home, size: 27, color: Colors.amber),
                  Padding(padding: EdgeInsets.only(left: 11)),
                  SizedBox(
                    width: Get.width * 0.45,
                    child: Text(jsonKateg1,
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                        style: TextStyle(color: Colors.amber, fontSize: 17)),
                  ),
                ],
              ),
              RawMaterialButton(
                onPressed: () {
                  pencarian = true;
                  paginate = 0;
                  filtercari = '';
                  textController.text = '';
                  filterkategori = jsonKateg1;
                  listdatabarang = [];
                  cekDataBarang();
                },
                constraints: BoxConstraints(),
                elevation: 1.0,
                fillColor: Colors.amber,
                child: Text(
                  '+ Lihat lainnya',
                  style: TextStyle(color: Colors.white),
                ),
                padding: EdgeInsets.all(4.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(9)),
                ),
              )
            ],
          ),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: listReferensi1)),
        ],
      ),
    );
  }

  tampilkanReff2() {
    if (jsonReff2.length > 0) {
      for (var i = 0; i < jsonReff2.length; i++) {
        var valHistory = jsonReff2[i];

        listReferensi2.add(
          Container(
              width: Get.width * 0.42,
              child: GestureDetector(
                onTap: () {
                  c.idOutletPilihanMP.value = valHistory[1].toString();
                  print(c.idOutletpadakeranjangMP.value);

                  if ((c.idOutletpadakeranjangMP.value ==
                          c.idOutletPilihanMP.value) ||
                      (c.idOutletpadakeranjangMP.value == '0')) {
                    c.namaOutletMP.value = valHistory[7];
                    c.namaOutletMP.value = valHistory[7];
                    c.tagIdMPC.value = valHistory[1].toString();
                    c.namaMPC.value = valHistory[2];
                    c.gambarMPC.value = valHistory[12];
                    c.gambarMPChiRess.value = valHistory[13];
                    c.namaoutletMPC.value = valHistory[7];
                    c.hargaMPC.value = valHistory[5];
                    c.lokasiMPC.value = valHistory[4];
                    c.deskripsiMPC.value = valHistory[10];
                    c.hargaIntMPC.value = (valHistory[8]);
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
                          Text('Pindah ke Outlet lain',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Warna.grey,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center),
                          Container(
                            padding: EdgeInsets.fromLTRB(22, 7, 22, 11),
                            child: Text(
                              'Sepertinya kamu ingin berpindah ke outlet lain, Boleh kok, Apakah keranjang di outlet sebelumnya mau kamu simpan ?',
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
                                      var order = c.keranjangMP.toList();
                                      var idoutl = c.idOutletMPC.value;
                                      simpankekeranjang(order, idoutl);

                                      c.idOutletpadakeranjangMP.value = '0';
                                      c.jumlahItemMP.value = 0;
                                      c.hargaKeranjangMP.value = 0;
                                      c.jumlahBarangMP.value = 0;

                                      c.keranjangMP.clear();
                                      c.idOutletPilihanMP.value =
                                          valHistory[1].toString();
                                      c.namaoutletpadakeranjangMP.value =
                                          'dalam keranjangmu';

                                      c.namaOutletMP.value = valHistory[7];
                                      c.tagIdMPC.value =
                                          valHistory[1].toString();
                                      c.namaMPC.value = valHistory[2];
                                      c.gambarMPC.value = valHistory[12];
                                      c.gambarMPChiRess.value = valHistory[13];
                                      c.namaoutletMPC.value = valHistory[7];
                                      c.hargaMPC.value = valHistory[5];
                                      c.lokasiMPC.value = valHistory[4];
                                      c.deskripsiMPC.value = valHistory[10];
                                      c.hargaIntMPC.value = (valHistory[8]);
                                      c.idOutletMPC.value =
                                          valHistory[1].toString();
                                      c.itemIdMPC.value =
                                          valHistory[11].toString();

                                      Get.off(DetailOtletMarketplace());
                                    },
                                    child: Text('Simpan Keranjang')),
                                ElevatedButton(
                                    onPressed: () {
                                      c.idOutletpadakeranjangMP.value = '0';
                                      c.jumlahItemMP.value = 0;
                                      c.hargaKeranjangMP.value = 0;
                                      c.jumlahBarangMP.value = 0;

                                      c.keranjangMP.clear();
                                      c.idOutletPilihanMP.value =
                                          valHistory[1].toString();
                                      c.namaoutletpadakeranjangMP.value =
                                          'dalam keranjangmu';

                                      c.namaOutletMP.value = valHistory[7];
                                      c.tagIdMPC.value =
                                          valHistory[1].toString();
                                      c.namaMPC.value = valHistory[2];
                                      c.gambarMPC.value = valHistory[12];
                                      c.gambarMPChiRess.value = valHistory[13];
                                      c.namaoutletMPC.value = valHistory[7];
                                      c.hargaMPC.value = valHistory[5];
                                      c.lokasiMPC.value = valHistory[4];
                                      c.deskripsiMPC.value = valHistory[10];
                                      c.hargaIntMPC.value = (valHistory[8]);
                                      c.idOutletMPC.value =
                                          valHistory[1].toString();
                                      c.itemIdMPC.value =
                                          valHistory[11].toString();

                                      Get.off(DetailOtletMarketplace());
                                    },
                                    child: Text('Pindah')),
                              ],
                            ),
                          )
                        ],
                      ),
                    )..show();
                  }
                },
                child: Card(
                    elevation: 1,
                    //color: Colors.lightGreen[50],
                    margin: EdgeInsets.all(5),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: CachedNetworkImage(
                                width: Get.width * 0.38,
                                height: Get.width * 0.38,
                                imageUrl: valHistory[3],
                                errorWidget: (context, url, error) {
                                  print(error);
                                  return Icon(Icons.error);
                                }),
                          ),
                          Padding(
                              padding: EdgeInsets.only(left: Get.width * 0.01)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: Get.width * 0.50,
                                child: Text(
                                  valHistory[2],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 19, color: Warna.grey),
                                ),
                              ),
                              SizedBox(
                                width: Get.width * 0.55,
                                child: Text(
                                  valHistory[7],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 12, color: Warna.grey),
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
                                  style: TextStyle(
                                      fontSize: 10, color: Warna.grey),
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
                                      Padding(
                                          padding: EdgeInsets.only(left: 3)),
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
                                      Padding(
                                          padding: EdgeInsets.only(left: 3)),
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
    jsonReff2 = [];
    return Container(
      padding: EdgeInsets.only(left: 11, right: 11),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.home, size: 27, color: Colors.amber),
                  Padding(padding: EdgeInsets.only(left: 11)),
                  SizedBox(
                    width: Get.width * 0.45,
                    child: Text(jsonKateg2,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.amber, fontSize: 17)),
                  ),
                ],
              ),
              RawMaterialButton(
                onPressed: () {
                  pencarian = true;
                  paginate = 0;
                  filtercari = '';
                  textController.text = '';
                  filterkategori = jsonKateg2;
                  listdatabarang = [];
                  cekDataBarang();
                },
                constraints: BoxConstraints(),
                elevation: 1.0,
                fillColor: Colors.amber,
                child: Text(
                  '+ Lihat lainnya',
                  style: TextStyle(color: Colors.white),
                ),
                padding: EdgeInsets.all(4.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(9)),
                ),
              )
            ],
          ),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: listReferensi2)),
        ],
      ),
    );
  }

  tampilkanReff3() {
    if (jsonReff3.length > 0) {
      for (var i = 0; i < jsonReff3.length; i++) {
        var valHistory = jsonReff3[i];

        listReferensi3.add(
          Container(
              width: Get.width * 0.42,
              child: GestureDetector(
                onTap: () {
                  c.idOutletPilihanMP.value = valHistory[1].toString();

                  if ((c.idOutletpadakeranjangMP.value ==
                          c.idOutletPilihanMP.value) ||
                      (c.idOutletpadakeranjangMP.value == '0')) {
                    c.namaOutletMP.value = valHistory[7];
                    c.namaOutletMP.value = valHistory[7];
                    c.tagIdMPC.value = valHistory[1].toString();
                    c.namaMPC.value = valHistory[2];
                    c.gambarMPC.value = valHistory[12];
                    c.gambarMPChiRess.value = valHistory[13];
                    c.namaoutletMPC.value = valHistory[7];
                    c.hargaMPC.value = valHistory[5];
                    c.lokasiMPC.value = valHistory[4];
                    c.deskripsiMPC.value = valHistory[10];
                    c.hargaIntMPC.value = (valHistory[8]);
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
                          Text('Pindah ke Outlet lain',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Warna.grey,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center),
                          Container(
                            padding: EdgeInsets.fromLTRB(22, 7, 22, 11),
                            child: Text(
                              'Sepertinya kamu ingin berpindah ke outlet lain, Boleh kok, Apakah keranjang di outlet sebelumnya mau kamu simpan ?',
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
                                      var order = c.keranjangMP.toList();
                                      var idoutl = c.idOutletMPC.value;
                                      simpankekeranjang(order, idoutl);

                                      c.idOutletpadakeranjangMP.value = '0';
                                      c.jumlahItemMP.value = 0;
                                      c.hargaKeranjangMP.value = 0;
                                      c.jumlahBarangMP.value = 0;

                                      c.keranjangMP.clear();
                                      c.idOutletPilihanMP.value =
                                          valHistory[1].toString();
                                      c.namaoutletpadakeranjangMP.value =
                                          'dalam keranjangmu';

                                      c.namaOutletMP.value = valHistory[7];
                                      c.tagIdMPC.value =
                                          valHistory[1].toString();
                                      c.namaMPC.value = valHistory[2];
                                      c.gambarMPC.value = valHistory[12];
                                      c.gambarMPChiRess.value = valHistory[13];
                                      c.namaoutletMPC.value = valHistory[7];
                                      c.hargaMPC.value = valHistory[5];
                                      c.lokasiMPC.value = valHistory[4];
                                      c.deskripsiMPC.value = valHistory[10];
                                      c.hargaIntMPC.value = (valHistory[8]);
                                      c.idOutletMPC.value =
                                          valHistory[1].toString();
                                      c.itemIdMPC.value =
                                          valHistory[11].toString();

                                      Get.off(DetailOtletMarketplace());
                                    },
                                    child: Text('Simpan Keranjang')),
                                ElevatedButton(
                                    onPressed: () {
                                      c.idOutletpadakeranjangMP.value = '0';
                                      c.jumlahItemMP.value = 0;
                                      c.hargaKeranjangMP.value = 0;
                                      c.jumlahBarangMP.value = 0;

                                      c.keranjangMP.clear();
                                      c.idOutletPilihanMP.value =
                                          valHistory[1].toString();
                                      c.namaoutletpadakeranjangMP.value =
                                          'dalam keranjangmu';

                                      c.namaOutletMP.value = valHistory[7];
                                      c.tagIdMPC.value =
                                          valHistory[1].toString();
                                      c.namaMPC.value = valHistory[2];
                                      c.gambarMPC.value = valHistory[12];
                                      c.gambarMPChiRess.value = valHistory[13];
                                      c.namaoutletMPC.value = valHistory[7];
                                      c.hargaMPC.value = valHistory[5];
                                      c.lokasiMPC.value = valHistory[4];
                                      c.deskripsiMPC.value = valHistory[10];
                                      c.hargaIntMPC.value = (valHistory[8]);
                                      c.idOutletMPC.value =
                                          valHistory[1].toString();
                                      c.itemIdMPC.value =
                                          valHistory[11].toString();

                                      Get.off(DetailOtletMarketplace());
                                    },
                                    child: Text('Pindah')),
                              ],
                            ),
                          )
                        ],
                      ),
                    )..show();
                  }
                },
                child: Card(
                    elevation: 1,
                    //color: Colors.lightGreen[50],
                    margin: EdgeInsets.all(5),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: CachedNetworkImage(
                                width: Get.width * 0.38,
                                height: Get.width * 0.38,
                                imageUrl: valHistory[3],
                                errorWidget: (context, url, error) {
                                  print(error);
                                  return Icon(Icons.error);
                                }),
                          ),
                          Padding(
                              padding: EdgeInsets.only(left: Get.width * 0.01)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: Get.width * 0.50,
                                child: Text(
                                  valHistory[2],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 19, color: Warna.grey),
                                ),
                              ),
                              SizedBox(
                                width: Get.width * 0.55,
                                child: Text(
                                  valHistory[7],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 12, color: Warna.grey),
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
                                  style: TextStyle(
                                      fontSize: 10, color: Warna.grey),
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
                                      Padding(
                                          padding: EdgeInsets.only(left: 3)),
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
                                      Padding(
                                          padding: EdgeInsets.only(left: 3)),
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
    jsonReff3 = [];
    return Container(
      padding: EdgeInsets.only(left: 11, right: 11),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.home, size: 27, color: Colors.amber),
                  Padding(padding: EdgeInsets.only(left: 11)),
                  SizedBox(
                    width: Get.width * 0.45,
                    child: Text(jsonKateg3,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(color: Colors.amber, fontSize: 17)),
                  ),
                ],
              ),
              RawMaterialButton(
                onPressed: () {
                  pencarian = true;
                  paginate = 0;
                  filtercari = '';
                  textController.text = '';
                  filterkategori = jsonKateg3;
                  listdatabarang = [];
                  cekDataBarang();
                },
                constraints: BoxConstraints(),
                elevation: 1.0,
                fillColor: Colors.amber,
                child: Text(
                  '+ Lihat lainnya',
                  style: TextStyle(color: Colors.white),
                ),
                padding: EdgeInsets.all(4.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(9)),
                ),
              )
            ],
          ),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: listReferensi3)),
        ],
      ),
    );
  }

  listkategori() {
    if (kategori.length > 0) {
      for (var i = 0; i < kategori.length; i++) {
        var valKate = kategori[i];

        listKategori.add(Container(
          child: Column(
            children: [
              GestureDetector(
                  onTap: () {
                    paginate = 0;
                    filtercari = '';
                    filterkategori = valKate[0];
                    listdatabarang = [];
                    pencarian = true;
                    cekDataBarang();
                  },
                  child: Image(image: CachedNetworkImageProvider(valKate[1]))),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    valKate[0],
                    style: TextStyle(color: Warna.warnautama, fontSize: 17),
                  ),
                  Icon(Icons.double_arrow, size: 19, color: Warna.warnautama),
                ],
              ),
            ],
          ),
          color: Colors.white,
        ));
      }
    }
    return listKategori;
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
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","skip":"$paginate","lat":"$latitude","long":"$longitude" }';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLmp}/mobileAppsUser/referensiMarketplace');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    paginate++;

    // EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        dbbox.put('dataLama', 'sudah ada');
        dbbox.put('dataLamaBarang', response.body);
        if (mounted) {
          jsonReff1 = hasil['referensi1'];
          jsonKateg1 = hasil['kategori1'];

          jsonReff2 = hasil['referensi2'];
          jsonKateg2 = hasil['kategori2'];

          jsonReff3 = hasil['referensi3'];
          jsonKateg3 = hasil['kategori3'];
          setState(() {
            loaddata = true;
          });
        }
      }
    }
  }

  void simpankekeranjang(order, idoutle) async {
    jsonDataBarang = [];
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var orderJson = order;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","jsonOrder":"$orderJson","idoutlet":"$idoutle"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLmp}/mobileAppsUser/simpanKeKeranjang');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        Get.snackbar('Keranjang Belanja', hasil['message']);
      }
    }
  }

  void referensiProdukforSave() async {
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
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","skip":"$paginate","lat":"$latitude","long":"$longitude" }';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLmp}/mobileAppsUser/referensiMarketplace');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    paginate++;

    // EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        dbbox.put('dataLama', 'sudah ada');
        dbbox.put('dataLamaBarang', response.body);
      }
    }
  }

  void queryPencarian() async {
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var cari = textController.text;
    var datarequest = '{"pid":"$pid","cari":"$cari"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLmp}/mobileAppsUser/pencarianMP');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        tokoCari = [];
        tokoCariContainer = [];
        produkCari = [];
        produkCariContainer = [];

        setState(() {
          fungsiPencarian = true;
          tokoCari = hasil['toko'];
          produkCari = hasil['produk'];
        });
      }
    }
  }

  List tokoCari = [];
  List<Container> tokoCariContainer = [];
  List produkCari = [];
  List<Container> produkCariContainer = [];

  listTokoTampil() {
    tokoCariContainer = [];
    if (tokoCari.length > 0) {
      tokoCariContainer.add(Container(
        padding: EdgeInsets.fromLTRB(11, 5, 11, 5),
        child: Text(
          'Outlet :',
          style: TextStyle(color: Warna.warnautama),
        ),
      ));
      for (var i = 0; i < tokoCari.length; i++) {
        var aaaa = tokoCari[i];

        tokoCariContainer.add(Container(
          child: InkWell(
            onTap: () {
              paginate = 0;
              listdatabarang = [];
              filtertoko = aaaa[2].toString();
              filtercari = '';
              filterkategori = '';
              pencarian = true;
              fungsiPencarian = false;
              yangDIcari = textController.text;

              cekDataBarang();
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(11, 5, 11, 5),
              child: Row(
                children: [
                  Icon(Icons.map, color: Colors.grey, size: 24),
                  Padding(padding: EdgeInsets.only(left: 11)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: Get.width * 0.8,
                        child: Text(
                          aaaa[0],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 17, color: Warna.grey),
                        ),
                      ),
                      SizedBox(
                        width: Get.width * 0.8,
                        child: Text(
                          aaaa[1],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
      }
    }
    return tokoCariContainer;
  }

  listProdukTampil() {
    produkCariContainer = [];
    if (produkCari.length > 0) {
      produkCariContainer.add(Container(
        padding: EdgeInsets.fromLTRB(11, 5, 11, 5),
        child: Text(
          'Mungkin ini produk yang kamu cari :',
          style: TextStyle(color: Warna.warnautama),
        ),
      ));
      produkCariContainer.add(Container(
        child: InkWell(
          onTap: () {
            paginate = 0;
            listdatabarang = [];
            filtertoko = '';
            filtercari = textController.text;
            filterkategori = '';
            pencarian = true;
            fungsiPencarian = false;
            yangDIcari = textController.text;

            cekDataBarang();
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(11, 5, 11, 5),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey, size: 24),
                Padding(padding: EdgeInsets.only(left: 11)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: Get.width * 0.8,
                      child: Text(
                        textController.text.capitalizeFirst,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 17, color: Warna.grey),
                      ),
                    ),
                    SizedBox(
                      width: Get.width * 0.8,
                      child: Text(
                        'Pada semua kategori',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ));

      for (var i = 0; i < produkCari.length; i++) {
        var aaaa = produkCari[i];

        produkCariContainer.add(Container(
          child: InkWell(
            onTap: () {
              paginate = 0;
              listdatabarang = [];
              filtertoko = '';
              filtercari = aaaa[0];
              filterkategori = '';
              pencarian = true;
              fungsiPencarian = false;
              yangDIcari = textController.text;

              cekDataBarang();
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(11, 5, 11, 5),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey, size: 24),
                  Padding(padding: EdgeInsets.only(left: 11)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: Get.width * 0.8,
                        child: Text(
                          aaaa[0],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 17, color: Warna.grey),
                        ),
                      ),
                      SizedBox(
                        width: Get.width * 0.8,
                        child: Text(
                          aaaa[1],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
      }
    }
    return produkCariContainer;
  }
}
