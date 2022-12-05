import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as https;
// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import '../../folderUmum/chat/view/chatDetailPage.dart';

import 'carilokasi.dart';
import 'pembayaran.dart';

class LokasidanKeranjangMK extends StatefulWidget {
  @override
  _LokasidanKeranjangMKState createState() => _LokasidanKeranjangMKState();
}

class _LokasidanKeranjangMKState extends State<LokasidanKeranjangMK> {
  final c = Get.find<ApiService>();
  bool dataSiap = false;

  var fill1 = Warna.putih.obs;
  var text1 = Warna.warnautama.obs;
  var openClose = 'tutup';
  var fill2 = Warna.warnautama.obs;
  var text2 = Warna.putih.obs;

  @override
  void initState() {
    super.initState();
    rekapBelanjadanAlamat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.warnautama,
        title: Text('Checkout'),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(5),
        child: RawMaterialButton(
          onPressed: () {
            if (openClose == 'buka') {
              pemeriksaanSebelumPembayaran();
            } else {
              AwesomeDialog(
                  context: Get.context,
                  dialogType: DialogType.noHeader,
                  animType: AnimType.rightSlide,
                  title: 'Outlet Sedang Tutup',
                  desc:
                      'Opps.. sepertinya saat ini outlet sedang tutup, pesanan kamu akan diproses outlet pada saat outlet ini buka, Apakah kamu yakin akan melanjutkan proses pemesanan ini?',
                  btnCancelText: 'Chat Outlet',
                  btnCancelColor: Colors.amber,
                  btnCancelOnPress: () {
                    Get.to(() => ChatDetailPage());
                  },
                  btnOkText: 'Iya, Lanjutkan',
                  btnOkOnPress: () {
                    pemeriksaanSebelumPembayaran();
                  })
                ..show();
            }
          },
          constraints: BoxConstraints(),
          elevation: 1.0,
          fillColor: Warna.warnautama,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                            width: Get.width * 0.4,
                            child: Text(
                              c.namaoutletpadakeranjang.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(color: Warna.putih, fontSize: 12),
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
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 33,
                            color: Colors.white,
                          ),
                        ],
                      )
                    ],
                  ),
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
      body: ListView(
        children: [
          Container(
            height: 7,
            color: Colors.grey[200],
          ),
          Container(
            padding: EdgeInsets.only(left: 22, right: 22, top: 11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alamat kamu saat ini',
                  style: TextStyle(fontSize: 12, color: Warna.grey),
                ),
                Padding(padding: EdgeInsets.only(top: 10)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: Get.width * 0.6,
                      child: Obx(() => Text(
                            c.alamatKirim.value,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(fontSize: 18, color: Warna.grey),
                          )),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  side: BorderSide(color: Warna.warnautama)))),
                      onPressed: () {
                        Get.off(CariLokasiKirim());
                      },
                      child: Text(
                        'Ganti',
                        style: TextStyle(color: Warna.warnautama),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 11)),
          Container(
            height: 7,
            color: Colors.grey[200],
          ),
          Container(
            padding: EdgeInsets.fromLTRB(22, 11, 22, 11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pengiriman',
                      style: TextStyle(color: Warna.grey),
                    ),
                    Obx(() => Text(
                          'Rp. ' + c.ongkirMakan.value.toString() + ',-',
                          style: TextStyle(color: Warna.grey),
                        )),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => RawMaterialButton(
                          onPressed: () {
                            if (c.pilihanKurir.value == 'sendiri') {
                            } else {
                              pilihanbutton('sendiri');
                            }
                          },
                          constraints: BoxConstraints(),
                          elevation: 1.0,
                          fillColor: fill1.value,
                          child: Text(
                            'Ambil Sendiri',
                            style: TextStyle(color: text1.value, fontSize: 18),
                          ),
                          padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(9)),
                          ),
                        )),
                    Padding(padding: EdgeInsets.only(left: 11)),
                    Obx(() => RawMaterialButton(
                          onPressed: () {
                            if (c.pilihanKurir.value == 'kurir') {
                            } else {
                              pilihanbutton('kurir');
                            }
                          },
                          constraints: BoxConstraints(),
                          elevation: 1.0,
                          fillColor: fill2.value,
                          child: Text(
                            'Diantar Kurir',
                            style: TextStyle(color: text2.value, fontSize: 18),
                          ),
                          padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(9)),
                          ),
                        )),
                  ],
                )
              ],
            ),
          ),
          Container(
            height: 7,
            color: Colors.grey[200],
          ),
          (dataSiap == true) ? listdaftar() : Container()
        ],
      ),
    );
  }

  rekapBelanjadanAlamat() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var latitude = c.latitude.value;
    var longitude = c.longitude.value;
    var jsonorder = jsonEncode(c.keranjangMakan);
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","lat":"$latitude","long":"$longitude","jsonOrder":"$jsonorder"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLmakan}/mobileAppsUser/chekoutMakan');

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
        openClose = hasil['openClose'];
        c.idChatLawan.value = hasil['idChat'];
        c.namaChatLawan.value = hasil['namaChat'];
        c.fotoChatLawan.value = hasil['fotoChat'];
        dataBarang = hasil['data'];
        c.ongkirMakan.value = hasil['ongkir'];
        c.jumlahItem.value = hasil['jumlahItem'];
        c.hargaKeranjang.value = hasil['hargaTotal'];
        c.namaoutletpadakeranjang.value = hasil['namaOutlet'];
        c.pilihanKurir.value = 'kurir';
        setState(() {
          c.alamatKirim.value = hasil['alamat'];
          dataSiap = true;
        });
      }
    }
  }

  List<Container> listdatabarang = [];
  List dataBarang = [];
  List indexQuantity = [].obs;

  listdaftar() {
    if (dataBarang.length > 0) {
      for (var i = 0; i < dataBarang.length; i++) {
        var valHistory = dataBarang[i];

        indexQuantity.add(valHistory[4]);
        listdatabarang.add(
          Container(
              // width: Get.width * 0.45,
              child: GestureDetector(
            onTap: () {},
            child: Card(
                elevation: 0.2,
                //color: Colors.lightGreen[50],
                margin: EdgeInsets.all(5),
                child: Container(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CachedNetworkImage(
                        imageUrl: valHistory[3],
                        width: 50.0,
                        height: 50.0,
                      ),
                      Padding(padding: EdgeInsets.only(left: 11)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: Get.width * 0.5,
                            child: Text(
                              valHistory[1],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(fontSize: 19, color: Warna.grey),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 5)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: Get.width * 0.28,
                                child: Text(
                                  valHistory[2],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontSize: 16, color: Warna.grey),
                                ),
                              ),
                              Padding(padding: EdgeInsets.only(left: 11)),
                              Row(
                                children: [
                                  RawMaterialButton(
                                    onPressed: () {
                                      pengurangan(
                                          valHistory[5], valHistory[0], i);
                                    },
                                    constraints: BoxConstraints(),
                                    elevation: 1.0,
                                    fillColor: Warna.putih,
                                    child: Icon(
                                      Icons.remove,
                                      color: Warna.warnautama,
                                    ),
                                    padding: EdgeInsets.fromLTRB(5, 4, 5, 4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(9)),
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(left: 7)),
                                  Obx(() => Text(
                                        indexQuantity[i].toString(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 20, color: Warna.grey),
                                      )),
                                  Padding(padding: EdgeInsets.only(left: 7)),
                                  RawMaterialButton(
                                    onPressed: () {
                                      penjumlahan(
                                          valHistory[5], valHistory[0], i);
                                    },
                                    constraints: BoxConstraints(),
                                    elevation: 1.0,
                                    fillColor: Warna.putih,
                                    child: Icon(
                                      Icons.add,
                                      color: Warna.warnautama,
                                    ),
                                    padding: EdgeInsets.fromLTRB(5, 4, 5, 4),
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
                    ],
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

  pengurangan(intHarga, itemid, indx) {
    if (c.jumlahBarang.value > 0) {
      if (indexQuantity[indx] > 1) {
        indexQuantity[indx] = indexQuantity[indx] - 1;
        c.jumlahItem.value--;

        var hrgSatuan = int.parse(intHarga);
        c.hargaKeranjang.value = c.hargaKeranjang.value - hrgSatuan;
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
      } else {
        AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.noHeader,
            animType: AnimType.rightSlide,
            title: 'Hapus Pesanan ?',
            desc:
                'Apa benar kamu akan menghapus item ini dari daftar pesanan ???',
            btnCancelText: 'Iya, Hapus',
            btnCancelOnPress: () {
              indexQuantity[indx] = indexQuantity[indx] - 1;
              c.jumlahItem.value--;

              var hrgSatuan = int.parse(intHarga);
              c.hargaKeranjang.value = c.hargaKeranjang.value - hrgSatuan;
              var kurang = 0;
              for (var i = 0; i < c.keranjangMakan.length; i++) {
                if (c.keranjangMakan[i] == itemid) {
                  if (kurang == 0) {
                    c.keranjangMakan.remove(itemid);

                    kurang = 1;
                  }
                }
              }

              listdatabarang = [];
              dataBarang = [];
              setState(() {
                dataSiap = false;
              });
              rekapBelanjadanAlamat();
              indexQuantity.removeAt(indx);
            },
            btnOkText: 'Tidak',
            btnOkOnPress: () {})
          ..show();
      }
    }
  }

  void penjumlahan(intHarga, itemid, indx) {
    var hrgSatuan = int.parse(intHarga);
    c.hargaKeranjang.value = c.hargaKeranjang.value + hrgSatuan;
    c.jumlahItem.value++;
    indexQuantity[indx] = indexQuantity[indx] + 1;
    c.keranjangMakan.add(itemid);
    var jb = 0;
    for (var i = 0; i < c.keranjangMakan.length; i++) {
      if (c.keranjangMakan[i] == itemid) {
        jb++;
      }
    }
    c.jumlahBarang.value = jb;
  }

  void clearbutton() {
    fill1.value = Warna.putih;
    text1.value = Warna.warnautama;
    fill2.value = Warna.putih;
    text2.value = Warna.warnautama;
  }

  void pilihanbutton(kurir) {
    if (c.pilihanKurir.value == 'kurir') {
      c.pilihanKurir.value = 'sendiri';
      clearbutton();
      fill1.value = Warna.warnautama;
      text1.value = Warna.putih;
      c.pilihanKurir.value = kurir;
      c.hargaKeranjang.value = c.hargaKeranjang.value - c.ongkirMakan.value;
    } else if (c.pilihanKurir.value == 'sendiri') {
      c.pilihanKurir.value = 'kurir';
      clearbutton();
      fill2.value = Warna.warnautama;
      text2.value = Warna.putih;
      c.hargaKeranjang.value = c.hargaKeranjang.value + c.ongkirMakan.value;
      c.pilihanKurir.value = kurir;
    } else {
      clearbutton();
      print(c.pilihanKurir.value);
    }
  }

  void pemeriksaanSebelumPembayaran() {
    if (c.jumlahItem.value == 0) {
      Get.snackbar('Error',
          'Opps...sepertinya pilihan kamu belum lengkap, lengkapi dulu ya..',
          colorText: Warna.putih, snackPosition: SnackPosition.BOTTOM);
    } else if (c.alamatKirim.value == '') {
      Get.snackbar('Error',
          'Opps...sepertinya Alamat kirim belum lengkap, lengkapi dulu ya..',
          colorText: Warna.putih, snackPosition: SnackPosition.BOTTOM);
    } else if (c.pilihanKurirFm.value == '') {
      Get.snackbar('Error',
          'Opps...sepertinya metode pengiriman belum lengkap, lengkapi dulu ya..',
          colorText: Warna.putih, snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.to(() => PembayaranMakanan());
    }
  }
}
