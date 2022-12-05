import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:http/http.dart' as https;
import '../../folderUmum/chat/view/chatDetailPage.dart';
import '/dashboard/view/dashboard.dart';
import '../pesanan/pesanan.dart';

class PembayaranTS extends StatefulWidget {
  @override
  _PembayaranTSState createState() => _PembayaranTSState();
}

class _PembayaranTSState extends State<PembayaranTS> {
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

  var namaToko = 'Toko Sekitar'.obs;
  var alamatToko = ''.obs;
  var logoToko = ''.obs;
  var cod = 0.obs;
  var bukatutup = ''.obs;
  var payCode = '';

  @override
  void initState() {
    super.initState();
    cekNamaToko();
    cekSaldokuDulu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pembayaran Belanja Toko'),
        backgroundColor: Warna.warnautama,
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(5),
        height: Get.height * 0.08,
        child: RawMaterialButton(
          onPressed: () {
            if (bukatutup.value == 'Buka') {
              prosesPesananSaya();
            } else if (bukatutup.value == 'Tutup') {
              var j = 'TOKO SEDANG TUTUP';
              var s =
                  'Saat ini toko sedang tutup, pesanan kamu akan diproses setelah toko ini buka, atau kamu bisa chat kepada outlet untuk informasi pesanan kamu';
              notifikasiTokoTutup(j, s);
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
                    'Proses Pesanan Saya',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        color: Warna.putih),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Obx(() => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: Get.width * 0.7,
                                      child: Text(
                                        namaToko.value,
                                        style: TextStyle(
                                            color: Warna.grey,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    SizedBox(
                                      width: Get.width * 0.7,
                                      child: Text(
                                        alamatToko.value,
                                        style: TextStyle(
                                            color: Warna.grey,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ),
                                    Text(
                                        '${c.jumlahItemTOSEK.value} Item pesanan',
                                        style: TextStyle(
                                            fontSize: 11, color: Warna.grey))
                                  ],
                                )),
                            Obx(() => CachedNetworkImage(
                                width: Get.width * 0.12,
                                height: Get.width * 0.12,
                                imageUrl: logoToko.value,
                                errorWidget: (context, url, error) {
                                  return Icon(Icons.shopping_cart,
                                      size: 22, color: Warna.warnautama);
                                })),
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
                                'Rp. ${c.hargaKeranjangTOSEK.value},-',
                                style: TextStyle(
                                    color: Warna.grey,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(' Pengiriman : ${c.pilihanKurirTOSEK.value}',
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
                        Obx(() => Container(
                              child: (cod.value == 1)
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
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w300),
                                              ),
                                            ),
                                            Text(
                                                'Pembayaran tunai saat barang tiba',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: Warna.grey))
                                          ],
                                        ),
                                        Checkbox(
                                          value: swCod.value,
                                          onChanged: (newValue) {
                                            pilihMetodeBayar('COD', newValue);
                                          },
                                        ),
                                      ],
                                    )
                                  : Container(),
                            )),
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
                                        fontSize: 18,
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
                                    pilihMetodeBayar('SALDO SS', newValue);
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
                                        fontSize: 18,
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
                                    Get.snackbar('Segera Hadir...!',
                                        'Fitur pembayaran melalui Transfer dan VA akan segera hadir');
                                    //pilihMetodeBayar('transfer', newValue);
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
                              Row(
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
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ),
                                      Text('SASUKA ONLINE INDONESIA',
                                          style: TextStyle(
                                              fontSize: 11, color: Warna.grey))
                                    ],
                                  ),
                                  Obx(() => Checkbox(
                                        value: bankMandiri.value,
                                        onChanged: (newValue) {
                                          pilihBank('MANDIRI', newValue);
                                        },
                                      )),
                                ],
                              ),
                              Padding(padding: EdgeInsets.only(top: 11)),
                              Row(
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
                                              fontSize: 18,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ),
                                      Text('SASUKA ONLINE INDONESIA',
                                          style: TextStyle(
                                              fontSize: 11, color: Warna.grey))
                                    ],
                                  ),
                                  Obx(() => Checkbox(
                                        value: bankBri.value,
                                        onChanged: (newValue) {
                                          pilihBank('BRI', newValue);
                                        },
                                      )),
                                ],
                              ),
                              Padding(padding: EdgeInsets.only(top: 11)),
                              Row(
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
                                              fontSize: 18,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ),
                                      Text('SASUKA ONLINE INDONESIA',
                                          style: TextStyle(
                                              fontSize: 11, color: Warna.grey))
                                    ],
                                  ),
                                  Obx(() => Checkbox(
                                        value: bankBni.value,
                                        onChanged: (newValue) {
                                          pilihBank('BNI', newValue);
                                        },
                                      )),
                                ],
                              ),
                              Padding(padding: EdgeInsets.only(top: 11)),
                              Row(
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
                                              fontSize: 18,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ),
                                      Text('SASUKA ONLINE INDONESIA',
                                          style: TextStyle(
                                              fontSize: 11, color: Warna.grey))
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
    if (pilih == 'SALDO SS') {
      if (c.saldoInt.value >= c.hargaKeranjangTOSEK.value) {
        if (newVal == true) {
          metodeBayarOK.value = 'SALDO SS';
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
    } else if (pilih == 'COD') {
      if (newVal == true) {
        metodeBayarOK.value = 'COD';
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
    if (c.ekspedisiNasionalTOSEK.value == true) {
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
          kirimBelanjaTokoSekitarViaTransfer();
        }
      } else if (metodeBayarOK.value == 'SALDO SS') {
        kirimBelanjaTokoSekitarViaSaldo();
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
      if (metodeBayarOK.value == 'COD') {
        kirimBelanjaTokoSekitarViaCOD();
      } else if (metodeBayarOK.value == 'SALDO SS') {
        kirimBelanjaTokoSekitarViaSaldo();
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
          kirimBelanjaTokoSekitarViaTransfer();
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

  kirimBelanjaTokoSekitarViaSaldo() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var tokenUser = dbbox.get('apiToken');
    var barangPesanan = c.keranjangTOSEK;
    var jenisPengiriman = c.pilihanKurirTOSEK.value;
    var latitude = c.latitude.value;
    var longitude = c.longitude.value;
    var idOutlet = c.idOutletpadakeranjangTOSEK.value;
    var ongkir = c.ongkirTOSEK.value;
    var alamat = c.alamatKirimTOSEK.value;
    var metodeBayar = metodeBayarOK.value;
    if (metodeBayar == 'transfer') {
      metodeBayar = bankPilihan.value;
    }
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","tokenUser":"$tokenUser","alamat":"$alamat","ongkir":"$ongkir","idOutlet":"$idOutlet","order":"$barangPesanan","pengiriman":"$jenisPengiriman","metode":"$metodeBayar","lat":"$latitude","long":"$longitude"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLtokosekitar}/mobileAppsUser/requestOrderTSSaldo');

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
      } else {
        Get.snackbar('PROSES GAGAL', hasil['message'],
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 5));
      }
    }
  }

  kirimBelanjaTokoSekitarViaCOD() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var tokenUser = dbbox.get('apiToken');
    var barangPesanan = c.keranjangTOSEK;
    var jenisPengiriman = c.pilihanKurirTOSEK.value;
    var latitude = c.latitude.value;
    var longitude = c.longitude.value;
    var idOutlet = c.idOutletpadakeranjangTOSEK.value;
    var ongkir = c.ongkirTOSEK.value;
    var alamat = c.alamatKirimTOSEK.value;
    var metodeBayar = metodeBayarOK.value;
    if (metodeBayar == 'transfer') {
      metodeBayar = bankPilihan.value;
    }
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","tokenUser":"$tokenUser","alamat":"$alamat","ongkir":"$ongkir","idOutlet":"$idOutlet","order":"$barangPesanan","pengiriman":"$jenisPengiriman","metode":"$metodeBayar","lat":"$latitude","long":"$longitude"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLtokosekitar}/mobileAppsUser/requestOrderTS');

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
        //var kodet = hasil['kodeTransaksi'];

      } else {
        Get.snackbar('PROSES GAGAL', hasil['message'],
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 5));
      }
    }
  }

  kirimBelanjaTokoSekitarViaTransfer() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var tokenUser = dbbox.get('apiToken');
    var barangPesanan = c.keranjangTOSEK;
    var jenisPengiriman = c.pilihanKurirTOSEK.value;
    var latitude = c.latitude.value;
    var longitude = c.longitude.value;
    var idOutlet = c.idOutletpadakeranjangTOSEK.value;
    var ongkir = c.ongkirTOSEK.value;
    var alamat = c.alamatKirimTOSEK.value;
    var metodeBayar = metodeBayarOK.value;
    if (metodeBayar == 'transfer') {
      metodeBayar = bankPilihan.value;
    }
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","tokenUser":"$tokenUser","alamat":"$alamat","ongkir":"$ongkir","idOutlet":"$idOutlet","order":"$barangPesanan","pengiriman":"$jenisPengiriman","metode":"$metodeBayar","lat":"$latitude","long":"$longitude"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLtokosekitar}/mobileAppsUser/requestOrderTS');

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
        //var kodet = hasil['kodeTransaksi'];
        c.kodePembayaranTOSEK.value = hasil['kodeTransaksi'];
      } else {
        Get.snackbar('PROSES GAGAL', hasil['message'],
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 5));
      }
    }
  }

  final controllerPinLokal = TextEditingController();
  pilihBank(String s, bool newValue) {
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

  cekNamaToko() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var idOutlet = c.idOutletPilihanTOSEK.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","idOutlet":"$idOutlet"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLtokosekitar}/mobileAppsUser/cekNamaToko');

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
        namaToko.value = hasil['namaOutlet'];
        alamatToko.value = hasil['alamat'];
        logoToko.value = hasil['foto'];
        cod.value = hasil['cod'];
        //---------------------chat
        c.idChatLawan.value = hasil['idChat'];
        c.namaChatLawan.value = hasil['namaOutlet'];
        c.fotoChatLawan.value = hasil['foto'];
        bukatutup.value = hasil['bukatutup'];
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

  kirimBelanjaCOD() async {
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
                    c.indexTabPesanan.value = 3;
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
            'Pembayaran Belanja Toko Sekitar',
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
                    bayarTokoSekitarviaSaldo(controllerPin.text);
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
    //clearkan data pesanan
    metodeBayarOK.value = '';
    c.latitude.value = double.parse(dbbox.get('latLogin'));
    c.longitude.value = double.parse(dbbox.get('longLogin'));
    c.ongkirTOSEK.value = 0;
    c.alamatKirimTOSEK.value = '';
    c.hargaKeranjangTOSEKTotal.value = 0;

    //CLEARKAN KERANJANG
    c.idOutletpadakeranjangTOSEK.value = 0;
    c.jumlahItemTOSEK.value = 0;
    c.hargaKeranjangTOSEK.value = 0;
    c.jumlahBarangTOSEK.value = 0;
    c.keranjangTOSEK.clear();
    c.idOutletPilihanTOSEK.value = 0;
    c.namaoutletpadakeranjangTOSEK.value = 'dalam keranjangmu';
    c.namaOutletTOSEK.value = '';
    c.tagIdTOSEKC.value = '';
    c.namaTOSEKC.value = '';
    c.gambarTOSEKC.value = '';
    c.namaoutletTOSEKC.value = '';
    c.hargaTOSEKC.value = '';
    c.lokasiTOSEKC.value = '';
    c.deskripsiTOSEKC.value = '';
    c.hargaIntTOSEKC.value = 0;
    c.idOutletTOSEKC.value = '';
    c.itemIdTOSEKC.value = '';
    c.pilihanKurir.value = '';
  }

  void bayarTokoSekitarviaSaldo(pin) async {
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

    var url = Uri.parse('${c.baseURL}/mobileApps/paymentTokoSekitar');

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
        c.indexTabPesanan.value = 3;
        Get.to(() => Pesananku());
      } else if (hasil['status'] == 'saldo apk pada dcn kosong') {
        c.pilihanKurir.value = '';
        Get.offAll(() => Dashboardku());
        c.indexTabPesanan.value = 3;
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
            c.indexTabPesanan.value = 3;
            Get.to(() => Pesananku());
          },
        )..show();
      }
    }
  }

  void notifikasiTokoTutup(String j, String s) {
    AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        title: j,
        desc: s,
        btnCancelText: 'Chat',
        btnCancelColor: Colors.amber,
        btnCancelOnPress: () {
          Get.to(() => ChatDetailPage());
        },
        btnOkText: 'Teruskan',
        btnOkColor: Warna.warnautama,
        btnOkOnPress: () {
          prosesPesananSaya();
        })
      ..show();
  }
}
