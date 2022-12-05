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

import '../base/conn.dart';
import 'helperProdukSimpanan.dart';
import 'lihatMutasiSimpanan.dart';
import 'lihatProdukSimpanan.dart';

class HomeSimpanan extends StatefulWidget {
  @override
  State<HomeSimpanan> createState() => _HomeSimpananState();
}

class _HomeSimpananState extends State<HomeSimpanan> {
  final c = Get.find<ApiService>();
  var rek = '0'.obs;
  var vcard = ''.obs;
  var foto = ''.obs;
  var nama = ''.obs;
  var saldo = ''.obs;
  var namaSimpanan = ''.obs;
  List<String> listRek = [];

  @override
  void initState() {
    super.initState();
    homeMyRekeningSimpanan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Warna.warnautama,
          title: Text("Simpanan Koperasi"),
        ),
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
                                  padding:
                                      EdgeInsets.only(top: Get.width * 0.1)),
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
                              Text(namaSimpanan.value,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  )),
                            ],
                          ),
                          Column(
                            children: [
                              CachedNetworkImage(
                                width: Get.width * 0.2,
                                imageUrl: foto.value,
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
                    labelText: "Pilih Nomor Rekening Simpanan",
                  ),
                ),
                onChanged: (propValue) {
                  setState(() {
                    rek.value = propValue;
                    homeMyRekeningSimpanan();
                  });
                },
                selectedItem: rek.value),
          ),
          Container(
            padding: EdgeInsets.only(left: 22, right: 22),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    namaSimpanan.value,
                    style: TextStyle(color: Warna.grey),
                  ),
                  RawMaterialButton(
                    onPressed: () {
                      Get.to(MutasiSimpanan());
                    },
                    constraints: BoxConstraints(),
                    elevation: 1.0,
                    fillColor: Warna.warnautama,
                    child: Text(
                      'Lihat Mutasi !',
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
        bottomNavigationBar: ListProdukSimpanan());
  }

  homeMyRekeningSimpanan() async {
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
    var url = Uri.parse('${c.baseURL}/mobileApps/homeMyRekeningSimpanan');

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
        namaSimpanan.value = hasil['jenisSimpanan'];
        listRek = List<String>.from(hasil['listRek']);
        setState(() {});
      } else {
        Get.off(LihatProdukSimpanan());
      }
    }
  }
}
