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
import '../samakan/outletmakan.dart';
import 'cekoutKeranjang.dart';

class EtalaseMakanan extends StatefulWidget {
  @override
  _EtalaseMakananState createState() => _EtalaseMakananState();
}

class _EtalaseMakananState extends State<EtalaseMakanan> {
  final c = Get.find<ApiService>();

  TextEditingController textController = TextEditingController();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var paginate = 0;
  var loaddata = false;
  var filtercari = '';
  var filterkategori = '';
  var loadkategori = '';
  var filtertoko = '';
  var waitCari = DateTime.now().add(const Duration(seconds: 2));
  var fungsiPencarian = false;

  @override
  void initState() {
    super.initState();
    textController.addListener(_pencarianFungsi);

    cekDataBarang();
  }

  void _onRefresh() async {
    listdatabarang = [];
    paginate = 0;
    cekDataBarang();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await cekDataBarang();
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  var yangDIcari = '';
  void _pencarianFungsi() {
    print(textController.text);

    if (textController.text == '') {
      fungsiPencarian = false;
    } else {
      if (textController.text.length > 2) {
        assert(DateTime.now().isAfter(waitCari) == true);
        waitCari = DateTime.now().add(const Duration(seconds: 2));
        print(textController.text);
        if (textController.text != yangDIcari) {
          print(yangDIcari);
          queryPencarian();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Makanan'),
          backgroundColor: Warna.warnautama,
          actions: [
            AnimSearchBar(
              helpText: '',
              suffixIcon: Icon(
                Icons.close,
                color: Warna.warnautama,
              ),
              autoFocus: true,
              closeSearchOnSuffixTap: false,
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
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(5),
          //height: Get.height * 0.08,
          child: RawMaterialButton(
            onPressed: () {
              if (c.hargaKeranjang.value > 0) {
                Get.to(() => LokasidanKeranjangMK());
              }
            },
            constraints: BoxConstraints(),
            elevation: 1.0,
            fillColor: Warna.warnautama,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                          '${c.keranjangMakan.length} item',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w300,
                              color: Warna.putih),
                        )),
                    Obx(() => SizedBox(
                          width: Get.width * 0.4,
                          child: Text(
                            c.namaoutletpadakeranjang.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Warna.putih, fontSize: 12),
                          ),
                        )),
                  ],
                ),
                Row(
                  children: [
                    Obx(() => Text(
                          'Rp. ${c.hargaKeranjang.value},-',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w300,
                              color: Warna.putih),
                        )),
                    Icon(
                      Icons.shopping_cart,
                      size: 33,
                      color: Colors.white,
                    )
                  ],
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(33)),
            ),
          ),
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
                    Container(
                      padding: EdgeInsets.all(22),
                      child: Text(
                        'Pilih kategori makanan kesukaanmu, dan makanan favorit segera datang',
                        style: TextStyle(
                            color: Warna.warnautama,
                            fontSize: 29,
                            fontWeight: FontWeight.w300),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: (loaddata == true) ? listkategori() : Center(),
                    ),
                    (loaddata == true) ? listdaftar() : Center(),
                  ],
                ),
              )
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
    jsonDataBarang = [];
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    await determinePosition();
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

    var url = Uri.parse('${c.baseURLmakan}/mobileAppsUser/cekProdukMakanan');

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
        jsonDataBarang = hasil['data'];
        kategori = hasil['kategori'];
        loadkategori = 'sudah';
        if (mounted) {
          setState(() {
            loaddata = true;
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

  listdaftar() {
    if (jsonDataBarang.length > 0) {
      for (var i = 0; i < jsonDataBarang.length; i++) {
        var valHistory = jsonDataBarang[i];

        listdatabarang.add(
          Container(
              // width: Get.width * 0.45,
              child: Container(
            child: Card(
                elevation: 0,
                //color: Colors.lightGreen[50],
                margin: EdgeInsets.all(5),
                child: InkWell(
                  onTap: () {
                    c.idOutletPilihan.value = valHistory[1].toString();

                    if ((c.idOutletpadakeranjangMakan.value ==
                            c.idOutletPilihan.value) ||
                        (c.idOutletpadakeranjangMakan.value == '0')) {
                      c.namaOutlet.value = valHistory[7];
                      c.namaPreview.value = valHistory[2];
                      c.gambarPreview.value = valHistory[12];
                      c.gambarPreviewhiRess.value = valHistory[13];
                      c.namaoutletPreview.value = valHistory[7];
                      c.hargaPreview.value = valHistory[5];
                      c.lokasiPreview.value = valHistory[4];
                      c.itemidPreview.value = valHistory[10];
                      c.deskripsiPreview.value = valHistory[11];

                      c.helper2.value = valHistory[12];
                      c.helper5.value = valHistory[8];
                      c.helper7.value = valHistory[10].toString();

                      Get.to(() => DetailOtletMakan());
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
                                'Sepertinya kamu ingin berpindah ke outlet lain, Boleh kok, keranjang di outlet sebelumnya kami hapus ya...',
                                style:
                                    TextStyle(fontSize: 14, color: Warna.grey),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 16)),
                            Container(
                              padding: EdgeInsets.only(left: 22, right: 22),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      child: Text('Tidak jadi')),
                                  ElevatedButton(
                                      onPressed: () {
                                        c.idOutletpadakeranjangMakan.value =
                                            '0';
                                        c.jumlahItem.value = 0;
                                        c.hargaKeranjang.value = 0;
                                        c.keranjangMakan.clear();
                                        c.idOutletPilihan.value =
                                            valHistory[1].toString();
                                        c.namaOutlet.value = valHistory[7];
                                        c.namaoutletpadakeranjang.value =
                                            'dalam keranjangmu';

                                        c.namaOutlet.value = valHistory[7];
                                        c.namaPreview.value = valHistory[2];
                                        c.gambarPreview.value = valHistory[12];
                                        c.gambarPreviewhiRess.value =
                                            valHistory[13];
                                        c.namaoutletPreview.value =
                                            valHistory[7];
                                        c.hargaPreview.value = valHistory[5];
                                        c.lokasiPreview.value = valHistory[4];
                                        c.itemidPreview.value = valHistory[10];
                                        c.deskripsiPreview.value =
                                            valHistory[11];

                                        Get.off(DetailOtletMakan());
                                      },
                                      child: Text('Ok Ganti')),
                                ],
                              ),
                            )
                          ],
                        ),
                      )..show();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        CachedNetworkImage(
                            width: Get.width * 0.25,
                            height: Get.width * 0.25,
                            imageUrl: valHistory[3],
                            errorWidget: (context, url, error) {
                              print(error);
                              return Icon(Icons.error);
                            }),
                        Padding(
                            padding: EdgeInsets.only(left: Get.width * 0.01)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: Get.width * 0.50,
                              child: Text(
                                valHistory[7],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style:
                                    TextStyle(fontSize: 19, color: Warna.grey),
                              ),
                            ),
                            SizedBox(
                              width: Get.width * 0.55,
                              child: Text(
                                valHistory[2],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style:
                                    TextStyle(fontSize: 12, color: Warna.grey),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 22)),
                            Text(
                              valHistory[5],
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Warna.grey,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.left,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  valHistory[4],
                                  style: TextStyle(
                                      fontSize: 10, color: Warna.grey),
                                ),
                                Padding(padding: EdgeInsets.only(left: 11)),
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
                  ),
                )),
          )),
        );
      }
    }
    return Column(
      children: listdatabarang,
    );
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
                    filtertoko = '';
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

  void queryPencarian() async {
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var cari = textController.text;
    var latitude = c.latitude.value;
    var longitude = c.longitude.value;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","lat":"$latitude","long":"$longitude","cari":"$cari"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLmakan}/mobileAppsUser/pencarianMK');

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
              paginate = 0;
              listdatabarang = [];
              filtertoko = aaaa[2].toString();
              filtercari = '';
              filterkategori = '';
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
