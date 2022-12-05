import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as https;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../base/notifikasiBuatAkun.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../folderUmum/chat/view/chatDetailPage.dart';
import '../marketplace/detailToko.dart';
import 'package:share/share.dart';
import 'cekoutKeranjang.dart';
import 'fotoProdukLainnya.dart';

class DetailOtletMarketplace extends StatefulWidget {
  @override
  _DetailOtletMarketplaceState createState() => _DetailOtletMarketplaceState();
}

class _DetailOtletMarketplaceState extends State<DetailOtletMarketplace> {
  final c = Get.find<ApiService>();

  List keranjangMakan = [];
  List dataOutlet = [];
  List dataBarang = [];
  bool dataSiap = false;
  var jarak = '00'.obs;
  var dilihat = '00'.obs;
  var terjual = 'Terjual'.obs;
  var hargaCoret = 'Rp.0'.obs;
  var hargaDiskon = ''.obs;
  var expedisi1 = ''.obs;
  var expedisi2 = ''.obs;
  var expedisi3 = ''.obs;
  var expedisi4 = ''.obs;
  var expedisi5 = ''.obs;
  var expedisi6 = ''.obs;

  var idchat = '0';

  int jumlah = 1;

  get http => null;

  tambahJumlah() {
    setState(() {
      jumlah = jumlah + 1;
    });
  }

