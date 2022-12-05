import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import '/dashboard/view/dashboard.dart';
import '../mobil/trackingdriverMobil.dart';

class PembayaranPerjalananMobil extends StatefulWidget {
  @override
  _PembayaranPerjalananMobilState createState() =>
      _PembayaranPerjalananMobilState();
}

class _PembayaranPerjalananMobilState extends State<PembayaranPerjalananMobil> {
  final c = Get.find<ApiService>();
  final controllerPin = TextEditingController();

  var swCod = false.obs;
  var swSaldo = false.obs;
  var metodeBayarOK = ''.obs;
  var jarak = ''.obs;
  var waktu = ''.obs;
  var driverTersedia = false.obs;
  var inquiryCode = '';
  var payCode = '';

  @override
  void initState() {
    super.initState();
    cekSaldokuDulu();
    cekOngkosDanDriverTersedia();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pembayaran'),
        backgroundColor: Warna.warnautama,
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(5),
        height: Get.height * 0.08,
        child: RawMaterialButton(
          onPressed: () {
            if (driverTersedia.value == true) {
              prosesTransaksiSaya(); //sambil periksadata inputannya
            } else {
              alertDriverTidakTersedia();
            }
          },
          constraints: BoxConstraints(),
          elevation: 1.0,
          fillColor: Warna.warnautama,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lakukan Pemesanan',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                        color: Warna.putih),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 33,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(33)),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(0, 22, 0, 22),
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(11),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.map,
                    size: 33,
                    color: Warna.grey,
                  ),
                  SizedBox(
                    width: Get.width * 0.6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lokasi Tujuan',
                          style: TextStyle(
                              color: Warna.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                        Obx(() => Text(
                              c.alamatTujuanMobil.value,
                              style: TextStyle(
                                  color: Warna.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            )),
                        Text(
                          'Ket : ${c.ketTujuanMobil.value}',
                          style: TextStyle(
                              color: Warna.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                  ),
                  RawMaterialButton(
                    onPressed: () {
                      Get.back();
                      Get.back();
                    },
                    constraints: BoxConstraints(),
                    elevation: 1.0,
                    fillColor: Colors.amber,
                    child: Text(
                      'Ganti',
                      style: TextStyle(color: Colors.white),
                    ),
                    padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                    ),
                  )
                ],
              ),
            ),
            Divider(),
            Container(
              padding: EdgeInsets.all(11),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.location_city,
                    size: 33,
                    color: Warna.grey,
                  ),
                  SizedBox(
                    width: Get.width * 0.6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lokasi Penjemputan',
                          style: TextStyle(
                              color: Warna.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                        Obx(() => Text(
                              c.alamatJemputMobil.value,
                              style: TextStyle(
                                  color: Warna.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            )),
                        Text(
                          'Ket :${c.ketJemputMobil.value}',
                          style: TextStyle(
                              color: Warna.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                  ),
                  RawMaterialButton(
                    onPressed: () {
                      Get.back();
                    },
                    constraints: BoxConstraints(),
                    elevation: 1.0,
                    fillColor: Colors.amber,
                    child: Text(
                      'Ganti',
                      style: TextStyle(color: Colors.white),
                    ),
                    padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                    ),
                  )
                ],
              ),
            ),
            Divider(),
            Padding(padding: EdgeInsets.only(top: 22)),
            Container(
                padding: EdgeInsets.only(left: 22, right: 22),
                child: Text(
                  'Pilih metode pembayaran yang kamu inginkan, untuk menyelesaikan transaksi ini',
                  style: TextStyle(color: Warna.grey, fontSize: 15),
                )),
            Padding(padding: EdgeInsets.only(top: 22)),
            Card(
              child: Container(
                padding: EdgeInsets.fromLTRB(22, 5, 22, 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RawMaterialButton(
                          onPressed: () {
                            Get.back();
                          },
                          constraints: BoxConstraints(),
                          elevation: 1.0,
                          fillColor: Warna.warnautama,
                          child: Text(
                            'Total Pembayaran :',
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                          padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(9)),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: Get.width * 0.4,
                              child: Obx(() => Text(
                                    c.hargaPerjalananMobil.value,
                                    style: TextStyle(
                                        color: Warna.grey,
                                        fontSize: 27,
                                        fontWeight: FontWeight.w300),
                                  )),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RawMaterialButton(
                          onPressed: () {
                            Get.back();
                          },
                          constraints: BoxConstraints(),
                          elevation: 1.0,
                          fillColor: Warna.warnautama,
                          child: Text(
                            'Jarak dan Waktu tempuh :',
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                          padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(9)),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Obx(() => Text(
                                  jarak.value,
                                  style: TextStyle(
                                      color: Warna.grey,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w300),
                                )),
                            Obx(() => Text('Sekitar ${waktu.value}',
                                style:
                                    TextStyle(fontSize: 11, color: Warna.grey)))
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Container(
                padding: EdgeInsets.fromLTRB(22, 5, 22, 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Metode bayar :',
                      style: TextStyle(color: Colors.amber, fontSize: 12),
                    ),
                    Padding(padding: EdgeInsets.only(top: 11)),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: Get.width * 0.7,
                              child: Text(
                                'Tunai',
                                style: TextStyle(
                                    color: Warna.grey,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                            Text('Pembayaran tunai saat pengantaran',
                                style:
                                    TextStyle(fontSize: 11, color: Warna.grey))
                          ],
                        ),
                        Obx(() => Checkbox(
                              value: swCod.value,
                              onChanged: (newValue) {
                                pilihMetodeBayar('cod', newValue);
                              },
                            )),
                      ],
                    ),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: Get.width * 0.7,
                              child: Text(
                                'Saldo Aplikasi',
                                style: TextStyle(
                                    color: Warna.grey,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                            Text('Saldo kamu : ${c.saldo.value}',
                                style:
                                    TextStyle(fontSize: 11, color: Warna.grey))
                          ],
                        ),
                        Obx(() => Checkbox(
                              value: swSaldo.value,
                              onChanged: (newValue) {
                                pilihMetodeBayar('saldo', newValue);
                              },
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void pilihMetodeBayar(String pilih, newVal) {
    if (pilih == 'saldo') {
      if (c.saldoInt.value >= c.hargaIntPerjalananMobil.value) {
        if (newVal == true) {
          metodeBayarOK.value = 'saldo';
          swCod.value = !newVal;
          swSaldo.value = newVal;
        } else {
          metodeBayarOK.value = '';
          swCod.value = false;
          swSaldo.value = false;
        }
      } else {
        Get.snackbar('Saldo Tidak Cukup',
            'Sepertinya saldo kamu tidak mencukupi untuk melakukan pembayaran menggunakan saldo',
            colorText: Colors.black, snackPosition: SnackPosition.BOTTOM);
      }
    } else if (pilih == 'cod') {
      if (newVal == true) {
        metodeBayarOK.value = 'cod';
        swCod.value = newVal;
        swSaldo.value = !newVal;
      } else {
        metodeBayarOK.value = '';
        swCod.value = false;
        swSaldo.value = false;
      }
    }
  }

  void prosesTransaksiSaya() async {
    if (metodeBayarOK.value == 'cod') {
      lakukanPemesananCOD();
    } else if (metodeBayarOK.value == 'saldo') {
      requestPembayaranViaSaldo();
    } else {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        title: 'Metode Pembayaran',
        desc:
            'Opps... sepertinya kamu belum memilih metode pembayaran yang diinginkan',
        btnCancelText: 'OK SIAP',
        btnCancelOnPress: () {},
      )..show();
    }
  }

  void cekSaldokuDulu() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/ceksaldo');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });
    print(response.body);

    // EasyLoading.dismiss();
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        c.saldo.value = hasil['saldo'];
        c.saldoInt.value = hasil['saldoInt'];
      }
    }
  }

  void cekOngkosDanDriverTersedia() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var latTujuan = c.latTujuanMobil.value;
    var longTujuan = c.longTujuanMobil.value;
    var latJemput = c.latJemputMobil.value;
    var longJemput = c.longJemputMobil.value;
    var ketJemput = c.ketJemputMobil.value;
    var ketTujuan = c.ketTujuanMobil.value;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","ketJemput":"$ketJemput","ketTujuan":"$ketTujuan","latTujuan":"$latTujuan","longTujuan":"$longTujuan","latJemput":"$latJemput","longJemput":"$longJemput"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLdriver}/mobileAppsUser/cekDriverMobil');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        c.alamatTujuanMobil.value = hasil['destination'];
        c.alamatJemputMobil.value = hasil['origin'];
        jarak.value = hasil['jarakKm'];
        waktu.value = hasil['waktuTempuh'];
        c.hargaPerjalananMobil.value = hasil['hargaRp'];
        c.hargaIntPerjalananMobil.value = hasil['hargaInt'];
        driverTersedia.value = true;
        inquiryCode = hasil['inquiry'];
      } else if (hasil['status'] == 'tidak ada driver') {
        driverTersedia.value = false;
        c.alamatTujuanMobil.value = hasil['destination'];
        c.alamatJemputMobil.value = hasil['origin'];
        jarak.value = hasil['jarakKm'];
        waktu.value = hasil['waktuTempuh'];
        c.hargaPerjalananMobil.value = hasil['hargaRp'];
        c.hargaIntPerjalananMobil.value = hasil['hargaInt'];
      }
    }
  }

