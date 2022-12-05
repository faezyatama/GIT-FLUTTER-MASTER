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
import '../pesanan/pesanan.dart';

class PembayaranMakanan extends StatefulWidget {
  @override
  _PembayaranMakananState createState() => _PembayaranMakananState();
}

class _PembayaranMakananState extends State<PembayaranMakanan> {
  final c = Get.find<ApiService>();
  final controllerPin = TextEditingController();

  var swCod = false.obs;
  var swSaldo = false.obs;
  var metodeBayarOK = ''.obs;
  var payCode = '';

  @override
  void initState() {
    super.initState();
    cekSaldokuDulu();
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
            prosesPesananSaya();
          },
          constraints: BoxConstraints(),
          elevation: 1.0,
          fillColor: Warna.warnautama,
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Proses Pesanan Saya',
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
        child: Column(
          children: [
            Container(
                padding: EdgeInsets.only(left: 22, right: 22),
                child: Text(
                  'Pilih metode pembayaran yang kamu inginkan, untuk menyelesaikan transaksi ini',
                  style: TextStyle(color: Warna.grey, fontSize: 15),
                )),
            Padding(padding: EdgeInsets.only(top: 22)),
            Card(
              elevation: 1.0,
              child: Container(
                padding: EdgeInsets.fromLTRB(22, 5, 22, 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nama Outlet :',
                      style: TextStyle(color: Colors.amber, fontSize: 12),
                    ),
                    Padding(padding: EdgeInsets.only(top: 11)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: Get.width * 0.9,
                          child: Text(
                            c.namaoutletpadakeranjang.value,
                            style: TextStyle(
                                color: Warna.grey,
                                fontSize: 20,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                        Text('${c.jumlahItem.value} Item pesanan',
                            style: TextStyle(fontSize: 11, color: Warna.grey))
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 1.0,
              child: Container(
                padding: EdgeInsets.fromLTRB(22, 5, 22, 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pembayaran :',
                      style: TextStyle(color: Colors.amber, fontSize: 12),
                    ),
                    Padding(padding: EdgeInsets.only(top: 11)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: Get.width * 0.9,
                          child: Text(
                            'Rp. ${c.hargaKeranjang.value},-',
                            style: TextStyle(
                                color: Warna.grey,
                                fontSize: 20,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                        Text(' Pengiriman : ${c.pilihanKurir.value}',
                            style: TextStyle(fontSize: 11, color: Warna.grey))
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
                                'Cash on Delivery',
                                style: TextStyle(
                                    color: Warna.grey,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                            Text('Pembayaran tunai saat barang tiba',
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
      if (c.saldoInt.value >= c.hargaKeranjang.value) {
        swCod.value = !newVal;
        swSaldo.value = newVal;
        if (newVal == true) {
          metodeBayarOK.value = 'saldo';
        } else {
          metodeBayarOK.value = 'cod';
        }
      } else {
        Get.snackbar('Saldo Tidak Cukup',
            'Sepertinya saldo kamu tidak mencukupi untuk melakukan pembayaran menggunakan saldo',
            colorText: Colors.black, snackPosition: SnackPosition.BOTTOM);
      }
    } else if (pilih == 'cod') {
      swCod.value = newVal;
      swSaldo.value = !newVal;
      if (newVal == true) {
        metodeBayarOK.value = 'cod';
      } else {
        metodeBayarOK.value = 'saldo';
      }
    }
  }

  void prosesPesananSaya() async {
    if (metodeBayarOK.value == 'cod') {
      kirimBelanjaCOD();
    } else if (metodeBayarOK.value == 'saldo') {
      kirimBelanjaNowSaldo();
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
      "sign": signature,
      "package": c.packageName
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

  kirimBelanjaNowSaldo() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var barangPesanan = jsonEncode(c.keranjangMakan);
    var jenisPengiriman = c.pilihanKurir.value;
    var metodeBayar = metodeBayarOK.value;

    var latitude = c.latitude.value;
    var longitude = c.longitude.value;
    var idOutlet = c.idOutletpadakeranjangMakan.value;
    var ongkir = c.ongkirMakan.value;
    var alamat = c.alamatKirim.value;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid" ,"alamat":"$alamat","ongkir":"$ongkir","idOutlet":"$idOutlet","order":"$barangPesanan","pengiriman":"$jenisPengiriman","metode":"$metodeBayar","lat":"$latitude","long":"$longitude"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLmakan}/mobileAppsUser/kirimOrderSamakanSaldov2');

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
      } else if (hasil['status'] == 'Aplikator Maintenance') {
        Get.snackbar('Sedang Gangguan',
            'Maaf saat ini pembayaran menggunakan saldo sedang gangguan, coba gunakan metode lain');
      } else {
        Get.snackbar('Gagal Pembayaran Via Saldo',
            'Maaf saat ini pembayaran menggunakan saldo sedang gangguan, coba gunakan metode lain');
      }
    }
  }

  void kirimBelanjaCOD() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var barangPesanan = jsonEncode(c.keranjangMakan);
    var jenisPengiriman = c.pilihanKurir.value;
    var metodeBayar = metodeBayarOK.value;
    var latitude = c.latitude.value;
    var longitude = c.longitude.value;
    var idOutlet = c.idOutletPilihan.value;
    //c.idOutletpadakeranjangMakan.value;
    var ongkir = c.ongkirMakan.value;
    var alamat = c.alamatKirim.value;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","alamat":"$alamat","ongkir":"$ongkir","idOutlet":"$idOutlet","order":"$barangPesanan","pengiriman":"$jenisPengiriman","metode":"$metodeBayar","lat":"$latitude","long":"$longitude"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLmakan}/mobileAppsUser/kirimOrderSamakanCODv2');

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
        c.iddrivermakan.value = hasil['idDriver'];
        c.kodetransaksimakan.value = hasil['kodetrx'];

        var metode = hasil['metode'];
        if (metode == 'SSIK') {
          Get.offAll(() => Dashboardku());
          c.indexTabPesanan.value = 0;
          Get.to(() => Pesananku());
        } else if (metode == 'AMBIL SENDIRI') {
          //ARAHKAN KE LIST DAFTAR
          Get.offAll(() => Dashboardku());
          c.indexTabPesanan.value = 0;
          Get.to(() => Pesananku());
        } else if (metode == 'INTEGRASI') {
          //ARAHKAN KE LIST DAFTAR
          Get.offAll(() => Dashboardku());
          c.indexTabPesanan.value = 0;
          Get.to(() => Pesananku());
        } else {
          //ARAHKAN KE LIST DAFTAR

          Get.offAll(() => Dashboardku());
          c.indexTabPesanan.value = 0;
          Get.to(() => Pesananku());
        }
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
                    clearDataKeranjang();
                    c.pilihanKurir.value = '';
                    Get.offAll(() => Dashboardku());

                    c.indexTabPesanan.value = 0;
                    Get.to(() => Pesananku());
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
            'Pembayaran Belanja Makanan Online',
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

  void clearDataKeranjang() {
    //clearkan data pesanan
    Box dbbox = Hive.box<String>('sasukaDB');
    metodeBayarOK.value = '';
    c.latitude.value = double.parse(dbbox.get('latLogin'));
    c.longitude.value = double.parse(dbbox.get('longLogin'));
    c.ongkirMakan.value = 0;
    c.alamatKirim.value = '';

    //clearkan keranjang
    c.idOutletpadakeranjangMakan.value = '0';
    c.jumlahItem.value = 0;
    c.hargaKeranjang.value = 0;
    c.keranjangMakan.clear();
    c.idOutletPilihan.value = '';
    c.namaOutlet.value = '';
    c.namaoutletpadakeranjang.value = 'Pesanan kamu';
    c.namaPreview.value = '';
    c.gambarPreview.value = '';
    c.gambarPreviewhiRess.value = '';
    c.namaoutletPreview.value = '';
    c.hargaPreview.value = '';
    c.lokasiPreview.value = '';
    c.itemidPreview.value = 0;
    c.deskripsiPreview.value = '';
    c.pilihanKurir.value = '';
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

    var url = Uri.parse('${c.baseURL}/mobileApps/paymentMakanan');

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
        clearDataKeranjang();
        c.pilihanKurir.value = '';
        Get.offAll(() => Dashboardku());
        c.indexTabPesanan.value = 0;
        Get.to(() => Pesananku());
      } else if (hasil['status'] == 'saldo apk pada dcn kosong') {
        c.pilihanKurir.value = '';
        Get.offAll(() => Dashboardku());
        c.indexTabPesanan.value = 0;
        Get.to(() => Pesananku());
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
            clearDataKeranjang();
            c.pilihanKurir.value = '';
            Get.offAll(() => Dashboardku());
            c.indexTabPesanan.value = 0;
            Get.to(() => Pesananku());
          },
        )..show();
      }
    }
  }
}
