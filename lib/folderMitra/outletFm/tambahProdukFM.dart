import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as https;
import 'package:crypto/crypto.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import '/camera/galeriProduk.dart';

import 'produkFM.dart';

class TambahProdukFM extends StatefulWidget {
  @override
  _TambahProdukFMState createState() => _TambahProdukFMState();
}

class _TambahProdukFMState extends State<TambahProdukFM> {
  final c = Get.find<ApiService>();
  final ctrNamaProduk = TextEditingController();
  final ctrDesProduk = TextEditingController();
  final ctrBeratProduk = TextEditingController();
  final ctrHargaProduk = TextEditingController();

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
                        maxLength: 150,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
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
                      TextField(
                        onChanged: (ss) {},
                        maxLength: 1000,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
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
                      Padding(padding: EdgeInsets.only(top: 22)),
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
                      Padding(padding: EdgeInsets.only(top: 22)),
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
                          items: ['Baru', 'Fresh', 'Beku'],
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
              child: Text(
                'Kategori Produk',
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
                      (dataKategori == true)
                          ? DropdownSearch<String>(
                              items: listKategori,
                              popupProps: PopupProps.menu(
                                showSelectedItems: true,
                                disabledItemFn: (String s) => s.startsWith('I'),
                              ),
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: "Kategori",
                                ),
                              ),
                              onChanged: (propValue) {
                                setState(() {
                                  pilihanKategori = propValue;
                                  subKategoriCek();
                                  pilihanJenisKategori =
                                      'Pilih Spesifik Produk';
                                  pilihanSubKategori = 'Pilih Sub Kategori';
                                  dataJenisKategori = false;
                                });
                              },
                              selectedItem: pilihanKategori)
                          : Padding(padding: EdgeInsets.only(top: 11)),
                      Padding(padding: EdgeInsets.only(top: 11)),
                      (dataSubKategori == true)
                          ? DropdownSearch<String>(
                              popupProps: PopupProps.menu(
                                showSelectedItems: true,
                                disabledItemFn: (String s) => s.startsWith('I'),
                              ),
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: "Sub Kategori",
                                ),
                              ),
                              items: listSubKategori,
                              onChanged: (propValue) {
                                setState(() {});
                                pilihanSubKategori = propValue;
                              },
                              selectedItem: pilihanSubKategori)
                          : Padding(padding: EdgeInsets.only(top: 11)),
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
                          Text('Pengiriman Lokal (Driver Lokal)'),
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
                'Foto Produk',
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              c.uploadTo.value = 'pic1';
                              Get.to(() => GaleriProduk());
                            },
                            child: SizedBox(
                              width: Get.width * 0.35,
                              child: Obx(() => CachedNetworkImage(
                                  fit: BoxFit.fill,
                                  imageUrl:
                                      'https://images.sasuka.online/200/' +
                                          c.picProduk1.value,
                                  errorWidget: (context, url, error) {
                                    print(error);
                                    return Icon(Icons.filter);
                                  })),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              c.uploadTo.value = 'pic2';
                              Get.to(() => GaleriProduk());
                            },
                            child: SizedBox(
                              width: Get.width * 0.35,
                              child: Obx(() => CachedNetworkImage(
                                  fit: BoxFit.fill,
                                  imageUrl:
                                      'https://images.sasuka.online/200/' +
                                          c.picProduk2.value,
                                  errorWidget: (context, url, error) {
                                    print(error);
                                    return Icon(Icons.error);
                                  })),
                            ),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top: 11)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              c.uploadTo.value = 'pic3';
                              Get.to(() => GaleriProduk());
                            },
                            child: SizedBox(
                              width: Get.width * 0.35,
                              child: Obx(() => CachedNetworkImage(
                                  fit: BoxFit.fill,
                                  imageUrl:
                                      'https://images.sasuka.online/200/' +
                                          c.picProduk3.value,
                                  errorWidget: (context, url, error) {
                                    print(error);
                                    return Icon(Icons.error);
                                  })),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              c.uploadTo.value = 'pic4';
                              Get.to(() => GaleriProduk());
                            },
                            child: SizedBox(
                              width: Get.width * 0.35,
                              child: Obx(() => CachedNetworkImage(
                                  fit: BoxFit.fill,
                                  imageUrl:
                                      'https://images.sasuka.online/200/' +
                                          c.picProduk4.value,
                                  errorWidget: (context, url, error) {
                                    print(error);
                                    return Icon(Icons.error);
                                  })),
                            ),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top: 11)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              c.uploadTo.value = 'pic5';
                              Get.to(() => GaleriProduk());
                            },
                            child: SizedBox(
                              width: Get.width * 0.35,
                              child: Obx(() => CachedNetworkImage(
                                  fit: BoxFit.fill,
                                  imageUrl:
                                      'https://images.sasuka.online/200/' +
                                          c.picProduk5.value,
                                  errorWidget: (context, url, error) {
                                    print(error);
                                    return Icon(Icons.error);
                                  })),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              c.uploadTo.value = 'pic6';
                              Get.to(() => GaleriProduk());
                            },
                            child: SizedBox(
                              width: Get.width * 0.35,
                              child: Obx(() => CachedNetworkImage(
                                  fit: BoxFit.fill,
                                  imageUrl:
                                      'https://images.sasuka.online/200/' +
                                          c.picProduk6.value,
                                  errorWidget: (context, url, error) {
                                    print(error);
                                    return Icon(Icons.error);
                                  })),
                            ),
                          ),
                        ],
                      ),
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
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var jenis = 'Sasuka Fresh Mart';
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","jenis":"$jenis"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLfreshmart}/mobileAppsOutlet/kategoriProdukFM');

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
    } else if (pilihanSubKategori == 'Pilih Sub Kategori') {
      errorParameter(
          'Pilih Sub kategori produk yang kamu tawarkan agar pelanggan mudah menemukan produk kamu');
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
    } else {
      prosesTambahProdukBaru();
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
    String namaProduk = base64.encode(utf8.encode(ctrNamaProduk.text));
    String des = base64.encode(utf8.encode(ctrDesProduk.text));
    var kate = pilihanKategori;
    var subkate = pilihanSubKategori;
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
        '{"pid":"$pid","pic6":"$pic6","pic5":"$pic5","pic4":"$pic4","pic3":"$pic3","pic2":"$pic2","pic1":"$pic1","pos":"$pos","jet":"$jet","sicepat":"$sicepat","jnt":"$jnt","jne":"$jne","intg":"$intg","ssik":"$ssik","namaProduk":"$namaProduk","des":"$des","kategori":"$kate","sub":"$subkate","spesifik":"$spesifik","berat":"$berat","harga":"$harga","stok":"$stok","kondisi":"$kon"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLfreshmart}/mobileAppsOutlet/buatItemBaruFMBase64');

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
        c.selectedIndexFMKU.value = 0;
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'PRODUK BARU',
          desc: 'Produk baru kamu berhasil ditambahkan ke daftar produk',
          btnOkText: 'OK',
          btnOkOnPress: () {
            Get.back();
            Get.to(() => ProdukFM());
          },
        )..show();
      }
    }
  }

  subKategoriCek() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var jenis = 'Sasuka Fresh Mart';
    var kategori = pilihanKategori;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","jenis":"$jenis","kategori":"$kategori"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLfreshmart}/mobileAppsOutlet/SubKategoriProdukFM');

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
        listSubKategori = List<String>.from(hasil['data']);
        setState(() {
          dataSubKategori = true;
        });
      }
    }
  }
}
