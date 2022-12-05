import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:crypto/crypto.dart';
import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import 'package:http/http.dart' as https;
import 'LaporanBeli.dart';

class LaporanDetailLunas extends StatefulWidget {
  @override
  _LaporanDetailLunasState createState() => _LaporanDetailLunasState();
}

class _LaporanDetailLunasState extends State<LaporanDetailLunas> {
  final c = Get.find<ApiService>();
  var suplier = ''.obs;
  var alamat = ''.obs;
  var hp = ''.obs;
  var kodetrx = ''.obs;
  var pembayaran = ''.obs;
  var totalharga = ''.obs;
  var tanggal = ''.obs;
  var tanggalJatuhTempo = ''.obs;
  var sudahBayar = ''.obs;
  var sisaBayar = ''.obs;

  var notaTotalInt = '0'.obs;
  var notaBayarInt = '0'.obs;
  var notaSisaInt = '0'.obs;

  var notaTotalIntView = '0'.obs;
  var notaBayarIntView = '0'.obs;
  var notaSisaIntView = '0'.obs;

  final ctrlbayar = TextEditingController();

  var adaDataDitampilkan = 'blank';
  bool dataSiap = false;
  @override
  void initState() {
    super.initState();
    cekLaporan();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pembelian'),
        backgroundColor: Colors.green,
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.fromLTRB(22, 11, 22, 5),
        height: Get.height * 0.07,
        child: Column(
          children: [
            (pembayaran.value == 'Kredit')
                ? RawMaterialButton(
                    onPressed: () {
                      cicilPembelianKredit();
                    },
                    constraints: BoxConstraints(),
                    elevation: 1.0,
                    fillColor: Colors.green,
                    child: Text(
                      'Pembayaran Cicilan / Pelunasan',
                      style: TextStyle(color: Warna.putih, fontSize: 16),
                    ),
                    padding: EdgeInsets.fromLTRB(33, 11, 33, 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                    ),
                  )
                : Container(),
            (pembayaran.value == 'Konsinyasi')
                ? RawMaterialButton(
                    onPressed: () {},
                    constraints: BoxConstraints(),
                    elevation: 1.0,
                    fillColor: Colors.green,
                    child: Text(
                      'Retur Barang / Pembayaran',
                      style: TextStyle(color: Warna.putih, fontSize: 16),
                    ),
                    padding: EdgeInsets.fromLTRB(33, 11, 33, 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
      body: ListView(
        children: [
          Padding(padding: EdgeInsets.fromLTRB(22, 22, 22, 1)),
          Container(
            padding: EdgeInsets.fromLTRB(22, 1, 22, 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Supplier',
                  style: TextStyle(fontSize: 12, color: Warna.grey),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Obx(() => SizedBox(
                          width: Get.width * 0.6,
                          child: Text(
                            suplier.value,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 16,
                                color: Warna.grey,
                                fontWeight: FontWeight.w600),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(22, 1, 22, 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Alamat',
                  style: TextStyle(fontSize: 12, color: Warna.grey),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Obx(() => SizedBox(
                          width: Get.width * 0.6,
                          child: Text(
                            alamat.value,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 12,
                                color: Warna.grey,
                                fontWeight: FontWeight.w600),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(22, 1, 22, 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Telp/HP Supplier',
                  style: TextStyle(fontSize: 12, color: Warna.grey),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Obx(() => Text(
                          hp.value,
                          style: TextStyle(
                              fontSize: 12,
                              color: Warna.grey,
                              fontWeight: FontWeight.w600),
                        )),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(22, 1, 22, 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'KodeTrx',
                  style: TextStyle(fontSize: 12, color: Warna.grey),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Obx(() => Text(
                          kodetrx.value,
                          style: TextStyle(
                              fontSize: 12,
                              color: Warna.grey,
                              fontWeight: FontWeight.w600),
                        )),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(22, 1, 22, 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tanggal Pembelian',
                  style: TextStyle(fontSize: 12, color: Warna.grey),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Obx(() => Text(
                          tanggal.value,
                          style: TextStyle(
                              fontSize: 12,
                              color: Warna.grey,
                              fontWeight: FontWeight.w600),
                        )),
                  ],
                ),
              ],
            ),
          ),
          Divider(),
          Container(
            padding: EdgeInsets.fromLTRB(22, 1, 22, 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Pembelian',
                  style: TextStyle(fontSize: 12, color: Warna.grey),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Obx(() => Text(
                          totalharga.value,
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.green,
                              fontWeight: FontWeight.w600),
                        )),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(22, 1, 22, 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Bayar',
                  style: TextStyle(fontSize: 12, color: Warna.grey),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Obx(() => Text(
                          sudahBayar.value,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w600),
                        )),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(22, 1, 22, 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sisa',
                  style: TextStyle(fontSize: 12, color: Warna.grey),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Obx(() => Text(
                          sisaBayar.value,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w600),
                        )),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(22, 1, 22, 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status Pembayaran',
                  style: TextStyle(fontSize: 12, color: Warna.grey),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Obx(() => Text(
                          pembayaran.value,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w600),
                        )),
                  ],
                ),
              ],
            ),
          ),
          (pembayaran.value == 'Kredit')
              ? Container(
                  padding: EdgeInsets.fromLTRB(22, 1, 22, 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tanggal Jatuh Tempo',
                        style: TextStyle(fontSize: 12, color: Warna.grey),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Obx(() => Text(
                                tanggalJatuhTempo.value,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600),
                              )),
                        ],
                      ),
                    ],
                  ),
                )
              : Container(),
          Divider(),
          Padding(padding: EdgeInsets.only(top: 12)),
          Center(
            child: Text(
              'Daftar Pembelian Produk :',
              style: TextStyle(
                  fontSize: 16, color: Warna.grey, fontWeight: FontWeight.w600),
            ),
          ),
          (adaDataDitampilkan == 'ada') ? listdaftar() : Container(),
        ],
      ),
    );
  }

