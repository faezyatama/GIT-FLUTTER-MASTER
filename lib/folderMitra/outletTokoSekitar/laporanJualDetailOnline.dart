import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import 'package:http/http.dart' as https;
import '/cetak/cetakPOSonline.dart';

class LaporanJualDetailOnline extends StatefulWidget {
  @override
  _LaporanJualDetailOnlineState createState() =>
      _LaporanJualDetailOnlineState();
}

class _LaporanJualDetailOnlineState extends State<LaporanJualDetailOnline> {
  final c = Get.find<ApiService>();

  var kodetrx = ''.obs;
  var pembayaran = ''.obs;
  var totalharga = ''.obs;
  var tanggal = ''.obs;
  var sudahBayar = ''.obs;
  var sisaBayar = ''.obs;

  var notaTotalInt = '0'.obs;
  var notaBayarInt = '0'.obs;
  var notaSisaInt = '0'.obs;

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
        title: Text('Detail Penjualan'),
        backgroundColor: Colors.green,
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.fromLTRB(22, 11, 22, 5),
        height: Get.height * 0.07,
        child: Column(
          children: [
            RawMaterialButton(
              onPressed: () {
                Get.to(() => TTcetakPOSOnline());
              },
              constraints: BoxConstraints(),
              elevation: 1.0,
              fillColor: Colors.green,
              child: Text(
                'Cetak Struk Penjualan',
                style: TextStyle(color: Warna.putih, fontSize: 16),
              ),
              padding: EdgeInsets.fromLTRB(33, 11, 33, 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(9)),
              ),
            )
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
                  'Tanggal',
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
                  'Total Penjualan',
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
                  'Bayar',
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
                  'Kembali',
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
    var kodeTrx = c.kodePenjualanTokoSekitar.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","kodetrx":"$kodeTrx"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLtokosekitar}/mobileAppsOutlet/laporanPenjualanDetailOnline');

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
          kodetrx.value = hasil['kodetrx'];
          pembayaran.value = hasil['pembayaran'];
          totalharga.value = hasil['totalharga'];
          tanggal.value = hasil['tanggal'];
          sudahBayar.value = hasil['sudahBayar'];
          sisaBayar.value = hasil['sisaBayar'];

          //CETAK
          c.dataCetakStruk = hasil['data'];
          c.tanggalPOS = hasil['tanggal'];
          c.bayarRp = hasil['sudahBayar'];
          c.kembaliRp = hasil['sisaBayar'];
          c.totalRp = hasil['total'];
          c.nomorTransaksiPOS = hasil['kodetrx'];

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
        child: Card(
            elevation: 0,
            child: Container(
              margin: EdgeInsets.all(11),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
      ));
    }
    return Column(children: order);
  }
}
