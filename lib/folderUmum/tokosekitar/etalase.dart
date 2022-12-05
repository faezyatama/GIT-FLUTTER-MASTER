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
import 'outletTS.dart';

class EtalaseTokoSekitar extends StatefulWidget {
  @override
  _EtalaseTokoSekitarState createState() => _EtalaseTokoSekitarState();
}

class _EtalaseTokoSekitarState extends State<EtalaseTokoSekitar> {
  final c = Get.find<ApiService>();

  TextEditingController textController = TextEditingController();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var paginate = 0;
  var loaddata1 = false;
  var loaddata2 = false;
  var loaddata3 = false;
  var loaddataVertikal = false;

  var pencarian = false;
  var datakategori = false;
  var loaddataPencarian = false;
  var fungsiPencarian = false;
  var filtercari = '';
  var filterkategori = '';
  var filtertoko = '';
  var loadkategori = '';
  var waitCari = DateTime.now().add(const Duration(seconds: 2));

  var judul = 'Toko Sekitar'.obs;
  var subJudul = 'Cek Toko Online di Sekitar kita'.obs;
  List kategori = [];
  List jsonDataBarang = [];
  List<Container> listdatabarang = [];
  List<Container> listKategori = [];
  List<Container> finalList = [];
  List<Container> nodataList = [];

  List jsonReff1 = [];
  var jsonKateg1 = '';
  List<Container> listReferensi1 = [];

  List jsonReff2 = [];
  var jsonKateg2 = '';
  List<Container> listReferensi2 = [];

  List jsonReff3 = [];
  var jsonKateg3 = '';
  List<Container> listReferensi3 = [];
  var textAppBar = 'Cek Toko Sekitar'.obs;

  @override
  void initState() {
    super.initState();
    textController.addListener(_pencarianFungsi);
    cekKategori();
    cekTokoListVertikal();
    //referensiTokoSekitar();
  }

  void _onRefresh() async {
    listdatabarang = [];
    paginate = 0;
    cekTokoListVertikal();
    _refreshController.refreshCompleted();
  }

