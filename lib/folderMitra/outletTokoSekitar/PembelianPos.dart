import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import 'package:http/http.dart' as https;
import 'package:intl/intl.dart' as intl;
import 'LaporanBeli.dart';
import 'supplierPOS.dart';

class PembelianPOS extends StatefulWidget {
  @override
  _PembelianPOSState createState() => _PembelianPOSState();
}

class _PembelianPOSState extends State<PembelianPOS> {
  final controllerCari = TextEditingController();
  final controllerBayar = TextEditingController();
  final controllerKembali = TextEditingController();
  final controllerQuantity = TextEditingController();
  final controllerHPP = TextEditingController();
  var tanggalView = 'Hari ini'.obs;
  var tanggalSend = 'Hari ini';

  final c = Get.find<ApiService>();
  bool dataSiap = false;
  var persentaseKeuntungan = 0.0.obs;

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
  FocusNode myFocusNodeQuantity;

  //value pembayaran
  var valLunas = true.obs;
  var valKredit = false.obs;
  var valKonsinyasi = false.obs;
  var pembayaranTerpilih = 'Lunas';

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
          title: Text('Pembelian & Tambah Stok'),
          backgroundColor: Colors.green,
        ),
        bottomNavigationBar: SizedBox(
          height: Get.height * 0.17,
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
                      Text(
                        'Supplier :',
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      Obx(() => Text(
                            c.pilihanSupplierTS.value,
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600),
                          ))
                    ],
                  ),
                ),
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
                                fontSize: 27, fontWeight: FontWeight.w200),
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
                                fontSize: 27, fontWeight: FontWeight.w200),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  child: RawMaterialButton(
                    onPressed: () {
                      if (arrPenjualan.length > 0) {
                        prosesPembayaran();
                      } else {
                        Get.snackbar('Tidak dapat diproses',
                            'Belum ada barang yang akan dibeli atau ditambahkan stoknya',
                            snackPosition: SnackPosition.BOTTOM);
                      }
                    },
                    // constraints: BoxConstraints(),
                    fillColor: Colors.green,
                    child: Text(
                      'Proses input pembelian',
                      style: TextStyle(color: Warna.putih, fontSize: 16),
                    ),
                    padding: EdgeInsets.fromLTRB(55, 7, 55, 7),
                  ),
                )
              ],
            ),
          ),
        ),
        body: Obx(
          () => Stack(children: [
            Container(
                margin: EdgeInsets.only(top: Get.height * 0.13),
                child: SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: true,
                    header: WaterDropHeader(),
                    footer: CustomFooter(
                      builder: (BuildContext context, LoadStatus mode) {
                        Widget body;
                        if (mode == LoadStatus.idle) {
                          body = Text("");
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
                                      width: Get.width * 0.55,
                                    ),
                                    Text(
                                      'Transaksi Pembelian dan penambahan stok siap dilakukan',
                                      style: TextStyle(
                                          fontSize: 22, color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'Pilih produk atau cari produk yang dibeli atau yang ingin ditambahkan stoknya',
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
              margin: EdgeInsets.only(top: Get.height * 0.03),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: Get.width * 0.5,
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
                  (tampilanThumbnail.value == true)
                      ? Column(
                          children: [
                            IconButton(
                                onPressed: () {
                                  tampilanThumbnail.value = false;
                                  modeIcon.value = true;
                                  pencarianText.value = false;
                                  controllerCari.text = '';
                                  _onRefresh();
                                },
                                icon: Icon(
                                  Icons.drag_indicator,
                                  size: 25,
                                  color: Warna.grey,
                                )),
                            Text('View',
                                style:
                                    TextStyle(color: Warna.grey, fontSize: 10))
                          ],
                        )
                      : Column(
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
                                    color: Colors.white, fontSize: 10),
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
                                      size: 27, color: Warna.warnautama)),
                            ),
                            Text('Cart',
                                style: TextStyle(
                                    color: Warna.warnautama, fontSize: 10))
                          ],
                        ),
                  Column(
                    children: [
                      IconButton(
                          onPressed: () {
                            Get.to(() => SupplierPOS());
                          },
                          icon: Icon(
                            Icons.person,
                            size: 25,
                            color: Warna.grey,
                          )),
                      Text('Supplier',
                          style: TextStyle(color: Warna.grey, fontSize: 10))
                    ],
                  ),
                ],
              ),
            ),
            (pencarianText.value == true)
                ? Container(
                    color: Colors.grey[200],
                    margin: EdgeInsets.fromLTRB(11, Get.height * 0.15, 11, 0),
                    child: listPencarian(),
                  )
                : Container(),
            (modeIcon.value == true)
                ? Container(
                    color: Colors.grey[200],
                    margin: EdgeInsets.fromLTRB(5, Get.height * 0.15, 5, 0),
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
    var kodeOutlet = 'TS-$pid';
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
        var subjumlah = ord[10] * quantity;
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
                                      GestureDetector(
                                        onTap: () {
                                          controllerQuantity.text =
                                              quantity.toString();
                                          inputQuantityManual(ord);
                                        },
                                        child: Text(
                                          '$quantity', //HARGA
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Warna.grey,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w200),
                                        ),
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
                                  GestureDetector(
                                    onTap: () {
                                      controllerHPP.text = ord[10].toString();
                                      var hppModal = ord[10];
                                      var hargaJual = ord[7];
                                      var selisih = (hargaJual - hppModal);
                                      persentaseKeuntungan.value =
                                          (selisih / hargaJual * 100);
                                      ubahHPPProduk(ord, quantity);
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'HPP :   Rp. ${ord[10]}', //HARGA
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Warna.warnautama,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300),
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
      var hg = ord[10];
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
          '#ff6666', 'Cancel', false, ScanMode.QR);

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
          padding: EdgeInsets.all(11),
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
              Padding(padding: EdgeInsets.only(top: 33)),
              Text('Metode Pembayaran',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: Get.width * 0.4,
                    child: Text('Lunas',
                        style: TextStyle(color: Warna.grey, fontSize: 16)),
                  ),
                  Obx(() => Checkbox(
                        value: valLunas.value,
                        onChanged: (newValue) {
                          pilihanPembayaran('Lunas', newValue);
                        },
                      )),
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: Get.width * 0.4,
                    child: Text('Kredit',
                        style: TextStyle(color: Warna.grey, fontSize: 16)),
                  ),
                  Obx(() => Checkbox(
                        value: valKredit.value,
                        onChanged: (newValue) {
                          pilihanPembayaran('Kredit', newValue);
                        },
                      )),
                ],
              ),
              Obx(() => Container(
                    child: (valKredit.value == true)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Jatuh tempo',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.blue),
                              ),
                              RawMaterialButton(
                                onPressed: () {
                                  DatePicker.showDatePicker(context,
                                      showTitleActions: true,
                                      minTime: DateTime(2021, 1, 1),
                                      maxTime: DateTime(2031, 12, 31),
                                      onChanged: (date) {
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
                                  },
                                      currentTime: DateTime.now(),
                                      locale: LocaleType.id);
                                },
                                constraints: BoxConstraints(),
                                elevation: 1.0,
                                fillColor: Colors.white,
                                child: Obx(() => Text(
                                      tanggalView.value,
                                      style: TextStyle(
                                          color: Colors.blue, fontSize: 14),
                                    )),
                                padding: EdgeInsets.fromLTRB(12, 2, 12, 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(9)),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  )),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: Get.width * 0.4,
                    child: Text('Konsinyasi',
                        style: TextStyle(color: Warna.grey, fontSize: 16)),
                  ),
                  Obx(() => Checkbox(
                        value: valKonsinyasi.value,
                        onChanged: (newValue) {
                          pilihanPembayaran('Konsinyasi', newValue);
                        },
                      )),
                ],
              ),
            ],
          ),
        ),
        btnOkText: 'PROSES TRANSAKSI INI',
        btnOkColor: Colors.green,
        btnOkOnPress: () {
          prosesInputPembelianNow();
        })
      ..show();
  }

  inputQuantityManual(barang) {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.topSlide,
      body: TextField(
        style: TextStyle(fontSize: 22),
        controller: controllerQuantity,
        autofocus: true,
        focusNode: myFocusNodeQuantity,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.add),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6))),
        onChanged: (value) {},
      ),
      btnOkOnPress: () {
        //HAPUS BARANG DI KERANJANG
        arrPenjualan.removeWhere((element) => element == barang);
        //TAMBAHKAN BARANG DI KERJANGAN
        var jumlahQ = int.parse(controllerQuantity.text);
        for (var a = 0; a < jumlahQ; a++) {
          arrPenjualan.add(barang);
        }
        _onRefresh();
      },
      btnOkText: 'Atur Quantity',
    )..show();
  }

  void ubahHPPProduk(hpp, jumlahQ) {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.topSlide,
      body: Container(
        margin: EdgeInsets.fromLTRB(11, 2, 11, 2),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: Get.width * 0.23,
                  child: CachedNetworkImage(
                      fit: BoxFit.fill,
                      imageUrl: hpp[8],
                      errorWidget: (context, url, error) {
                        print(error);
                        return Icon(Icons.error);
                      }),
                ),
                Padding(padding: EdgeInsets.only(left: 11)),
                SizedBox(
                  width: Get.width * 0.4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nama Produk',
                          style: TextStyle(
                            color: Warna.grey,
                            fontSize: 10,
                          )),
                      Text(hpp[1],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      Text('Harga Jual',
                          style: TextStyle(
                            color: Warna.grey,
                            fontSize: 10,
                          )),
                      Text('Rp. ${hpp[7]}',
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      Text('Persen Keuntungan',
                          style: TextStyle(
                            color: Warna.grey,
                            fontSize: 12,
                          )),
                      Obx(() => Text(
                          persentaseKeuntungan.value.toStringAsFixed(1) + ' %',
                          style: TextStyle(
                              color: (persentaseKeuntungan.value < 0)
                                  ? Colors.red
                                  : Colors.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 22)),
            Text('Harga Modal / HPP',
                style: TextStyle(
                  color: Warna.grey,
                  fontSize: 12,
                )),
            TextField(
              style: TextStyle(fontSize: 22),
              controller: controllerHPP,
              autofocus: true,
              focusNode: myFocusNodeQuantity,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.payment),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6))),
              onChanged: (value) {
                if (controllerHPP.text != '') {
                  var hppnew = int.parse(controllerHPP.text);
                  var hargaJual = hpp[7];
                  var selisih = (hargaJual - hppnew);
                  persentaseKeuntungan.value = (selisih / hargaJual * 100);
                }
              },
            ),
          ],
        ),
      ),
      btnOkOnPress: () {
        //filter dulu
        if (controllerHPP.text == '') {
          return;
        }
        // kalau harga beli lebih mahal dari harga jual
        if (persentaseKeuntungan.value < 0) {
          Get.snackbar('Error !!!',
              'Harga modal sepertinya lebih besar dari Harga Jual, Atur kembali harga jual agar tidak mengalami kerugian');
          return;
        }
        //EKSEKUSI PERUBAHAN HPP LOKAL
        //HAPUS BARANG DI KERANJANG
        arrPenjualan.removeWhere((element) => element == hpp);
        //TAMBAHKAN BARANG DI KERJANGAN
        hpp[10] = int.parse(controllerHPP.text);

        for (var a = 0; a < jumlahQ; a++) {
          arrPenjualan.add(hpp);
        }
        _onRefresh();

        hpp[10] = int.parse(controllerHPP.text);
      },
      btnOkText: 'Atur Harga Modal / HPP',
    )..show();
  }

  void prosesInputPembelianNow() async {
    bool conn = await cekInternet();
    if (!conn) {
      return;
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var kodeOutlet = 'TS-$pid';
    var suplier = c.pilihanSupplierTS.value;

    //KONSTRKTOR DATA PEMBELIAN
    var itemIDD = [];
    var finalPembelian = [];
    var produkNew = [];
    for (var a = 0; a < arrPenjualan.length; a++) {
      var itemId = arrPenjualan[a][0];
      if (itemIDD.contains(itemId)) {
      } else {
        //hitung jumlah
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

    var arrPembelian = jsonEncode(finalPembelian);
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","jatuhTempo":"$tanggalSend","metodeBayar":"$pembayaranTerpilih","suplier":"$suplier","kodeOutlet":"$kodeOutlet"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();
    var url = Uri.parse(
        '${c.baseURLtokosekitar}/mobileAppsOutlet/transaksiPembelianPOS');

    final response = await https.post(url, body: {
      "user": user,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName,
      "dataBeli": arrPembelian
    });

    // EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        Get.back();
        Get.to(() => LaporanPembelianProduk());
      } else if (hasil['status'] == 'failed') {
        Get.back();
        Get.snackbar('Error', 'Proses pembelian gagal dilakukan');
      }
    }
  }

  void pilihanPembayaran(String s, bool newValue) {
    //all off
    if (newValue == true) {
      valLunas.value = false;
      valKredit.value = false;
      valKonsinyasi.value = false;
      if (s == 'Kredit') {
        valKredit.value = true;
        pembayaranTerpilih = 'Kredit';
      } else if (s == 'Konsinyasi') {
        valKonsinyasi.value = true;
        pembayaranTerpilih = 'Konsinyasi';
        tanggalView.value = 'Hari ini';
        tanggalSend = 'Hari ini';
      } else if (s == 'Lunas') {
        valLunas.value = true;
        pembayaranTerpilih = 'Lunas';
        tanggalView.value = 'Hari ini';
        tanggalSend = 'Hari ini';
      }
    } else {
      pembayaranTerpilih = 'Lunas';
      valLunas.value = true;
      valKredit.value = false;
      valKonsinyasi.value = false;
      tanggalView.value = 'Hari ini';
      tanggalSend = 'Hari ini';
    }
  }
}
