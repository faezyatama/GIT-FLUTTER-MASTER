import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/warna.dart';
import '/base/api_service.dart';
import 'package:http/http.dart' as https;
import 'helperProdukPinjaman.dart';
import 'lihatMutasiPinjaman.dart';
import 'lihatProdukPinjaman.dart';

import '../base/conn.dart';

class HomePinjaman extends StatefulWidget {
  @override
  State<HomePinjaman> createState() => _HomePinjamanState();
}

class _HomePinjamanState extends State<HomePinjaman> {
  final controllerPin = TextEditingController();

  final c = Get.find<ApiService>();
  var rek = '0'.obs;
  var vcard = ''.obs;
  var foto = ''.obs;
  var nama = ''.obs;
  var saldo = ''.obs;
  var namaPinjaman = ''.obs;
  List<String> listRek = [];
  var tampilkan = false;

  @override
  void initState() {
    super.initState();
    homeMyRekeningPinjaman();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.warnautama,
        title: Text("Pinjaman Koperasi"),
      ),
      bottomNavigationBar:
          (tampilkan == true) ? ListProdukPinjaman() : SizedBox(),
      body: ListView(children: [
        Obx(() => SizedBox(
              width: Get.width * 0.9,
              height: Get.width * 0.65,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(vcard.value),
                    fit: BoxFit.contain,
                  ),
                ),
                child: Column(children: [
                  Padding(padding: EdgeInsets.only(top: Get.width * 0.25)),
                  Container(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(top: Get.width * 0.1)),
                            Text(nama.value,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                )),
                            Text(saldo.value,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                )),
                            Text(namaPinjaman.value,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                )),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              color: Colors.white,
                              padding: EdgeInsets.all(1),
                              child: CachedNetworkImage(
                                width: Get.width * 0.2,
                                imageUrl: foto.value,
                              ),
                            ),
                            Text(
                              rek.value,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 58, 56, 56),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ]),
              ),
            )),
        Padding(padding: EdgeInsets.only(top: 22)),
        Container(
          padding: EdgeInsets.only(left: 22, right: 22),
          child: DropdownSearch<String>(
              items: listRek,
              popupProps: PopupProps.menu(
                showSelectedItems: true,
                disabledItemFn: (String s) => s.startsWith('I'),
              ),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Nomor Rekening Pinjaman",
                ),
              ),
              onChanged: (propValue) {
                setState(() {
                  rek.value = propValue;
                  homeMyRekeningPinjaman();
                });
              },
              selectedItem: rek.value),
        ),
        Container(
          padding: EdgeInsets.only(left: 22, right: 22),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              namaPinjaman.value,
              style: TextStyle(color: Warna.grey),
            ),
            RawMaterialButton(
              onPressed: () {
                Get.to(MutasiPinjaman());
              },
              constraints: BoxConstraints(),
              elevation: 1.0,
              fillColor: Warna.warnautama,
              child: Text(
                'Riwayat Pembayaran',
                style: TextStyle(fontSize: 11, color: Colors.white),
              ),
              padding: EdgeInsets.fromLTRB(22, 3, 22, 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(33)),
              ),
            ),
          ]),
        ),
        Padding(padding: EdgeInsets.only(top: 22)),
      ]),
    );
  }

  homeMyRekeningPinjaman() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","rek":"${rek.value}"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();
    var url = Uri.parse('${c.baseURL}/mobileApps/homeMyRekeningPinjaman');

    final response = await https.post(url, body: {
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
        listRek = [];
        rek.value = hasil['norek'];
        c.nomorRekeningPilihan = hasil['norek'];
        vcard.value = hasil['card'];
        foto.value = hasil['foto'];
        nama.value = hasil['namaUser'];
        saldo.value = hasil['saldo'];
        namaPinjaman.value = hasil['jenisPinjaman'];
        listRek = List<String>.from(hasil['listRek']);
        tampilkan = true;
        setState(() {});
      } else {
        Get.off(LihatProdukPinjaman());
      }
    }
  }
}