  void _onLoading() {
    // monitor network fetch
    cekTokoListVertikal();
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
          title: Obx(() => Text(textAppBar.value)),
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
                      body = Text("Mencari Toko disekitarmu ...");
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
                          child: Column(
                            children: [
                              Padding(padding: EdgeInsets.only(top: 11)),
                              Obx(() => Text(
                                    judul.value,
                                    style: TextStyle(
                                        color: Warna.warnautama,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w200),
                                  )),
                              Obx(() => Text(
                                    subJudul.value,
                                    style: TextStyle(
                                        color: Warna.warnautama,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w200),
                                  )),
                            ],
                          ),
                        )
                      : Container(),
                  Container(
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
                                Duration(milliseconds: 1000),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enlargeCenterPage: true,
                            //onPageChanged: callbackFunction,
                            scrollDirection: Axis.vertical,
                          ),
                          items: (datakategori == true)
                              ? listkategori()
                              : listkategori())),
                  (pencarian == false)
                      ? (loaddata1 == true)
                          ? tampilkanReff1()
                          : Container()
                      : Padding(padding: EdgeInsets.only(top: 1)),
                  (pencarian == false)
                      ? (loaddata2 == true)
                          ? tampilkanReff2()
                          : Container()
                      : Padding(padding: EdgeInsets.only(top: 1)),
                  (pencarian == false)
                      ? (loaddata3 == true)
                          ? tampilkanReff3()
                          : Container()
                      : Container(),
                  (loaddataVertikal == true)
                      ? Container(
                          padding: EdgeInsets.only(left: 11, top: 5, right: 11),
                          child: Row(
                            children: [
                              Icon(Icons.home, size: 27, color: Colors.amber),
                              Padding(padding: EdgeInsets.only(left: 11)),
                              Text('Toko disekitarmu',
                                  style: TextStyle(
                                      color: Colors.amber, fontSize: 17)),
                            ],
                          ),
                        )
                      : Container(),
                  (loaddataPencarian == true)
                      ? Column(children: listdaftarTokoVerikal())
                      : Container(),
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

  cekTokoListVertikal() async {
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

    var url =
        Uri.parse('${c.baseURLtokosekitar}/mobileAppsUser/cekListVertikalTS');

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
          loaddataVertikal = hasil['adaData'];
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
    //GPS
    await determinePosition();
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLtokosekitar}/mobileAppsUser/kategoriTS');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    // EasyLoading.dismiss();
    //print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        judul.value = hasil['judul'];
        subJudul.value = hasil['subJudul'];

        kategori = hasil['kategori'];
        dbbox.put('kategoriTOSEK', response.body);
        if (mounted) {
          setState(() {
            datakategori = true;
          });
        }
      }
    }
    //END LOAD DATA TOP UP
  }

  listdaftarTokoVerikal() {
    if (jsonDataBarang.length > 0) {
      for (var i = 0; i < jsonDataBarang.length; i++) {
        var valHistory = jsonDataBarang[i];

        listdatabarang.add(
          Container(
            child: Card(
                elevation: 0,
                //color: Colors.lightGreen[50],
                margin: EdgeInsets.all(5),
                child: InkWell(
                  onTap: () {
                    int idd = int.parse(valHistory[2]);
                    c.idPilihanOutletTS.value = idd;
                    cekTokoBukaAtauTutup('buka', idd);
                  },
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
                                width: Get.width * 0.3,
                                height: Get.width * 0.3,
                                imageUrl: valHistory[4],
                                errorWidget: (context, url, error) {
                                  print(error);
                                  return Icon(Icons.error);
                                }),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: Get.width * 0.02)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: Get.width * 0.55,
                              child: Text(
                                valHistory[3], //NAMA TOKO
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style:
                                    TextStyle(fontSize: 19, color: Warna.grey),
                              ),
                            ),
                            SizedBox(
                              width: Get.width * 0.55,
                              child: Text(
                                valHistory[1], //DESKRIPSI
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style:
                                    TextStyle(fontSize: 12, color: Warna.grey),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 11)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: Get.width * 0.2,
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/sellerbadge/${valHistory[8]}',
                                        width: Get.width * 0.05,
                                      ),
                                      Text(
                                        valHistory[9],
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 9, color: Warna.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: Get.width * 0.02)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      // width: Get.width * 0.25,
                                      child: Text(
                                        valHistory[5], //LOKASI
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Warna.grey,
                                            fontWeight: FontWeight.w600),
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
                                                padding:
                                                    EdgeInsets.only(left: 3)),
                                            Text(
                                              valHistory[6], // JARAK
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Warna.grey),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(left: 11)),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.watch,
                                              color: Warna.grey,
                                              size: 11,
                                            ),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(left: 3)),
                                            Text(
                                              valHistory[7], // BUKA TUTUP
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Warna.grey),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        );
      }
      jsonDataBarang = [];
      return listdatabarang;
    } else {
      nodataList = [];
      nodataList.add(Container(
        padding: EdgeInsets.fromLTRB(22, 44, 22, 2),
        child: Column(
          children: [
            Image.asset(
              'images/nodata.png',
              width: Get.width * 0.6,
            ),
            Center(
                child: Text(
              'Belum Ada $textAppBar',
              style: TextStyle(
                fontSize: 22,
                color: Warna.grey,
              ),
              textAlign: TextAlign.center,
            )),
            Center(
                child: Text(
              'Opps masih ada toko yang belum terdaftar, Sepertinya ini adalah peluang menarik bagi kamu untuk menjadi Agen ${c.namaAplikasi} untuk mendaftarkan Toko disekitarmu, dapatkan penawaran menariknya',
              style: TextStyle(
                fontSize: 14,
                color: Warna.grey,
              ),
              textAlign: TextAlign.center,
            ))
          ],
        ),
      ));
      if (listdatabarang.length == 0) {
        return nodataList;
      } else {
        nodataList = [];
        return listdatabarang;
      }
    }
  }

  tampilkanReff1() {
    if (jsonReff1.length > 0) {
      for (var i = 0; i < jsonReff1.length; i++) {
        var valHistory = jsonReff1[i];

        listReferensi1.add(
          Container(
            width: Get.width * 0.42,
            child: Card(
                elevation: 1,
                margin: EdgeInsets.all(2),
                child: InkWell(
                  onTap: () {
                    int idd = valHistory[2];
                    c.idPilihanOutletTS.value = idd;
                    cekTokoBukaAtauTutup('buka', idd);
                  },
                  child: Container(
                    padding: EdgeInsets.all(3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: CachedNetworkImage(
                                  width: Get.width * 0.38,
                                  height: Get.width * 0.38,
                                  imageUrl: valHistory[4], //FOTO
                                  errorWidget: (context, url, error) {
                                    print(error);
                                    return Icon(Icons.error);
                                  }),
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 11)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: Get.width * 0.55,
                              height: Get.height * 0.04,
                              child: Text(
                                valHistory[1], // DESKRIPSI
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style:
                                    TextStyle(fontSize: 12, color: Warna.grey),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 8)),
                            SizedBox(
                              width: Get.width * 0.55,
                              height: Get.height * 0.07,
                              child: Text(
                                valHistory[3], //NAMA TOKO
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Warna.grey,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                SizedBox(
                                  width: Get.width * 0.12,
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/sellerbadge/${valHistory[8]}',
                                        width: Get.width * 0.05,
                                      ),
                                      Text(
                                        valHistory[9],
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 9, color: Warna.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      // width: Get.width * 0.25,
                                      child: Text(
                                        valHistory[5], //LOKASI
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                            color: Warna.grey),
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
                                                padding:
                                                    EdgeInsets.only(left: 2)),
                                            Text(
                                              valHistory[6], // JARAK
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Warna.grey),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(left: 2)),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.watch,
                                              color: Warna.grey,
                                              size: 11,
                                            ),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(left: 2)),
                                            Text(
                                              valHistory[7], // BUKA TUTUP
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Warna.grey),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        );
      }
    }
    jsonReff1 = [];
    return Container(
      padding: EdgeInsets.only(left: 11, right: 11),
      child: Column(
        children: [
          (fungsiPencarian == false)
              ? Container(
                  padding: EdgeInsets.fromLTRB(12, 1, 12, 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.home, size: 27, color: Colors.amber),
                          Padding(padding: EdgeInsets.only(left: 11)),
                          Text(jsonKateg3,
                              style:
                                  TextStyle(color: Colors.amber, fontSize: 17)),
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
                          cekTokoListVertikal();
                        },
                        constraints: BoxConstraints(),
                        elevation: 1.0,
                        fillColor: Colors.amber,
                        child: Text(
                          '+ Lihat Toko lainnya',
                          style: TextStyle(color: Colors.white),
                        ),
                        padding: EdgeInsets.all(4.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9)),
                        ),
                      )
                    ],
                  ),
                )
              : Container(),
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
            child: Card(
                elevation: 1,
                //color: Colors.lightGreen[50],
                margin: EdgeInsets.all(2),
                child: InkWell(
                  onTap: () {
                    int idd = valHistory[2];
                    c.idPilihanOutletTS.value = idd;
                    cekTokoBukaAtauTutup('buka', idd);
                  },
                  child: Container(
                    padding: EdgeInsets.all(3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: CachedNetworkImage(
                                  width: Get.width * 0.38,
                                  height: Get.width * 0.38,
                                  imageUrl: valHistory[4], //FOTO
                                  errorWidget: (context, url, error) {
                                    print(error);
                                    return Icon(Icons.error);
                                  }),
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 11)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: Get.width * 0.55,
                              height: Get.height * 0.04,
                              child: Text(
                                valHistory[1], // DESKRIPSI
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style:
                                    TextStyle(fontSize: 12, color: Warna.grey),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 8)),
                            SizedBox(
                              width: Get.width * 0.55,
                              height: Get.height * 0.07,
                              child: Text(
                                valHistory[3], //NAMA TOKO
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Warna.grey,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                SizedBox(
                                  width: Get.width * 0.12,
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/sellerbadge/${valHistory[8]}',
                                        width: Get.width * 0.05,
                                      ),
                                      Text(
                                        valHistory[9],
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 9, color: Warna.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      // width: Get.width * 0.25,
                                      child: Text(
                                        valHistory[5], //LOKASI
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                            color: Warna.grey),
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
                                                padding:
                                                    EdgeInsets.only(left: 2)),
                                            Text(
                                              valHistory[6], // JARAK
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Warna.grey),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(left: 2)),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.watch,
                                              color: Warna.grey,
                                              size: 11,
                                            ),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(left: 2)),
                                            Text(
                                              valHistory[7], // BUKA TUTUP
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Warna.grey),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        );
      }
    }
    jsonReff2 = [];
    return Container(
      padding: EdgeInsets.only(left: 11, right: 11),
      child: Column(
        children: [
          (fungsiPencarian == false)
              ? Container(
                  padding: EdgeInsets.fromLTRB(12, 1, 12, 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.home, size: 27, color: Colors.amber),
                          Padding(padding: EdgeInsets.only(left: 11)),
                          Text(jsonKateg3,
                              style:
                                  TextStyle(color: Colors.amber, fontSize: 17)),
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
                          cekTokoListVertikal();
                        },
                        constraints: BoxConstraints(),
                        elevation: 1.0,
                        fillColor: Colors.amber,
                        child: Text(
                          '+ Lihat Toko lainnya',
                          style: TextStyle(color: Colors.white),
                        ),
                        padding: EdgeInsets.all(4.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9)),
                        ),
                      )
                    ],
                  ),
                )
              : Container(),
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
            child: Card(
                elevation: 1,
                //color: Colors.lightGreen[50],
                margin: EdgeInsets.all(2),
                child: InkWell(
                  onTap: () {
                    int idd = valHistory[2];
                    c.idPilihanOutletTS.value = idd;
                    cekTokoBukaAtauTutup('buka', idd);
                  },
                  child: Container(
                    padding: EdgeInsets.all(3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: CachedNetworkImage(
                                  width: Get.width * 0.38,
                                  height: Get.width * 0.38,
                                  imageUrl: valHistory[4], //FOTO
                                  errorWidget: (context, url, error) {
                                    print(error);
                                    return Icon(Icons.error);
                                  }),
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 11)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: Get.width * 0.55,
                              height: Get.height * 0.04,
                              child: Text(
                                valHistory[1], // DESKRIPSI
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style:
                                    TextStyle(fontSize: 12, color: Warna.grey),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 8)),
                            SizedBox(
                              width: Get.width * 0.55,
                              height: Get.height * 0.07,
                              child: Text(
                                valHistory[3], //NAMA TOKO
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Warna.grey,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                SizedBox(
                                  width: Get.width * 0.12,
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/sellerbadge/${valHistory[8]}',
                                        width: Get.width * 0.05,
                                      ),
                                      Text(
                                        valHistory[9],
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 9, color: Warna.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      // width: Get.width * 0.25,
                                      child: Text(
                                        valHistory[5], //LOKASI
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                            color: Warna.grey),
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
                                                padding:
                                                    EdgeInsets.only(left: 2)),
                                            Text(
                                              valHistory[6], // JARAK
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Warna.grey),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(left: 2)),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.watch,
                                              color: Warna.grey,
                                              size: 11,
                                            ),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(left: 2)),
                                            Text(
                                              valHistory[7], // BUKA TUTUP
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Warna.grey),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        );
      }
    }
    jsonReff3 = [];
    return Container(
      padding: EdgeInsets.only(left: 11, right: 11),
      child: Column(
        children: [
          (fungsiPencarian == false)
              ? Container(
                  padding: EdgeInsets.fromLTRB(12, 1, 12, 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.home, size: 27, color: Colors.amber),
                          Padding(padding: EdgeInsets.only(left: 11)),
                          Text(jsonKateg3,
                              style:
                                  TextStyle(color: Colors.amber, fontSize: 17)),
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
                          cekTokoListVertikal();
                        },
                        constraints: BoxConstraints(),
                        elevation: 1.0,
                        fillColor: Colors.amber,
                        child: Text(
                          '+ Lihat Toko lainnya',
                          style: TextStyle(color: Colors.white),
                        ),
                        padding: EdgeInsets.all(4.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9)),
                        ),
                      )
                    ],
                  ),
                )
              : Container(),
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
                    textAppBar.value = valKate[0];
                    listdatabarang = [];
                    pencarian = true;
                    cekTokoListVertikal();
                  },
                  child: Column(
                    children: [
                      Image(image: CachedNetworkImageProvider(valKate[1])),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            valKate[0],
                            style: TextStyle(
                                color: Warna.warnautama, fontSize: 17),
                          ),
                          Icon(Icons.double_arrow,
                              size: 19, color: Warna.warnautama),
                        ],
                      ),
                    ],
                  )),
            ],
          ),
          color: Colors.white,
        ));
      }
    }
    return listKategori;
  }

  void referensiTokoSekitar() async {
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

    var url = Uri.parse('${c.baseURLtokosekitar}/mobileAppsUser/referensiToko');

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
          loaddata1 = hasil['adadata1'];

          jsonReff2 = hasil['referensi2'];
          jsonKateg2 = hasil['kategori2'];
          loaddata2 = hasil['adadata2'];

          jsonReff3 = hasil['referensi3'];
          jsonKateg3 = hasil['kategori3'];
          loaddata3 = hasil['adadata3'];

          setState(() {});
        }
      }
    }
  }

  void queryPencarian() async {
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var cari = textController.text;
    var latitude = c.latitude.value;
    var longitude = c.longitude.value;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","cari":"$cari","lat":"$latitude","long":"$longitude"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLtokosekitar}/mobileAppsUser/pencarianToko');

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
              int idd = aaaa[2];
              c.idPilihanOutletTS.value = idd;
              cekTokoBukaAtauTutup('buka', idd);
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

            cekTokoListVertikal();
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

              cekTokoListVertikal();
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

  cekTokoBukaAtauTutup(String tutupBuka, int idOutlet) {
    if (tutupBuka == 'buka') {
      c.idOutletPilihanTOSEK.value = idOutlet;

      if ((c.idOutletpadakeranjangTOSEK.value ==
              c.idOutletPilihanTOSEK.value) ||
          (c.idOutletpadakeranjangTOSEK.value == 0)) {
        Get.to(() => DetailOtletTS());
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
              Text('Pindah ke Toko lainnya',
                  style: TextStyle(
                      fontSize: 20,
                      color: Warna.grey,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
              Container(
                padding: EdgeInsets.fromLTRB(22, 7, 22, 11),
                child: Text(
                  'Sepertinya kamu ingin berpindah ke outlet lain, Boleh kok ?',
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
                          c.idOutletpadakeranjangTOSEK.value = 0;
                          c.jumlahItemTOSEK.value = 0;
                          c.hargaKeranjangTOSEK.value = 0;
                          c.jumlahBarangTOSEK.value = 0;

                          c.keranjangTOSEK.clear();
                          c.idOutletPilihanTOSEK.value = idOutlet;
                          c.namaoutletpadakeranjangTOSEK.value =
                              'dalam keranjangmu';

                          Get.off(DetailOtletTS());
                        },
                        child: Text('Lihat Toko ini')),
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
  }
}
