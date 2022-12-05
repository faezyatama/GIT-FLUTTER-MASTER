//ROUTE SUDAH DIPERIKSA
import 'dart:async';
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as https;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';

import 'daftarAntaranIntegrasi.dart';

class DaftarPesananTS extends StatefulWidget {
  DaftarPesananTS({this.kodePesanan});
  final String kodePesanan;

  @override
  _DaftarPesananTSState createState() => _DaftarPesananTSState();
}

class _DaftarPesananTSState extends State<DaftarPesananTS> {
  final c = Get.find<ApiService>();
  bool dataSiap = false;
  var namaoutlet = ''.obs;
  var jumlahpesanan = ''.obs;
  var ongkoskirim = ''.obs;
  var totalpesanan = ''.obs;
  var tanggal = ''.obs;
  var kode = ''.obs;
  var pembayaran = ''.obs;
  var expedisi = ''.obs;
  var tahapanstatus = ''.obs;
  var detailTransfer = [];
  var awb = false;
  var penerima = [];
  var onProsesAntaran = ''.obs;
  var statusPengantaran = ''.obs;
  Timer timer;

  @override
  void initState() {
    super.initState();
    rekapBelanjadanAlamat();

    timer = Timer.periodic(
        Duration(seconds: 8), (Timer t) => cekOrderBerlangsung());
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.warnautama,
        title: Text('Detail Antaran Toko Sekitar'),
      ),
      bottomNavigationBar: Obx(() => Container(
          margin: EdgeInsets.fromLTRB(22, 8, 22, 8),
          height: Get.height * 0.06,
          child: (onProsesAntaran.value == 'PENGIRIMAN')
              ? RawMaterialButton(
                  onPressed: () {
                    serahkanBarangKeKonsumen();
                  },
                  constraints: BoxConstraints(),
                  elevation: 1.0,
                  fillColor: Warna.warnautama,
                  child: Text(
                    'Serahkan Barang',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  padding: EdgeInsets.fromLTRB(22, 6, 22, 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(33)),
                  ),
                )
              : RawMaterialButton(
                  onPressed: () {},
                  constraints: BoxConstraints(),
                  elevation: 0,
                  fillColor: (statusPengantaran.value == '')
                      ? Warna.putih
                      : Colors.green,
                  child: Obx(() => Text(
                        statusPengantaran.value,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      )),
                  padding: EdgeInsets.fromLTRB(22, 6, 22, 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(33)),
                  ),
                ))),
      body: ListView(
        children: [
          Container(
            color: Colors.grey[200],
            padding: EdgeInsets.fromLTRB(22, 22, 22, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaksi',
                      style: TextStyle(color: Warna.grey),
                    ),
                    Obx(() => Column(
                          children: [
                            Text(
                              kode.value,
                              style: TextStyle(
                                  color: Warna.warnautama,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              tanggal.value,
                              style: TextStyle(color: Warna.grey, fontSize: 11),
                            ),
                          ],
                        )),
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: Colors.grey[200],
            padding: EdgeInsets.fromLTRB(22, 0, 22, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status',
                      style: TextStyle(color: Warna.grey),
                    ),
                    SizedBox(
                      width: Get.width * 0.6,
                      child: Obx(
                        () => Text(
                          tahapanstatus.value,
                          overflow: TextOverflow.clip,
                          maxLines: 3,
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Warna.grey, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 5, bottom: 11),
            height: 7,
            color: Colors.grey[200],
          ),
          Container(
            padding: EdgeInsets.fromLTRB(22, 0, 22, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Outlet',
                      style: TextStyle(color: Warna.grey),
                    ),
                    Obx(() => Text(
                          namaoutlet.value,
                          style: TextStyle(
                              color: Warna.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        )),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(22, 0, 22, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pesanan :',
                      style: TextStyle(color: Warna.grey),
                    ),
                    Obx(() => Text(
                          jumlahpesanan.value,
                          style: TextStyle(color: Warna.grey, fontSize: 16),
                        )),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(22, 0, 22, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ongkos Kirim',
                      style: TextStyle(color: Warna.grey),
                    ),
                    Obx(() => Text(
                          ongkoskirim.value,
                          style: TextStyle(color: Warna.grey, fontSize: 16),
                        )),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(22, 0, 22, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(color: Warna.grey),
                    ),
                    Obx(() => Text(
                          totalpesanan.value,
                          style: TextStyle(
                              color: Warna.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        )),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 11, bottom: 11),
            height: 7,
            color: Colors.grey[200],
          ),
          Container(
            padding: EdgeInsets.fromLTRB(22, 0, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pembayaran via',
                      style: TextStyle(color: Warna.grey),
                    ),
                    RawMaterialButton(
                      onPressed: () {},
                      constraints: BoxConstraints(),
                      elevation: 0,
                      fillColor: Colors.green,
                      child: Obx(() => Text(
                            pembayaran.value,
                            style: TextStyle(color: Warna.putih, fontSize: 16),
                          )),
                      padding: EdgeInsets.fromLTRB(14, 1, 14, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 7,
            color: Colors.grey[200],
          ),
          Container(
            padding: EdgeInsets.fromLTRB(22, 0, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Expedisi / Pengiriman',
                      style: TextStyle(color: Warna.grey),
                    ),
                    RawMaterialButton(
                      onPressed: () {},
                      constraints: BoxConstraints(),
                      elevation: 0,
                      fillColor: Colors.blue,
                      child: Obx(() => Text(
                            expedisi.value,
                            style: TextStyle(color: Warna.putih, fontSize: 16),
                          )),
                      padding: EdgeInsets.fromLTRB(14, 1, 14, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          (awb == true)
              ? Container(
                  padding: EdgeInsets.fromLTRB(22, 0, 22, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'No Resi :',
                            style: TextStyle(color: Warna.grey),
                          ),
                          Text(
                            penerima[5],
                            style: TextStyle(
                                color: Warna.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : Container(),
          (awb == true)
              ? Container(
                  padding: EdgeInsets.fromLTRB(22, 12, 22, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Dikirim :',
                            style: TextStyle(color: Warna.grey),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                penerima[0],
                                style: TextStyle(
                                    color: Warna.grey,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16),
                              ),
                              Text(
                                penerima[1] + ' - ' + penerima[2],
                                style:
                                    TextStyle(color: Warna.grey, fontSize: 14),
                              ),
                              Text(
                                penerima[3] + ' - ' + penerima[4],
                                style:
                                    TextStyle(color: Warna.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : Container(),
          Container(
            height: 7,
            color: Colors.grey[200],
          ),
          Container(
            padding: EdgeInsets.fromLTRB(22, 11, 22, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order :',
                      style: TextStyle(color: Warna.grey),
                    ),
                  ],
                ),
              ],
            ),
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
    var kodetrx = widget.kodePesanan;

    var datarequest = '{"pid":"$pid","kodetrx":"$kodetrx"}';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse(
        'https://apiservice.tokosekitar.com/kurirTS/detailBelanjaanTokoSekitar');

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
        var transaksi = hasil['data'];
        namaoutlet.value = transaksi[0];
        jumlahpesanan.value = transaksi[1];
        ongkoskirim.value = transaksi[2];
        totalpesanan.value = transaksi[3];
        kode.value = transaksi[4];
        tanggal.value = transaksi[5];
        pembayaran.value = transaksi[8];
        expedisi.value = transaksi[9];
        tahapanstatus.value = transaksi[6];
        onProsesAntaran.value = hasil['prosesAntaran'];
        dataBarang = hasil['order'];
        detailTransfer = hasil['detailTransfer'];

        if (mounted) {
          setState(() {
            awb = hasil['awb'];
            penerima = hasil['penerima'];
            dataSiap = true;
          });
        }
      }
    }
  }

  List<Container> listdatabarang = [];
  List dataBarang = [];

  listdaftar() {
    if (dataBarang.length > 0) {
      for (var i = 0; i < dataBarang.length; i++) {
        var item = dataBarang[i];
        var namamakanan = item[0];
        var quantity = item[1];
        var hargasatuan = item[2];
        var hargajumlah = item[3];
        var pic = item[4];

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
                        imageUrl: pic,
                        width: Get.width * 0.15,
                        height: Get.width * 0.15,
                      ),
                      Padding(padding: EdgeInsets.only(left: 11)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: Get.width * 0.7,
                            child: Text(
                              namamakanan, //nama makanan
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(fontSize: 20, color: Warna.grey),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 5)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$quantity x $hargasatuan',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style:
                                    TextStyle(fontSize: 16, color: Warna.grey),
                              ),
                              Padding(padding: EdgeInsets.only(left: 55)),
                              Text(
                                '$hargajumlah',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style:
                                    TextStyle(fontSize: 16, color: Warna.grey),
                              )
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

  void serahkanBarangKeKonsumen() {
    final controllerKode = TextEditingController();
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Image.asset(
            'images/secure.png',
            width: Get.width * 0.3,
          ),
          Text('Penyerahan Barang',
              style: TextStyle(
                  fontSize: 18,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w600)),
          Padding(padding: EdgeInsets.only(top: 16)),
          Text(
              'Untuk menyelesaikan order ini silahkan masukan Kode Serah Terima',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center),
          Text(
            'Silahkan minta kode serah terima dari Konsumen',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Warna.grey),
            textAlign: TextAlign.center,
          ),
          Padding(padding: EdgeInsets.only(top: 9)),
          Padding(padding: EdgeInsets.only(top: 16)),
          Container(
            width: Get.width * 0.7,
            child: TextField(
              textAlign: TextAlign.center,
              maxLength: 5,
              style: TextStyle(
                  fontSize: 25, fontWeight: FontWeight.w600, color: Warna.grey),
              controller: controllerKode,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.vpn_key),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          RawMaterialButton(
            constraints: BoxConstraints(minWidth: Get.width * 0.7),
            elevation: 1.0,
            fillColor: Warna.warnautama,
            child: Text(
              'Serahkan Barang',
              style: TextStyle(color: Warna.putih, fontSize: 14),
            ),
            padding: EdgeInsets.fromLTRB(18, 9, 18, 9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            onPressed: () {
              if ((controllerKode.text == '') ||
                  (controllerKode.text.length != 5)) {
                controllerKode.text = '';
                Get.back();
                AwesomeDialog(
                  context: Get.context,
                  dialogType: DialogType.noHeader,
                  animType: AnimType.rightSlide,
                  title: 'PERHATIAN !',
                  desc:
                      'Kode tidak dimasukan dengan benar, Kode hanya berisi 5 angka',
                  btnCancelText: 'OK',
                  btnCancelColor: Colors.amber,
                  btnCancelOnPress: () {},
                )..show();
              } else {
                selesaikanPengantaran(controllerKode.text);
              }
            },
          ),
        ],
      ),
    )..show();
  }

  void selesaikanPengantaran(String kodeST) async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var kodetrx = widget.kodePesanan;

    var datarequest =
        '{"pid":"$pid","kodetrx":"$kodetrx","kodeSerahTerima":"$kodeST"}';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse(
        'https://apiservice.tokosekitar.com/kurirTS/SelesaikanPengantaranViaKurir');

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
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          dismissOnBackKeyPress: false,
          dismissOnTouchOutside: false,
          title: 'Pengantaran Selesai',
          desc: 'Pengantaran telah berhasil diselesaikan',
          btnCancelText: 'OK',
          btnCancelColor: Colors.green,
          btnCancelOnPress: () {
            Get.back();
            Get.back();
            Get.back();
            Get.to(() => DaftarAntaran());
          },
        )..show();
      } else if (hasil['status'] == 'kode salah') {
        Get.back();
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'Kode Salah',
          desc:
              'Opps... sepertinya kamu memasukan kode yang salah, Ulangi pengisian kode serah terima',
          btnCancelText: 'OK',
          btnCancelColor: Colors.red,
          btnCancelOnPress: () {
            Get.back();
          },
        )..show();
      } else {
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          dismissOnBackKeyPress: false,
          dismissOnTouchOutside: false,
          title: 'TRANSAKSI EXPIRE',
          desc: hasil['message'],
          btnCancelText: 'OK',
          btnCancelColor: Colors.amber,
          btnCancelOnPress: () {
            Get.back();
            Get.back();
            Get.back();
            Get.to(() => DaftarAntaran());
          },
        )..show();
      }
    }
  }

  cekOrderBerlangsung() async {
    bool conn = await cekInternet();
    if (!conn) {
      return;
    }
    if (c.timerDetailPesananBarangIntegrasi.value == false) {
      return;
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var kodetrx = widget.kodePesanan;

    var datarequest = '{"pid":"$pid","kodetrx":"$kodetrx"}';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse(
        '${c.baseURLdriver}/mobileAppsMitraDriver/CekTrxIniIntegrasi');

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
        onProsesAntaran.value = 'Sukses';
        statusPengantaran.value = 'Pengantaran Telah Selesai';
      }
    }
  }
}