  cekLaporan() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var kodeTrx = c.kodePembelianTokoSekitar.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","kodetrx":"$kodeTrx"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLtokosekitar}/mobileAppsOutlet/laporanPembelianLunasDetail');

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
        if (mounted) {
          suplier.value = hasil['suplier'];
          alamat.value = hasil['alamat'];
          hp.value = hasil['hp'];
          kodetrx.value = hasil['kodetrx'];
          pembayaran.value = hasil['pembayaran'];
          totalharga.value = hasil['totalharga'];
          tanggal.value = hasil['tanggal'];
          tanggalJatuhTempo.value = hasil['tanggalJatuhTempo'];
          sudahBayar.value = hasil['sudahBayar'];
          sisaBayar.value = hasil['sisaBayar'];

          notaTotalInt.value = hasil['notaTotalInt'];
          notaBayarInt.value = hasil['notaBayarInt'];
          notaSisaInt.value = hasil['notaSisaInt'];

          notaTotalIntView.value = hasil['notaTotalInt'];
          notaBayarIntView.value = hasil['notaBayarInt'];
          notaSisaIntView.value = hasil['notaSisaInt'];

          setState(() {
            dataSiap = true;
            dataOrder = hasil['data'];
            adaDataDitampilkan = 'ada';
          });
        }
      } else if (hasil['status'] == 'no data') {
        setState(() {
          adaDataDitampilkan = 'tidak';
        });
      }
    }
  }

  List dataOrder = [];
  List<Container> order = [];
  listdaftar() {
    for (var a = 0; a < dataOrder.length; a++) {
      var ord = dataOrder[a];

      order.add(Container(
        child: GestureDetector(
          onTap: () {
            c.kodePembelianTokoSekitar.value = ord[0];
            Get.to(() => LaporanDetailLunas());
          },
          child: Card(
              elevation: 0,
              child: Container(
                margin: EdgeInsets.all(11),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: Get.width * 0.55,
                            child: Text(
                              ord[3], //name
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Warna.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300),
                            ),
                          ),
                          SizedBox(
                            width: Get.width * 0.55,
                            child: Text(
                              '${ord[0]}', //kategori
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Warna.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      ord[2], //HARGA
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Warna.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w200),
                    ),
                  ],
                ),
              )),
        ),
      ));
    }
    return Column(children: order);
  }

  void cicilPembelianKredit() {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      body: Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(22, 1, 22, 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Pembelian',
                    style: TextStyle(fontSize: 12, color: Warna.grey),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Obx(() => Text(
                            notaTotalIntView.value.toString(),
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.w600),
                          )),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(22, 1, 22, 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Bayar',
                    style: TextStyle(fontSize: 12, color: Warna.grey),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Obx(() => Text(
                            notaBayarIntView.value.toString(),
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.w600),
                          )),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(22, 1, 22, 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sisa',
                    style: TextStyle(fontSize: 12, color: Warna.grey),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Obx(() => Text(
                            notaSisaIntView.value.toString(),
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.w600),
                          )),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
            Padding(padding: EdgeInsets.only(top: 22)),
            Text(
              'Pembayaran Pembelian Kredit',
              style: TextStyle(fontSize: 16, color: Warna.grey),
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            Container(
              padding: EdgeInsets.fromLTRB(22, 2, 22, 2),
              child: TextField(
                onChanged: (ss) {
                  prosesHitungan();
                },
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Warna.grey),
                controller: ctrlbayar,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  TextInputMask(
                      mask: ['999,999,999,999', '999,999,999,999'],
                      reverse: true)
                ],
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
          ],
        ),
      ),
      btnOkColor: Colors.green,
      btnOkText: 'Catat Pembayaran',
      btnOkOnPress: () {
        buatPembayaranPembelian();
      },
    )..show();
  }

  prosesHitungan() {
    //bersihkan titik dan koma
    var hDis = ctrlbayar.text.replaceAll('.', '');
    var textInput = hDis.replaceAll(',', '');

    var hDis2 = notaTotalInt.value.replaceAll('.', '');
    var totalBeli = hDis2.replaceAll(',', '');

    var hDis3 = notaBayarInt.value.replaceAll('.', '');
    var totalBayar = hDis3.replaceAll(',', '');

    var hDis4 = notaSisaInt.value.replaceAll('.', '');
    var sisaBayar = hDis4.replaceAll(',', '');

    var tbayar = int.parse(totalBayar) + int.parse(textInput);
    var tsisa = int.parse(totalBeli) - tbayar;
    var f = NumberFormat('#,###,###');
    var cc = f.format(tbayar);
    var ss = f.format(tsisa);
    var maxBayar = f.format(int.parse(totalBeli));
    var maxSisa = f.format(int.parse(sisaBayar));

    if (tsisa < 0) {
      notaBayarIntView.value = maxBayar;
      notaSisaIntView.value = '0';
      ctrlbayar.text = maxSisa;
    } else {
      notaBayarIntView.value = cc;
      notaSisaIntView.value = ss;
    }
  }

  void buatPembayaranPembelian() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var kodeTrx = c.kodePembelianTokoSekitar.value;
    var jumBayar = ctrlbayar.text;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","kodetrx":"$kodeTrx","jumBayar":"$jumBayar"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLtokosekitar}/mobileAppsOutlet/bayarPembelianKredit');

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
        Get.snackbar(
            'Proses Berhasil', 'Proses pencatatan pembayaran kredit berhasil');
        Get.back();
        Get.back();
        Get.back();
        Get.to(() => LaporanPembelianProduk());
      } else {
        Get.snackbar('Proses Gagal !',
            'Proses pencatatan pembayaran kredit gagal, Periksa kembali pengisian data');
      }
    }
  }
}
