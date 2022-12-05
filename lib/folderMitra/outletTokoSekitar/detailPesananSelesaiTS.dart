import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as https;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import 'pesananTS.dart';

class DetailBelanjaanSelesaiTS extends StatefulWidget {
  DetailBelanjaanSelesaiTS({this.kodePesanan});
  final String kodePesanan;

  @override
  _DetailBelanjaanSelesaiTSState createState() =>
      _DetailBelanjaanSelesaiTSState();
}

class _DetailBelanjaanSelesaiTSState extends State<DetailBelanjaanSelesaiTS> {
  final c = Get.find<ApiService>();
  var myGroup = AutoSizeGroup();

  bool dataSiap = false;
  var namaoutlet = ''.obs;
  var jumlahpesanan = ''.obs;
  var ongkoskirim = ''.obs;
  var totalpesanan = ''.obs;
  var tanggal = ''.obs;
  var kode = ''.obs;
  var pembayaran = ''.obs;
  var expedisi = ''.obs;
  var tahapanstatus = ''.obs;
  var detailTransfer = [];
  var showButton = true.obs;
  var integrasi = false.obs;
  var namaKurir = '';

  @override
  void initState() {
    super.initState();
    rekapBelanjadanAlamat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.warnautama,
        title: Text('Detail Pesanan Selesai'),
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.grey[200],
            padding: EdgeInsets.fromLTRB(22, 22, 22, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaksi',
                      style: TextStyle(color: Warna.grey),
                    ),
                    Obx(() => Column(
                          children: [
                            Text(
                              kode.value,
                              style: TextStyle(
                                  color: Warna.warnautama,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              tanggal.value,
                              style: TextStyle(color: Warna.grey, fontSize: 11),
                            ),
                          ],
                        )),
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: Colors.grey[200],
            padding: EdgeInsets.fromLTRB(22, 0, 22, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status',
                      style: TextStyle(color: Warna.grey),
                    ),
                    SizedBox(
                      width: Get.width * 0.6,
                      child: Obx(
                        () => Text(
                          tahapanstatus.value,
                          overflow: TextOverflow.clip,
                          maxLines: 3,
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Warna.grey, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 5, bottom: 11),
            height: 7,
            color: Colors.grey[200],
          ),
          Container(
            padding: EdgeInsets.fromLTRB(22, 0, 22, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nama Pemesan',
                      style: TextStyle(color: Warna.grey),
                    ),
                    Obx(() => Text(
                          namaoutlet.value,
                          style: TextStyle(
                              color: Warna.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        )),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(22, 0, 22, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Harga Pesanan :',
                      style: TextStyle(color: Warna.grey),
                    ),
                    Obx(() => Text(
                          jumlahpesanan.value,
                          style: TextStyle(color: Warna.grey, fontSize: 16),
                        )),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(22, 0, 22, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ongkos Kirim',
                      style: TextStyle(color: Warna.grey),
                    ),
                    Obx(() => Text(
                          ongkoskirim.value,
                          style: TextStyle(color: Warna.grey, fontSize: 16),
                        )),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(22, 0, 22, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(color: Warna.grey),
                    ),
                    Obx(() => Text(
                          totalpesanan.value,
                          style: TextStyle(
                              color: Warna.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        )),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 11, bottom: 11),
            height: 7,
            color: Colors.grey[200],
          ),
          Container(
            padding: EdgeInsets.fromLTRB(22, 0, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pembayaran',
                      style: TextStyle(color: Warna.grey),
                    ),
                    RawMaterialButton(
                      onPressed: () {},
                      constraints: BoxConstraints(),
                      elevation: 0,
                      fillColor: Colors.green,
                      child: Obx(() => Text(
                            pembayaran.value,
                            style: TextStyle(color: Warna.putih, fontSize: 16),
                          )),
                      padding: EdgeInsets.fromLTRB(14, 1, 14, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 7,
            color: Colors.grey[200],
          ),
          Container(
            padding: EdgeInsets.fromLTRB(22, 0, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Expedisi / Pengiriman',
                      style: TextStyle(color: Warna.grey),
                    ),
                    RawMaterialButton(
                      onPressed: () {},
                      constraints: BoxConstraints(),
                      elevation: 0,
                      fillColor: Colors.blue,
                      child: Obx(() => Text(
                            expedisi.value,
                            style: TextStyle(color: Warna.putih, fontSize: 16),
                          )),
                      padding: EdgeInsets.fromLTRB(14, 1, 14, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          (integrasi.value == true)
              ? Container(
                  padding: EdgeInsets.fromLTRB(22, 7, 22, 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Dikirim Oleh Kurir :',
                        style: TextStyle(color: Warna.grey),
                      ),
                      Text(
                        namaKurir,
                        style: TextStyle(
                            color: Warna.grey, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )
              : Container(),
          Container(
            height: 7,
            color: Colors.grey[200],
          ),
          Container(
            padding: EdgeInsets.fromLTRB(22, 11, 22, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order :',
                      style: TextStyle(color: Warna.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          (dataSiap == true) ? listdaftar() : Container()
        ],
      ),
    );
  }

  rekapBelanjadanAlamat() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var kodetrx = widget.kodePesanan;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","kodetrx":"$kodetrx"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLtokosekitar}/mobileAppsOutlet/detailBelanjaanTokoSekitarSelesai');

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
        var transaksi = hasil['data'];
        namaoutlet.value = transaksi[0];
        jumlahpesanan.value = transaksi[1];
        ongkoskirim.value = transaksi[2];
        totalpesanan.value = transaksi[3];
        kode.value = transaksi[4];
        tanggal.value = transaksi[5];
        pembayaran.value = transaksi[8];
        expedisi.value = transaksi[9];
        tahapanstatus.value = transaksi[6];

        dataBarang = hasil['order'];

        //chat detail
        var chat = hasil['chat'];
        c.idChatLawan.value = chat[0];
        c.namaChatLawan.value = chat[1];
        c.fotoChatLawan.value = chat[2];

        if (mounted) {
          setState(() {
            integrasi.value = hasil['integrasi'];
            namaKurir = hasil['namaKurir'];

            dataSiap = true;
          });
        }
      }
    }
  }

  List<Container> listdatabarang = [];
  List dataBarang = [];

  listdaftar() {
    if (dataBarang.length > 0) {
      for (var i = 0; i < dataBarang.length; i++) {
        var item = dataBarang[i];
        var namamakanan = item[0];
        var quantity = item[1];
        var hargasatuan = item[2];
        var hargajumlah = item[3];
        var pic = item[4];

        listdatabarang.add(
          Container(
              // width: Get.width * 0.45,
              child: GestureDetector(
            onTap: () {},
            child: Card(
                elevation: 0.2,
                //color: Colors.lightGreen[50],
                margin: EdgeInsets.all(5),
                child: Container(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CachedNetworkImage(
                        imageUrl: pic,
                        width: Get.width * 0.15,
                        height: Get.width * 0.15,
                      ),
                      Padding(padding: EdgeInsets.only(left: 11)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: Get.width * 0.7,
                            child: Text(
                              namamakanan, //nama makanan
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(fontSize: 20, color: Warna.grey),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 5)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$quantity x $hargasatuan',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style:
                                    TextStyle(fontSize: 16, color: Warna.grey),
                              ),
                              Padding(padding: EdgeInsets.only(left: 55)),
                              Text(
                                '$hargajumlah',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style:
                                    TextStyle(fontSize: 16, color: Warna.grey),
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          )),
        );
      }
    }
    return Column(
      children: listdatabarang,
    );
  }

  void siapKirimPesanan(String kodetrx) async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var outletcode = 'MK-' + pid;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","kodetrx":"$kodetrx","outletcode":"$outletcode"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/sasuka/pesananSiapKirimFM');

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
        if (mounted) {
          AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.success,
            animType: AnimType.rightSlide,
            title: 'Siap Kirim',
            desc: 'Pesanan telah di masukan ke folder Siap Kirim,',
            btnOkText: 'OK SIAP',
            btnOkOnPress: () {
              c.selectedIndexOrderTSKU.value = 2;
              Get.back();
              Get.back();
              Get.to(() => PesananTS());
            },
          )..show();
        }
      } else {
        Get.back();
      }
    }
  }
}