  void alertDriverTidakTersedia() {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Image.asset(
            'images/nodriver.png',
            width: Get.width * 0.5,
          ),
          Text('DRIVER SEDANG SIBUK',
              style: TextStyle(
                  fontSize: 18,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w600)),
          Text(
              'Opps.. maaf saat ini driver kami sedang sibuk semua, kami belum bisa menemukan driver untukmu.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center),
          Padding(padding: EdgeInsets.only(top: 9)),
          RawMaterialButton(
            onPressed: () {
              Get.offAll(Dashboardku());
            },
            constraints: BoxConstraints(),
            elevation: 1.0,
            fillColor: Warna.warnautama,
            child: Text(
              'Batalkan perjalanan',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Warna.putih),
            ),
            padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(33)),
            ),
          ),
        ],
      ),
    )..show();
  }

  void lakukanPemesananCOD() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","inquiry":"$inquiryCode","pembayaranVia":"${metodeBayarOK.value}"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLdriver}/mobileAppsUser/pesanMotorCODMobilV2');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        var driverList = hasil['driver'];
        c.kodeTransaksiMobil.value = hasil['kodetrx'];
        c.arrIdDriverMobil.clear();
        for (var a = 0; a < driverList.length; a++) {
          c.arrIdDriverMobil.add(driverList[a]);
        }
        Get.offAll(Dashboardku());
        Get.to(() => TrackingDriverMobil());
      } else if (hasil['status'] == 'tidak ada driver') {
        alertDriverTidakTersedia();
      } else {
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'PERHATIAN !',
          desc: hasil['message'],
          btnCancelText: 'OK',
          btnCancelOnPress: () {
            Get.back();
          },
        )..show();
      }
    }
  }

  requestPembayaranViaSaldo() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","inquiry":"$inquiryCode","pembayaranVia":"${metodeBayarOK.value}"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLdriver}/mobileAppsUser/pesanMotorSaldoMobilV2');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });
    print(response.body);

    // EasyLoading.dismiss();
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        payCode = hasil['kodeBayar'];
        var payCodeNominal = hasil['nominalRp'];
        pinDibutuhkanPayment(payCodeNominal);
      } else if (hasil['status'] == 'tidak ada driver') {
        Get.snackbar('Driver tidak ditemukan di area ini',
            'Opps... sepertinya driver di daerah ini tidak ditemukan');
      } else if (hasil['status'] == 'Aplikator Maintenance') {
        Get.snackbar('Sedang Gangguan',
            'Maaf saat ini pembayaran menggunakan saldo sedang gangguan, coba gunakan metode lain');
      } else {
        Get.snackbar('Gagal Pembayaran Via Saldo',
            'Maaf saat ini pembayaran menggunakan saldo sedang gangguan, coba gunakan metode lain');
      }
    }
  }

  pinDibutuhkanPayment(nominal) {
    final controllerPin = TextEditingController();
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
      title: '',
      desc: '',
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                  onTap: () {
                    Get.offAll(() => Dashboardku());
                  },
                  child:
                      Icon(Icons.highlight_remove_rounded, color: Colors.grey)),
            ],
          ),
          Image.asset(
            'images/secure.png',
            width: Get.width * 0.5,
          ),
          Text('PIN DIBUTUHKAN',
              style: TextStyle(
                  fontSize: 18,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w600)),
          Text('Silahkan masukan PIN kamu untuk melakukan transaksi ini',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center),
          Padding(padding: EdgeInsets.only(top: 9)),
          Text(
            'Pembayaran Transaksi Transportasi Online',
            style: TextStyle(fontSize: 14, color: Warna.grey),
          ),
          Text(
            nominal,
            style: TextStyle(
                fontSize: 16, color: Warna.grey, fontWeight: FontWeight.w600),
          ),
          Padding(padding: EdgeInsets.only(top: 16)),
          Container(
            width: Get.width * 0.7,
            child: TextField(
              obscureText: true,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: TextStyle(
                  fontSize: 25, fontWeight: FontWeight.w600, color: Warna.grey),
              controller: controllerPin,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.vpn_key),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          Row(
            children: [
              RawMaterialButton(
                constraints: BoxConstraints(minWidth: Get.width * 0.7),
                elevation: 1.0,
                fillColor: Warna.warnautama,
                child: Text(
                  'Proses Transaksi Ini',
                  style: TextStyle(color: Warna.putih, fontSize: 14),
                ),
                padding: EdgeInsets.fromLTRB(18, 9, 18, 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                ),
                onPressed: () {
                  if ((controllerPin.text == '') ||
                      (controllerPin.text.length != 6)) {
                    controllerPin.text = '';
                    Get.snackbar('PERHATIAN...',
                        'Pin tidak dimasukan dengan benar, Pin hanya berisi 6 angka');
                  } else {
                    prosesPembayaranPaymentSaldo(controllerPin.text);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    )..show();
  }

  void prosesPembayaranPaymentSaldo(pin) async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }

    EasyLoading.show(status: 'Mohon tunggu...', dismissOnTap: false);
    //try {
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');

    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","pin":"$pin","payCode":"$payCode"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/paymentDriver');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });
    print(response.body);
    //BUKA PIN APABILA SUDAH BERHASIL
    EasyLoading.dismiss();
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        Get.offAll(Dashboardku());
        Get.to(() => TrackingDriverMobil());
      } else if (hasil['status'] == 'saldo apk pada dcn kosong') {
        Get.snackbar(
          'Tidak Dapat Melanjutkan Proses',
          'Silahkan menghubungi layanan live chat dengna kode error-sal-dcn',
        );
      } else if (hasil['status'] == 'PIN SALAH') {
        Get.snackbar('PIN TIDAK SESUAI',
            'Oppss... sepertinya pin yang dimasukan tidak sesuai',
            colorText: Colors.white);
      } else if (hasil['status'] == 'SALDO TIDAK CUKUP') {
        Get.snackbar('SALDO TIDAK CUKUP',
            'Oppss... sepertinya saldo kamu tidak cukup silahkan topup saldo terlebih dahulu');
      } else {
        AwesomeDialog(
          context: Get.context,
          dismissOnBackKeyPress: false,
          dismissOnTouchOutside: false,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: 'PERHATIAN !',
          desc: hasil['message'],
          btnCancelText: 'OK',
          btnCancelColor: Colors.amber,
          btnCancelOnPress: () {
            Get.back();
            // Get.offAll(Dashboardku());
            // Get.to(() => TrackingDriverMotor());
          },
        )..show();
      }
    }
  }
}
