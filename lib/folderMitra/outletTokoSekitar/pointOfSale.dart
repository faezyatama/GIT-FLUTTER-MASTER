import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import 'package:http/http.dart' as https;
import 'package:intl/intl.dart' as intl;
import '/cetak/cetakPOS.dart';

class PointOfSale extends StatefulWidget {
  @override
  _PointOfSaleState createState() => _PointOfSaleState();
}

class _PointOfSaleState extends State<PointOfSale> {
  final controllerCari = TextEditingController();
  final controllerBayar = TextEditingController();
  final controllerKembali = TextEditingController();

  final c = Get.find<ApiService>();
  bool dataSiap = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var adaDataDitampilkan = 'blank';

  List produkAll = [].obs;
  var pencarianText = false.obs;
  var modeIcon = false.obs;
  var arrPenjualan = [];
  var tampilanThumbnail = true.obs;
  var tampilkanPenjualanList = false.obs;
  var totalbelanja = 0.obs;
  var rpTotalBelanja = '0'.obs;

  FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();

    loadAllProdukToDatabase();
  }

  void _onRefresh() async {
    // monitor network fetch
    order = [];
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Penjualan'),
          backgroundColor: Warna.warnautama,
          actions: [
            (tampilanThumbnail.value == true)
                ? Row(
                    children: [
                      Badge(
                        elevation: 0,
                        position: BadgePosition.topEnd(top: 0, end: 3),
                        animationDuration: Duration(milliseconds: 300),
                        animationType: BadgeAnimationType.fade,
                        badgeColor: (arrPenjualan.length == 0)
                            ? Colors.transparent
                            : Colors.red,
                        badgeContent: Text(
                          arrPenjualan.length.toString(),
                          style: TextStyle(
                              color: (arrPenjualan.length == 0)
                                  ? Colors.transparent
                                  : Colors.white,
                              fontSize: 10),
                        ),
                        child: IconButton(
                            onPressed: () {
                              tampilanThumbnail.value = false;
                              modeIcon.value = true;
                              pencarianText.value = false;
                              controllerCari.text = '';
                              _onRefresh();
                            },
                            icon: Icon(Icons.drag_indicator,
                                size: 27, color: Warna.putih)),
                      ),
                      SizedBox(
                        width: Get.width * 0.12,
                        child: Text('Mode Tampilan',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(color: Warna.putih, fontSize: 10)),
                      )
                    ],
                  )
                : Row(
                    children: [
                      Badge(
                        elevation: 0,
                        position: BadgePosition.topEnd(top: 0, end: 3),
                        animationDuration: Duration(milliseconds: 300),
                        animationType: BadgeAnimationType.fade,
                        badgeColor: (arrPenjualan.length == 0)
                            ? Colors.transparent
                            : Colors.red,
                        badgeContent: Text(
                          arrPenjualan.length.toString(),
                          style: TextStyle(
                              color: (arrPenjualan.length == 0)
                                  ? Colors.transparent
                                  : Colors.white,
                              fontSize: 10),
                        ),
                        child: IconButton(
                            onPressed: () {
                              tampilanThumbnail.value = true;
                              modeIcon.value = false;
                              pencarianText.value = false;
                              controllerCari.text = '';
                              tampilkanPenjualanList.value = true;
                              _onRefresh();
                            },
                            icon: Icon(Icons.shopping_cart,
                                size: 27, color: Warna.putih)),
                      ),
                      SizedBox(
                        width: Get.width * 0.12,
                        child: Text('Mode Tampilan',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(color: Warna.putih, fontSize: 10)),
                      )
                    ],
                  )
          ],
        ),
        bottomNavigationBar: SizedBox(
          height: Get.height * 0.15,
          width: Get.width * 0.99,
          child: Container(
            color: Colors.grey[200],
            child: Column(
              children: [
                Container(
                  color: Colors.grey,
                  height: 1,
                ),
                Container(
                  padding: EdgeInsets.only(left: 11, right: 11),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Padding(padding: EdgeInsets.only(top: 7)),
                          Text(
                            'Jumlah item',
                            style: TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            arrPenjualan.length.toString(),
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w200),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Padding(padding: EdgeInsets.only(top: 7)),
                          Text(
                            'Total Belanja',
                            style: TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            'Rp. ${rpTotalBelanja.value}',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w200),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: Get.width * 0.95,
                  child: Container(
                    child: RawMaterialButton(
                      onPressed: () {
                        if (arrPenjualan.length == 0) {
                          AwesomeDialog(
                            context: Get.context,
                            dialogType: DialogType.warning,
                            animType: AnimType.rightSlide,
                            title: 'PERHATIAN !',
                            desc:
                                'Sepertinya belum ada barang yang dimasukan untuk proses penjualan',
                            btnCancelText: 'OK',
                            btnCancelColor: Colors.amber,
                            btnCancelOnPress: () {},
                          )..show();
                        } else {
                          prosesPembayaran();
                          controllerBayar.text = '';
                          controllerKembali.text = '0';
                          myFocusNode.requestFocus();
                        }
                      },
                      constraints: BoxConstraints(),
                      elevation: 1.0,
                      fillColor: Warna.warnautama,
                      child: Text(
                        'Proses Pembayaran',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      padding: EdgeInsets.fromLTRB(33, 9, 33, 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(22)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Obx(
          () => Stack(children: [
            Container(
                margin: EdgeInsets.only(top: Get.height * 0.14),
                child: SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: true,
                    header: WaterDropHeader(),
                    footer: CustomFooter(
                      builder: (BuildContext context, LoadStatus mode) {
                        Widget body;
                        if (mode == LoadStatus.idle) {
                          body = Text(
                              "Sepertinya semua transaksi telah ditampilkan");
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
                    onLoading: _onRefresh,
                    child: ListView(
                      children: [
                        (tampilkanPenjualanList.value == true)
                            ? listdaftar()
                            : Container(),
                        (tampilkanPenjualanList.value == false)
                            ? Container(
                                padding: EdgeInsets.fromLTRB(22, 63, 22, 2),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'images/nofreshmart.png',
                                      width: Get.width * 0.6,
                                    ),
                                    Text(
                                      'Transaksi Penjualan siap dilakukan',
                                      style: TextStyle(
                                          fontSize: 22, color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'Pilih produk atau cari produk yang akan dijual',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              )
                            : Container()
                      ],
                    ))),
            Container(
              margin: EdgeInsets.only(top: Get.height * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: Get.width * 0.75,
                        child: TextField(
                          style: TextStyle(fontSize: 22),
                          controller: controllerCari,
                          onChanged: (value) {
                            cariProdukDiDatabase(value);
                          },
                          decoration: InputDecoration(
                              labelText: 'Cari Produk',
                              labelStyle: TextStyle(fontSize: 15),
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6))),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                          onPressed: () {
                            scanQR();
                          },
                          icon: Icon(
                            Icons.qr_code,
                            size: 25,
                            color: Warna.grey,
                          )),
                      Text('Scan',
                          style: TextStyle(color: Warna.grey, fontSize: 10))
                    ],
                  ),
                ],
              ),
            ),
            (pencarianText.value == true)
                ? Container(
                    color: Colors.grey[200],
                    margin: EdgeInsets.fromLTRB(11, Get.height * 0.11, 11, 0),
                    child: listPencarian(),
                  )
                : Container(),
            (modeIcon.value == true)
                ? Container(
                    color: Colors.grey[200],
                    margin: EdgeInsets.fromLTRB(5, Get.height * 0.11, 5, 0),
                    child: produkIconMode(),
                  )
                : Container()
          ]),
        ));
  }

  loadAllProdukToDatabase() async {
    bool conn = await cekInternet();
    if (!conn) {
      return;
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var kodeOutlet = c.kodeOutletPOS;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","kodeOutlet":"$kodeOutlet"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLtokosekitar}/mobileAppsOutlet/POSLoadProduk');

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
        dbbox.put(kodeOutlet, response.body);
        produkAll = hasil['dataproduk'];
      } else if (hasil['status'] == 'no data') {
        Get.back();
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: 'PERHATIAN !',
          desc:
              'Opps... sepertinya kamu belum menambahkan produk yang akan dijual',
          btnCancelText: 'OK',
          btnCancelColor: Colors.amber,
          btnCancelOnPress: () {},
        )..show();
      }
    }
  }

  List<Container> order = [];
  listdaftar() {
    var listTemporary = [];
    totalbelanja.value = 0;

    for (var a = 0; a < arrPenjualan.length; a++) {
      var ord = arrPenjualan[a];

      if (listTemporary.contains(ord)) {
      } else {
        //==================hitung jumlah quantity
        var quantity = 0;
        for (var b = 0; b < arrPenjualan.length; b++) {
          var orB = arrPenjualan[b];
          if (orB == ord) {
            quantity = quantity + 1;
          }
        }
        //===================sub jumlah
        var subjumlah = ord[7] * quantity;
        var rpSubJumlah = intl.NumberFormat.decimalPattern().format(subjumlah);
        totalbelanja.value = totalbelanja.value + subjumlah;
        rpTotalBelanja.value =
            intl.NumberFormat.decimalPattern().format(totalbelanja.value);

        order.add(
          Container(
            child: Container(
              margin: EdgeInsets.fromLTRB(11, 5, 11, 5),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            width: Get.width * 0.15,
                            child: CachedNetworkImage(
                                fit: BoxFit.fill,
                                imageUrl: ord[8],
                                errorWidget: (context, url, error) {
                                  print(error);
                                  return Icon(Icons.error);
                                }),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(left: 12)),
                      GestureDetector(
                        onTap: () {},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: Get.width * 0.7,
                              child: Text(
                                ord[1], //name
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Warna.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: Get.width * 0.4,
                                  child: Text(
                                    '$quantity x Rp. ${ord[7]}', //HARGA
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Warna.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w200),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: Get.width * 0.7,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            arrPenjualan.remove(ord);
                                            listdaftar();
                                            _onRefresh();
                                          },
                                          icon: Icon(
                                            Icons.remove_circle_outline,
                                            color: Warna.grey,
                                          )),
                                      Text(
                                        '$quantity', //HARGA
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Warna.grey,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w200),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            arrPenjualan.add(ord);
                                            listdaftar();
                                            _onRefresh();
                                          },
                                          icon: Icon(
                                            Icons.add_circle_outline,
                                            color: Warna.grey,
                                          )),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Rp. ', //HARGA
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Warna.warnautama,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w300),
                                      ),
                                      Text(
                                        '$rpSubJumlah', //HARGA
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Warna.warnautama,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(color: Colors.grey[200], height: 1)
                ],
              ),
            ),
          ),
        );
      }
      listTemporary.add(ord);
    }
    return Column(children: order);
  }

  //INI UNTUK PENCARIAN
  List referensiCari = [];
  List<Container> hasilCari = [];
  listPencarian() {
    for (var a = 0; a < referensiCari.length; a++) {
      var ord = referensiCari[a];

      hasilCari.add(
        Container(
          child: InkWell(
            onTap: () {
              arrPenjualan.add(referensiCari[a]);
              pencarianText.value = false;
              controllerCari.text = '';
              tampilkanPenjualanList.value = true;
              listdaftar();
              _onRefresh();
              setState(() {});
            },
            child: Container(
              margin: EdgeInsets.all(11),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: Get.width * 0.12,
                        child: CachedNetworkImage(
                            fit: BoxFit.fill,
                            imageUrl: ord[8],
                            errorWidget: (context, url, error) {
                              print(error);
                              return Icon(Icons.error);
                            }),
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.only(left: 12)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: Get.width * 0.68,
                        child: Text(
                          ord[1], //name
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Warna.grey,
                              fontSize: 18,
                              fontWeight: FontWeight.w300),
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: Get.width * 0.4,
                            child: Text(
                              'Stok tersedia : ${ord[9]}', //HARGA
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Warna.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w200),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Column(children: hasilCari);
  }

//INI UNTUK MODE ICON
  List<Container> iconArray = [];
  produkIconMode() {
    iconArray = [];
    for (var a = 0; a < produkAll.length; a++) {
      var ord = produkAll[a];

      //==================hitung jumlah quantity
      var quantity = 0;
      var hg = ord[7];
      var hgSatuan = intl.NumberFormat.decimalPattern().format(hg);

      for (var b = 0; b < arrPenjualan.length; b++) {
        var orB = arrPenjualan[b];
        if (orB == ord) {
          quantity = quantity + 1;
        }
      }

      iconArray.add(
        Container(
          child: InkWell(
            onTap: () {
              arrPenjualan.add(produkAll[a]);
              pencarianText.value = false;
              controllerCari.text = '';
              listdaftar();
              _onRefresh();
            },
            child: Container(
              margin: EdgeInsets.all(11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: Get.width * 0.28,
                        child: Badge(
                          elevation: 0,
                          position: BadgePosition.topEnd(top: 3, end: 3),
                          animationDuration: Duration(milliseconds: 300),
                          animationType: BadgeAnimationType.fade,
                          badgeColor:
                              (quantity == 0) ? Colors.transparent : Colors.red,
                          badgeContent: Text(
                            '$quantity',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          child: CachedNetworkImage(
                              fit: BoxFit.fill,
                              imageUrl: ord[8],
                              errorWidget: (context, url, error) {
                                print(error);
                                return Icon(Icons.error);
                              }),
                        ),
                      ),
                      SizedBox(
                        width: Get.width * 0.28,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$hgSatuan', //HARGA
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Warna.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.vertical_split,
                                  size: 12,
                                  color: Colors.blue,
                                ),
                                Text(
                                  ord[9].toString(), //HARGA
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: Get.width * 0.28,
                        child: Text(
                          ord[1], //name
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Warna.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w300),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return GridView.count(
        primary: false,
        padding: const EdgeInsets.all(2),
        childAspectRatio: 0.65,
        crossAxisSpacing: 3,
        mainAxisSpacing: 5,
        crossAxisCount: 3,
        children: iconArray);
  }

  void cariProdukDiDatabase(String value) {
    pencarianText.value = true;
    modeIcon.value = false;
    tampilanThumbnail.value = true;
    print(value);
    referensiCari = [];
    hasilCari = [];

    if (value != '') {
      for (var a = 0; a < produkAll.length; a++) {
        var produk = produkAll[a].toString().toLowerCase();
        if (produk.contains(value.toLowerCase())) {
          print(referensiCari);
          referensiCari.add(produkAll[a]);
        }
      }
    }
    setState(() {});
    _onRefresh();
  }

  Future<void> scanQR() async {
    pencarianText.value = false;
    tampilanThumbnail.value = true;
    modeIcon.value = false;
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);

      var ditemukan = 0;
      if (barcodeScanRes != '') {
        for (var a = 0; a < produkAll.length; a++) {
          var produk = produkAll[a].toString();
          var lPs = produkAll[a];

          if (produk.contains(barcodeScanRes)) {
            arrPenjualan.add(lPs);
            ditemukan = 1;
            tampilkanPenjualanList.value = true;
            _onRefresh();
            break;
          }
        }
      }

      if (barcodeScanRes != '-1') {
        if (ditemukan == 0) {
          AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.error,
            animType: AnimType.topSlide,
            title: 'BARCODE SCANNER',
            desc:
                'Produk tidak ditemukan, pastikan kamu sudah memasukan barcode pada data produk',
            btnOkText: 'OK SIAP',
            btnOkColor: Colors.red,
            btnOkOnPress: () {},
          )..show();
        }
      }
      _onRefresh();
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
  }

  void prosesPembayaran() {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      body: Container(
        child: Column(
          children: [
            Text('Total Belanja',
                style: TextStyle(
                  color: Warna.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                )),
            Text('Rp. ${rpTotalBelanja.value}',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 28,
                  fontWeight: FontWeight.w200,
                )),
            Text('${arrPenjualan.length.toString()} Item/Produk',
                style: TextStyle(
                  color: Warna.grey,
                  fontSize: 14,
                )),
            Padding(padding: EdgeInsets.only(top: 22)),
            Text('Pembayaran',
                style: TextStyle(
                  color: Warna.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                )),
            Container(
              margin: EdgeInsets.fromLTRB(12, 0, 12, 0),
              child: TextField(
                enabled: true,
                autofocus: true,
                focusNode: myFocusNode,
                style: TextStyle(fontSize: 22),
                keyboardType: TextInputType.number,
                controller: controllerBayar,
                inputFormatters: [
                  TextInputMask(
                      mask: ['999.999.999.999', '999.999.9999.999'],
                      reverse: true)
                ],
                onChanged: (value) {
                  var nominal = value.replaceAll('.', '');
                  var kembalian = (int.parse(nominal) - totalbelanja.value);
                  var rep =
                      intl.NumberFormat.decimalPattern().format(kembalian);

                  controllerKembali.text = rep.replaceAll(',', '.');
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.payments),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6))),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 22)),
            Text('Uang Kembali',
                style: TextStyle(
                  color: Warna.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                )),
            Container(
              margin: EdgeInsets.fromLTRB(12, 0, 12, 0),
              child: TextField(
                enabled: false,
                style: TextStyle(fontSize: 22),
                controller: controllerKembali,
                onChanged: (value) {},
                inputFormatters: [
                  TextInputMask(
                      mask: ['999.999.999.999', '999.999.9999.999'],
                      reverse: true)
                ],
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.money),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6))),
              ),
            ),
          ],
        ),
      ),
      btnOkText: 'BAYAR TRANSAKSI INI',
      btnOkColor: Colors.green,
      btnOkOnPress: () {
        var rr = controllerKembali.text.replaceAll('.', '');
        var uangkembali = int.parse(rr);
        if ((uangkembali >= 0) && (controllerBayar.text != "")) {
          prosesPenjualanBarang();
        } else {
          Get.snackbar(
              'Pembayaran Kurang', 'Opps...sepertinya pembayarannya kurang');
        }
      },
    )..show();
  }

  void prosesPenjualanBarang() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');

    //KONSTRKTOR DATA PENJUALAN

    var itemIDD = [];
    var finalPembelian = [];
    var produkNew = [];
    for (var a = 0; a < arrPenjualan.length; a++) {
      var itemId = arrPenjualan[a][0];
      if (itemIDD.contains(itemId)) {
      } else {
        var produk = arrPenjualan[a];
        var quantity = 0;
        for (var b = 0; b < arrPenjualan.length; b++) {
          if (arrPenjualan[b] == produk) {
            quantity = quantity + 1;
          }
        }
        produk.add(quantity);
        produkNew.add(produk);
        itemIDD.add(itemId);
        finalPembelian.add(produk);
      }
    }
    var arrJual = jsonEncode(finalPembelian);

    //END KONSTRUKTER
    var totalB = rpTotalBelanja.value;
    var bayarB = controllerBayar.text;
    var kembaliB = controllerKembali.text;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","totalB":"$totalB","bayarB":"$bayarB","kembaliB":"$kembaliB"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLtokosekitar}/mobileAppsOutlet/prosesPenjualanOffline');

    final response = await https.post(url, body: {
      "user": user,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName,
      "dataJual": arrJual
    });

    // EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        //PINDAHKAN TRANSAKSI UNTUK DICETAK
        //DateTime now = DateTime.now();
        // String formattedDate = DateFormat('EEE d MMM, kk:mm:ss ').format(now);
        c.dataCetakStruk = arrPenjualan;
        c.tanggalPOS = hasil['tanggal'];
        c.bayarRp = hasil['bayar'];
        c.kembaliRp = hasil['kembali'];
        c.totalRp = hasil['total'];
        c.nomorTransaksiPOS = hasil['kodeTransaksi'];
        arrPenjualan = [];
        rpTotalBelanja.value = '0';
        listdaftar();
        _onRefresh();

        AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.success,
            animType: AnimType.bottomSlide,
            title: 'TRANSAKSI BERHASIL',
            desc:
                'Transaksi berhasil disimpan, Apakah kamu mau mencetak transaksi ini ?',
            btnOkOnPress: () {
              Get.to(() => TTcetakPOS());
            },
            btnOkText: 'Cetak Struk',
            btnCancelOnPress: () {},
            btnCancelText: 'Tidak')
          ..show();
      } else {
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.bottomSlide,
          title: 'TRANSAKSI GAGAL',
          desc: hasil['message'],
          btnOkOnPress: () {},
          btnOkText: 'Periksa kembali',
        )..show();
      }
    }
  }
}