  void kurangiJumlah() {
    if (jumlah > 1) {
      setState(() {
        jumlah = jumlah - 1;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    detailProduk();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SpeedDial(
        /// both default to 16
        // marginEnd: 18,
        // marginBottom: Get.height * 0.36,
        // animatedIcon: AnimatedIcons.menu_close,
        // animatedIconTheme: IconThemeData(size: 22.0),
        /// This is ignored if animatedIcon is non null
        icon: Icons.auto_awesome,
        activeIcon: Icons.remove,
        // iconTheme: IconThemeData(color: Colors.grey[50], size: 30),
        /// The label of the main button.
        // label: Text("Open Speed Dial"),
        /// The active label of the main button, Defaults to label if not specified.
        // activeLabel: Text("Close Speed Dial"),
        /// Transition Builder between label and activeLabel, defaults to FadeTransition.
        // labelTransitionBuilder: (widget, animation) => ScaleTransition(scale: animation,child: widget),
        /// The below button size defaults to 56 itself, its the FAB size + It also affects relative padding and other elements
        // buttonSize: 56.0,
        visible: true,

        /// If true user is forced to close dial manually
        /// by tapping main button and overlay is not rendered.
        closeManually: false,

        /// If true overlay will render no matter what.
        renderOverlay: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        onOpen: () => print('OPENING DIAL'),
        onClose: () => print('DIAL CLOSED'),
        tooltip: 'Speed Dial',
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 8.0,
        shape: CircleBorder(),
        // orientation: SpeedDialOrientation.Up,
        // childMarginBottom: 2,
        // childMarginTop: 2,
        children: [
          SpeedDialChild(
            child: Icon(Icons.chat),
            backgroundColor: Colors.amber,
            label: 'Chat ke Outlet',
            labelStyle: TextStyle(fontSize: 16.0, color: Warna.grey),
            onTap: () {
              //TAMU OR MEMBER
              if (c.loginAsPenggunaKita.value == 'Member') {
                //c.idChatLawan.value = idchat;
                c.namaChatLawan.value = c.namaMPC.value;
                c.fotoChatLawan.value = c.gambarMPC.value;
                //print(c.idChatLawan.value);
                Get.to(() => ChatDetailPage());
              } else {
                var judulF = 'Akun ${c.namaAplikasi} Dibutuhkan ?';

                var subJudul =
                    'Yuk Buka akun ${c.namaAplikasi} sekarang, hanya beberapa langkah akun kamu sudah aktif loh...';

                bukaLoginPage(judulF, subJudul);
              }
              //END TAMU OR MEMBER
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.favorite),
            backgroundColor: Colors.blue[300],
            label: 'Suka / Wishlist',
            labelStyle: TextStyle(fontSize: 16.0, color: Warna.grey),
            onTap: () {
              //TAMU OR MEMBER
              if (c.loginAsPenggunaKita.value == 'Member') {
                sukaProdukIni();
                Get.snackbar(
                    c.namaMPC.value, 'Terima kasih telah menyukai produk ini');
              } else {
                var judulF = 'Akun ${c.namaAplikasi} Dibutuhkan ?';
                var subJudul =
                    'Yuk Buka akun ${c.namaAplikasi} sekarang, hanya beberapa langkah akun kamu sudah aktif loh...';

                bukaLoginPage(judulF, subJudul);
              }
              //END TAMU OR MEMBER
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.share),
            backgroundColor: Colors.pink[300],
            label: 'Bagikan produk ini ke teman',
            labelStyle: TextStyle(fontSize: 16.0, color: Warna.grey),
            onTap: () {
              Box dbbox = Hive.box<String>('sasukaDB');
              var sscode = dbbox.get('kodess');
              var produkUR =
                  c.namaMPC.value.replaceAll(RegExp('[^A-Za-z0-9]'), '-');
              var url =
                  'https://my.satuaja.id?product=${c.itemIdMPC.value}&pr=$produkUR&promo=$sscode';
              Share.share(url, subject: 'Share Transaksi');
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(5),
        child: RawMaterialButton(
          onPressed: () {
            //TAMU OR MEMBER
            if (c.loginAsPenggunaKita.value == 'Member') {
              if (c.hargaKeranjangMP.value > 0) {
                Get.to(() => LokasidanKeranjangMP());
              }
            } else {
              var judulF = 'Akun ${c.namaAplikasi} Dibutuhkan ?';
              var subJudul =
                  'Yuk Buka akun ${c.namaAplikasi} sekarang, hanya beberapa langkah akun kamu sudah aktif loh...';

              bukaLoginPage(judulF, subJudul);
            }
            //END TAMU OR MEMBER
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
                        '${c.jumlahItemMP.value} item',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w300,
                            color: Warna.putih),
                      )),
                  Obx(() => SizedBox(
                        width: Get.width * 0.35,
                        child: Text(
                          c.namaoutletpadakeranjangMP.value,
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
                        'Rp. ${c.hargaKeranjangMP.value},-',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w300,
                            color: Warna.putih),
                      )),
                  Icon(
                    Icons.shopping_cart,
                    size: 25,
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
      body: Stack(
        children: [
          ListView(
            children: [
              FotoProdukLain(),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(11, 16, 11, 18),
                    child: Column(
                      children: [
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          child: Container(
                            padding: EdgeInsets.all(3),
                            child: Column(
                              children: [
                                //
                                Obx(() => Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: Get.width * 0.65,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                c.namaMPC.value,
                                                style: TextStyle(
                                                    fontSize: 23,
                                                    color: Warna.grey,
                                                    fontWeight:
                                                        FontWeight.w300),
                                                textAlign: TextAlign.left,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    c.hargaMPC.value,
                                                    style: TextStyle(
                                                        fontSize: 24,
                                                        color: Colors.amber,
                                                        fontWeight:
                                                            FontWeight.w300),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                // row harga coret
                                                children: [
                                                  (hargaCoret.value == 'Rp.0')
                                                      ? Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 1))
                                                      : Text(
                                                          hargaCoret.value,
                                                          style: TextStyle(
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough,
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300),
                                                          textAlign:
                                                              TextAlign.left,
                                                        ),
                                                  (hargaCoret.value == 'Rp.0')
                                                      ? Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 1))
                                                      : Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                          size: 14,
                                                        ),
                                                  (hargaCoret.value == 'Rp.0')
                                                      ? Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 1))
                                                      : Text(
                                                          hargaDiskon.value,
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300),
                                                          textAlign:
                                                              TextAlign.left,
                                                        ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: Get.width * 0.22,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    c.beratMPC.value,
                                                    style: TextStyle(
                                                        color: Warna.grey),
                                                  ),
                                                  Icon(
                                                    Icons.shopping_bag,
                                                    color: Warna.grey,
                                                    size: 18,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    terjual.value,
                                                    style: TextStyle(
                                                        color: Warna.grey),
                                                  ),
                                                  Icon(
                                                    Icons.local_offer,
                                                    color: Warna.grey,
                                                    size: 18,
                                                  ),
                                                ],
                                              ),
                                              RawMaterialButton(
                                                onPressed: () {
                                                  //TAMU OR MEMBER
                                                  if (c.loginAsPenggunaKita
                                                          .value ==
                                                      'Member') {
                                                    var jb = 0;
                                                    for (var i = 0;
                                                        i <
                                                            c.keranjangMP
                                                                .length;
                                                        i++) {
                                                      if (c.keranjangMP[i] ==
                                                          c.itemIdMPC.value
                                                              .toString()) {
                                                        jb++;
                                                      }
                                                    }
                                                    c.jumlahBarangMP.value = jb;
                                                    print(c.hargaIntMPC.value);
                                                    tambahKeKeranjang(
                                                        c.gambarMPC.value,
                                                        c.namaMPC.value,
                                                        c.deskripsiMPC.value,
                                                        c.hargaMPC.value,
                                                        c.itemIdMPC.value,
                                                        c.hargaIntMPC.value,
                                                        c.idOutletMPC.value);
                                                  } else {
                                                    var judulF =
                                                        'Akun ${c.namaAplikasi} Dibutuhkan ?';
                                                    var subJudul =
                                                        'Yuk Buka akun ${c.namaAplikasi} sekarang, hanya beberapa langkah akun kamu sudah aktif loh...';

                                                    bukaLoginPage(
                                                        judulF, subJudul);
                                                  }
                                                  //END TAMU OR MEMBER
                                                },
                                                constraints: BoxConstraints(),
                                                elevation: 0.0,
                                                fillColor: Warna.warnautama,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .shopping_cart_outlined,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      'Tambah',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                                padding: EdgeInsets.all(4.0),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(9)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    )),
                                Padding(padding: EdgeInsets.only(top: 5)),
                                Obx(() => Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        (expedisi1.value == '')
                                            ? Container()
                                            : Image.network(
                                                expedisi1.value,
                                                height: 17,
                                                width: Get.width * 0.12,
                                              ),
                                        (expedisi2.value == '')
                                            ? Container()
                                            : Image.network(
                                                expedisi2.value,
                                                height: 17,
                                                width: Get.width * 0.12,
                                              ),
                                        (expedisi3.value == '')
                                            ? Container()
                                            : Image.network(
                                                expedisi3.value,
                                                height: 17,
                                                width: Get.width * 0.12,
                                              ),
                                        (expedisi4.value == '')
                                            ? Container()
                                            : Image.network(
                                                expedisi4.value,
                                                height: 17,
                                                width: Get.width * 0.12,
                                              ),
                                        (expedisi5.value == '')
                                            ? Container()
                                            : Image.network(
                                                expedisi5.value,
                                                height: 17,
                                                width: Get.width * 0.12,
                                              ),
                                        (expedisi6.value == '')
                                            ? Container()
                                            : Image.network(
                                                expedisi6.value,
                                                height: 17,
                                                width: Get.width * 0.12,
                                              )
                                      ],
                                    )),
                                Divider(),
                                Padding(padding: EdgeInsets.only(top: 22)),

                                Text(
                                  'Detail Produk :',
                                  style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                                Obx(() => Text(
                                      '''${c.deskripsiMPC.value}''',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Warna.grey,
                                      ),
                                      textAlign: TextAlign.left,
                                    )),
                                Padding(padding: EdgeInsets.only(top: 22)),
                                Divider(),
                                DetailTokoMarketplace(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  tambahKeKeranjang(gambar, nama, detail, harga, itemid, intHarga, idOutlet) {
    final c = Get.find<ApiService>();
    harga = harga.toString();
    //itemid = itemid.toString();
    intHarga = intHarga.toString();
    idOutlet = idOutlet.toString();

    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          CachedNetworkImage(
            imageUrl: gambar,
            width: Get.width * 0.7,
            height: Get.width * 0.7,
          ),
          Padding(padding: EdgeInsets.only(top: 9)),
          Text(nama,
              style: TextStyle(
                  fontSize: 20, color: Warna.grey, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
          Container(
            padding: EdgeInsets.fromLTRB(22, 7, 22, 11),
            child: Text(
              detail,
              style: TextStyle(fontSize: 14, color: Warna.grey),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 16)),
          Text(harga,
              style: TextStyle(
                  fontSize: 18,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w600)),
          Padding(padding: EdgeInsets.only(top: 7)),
          Padding(padding: EdgeInsets.only(top: 7)),
          Container(
            padding: EdgeInsets.only(left: 9, right: 9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: Warna.warnautama,
                      size: 25,
                    ),
                    onPressed: () {
                      if (c.jumlahBarangMP.value > 0) {
                        c.jumlahItemMP.value--;
                        var hrgSatuan = int.parse(intHarga);
                        c.hargaKeranjangMP.value =
                            c.hargaKeranjangMP.value - hrgSatuan;
                        var kurang = 0;
                        for (var i = 0; i < c.keranjangMP.length; i++) {
                          if (c.keranjangMP[i] == itemid.toString()) {
                            if (kurang == 0) {
                              c.keranjangMP.remove(itemid.toString());
                              kurang = 1;
                            }
                          }
                        }
                        var jb = 0;
                        for (var i = 0; i < c.keranjangMP.length; i++) {
                          if (c.keranjangMP[i] == itemid.toString()) {
                            jb++;
                          }
                        }
                        c.jumlahBarangMP.value = jb;

                        // print(c.keranjangMakan);
                      } else {
                        c.idOutletpadakeranjangMP.value = '0';
                      }
                    }),
                Obx(() => Text(c.jumlahBarangMP.value.toString(),
                    style: TextStyle(
                        fontSize: 18,
                        color: Warna.warnautama,
                        fontWeight: FontWeight.w400))),
                IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: Warna.warnautama,
                      size: 25,
                    ),
                    onPressed: () {
                      var hrgSatuan = int.parse(intHarga);
                      c.hargaKeranjangMP.value =
                          c.hargaKeranjangMP.value + hrgSatuan;
                      c.jumlahItemMP.value++;
                      c.keranjangMP.add(itemid.toString());
                      var jb = 0;
                      for (var i = 0; i < c.keranjangMP.length; i++) {
                        if (c.keranjangMP[i] == itemid.toString()) {
                          jb++;
                        }
                      }
                      c.jumlahBarangMP.value = jb;
                      c.idOutletpadakeranjangMP.value = idOutlet.toString();
                      print(c.keranjangMP);
                    }),
                RawMaterialButton(
                  onPressed: () {
                    Get.back();
                  },
                  constraints: BoxConstraints(),
                  elevation: 1.0,
                  fillColor: Warna.warnautama,
                  child: Text(
                    'Tambahkan',
                    style: TextStyle(color: Warna.putih),
                  ),
                  padding: EdgeInsets.fromLTRB(9, 3, 9, 3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(9)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )..show();
  }

  cekBarangDiLokal(idMakanan) {
    var hasil = 0;

    for (var i = 0; i < c.keranjangMP.length; i++) {
      if (c.keranjangMP[i].itemid == idMakanan) {
        hasil = c.keranjangMP[i].jumlah;
      }
    }

    return hasil;
  }

  void sukaProdukIni() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var item = c.itemIdMPC.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","itemid":"$item"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLmp}/mobileAppsUser/sukaProduk');

    final response = await https.post(url, body: {
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
      if (hasil['status'] == 'success') {}
    }
  }

  void detailProduk() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var produkID = c.itemIdMPC.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","produkID":"$produkID"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLmp}/mobileAppsUser/detailProdukMP');

    final response = await https.post(url, body: {
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
        c.beratMPC.value = hasil['beratBarang'];
        hargaCoret.value = hasil['hargaCoret'];
        hargaDiskon.value = hasil['diskon'];
        terjual.value = hasil['terjual'];

        c.gambarMPChiRess.value = hasil['fotoHiress'];
        c.gambarMPC.value = hasil['fotoHiress'];
        expedisi1.value = hasil['pengiriman1'];
        expedisi2.value = hasil['pengiriman2'];
        expedisi3.value = hasil['pengiriman3'];
        expedisi4.value = hasil['pengiriman4'];
        expedisi5.value = hasil['pengiriman5'];
        expedisi6.value = hasil['pengiriman6'];
      }
    }
  }
}
