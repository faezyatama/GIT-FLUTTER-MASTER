import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';

import '../../folderUmum/freshmart/etalase.dart';
import '../../folderUmum/freshmart/outletfreshmart.dart';

class ReferensiFreshmart extends StatefulWidget {
  @override
  _ReferensiFreshmartState createState() => _ReferensiFreshmartState();
}

class _ReferensiFreshmartState extends State<ReferensiFreshmart> {
  final c = Get.find<ApiService>();

  TextEditingController textController = TextEditingController();

  var paginate = 0;
  var loaddata = false;
  var filtercari = '';
  var filterkategori = '';
  var loadkategori = '';

  @override
  void initState() {
    super.initState();
    cekDataBarang();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        listdaftar(),
        Container(
            margin: EdgeInsets.all(11),
            child: Column(
              children: [
                IconButton(
                    icon: Icon(Icons.arrow_forward_ios,
                        size: 44, color: Colors.grey),
                    onPressed: () {
                      Get.to(() => EtalaseFreshmart());
                    }),
                Text('Lihat Lainnya',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ))
              ],
            ))
      ],
    );
  }

  cekDataBarang() async {
    jsonDataBarang = [];
    if (c.reffreshmartDashboard == '') {
      bool conn = await cekInternet();
      if (!conn) {
        return;
      }
      //BODY YANG DIKIRIM
      Box dbbox = Hive.box<String>('sasukaDB');
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');
      var latitude = c.latitude.value;
      var longitude = c.longitude.value;
      var user = dbbox.get('loginSebagai');

      var datarequest =
          '{"pid":"$pid","skip":"$paginate","cari":"$filtercari","kategori":"$filterkategori","lat":"$latitude","long":"$longitude","loadKategori":"$loadkategori"}';

      var bytes = utf8.encode(datarequest + '$token' + user);
      var signature = md5.convert(bytes).toString();

      var url = Uri.parse(
          '${c.baseURLfreshmart}/mobileAppsUser/cekProdukFreshmartDashboard');

      final response = await http.post(url, body: {
        "user": user,
        "appid": c.appid,
        "data_request": datarequest,
        "sign": signature,
        "package": c.packageName
      });

      paginate++;

      // print('LOADING DATA FRESHMART- ' + user);
      // print(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> hasil = jsonDecode(response.body);
        if (hasil['status'] == 'success') {
          c.reffreshmartDashboard = response.body;

          jsonDataBarang = hasil['data'];
          loadkategori = 'sudah';
          if (mounted) {
            setState(() {
              loaddata = true;
            });
          }
        }
      }
    } else {
      Map<String, dynamic> hasil = jsonDecode(c.reffreshmartDashboard);
      if (hasil['status'] == 'success') {
        jsonDataBarang = hasil['data'];
        loadkategori = 'sudah';
        if (mounted) {
          setState(() {
            loaddata = true;
          });
        }
      }
    }

    //END LOAD DATA TOP UP
  }

  List jsonDataBarang = [];
  List<Container> listdatabarang = [];

  listdaftar() {
    if (jsonDataBarang.length > 0) {
      for (var i = 0; i < jsonDataBarang.length; i++) {
        var valHistory = jsonDataBarang[i];

        listdatabarang.add(
          Container(
              child: GestureDetector(
            onTap: () {
              c.idOutletPilihanFm.value = valHistory[1].toString();

              if ((c.idOutletpadakeranjangFm.value ==
                      c.idOutletPilihanFm.value) ||
                  (c.idOutletpadakeranjangFm.value == '0')) {
                c.namaOutletFm.value = valHistory[7];

                c.namaPreviewFM.value = valHistory[2];
                c.gambarPreviewFM.value = valHistory[12];
                c.gambarPreviewFMhiRess.value = valHistory[13];
                c.namaoutletPreviewFM.value = valHistory[7];
                c.hargaPreviewFM.value = valHistory[5];
                c.lokasiPreviewFM.value = valHistory[4];
                c.itemidPreviewFM.value = valHistory[10];
                c.deskripsiPreviewFM.value = valHistory[11];

                c.helper2.value = valHistory[12];
                c.helper5.value = valHistory[8];
                c.helper7.value = valHistory[10].toString();

                Get.to(() => DetailOtletFreshmart());
              } else {
                AwesomeDialog(
                  context: Get.context,
                  dialogType: DialogType.noHeader,
                  animType: AnimType.bottomSlide,
                  title: '',
                  desc: '',
                  body: Column(
                    children: [
                      Image.asset('images/nofood.png'),
                      Text('Pindah ke Outlet lain',
                          style: TextStyle(
                              fontSize: 20,
                              color: Warna.grey,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center),
                      Container(
                        padding: EdgeInsets.fromLTRB(22, 7, 22, 11),
                        child: Text(
                          'Sepertinya kamu ingin berpindah ke outlet lain, Boleh kok, keranjang di outlet sebelumnya kami hapus ya...',
                          style: TextStyle(fontSize: 14, color: Warna.grey),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 16)),
                      Container(
                        padding: EdgeInsets.only(left: 22, right: 22),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: Text('Tidak jadi')),
                            ElevatedButton(
                                onPressed: () {
                                  c.idOutletpadakeranjangFm.value = '0';
                                  c.jumlahItemFm.value = 0;
                                  c.hargaKeranjangFm.value = 0;
                                  c.keranjangFm.clear();
                                  c.idOutletPilihanFm.value =
                                      valHistory[1].toString();
                                  c.namaOutletFm.value = valHistory[7];
                                  c.namaoutletpadakeranjangFm.value =
                                      'dalam keranjangmu';
                                  c.namaPreviewFM.value = valHistory[2];
                                  c.gambarPreviewFM.value = valHistory[12];
                                  c.gambarPreviewFMhiRess.value =
                                      valHistory[13];
                                  c.namaoutletPreviewFM.value = valHistory[7];
                                  c.hargaPreviewFM.value = valHistory[5];
                                  c.lokasiPreviewFM.value = valHistory[4];
                                  c.itemidPreviewFM.value = valHistory[10];
                                  c.deskripsiPreviewFM.value = valHistory[11];
                                  Get.off(DetailOtletFreshmart());
                                },
                                child: Text('Ok Ganti')),
                          ],
                        ),
                      )
                    ],
                  ),
                )..show();
              }
            },
            child: Card(
                elevation: 0.1,
                //color: Colors.lightGreen[50],
                margin: EdgeInsets.all(5),
                child: Container(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      CachedNetworkImage(
                          width: Get.width * 0.3,
                          height: Get.width * 0.3,
                          imageUrl: valHistory[3],
                          errorWidget: (context, url, error) {
                            print(error);
                            return Icon(Icons.error);
                          }),
                      Padding(padding: EdgeInsets.only(left: Get.width * 0.01)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: Get.width * 0.32,
                            child: Text(
                              valHistory[7],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(fontSize: 16, color: Warna.grey),
                            ),
                          ),
                          SizedBox(
                            width: Get.width * 0.32,
                            child: Text(
                              valHistory[2],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(fontSize: 12, color: Warna.grey),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 22)),
                          Text(
                            valHistory[5],
                            style: TextStyle(
                                fontSize: 18,
                                color: Warna.grey,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.left,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                valHistory[4],
                                style:
                                    TextStyle(fontSize: 10, color: Warna.grey),
                              ),
                              Padding(padding: EdgeInsets.only(left: 11)),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    color: Warna.grey,
                                    size: 14,
                                  ),
                                  Padding(padding: EdgeInsets.only(left: 3)),
                                  Text(
                                    valHistory[6],
                                    style: TextStyle(
                                        fontSize: 10, color: Warna.grey),
                                  ),
                                  Padding(padding: EdgeInsets.only(left: 8)),
                                  Icon(
                                    Icons.watch,
                                    color: Warna.grey,
                                    size: 11,
                                  ),
                                  Padding(padding: EdgeInsets.only(left: 3)),
                                  Text(
                                    valHistory[9],
                                    style: TextStyle(
                                        fontSize: 10, color: Warna.grey),
                                  )
                                ],
                              ),
                              Padding(padding: EdgeInsets.only(left: 11)),
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
    jsonDataBarang = [];
    return Row(children: listdatabarang);
  }
}
