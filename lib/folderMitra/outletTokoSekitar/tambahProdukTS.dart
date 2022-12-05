import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as https;
import 'package:crypto/crypto.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import '/camera/galeriProdukTs.dart';
import 'listProdukToko.dart';

class TambahProdukTS extends StatefulWidget {
  @override
  _TambahProdukTSState createState() => _TambahProdukTSState();
}

class _TambahProdukTSState extends State<TambahProdukTS> {
  final c = Get.find<ApiService>();
  final ctrNamaProduk = TextEditingController();
  final ctrDesProduk = TextEditingController();
  final ctrBeratProduk = TextEditingController();
  final ctrHargaProduk = TextEditingController();
  final ctrlBarcode = TextEditingController();
  final ctrlBuatKategoriBaru = TextEditingController();
  final ctrlHargaModal = TextEditingController();

  List<String> listKategori = [];
  List<String> listSubKategori = [];
  List<String> listJenisKategori = [];

  var dataKategori = true;
  var dataSubKategori = false;
  var dataJenisKategori = false;

  var pilihanKategori = 'Pilih Kategori';
  var pilihanSubKategori = 'Pilih Sub Kategori';
  var pilihanJenisKategori = 'Pilih Spesifik Produk';

  var pilihanStok = 'Kondisi Stok ?';
  var kondisiProduk = 'Kondisi Produk ?';

  var exSendiri = true;
  var exSasuka = true;
  var exJne = false;
  var exJnt = false;
  var exSicepat = false;
  var exJet = false;
  var exPos = false;

