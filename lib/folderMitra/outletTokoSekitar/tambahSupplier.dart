import 'dart:convert';
import 'package:http/http.dart' as https;
import 'package:crypto/crypto.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import 'supplierPOS.dart';

class TambahSupplier extends StatefulWidget {
  @override
  _TambahSupplierState createState() => _TambahSupplierState();
}

class _TambahSupplierState extends State<TambahSupplier> {
  final controllerNama = TextEditingController();
  final controllerHP = TextEditingController();
  final controllerAlamat = TextEditingController();

  final c = Get.find<ApiService>();

  List<String> listProvinsi = [];
  var dataprovinsi = false;
  var pilihanProvinsi = '';

  var provinsi = 'Provinsi'.obs;
  var kabupaten = 'Kabupaten'.obs;

  List<String> listKabupaten = [];
  var datakab = false;
  var pilihanKabupaten = '';

  @override
  void initState() {
    super.initState();
    provinsiCek();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Supplier'),
        backgroundColor: Colors.green,
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(11),
        child: RawMaterialButton(
          onPressed: () {
            cekKelengkapanData();
          },
          constraints: BoxConstraints(),
          elevation: 1.0,
          fillColor: Colors.green,
          child: Text(
            'Tambah Suplier !',
            style: TextStyle(color: Warna.putih, fontSize: 16),
          ),
          padding: EdgeInsets.fromLTRB(22, 11, 22, 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(9)),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(22),
        child: ListView(
          children: [
            Container(
              child: Text(
                'Tambah Supplier',
                style: TextStyle(
                    fontSize: 33,
                    color: Warna.grey,
                    fontWeight: FontWeight.w200),
              ),
            ),
            Container(
              child: Text(
                'Tambahkan supplier untuk mempermudah pengaturan barang masuk/Pembelian dan mengelola nota pembelian',
                style: TextStyle(
                  fontSize: 14,
                  color: Warna.grey,
                ),
              ),
            ),
            Container(
              child: Text(
                'Transaksi pembelian kamu kini menjadi lebih rapi',
                style: TextStyle(
                  fontSize: 14,
                  color: Warna.grey,
                ),
              ),
            ),
            Padding(padding: EdgeInsets.all(22)),
            Container(
              child: TextField(
                onChanged: (ss) {},
                maxLength: 30,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Warna.warnautama),
                controller: controllerNama,
                decoration: InputDecoration(
                    labelText: 'Nama Supplier',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            Container(
              child: TextField(
                onChanged: (ss) {},
                maxLength: 50,
                keyboardType: TextInputType.number,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Warna.warnautama),
                controller: controllerHP,
                decoration: InputDecoration(
                    labelText: 'Telepon / HP',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            Container(
              child: TextField(
                onChanged: (ss) {},
                maxLength: 50,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Warna.warnautama),
                controller: controllerAlamat,
                decoration: InputDecoration(
                    labelText: 'Alamat',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            (dataprovinsi == true)
                ? DropdownSearch<String>(
                    items: listProvinsi,
                    popupProps: PopupProps.menu(
                      showSelectedItems: true,
                      disabledItemFn: (String s) => s.startsWith('I'),
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Provinsi",
                      ),
                    ),
                    onChanged: (propValue) {
                      setState(() {
                        pilihanKabupaten = '';
                      });

                      pilihanProvinsi = propValue;
                      kabupatenCek(propValue);
                    },
                    selectedItem: pilihanProvinsi)
                : Padding(padding: EdgeInsets.only(top: 11)),
            Padding(padding: EdgeInsets.only(top: 22)),
            (datakab == true)
                ? DropdownSearch<String>(
                    items: listKabupaten,
                    popupProps: PopupProps.menu(
                      showSelectedItems: true,
                      disabledItemFn: (String s) => s.startsWith('I'),
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Kabupaten",
                      ),
                    ),
                    onChanged: (kabValue) {
                      pilihanKabupaten = kabValue;
                    },
                    selectedItem: pilihanKabupaten)
                : Padding(padding: EdgeInsets.only(top: 11)),
            Padding(padding: EdgeInsets.only(top: 22)),
          ],
        ),
      ),
    );
  }

  provinsiCek() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var latitude = c.latitude.value;
    var longitude = c.longitude.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","lat":"$latitude","long":"$longitude"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLtokosekitar}/mobileAppsOutlet/provinsi');

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
        listProvinsi = List<String>.from(hasil['provinsi']);
        setState(() {
          dataprovinsi = true;
        });
      }
    }
  }

  void kabupatenCek(String propValue) async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var provinsi = propValue;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","provinsi":"$provinsi"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLtokosekitar}/mobileAppsOutlet/kabupaten');

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
        listKabupaten = List<String>.from(hasil['kabupaten']);

        setState(() {
          datakab = true;
        });
      }
    }
  }

  void tambahkanSupplierBaru() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var namaSupplier = controllerNama.text;
    var teleponSup = controllerHP.text;
    var alamat = controllerAlamat.text;
    var provinsi = pilihanProvinsi;
    var kabupaten = pilihanKabupaten;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","namaSupplier":"$namaSupplier","teleponSup":"$teleponSup","alamat":"$alamat","kabupaten":"$kabupaten","provinsi":"$provinsi"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLtokosekitar}/mobileAppsOutlet/tambahSuplier');

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
        Get.off(SupplierPOS());
      } else {
        Get.snackbar('Gagal !', hasil['message']);
        Get.off(SupplierPOS());
      }
    }
  }

  void cekKelengkapanData() {
    if (controllerNama.text == '') {
      Get.snackbar(
          'Data Belum Lengkap', 'Sepertinya nama supplier belum diisi');
      return;
    } else if (controllerHP.text == '') {
      Get.snackbar(
          'Data Belum Lengkap', 'Sepertinya Nomor Telepon / HP belum diisi');
      return;
    } else if (controllerAlamat.text == '') {
      Get.snackbar(
          'Data Belum Lengkap', 'Sepertinya alamat supplier belum diisi');
      return;
    } else if (pilihanProvinsi == '') {
      Get.snackbar('Data Belum Lengkap',
          'Sepertinya lokasi provinsi supplier belum diisi');
      return;
    } else if (pilihanKabupaten == '') {
      Get.snackbar('Data Belum Lengkap',
          'Sepertinya lokasi kabupaten supplier belum diisi');
      return;
    } else {
      tambahkanSupplierBaru();
    }
  }
}
