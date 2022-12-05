import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/warna.dart';

import 'PerformaAgensi.dart';
import 'dataAgen.dart';

class TambahAgen extends StatefulWidget {
  @override
  _TambahAgenState createState() => _TambahAgenState();
}

class _TambahAgenState extends State<TambahAgen> {
  final c = Get.find<ApiService>();
  var namaCalon = ''.obs;
  var ssCalon = ''.obs;
  var fotoCalon = ''.obs;
  var kodeTrx = ''.obs;
  var clAgen = 0.obs;

  var tampilkan = 'DataAgen'.obs;
  var listKategori = [
    'Agen Driver & Kurir',
    'Agen Outlet Mitra',
    'Agen Pulsa & PPOB',
    'Agen My School',
    'Agen Toko Sekitar'
  ];
  var listKategori2 = [
    'Agen Driver & Kurir',
    'Agen Outlet Mitra',
    'Agen Pulsa & PPOB',
    'Agen My School',
    'Agen Toko Sekitar'
  ];
  var listKategori3 = [
    'Agen Driver & Kurir',
    'Agen Outlet Mitra',
    'Agen Pulsa & PPOB',
    'Agen My School',
    'Agen Toko Sekitar'
  ];
  var listKategori4 = [
    'Agen Driver & Kurir',
    'Agen Outlet Mitra',
    'Agen Pulsa & PPOB',
    'Agen My School',
    'Agen Toko Sekitar'
  ];
  var listKategori5 = [
    'Agen Driver & Kurir',
    'Agen Outlet Mitra',
    'Agen Pulsa & PPOB',
    'Agen My School',
    'Agen Toko Sekitar'
  ];
  var pilihanKategori1 = '';
  var pilihanKategori2 = '';
  var pilihanKategori3 = '';
  var pilihanKategori4 = '';
  var pilihanKategori5 = '';

  var spe1 = true;
  var spe2 = false.obs;
  var spe3 = false.obs;
  var spe4 = false.obs;
  var spe5 = false.obs;