  @override
  void initState() {
    super.initState();
    c.picProduk1.value = 'noimage.jpg';
    c.picProduk2.value = 'noimage.jpg';
    c.picProduk3.value = 'noimage.jpg';
    c.picProduk4.value = 'noimage.jpg';
    c.picProduk5.value = 'noimage.jpg';
    c.picProduk6.value = 'noimage.jpg';
    kategoriCek();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Tambah Produk Baru'),
          backgroundColor: Colors.green,
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(11),
          child: RawMaterialButton(
            onPressed: () {
              periksaKelengkapan();
            },
            constraints: BoxConstraints(),
            elevation: 1.0,
            fillColor: Colors.green,
            child: Text(
              'Tambah Produk Sekarang !',
              style: TextStyle(color: Warna.putih, fontSize: 16),
            ),
            padding: EdgeInsets.fromLTRB(22, 11, 22, 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(9)),
            ),
          ),
        ),
        body: ListView(
          children: [
            Container(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Text(
                'Produk/Item',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w300,
                    color: Warna.warnautama),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Card(
                child: Container(
                  margin: EdgeInsets.all(22),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (ss) {},
                        maxLength: 50,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Warna.grey),
                        controller: ctrNamaProduk,
                        decoration: InputDecoration(
                            labelText: 'Nama Produk',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10))),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: Get.width * 0.62,
                            child: TextField(
                              onChanged: (ss) {},
                              maxLength: 50,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Warna.grey),
                              controller: ctrlBarcode,
                              decoration: InputDecoration(
                                  labelText: 'Barcode Produk',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                          Center(
                            child: IconButton(
                              icon: Icon(Icons.qr_code_2_outlined,
                                  size: 33, color: Warna.grey),
                              onPressed: () {
                                scanQR();
                              },
                            ),
                          ),
                        ],
                      ),
                      TextField(
                        onChanged: (ss) {},
                        maxLength: 1000,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Warna.grey),
                        controller: ctrDesProduk,
                        decoration: InputDecoration(
                            labelText: 'Deskripsi Produk',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10))),
                      ),
                      TextField(
                        onChanged: (ss) {},
                        maxLength: 7,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Warna.grey),
                        controller: ctrBeratProduk,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Berat Produk (Gram)',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10))),
                      ),
                      TextField(
                        onChanged: (ss) {},
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Warna.grey),
                        controller: ctrHargaProduk,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Harga Jual (Rp.)',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10))),
                      ),
                      Padding(padding: EdgeInsets.only(top: 17)),
                      TextField(
                        onChanged: (ss) {},
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Warna.grey),
                        controller: ctrlHargaModal,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Harga Modal (HPP)',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10))),
                      ),
                      Padding(padding: EdgeInsets.only(top: 33)),
                      DropdownSearch<String>(
                          popupProps: PopupProps.menu(
                            showSelectedItems: true,
                            disabledItemFn: (String s) => s.startsWith('I'),
                          ),
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: "Stok Produk",
                            ),
                          ),
                          items: ['Ready Stock', 'Pre Order / Indent'],
                          onChanged: (propValue) {
                            setState(() {});
                            pilihanStok = propValue;
                          },
                          selectedItem: pilihanStok),
                      Padding(padding: EdgeInsets.only(top: 22)),
                      DropdownSearch<String>(
                          popupProps: PopupProps.menu(
                            showSelectedItems: true,
                            disabledItemFn: (String s) => s.startsWith('I'),
                          ),
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: "Kondisi Produk",
                            ),
                          ),
                          items: ['Baru', 'Bekas', 'Daur ulang'],
                          onChanged: (propValue) {
                            setState(() {});
                            kondisiProduk = propValue;
                          },
                          selectedItem: kondisiProduk)
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kategori Produk',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w300,
                        color: Warna.warnautama),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Card(
                child: Container(
                  margin: EdgeInsets.all(22),
                  child: Column(
                    children: [
                      (dataKategori == true)
                          ? DropdownSearch<String>(
                              popupProps: PopupProps.menu(
                                showSelectedItems: true,
                                disabledItemFn: (String s) => s.startsWith('I'),
                              ),
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: "Kategori",
                                ),
                              ),
                              items: listKategori,
                              onChanged: (propValue) {
                                setState(() {
                                  pilihanKategori = propValue;
                                });
                              },
                              selectedItem: pilihanKategori)
                          : Padding(padding: EdgeInsets.only(top: 11)),
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                alertTambahKategori();
                              },
                              icon: Icon(Icons.add),
                              color: Warna.warnautama),
                          GestureDetector(
                            onTap: () {
                              alertTambahKategori();
                            },
                            child: Text(
                              'Tambah Kategori',
                              style: (TextStyle(color: Warna.warnautama)),
                            ),
                          )
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top: 11)),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Text(
                'Pengiriman',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w300,
                    color: Warna.warnautama),
              ),
            ),
            Container(
              margin: EdgeInsets.all(16),
              child: Card(
                child: Container(
                  padding: EdgeInsets.all(22),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: exSasuka,
                            onChanged: (newValue) {
                              setState(() {
                                exSasuka = newValue;
                              });
                            },
                          ),
                          Padding(padding: EdgeInsets.only(left: 11)),
                          Text('Pengiriman Lokal (SatuAja)'),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: exSendiri,
                            onChanged: (newValue) {
                              setState(() {
                                exSendiri = newValue;
                              });
                            },
                          ),
                          Padding(padding: EdgeInsets.only(left: 11)),
                          Text('Sendiri (Kurir Integrasi)'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Text(
                'Foto Produk / Barang',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w300,
                    color: Warna.warnautama),
              ),
            ),
            Container(
              margin: EdgeInsets.all(16),
              child: Card(
                child: Container(
                  padding: EdgeInsets.all(22),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              c.uploadTo.value = 'pic1';
                              Get.to(() => GaleriProdukTS());
                            },
                            child: SizedBox(
                              width: Get.width * 0.7,
                              child: Obx(() => CachedNetworkImage(
                                  fit: BoxFit.fill,
                                  imageUrl:
                                      'https://images.tokosekitar.com/400/' +
                                          c.picProduk1.value,
                                  errorWidget: (context, url, error) {
                                    print(error);
                                    return Icon(Icons.filter);
                                  })),
                            ),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top: 11)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  List dataKategoriKita = [];
  kategoriCek() async {
    bool conn = await cekInternet();
    if (!conn) {
      return;
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var jenis = 'Toko Sekitar';
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","jenis":"$jenis"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLtokosekitar}/mobileAppsOutlet/kategoriProdukTS');

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
        listKategori = List<String>.from(hasil['data']);
        setState(() {
          dataKategori = true;
        });
      }
    }
  }

  void periksaKelengkapan() {
    try {
      if (ctrNamaProduk.text == '') {
        errorParameter('Oppss... Sepertinya kamu belum mengisi Nama Produk');
      } else if (ctrDesProduk.text == '') {
        errorParameter(
            'Deskripsi produk diperlukan untuk menjelaskan kepada pelanggan produk apa yang kamu tawarkan');
      } else if (ctrBeratProduk.text == '') {
        errorParameter(
            'Berat Produk diperlukan untuk menghitung ongkos kirim dengan lebih tepat, jangan lupa diisi ya');
      } else if (pilihanStok == 'Kondisi Stok ?') {
        errorParameter(
            'Oppss... Sepertinya kamu belum memilih kondisi stok produk');
      } else if (kondisiProduk == 'Kondisi Produk ?') {
        errorParameter('Oppss... Sepertinya kamu belum memilih kondisi produk');
      } else if (pilihanKategori == 'Pilih Kategori') {
        errorParameter(
            'Pilih kategori produk yang kamu tawarkan agar pelanggan mudah menemukan produk kamu');
      } else if ((exSendiri == false) &&
          (exSasuka == false) &&
          (exJne == false) &&
          (exJnt == false) &&
          (exSicepat == false) &&
          (exJet == false) &&
          (exPos == false)) {
        errorParameter(
            'Oppss... Sepertinya kamu belum memilih metode pengiriman yang tersedia');
      } else if (c.picProduk1.value == 'noimage.jpg') {
        errorParameter(
            'Foto produk Utama belum dipilih, silahkan pilih Foto utama yang akan ditampilkan');
      } else if (int.parse(ctrHargaProduk.text) <
          int.parse(ctrlHargaModal.text)) {
        errorParameter(
            'Harga Modal lebih besar dari Harga jual, Atur kembali pengaturan harga');
      } else {
        prosesTambahProdukBaru();
      }
    } catch (e) {
      errorParameter('Opps... Sepertinya ada formulir yang salah diisi');
    }
  }

  void errorParameter(String s) {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: 'PERHATIAN !',
      desc: s,
      btnCancelText: 'OK',
      btnCancelColor: Colors.amber,
      btnCancelOnPress: () {},
    )..show();
  }

  void prosesTambahProdukBaru() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');

    //PARAMETER TAMBAH PRODUK
    var namaProduk = ctrNamaProduk.text;
    var des = ctrDesProduk.text;
    var bcode = ctrlBarcode.text;
    var hppModal = ctrlHargaModal.text;

    var kate = pilihanKategori;
    var spesifik = pilihanJenisKategori;

    var berat = (int.parse(ctrBeratProduk.text) / 1000);

    var harga = ctrHargaProduk.text;
    var stok = pilihanStok;
    var kon = kondisiProduk;

    var ssik = exSasuka;
    var intg = exSendiri;
    var jne = exJne;
    var jnt = exJnt;
    var sicepat = exSicepat;
    var jet = exJet;
    var pos = exPos;

    var pic1 = c.picProduk1.value;
    var pic2 = c.picProduk2.value;
    var pic3 = c.picProduk3.value;
    var pic4 = c.picProduk4.value;
    var pic5 = c.picProduk5.value;
    var pic6 = c.picProduk6.value;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","hppModal":"$hppModal","bcode":"$bcode","pic6":"$pic6","pic5":"$pic5","pic4":"$pic4","pic3":"$pic3","pic2":"$pic2","pic1":"$pic1","pos":"$pos","jet":"$jet","sicepat":"$sicepat","jnt":"$jnt","jne":"$jne","intg":"$intg","ssik":"$ssik","namaProduk":"$namaProduk","des":"$des","kategori":"$kate","sub":"$kate","spesifik":"$spesifik","berat":"$berat","harga":"$harga","stok":"$stok","kondisi":"$kon"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLtokosekitar}/mobileAppsOutlet/buatItemBaruTS');

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
        c.selectedIndexTSKU.value = 0;
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'PRODUK BARU',
          desc: 'Produk baru kamu berhasil ditambahkan ke daftar produk',
          btnOkText: 'OK',
          btnOkOnPress: () {
            Get.back();
            Get.to(() => ListProdukToko());
          },
        )..show();
      }
    }
  }

  void alertTambahKategori() {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: 'TAMBAH KATEGORI',
      body: Container(
        child: Column(
          children: [
            Text('TAMBAH KATEGORI',
                style: TextStyle(
                  fontSize: 22,
                  color: Warna.grey,
                  fontWeight: FontWeight.w200,
                )),
            TextField(
              onChanged: (ss) {},
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Warna.grey),
              controller: ctrlBuatKategoriBaru,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ],
        ),
      ),
      btnCancelText: 'TAMBAH',
      btnCancelColor: Colors.green,
      btnCancelOnPress: () {
        tambahKategoriBaru();
      },
    )..show();
  }

  void tambahKategoriBaru() async {
    bool conn = await cekInternet();
    if (!conn) {
      return;
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var kategori = ctrlBuatKategoriBaru.text;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","kategori":"$kategori"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLtokosekitar}/mobileAppsOutlet/buatKategoriBaru');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    // EasyLoading.dismiss();
    print(response.body);
    ctrlBuatKategoriBaru.text = '';
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        listKategori = List<String>.from(hasil['data']);
        setState(() {
          dataKategori = true;
        });
      }
    }
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      if (barcodeScanRes != '') {
        ctrlBarcode.text = barcodeScanRes;
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
  }
}
