import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as https;
import 'package:signature/signature.dart';
import '../base/api_service.dart';
import '../base/conn.dart';
import '../base/warna.dart';
import '../camera/kameraSimpanan.dart';
import 'sedangDalamProses.dart';

class FormBukaSimpanan extends StatefulWidget {
  @override
  State<FormBukaSimpanan> createState() => _FormBukaSimpananState();
}

class _FormBukaSimpananState extends State<FormBukaSimpanan> {
  final c = Get.find<ApiService>();
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 1,
    penColor: Colors.red,
    exportBackgroundColor: Colors.blue,
    exportPenColor: Colors.black,
    onDrawStart: () => print('onDrawStart called!'),
    onDrawEnd: () => print('onDrawEnd called!'),
  );

  var pernyataan = false.obs;
  var checkboxdomisilisama = true;

  final ctrlKtp = TextEditingController();
  final ctrlNamaLengkap = TextEditingController();
  final ctrlTempatLahir = TextEditingController();
  final ctrlTglLahir = TextEditingController();
  final ctrlHp = TextEditingController();
  final ctrlNpwp = TextEditingController();
  final ctrlNamaIbu = TextEditingController();
  final ctrlAlamatKtp = TextEditingController();
  final ctrlAlamatDomisili = TextEditingController();
  final ctrlAlamatInstansi = TextEditingController();
  final ctrlPekerjaan = TextEditingController();
  final ctrlJabatan = TextEditingController();
  final ctrlInstansi = TextEditingController();

  List<String> listProvinsi = [];
  var dataprovinsi = false;
  var pilihanProvinsi = '';

  List<String> listKabupaten = [];
  var datakab = false;
  var pilihanKabupaten = '';

  List<String> listKecamatan = [];
  var dataKec = false;
  var pilihanKecamatan = '';
  var alamat = 'Alamat Outlet ?'.obs;
  var provinsi = 'Provinsi'.obs;
  var kabupaten = 'Kabupaten'.obs;
  var kecamatan = 'Kecamatan'.obs;

  //---------ALAMAT 2
  List<String> listProvinsi2 = [];
  var dataprovinsi2 = false;
  var pilihanProvinsi2 = '';

  List<String> listKabupaten2 = [];
  var datakab2 = false;
  var pilihanKabupaten2 = '';

  List<String> listKecamatan2 = [];
  var dataKec2 = false;
  var pilihanKecamatan2 = '';
  var alamat2 = 'Alamat Outlet ?'.obs;
  var provinsi2 = 'Provinsi'.obs;
  var kabupaten2 = 'Kabupaten'.obs;
  var kecamatan2 = 'Kecamatan'.obs;
  //----------END ALAMAT 2

  var headerFormBukaRek = ''.obs;
  Box dbbox = Hive.box<String>('sasukaDB');

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => print('Value changed'));

    headerGambar();
    provinsiCek();
    provinsiCek2();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.warnautama,
        title: Text("Formulir Buka Simpanan"),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(5),
        height: Get.height * 0.08,
        child: RawMaterialButton(
          onPressed: () {
            validasiRequest();
          },
          constraints: BoxConstraints(),
          elevation: 1.0,
          fillColor: Warna.warnautama,
          child: Text(
            'Ajukan Permohonan Buka Simpanan',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w300, color: Warna.putih),
          ),
          padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(33)),
          ),
        ),
      ),
      body: ListView(children: [
        Container(
          padding: EdgeInsets.all(12),
          child: Center(
            child: Column(
              children: [
                Text(
                  c.simpananPilihan,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w200,
                      color: Warna.warnautama),
                ),
                Text(
                  'Lengkapi data berikut ini untuk permohonan buka rekening ' +
                      c.simpananPilihan,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      color: Warna.grey,
                      fontWeight: FontWeight.w300),
                ),
                Padding(padding: EdgeInsets.only(top: 22)),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  RawMaterialButton(
                    onPressed: () {},
                    constraints: BoxConstraints(),
                    elevation: 1.0,
                    fillColor: Colors.amber,
                    child: Text(
                      'Data Pribadi',
                      style: TextStyle(fontSize: 11, color: Colors.white),
                    ),
                    padding: EdgeInsets.fromLTRB(22, 3, 22, 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(33)),
                    ),
                  ),
                ]),
                //-----------------------------------------------
                TextField(
                  onChanged: (ss) {},
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Warna.grey),
                  controller: ctrlKtp,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.card_membership),
                      labelText: 'Nomor KTP/SIM',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),

                //-------------------------------------------------
                Padding(padding: EdgeInsets.only(top: 5)),
                TextField(
                  onChanged: (ss) {},
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Warna.grey),
                  controller: ctrlNamaLengkap,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                Padding(padding: EdgeInsets.only(top: 5)),

                //--------------------------------------------
                TextField(
                  onChanged: (ss) {},
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Warna.grey),
                  controller: ctrlTempatLahir,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.map_sharp),
                      labelText: 'Tempat Lahir',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),

                Padding(padding: EdgeInsets.only(top: 5)),
                GestureDetector(
                  onTap: () {
                    DatePicker.showDatePicker(context,
                        showTitleActions: true,
                        minTime: DateTime(1910, 3, 5),
                        maxTime: DateTime(2050, 6, 7), onChanged: (date) {
                      print('change $date');
                    }, onConfirm: (date) {
                      ctrlTglLahir.text = date.day.toString() +
                          '-' +
                          date.month.toString() +
                          '-' +
                          date.year.toString();
                      setState(() {});
                    }, currentTime: DateTime.now(), locale: LocaleType.id);
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      onChanged: (ss) {},
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Warna.grey),
                      controller: ctrlTglLahir,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.calendar_month),
                          labelText: 'Tanggal Lahir',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                ),

                Padding(padding: EdgeInsets.only(top: 5)),

                TextField(
                  onChanged: (ss) {},
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Warna.grey),
                  controller: ctrlHp,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone),
                      labelText: 'No Telepon / HP',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                Padding(padding: EdgeInsets.only(top: 5)),
                TextField(
                  onChanged: (ss) {},
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Warna.grey),
                  controller: ctrlNpwp,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.card_travel),
                      labelText: 'NPWP',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                Padding(padding: EdgeInsets.only(top: 5)),

                TextField(
                  onChanged: (ss) {},
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Warna.grey),
                  controller: ctrlNamaIbu,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.woman_rounded),
                      labelText: 'Nama ibu kandung',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),

                //-----------------------------
                //---ALAMAT -------------------
                //-----------------------------
                Padding(padding: EdgeInsets.only(top: 15)),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  RawMaterialButton(
                    onPressed: () {},
                    constraints: BoxConstraints(),
                    elevation: 1.0,
                    fillColor: Colors.amber,
                    child: Text(
                      'Data Alamat',
                      style: TextStyle(fontSize: 11, color: Colors.white),
                    ),
                    padding: EdgeInsets.fromLTRB(22, 3, 22, 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(33)),
                    ),
                  ),
                ]),

                TextField(
                  onChanged: (ss) {},
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Warna.grey),
                  controller: ctrlAlamatKtp,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.location_city),
                      labelText: 'Alamat Sesuai KTP',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                Container(
                  padding: EdgeInsets.only(left: 45),
                  child: Column(
                    children: [
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
                                  pilihanKecamatan = '';
                                  dataKec = false;
                                });

                                pilihanProvinsi = propValue;
                                kabupatenCek(propValue);
                              },
                              selectedItem: pilihanProvinsi)
                          : Padding(padding: EdgeInsets.only(top: 4)),
                      Padding(padding: EdgeInsets.only(top: 4)),
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
                          : Padding(padding: EdgeInsets.only(top: 1)),
                      Padding(padding: EdgeInsets.only(top: 4)),
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
                          : Padding(padding: EdgeInsets.only(top: 1)),
                      Padding(padding: EdgeInsets.only(top: 5)),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      child: Text(
                        'Apakah alamat saat ini sesuai KTP ?',
                        style: TextStyle(fontSize: 14, color: Warna.grey),
                        maxLines: 3,
                      ),
                    ),
                    Checkbox(
                      value: checkboxdomisilisama,
                      onChanged: (newValue) {
                        setState(() {
                          checkboxdomisilisama = newValue;
                          alamatKtpdanDomisilisama();
                        });
                      },
                    ),
                  ],
                ),
                (checkboxdomisilisama != true)
                    ? Container(
                        child: Column(children: [
                          TextField(
                            onChanged: (ss) {},
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Warna.grey),
                            controller: ctrlAlamatDomisili,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.location_city),
                                labelText: 'Alamat Domisili',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10))),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 45),
                            child: Column(
                              children: [
                                (dataprovinsi2 == true)
                                    ? DropdownSearch<String>(
                                        items: listProvinsi2,
                                        popupProps: PopupProps.menu(
                                          showSelectedItems: true,
                                          disabledItemFn: (String s) =>
                                              s.startsWith('I'),
                                        ),
                                        dropdownDecoratorProps:
                                            DropDownDecoratorProps(
                                          dropdownSearchDecoration:
                                              InputDecoration(
                                            labelText: "Provinsi",
                                          ),
                                        ),
                                        onChanged: (propValue) {
                                          setState(() {
                                            pilihanKabupaten2 = '';
                                            pilihanKecamatan2 = '';
                                            dataKec2 = false;
                                          });

                                          pilihanProvinsi2 = propValue;
                                          kabupatenCek2(propValue);
                                        },
                                        selectedItem: pilihanProvinsi2)
                                    : Padding(padding: EdgeInsets.only(top: 4)),
                                Padding(padding: EdgeInsets.only(top: 4)),
                                (datakab2 == true)
                                    ? DropdownSearch<String>(
                                        items: listKabupaten2,
                                        popupProps: PopupProps.menu(
                                          showSelectedItems: true,
                                          disabledItemFn: (String s) =>
                                              s.startsWith('I'),
                                        ),
                                        dropdownDecoratorProps:
                                            DropDownDecoratorProps(
                                          dropdownSearchDecoration:
                                              InputDecoration(
                                            labelText: "Kabupaten",
                                          ),
                                        ),
                                        onChanged: (kabValue) {
                                          pilihanKabupaten2 = kabValue;
                                          pilihanKecamatan2 = '';
                                          kecamatanCek2(kabValue);
                                        },
                                        selectedItem: pilihanKabupaten2)
                                    : Padding(padding: EdgeInsets.only(top: 1)),
                                Padding(padding: EdgeInsets.only(top: 4)),
                                (dataKec2 == true)
                                    ? DropdownSearch<String>(
                                        items: listKecamatan2,
                                        popupProps: PopupProps.menu(
                                          showSelectedItems: true,
                                          disabledItemFn: (String s) =>
                                              s.startsWith('I'),
                                        ),
                                        dropdownDecoratorProps:
                                            DropDownDecoratorProps(
                                          dropdownSearchDecoration:
                                              InputDecoration(
                                            labelText: "Kecamatan",
                                          ),
                                        ),
                                        onChanged: (kecValue) {
                                          pilihanKecamatan2 = kecValue;
                                        },
                                        selectedItem: pilihanKecamatan2)
                                    : Padding(padding: EdgeInsets.only(top: 1)),
                                Padding(padding: EdgeInsets.only(top: 5)),
                              ],
                            ),
                          ),
                        ]),
                      )
                    : Container(),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  RawMaterialButton(
                    onPressed: () {},
                    constraints: BoxConstraints(),
                    elevation: 1.0,
                    fillColor: Colors.amber,
                    child: Text(
                      'Data Pekerjaan',
                      style: TextStyle(fontSize: 11, color: Colors.white),
                    ),
                    padding: EdgeInsets.fromLTRB(22, 3, 22, 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(33)),
                    ),
                  ),
                ]),
                Padding(padding: EdgeInsets.only(top: 5)),

                TextField(
                  onChanged: (ss) {},
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Warna.grey),
                  controller: ctrlPekerjaan,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.work),
                      labelText: 'Pekerjaan',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                Padding(padding: EdgeInsets.only(top: 5)),

                TextField(
                  onChanged: (ss) {},
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Warna.grey),
                  controller: ctrlJabatan,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.chair),
                      labelText: 'Jabatan / Sebagai',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                Padding(padding: EdgeInsets.only(top: 5)),

                TextField(
                  onChanged: (ss) {},
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Warna.grey),
                  controller: ctrlInstansi,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.maps_home_work),
                      labelText: 'Instansi / Perusahaan',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                Padding(padding: EdgeInsets.only(top: 5)),

                TextField(
                  onChanged: (ss) {},
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Warna.grey),
                  controller: ctrlAlamatInstansi,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.map),
                      labelText: 'Alamat Pekerjaan',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),

                Padding(padding: EdgeInsets.only(top: 15)),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  RawMaterialButton(
                    onPressed: () {},
                    constraints: BoxConstraints(),
                    elevation: 1.0,
                    fillColor: Colors.amber,
                    child: Text(
                      'Dokumen Pendukung',
                      style: TextStyle(fontSize: 11, color: Colors.white),
                    ),
                    padding: EdgeInsets.fromLTRB(22, 3, 22, 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(33)),
                    ),
                  ),
                ]),
                Text(
                  'Lampiran Gambar :',
                  style: TextStyle(
                      fontSize: 23,
                      color: Warna.warnautama,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '1. Pas Foto Anggota',
                  style: TextStyle(fontSize: 14, color: Warna.grey),
                ),
                GestureDetector(
                  onTap: () {
                    c.uploadTo.value = 'profil';
                    Get.to(() => CameraSimpanan());
                  },
                  child: Obx(() => Container(
                      width: Get.width * 0.4,
                      height: Get.width * 0.4,
                      decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage(
                                c.filePasFotoDisplay.value,
                              ))))),
                ),
                Padding(padding: EdgeInsets.only(top: 22)),
                Text(
                  '2. Foto Kartu Tanda Penduduk (KTP)',
                  style: TextStyle(fontSize: 14, color: Warna.grey),
                ),
                GestureDetector(
                  onTap: () {
                    c.uploadTo.value = 'ktp';
                    Get.to(() => CameraSimpanan());
                  },
                  child: SizedBox(
                    width: Get.width * 0.75,
                    child: Obx(() => CachedNetworkImage(
                        fit: BoxFit.fill,
                        imageUrl: c.fileKTPDisplay.value,
                        errorWidget: (context, url, error) {
                          print(error);
                          return Icon(Icons.error);
                        })),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 22)),
                Text(
                  '3. Foto Selfi bersama KTP',
                  style: TextStyle(fontSize: 14, color: Warna.grey),
                ),
                GestureDetector(
                  onTap: () {
                    c.uploadTo.value = 'selfi';
                    Get.to(() => CameraSimpanan());
                  },
                  child: SizedBox(
                    width: Get.width * 0.75,
                    child: Obx(() => CachedNetworkImage(
                        fit: BoxFit.fill,
                        imageUrl: c.fileSelfiKTPDisplay.value,
                        errorWidget: (context, url, error) {
                          print(error);
                          return Icon(Icons.error);
                        })),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 22)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Obx(() => Checkbox(
                          value: pernyataan.value,
                          onChanged: (newValue) {
                            setState(() {
                              pernyataan.value = newValue;
                              if (pernyataan.value == true) {
                                alertTampilkanTandaTangan();
                              }
                            });
                          },
                        )),
                    SizedBox(
                      width: Get.width * 0.65,
                      child: Text(
                        'Data yang diberikan adalah data sebenarnya untuk membuka rekening simpanan.',
                        style: TextStyle(fontSize: 14, color: Warna.grey),
                        maxLines: 4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
      ]),
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

    var url = Uri.parse('${c.baseURLdriver}/mobileAppsMitraDriver/provinsi');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    // EasyLoading.dismiss();
    // print(response.body);
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

  provinsiCek2() async {
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

    var url = Uri.parse('${c.baseURLdriver}/mobileAppsMitraDriver/provinsi');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    // EasyLoading.dismiss();
    // print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        listProvinsi2 = List<String>.from(hasil['provinsi']);
        setState(() {
          dataprovinsi2 = true;
        });
      }
    }
  }

  List dataProvinsiKita = [];
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

    var url = Uri.parse('${c.baseURLdriver}/mobileAppsMitraDriver/kabupaten');

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

    var url = Uri.parse('${c.baseURLdriver}/mobileAppsMitraDriver/kecamatan');

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

  void kabupatenCek2(String propValue) async {
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

    var url = Uri.parse('${c.baseURLdriver}/mobileAppsMitraDriver/kabupaten');

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
        listKabupaten2 = List<String>.from(hasil['kabupaten']);

        setState(() {
          datakab2 = true;
        });
      }
    }
  }

  void kecamatanCek2(String kab) async {
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

    var url = Uri.parse('${c.baseURLdriver}/mobileAppsMitraDriver/kecamatan');

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
        listKecamatan2 = List<String>.from(hasil['kecamatan']);
        setState(() {
          dataKec2 = true;
        });
      }
    }
  }

  headerGambar() async {
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
    var url = Uri.parse('${c.baseURL}/mobileApps/headerGambarUSP');

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
        headerFormBukaRek.value = hasil['gambar'];
      }
    }
  }

  validasiRequest() {
    if (checkboxdomisilisama == true) {
      ctrlAlamatDomisili.text = ctrlAlamatKtp.text;
      pilihanProvinsi2 = pilihanProvinsi;
      pilihanKabupaten2 = pilihanKabupaten;
      pilihanKecamatan2 = pilihanKecamatan;
    }
    if (ctrlKtp.text == '') {
      Get.snackbar(
          'Periksa Nomor KTP', 'lengkapi data dan coba kirimkan kembali');
    } else if (ctrlNamaLengkap.text == '') {
      Get.snackbar(
          'Periksa Nama Lengkap', 'lengkapi data dan coba kirimkan kembali',
          snackPosition: SnackPosition.BOTTOM);
    } else if (ctrlTempatLahir.text == '') {
      Get.snackbar(
          'Periksa Tempat Lahir', 'lengkapi data dan coba kirimkan kembali',
          snackPosition: SnackPosition.BOTTOM);
    } else if (ctrlTglLahir.text == '') {
      Get.snackbar(
          'Periksa Tanggal lahir', 'lengkapi data dan coba kirimkan kembali',
          snackPosition: SnackPosition.BOTTOM);
    } else if (ctrlHp.text == '') {
      Get.snackbar(
          'Periksa Nomor HP', 'lengkapi data dan coba kirimkan kembali',
          snackPosition: SnackPosition.BOTTOM);
    } else if (ctrlNpwp.text == '') {
      Get.snackbar(
          'Periksa nomor NPWP', 'lengkapi data dan coba kirimkan kembali',
          snackPosition: SnackPosition.BOTTOM);
    } else if (ctrlNamaIbu.text == '') {
      Get.snackbar(
          'Periksa Nama Ibu Kandung', 'lengkapi data dan coba kirimkan kembali',
          snackPosition: SnackPosition.BOTTOM);
    } else if (ctrlAlamatKtp.text == '') {
      Get.snackbar(
          'Periksa Alamat KTP', 'lengkapi data dan coba kirimkan kembali',
          snackPosition: SnackPosition.BOTTOM);
    } else if (ctrlAlamatDomisili.text == '') {
      Get.snackbar(
          'Periksa Alamt Domisili', 'lengkapi data dan coba kirimkan kembali',
          snackPosition: SnackPosition.BOTTOM);
    } else if (ctrlAlamatInstansi.text == '') {
      Get.snackbar(
          'Periksa Alamat Instansi', 'lengkapi data dan coba kirimkan kembali',
          snackPosition: SnackPosition.BOTTOM);
    } else if (ctrlPekerjaan.text == '') {
      Get.snackbar(
          'Periksa Pekerjaan', 'lengkapi data dan coba kirimkan kembali',
          snackPosition: SnackPosition.BOTTOM);
    } else if (ctrlJabatan.text == '') {
      Get.snackbar('Periksa Jabatan', 'lengkapi data dan coba kirimkan kembali',
          snackPosition: SnackPosition.BOTTOM);
    } else if (ctrlInstansi.text == '') {
      Get.snackbar(
          'Periksa Nama Instansi', 'lengkapi data dan coba kirimkan kembali',
          snackPosition: SnackPosition.BOTTOM);
    } else if (pilihanProvinsi == '') {
      Get.snackbar(
          'Periksa Provinsi', 'lengkapi data dan coba kirimkan kembali',
          snackPosition: SnackPosition.BOTTOM);
    } else if (pilihanKabupaten == '') {
      Get.snackbar(
          'Periksa Kabupaten', 'lengkapi data dan coba kirimkan kembali',
          snackPosition: SnackPosition.BOTTOM);
    } else if (pilihanKecamatan == '') {
      Get.snackbar(
          'Periksa Kecamatan', 'lengkapi data dan coba kirimkan kembali',
          snackPosition: SnackPosition.BOTTOM);
    } else if (pilihanProvinsi2 == '') {
      Get.snackbar(
          'Periksa Provinsi', 'lengkapi data dan coba kirimkan kembali',
          snackPosition: SnackPosition.BOTTOM);
    } else if (pilihanKabupaten2 == '') {
      Get.snackbar(
          'Periksa Kabupaten', 'lengkapi data dan coba kirimkan kembali',
          snackPosition: SnackPosition.BOTTOM);
    } else if (pilihanKecamatan2 == '') {
      Get.snackbar(
          'Periksa Kecamatan', 'lengkapi data dan coba kirimkan kembali',
          snackPosition: SnackPosition.BOTTOM);
    } else if (c.fileKTP.value == '') {
      Get.snackbar(
          'Periksa Foto KTP', 'lengkapi data dan coba kirimkan kembali',
          snackPosition: SnackPosition.BOTTOM);
    } else if (c.fileSelfiKTP.value == '') {
      Get.snackbar('Periksa Foto Selfi bersama KTP',
          'lengkapi data dan coba kirimkan kembali',
          snackPosition: SnackPosition.BOTTOM);
    } else if (c.filePasFoto.value == '') {
      Get.snackbar(
          'Periksa Pas Foto', 'lengkapi data dan coba kirimkan kembali',
          snackPosition: SnackPosition.BOTTOM);
    } else if (pernyataan.value == false) {
      Get.snackbar('Belum Centang Pernyataan',
          'Silahkan centang pernyataan dan tanda tangan',
          snackPosition: SnackPosition.BOTTOM);
    } else {
      kirimDataBukaRekening();
    }
  }

  alertTampilkanTandaTangan() {
    AwesomeDialog(
        context: Get.context,
        dismissOnBackKeyPress: false,
        dismissOnTouchOutside: false,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        body: Container(
            child: Column(
          children: [
            Text(
              'Tanda Tangan',
              style: TextStyle(fontSize: 18, color: Warna.warnautama),
            ),
            Text(
              'Silahkan tanda tangani form pengajuan ini',
              style: TextStyle(fontSize: 14, color: Warna.grey),
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            Column(
              children: <Widget>[
                //SIGNATURE CANVAS
                Signature(
                  controller: _controller,
                  height: 300,
                  backgroundColor: Color.fromARGB(255, 145, 206, 234),
                ),
                //OK AND CLEAR BUTTONS
                Container(
                  decoration: const BoxDecoration(color: Colors.black),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      //SHOW EXPORTED IMAGE IN NEW ROUTE

                      IconButton(
                        icon: const Icon(Icons.undo),
                        color: Colors.white,
                        onPressed: () {
                          setState(() => _controller.undo());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.redo),
                        color: Colors.white,
                        onPressed: () {
                          setState(() => _controller.redo());
                        },
                      ),
                      //CLEAR CANVAS
                      IconButton(
                        icon: const Icon(Icons.clear),
                        color: Colors.white,
                        onPressed: () {
                          setState(() => _controller.clear());
                        },
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        )),
        btnOkOnPress: () async {
          if (_controller.isEmpty) {
            c.imageTTD = '';
            pernyataan.value = false;
          } else {
            final imageData = await _controller.toPngBytes();
            c.imageTTD = base64.encode(imageData);
          }
        },
        btnOkText: 'OK')
      ..show();
  }

  alamatKtpdanDomisilisama() {
    if (checkboxdomisilisama == true) {
      ctrlAlamatDomisili.text = ctrlAlamatKtp.text;
      pilihanProvinsi2 = pilihanProvinsi;
      pilihanKabupaten2 = pilihanKabupaten;
      pilihanKecamatan2 = pilihanKecamatan;
    } else {
      ctrlAlamatDomisili.text = '';
      pilihanProvinsi2 = '';
      pilihanKabupaten2 = '';
      pilihanKecamatan2 = '';
    }
  }

  kirimDataBukaRekening() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","ttd":"${c.imageTTD}","idProduk":"${c.idsimpanan}","produk":"${c.simpananPilihan}","ctrlKtp":"${ctrlKtp.text}","ctrlNamaLengkap":"${ctrlNamaLengkap.text}","ctrlTempatLahir":"${ctrlTempatLahir.text}","ctrlTglLahir":"${ctrlTglLahir.text}","ctrlHp":"${ctrlHp.text}","ctrlNpwp":"${ctrlNpwp.text}","ctrlNamaIbu":"${ctrlNamaIbu.text}","ctrlAlamatKtp":"${ctrlAlamatKtp.text}","ctrlAlamatDomisili":"${ctrlAlamatDomisili.text}","ctrlAlamatInstansi":"${ctrlAlamatInstansi.text}","ctrlPekerjaan":"${ctrlPekerjaan.text}","ctrlJabatan":"${ctrlJabatan.text}","ctrlInstansi":"${ctrlInstansi.text}","pilihanProvinsi":"$pilihanProvinsi","pilihanKabupaten":"$pilihanKabupaten","pilihanKecamatan":"$pilihanKecamatan","pilihanProvinsi2":"$pilihanProvinsi2","pilihanKabupaten2":"$pilihanKabupaten2","pilihanKecamatan2":"$pilihanKecamatan2","fileKTP":"${c.fileKTP.value}","fileSelfiKTP":"${c.fileSelfiKTP.value}","filePasFoto":"${c.filePasFoto.value}"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();
    var url =
        Uri.parse('${c.baseURL}/mobileApps/permohonanBukaRekeningSimpanan');

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
        bersihkanFormulir();
        AwesomeDialog(
            context: Get.context,
            dismissOnBackKeyPress: false,
            dismissOnTouchOutside: false,
            dialogType: DialogType.noHeader,
            animType: AnimType.rightSlide,
            title: 'Permohonan Terkirim',
            desc:
                'Permohonan untuk membuka rekening telah terkirim dan akan segera diperiksa. Informasi akan dikirimkan melalui whatsapp ke nomor terdaftar',
            btnOkOnPress: () {
              Get.back();
              Get.back();
              Get.to(SedangDalamProses());
            },
            btnOkText: 'OK')
          ..show();
      } else {
        AwesomeDialog(
            context: Get.context,
            dismissOnBackKeyPress: false,
            dismissOnTouchOutside: false,
            dialogType: DialogType.noHeader,
            animType: AnimType.rightSlide,
            title: 'Error Ditemukan',
            desc: 'Permohonan untuk membuka rekening tidak dapat dikirimkan',
            btnOkOnPress: () {
              // Get.back();
            },
            btnOkText: 'OK')
          ..show();
      }
    }
  }

  bersihkanFormulir() {
    c.fileKTP.value = '';
    c.fileSelfiKTP.value = '';
    c.filePasFoto.value = '';
    c.fileKTPDisplay.value = 'https://images.sasuka.online/umum/ktp.png';
    c.fileSelfiKTPDisplay.value =
        'https://images.sasuka.online/umum/selfie.png';
    c.filePasFotoDisplay.value =
        'https://images.sasuka.online/umum/pasfoto.jpg';
  }
}
