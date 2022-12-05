import 'dart:convert';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import 'sertifikat.dart';
import 'spmpkop.dart';

class DetailRitzuka extends StatefulWidget {
  @override
  _DetailRitzukaState createState() => _DetailRitzukaState();
}

class _DetailRitzukaState extends State<DetailRitzuka> {
  final c = Get.find<ApiService>();

  var tahapan = 'TAHAPAN SAAT INI';
  var profitHariIni = '0.00';
  var bagihasil = '0.00';
  var akumulasiBagiHasil = '0.00';
  var tanggalView = 'Pilih Tanggal'.obs;
  var tanggalSend = 'Pilih Tanggal';
  var buttonSPMP = false.obs;

  @override
  void initState() {
    super.initState();
    detailMyRitz();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail UMP'),
        backgroundColor: Colors.blue[700],
      ),
      body: ListView(
        children: [
          CachedNetworkImage(
              width: Get.width * 1,
              height: Get.width * 0.8,
              imageUrl: c.fotoritzpilihan.value,
              errorWidget: (context, url, error) {
                print(error);
                return Icon(Icons.error);
              }),
          Padding(padding: EdgeInsets.only(left: 11)),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                c.namaritzPilihan.value, // nama ritzuka
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                    fontSize: 18,
                    color: Warna.grey,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                c.alamatRitzPilihan.value, // alamat
                style: TextStyle(fontSize: 12, color: Warna.grey),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RawMaterialButton(
                    onPressed: () {},
                    constraints: BoxConstraints(),
                    elevation: 1.0,
                    fillColor: Colors.green,
                    child: Text(
                      c.unitRitzPilihan.value, //unit
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(left: 11)),
                  RawMaterialButton(
                    onPressed: () {},
                    constraints: BoxConstraints(),
                    elevation: 1.0,
                    fillColor: Colors.green,
                    child: Text(
                      c.totalUmpRitzPilihan.value,
                      style: TextStyle(color: Warna.putih, fontSize: 14),
                    ),
                    padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RawMaterialButton(
                    onPressed: () {
                      Get.to(() => SertifikatRitzuka());
                    },
                    constraints: BoxConstraints(),
                    elevation: 1.0,
                    fillColor: Colors.blueAccent,
                    child: Text(
                      'e-Sertifikat',
                      style: TextStyle(color: Warna.putih, fontSize: 14),
                    ),
                    padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(left: 11)),
                  Obx(() => Container(
                        child: (buttonSPMP.value == true)
                            ? RawMaterialButton(
                                onPressed: () {
                                  Get.to(() => PdfSPMPKop());
                                },
                                constraints: BoxConstraints(),
                                elevation: 1.0,
                                fillColor: Colors.indigo,
                                child: Text(
                                  'SPMPKOP',
                                  style: TextStyle(
                                      color: Warna.putih, fontSize: 14),
                                ),
                                padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(9)),
                                ),
                              )
                            : Container(),
                      )),
                ],
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 12, 0, 12),
                color: Colors.grey[200],
                height: 5,
              ),
              Text(
                'Status Saat ini :',
                style: TextStyle(color: Warna.grey, fontSize: 12),
              ),
              Text(tahapan,
                  style: TextStyle(
                      color: Warna.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              Container(
                margin: EdgeInsets.fromLTRB(0, 12, 0, 12),
                color: Colors.grey[200],
                height: 5,
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(12, 5, 12, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pendapatan Harian :',
                    style: TextStyle(color: Warna.grey, fontSize: 12),
                  ),
                  RawMaterialButton(
                    onPressed: () {
                      DatePicker.showDatePicker(context,
                          showTitleActions: true,
                          minTime: DateTime(2021, 8, 1),
                          maxTime: DateTime(2031, 12, 31), onChanged: (date) {
                        tanggalView.value =
                            '${date.day.toString()}-${date.month.toString()}-${date.year.toString()}';
                        tanggalSend =
                            '${date.year.toString()}-${date.month.toString()}-${date.day.toString()}';
                      }, onConfirm: (date) {
                        tanggalView.value =
                            '${date.day.toString()}-${date.month.toString()}-${date.year.toString()}';
                        tanggalSend =
                            '${date.year.toString()}-${date.month.toString()}-${date.day.toString()}';
                        detailMyRitz();
                      }, currentTime: DateTime.now(), locale: LocaleType.id);
                    },
                    constraints: BoxConstraints(),
                    elevation: 1.0,
                    fillColor: Colors.green,
                    child: Obx(() => Text(
                          tanggalView.value,
                          style: TextStyle(color: Warna.putih, fontSize: 16),
                        )),
                    padding: EdgeInsets.fromLTRB(33, 5, 33, 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(12, 5, 12, 5),
              child: Card(
                child: Container(
                    padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Laba Kotor/Gross Profit (Rp.)',
                              style: TextStyle(fontSize: 12, color: Warna.grey),
                            ),
                            Padding(padding: EdgeInsets.only(left: 22)),
                            Text(
                              profitHariIni,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Warna.grey,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pendapatan Bagi hasil (Rp.)',
                              style: TextStyle(fontSize: 12, color: Warna.grey),
                            ),
                            Padding(padding: EdgeInsets.only(left: 22)),
                            Text(
                              bagihasil,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Warna.grey,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Akumulasi Bagi Hasil Ritzuka (Rp.)',
                              style: TextStyle(fontSize: 12, color: Warna.grey),
                            ),
                            Padding(padding: EdgeInsets.only(left: 22)),
                            Text(
                              akumulasiBagiHasil,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Warna.grey,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  detailMyRitz() async {
    bool conn = await cekInternet();
    if (conn) {
      Box dbbox = Hive.box<String>('sasukaDB');
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');
      var idRitz = c.idritzukapilihan.value;

      var datarequest =
          '{"pid":"$pid","idritz":"$idRitz","tanggal":"$tanggalSend"}';
      var bytes = utf8.encode(datarequest + '$token');
      var signature = md5.convert(bytes).toString();
      var user = dbbox.get('loginSebagai');

      var url = Uri.parse('${c.baseURL}/sasuka/detailRitzukaKu');

      final response = await http.post(url, body: {
        "user": user,
        "appid": c.appid,
        "data_request": datarequest,
        "sign": signature
      });

      // EasyLoading.dismiss();
      print(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> hasil = jsonDecode(response.body);
        if (hasil['status'] == 'success') {
          if (mounted) {
            setState(() {
              tahapan = hasil['tahapan'];
              profitHariIni = hasil['profitHariIni'];
              bagihasil = hasil['bagiHasil'];
              akumulasiBagiHasil = hasil['akumulasiBagiHasil'];
              c.spmpkopPilihan.value = hasil['spmpkopURL'];
              buttonSPMP.value = hasil['spmpkop'];
            });
          }
        } else if (hasil['status'] == 'no data') {}
      }
    }
  }
}