  final controllerSS = TextEditingController();
  final controllerVerifikasi = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Tambah Agensi Baru'), backgroundColor: Colors.amber),
      bottomNavigationBar: SizedBox(
        height: Get.height * 0.1,
        child: Container(
          padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(
              children: [
                Center(
                  child: Text(
                    c.jumlahAgen.value,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber),
                  ),
                ),
                Center(
                  child: Text(
                    'Agen',
                    style: TextStyle(fontSize: 11, color: Warna.grey),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Center(
                  child: Text(
                    c.akumulasiPendapatanAgensi.value,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber),
                  ),
                ),
                Center(
                  child: Text(
                    'Total Akumulasi Pendapatan Agensi',
                    style: TextStyle(fontSize: 11, color: Warna.grey),
                  ),
                ),
              ],
            )
          ]),
        ),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(22, 22, 22, 22),
        child: ListView(children: [
          Column(
            children: [
              Center(
                child: Text(
                  c.namaAgensi.value,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Warna.grey),
                ),
              ),
              Center(
                child: Text(
                  c.kodeAgensi.value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w200,
                      color: Warna.grey),
                ),
              ),
              Center(
                child: Text(
                  c.alamatAgensi.value,
                  style: TextStyle(fontSize: 12, color: Warna.grey),
                ),
              ),
              Center(
                child: Text(
                  c.kotaAgensi.value,
                  style: TextStyle(fontSize: 12, color: Warna.grey),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 22)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.off(DataAgenku());
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          'images/agensi/AgenGrey.png',
                          width: Get.width * 0.15,
                        ),
                        Center(
                          child: Text(
                            'Data Agen',
                            style: TextStyle(fontSize: 12, color: Warna.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      tampilkan.value = 'TambahAgen';
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          'images/agensi/TambahAgen.png',
                          width: Get.width * 0.15,
                        ),
                        Center(
                          child: Text(
                            'Tambah Agen',
                            style: TextStyle(fontSize: 12, color: Warna.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.off(PerformaAgensi());
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          'images/agensi/PerformaGrey.png',
                          width: Get.width * 0.15,
                        ),
                        Center(
                          child: Text(
                            'Performa',
                            style: TextStyle(fontSize: 12, color: Warna.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: [
              Padding(padding: EdgeInsets.only(top: 11)),
              Text(
                'Tambah Agen Baru',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.amber,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 11)),
              Text(
                'Ayo bangun tim kamu dengan menambahkan agen sesuai dengan spesialisasinya, cukup masukan Kode Anggota dari calon agen kamu pada kolom dibawah ini',
                style: TextStyle(
                  fontSize: 14,
                  color: Warna.grey,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.only(top: 22)),
              Container(
                padding: EdgeInsets.fromLTRB(33, 2, 33, 2),
                child: TextField(
                  onChanged: (ss) {},
                  maxLength: 8,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Warna.warnautama),
                  controller: controllerSS,
                  decoration: InputDecoration(
                      labelText: 'Kode Anggota Agen',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Container(
                margin: EdgeInsets.all(11),
                child: RawMaterialButton(
                  onPressed: () {
                    cekKelengkapanData();
                  },
                  constraints: BoxConstraints(),
                  elevation: 1.0,
                  fillColor: Colors.green,
                  child: Text(
                    'Tambah Agen !',
                    style: TextStyle(color: Warna.putih, fontSize: 16),
                  ),
                  padding: EdgeInsets.fromLTRB(22, 11, 22, 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(9)),
                  ),
                ),
              ),
            ],
          )
        ]),
      ),
    );
  }

  void cekKelengkapanData() {
    if (controllerSS.text == '') {
      Get.snackbar('Error..!!', 'Kode Anggota calon agen belum dimasukan');
    } else if (controllerSS.text.length != 8) {
      Get.snackbar('Error..!!', 'Kode Anggota calon agen tidak valid');
    } else {
      periksaAgenIni();
    }
  }

  void periksaAgenIni() async {
    EasyLoading.show(
        status:
            'Mohon tunggu kami sedang mengirimkan kode verifikasi kepada calon agen....');
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var ssagen = controllerSS.text;

    var datarequest = '{"pid":"$pid","ssagen":"$ssagen"}';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse('${c.baseURL}/agensi/periksaCalonAgen');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        namaCalon.value = hasil['namaAgen'];
        ssCalon.value = hasil['ssAgen'];
        fotoCalon.value = hasil['fotoAgen'];
        kodeTrx.value = hasil['kodeTrx'];
        clAgen.value = hasil['clAgen'];

        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          body: Obx(() => Container(
                child: Column(
                  children: [
                    Text(
                      'Verifikasi Calon Agen',
                      style: TextStyle(
                          color: Warna.grey,
                          fontSize: 22,
                          fontWeight: FontWeight.w500),
                    ),
                    Padding(padding: EdgeInsets.only(top: 22)),
                    Container(
                      padding: EdgeInsets.fromLTRB(33, 2, 33, 2),
                      child: Text(
                        'Kami telah mengirimkan kode pendaftaran agen kepada ${namaCalon.value}, silahkan masukan kode tersebut di kolom dibawah ini untuk menambahkan Agen.',
                        style: TextStyle(
                          color: Warna.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 22)),
                    CircleAvatar(
                      radius: 45.0,
                      backgroundImage: NetworkImage(fotoCalon.value),
                      backgroundColor: Colors.transparent,
                    ),
                    Text(
                      namaCalon.value,
                      style: TextStyle(
                          color: Warna.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      ssCalon.value,
                      style: TextStyle(
                        color: Warna.grey,
                        fontSize: 11,
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 22)),
                    Container(
                      margin: EdgeInsets.fromLTRB(22, 0, 22, 0),
                      child: Text("Spesialisasi",
                          style:
                              TextStyle(fontSize: 10, color: Warna.warnautama)),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(33, 2, 33, 2),
                      child: DropdownSearch<String>(
                          items: listKategori,
                          popupProps: PopupProps.menu(
                            showSelectedItems: true,
                            disabledItemFn: (String s) => s.startsWith('I'),
                          ),
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: "Spesialisasi",
                            ),
                          ),
                          onChanged: (a) {
                            pilihanKategori1 = a;
                            if ((clAgen > 1) && (clAgen < 6)) {
                              listKategori2.remove(a);
                              listKategori3.remove(a);
                              listKategori4.remove(a);
                              listKategori5.remove(a);

                              spe2.value = true;

                              //clearkan value
                              spe3.value = false;
                              spe4.value = false;
                              spe5.value = false;
                              pilihanKategori3 = '';
                              pilihanKategori4 = '';
                              pilihanKategori5 = '';
                            }
                          },
                          selectedItem: pilihanKategori1),
                    ),
                    (spe2.value == true)
                        ? Container(
                            margin: EdgeInsets.only(top: 15),
                            padding: EdgeInsets.fromLTRB(33, 2, 33, 2),
                            child: DropdownSearch<String>(
                                items: listKategori2,
                                popupProps: PopupProps.menu(
                                  showSelectedItems: true,
                                  disabledItemFn: (String s) =>
                                      s.startsWith('I'),
                                ),
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                    labelText: "Spesialisasi 2",
                                  ),
                                ),
                                onChanged: (b) {
                                  pilihanKategori2 = b;
                                  if ((clAgen > 2) && (clAgen < 6)) {
                                    listKategori3.remove(b);
                                    listKategori4.remove(b);
                                    listKategori5.remove(b);
                                    spe3.value = true;

                                    //clearkan value
                                    spe4.value = false;
                                    spe5.value = false;
                                    pilihanKategori4 = '';
                                    pilihanKategori5 = '';
                                  }
                                },
                                selectedItem: pilihanKategori2),
                          )
                        : Container(),
                    (spe3.value == true)
                        ? Container(
                            margin: EdgeInsets.only(top: 15),
                            padding: EdgeInsets.fromLTRB(33, 2, 33, 2),
                            child: DropdownSearch<String>(
                                items: listKategori3,
                                popupProps: PopupProps.menu(
                                  showSelectedItems: true,
                                  disabledItemFn: (String s) =>
                                      s.startsWith('I'),
                                ),
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                    labelText: "Spesialisasi 3",
                                  ),
                                ),
                                onChanged: (c) {
                                  pilihanKategori3 = c;
                                  if ((clAgen > 3) && (clAgen < 6)) {
                                    listKategori4.remove(c);
                                    listKategori5.remove(c);
                                    spe4.value = true;

                                    //clearkan value
                                    spe5.value = false;
                                    pilihanKategori5 = '';
                                  }
                                },
                                selectedItem: pilihanKategori3),
                          )
                        : Container(),
                    (spe4.value == true)
                        ? Container(
                            margin: EdgeInsets.only(top: 15),
                            padding: EdgeInsets.fromLTRB(33, 2, 33, 2),
                            child: DropdownSearch<String>(
                                popupProps: PopupProps.menu(
                                  showSelectedItems: true,
                                  disabledItemFn: (String s) =>
                                      s.startsWith('I'),
                                ),
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                    labelText: "Spesialisasi 4",
                                  ),
                                ),
                                items: listKategori4,
                                onChanged: (d) {
                                  pilihanKategori4 = d;
                                  if ((clAgen > 4) && (clAgen < 6)) {
                                    listKategori5.remove(d);
                                    spe5.value = true;
                                  }
                                },
                                selectedItem: pilihanKategori4),
                          )
                        : Container(),
                    (spe5.value == true)
                        ? Container(
                            margin: EdgeInsets.only(top: 15),
                            padding: EdgeInsets.fromLTRB(33, 2, 33, 2),
                            child: DropdownSearch<String>(
                                popupProps: PopupProps.menu(
                                  showSelectedItems: true,
                                  disabledItemFn: (String s) =>
                                      s.startsWith('I'),
                                ),
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                    labelText: "Spesialisasi 5",
                                  ),
                                ),
                                items: listKategori5,
                                onChanged: (e) {
                                  pilihanKategori5 = e;
                                },
                                selectedItem: pilihanKategori5),
                          )
                        : Container(),
                    Padding(padding: EdgeInsets.only(top: 15)),
                    Container(
                      padding: EdgeInsets.fromLTRB(33, 2, 33, 2),
                      child: Text(
                        'Silahkan masukan kode verifikasi :',
                        style: TextStyle(
                          color: Warna.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(33, 2, 33, 2),
                      child: TextField(
                        onChanged: (ss) {},
                        maxLength: 5,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Warna.warnautama),
                        controller: controllerVerifikasi,
                        decoration: InputDecoration(
                            labelText: 'Kode Verifikasi',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10))),
                      ),
                    ),
                  ],
                ),
              )),
          btnOkText: 'Tambahkan Agen !',
          btnOkOnPress: () {
            if (controllerVerifikasi.text.length != 5) {
              Get.snackbar('Error..!!',
                  'Sepertinya kode verifikasi belum dimasukan dengan benar');
            } else {
              prosesPendaftaranAgenSekarang();
            }
          },
        )..show();
      } else if (hasil['status'] == 'failed') {
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: 'Proses Gagal',
          desc: hasil['message'],
          btnCancelText: 'OK SIAP',
          btnCancelOnPress: () {
            controllerSS.text = '';
          },
        )..show();
      }
    }
    //END LOAD DATA TOP UP
  }

  void prosesPendaftaranAgenSekarang() async {
    EasyLoading.show(status: 'Mohon tunggu kami proses permintaan kamu...');
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var ssagen = controllerSS.text;
    var verifikasi = controllerVerifikasi.text;
    var kodeTr = kodeTrx.value;
    var sp1 = pilihanKategori1;
    var sp2 = pilihanKategori2;
    var sp3 = pilihanKategori3;
    var sp4 = pilihanKategori4;
    var sp5 = pilihanKategori5;

    var datarequest =
        '{"pid":"$pid","sp1":"$sp1","sp2":"$sp2","sp3":"$sp3","sp4":"$sp4","sp5":"$sp5","ssagen":"$ssagen","kodeTr":"$kodeTr","verifikasi":"$verifikasi"}';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse('${c.baseURL}/agensi/DaftarAgenSekarang');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'Proses Berhasil',
          desc: hasil['message'],
          btnOkText: 'OK SIAP',
          btnOkOnPress: () {
            controllerVerifikasi.text = '';
            Get.off(DataAgenku());
          },
        )..show();
      } else if (hasil['status'] == 'kode salah') {
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: 'Kode Salah',
          desc: hasil['message'],
          btnCancelText: 'OK SIAP',
          btnCancelOnPress: () {},
        )..show();
      } else {
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: 'Proses Gagal',
          desc: hasil['message'],
          btnCancelText: 'OK SIAP',
          btnCancelOnPress: () {},
        )..show();
      }
    }
  }
}
