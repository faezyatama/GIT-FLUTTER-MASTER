import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as https;
import 'package:crypto/crypto.dart';
import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';

import 'petaOutletMakan.dart';

class PengaturanOutlet extends StatefulWidget {
  @override
  _PengaturanOutletState createState() => _PengaturanOutletState();
}

class _PengaturanOutletState extends State<PengaturanOutlet> {
  TextStyle styleTextNormal = TextStyle(
    fontSize: 14,
    color: Warna.grey,
  );
  TextStyle styleHurufBesar = TextStyle(
      fontSize: 18, color: Warna.warnautama, fontWeight: FontWeight.w600);
  TextStyle styleHurufsedang = TextStyle(
      fontSize: 15, color: Warna.warnautama, fontWeight: FontWeight.w600);
  TextStyle smallhuruf = TextStyle(
      fontSize: 14, color: Warna.warnautama, fontWeight: FontWeight.w300);
  TextStyle styleHurufkecil = TextStyle(fontSize: 11, color: Warna.grey);

  //parameter yang dibutuhkan
  final c = Get.find<ApiService>();
  List<String> listProvinsi = [];
  var dataprovinsi = false;
  var pilihanProvinsi = '';

  List<String> listKabupaten = [];
  var datakab = false;
  var pilihanKabupaten = '';

  List<String> listKecamatan = [];
  var dataKec = false;
  var pilihanKecamatan = '';

  var namaOutlet = 'Nama Outlet Kamu ?'.obs;
  var tagline = 'Ucapan selamat datang kepada penggunjung'.obs;
  var alamat = 'Alamat Outlet ?'.obs;
  var provinsi = 'Provinsi'.obs;
  var kabupaten = 'Kabupaten'.obs;
  var kecamatan = 'Kecamatan'.obs;
  var senin = true;
  var selasa = true;
  var rabu = true;
  var kamis = true;
  var jumat = true;
  var sabtu = true;
  var minggu = true;
  var pengirimanSendiri = false;
  var pengirimanSasuka = true;
  var kirimViasendiri = false;
  var kirimViaSatuAja = true;
  var kirimViaFinal = 'SASUKA';
  var jambuka = '00 : 00'.obs;
  var jamtutup = '00 : 00'.obs;
  final controllerSSText1 = TextEditingController();
  final controllerSSText2 = TextEditingController();
  final controllerSSText3 = TextEditingController();
  final controllerSSText4 = TextEditingController();
  final controllerSSText5 = TextEditingController();

  final controllerGratisKM = TextEditingController();
  final controllerMaxKM = TextEditingController();
  final controllerHargaKM = TextEditingController();

  TimeOfDay _timeBuka = TimeOfDay.now().replacing(minute: 30);
  TimeOfDay _timeTutup = TimeOfDay.now().replacing(minute: 30);

  bool iosStyle = true;

  void onTimeChanged(TimeOfDay newTime) {
    setState(() {
      _timeBuka = newTime;
      jambuka.value =
          _timeBuka.hour.toString() + ' : ' + _timeBuka.minute.toString();
    });
  }

  void onTimeChangedTutup(TimeOfDay newTime) {
    setState(() {
      _timeTutup = newTime;
      jamtutup.value =
          _timeTutup.hour.toString() + ' : ' + _timeTutup.minute.toString();
    });
  }

  //lokasi outlet

