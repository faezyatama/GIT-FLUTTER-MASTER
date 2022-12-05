//ROUTE SUDAH DIPERIKSA
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import 'package:http/http.dart' as https;
import '/camera/kameraDriver.dart';
import 'dashboardIntegrasi.dart';
import 'waitingRegister.dart';

class DaftarMenjadiDriver extends StatefulWidget {
  @override
  _DaftarMenjadiDriverState createState() => _DaftarMenjadiDriverState();
}

class _DaftarMenjadiDriverState extends State<DaftarMenjadiDriver> {
  final c = Get.find<ApiService>();
  TextStyle styleTextNormal = TextStyle(
    fontSize: 14,
    color: Warna.grey,
  );

  final ctrlKtp = TextEditingController();
  final ctrlAlamat = TextEditingController();
  final ctrlNopol = TextEditingController();
  final ctrlTipeSeri = TextEditingController();
  final ctrlPenumpang = TextEditingController();
  var checkboxpernyataan = false;

  var pilihanDriver = '';
  var pilihanKategori = '';
  List<String> listProvinsi = [];
  var dataprovinsi = false;
  var pilihanProvinsi = '';
  List<String> listKendaraan = [];

  List<String> listKabupaten = [];
  var datakab = false;
  var pilihanKabupaten = '';

  List<String> listKecamatan = [];
  var dataKec = false;
  var pilihanKecamatan = '';
  var pilihanMerek = '';
  var pilihanJenisKendaraan = '';
  var namaOutlet = 'Nama Outlet Kamu ?'.obs;
  var tagline = 'Ucapan selamat datang kepada penggunjung'.obs;
  var alamat = 'Alamat Outlet ?'.obs;
  var provinsi = 'Provinsi'.obs;
  var kabupaten = 'Kabupaten'.obs;
  var kecamatan = 'Kecamatan'.obs;
  Box dbbox = Hive.box<String>('sasukaDB');

