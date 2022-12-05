import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../base/notifikasiBuatAkun.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import 'package:http/http.dart' as https;
import '../marketplace/outletmarketplace.dart';

class DetailTokoMarketplace extends StatefulWidget {
  @override
  _DetailTokoMarketplaceState createState() => _DetailTokoMarketplaceState();
}

class _DetailTokoMarketplaceState extends State<DetailTokoMarketplace> {
  List keranjangMakan = [];
  List dataOutlet = [];
  List dataBarang = [];
  bool dataSiap = false;
  var jarak = ''.obs;
  var dilihat = ''.obs;
  var terjual = ''.obs;
  var idchat = '0';
  var badge = ''.obs;
  var namaBadge = ''.obs;
  final c = Get.find<ApiService>();

  @override
  void initState() {
    super.initState();
    detailOutlet();
  }

  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Obx(() => Container(
                color: Colors.grey[200],
                padding: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: Get.width * 0.2,
                      child: Column(
                        children: [
                          (namaBadge.value == '')
                              ? Container()
                              : Image.asset(
                                  'images/sellerbadge/$badge',
                                  width: Get.width * 0.1,
                                ),
                          Text(
                            namaBadge.value,
                            style: TextStyle(
                                color: Colors.amber,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(left: 11)),
                    SizedBox(
                      width: Get.width * 0.6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Penjual :',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            c.namaoutletMPC.value,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                color: Colors.amber,
                                fontSize: 20,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.right,
                          ),
                          Text(
                            c.lokasiMPC.value,
                            style: TextStyle(color: Warna.grey),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.visibility,
                                    color: Warna.grey,
                                    size: 18,
                                  ),
                                  Text(
                                    dilihat.value,
                                    style: TextStyle(color: Warna.grey),
                                  ),
                                ],
                              ),
                              Row(
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
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          Divider(),
          Padding(padding: EdgeInsets.only(top: 22)),
          Text(
            'Outlet ini juga menjual : ',
            style: TextStyle(
                color: Colors.amber, fontSize: 14, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          (dataSiap == true)
              ? listdaftar()
              : Container(
                  child: LinearProgressIndicator(),
                )
        ],
      ),
    );
  }

  detailOutlet() async {
    print('DETAIL TOKO LOADED');
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var latitude = c.latitude.value;
    var longitude = c.longitude.value;
    var idoutlet = c.idOutletPilihanMP.value;
    print(idoutlet);
    var statusCode = 100;
    if (c.dataResponseIdTokoMPC.value == c.idOutletPilihanMP.value) {
      statusCode = 200;
    } else {
      // EasyLoading.dismiss();
      var user = dbbox.get('loginSebagai');

      var datarequest =
          '{"pid":"$pid","lat":"$latitude","long":"$longitude","idOutlet":"$idoutlet"}';
      var bytes = utf8.encode(datarequest + '$token' + user);
      var signature = md5.convert(bytes).toString();

      var url =
          Uri.parse('${c.baseURLmp}/mobileAppsUser/outletMarketplaceDetail');
      final response = await https.post(url, body: {
        "user": user,
        "appid": c.appid,
        "data_request": datarequest,
        "sign": signature,
        "package": c.packageName
      });

      c.dataResponseTokoMPC.value = response.body;
      c.dataResponseIdTokoMPC.value = c.idOutletPilihanMP.value;
      statusCode = response.statusCode;

      print(response.body);
    }

    if (statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(c.dataResponseTokoMPC.value);
      if (hasil['status'] == 'success') {
        dataOutlet = hasil['dataOutlet'];
        dataBarang = hasil['barang'];
        jarak.value = hasil['jarak'].toString();
        terjual.value = hasil['terjual'].toString();
        dilihat.value = hasil['dilihat'].toString();
        idchat = hasil['idchat'];
        c.idChatLawan.value = hasil['idchat'];
        badge.value = hasil['badge'];
        namaBadge.value = hasil['namaBadge'];
        //  listdaftar();
        setState(() {
          dataSiap = true;
        });
      }
    }
  }

  List<Container> listdatabarang = [];
  listdaftar() {
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
                    setState(() {
                      // print('ini dia nn');
                      //gambar, nama, detail, harga, itemid, intHarga, idOutlet
                      c.namaMPC.value = valHistory[1];
                      c.gambarMPC.value =
                          valHistory[2].replaceAll('/200/', '/400/');
                      c.gambarMPChiRess.value =
                          valHistory[2].replaceAll('/200/', '/600/');
                      c.tagIdMPC.value = valHistory[6].toString();
                      c.hargaMPC.value = valHistory[3];
                      c.deskripsiMPC.value = valHistory[4];
                      c.hargaIntMPC.value = valHistory[5];
                      c.idOutletMPC.value = valHistory[7].toString();
                      c.itemIdMPC.value = valHistory[6].toString();
                    });
                    Get.back();
                    Get.to(() => DetailOtletMarketplace());
                  },
                  child: Container(
                    padding: EdgeInsets.all(5),
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
                              width: Get.width * 0.55,
                              child: Text(
                                valHistory[1],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style:
                                    TextStyle(fontSize: 16, color: Warna.grey),
                              ),
                            ),
                            SizedBox(
                              width: Get.width * 0.55,
                              child: Text(
                                valHistory[4],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style:
                                    TextStyle(fontSize: 12, color: Warna.grey),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 5)),
                            SizedBox(
                              width: Get.width * 0.55,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        valHistory[3],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 18, color: Warna.grey),
                                      ),
                                      (valHistory[11] == 'Rp.0')
                                          ? Container()
                                          : Text(
                                              valHistory[11],
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: TextStyle(
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  fontSize: 12,
                                                  color: Warna.grey),
                                            ),
                                    ],
                                  ),
                                  RawMaterialButton(
                                    onPressed: () {
                                      //TAMU OR MEMBER
                                      if (c.loginAsPenggunaKita.value ==
                                          'Member') {
                                        var jb = 0;
                                        for (var i = 0;
                                            i < c.keranjangMP.length;
                                            i++) {
                                          if (c.keranjangMP[i] ==
                                              valHistory[6].toString()) {
                                            jb++;
                                          }
                                        }
                                        c.jumlahBarangMP.value = jb;
                                        tambahKeKeranjang(
                                            valHistory[2],
                                            valHistory[1],
                                            valHistory[4],
                                            valHistory[3],
                                            valHistory[6],
                                            valHistory[5],
                                            valHistory[7]);
                                      } else {
                                        var judulF =
                                            'Akun ${c.namaAplikasi} Dibutuhkan ?';

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
                                      children: [
                                        Icon(Icons.shopping_cart_outlined,
                                            color: Colors.white, size: 14),
                                        Text(
                                          'Tambah',
                                          style: TextStyle(color: Warna.putih),
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.fromLTRB(9, 2, 9, 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(9)),
                                    ),
                                  ),
                                ],
                              ),
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
}