  @override
  void initState() {
    super.initState();
    cekAwalOutletDetail();
    provinsiCek();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Atur Outlet Kuliner'),
            backgroundColor: Warna.warnautama),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(11),
          child: RawMaterialButton(
            onPressed: () {
              //bukaOutletNow('Makanan');
              periksaKelengkapanParameter();
            },
            constraints: BoxConstraints(),
            elevation: 1.0,
            fillColor: Warna.warnautama,
            child: Text(
              'Update Outlet Sekarang !',
              style: TextStyle(color: Warna.putih, fontSize: 16),
            ),
            padding: EdgeInsets.fromLTRB(22, 11, 22, 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(9)),
            ),
          ),
        ),
        body: ListView(children: [
          Container(
            margin: EdgeInsets.fromLTRB(22, 11, 22, 11),
            child: Card(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RawMaterialButton(
                      onPressed: () {},
                      constraints: BoxConstraints(),
                      elevation: 1.0,
                      fillColor: Colors.grey,
                      child: Text(
                        '1. Atur Nama Warung/Resto',
                        style: TextStyle(color: Warna.putih, fontSize: 16),
                      ),
                      padding: EdgeInsets.fromLTRB(22, 11, 22, 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 22)),
                    Text(
                      'Kamu bisa mengatur nama warung/restoran kamu disini, Caranya cukup klik Nama Outlet dan edit sesuai keinginan kamu.',
                      style: styleTextNormal,
                    ),
                    Padding(padding: EdgeInsets.only(top: 22)),
                    Text(
                      'Tagline/motto/ucapan selamat datang dapat kamu atur juga loh, cukup klik dan ganti sesuai keinginan kamu.',
                      style: styleTextNormal,
                    ),
                    Padding(padding: EdgeInsets.only(top: 22)),
                    Text(
                      'Nama Warung/Resto :',
                      style: styleHurufkecil,
                    ),
                    GestureDetector(
                      onTap: () {
                        editText('Nama Outlet');
                      },
                      child: Row(
                        children: [
                          SizedBox(
                            width: Get.width * 0.6,
                            child: Obx(() => Text(
                                  namaOutlet.value,
                                  style: styleHurufBesar,
                                )),
                          ),
                          Padding(padding: EdgeInsets.only(left: 11)),
                          Icon(
                            Icons.drive_file_rename_outline,
                            color: Warna.warnautama,
                            size: 25,
                          )
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 11)),
                    Text(
                      'Tagline/Motto/Ucapan :',
                      style: styleHurufkecil,
                    ),
                    GestureDetector(
                      onTap: () {
                        editText('Pengaturan Tagline');
                      },
                      child: Row(
                        children: [
                          SizedBox(
                            width: Get.width * 0.6,
                            child: Obx(() => Text(
                                  tagline.value,
                                  style: styleHurufsedang,
                                )),
                          ),
                          Padding(padding: EdgeInsets.only(left: 11)),
                          Icon(
                            Icons.drive_file_rename_outline,
                            color: Warna.warnautama,
                            size: 25,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(22, 11, 22, 11),
            child: Card(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RawMaterialButton(
                      onPressed: () {},
                      constraints: BoxConstraints(),
                      elevation: 1.0,
                      fillColor: Colors.grey,
                      child: Text(
                        '2. Atur Alamat / Peta Lokasi',
                        style: TextStyle(color: Warna.putih, fontSize: 16),
                      ),
                      padding: EdgeInsets.fromLTRB(22, 11, 22, 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 22)),
                    Text(
                      'Supaya pelanggan dan kurir dapat menemukan outlet kamu dengan mudah, kamu bisa mengatur alamat kamu disini',
                      style: styleTextNormal,
                    ),
                    Padding(padding: EdgeInsets.only(top: 22)),
                    Text(
                      'Alamat Outlet :',
                      style: styleHurufkecil,
                    ),
                    GestureDetector(
                      onTap: () {
                        editText('Alamat Outlet');
                      },
                      child: Row(
                        children: [
                          SizedBox(
                            width: Get.width * 0.6,
                            child: Obx(() => Text(
                                  alamat.value,
                                  style: styleHurufBesar,
                                )),
                          ),
                          Padding(padding: EdgeInsets.only(left: 11)),
                          Icon(
                            Icons.drive_file_rename_outline,
                            color: Warna.warnautama,
                            size: 25,
                          )
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 22)),
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
                    Padding(padding: EdgeInsets.only(top: 22)),
                    (datakab == true)
                        ? DropdownSearch<String>(
                            popupProps: PopupProps.menu(
                              showSelectedItems: true,
                              disabledItemFn: (String s) => s.startsWith('I'),
                            ),
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                labelText: "Kabupaten",
                              ),
                            ),
                            items: listKabupaten,
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
                            popupProps: PopupProps.menu(
                              showSelectedItems: true,
                              disabledItemFn: (String s) => s.startsWith('I'),
                            ),
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                labelText: "Kecamatan",
                              ),
                            ),
                            items: listKecamatan,
                            onChanged: (kecValue) {
                              pilihanKecamatan = kecValue;
                            },
                            selectedItem: pilihanKecamatan)
                        : Padding(padding: EdgeInsets.only(top: 11)),
                    Padding(padding: EdgeInsets.only(top: 22)),
                    Padding(padding: EdgeInsets.only(top: 22)),
                    Text(
                      'Peta Lokasi Outlet :',
                      style: styleHurufkecil,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => SetLokasiOutletMakan());
                      },
                      child: Obx(() => Row(
                            children: [
                              SizedBox(
                                  width: Get.width * 0.6,
                                  child: (c.latOutletMakanku.value == 0.0)
                                      ? Text(
                                          'Peta Lokasi Belum ditentukan',
                                          style: styleHurufBesar,
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Peta Lokasi Sudah Ada',
                                              style: styleHurufBesar,
                                            ),
                                            Text(
                                              'GPS : ' +
                                                  c.latOutletMakanku.value
                                                      .toString() +
                                                  ' / ' +
                                                  c.longOutletMakanku.value
                                                      .toString(),
                                              style: styleHurufkecil,
                                            ),
                                          ],
                                        )),
                              Padding(padding: EdgeInsets.only(left: 11)),
                              Icon(
                                Icons.drive_file_rename_outline,
                                color: Warna.warnautama,
                                size: 25,
                              )
                            ],
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(22, 11, 22, 11),
            child: Card(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RawMaterialButton(
                      onPressed: () {},
                      constraints: BoxConstraints(),
                      elevation: 1.0,
                      fillColor: Colors.grey,
                      child: Text(
                        '3. Atur Waktu Operasional',
                        style: TextStyle(color: Warna.putih, fontSize: 16),
                      ),
                      padding: EdgeInsets.fromLTRB(22, 11, 22, 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 22)),
                    Text(
                      'Tentukan waktu kerja kamu disini, waktu kerja akan menginformasukan kepada pelanggan kamu apakah saat ini kamu sedang buka atau tutup',
                      style: styleTextNormal,
                    ),
                    Padding(padding: EdgeInsets.only(top: 22)),
                    Padding(padding: EdgeInsets.only(top: 22)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Jam Buka  Outlet :',
                              style: styleHurufkecil,
                            ),
                            Obx(() => ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    showPicker(
                                      is24HrFormat: true,
                                      context: context,
                                      value: _timeBuka,
                                      onChange: (onTimeChanged),
                                    ),
                                  );
                                },
                                child: Text(jambuka.value))),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'Jam Tutup Outlet :',
                              style: styleHurufkecil,
                            ),
                            Obx(() => ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    showPicker(
                                      is24HrFormat: true,
                                      context: context,
                                      value: _timeTutup,
                                      onChange: onTimeChangedTutup,
                                    ),
                                  );
                                },
                                child: Text(jamtutup.value))),
                          ],
                        ),
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(top: 22)),
                    Text(
                      'Hari Kerja Outlet :',
                      style: styleHurufkecil,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: senin,
                          onChanged: (newValue) {
                            setState(() {
                              senin = newValue;
                            });
                          },
                        ),
                        Padding(padding: EdgeInsets.only(left: 11)),
                        Text('Senin'),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: selasa,
                          onChanged: (newValue) {
                            setState(() {
                              selasa = newValue;
                            });
                          },
                        ),
                        Padding(padding: EdgeInsets.only(left: 11)),
                        Text('Selasa'),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: rabu,
                          onChanged: (newValue) {
                            setState(() {
                              rabu = newValue;
                            });
                          },
                        ),
                        Padding(padding: EdgeInsets.only(left: 11)),
                        Text('Rabu'),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: kamis,
                          onChanged: (newValue) {
                            setState(() {
                              kamis = newValue;
                            });
                          },
                        ),
                        Padding(padding: EdgeInsets.only(left: 11)),
                        Text('Kamis'),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: jumat,
                          onChanged: (newValue) {
                            setState(() {
                              jumat = newValue;
                            });
                          },
                        ),
                        Padding(padding: EdgeInsets.only(left: 11)),
                        Text('Jumat'),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: sabtu,
                          onChanged: (newValue) {
                            setState(() {
                              sabtu = newValue;
                            });
                          },
                        ),
                        Padding(padding: EdgeInsets.only(left: 11)),
                        Text('Sabtu'),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: minggu,
                          onChanged: (newValue) {
                            setState(() {
                              minggu = newValue;
                            });
                          },
                        ),
                        Padding(padding: EdgeInsets.only(left: 11)),
                        Text('Minggu'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(22, 11, 22, 11),
            child: Card(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RawMaterialButton(
                      onPressed: () {},
                      constraints: BoxConstraints(),
                      elevation: 1.0,
                      fillColor: Colors.grey,
                      child: Text(
                        '4. Atur Metode Pengiriman',
                        style: TextStyle(color: Warna.putih, fontSize: 16),
                      ),
                      padding: EdgeInsets.fromLTRB(22, 11, 22, 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 22)),
                    Text(
                      'Kamu bisa mengatur metode pengiriman untuk outlet kamu, Apabila kamu memiliki kurir sendiri maka kamu bisa memilih metode pengiriman sendiri, namun apabila tidak ada maka pengiriman akan di atur oleh sistem ${c.namaAplikasi} untuk mencari alternatif pengiriman yang memungkinkan',
                      style: styleTextNormal,
                    ),
                    Padding(padding: EdgeInsets.only(top: 22)),
                    Padding(padding: EdgeInsets.only(top: 22)),
                    Text(
                      'Pengaturan Pengiriman :',
                      style: styleHurufkecil,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Diatur Sistem'),
                        Checkbox(
                          value: kirimViaSatuAja,
                          onChanged: (newValue) {
                            pilihanPengiriman('SASUKA', newValue);
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pakai kurir sendiri'),
                        Checkbox(
                          value: kirimViasendiri,
                          onChanged: (newValue) {
                            pilihanPengiriman('SENDIRI', newValue);
                          },
                        ),
                      ],
                    ),
                    (kirimViasendiri == true)
                        ? Container(
                            child: Column(
                              children: [
                                Divider(),
                                Text(
                                  'Kamu bisa mengatur sendiri harga pengiriman ke pelanggan, mulai dari Gratis Ongkir ataupun memberikan harga kirim berdasarkan jarak.',
                                  style: styleTextNormal,
                                ),
                                Padding(padding: EdgeInsets.only(top: 22)),
                                TextField(
                                  maxLength: 2,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Warna.grey),
                                  controller: controllerGratisKM,
                                  decoration: InputDecoration(
                                      labelText:
                                          'Maksimal pengantaran GRATIS (km)',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                                TextField(
                                  maxLength: 2,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Warna.grey),
                                  controller: controllerMaxKM,
                                  decoration: InputDecoration(
                                      labelText:
                                          'Maksimal Jangkauan Layanan (km)',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                                TextField(
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Warna.grey),
                                  controller: controllerHargaKM,
                                  decoration: InputDecoration(
                                      labelText: 'Harga kurir per-Km (Rp.)',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                                Divider(),
                                Text(
                                  'Kamu bisa dengan mudah mendaftarkan kurir sendiri yang terintegrasi dengan Outlet Kamu. Setelah kurir kamu terdaftar maka kamu cukup masukan Kode Anggota kurir ke form dibawah ini ya...',
                                  style: styleTextNormal,
                                ),
                                Padding(padding: EdgeInsets.only(top: 22)),
                                TextField(
                                  onChanged: (ss) {
                                    if (ss.length == 8) {
                                      cekKodeSSDriver(ss, 'Kurir1');
                                    }
                                  },
                                  maxLength: 8,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Warna.grey),
                                  controller: controllerSSText1,
                                  decoration: InputDecoration(
                                      labelText: 'Kode Anggota Kurir 1',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                                TextField(
                                  onChanged: (ss) {
                                    if (ss.length == 8) {
                                      cekKodeSSDriver(ss, 'Kurir2');
                                    }
                                  },
                                  maxLength: 8,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Warna.grey),
                                  controller: controllerSSText2,
                                  decoration: InputDecoration(
                                      labelText: 'Kode Anggota Kurir 2',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                                TextField(
                                  onChanged: (ss) {
                                    if (ss.length == 8) {
                                      cekKodeSSDriver(ss, 'Kurir3');
                                    }
                                  },
                                  maxLength: 8,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Warna.grey),
                                  controller: controllerSSText3,
                                  decoration: InputDecoration(
                                      labelText: 'Kode Anggota Kurir 3',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                                TextField(
                                  onChanged: (ss) {
                                    if (ss.length == 8) {
                                      cekKodeSSDriver(ss, 'Kurir4');
                                    }
                                  },
                                  maxLength: 8,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Warna.grey),
                                  controller: controllerSSText4,
                                  decoration: InputDecoration(
                                      labelText: 'Kode Anggota Kurir 4',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                                TextField(
                                  onChanged: (ss) {
                                    if (ss.length == 8) {
                                      cekKodeSSDriver(ss, 'Kurir5');
                                    }
                                  },
                                  maxLength: 8,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Warna.grey),
                                  controller: controllerSSText5,
                                  decoration: InputDecoration(
                                      labelText: 'Kode Anggota Kurir 5',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          )
        ]));
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

    var url = Uri.parse('${c.baseURLmakan}/mobileAppsOutlet/provinsi');

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

    var url = Uri.parse('${c.baseURLmakan}/mobileAppsOutlet/kabupaten');

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

    var url = Uri.parse('${c.baseURLmakan}/mobileAppsOutlet/kecamatan');

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

  editText(detail) {
    final controllerText = TextEditingController();
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Text('Pengaturan ' + detail,
              style: TextStyle(
                  fontSize: 18,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w600)),
          Text('Nama outlet makanan',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center),
          Padding(padding: EdgeInsets.only(top: 9)),
          Padding(padding: EdgeInsets.only(top: 16)),
          Container(
            width: Get.width * 0.7,
            child: TextField(
              maxLines: 4,
              textAlign: TextAlign.center,
              maxLength: 50,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w600, color: Warna.grey),
              controller: controllerText,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          RawMaterialButton(
            constraints: BoxConstraints(minWidth: Get.width * 0.7),
            elevation: 1.0,
            fillColor: Warna.warnautama,
            child: Text(
              'Atur ' + detail,
              style: TextStyle(color: Warna.putih, fontSize: 14),
            ),
            padding: EdgeInsets.fromLTRB(18, 9, 18, 9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            onPressed: () {
              if ((controllerText.text == '') ||
                  (controllerText.text.length < 6)) {
                controllerText.text = '';
                Get.back();
                AwesomeDialog(
                  context: Get.context,
                  dialogType: DialogType.noHeader,
                  animType: AnimType.rightSlide,
                  title: 'PERHATIAN !',
                  desc:
                      'Sepertinya pengisian form belum dilakukan dengan benar',
                  btnCancelText: 'OK',
                  btnCancelColor: Colors.amber,
                  btnCancelOnPress: () {},
                )..show();
              } else {
                if (detail == 'Nama Outlet') {
                  namaOutlet.value = controllerText.text;
                } else if (detail == 'Pengaturan Tagline') {
                  tagline.value = controllerText.text;
                } else if (detail == 'Alamat Outlet') {
                  alamat.value = controllerText.text;
                }
                Get.back();
              }
            },
          ),
        ],
      ),
    )..show();
  }

  void pilihanPengiriman(String s, bool newValue) {
    //clear all
    setState(() {
      kirimViaSatuAja = false;
      kirimViasendiri = false;

      if ((s == 'SASUKA')) {
        kirimViaSatuAja = newValue;
        kirimViasendiri = !newValue;
        kirimViaFinal = 'SASUKA';
      }
      if ((s == 'SENDIRI')) {
        kirimViasendiri = newValue;
        kirimViaSatuAja = !newValue;
        kirimViaFinal = 'SENDIRI';
      }
    });
  }

  void periksaKelengkapanParameter() {
    if (namaOutlet.value == 'Nama Outlet Kamu ?') {
      errorParameter('Nama Outlet belum di isi dengan benar');
    } else if (tagline.value == 'Ucapan selamat datang kepada penggunjung') {
      errorParameter(
          'Tagline / Motto / Ucapan selamat datang belum diisi dengan benar');
    } else if (alamat.value == 'Alamat Outlet ?') {
      errorParameter(
          'Alamat outlet kamu belum diisi dengan benar, Isikan alamat outlet untuk mempermudah proses pengiriman');
    } else if (pilihanProvinsi == '') {
      errorParameter('Pilih provinsi tempat outlet kamu berada');
    } else if (pilihanKabupaten == '') {
      errorParameter('Pilih Kabupaten / Kota tempat outlet kamu berada');
    } else if (pilihanKecamatan == '') {
      errorParameter('Pilih Kecamatan tempat outlet kamu berada');
    } else if (pilihanKecamatan == '') {
      errorParameter('Pilih Kecamatan tempat outlet kamu berada');
    } else if (c.latOutletMakanku.value == 0.0) {
      errorParameter(
          'Opps.. Sepertinya kamu belum menentukan lokasi outlet kamu pada peta');
    } else {
      updateOutletNow('Makanan');
    }
  }

  void updateOutletNow(String s) async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');

    //PARAMETER BUKA OUTLET
    String haribuka = "$senin#$selasa#$rabu#$kamis#$jumat#$sabtu#$minggu";
    var latOutletku = c.latOutletMakanku.value;
    var longOutletku = c.longOutletMakanku.value;
    var combineSS = controllerSSText1.text +
        ',' +
        controllerSSText2.text +
        ',' +
        controllerSSText3.text +
        ',' +
        controllerSSText4.text +
        ',' +
        controllerSSText5.text;

    var gratisKm = controllerGratisKM.text;
    var maxLayanan = controllerMaxKM.text;
    var hargaKm = controllerHargaKM.text;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","gratis":"$gratisKm","jangkauan":"$maxLayanan","hargakm":"$hargaKm","jenis":"$s","namaOutlet":"$namaOutlet","tagline":"$tagline","alamat":"$alamat","provinsi":"$pilihanProvinsi","kabupaten":"$pilihanKabupaten","kecamatan":"$pilihanKecamatan","latOutlet":"$latOutletku","longOutlet":"$longOutletku","buka":"${jambuka.value}","tutup":"${jamtutup.value}","hari":"$haribuka","pengiriman":"$kirimViaFinal","integrasi":"$combineSS"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLmakan}/mobileAppsOutlet/updateOutlet');

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
        //proses pendaftaran akun berhasil
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'Berhasil...!',
          desc: 'Perubahan outlet kamu telah dilakukan',
          btnOkText: 'OK',
          btnOkOnPress: () {
            c.adaOutletMakan.value = 'Ada';
            var detailOutlet = hasil['detailOutlet'];
            c.namaOutletMakan.value = detailOutlet[0];
            c.alamatOutletMakan.value = detailOutlet[1];
            c.kabupatenMakan.value = detailOutlet[2];
            c.deskripsiMakan.value = detailOutlet[3];
            c.kunjunganMakan.value = detailOutlet[4];
            c.terjualMakan.value = detailOutlet[5];
            c.produkMakan.value = detailOutlet[6];
            Get.back();
          },
        )..show();
      } else {
        Get.back();
      }
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

  void cekKodeSSDriver(String ss, String kurir) async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');

    //PARAMETER BUKA OUTLET
    var ssDriver = ss;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","ss":"$ssDriver"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLmakan}/mobileAppsOutlet/cekSSDriverIntegrasi');

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
        var dataKurir = hasil['data'];
        var pesan = hasil['pesan'];
        var messege = hasil['message'];
        if (messege == 'Found') {
          AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.noHeader,
            animType: AnimType.rightSlide,
            title: dataKurir,
            desc: pesan,
            btnCancelText: 'OK',
            btnCancelColor: Colors.amber,
            btnCancelOnPress: () {},
          )..show();
        } else {
          AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.noHeader,
            animType: AnimType.rightSlide,
            title: dataKurir,
            desc: pesan,
            btnCancelText: 'OK',
            btnCancelColor: Colors.amber,
            btnCancelOnPress: () {},
          )..show();
          //bersihkan kolom
          if (kurir == 'Kurir1') {
            controllerSSText1.text = '';
          } else if (kurir == 'Kurir2') {
            controllerSSText2.text = '';
          } else if (kurir == 'Kurir3') {
            controllerSSText3.text = '';
          } else if (kurir == 'Kurir4') {
            controllerSSText4.text = '';
          } else if (kurir == 'Kurir5') {
            controllerSSText5.text = '';
          }
        }
      }
    }
  }

  void cekAwalOutletDetail() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","jenis":"Makanan"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLmakan}/mobileAppsOutlet/cekAwalDataOutlet');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    // EasyLoading.dismiss();
    print(response.body);
    var kurir = [];
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        var detoutlet = hasil['detailOutlet'];
        var hari = hasil['hari'];
        kurir = hasil['kurir'];
        setState(() {
          namaOutlet.value = detoutlet[0];
          tagline.value = detoutlet[1];
          alamat.value = detoutlet[2];
          pilihanProvinsi = detoutlet[3];
          pilihanKabupaten = detoutlet[4];
          pilihanKecamatan = detoutlet[5];
          c.latOutletMakanku.value = detoutlet[6];
          c.longOutletMakanku.value = detoutlet[7];
          jambuka.value = detoutlet[8];
          jamtutup.value = detoutlet[9];

          //PENGATURAN HARI
          senin = hari[0];
          selasa = hari[1];
          rabu = hari[2];
          kamis = hari[3];
          jumat = hari[4];
          sabtu = hari[5];
          minggu = hari[6];

          //kurir
          if (detoutlet[10] == 'SENDIRI') {
            kirimViaSatuAja = false;
            kirimViasendiri = true;
            kirimViaFinal = 'SENDIRI';

            controllerGratisKM.text = detoutlet[11].toString();
            controllerMaxKM.text = detoutlet[12].toString();
            controllerHargaKM.text = detoutlet[13].toString();
          } else {
            kirimViaSatuAja = true;
            kirimViasendiri = false;
            kirimViaFinal = 'SASUKA';
          }

          if (0 < kurir.length) {
            controllerSSText1.text = kurir[0];
          }
          if (1 < kurir.length) {
            controllerSSText2.text = kurir[1];
          }
          if (2 < kurir.length) {
            controllerSSText3.text = kurir[2];
          }
          if (3 < kurir.length) {
            controllerSSText4.text = kurir[3];
          }
          if (4 < kurir.length) {
            controllerSSText5.text = kurir[4];
          }
        });
      }
    }
  }
}
