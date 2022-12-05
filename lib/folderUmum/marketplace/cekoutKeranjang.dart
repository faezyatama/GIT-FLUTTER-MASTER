import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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

import 'aturAlamat.dart';
import 'carilokasi.dart';
import 'pembayaran.dart';

class LokasidanKeranjangMP extends StatefulWidget {
  @override
  _LokasidanKeranjangMPState createState() => _LokasidanKeranjangMPState();
}

class _LokasidanKeranjangMPState extends State<LokasidanKeranjangMP> {
  final c = Get.find<ApiService>();
  var dataSiap = false.obs;
  //bool ekspedisiNasional = false;
  var dataExpedisi = false.obs;
  var viewExpedisiFinal = false.obs;
  var saveAs = ''.obs;
  var openClose = 'tutup';

  var imagePilihan = ''.obs;
  var namaexpPilihan = ''.obs;
  var detailExpedisiPilihan = ''.obs;
  var hargaRpPilihan = ''.obs;

  var hargaIntPilihan = 0.obs;
  var beratGramTotal = 0;
  var costPerKg = 0;

  final controllerPass = TextEditingController();

  var fill1 = Warna.putih.obs;
  var text1 = Warna.warnautama.obs;

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
          title: Text('Checkout Marketplace'),
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
                              '${c.jumlahItemMP.value} item',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w300,
                                  color: Warna.putih),
                            )),
                        Obx(() => SizedBox(
                              width: Get.width * 0.4,
                              child: Text(
                                c.namaoutletpadakeranjangMP.value,
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
                        Obx(() => Column(
                              children: [
                                Text(
                                  'Rp. ${c.hargaKeranjangMPTotal.value},-',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w300,
                                      color: Warna.putih),
                                ),
                              ],
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
        body: Obx(
          () => ListView(
            children: [
              Container(
                height: 7,
                color: Colors.grey[200],
              ),
              (c.ekspedisiNasional.value == false)
                  ? Container(
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
                                      c.alamatKirimMP.value,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 4,
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Warna.grey,
                                          fontWeight: FontWeight.w500),
                                    )),
                              ),
                              ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            side: BorderSide(
                                                color: Warna.warnautama)))),
                                onPressed: () {
                                  Get.off(CariLokasiKirim());
                                },
                                child: Text(
                                  '+ Lokasi',
                                  style: TextStyle(color: Warna.warnautama),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Padding(padding: EdgeInsets.only(top: 1)),
              Container(
                height: 7,
                color: Colors.grey[200],
              ),
              (c.ekspedisiNasional.value == true)
                  ? Container(
                      padding: EdgeInsets.only(left: 22, right: 22, top: 11),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paket ini akan dikirimkan ke alamat :',
                            style: TextStyle(fontSize: 12, color: Warna.grey),
                          ),
                          Padding(padding: EdgeInsets.only(top: 10)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  SizedBox(
                                    width: Get.width * 0.6,
                                    child: Obx(() => Text(
                                          c.alamatKirimNasionalPenerima.value,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Warna.grey,
                                              fontWeight: FontWeight.w600),
                                        )),
                                  ),
                                  SizedBox(
                                    width: Get.width * 0.6,
                                    child: Obx(() => Text(
                                          c.alamatKirimNasional.value,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontSize: 15, color: Warna.grey),
                                        )),
                                  ),
                                  SizedBox(
                                    width: Get.width * 0.6,
                                    child: Obx(() => Text(
                                          '${c.alamatKirimNasionalKec.value} - ${c.alamatKirimNasionalKab.value}',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontSize: 15, color: Warna.grey),
                                        )),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            side: BorderSide(
                                                color: Warna.warnautama)))),
                                onPressed: () {
                                  Get.off(AturAlamatKirimMarketplace());
                                },
                                child: Text(
                                  'Alamat',
                                  style: TextStyle(color: Warna.warnautama),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Container(
                      height: 7,
                      color: Colors.grey[200],
                    ),
              Padding(padding: EdgeInsets.only(top: 11)),
              (c.ekspedisiNasional.value == false)
                  ? Container(
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
                                    'Rp. ' + c.ongkirMP.value.toString() + ',-',
                                    style: TextStyle(color: Warna.grey),
                                  )),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Obx(() => RawMaterialButton(
                                    onPressed: () {
                                      if (c.pilihanKurirFm.value == 'sendiri') {
                                      } else {
                                        pilihanbutton('sendiri');
                                      }
                                    },
                                    constraints: BoxConstraints(),
                                    elevation: 1.0,
                                    fillColor: fill1.value,
                                    child: Text(
                                      'Ambil Sendiri',
                                      style: TextStyle(
                                          color: text1.value, fontSize: 18),
                                    ),
                                    padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(9)),
                                    ),
                                  )),
                              Padding(padding: EdgeInsets.only(left: 11)),
                              Obx(() => RawMaterialButton(
                                    onPressed: () {
                                      if (c.pilihanKurirMP.value == 'kurir') {
                                      } else {
                                        pilihanbutton('kurir');
                                      }
                                    },
                                    constraints: BoxConstraints(),
                                    elevation: 1.0,
                                    fillColor: fill2.value,
                                    child: Text(
                                      'Diantar Kurir',
                                      style: TextStyle(
                                          color: text2.value, fontSize: 18),
                                    ),
                                    padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(9)),
                                    ),
                                  )),
                            ],
                          )
                        ],
                      ),
                    )
                  : Container(),
              (c.ekspedisiNasional.value == true)
                  ? Container(
                      padding: EdgeInsets.fromLTRB(22, 11, 22, 11),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pengiriman yang akan digunakan :',
                            style: TextStyle(color: Warna.grey),
                          ),
                          (dataExpedisi.value == true)
                              ? pengirimanExpedisiTersedia()
                              : Container(),
                          (viewExpedisiFinal.value == true)
                              ? pilihanExpedisiFinal()
                              : Container()
                        ],
                      ),
                    )
                  : Container(),
              Container(
                height: 7,
                color: Colors.grey[200],
              ),
              (dataSiap.value == true) ? listdaftar() : Container()
            ],
          ),
        ));
  }

  rekapBelanjadanAlamat() async {
    EasyLoading.show(status: 'Mohon tunggu...', dismissOnTap: false);

    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    try {
      Box dbbox = Hive.box<String>('sasukaDB');
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');
      var latitude = c.latitude.value;
      var longitude = c.longitude.value;
      var jsonorder = c.keranjangMP;
      var idKecamatan = c.alamatKirimNasionalIDKec.value;
      var user = dbbox.get('loginSebagai');

      var datarequest =
          '{"pid":"$pid","lat":"$latitude","long":"$longitude","jsonOrder":"$jsonorder","idKecamatan":"$idKecamatan"}';
      var bytes = utf8.encode(datarequest + '$token' + user);
      var signature = md5.convert(bytes).toString();

      var url = Uri.parse('${c.baseURLmp}/mobileAppsUser/chekoutMarketplace');

      final response = await https.post(url, body: {
        "user": user,
        "appid": c.appid,
        "data_request": datarequest,
        "sign": signature,
        "package": c.packageName
      });

      EasyLoading.dismiss();
      print(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> hasil = jsonDecode(response.body);
        if (hasil['status'] == 'success') {
          openClose = hasil['openClose'];
          c.idChatLawan.value = hasil['idChat'];
          c.namaChatLawan.value = hasil['namaChat'];
          c.fotoChatLawan.value = hasil['fotoChat'];

          dataBarang = hasil['data'];
          c.ongkirMP.value = hasil['ongkir'];
          c.jumlahItemMP.value = hasil['jumlahItem'];
          c.hargaKeranjangMP.value = hasil['hargaTotal'];
          c.hargaKeranjangMPTotal.value =
              c.hargaKeranjangMP.value + hargaIntPilihan.value;
          c.namaoutletpadakeranjangMP.value = hasil['namaOutlet'];
          c.ekspedisiNasional.value = hasil['ekspedisiNasional'];
          c.jumlahBarangMP.value = hasil['jumlahItem'];

          if (c.ekspedisiNasional.value == true) {
            c.alamatKirimNasionalSaveAs.value = hasil['saveAs'];
            c.alamatKirimNasionalPenerima.value = hasil['penerima'];
            c.alamatKirimNasional.value = hasil['alamat'];
            c.alamatKirimNasionalKec.value = hasil['kecamatan'];
            c.alamatKirimNasionalKab.value = hasil['kabupaten'];
            beratGramTotal = hasil['beratTotal'];
            ongkirList = hasil['ongkirList'];

            dataSiap.value = false;
            dataExpedisi.value = true;
          } else {
            setState(() {
              c.pilihanKurirMP.value = 'kurir';
              c.ekspedisiNasional.value = hasil['ekspedisiNasional'];
              c.alamatKirimMP.value = hasil['alamat'];
              dataSiap.value = true;
            });
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error Connection', 'Opps.. sepertinya sambungan terputus');
      EasyLoading.dismiss();
      Get.back();
    }
  }

  List<Container> listdatabarang = [];
  List dataBarang = [];
  List indexQuantity = [].obs;
  List<Container> listExpedisi = [];
  List ongkirList = [];

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
                                      pengurangan(valHistory[5], valHistory[0],
                                          i, valHistory[6]);
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
                                      penjumlahan(valHistory[5], valHistory[0],
                                          i, valHistory[6]);
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
    dataBarang = [];
    return Column(
      children: listdatabarang,
    );
  }

  pengurangan(intHarga, itemid, indx, berat) {
    if (c.jumlahBarangMP.value > 0) {
      if (indexQuantity[indx] > 1) {
        indexQuantity[indx] = indexQuantity[indx] - 1;
        c.jumlahItemMP.value--;
        //proses pengurangan harga ongkir
//apakah ini harga minimal < 1 kg ?
        beratGramTotal = beratGramTotal - berat;
        print(beratGramTotal);
        if (beratGramTotal < 1000) {
          hargaIntPilihan.value = costPerKg;
        } else {
          var tot = (beratGramTotal / 1000) * costPerKg;
          hargaIntPilihan.value = tot.round();
          hargaRpPilihan.value = 'Rp. ${hargaIntPilihan.value},-';
        }

        //
        var hrgSatuan = int.parse(intHarga);
        c.hargaKeranjangMP.value = c.hargaKeranjangMP.value - hrgSatuan;
        c.hargaKeranjangMPTotal.value =
            c.hargaKeranjangMP.value + hargaIntPilihan.value;
        var kurang = 0;
        for (var i = 0; i < c.keranjangMP.length; i++) {
          if (c.keranjangMP[i] == itemid) {
            if (kurang == 0) {
              c.keranjangMP.remove(itemid);
              kurang = 1;
            }
          }
        }
        var jb = 0;
        for (var i = 0; i < c.keranjangMP.length; i++) {
          if (c.keranjangMP[i] == itemid) {
            jb++;
          }
        }
        c.jumlahBarangMP.value = jb;
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
              c.jumlahItemMP.value--;

              var hrgSatuan = int.parse(intHarga);
              c.hargaKeranjangMP.value = c.hargaKeranjangMP.value - hrgSatuan;
              var kurang = 0;
              for (var i = 0; i < c.keranjangMP.length; i++) {
                if (c.keranjangMP[i] == itemid.toString()) {
                  if (kurang == 0) {
                    c.keranjangMP.remove(itemid.toString());

                    kurang = 1;
                  }
                }
              }

              listdatabarang = [];
              dataBarang = [];
              setState(() {
                dataSiap.value = false;
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

  void penjumlahan(intHarga, itemid, indx, int berat) {
    //hitung harga per kg

    //apakah ini harga minimal < 1 kg ?
    beratGramTotal = beratGramTotal + berat;
    print(beratGramTotal);
    if (beratGramTotal < 1000) {
      //no problem
    } else {
      var tot = (beratGramTotal / 1000) * costPerKg;
      hargaIntPilihan.value = tot.round();
      hargaRpPilihan.value = 'Rp. ${hargaIntPilihan.value},-';
    }

    var hrgSatuan = int.parse(intHarga);
    c.hargaKeranjangMP.value = c.hargaKeranjangMP.value + hrgSatuan;
    c.hargaKeranjangMPTotal.value =
        c.hargaKeranjangMP.value + hargaIntPilihan.value;

    c.jumlahItemMP.value++;
    indexQuantity[indx] = indexQuantity[indx] + 1;
    c.keranjangMP.add(itemid);
    var jb = 0;
    for (var i = 0; i < c.keranjangMP.length; i++) {
      if (c.keranjangMP[i] == itemid) {
        jb++;
      }
    }
    c.jumlahBarangMP.value = jb;
  }

  void clearbutton() {
    fill1.value = Warna.putih;
    text1.value = Warna.warnautama;
    fill2.value = Warna.putih;
    text2.value = Warna.warnautama;
  }

  void pilihanbutton(kurir) {
    if (c.pilihanKurirMP.value == 'kurir') {
      c.pilihanKurirMP.value = 'sendiri';

      clearbutton();
      fill1.value = Warna.warnautama;
      text1.value = Warna.putih;
      c.pilihanKurirMP.value = kurir;
      c.hargaKeranjangMP.value = c.hargaKeranjangMP.value - c.ongkirMP.value;
      c.hargaKeranjangMPTotal.value = c.hargaKeranjangMP.value;
    } else if (c.pilihanKurirMP.value == 'sendiri') {
      c.pilihanKurirMP.value = 'kurir';
      clearbutton();
      fill2.value = Warna.warnautama;
      text2.value = Warna.putih;
      c.hargaKeranjangMP.value = c.hargaKeranjangMP.value + c.ongkirMP.value;
      c.hargaKeranjangMPTotal.value = c.hargaKeranjangMP.value;
      c.pilihanKurirMP.value = kurir;
    } else {
      clearbutton();
      print(c.pilihanKurirMP.value);
    }
  }

  void pemeriksaanSebelumPembayaran() {
    if (c.jumlahItemMP.value == 0) {
      Get.snackbar('Error',
          'Opps...sepertinya pilihan kamu belum lengkap, lengkapi dulu ya..',
          colorText: Warna.putih, snackPosition: SnackPosition.BOTTOM);
    } else if (c.ekspedisiNasional.value == false) {
      if (c.alamatKirimMP.value == '') {
        Get.snackbar('Error',
            'Opps...sepertinya Alamat kirim belum lengkap, lengkapi dulu ya..',
            colorText: Warna.putih, snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.to(() => PembayaranMarketplace());
      }
    } else if (c.ekspedisiNasional.value == true) {
      if (c.alamatKirimNasional.value == '') {
        Get.snackbar('Error',
            'Opps...sepertinya Alamat kirim belum lengkap, lengkapi dulu ya..',
            colorText: Warna.putih, snackPosition: SnackPosition.BOTTOM);
      } else if (namaexpPilihan.value == '') {
        Get.snackbar('Error',
            'Opps...sepertinya kamu belum memilih expedisi, lengkapi dulu ya..',
            colorText: Warna.putih, snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.to(() => PembayaranMarketplace());
      }
    }
  }

  pengirimanExpedisiTersedia() {
    for (var a = 0; a < ongkirList.length; a++) {
      var result = ongkirList[a];
      var image = 'https://sasuka.online/icon/expedisi/${result[0]}';
      var namaexp = result[1];
      var detailExpedisi = result[2];
      var hargaRp = result[3];
      var hargaInt = result[5];

      listExpedisi.add(Container(
        margin: EdgeInsets.all(5),
        child: Container(
            child: Row(
          children: [
            CachedNetworkImage(
                width: Get.width * 0.2,
                height: Get.width * 0.2,
                imageUrl: image,
                errorWidget: (context, url, error) {
                  print(error);
                  return Icon(Icons.error);
                }),
            Padding(padding: EdgeInsets.only(left: 12)),
            SizedBox(
              width: Get.width * 0.45,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(namaexp,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: TextStyle(color: Warna.grey, fontSize: 16)),
                  Text(detailExpedisi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Warna.grey, fontSize: 14)),
                  Text(
                    hargaRp,
                    style: TextStyle(
                        color: Warna.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
            Checkbox(
              value: false,
              onChanged: (newValue) {
                imagePilihan.value = image;
                namaexpPilihan.value = namaexp;
                detailExpedisiPilihan.value = detailExpedisi;
                hargaRpPilihan.value = hargaRp;
                hargaIntPilihan.value = hargaInt;

                c.expedisiNasionalDipilih.value = namaexpPilihan.value;
                c.hargaexpedisiNasionalDipilih.value = hargaIntPilihan.value;
                c.hargaKeranjangMPTotal.value =
                    c.hargaKeranjangMP.value + hargaIntPilihan.value;
                costPerKg = result[6];

                if (beratGramTotal < 1000) {
                } else {
                  var tot = (beratGramTotal / 1000) * costPerKg;
                  hargaIntPilihan.value = tot.round();
                  hargaRpPilihan.value = 'Rp. ${hargaIntPilihan.value},-';
                  c.hargaKeranjangMPTotal.value =
                      c.hargaKeranjangMP.value + hargaIntPilihan.value;
                }

                dataSiap.value = true;
                viewExpedisiFinal.value = true;
                dataExpedisi.value = false;
              },
            )
          ],
        )),
      ));
    }

    return Column(children: listExpedisi);
  }

  pilihanExpedisiFinal() {
    return Container(
      margin: EdgeInsets.all(5),
      child: Container(
          child: Row(
        children: [
          CachedNetworkImage(
              width: Get.width * 0.2,
              height: Get.width * 0.2,
              imageUrl: imagePilihan.value,
              errorWidget: (context, url, error) {
                print(error);
                return Icon(Icons.error);
              }),
          Padding(padding: EdgeInsets.only(left: 12)),
          SizedBox(
            width: Get.width * 0.45,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(namaexpPilihan.value,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(color: Warna.grey, fontSize: 16)),
                Text(detailExpedisiPilihan.value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Warna.grey, fontSize: 14)),
                Obx(() => Text(
                      hargaRpPilihan.value,
                      style: TextStyle(
                          color: Warna.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ))
              ],
            ),
          ),
          Checkbox(
            value: true,
            onChanged: (newValue) {
              imagePilihan.value = '';
              namaexpPilihan.value = '';
              detailExpedisiPilihan.value = '';
              hargaRpPilihan.value = '';
              hargaIntPilihan.value = 0;
              c.hargaKeranjangMPTotal.value =
                  c.hargaKeranjangMP.value - hargaIntPilihan.value;
              listExpedisi = [];
              dataSiap.value = false;
              viewExpedisiFinal.value = false;
              dataExpedisi.value = true;
            },
          )
        ],
      )),
    );
  }
}
