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
import '../payment/payment.dart';
import '../pesanan/pesanan.dart';

class PembayaranMarketplace extends StatefulWidget {
  @override
  _PembayaranMarketplaceState createState() => _PembayaranMarketplaceState();
}

class _PembayaranMarketplaceState extends State<PembayaranMarketplace> {
  final c = Get.find<ApiService>();
  final controllerPinNas = TextEditingController();
  final controllerPinLok = TextEditingController();

  var swCod = false.obs;
  var swSaldo = false.obs;
  var swTransfer = false.obs;

  var bankMandiri = false.obs;
  var bankBri = false.obs;
  var bankBca = false.obs;
  var bankBni = false.obs;
  var bankPilihan = ''.obs;
  var transferBank = false.obs;
  var metodeBayarOK = ''.obs;
  var payCode = '';

  var tampilkanMandiri = false;
  var tampilkanBri = false;
  var tampilkanBni = false;
  var tampilkanBCA = false;
  var tampilkanBSI = false;

  @override
  void initState() {
    super.initState();
    cekSaldokuDulu();
    cekBankTersedia();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pembayaran Marketplace'),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
      body: ListView(
        children: [
          Container(
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
                                c.namaoutletpadakeranjangMP.value,
                                style: TextStyle(
                                    color: Warna.grey,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                            Text('${c.jumlahItemMP.value} Item pesanan',
                                style:
                                    TextStyle(fontSize: 11, color: Warna.grey))
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
                                'Rp. ${c.hargaKeranjangMPTotal.value},-',
                                style: TextStyle(
                                    color: Warna.grey,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                            Text(' Pengiriman : ${c.pilihanKurirMP.value}',
                                style:
                                    TextStyle(fontSize: 11, color: Warna.grey))
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
                        (c.ekspedisiNasional.value == false)
                            ? Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      Text(
                                          'Pembayaran tunai saat barang diterima',
                                          style: TextStyle(
                                              fontSize: 11, color: Warna.grey))
                                    ],
                                  ),
                                  Obx(() => Checkbox(
                                        value: swCod.value,
                                        onChanged: (newValue) {
                                          pilihMetodeBayar('cod', newValue);
                                        },
                                      )),
                                ],
                              )
                            : Container(),
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
                                    style: TextStyle(
                                        fontSize: 11, color: Warna.grey))
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
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: Get.width * 0.7,
                                  child: Text(
                                    'Transfer Bank / ATM',
                                    style: TextStyle(
                                        color: Warna.grey,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w300),
                                  ),
                                ),
                                Text('Transfer tunai, MBanking, ATM bersama',
                                    style: TextStyle(
                                        fontSize: 11, color: Warna.grey))
                              ],
                            ),
                            Obx(() => Checkbox(
                                  value: swTransfer.value,
                                  onChanged: (newValue) {
                                    pilihMetodeBayar('transfer', newValue);
                                  },
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                (transferBank.value == true)
                    ? Card(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(22, 5, 22, 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pilih bank tujuan transfer :',
                                style: TextStyle(
                                    color: Colors.amber, fontSize: 12),
                              ),
                              Padding(padding: EdgeInsets.only(top: 11)),
                              (tampilkanMandiri == true)
                                  ? Row(
                                      children: [
                                        Image.network(
                                          'https://sasuka.online/icon/bank/Bank Mandiri.png',
                                          width: Get.width * 0.15,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: Get.width * 0.55,
                                              child: Text(
                                                'Mandiri',
                                                style: TextStyle(
                                                    color: Warna.grey,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w300),
                                              ),
                                            ),
                                            Text('${c.namaAplikasi}',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: Warna.grey))
                                          ],
                                        ),
                                        Obx(() => Checkbox(
                                              value: bankMandiri.value,
                                              onChanged: (newValue) {
                                                pilihBank('MANDIRI', newValue);
                                              },
                                            )),
                                      ],
                                    )
                                  : Padding(padding: EdgeInsets.only(top: 11)),
                              (tampilkanBri == true)
                                  ? Row(
                                      children: [
                                        Image.network(
                                          'https://sasuka.online/icon/bank/Bank Rakyat Indonesia.png',
                                          width: Get.width * 0.15,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: Get.width * 0.55,
                                              child: Text(
                                                'BRI',
                                                style: TextStyle(
                                                    color: Warna.grey,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w300),
                                              ),
                                            ),
                                            Text('${c.namaAplikasi}',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: Warna.grey))
                                          ],
                                        ),
                                        Obx(() => Checkbox(
                                              value: bankBri.value,
                                              onChanged: (newValue) {
                                                pilihBank('BRI', newValue);
                                              },
                                            )),
                                      ],
                                    )
                                  : Padding(padding: EdgeInsets.only(top: 11)),
                              (tampilkanBni == true)
                                  ? Row(
                                      children: [
                                        Image.network(
                                          'https://sasuka.online/icon/bank/Bank Negara Indonesia (BNI).png',
                                          width: Get.width * 0.15,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: Get.width * 0.55,
                                              child: Text(
                                                'BNI',
                                                style: TextStyle(
                                                    color: Warna.grey,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w300),
                                              ),
                                            ),
                                            Text('${c.namaAplikasi}',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: Warna.grey))
                                          ],
                                        ),
                                        Obx(() => Checkbox(
                                              value: bankBni.value,
                                              onChanged: (newValue) {
                                                pilihBank('BNI', newValue);
                                              },
                                            )),
                                      ],
                                    )
                                  : Padding(padding: EdgeInsets.only(top: 11)),
                              (tampilkanBCA == true)
                                  ? Row(
                                      children: [
                                        Image.network(
                                          'https://sasuka.online/icon/bank/Bank Central Asia (BCA).png',
                                          width: Get.width * 0.15,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: Get.width * 0.55,
                                              child: Text(
                                                'BCA',
                                                style: TextStyle(
                                                    color: Warna.grey,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w300),
                                              ),
                                            ),
                                            Text('${c.namaAplikasi}',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: Warna.grey))
                                          ],
                                        ),
                                        Obx(() => Checkbox(
                                              value: bankBca.value,
                                              onChanged: (newValue) {
                                                pilihBank('BCA', newValue);
                                              },
                                            )),
                                      ],
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(top: 1),
                                    )
                            ],
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void pilihMetodeBayar(String pilih, newVal) {
    if (pilih == 'saldo') {
      if (c.saldoInt.value >= c.hargaKeranjangMP.value) {
        if (newVal == true) {
          metodeBayarOK.value = 'saldo';
          swCod.value = !newVal;
          swSaldo.value = newVal;
          swTransfer.value = !newVal;
          transferBank.value = false;
        } else {
          metodeBayarOK.value = '';
          swSaldo.value = false;
          transferBank.value = false;
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
        swTransfer.value = !newVal;
        transferBank.value = false;
      } else {
        metodeBayarOK.value = '';
        swCod.value = false;
        transferBank.value = false;
      }
    } else if (pilih == 'transfer') {
      if (newVal == true) {
        metodeBayarOK.value = 'transfer';
        transferBank.value = true;
        swTransfer.value = newVal;
        swSaldo.value = !newVal;
        swCod.value = !newVal;
      } else {
        metodeBayarOK.value = '';
        swTransfer.value = false;
        transferBank.value = false;
      }
    }
    setState(() {});
  }

  void prosesPesananSaya() async {
    if (c.ekspedisiNasional.value == true) {
      if (metodeBayarOK.value == 'transfer') {
        if (bankPilihan.value == '') {
          AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.noHeader,
            animType: AnimType.rightSlide,
            title: 'Bank belum dipilih',
            desc:
                'Opps... sepertinya kamu belum memilih bank tujuan transfer yang diinginkan',
            btnCancelText: 'OK SIAP',
            btnCancelOnPress: () {},
          )..show();
        } else {
          kirimBelanjaNasionalTransfer();
        }
      } else if (metodeBayarOK.value == 'saldo') {
        kirimBelanjaNasionalSaldo();
        //pinDibutuhkanNasional(detailbayar);
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
    } else {
      if (metodeBayarOK.value == 'cod') {
        kirimBelanjaLokalCOD();
      } else if (metodeBayarOK.value == 'saldo') {
        kirimBelanjaLokalSaldo();
      } else if (metodeBayarOK.value == 'transfer') {
        if (bankPilihan.value == '') {
          AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.noHeader,
            animType: AnimType.rightSlide,
            title: 'Bank belum dipilih',
            desc:
                'Opps... sepertinya kamu belum memilih bank tujuan transfer yang diinginkan',
            btnCancelText: 'OK SIAP',
            btnCancelOnPress: () {},
          )..show();
        } else {
          kirimBelanjaLokalTransfer();
        }
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

  void cekBankTersedia() async {
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

    var url = Uri.parse('${c.baseURL}/mobileApps/cekBankTersedia');

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
        if (hasil['mandiri'] != '') {
          tampilkanMandiri = true;
        }
        if (hasil['bri'] != '') {
          tampilkanBri = true;
        }
        if (hasil['bni'] != '') {
          tampilkanBni = true;
        }
        if (hasil['bca'] != '') {
          tampilkanBCA = true;
        }
        if (hasil['bsi'] != '') {
          tampilkanBSI = true;
        }
        setState(() {});
      }
    }
  }

  kirimBelanjaLokalCOD() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var barangPesanan = c.keranjangMP;
    var jenisPengiriman = c.pilihanKurirMP.value;
    var metodeBayar = metodeBayarOK.value;
    var latitude = c.latitude.value;
    var longitude = c.longitude.value;
    var idOutlet = c.idOutletpadakeranjangMP.value;
    var ongkir = c.ongkirMP.value;
    var alamat = c.alamatKirimMP.value;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","alamat":"$alamat","ongkir":"$ongkir","idOutlet":"$idOutlet","order":"$barangPesanan","pengiriman":"$jenisPengiriman","metode":"$metodeBayar","lat":"$latitude","long":"$longitude"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLmp}/mobileAppsUser/kirimBelanjaLokalCODMarketplace');

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
        clearDataKeranjang();
        c.pilihanKurir.value = '';
        c.indexTabPesanan.value = 2;
        Get.offAll(() => Dashboardku());
        Get.to(() => Pesananku());
      } else if (hasil['status'] == 'Aplikator Maintenance') {
        Get.snackbar('Sedang Gangguan',
            'Maaf saat ini pembayaran menggunakan COD sedang gangguan, coba gunakan metode lain');
      } else {
        Get.snackbar('Gagal Pembayaran Via COD',
            'Maaf saat ini pembayaran menggunakan COD sedang gangguan, coba gunakan metode lain');
      }
    }
  }

  kirimBelanjaLokalSaldo() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');

    var barangPesanan = c.keranjangMP;
    var jenisPengiriman = c.pilihanKurirMP.value;
    var metodeBayar = metodeBayarOK.value;
    var latitude = c.latitude.value;
    var longitude = c.longitude.value;
    var idOutlet = c.idOutletpadakeranjangMP.value;
    var ongkir = c.ongkirMP.value;
    var alamat = c.alamatKirimMP.value;

    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","alamat":"$alamat","ongkir":"$ongkir","idOutlet":"$idOutlet","order":"$barangPesanan","pengiriman":"$jenisPengiriman","metode":"$metodeBayar","lat":"$latitude","long":"$longitude"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLmp}/mobileAppsUser/kirimOrderMarketplaceLokalSaldo');

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

  kirimBelanjaLokalTransfer() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var barangPesanan = c.keranjangMP;
    var jenisPengiriman = c.pilihanKurirMP.value;
    var metodeBayar = metodeBayarOK.value;
    var latitude = c.latitude.value;
    var longitude = c.longitude.value;
    var idOutlet = c.idOutletpadakeranjangMP.value;
    var ongkir = c.ongkirMP.value;
    var alamat = c.alamatKirimMP.value;
    var bankPilihanku = bankPilihan.value;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","bank":"$bankPilihanku","alamat":"$alamat","ongkir":"$ongkir","idOutlet":"$idOutlet","order":"$barangPesanan","pengiriman":"$jenisPengiriman","metode":"$metodeBayar","lat":"$latitude","long":"$longitude"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLmp}/mobileAppsUser/kirimBelanjaLokalTransferMarketplace');

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
        clearDataKeranjang();
        payCode = hasil['kodeBayar'];
        c.pilihanKurir.value = '';
        Get.offAll(() => Dashboardku());
        Get.to(() => PaymentPoint());
      } else if (hasil['status'] == 'Aplikator Maintenance') {
        Get.snackbar('Sedang Gangguan',
            'Maaf saat ini pembayaran menggunakan saldo sedang gangguan, coba gunakan metode lain');
      } else {
        Get.snackbar('Gagal Pembayaran Via Transfer',
            'Maaf saat ini pembayaran menggunakan transfer sedang gangguan, coba gunakan metode lain');
      }
    }
  }

  kirimBelanjaNasionalSaldo() async {
    EasyLoading.show(status: 'Mohon tunggu...', dismissOnTap: false);
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }

    try {
      Box dbbox = Hive.box<String>('sasukaDB');
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');

      var barangPesanan = c.keranjangMP;
      var jenisPengiriman = c.pilihanKurirMP.value;
      var metodeBayar = metodeBayarOK.value;
      var latitude = c.latitude.value;
      var longitude = c.longitude.value;
      var idOutlet = c.idOutletpadakeranjangMP.value;

      var ongkir = c.hargaexpedisiNasionalDipilih.value;
      var alamat = c.alamatKirimNasionalSaveAs.value;
      var expedisi = c.expedisiNasionalDipilih.value;
      var user = dbbox.get('loginSebagai');

      var datarequest =
          '{"pid":"$pid","expedisi":"$expedisi","alamat":"$alamat","ongkir":"$ongkir","idOutlet":"$idOutlet","order":"$barangPesanan","pengiriman":"$jenisPengiriman","metode":"$metodeBayar","lat":"$latitude","long":"$longitude"}';
      var bytes = utf8.encode(datarequest + '$token' + user);
      var signature = md5.convert(bytes).toString();

      var url = Uri.parse(
          '${c.baseURLmp}/mobileAppsUser/kirimOrderMarketplaceNasionalSaldo');

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
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar('Opps... sepertinya ada masalah',
          'Maaf seperti ada gangguan, silahkan ulangi beberapa saat lagi');
    }
  }

  kirimBelanjaNasionalTransfer() async {
    EasyLoading.show(status: 'Mohon tunggu...', dismissOnTap: false);

    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    try {
      Box dbbox = Hive.box<String>('sasukaDB');
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');

      var barangPesanan = c.keranjangMP;
      var jenisPengiriman = c.pilihanKurirMP.value;
      var metodeBayar = metodeBayarOK.value;
      var latitude = c.latitude.value;
      var longitude = c.longitude.value;
      var idOutlet = c.idOutletpadakeranjangMP.value;

      var ongkir = c.hargaexpedisiNasionalDipilih.value;
      var alamat = c.alamatKirimNasionalSaveAs.value;
      var expedisi = c.expedisiNasionalDipilih.value;
      var bankPilihanku = bankPilihan.value;
      var user = dbbox.get('loginSebagai');

      var datarequest =
          '{"pid":"$pid","bank":"$bankPilihanku","expedisi":"$expedisi","alamat":"$alamat","ongkir":"$ongkir","idOutlet":"$idOutlet","order":"$barangPesanan","pengiriman":"$jenisPengiriman","metode":"$metodeBayar","lat":"$latitude","long":"$longitude"}';
      var bytes = utf8.encode(datarequest + '$token' + user);
      var signature = md5.convert(bytes).toString();

      var url = Uri.parse(
          '${c.baseURLmp}/mobileAppsUser/kirimOrderMarketplaceNasionalTransfer');
      print(idOutlet);

      final response = await http.post(url, body: {
        "user": user,
        "appid": c.appid,
        "data_request": datarequest,
        "sign": signature,
        "package": c.packageName
      });

      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        Map<String, dynamic> hasil = jsonDecode(response.body);
        if (hasil['status'] == 'success') {
          clearDataKeranjang();
          payCode = hasil['kodeBayar'];
          c.pilihanKurir.value = '';
          Get.offAll(() => Dashboardku());
          Get.to(() => PaymentPoint());
        } else if (hasil['status'] == 'Aplikator Maintenance') {
          Get.snackbar('Sedang Gangguan',
              'Maaf saat ini pembayaran menggunakan saldo sedang gangguan, coba gunakan metode lain');
        } else {
          Get.snackbar('Gagal Pembayaran Via Transfer',
              'Maaf saat ini pembayaran menggunakan transfer sedang gangguan, coba gunakan metode lain');
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar('Gagal Pembayaran Via Transfer',
          'Maaf saat ini pembayaran menggunakan transfer sedang gangguan, coba gunakan metode lain');
    }
  }

  pinDibutuhkanLokal(detail) {
    final controllerPinLokal = TextEditingController();
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
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
            detail,
            style: TextStyle(fontSize: 14, color: Warna.grey),
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
              controller: controllerPinLokal,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.vpn_key),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
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
              if ((controllerPinLokal.text == '') ||
                  (controllerPinLokal.text.length != 6)) {
                controllerPinLokal.text = '';
                Get.back();
                AwesomeDialog(
                  context: Get.context,
                  dialogType: DialogType.noHeader,
                  animType: AnimType.rightSlide,
                  title: 'PERHATIAN !',
                  desc:
                      'Pin tidak dimasukan dengan benar, Pin hanya berisi 6 angka',
                  btnCancelText: 'OK',
                  btnCancelColor: Colors.amber,
                  btnCancelOnPress: () {},
                )..show();
              } else {
                // kirimBelanjaLokalSaldo();
              }
            },
          ),
        ],
      ),
    )..show();
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

                    c.indexTabPesanan.value = 2;
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
            'Pembayaran Belanja Marketplace',
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

  void pilihBank(String s, bool newValue) {
    bankMandiri.value = false;
    bankBri.value = false;
    bankBca.value = false;
    bankBni.value = false;
    if (s == 'MANDIRI') {
      if (newValue == true) {
        bankPilihan.value = 'MANDIRI';
        bankMandiri.value = true;
      } else {
        bankPilihan.value = '';
      }
    } else if (s == 'BRI') {
      if (newValue == true) {
        bankPilihan.value = 'BRI';
        bankBri.value = true;
      } else {
        bankPilihan.value = '';
      }
    } else if (s == 'BNI') {
      if (newValue == true) {
        bankPilihan.value = 'BNI';
        bankBni.value = true;
      } else {
        bankPilihan.value = '';
      }
    } else if (s == 'BCA') {
      if (newValue == true) {
        bankPilihan.value = 'BCA';
        bankBca.value = true;
      } else {
        bankPilihan.value = '';
      }
    }

    print(bankPilihan.value);
  }

  void clearDataKeranjang() {
    Box dbbox = Hive.box<String>('sasukaDB');
    //clearkan data pesanan
    metodeBayarOK.value = '';
    c.latitude.value = double.parse(dbbox.get('latLogin'));
    c.longitude.value = double.parse(dbbox.get('longLogin'));
    c.ongkirMP.value = 0;
    c.alamatKirimMP.value = '';
    //CLEARKAN KERANJANG
    c.idOutletpadakeranjangMP.value = '0';
    c.jumlahItemMP.value = 0;
    c.hargaKeranjangMP.value = 0;
    c.jumlahBarangMP.value = 0;
    c.keranjangMP.clear();
    c.idOutletPilihanMP.value = '';
    c.namaoutletpadakeranjangMP.value = 'dalam keranjangmu';
    c.namaOutletMP.value = '';
    c.tagIdMPC.value = '';
    c.namaMPC.value = '';
    c.gambarMPC.value = '';
    c.namaoutletMPC.value = '';
    c.hargaMPC.value = '';
    c.lokasiMPC.value = '';
    c.deskripsiMPC.value = '';
    c.hargaIntMPC.value = 0;
    c.idOutletMPC.value = '';
    c.itemIdMPC.value = '';
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

    var url = Uri.parse('${c.baseURL}/mobileApps/paymentMarketplace');

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
        c.indexTabPesanan.value = 2;
        Get.offAll(() => Dashboardku());
        Get.to(() => Pesananku());
      } else if (hasil['status'] == 'saldo apk pada dcn kosong') {
        c.pilihanKurir.value = '';
        c.indexTabPesanan.value = 2;

        Get.offAll(() => Dashboardku());
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
            c.indexTabPesanan.value = 2;
            clearDataKeranjang();
            c.pilihanKurir.value = '';
            Get.offAll(() => Dashboardku());
            Get.to(() => Pesananku());
          },
        )..show();
      }
    }
    // } catch (e) {
    //   EasyLoading.dismiss();
    //   Get.snackbar('Opps... sepertinya ada masalah',
    //       'Maaf seperti ada gangguan, silahkan ulangi beberapa saat lagi');
    // }
  }
}
