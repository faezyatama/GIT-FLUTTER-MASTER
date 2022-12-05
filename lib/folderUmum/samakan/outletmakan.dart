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
import '/base/besarinGambar.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../folderUmum/chat/view/chatDetailPage.dart';

import 'cekoutKeranjang.dart';

class DetailOtletMakan extends StatefulWidget {
  @override
  _DetailOtletMakanState createState() => _DetailOtletMakanState();
}

class _DetailOtletMakanState extends State<DetailOtletMakan> {
  final c = Get.find<ApiService>();

  List keranjangMakan = [];
  List dataOutlet = [];
  List dataBarang = [];
  bool dataSiap = false;
  var jarak = ''.obs;
  var dilihat = ''.obs;
  var terjual = ''.obs;
  var idchat = '0';
  int jumlah = 1;

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
    detailOutlet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SpeedDial(
        /// both default to 16
        // marginEnd: 18,
        // marginBottom: Get.height * 0.53,
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
            labelStyle: TextStyle(fontSize: 18.0, color: Colors.grey),
            onTap: () {
              //TAMU OR MEMBER
              if (c.loginAsPenggunaKita.value == 'Member') {
                c.idChatLawan.value = idchat;
                c.namaChatLawan.value = c.namaoutletPreview.value;
                c.fotoChatLawan.value = c.gambarPreview.value;
                print(c.idChatLawan.value);
                Get.to(() => ChatDetailPage());
              } else {
                var judulF = 'Akun ${c.namaAplikasi} Dibutuhkan';
                var subJudul =
                    'Yuk Buka akun ${c.namaAplikasi} sekarang, belanja menjadi lebih mudah';

                bukaLoginPage(judulF, subJudul);
              }
              //END TAMU OR MEMBER
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.favorite),
            backgroundColor: Colors.blue[300],
            label: 'Suka / Wishlist',
            labelStyle: TextStyle(fontSize: 18.0, color: Colors.grey),
            onTap: () {
              //TAMU OR MEMBER
              if (c.loginAsPenggunaKita.value == 'Member') {
                Get.snackbar(c.namaoutletPreview.value,
                    'Terima kasih telah menyukai produk ini');
                sukaProdukIni();
              } else {
                var judulF = 'Akun ${c.namaAplikasi} Dibutuhkan';
                var subJudul =
                    'Yuk Buka akun ${c.namaAplikasi} sekarang, belanja menjadi lebih mudah';

                bukaLoginPage(judulF, subJudul);
              }
              //END TAMU OR MEMBER
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
              if (c.hargaKeranjang.value > 0) {
                Get.to(() => LokasidanKeranjangMK());
              }
            } else {
              var judulF = 'Cek out belanja ?';
              var subJudul =
                  'Yuk Buka akun ${c.namaAplikasi} sekarang, akun kamu dapat aktif dalam beberapa langkah mudah';

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
                        '${c.jumlahItem.value} item',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w300,
                            color: Warna.putih),
                      )),
                  Obx(() => SizedBox(
                        width: Get.width * 0.35,
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
          SizedBox(
            height: Get.height * 0.45,
            width: Get.width * 1,
            child: Hero(
                tag: c.namaPreview.value,
                child: Material(
                    child: InkWell(
                  child: CachedNetworkImage(
                      fit: BoxFit.fill,
                      imageUrl: c.gambarPreview.value,
                      errorWidget: (context, url, error) {
                        print(error);
                        return Icon(Icons.error);
                      }),
                ))),
          ),
          ListView(
            children: [
              SizedBox(
                width: Get.width * 0.8,
                height: Get.height * 0.32,
                child: InkWell(
                  onTap: () {
                    c.besarinGambar.value = c.gambarPreviewhiRess.value;
                    c.besarinGambarNama.value = c.namaPreview.value;
                    Get.to(() => BesarinGambar());
                  },
                  child: Container(),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(22, 0, 18, 18),
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
                            Obx(() => Text(
                                  c.namaPreview.value,
                                  style: TextStyle(
                                      fontSize: 28,
                                      color: Warna.grey,
                                      fontWeight: FontWeight.w300),
                                  textAlign: TextAlign.center,
                                )),

                            Obx(() => Text(
                                  c.deskripsiPreview.value,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Warna.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                )),
                            Container(
                              child: Obx(() => Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(c.hargaPreview.value,
                                          style: TextStyle(
                                              fontSize: 28,
                                              color: Warna.warnautama,
                                              fontWeight: FontWeight.w300)),
                                      Padding(
                                          padding: EdgeInsets.only(left: 12)),
                                      RawMaterialButton(
                                        onPressed: () {
                                          //TAMU OR MEMBER
                                          if (c.loginAsPenggunaKita.value ==
                                              'Member') {
                                            var jb = 0;
                                            for (var i = 0;
                                                i < c.keranjangMakan.length;
                                                i++) {
                                              if (c.keranjangMakan[i] ==
                                                  c.itemidPreview.value) {
                                                jb++;
                                              }
                                            }
                                            c.jumlahBarang.value = jb;
                                            //gambar, nama, detail, harga, itemid, intHarga, idOutlet
                                            tambahKeKeranjang(
                                                c.gambarPreview.value, //gambar
                                                c.namaPreview.value, //nama
                                                c.deskripsiPreview
                                                    .value, //detail
                                                c.hargaPreview.value, //harga
                                                c.itemidPreview.value, //itemid
                                                c.helper5.value, //intharga
                                                c.helper7.value); //idoutlet
                                          } else {
                                            var judulF =
                                                'Akun ${c.namaAplikasi} Dibutuhkan';
                                            var subJudul =
                                                'Yuk Buka akun ${c.namaAplikasi} sekarang, belanja menjadi lebih mudah';

                                            bukaLoginPage(judulF, subJudul);
                                          }
                                          //END TAMU OR MEMBER
                                        },
                                        constraints: BoxConstraints(),
                                        elevation: 1.0,
                                        fillColor: Warna.warnautama,
                                        child: Text(
                                          '+ Beli',
                                          style: TextStyle(color: Warna.putih),
                                        ),
                                        padding:
                                            EdgeInsets.fromLTRB(9, 4, 9, 4),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(9)),
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                            Padding(padding: EdgeInsets.only(top: 22)),
                            Divider(),
                            Text(
                              c.namaoutletPreview.value,
                              style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              c.lokasiPreview.value,
                              style: TextStyle(color: Warna.grey),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.place,
                                  color: Warna.grey,
                                  size: 18,
                                ),
                                Text(
                                  jarak.value,
                                  style: TextStyle(color: Warna.grey),
                                ),
                                Padding(padding: EdgeInsets.only(left: 11)),
                                Icon(
                                  Icons.shopping_bag,
                                  color: Warna.grey,
                                  size: 18,
                                ),
                                Text(
                                  terjual.value,
                                  style: TextStyle(color: Warna.grey),
                                ),
                                Padding(padding: EdgeInsets.only(left: 11)),
                                Icon(
                                  Icons.visibility,
                                  color: Warna.grey,
                                  size: 18,
                                ),
                                Text(
                                  dilihat.value,
                                  style: TextStyle(color: Warna.grey),
                                )
                              ],
                            ),
                            Padding(padding: EdgeInsets.only(top: 22)),
                            (dataSiap == true) ? listdaftar() : Container()
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
    );
  }

  detailOutlet() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var latitude = c.latitude.value;
    var longitude = c.longitude.value;
    var idoutlet = c.idOutletPilihan.value;
    var user = dbbox.get('loginSebagai');

    // print('print id outlet : $idoutlet');

    var datarequest =
        '{"pid":"$pid","lat":"$latitude","long":"$longitude","idOutlet":"$idoutlet"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLmakan}/mobileAppsUser/outletDetail');

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
        dataOutlet = hasil['dataOutlet'];
        dataBarang = hasil['barang'];
        jarak.value = hasil['jarak'].toString();
        terjual.value = hasil['terjual'].toString();
        dilihat.value = hasil['dilihat'].toString();
        idchat = hasil['idchat'];

        //  listdaftar();
        setState(() {
          dataSiap = true;
        });
      }
    }
  }

  List<Container> listdatabarang = [];
  listdaftar() {
    listdatabarang = [];
    if (dataBarang.length > 0) {
      for (var i = 0; i < dataBarang.length; i++) {
        var valHistory = dataBarang[i];

        listdatabarang.add(
          Container(
              // width: Get.width * 0.45,
              child: Container(
            child: Card(
                elevation: 0.2,
                //color: Colors.lightGreen[50],
                margin: EdgeInsets.all(5),
                child: InkWell(
                  onTap: () {
                    c.namaPreview.value = valHistory[1]; //nama
                    c.gambarPreview.value = valHistory[9]; //gambar
                    c.gambarPreviewhiRess.value = valHistory[10]; //gambar

                    c.hargaPreview.value = valHistory[3]; //harga
                    c.itemidPreview.value = valHistory[6]; //itemid;
                    c.deskripsiPreview.value = valHistory[4]; //detail

                    c.helper2.value = valHistory[9];
                    c.helper5.value = valHistory[5];
                    c.helper7.value = valHistory[6].toString();
                    Get.back();
                    Get.to(() => DetailOtletMakan());
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CachedNetworkImage(
                            width: Get.width * 0.25,
                            height: Get.width * 0.25,
                            imageUrl: valHistory[2],
                            errorWidget: (context, url, error) {
                              print(error);
                              return Icon(Icons.error);
                            }),
                        Padding(padding: EdgeInsets.only(left: 11)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: Get.width * 0.38,
                              child: Text(
                                valHistory[1],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style:
                                    TextStyle(fontSize: 19, color: Warna.grey),
                              ),
                            ),
                            SizedBox(
                              width: Get.width * 0.37,
                              child: Text(
                                valHistory[4],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style:
                                    TextStyle(fontSize: 12, color: Warna.grey),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 22)),
                            Row(
                              children: [
                                SizedBox(
                                  width: Get.width * 0.24,
                                  child: Text(
                                    valHistory[3],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                        fontSize: 15, color: Warna.grey),
                                  ),
                                ),
                                RawMaterialButton(
                                  onPressed: () {
                                    //TAMU OR MEMBER
                                    if (c.loginAsPenggunaKita.value ==
                                        'Member') {
                                      var jb = 0;
                                      for (var i = 0;
                                          i < c.keranjangMakan.length;
                                          i++) {
                                        if (c.keranjangMakan[i] ==
                                            valHistory[6]) {
                                          jb++;
                                        }
                                      }
                                      c.jumlahBarang.value = jb;
                                      //gambar, nama, detail, harga, itemid, intHarga, idOutlet
                                      tambahKeKeranjang(
                                          valHistory[2], //gambar
                                          valHistory[1], //nama
                                          valHistory[4], //detail
                                          valHistory[3], //harga
                                          valHistory[6], //itemid
                                          valHistory[5], //intharga
                                          valHistory[7]); //idoutlet
                                    } else {
                                      var judulF =
                                          'Akun ${c.namaAplikasi} Dibutuhkan';
                                      var subJudul =
                                          'Yuk Buka akun ${c.namaAplikasi} sekarang, belanja menjadi lebih mudah';

                                      bukaLoginPage(judulF, subJudul);
                                    }
                                    //END TAMU OR MEMBER
                                  },
                                  constraints: BoxConstraints(),
                                  elevation: 1.0,
                                  fillColor: Warna.warnautama,
                                  child: Text(
                                    '+ Tambah',
                                    style: TextStyle(color: Warna.putih),
                                  ),
                                  padding: EdgeInsets.fromLTRB(9, 1, 9, 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(9)),
                                  ),
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

  tambahKeKeranjang(gambar, nama, detail, harga, itemid, intHarga, idOutlet) {
    final c = Get.find<ApiService>();

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
                      if (c.jumlahBarang.value > 0) {
                        c.jumlahItem.value--;
                        var hrgSatuan = int.parse(intHarga);
                        c.hargaKeranjang.value =
                            c.hargaKeranjang.value - hrgSatuan;
                        var kurang = 0;
                        for (var i = 0; i < c.keranjangMakan.length; i++) {
                          if (c.keranjangMakan[i] == itemid) {
                            if (kurang == 0) {
                              c.keranjangMakan.remove(itemid);
                              kurang = 1;
                            }
                          }
                        }
                        var jb = 0;
                        for (var i = 0; i < c.keranjangMakan.length; i++) {
                          if (c.keranjangMakan[i] == itemid) {
                            jb++;
                          }
                        }
                        c.jumlahBarang.value = jb;

                        // print(c.keranjangMakan);
                      } else {
                        c.idOutletpadakeranjangMakan.value = '0';
                      }
                    }),
                Obx(() => Text(c.jumlahBarang.value.toString(),
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
                      c.hargaKeranjang.value =
                          c.hargaKeranjang.value + hrgSatuan;
                      c.jumlahItem.value++;
                      c.keranjangMakan.add(itemid);
                      var jb = 0;
                      for (var i = 0; i < c.keranjangMakan.length; i++) {
                        if (c.keranjangMakan[i] == itemid) {
                          jb++;
                        }
                      }
                      c.jumlahBarang.value = jb;
                      c.idOutletpadakeranjangMakan.value = idOutlet.toString();
                      // print(idOutlet);}),
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

    for (var i = 0; i < c.keranjangMakan.length; i++) {
      if (c.keranjangMakan[i].itemid == idMakanan) {
        hasil = c.keranjangMakan[i].jumlah;
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
    var item = c.itemidPreview.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","itemid":"$item"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLmakan}/mobileAppsUser/sukaProduk');

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
      if (hasil['status'] == 'success') {}
    }
  }
}
