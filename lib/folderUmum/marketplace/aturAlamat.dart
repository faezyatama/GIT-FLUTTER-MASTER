import 'dart:convert';
import 'package:http/http.dart' as https;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:dropdown_search/dropdown_search.dart';

import 'cekoutKeranjang.dart';

class AturAlamatKirimMarketplace extends StatefulWidget {
  @override
  _AturAlamatKirimMarketplaceState createState() =>
      _AturAlamatKirimMarketplaceState();
}

class _AturAlamatKirimMarketplaceState
    extends State<AturAlamatKirimMarketplace> {
  final c = Get.find<ApiService>();

  final controllerAlamat = TextEditingController();
  final controllerSave = TextEditingController();
  final controllerhp = TextEditingController();
  final controllernama = TextEditingController();
  bool dataAlamat = false;
  bool dataAlamatTersedia = false;
  List<String> listProvinsi = [];
  var dataprovinsi = false;
  var pilihanProvinsi = '';

  List<String> listKabupaten = [];
  var datakab = false;
  var pilihanKabupaten = '';

  List<String> listKecamatan = [];
  var dataKec = false;
  var pilihanKecamatan = '';

  @override
  void initState() {
    super.initState();
    cekAlamatTersedia();
    provinsiCek();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Atur Alamat kamu disini'),
        backgroundColor: Warna.warnautama,
      ),
      body: Container(
        padding: EdgeInsets.all(22),
        child: ListView(
          children: [
            Text('Daftar Alamat kamu',
                style: TextStyle(
                    color: Warna.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            Padding(padding: EdgeInsets.only(top: 11)),
            (dataAlamatTersedia == true)
                ? tampilkanAlamat()
                : LinearProgressIndicator(),
            Padding(padding: EdgeInsets.only(top: 22)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tambah Alamat baru',
                    style: TextStyle(
                        color: Warna.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(color: Warna.warnautama)))),
                  onPressed: () {
                    periksaForm();
                  },
                  child: Text(
                    '+ Tambah Alamat',
                    style: TextStyle(color: Warna.warnautama),
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            Container(
              child: TextField(
                style: TextStyle(fontSize: 21),
                controller: controllerSave,
                decoration: InputDecoration(
                    labelText: 'Simpan Sebagai (Rumah / Kantor / ...',
                    labelStyle: TextStyle(fontSize: 15),
                    prefixIcon: Icon(Icons.map),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5))),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            Container(
              child: TextField(
                style: TextStyle(fontSize: 21),
                controller: controllernama,
                decoration: InputDecoration(
                    labelText: 'Nama Penerima Paket',
                    labelStyle: TextStyle(fontSize: 15),
                    //  prefixIcon: Icon(Icons.local_airport),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5))),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            Container(
              child: TextField(
                style: TextStyle(fontSize: 21),
                controller: controllerAlamat,
                decoration: InputDecoration(
                    labelText: 'Alamat',
                    labelStyle: TextStyle(fontSize: 15),
                    //  prefixIcon: Icon(Icons.local_airport),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5))),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            Container(
              child: TextField(
                style: TextStyle(fontSize: 21),
                controller: controllerhp,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    labelText: 'Nomot Telepon / HP',
                    labelStyle: TextStyle(fontSize: 15),
                    //  prefixIcon: Icon(Icons.local_airport),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5))),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            (dataprovinsi == true)
                ? DropdownSearch<String>(
                    popupProps: PopupProps.menu(
                      showSelectedItems: true,
                      disabledItemFn: (String s) => s.startsWith('I'),
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Provinsi",
                      ),
                    ),
                    items: listProvinsi,
                    onChanged: (propValue) {
                      setState(() {
                        pilihanKabupaten = '';
                        pilihanKecamatan = '';
                        dataKec = false;
                      });

                      pilihanProvinsi = propValue;
                      kabupatenCek(propValue);
                    },
                    selectedItem: pilihanProvinsi)
                : Padding(padding: EdgeInsets.only(top: 11)),
            Padding(padding: EdgeInsets.only(top: 11)),
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
                      pilihanKecamatan = '';
                      kecamatanCek(kabValue);
                    },
                    selectedItem: pilihanKabupaten)
                : Padding(padding: EdgeInsets.only(top: 11)),
            Padding(padding: EdgeInsets.only(top: 22)),
            (dataKec == true)
                ? DropdownSearch<String>(
                    items: listKecamatan,
                    popupProps: PopupProps.menu(
                      showSelectedItems: true,
                      disabledItemFn: (String s) => s.startsWith('I'),
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Kecamatan",
                      ),
                    ),
                    onChanged: (kecValue) {
                      pilihanKecamatan = kecValue;
                    },
                    selectedItem: pilihanKecamatan)
                : Padding(padding: EdgeInsets.only(top: 11)),
            Padding(padding: EdgeInsets.only(top: 22)),
          ],
        ),
      ),
    );
  }

  List dataProvinsiKita = [];
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

    var url = Uri.parse('${c.baseURLmp}/mobileAppsUser/provinsi');

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

    var url = Uri.parse('${c.baseURLmp}/mobileAppsUser/kabupaten');

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

  void kecamatanCek(String kab) async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var kab = pilihanKabupaten;
    var prov = pilihanProvinsi;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","kabupaten":"$kab","provinsi":"$prov"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLmp}/mobileAppsUser/kecamatan');

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
        listKecamatan = List<String>.from(hasil['kecamatan']);
        setState(() {
          dataKec = true;
        });
      }
    }
  }

  void periksaForm() {
    if (controllerAlamat.text == '') {
      Get.snackbar('Alamat Salah',
          'Opps sepertinya alamat belum dituliskan dengan benar',
          snackPosition: SnackPosition.BOTTOM);
    } else if (controllerSave.text == '') {
      Get.snackbar('Simpan Alamat ini Sebagai',
          'Opps sepertinya alamat belum dituliskan dengan benar',
          snackPosition: SnackPosition.BOTTOM);
    } else if (controllernama.text == '') {
      Get.snackbar('Simpan Alamat ini Sebagai',
          'Opps sepertinya nama penerima belum dituliskan dengan benar',
          snackPosition: SnackPosition.BOTTOM);
    } else if (pilihanProvinsi == '') {
      Get.snackbar('Provinsi Belum diisi',
          'Opps sepertinya provinsi belum dituliskan dengan benar',
          snackPosition: SnackPosition.BOTTOM);
    } else if (pilihanKabupaten == '') {
      Get.snackbar('Kabupaten Belum diisi',
          'Opps sepertinya kabupaten belum dituliskan dengan benar',
          snackPosition: SnackPosition.BOTTOM);
    } else if (pilihanKecamatan == '') {
      Get.snackbar('Kecamatan Belum diisi',
          'Opps sepertinya kecamatan belum dituliskan dengan benar',
          snackPosition: SnackPosition.BOTTOM);
    } else {
      kirimAlamatBaru();
    }
  }

  void kirimAlamatBaru() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var saveAs = controllerSave.text;
    var alamat = controllerAlamat.text;
    var hp = controllerhp.text;
    var nama = controllernama.text;
    var provinsi = pilihanProvinsi;
    var kabupaten = pilihanKabupaten;
    var kecamatan = pilihanKecamatan;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","penerima":"$nama","hp":"$hp","saveAs":"$saveAs","alamat":"$alamat","provinsi":"$provinsi","kabupaten":"$kabupaten","kecamatan":"$kecamatan"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLmp}/mobileAppsUser/saveAlamatBaru');

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
        listAlamatData = hasil['alamatTersimpan'];
        controllerSave.text = '';
        controllerAlamat.text = '';
        controllerhp.text = '';
        pilihanProvinsi = '';
        pilihanKabupaten = '';
        pilihanKecamatan = '';

        setState(() {
          dataAlamatTersedia = true;
          dataKec = false;
          datakab = false;
        });
      }
    }
  }

  void cekAlamatTersedia() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLmp}/mobileAppsUser/cekAlamatTersedia');

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
        listAlamatData = hasil['alamatTersimpan'];
        setState(() {
          dataAlamatTersedia = true;
        });
      }
    }
  }

  List<Container> listAlamat = [];
  List listAlamatData = [];

  tampilkanAlamat() {
    listAlamat = [];
    for (var a = 0; a < listAlamatData.length; a++) {
      var result = listAlamatData[a];
      listAlamat.add(Container(
        child: GestureDetector(
          onTap: () {
            c.alamatKirimNasional.value = result[1];
            c.alamatKirimNasionalKab.value = result[4];
            c.alamatKirimNasionalKec.value = result[3];
            c.alamatKirimNasionalSaveAs.value = result[0];
            c.alamatKirimNasionalIDKec.value = result[6].toString();

            Get.off(LokasidanKeranjangMP());
          },
          child: Card(
            child: Container(
              padding: EdgeInsets.all(5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: Get.width * 0.5,
                            child: Text(
                              result[7],
                              overflow: TextOverflow.clip,
                              maxLines: 3,
                              style: TextStyle(
                                  color: Warna.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 5),
                          ),
                          RawMaterialButton(
                            constraints:
                                BoxConstraints(minWidth: Get.width * 0.2),
                            elevation: 1.0,
                            fillColor: Colors.green,
                            child: Text(
                              result[0],
                              overflow: TextOverflow.clip,
                              style:
                                  TextStyle(color: Warna.putih, fontSize: 11),
                            ),
                            padding: EdgeInsets.fromLTRB(5, 2, 5, 2),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7)),
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      SizedBox(
                        width: Get.width * 0.7,
                        child: Text(
                          result[1],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          style: TextStyle(
                            color: Warna.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: Get.width * 0.65,
                        child: Text(
                          '${result[3]} - ${result[4]} / Hp. ${result[2]}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          style: TextStyle(
                            color: Warna.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ));
    }
    return Column(children: listAlamat);
  }
}
