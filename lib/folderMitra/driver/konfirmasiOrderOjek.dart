//ROUTE SUDAH DIPERIKSA
import 'dart:async';
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as https;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';

import '../../../folderUmum/chat/view/chatDetailPage.dart';
import 'orderOjek.dart';

class KonfirmasiOrderOjek extends StatefulWidget {
  @override
  _KonfirmasiOrderOjekState createState() => _KonfirmasiOrderOjekState();
}

class _KonfirmasiOrderOjekState extends State<KonfirmasiOrderOjek> {
  final c = Get.find<ApiService>();
  bool dataSiap = false;
  Timer timer;
  var kodepesanan = ''.obs;
  var tahap = ''.obs;
  var namaPemesan = ''.obs;
  var idchat = ''.obs;
  var foto = 'https://sasuka.online/sasuka.online/foto/no-avatar.png'.obs;
  var tujuan = ''.obs;
  var jemput = ''.obs;
  var pembayaranVia = ''.obs;
  var tarif = ''.obs;
  var buttonKonfirmasi = ''.obs;
  var tanggal = ''.obs;
  @override
  void initState() {
    super.initState();
    rekapBelanjadanAlamat();
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.warnautama,
        title: Text('Konfirmasi Pengantaran'),
      ),
      bottomNavigationBar: Obx(() => Container(
          margin: EdgeInsets.fromLTRB(22, 8, 22, 8),
          height: Get.height * 0.06,
          child: (c.buttonTerimaOrderKurir.value == true)
              ? RawMaterialButton(
                  onPressed: () {
                    terimaPengantaranIni();
                  },
                  constraints: BoxConstraints(),
                  elevation: 1.0,
                  fillColor: Warna.warnautama,
                  child: Text(
                    'Terima Order Ini',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  padding: EdgeInsets.fromLTRB(22, 6, 22, 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(33)),
                  ),
                )
              : RawMaterialButton(
                  onPressed: () {},
                  constraints: BoxConstraints(),
                  elevation: 0,
                  fillColor: Colors.grey,
                  child: Text(
                    'Loading data ...',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  padding: EdgeInsets.fromLTRB(22, 6, 22, 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(33)),
                  ),
                ))),
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
                      'Kode Pengantaran',
                      style: TextStyle(color: Warna.grey),
                    ),
                    Obx(() => Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              kodepesanan.value,
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
                      child: Obx(() => Text(
                            tahap.value,
                            overflow: TextOverflow.clip,
                            maxLines: 3,
                            textAlign: TextAlign.right,
                            style: TextStyle(color: Warna.grey, fontSize: 16),
                          )),
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => CircleAvatar(
                        radius: Get.width * 0.1,
                        backgroundImage: NetworkImage(foto.value))),
                    SizedBox(
                      width: Get.width * 0.65,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nama Pemesan :',
                            style: TextStyle(color: Warna.grey, fontSize: 11),
                          ),
                          Obx(() => Text(
                                namaPemesan.value,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                    color: Warna.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              )),
                          Padding(padding: EdgeInsets.only(top: 11)),
                          Text(
                            'Lokasi Tujuan :',
                            style: TextStyle(color: Warna.grey, fontSize: 11),
                          ),
                          Obx(() => Text(
                                tujuan.value,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 4,
                                style: TextStyle(
                                    color: Warna.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              )),
                          Padding(padding: EdgeInsets.only(top: 11)),
                          Text(
                            'Lokasi Penjemputan :',
                            style: TextStyle(color: Warna.grey, fontSize: 11),
                          ),
                          Obx(() => Text(
                                jemput.value,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 4,
                                style: TextStyle(
                                    color: Warna.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              )),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RawMaterialButton(
                                onPressed: () {
                                  Get.to(() => ChatDetailPage());
                                },
                                constraints: BoxConstraints(),
                                elevation: 0,
                                fillColor: Colors.green[800],
                                child: Row(
                                  children: [
                                    Icon(Icons.chat,
                                        color: Colors.white, size: 17),
                                    Padding(padding: EdgeInsets.only(left: 6)),
                                    Text(
                                      'Chat',
                                      style: TextStyle(
                                          color: Warna.putih, fontSize: 16),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.fromLTRB(14, 5, 14, 5),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(9)),
                                ),
                              ),
                              RawMaterialButton(
                                onPressed: () {},
                                constraints: BoxConstraints(),
                                elevation: 0,
                                fillColor: Colors.green[800],
                                child: Row(
                                  children: [
                                    Icon(Icons.map,
                                        color: Colors.white, size: 17),
                                    Padding(padding: EdgeInsets.only(left: 6)),
                                    Text(
                                      'Lihat peta',
                                      style: TextStyle(
                                          color: Warna.putih, fontSize: 16),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.fromLTRB(14, 5, 14, 5),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(9)),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
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
                      'Pembayaran via',
                      style: TextStyle(color: Warna.grey),
                    ),
                    RawMaterialButton(
                      onPressed: () {},
                      constraints: BoxConstraints(),
                      elevation: 0,
                      fillColor: Colors.blue,
                      child: Obx(() => Text(
                            pembayaranVia.value,
                            style: TextStyle(color: Warna.putih, fontSize: 16),
                          )),
                      padding: EdgeInsets.fromLTRB(14, 4, 14, 4),
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
                      'Tarif Pengantaran',
                      style: TextStyle(color: Warna.grey),
                    ),
                    RawMaterialButton(
                      onPressed: () {},
                      constraints: BoxConstraints(),
                      elevation: 0,
                      fillColor: Colors.blue,
                      child: Obx(() => Text(
                            tarif.value,
                            style: TextStyle(color: Warna.putih, fontSize: 16),
                          )),
                      padding: EdgeInsets.fromLTRB(14, 4, 14, 4),
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
            padding: EdgeInsets.fromLTRB(22, 11, 22, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [],
                ),
              ],
            ),
          ),
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
    var kodetrx = c.kodeJualPengantaranDriver.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","kodetrx":"$kodetrx"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLdriver}/mobileAppsMitraDriver/KonfirmasiKesediaanOjek');

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
        c.buttonTerimaOrderKurir.value = hasil['buttonKonfirmasi'];
        kodepesanan.value = hasil['kodetrx'];
        tahap.value = hasil['tahap'];
        namaPemesan.value = hasil['namaPemesan'];
        foto.value = hasil['foto'];
        tujuan.value = hasil['tujuan'];
        jemput.value = hasil['jemput'];
        pembayaranVia.value = hasil['pembayaranVia'];
        tarif.value = hasil['tarif'];
        tanggal.value = hasil['tanggal'];
        c.idChatLawan.value = hasil['idchat'];
        c.namaChatLawan.value = hasil['namaPemesan'];
        c.fotoChatLawan.value = hasil['foto'];
      }
    }
  }

  void terimaPengantaranIni() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var kodetrx = c.kodeJualPengantaranDriver.value;
    var latt = c.latitude.value;
    var longg = c.longitude.value;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","kodetrx":"$kodetrx","latt":"$latt","longg":"$longg"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLdriver}/mobileAppsMitraDriver/terimaOrderOjek');

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
        c.telahTerimaOrder.value = true;
        Get.back();
        Get.to(() => OrderPengantaranOjek());
      } else if (hasil['status'] == 'expire') {
        Get.back();
        AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.noHeader,
            animType: AnimType.scale,
            title: 'Order Telah Expire',
            desc:
                'Opps... sepertinya order ini telah terlewatkan, Order berikutnya akan segera datang, Segera buka order dan menerima pengantaran ya...',
            btnOkText: 'Tutup',
            btnOkOnPress: () async {
              Get.back();
            })
          ..show();
      }
    }
  }
}
