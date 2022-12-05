import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '/base/warna.dart';
import 'package:http/http.dart' as https;
import '../base/api_service.dart';
import '../base/conn.dart';

class SimulasiKredit extends StatefulWidget {
  @override
  State<SimulasiKredit> createState() => _SimulasiKreditState();
}

class _SimulasiKreditState extends State<SimulasiKredit> {
  final ctrlPlafon = TextEditingController();
  final ctrlTenor = TextEditingController();
  var dataready = false;
  final c = Get.find<ApiService>();
  var judul = ''.obs;
  var subJudul = ''.obs;

  var plafondMin = 0.obs;
  var plafondMax = 0.obs;

  var plafondMinRp = '0'.obs;
  var plafondMaxRp = '0'.obs;

  var tenorMin = 0.obs;
  var tenorMax = 0.obs;

  @override
  void initState() {
    super.initState();
    cekProdukPinjaman();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simulasi Kredit'),
        backgroundColor: Warna.warnautama,
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(5),
        height: Get.height * 0.08,
        child: RawMaterialButton(
          onPressed: () {
            periksaKelengkapan();
          },
          constraints: BoxConstraints(),
          elevation: 1.0,
          fillColor: Warna.warnautama,
          child: Text(
            'Hitung Simulasi',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w300, color: Warna.putih),
          ),
          padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(33)),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(22),
        child: ListView(
          children: [
            Obx(() => Text(
                  judul.value,
                  style: TextStyle(fontSize: 22, color: Warna.warnautama),
                )),
            Obx(() => Text(
                  subJudul.value,
                  style: TextStyle(fontSize: 14, color: Warna.warnautama),
                )),
            Padding(padding: EdgeInsets.only(top: 11)),
            Obx(() => Text(
                  'Plafond Pinjaman ' +
                      plafondMinRp.value +
                      ' s/d ' +
                      plafondMaxRp.value,
                  style: TextStyle(fontSize: 14, color: Warna.grey),
                )),
            TextField(
              onChanged: (ss) {},
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Warna.grey),
              controller: ctrlPlafon,
              keyboardType: TextInputType.number,
              inputFormatters: [
                TextInputMask(
                    mask: ['999.999.999.999', '999.999.9999.999'],
                    reverse: true)
              ],
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.map),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            Obx(() => Text(
                  'Jangka waktu Pinjaman ' +
                      tenorMin.value.toString() +
                      ' - ' +
                      tenorMax.value.toString() +
                      ' Bulan',
                  style: TextStyle(fontSize: 14, color: Warna.grey),
                )),
            TextField(
              onChanged: (ss) {},
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Warna.grey),
              controller: ctrlTenor,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.map),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            Padding(padding: EdgeInsets.only(top: 22)),
            Text(
              'Simulasi',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16, color: Warna.grey, fontWeight: FontWeight.w600),
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            DataTable(
                columnSpacing: 1,
                horizontalMargin: 2.0,
                columns: [
                  DataColumn(
                    label: Text('#'),
                  ),
                  DataColumn(
                    label: Text('Pokok'),
                  ),
                  DataColumn(
                    label: Text('Bunga'),
                  ),
                  DataColumn(
                    label: Text('Setoran'),
                  ),
                  DataColumn(
                    label: Text('Saldo'),
                  ),
                ],
                rows: dataSim)
          ],
        ),
      ),
    );
  }

  cekProdukPinjaman() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');
    var idproduk = c.idpinjaman;
    var produk = c.jenisPinjaman;

    var datarequest =
        '{"pid":"$pid","idProduk":"$idproduk","produk":"$produk"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();
    var url = Uri.parse('${c.baseURL}/mobileApps/detailProdukPinjaman');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    // EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        judul.value = hasil['judul'];
        subJudul.value = hasil['subJudulSimulasi'];
        plafondMin.value = hasil['intPlafondMin'];
        plafondMax.value = hasil['intPlafondMax'];
        plafondMinRp.value = hasil['intPlafondMinRp'];
        plafondMaxRp.value = hasil['intPlafondMaxRp'];
        tenorMin.value = hasil['intTenorMin'];
        tenorMax.value = hasil['intTenorMax'];
      } else {
        Get.snackbar("Produk Belum Tersedia",
            'Opps... maaf saat ini produk yang kamu cari belum tersedia');
        Get.back();
      }
    }
  }

  periksaKelengkapan() {
    var nominal = ctrlPlafon.text.replaceAll('.', '');
    var nom = int.parse(nominal);
    var tenor = int.parse(ctrlTenor.text);
    prosesHitungSimulasi(nom, tenor);

    if (nom > plafondMax.value) {
    } else if (nom < plafondMin.value) {
    } else if (tenor > tenorMax.value) {
    } else if (tenor < tenorMin.value) {
    } else {}
  }

  prosesHitungSimulasi(nom, tenor) async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');
    var idproduk = c.idpinjaman;
    var produk = c.jenisPinjaman;

    var datarequest =
        '{"pid":"$pid","nominal":"$nom","tenor":"$tenor","idProduk":"$idproduk","produk":"$produk"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();
    var url = Uri.parse('${c.baseURL}/mobileApps/hitungSimulasi');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    // EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        dataMutasi = hasil['data'];
        listdaftar();
        setState(() {});
      } else {
        Get.snackbar("Produk Belum Tersedia",
            'Opps... maaf saat ini produk yang kamu cari belum tersedia');
        Get.back();
      }
    }
  }

  List<dynamic> dataMutasi = [].obs;
  List<DataRow> dataSim = [];
  listdaftar() {
    dataSim = [];
    var f = NumberFormat('#,###,000');
    print(f.format(12.345));
    if (dataMutasi.length > 0) {
      for (var i = 0; i < dataMutasi.length; i++) {
        var mutasi = dataMutasi[i];

        dataSim.add(
          DataRow(cells: [
            DataCell(Text(mutasi[0].toString())),
            DataCell(Text(f.format(mutasi[2]))),
            DataCell(Text(f.format(mutasi[3]))),
            DataCell(Text(f.format(mutasi[4]))),
            DataCell(Text(f.format(mutasi[5]))),
          ]),
        );
      }
      return dataSim;
    }
  }
}