  @override
  void initState() {
    super.initState();
    provinsiCek();
    merekKendaraan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daftar Driver"),
        backgroundColor: Warna.warnautama,
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.fromLTRB(22, 8, 22, 8),
        height: Get.height * 0.06,
        child: RawMaterialButton(
          onPressed: () {
            periksaKelengkapanBerkas();
          },
          constraints: BoxConstraints(),
          elevation: 1.0,
          fillColor: Warna.warnautama,
          child: Text(
            'Daftar Sekarang !',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          padding: EdgeInsets.fromLTRB(22, 6, 22, 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(33)),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(22),
        child: ListView(
          children: [
            Text(
              'Pendaftaran Akun Driver',
              style: TextStyle(
                  fontSize: 22,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w300),
            ),
            Padding(padding: EdgeInsets.only(top: 22)),
            Text(
              'Mendaftar menjadi driver di Aplikasi ${c.namaAplikasi} sangat mudah loh... Lengkapi Berkas kamu dan Akun Driver kamu akan segera aktif...',
              style: TextStyle(
                  fontSize: 16, color: Warna.grey, fontWeight: FontWeight.w300),
            ),
            Padding(padding: EdgeInsets.only(top: 22)),
            Text(
              dbbox.get('nama'),
              style: TextStyle(
                  fontSize: 23,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w300),
            ),
            Text(
              dbbox.get('kodess'),
              style: TextStyle(
                  fontSize: 14,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w300),
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            TextField(
              onChanged: (ss) {},
              maxLength: 50,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Warna.grey),
              controller: ctrlKtp,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: 'Nomor KTP',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            TextField(
              onChanged: (ss) {},
              maxLength: 50,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Warna.grey),
              controller: ctrlAlamat,
              decoration: InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
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
                        pilihanKecamatan = '';
                        dataKec = false;
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
            Padding(padding: EdgeInsets.only(top: 33)),
            DropdownSearch<String>(
                items: ["Kurir Integrasi Outlet", 'Umum'],
                popupProps: PopupProps.menu(
                  showSelectedItems: true,
                  disabledItemFn: (String s) => s.startsWith('I'),
                ),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Jenis Layanan",
                  ),
                ),
                onChanged: (propValue) {
                  setState(() {});
                  pilihanDriver = propValue;
                },
                selectedItem: pilihanKategori),
            Padding(padding: EdgeInsets.only(top: 22)),
            DropdownSearch<String>(
                items: ['Motor', 'Mobil', 'Pickup', 'Bentor'],
                popupProps: PopupProps.menu(
                  showSelectedItems: true,
                  disabledItemFn: (String s) => s.startsWith('I'),
                ),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Kendaraan",
                  ),
                ),
                onChanged: (propValue) {
                  setState(() {});
                  pilihanJenisKendaraan = propValue;
                  merekKendaraan();
                },
                selectedItem: pilihanKategori),
            Padding(padding: EdgeInsets.only(top: 22)),
            DropdownSearch<String>(
                items: listKendaraan,
                popupProps: PopupProps.menu(
                  showSelectedItems: true,
                  disabledItemFn: (String s) => s.startsWith('I'),
                ),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Merek",
                  ),
                ),
                onChanged: (propValue) {
                  setState(() {});
                  pilihanMerek = propValue;
                },
                selectedItem: pilihanKategori),
            Padding(padding: EdgeInsets.only(top: 22)),
            TextField(
              onChanged: (ss) {},
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Warna.grey),
              controller: ctrlTipeSeri,
              decoration: InputDecoration(
                  labelText: 'Tipe/Seri/Kendaraan',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            Padding(padding: EdgeInsets.only(top: 22)),
            TextField(
              onChanged: (ss) {},
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Warna.grey),
              controller: ctrlPenumpang,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: 'Jumlah Penumpang',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            Padding(padding: EdgeInsets.only(top: 22)),
            TextField(
              onChanged: (ss) {},
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Warna.grey),
              controller: ctrlNopol,
              decoration: InputDecoration(
                  labelText: 'Nomor Polisi / Plat Nomor',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            Padding(padding: EdgeInsets.only(top: 27)),
            Text(
              'Lampiran Gambar :',
              style: TextStyle(
                  fontSize: 23,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w300),
            ),
            Text(
              '1. Foto Profil Driver / Kurir',
              style: TextStyle(fontSize: 14, color: Warna.grey),
            ),
            GestureDetector(
              onTap: () {
                c.uploadTo.value = 'profil';
                Get.to(() => CameraDriver());
              },
              child: Obx(() => Container(
                  width: 222.0,
                  height: 222.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(
                            '${c.baseURLdriver}/storage/profile/' +
                                c.fotoProfilDriver.value,
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
                Get.to(() => CameraDriver());
              },
              child: SizedBox(
                width: Get.width * 0.35,
                child: Obx(() => CachedNetworkImage(
                    fit: BoxFit.fill,
                    imageUrl: '${c.baseURLdriver}/storage/berkas/' +
                        c.fotoKtpDriver.value,
                    errorWidget: (context, url, error) {
                      print(error);
                      return Icon(Icons.error);
                    })),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 22)),
            Text(
              '3. Foto Surat Ijin Mengemudi (SIM)',
              style: TextStyle(fontSize: 14, color: Warna.grey),
            ),
            GestureDetector(
              onTap: () {
                c.uploadTo.value = 'sim';
                Get.to(() => CameraDriver());
              },
              child: SizedBox(
                width: Get.width * 0.35,
                child: Obx(() => CachedNetworkImage(
                    fit: BoxFit.fill,
                    imageUrl: '${c.baseURLdriver}/storage/berkas/' +
                        c.fotoSimDriver.value,
                    errorWidget: (context, url, error) {
                      print(error);
                      return Icon(Icons.error);
                    })),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 22)),
            Text(
              '4. Foto Surat Tanda Nomor Kendaraan (STNK)',
              style: TextStyle(fontSize: 14, color: Warna.grey),
            ),
            GestureDetector(
              onTap: () {
                c.uploadTo.value = 'stnk';
                Get.to(() => CameraDriver());
              },
              child: SizedBox(
                width: Get.width * 0.35,
                child: Obx(() => CachedNetworkImage(
                    fit: BoxFit.fill,
                    imageUrl: '${c.baseURLdriver}/storage/berkas/' +
                        c.fotoStnkDriver.value,
                    errorWidget: (context, url, error) {
                      print(error);
                      return Icon(Icons.error);
                    })),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 22)),
            Row(
              children: [
                Checkbox(
                  value: checkboxpernyataan,
                  onChanged: (newValue) {
                    setState(() {
                      checkboxpernyataan = newValue;
                    });
                  },
                ),
                SizedBox(
                  width: Get.width * 0.7,
                  child: Text(
                    'Saya menyatakan bahwa data yang saya berikan adalah data sesungguhnya',
                    style: TextStyle(fontSize: 14, color: Warna.grey),
                    maxLines: 3,
                  ),
                )
              ],
            ),
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

    var url = Uri.parse('${c.baseURLdriver}/mobileAppsMitraDriver/provinsi');

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

  void merekKendaraan() async {
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

    var url =
        Uri.parse('${c.baseURLdriver}/mobileAppsMitraDriver/merekKendaraan');

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
        setState(() {
          if (pilihanJenisKendaraan == 'Mobil') {
            listKendaraan = List<String>.from(hasil['kendaraan']);
          } else if (pilihanJenisKendaraan == 'Motor') {
            listKendaraan = List<String>.from(hasil['motor']);
          } else if (pilihanJenisKendaraan == 'Pickup') {
            listKendaraan = List<String>.from(hasil['kendaraan']);
          } else if (pilihanJenisKendaraan == 'Bentor') {
            listKendaraan = List<String>.from(hasil['bentor']);
          } else {
            listKendaraan = List<String>.from(hasil['motor']);
          }
        });
      }
    }
  }

  void periksaKelengkapanBerkas() {
    if (ctrlKtp.text == '') {
      Get.snackbar(
          'Error...!', 'Opps... Sepertinya kamu belum mengisi nomor KTP',
          snackPosition: SnackPosition.BOTTOM);
    } else if (ctrlAlamat.text == '') {
      Get.snackbar('Error...!', 'Opps... Sepertinya kamu belum mengisi Alamat',
          snackPosition: SnackPosition.BOTTOM);
    } else if (pilihanProvinsi == '') {
      Get.snackbar(
          'Error...!', 'Opps... Sepertinya kamu belum Memilih Provinsi',
          snackPosition: SnackPosition.BOTTOM);
    } else if (pilihanKabupaten == '') {
      Get.snackbar(
          'Error...!', 'Opps... Sepertinya kamu belum Memilih Kabupaten/Kota',
          snackPosition: SnackPosition.BOTTOM);
    } else if (pilihanKecamatan == '') {
      Get.snackbar(
          'Error...!', 'Opps... Sepertinya kamu belum Memilih Kecamatan',
          snackPosition: SnackPosition.BOTTOM);
    } else if (pilihanDriver == '') {
      Get.snackbar(
          'Error...!', 'Opps... Sepertinya kamu belum Memilih Jenis Driver',
          snackPosition: SnackPosition.BOTTOM);
    } else if (pilihanJenisKendaraan == '') {
      Get.snackbar(
          'Error...!', 'Opps... Sepertinya kamu belum Memilih Jenis Kendaraan',
          snackPosition: SnackPosition.BOTTOM);
    } else if (pilihanMerek == '') {
      Get.snackbar(
          'Error...!', 'Opps... Sepertinya kamu belum Memilih Merek Kendaraan',
          snackPosition: SnackPosition.BOTTOM);
    } else if (ctrlTipeSeri.text == '') {
      Get.snackbar('Error...!',
          'Opps... Sepertinya kamu belum menentukan jumlah penumpang',
          snackPosition: SnackPosition.BOTTOM);
    } else if (ctrlPenumpang.text == '') {
      Get.snackbar('Error...!',
          'Opps... Sepertinya kamu belum Memilih Tipe/Seri Kendaraan',
          snackPosition: SnackPosition.BOTTOM);
    } else if (ctrlNopol.text == '') {
      Get.snackbar('Error...!',
          'Opps... Sepertinya kamu belum memasukan Plat Nomor Kendaraan',
          snackPosition: SnackPosition.BOTTOM);
    } else if (c.fotoProfilDriver.value == 'noimage.png') {
      Get.snackbar(
          'Error...!', 'Opps... Sepertinya kamu belum memasukan Foto Profil',
          snackPosition: SnackPosition.BOTTOM);
    } else if (c.fotoKtpDriver.value == 'noimage.png') {
      Get.snackbar(
          'Error...!', 'Opps... Sepertinya kamu belum memasukan Foto KTP',
          snackPosition: SnackPosition.BOTTOM);
    } else if (c.fotoSimDriver.value == 'noimage.png') {
      Get.snackbar(
          'Error...!', 'Opps... Sepertinya kamu belum memasukan Foto SIM',
          snackPosition: SnackPosition.BOTTOM);
    } else if (c.fotoStnkDriver.value == 'noimage.png') {
      Get.snackbar(
          'Error...!', 'Opps... Sepertinya kamu belum memasukan Foto STNK',
          snackPosition: SnackPosition.BOTTOM);
    } else if (checkboxpernyataan == false) {
      Get.snackbar('Error...!',
          'Opps... klik / centang pernyataan bahwa data yang diberikan adalah valid',
          snackPosition: SnackPosition.BOTTOM);
    } else {
      prosesPendaftaranDriver();
    }
  }

  void prosesPendaftaranDriver() async {
    EasyLoading.show(status: 'Mohon tunggu...', dismissOnTap: false);

    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');

    //parameter yang dibuthkan
    var ktp = ctrlKtp.text;
    var alamat = ctrlAlamat.text;
    var provinsi = pilihanProvinsi;
    var kabupaten = pilihanKabupaten;
    var kecamatan = pilihanKecamatan;
    var pilDriver = pilihanDriver;
    var jenisKendaraan = pilihanJenisKendaraan;
    var pilihanmerek = pilihanMerek;
    var tipeSeri = ctrlTipeSeri.text;
    var penumpang = ctrlPenumpang.text;

    var nopol = ctrlNopol.text;
    var fileprofil = c.fotoProfilDriver.value;
    var filektp = c.fotoKtpDriver.value;
    var filesim = c.fotoSimDriver.value;
    var filestnk = c.fotoStnkDriver.value;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","penumpang":"$penumpang","ktp":"$ktp","alamat":"$alamat","provinsi":"$provinsi","kabupaten":"$kabupaten","kecamatan":"$kecamatan","pilDriver":"$pilDriver","jenisKendaraan":"$jenisKendaraan","pilihanmerek":"$pilihanmerek","tipeSeri":"$tipeSeri","nopol":"$nopol","fileprofil":"$fileprofil","filektp":"$filektp","filesim":"$filesim","filestnk":"$filestnk"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLdriver}/mobileAppsMitraDriver/registerDriver');

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
      if (hasil['status'] == 'sukses integrasi') {
        Get.off(DashboardIntegrasi());
      } else if (hasil['status'] == 'waiting') {
        Get.off(WaitingRegister());
      } else {
        Get.back();
      }
    }
  }
}
