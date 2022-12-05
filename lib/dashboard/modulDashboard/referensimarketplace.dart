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

import '../../folderUmum/marketplace/etalase.dart';
import '../../folderUmum/marketplace/outletmarketplace.dart';

class ReferensiDashboard extends StatefulWidget {
  @override
  _ReferensiDashboardState createState() => _ReferensiDashboardState();
}

class _ReferensiDashboardState extends State<ReferensiDashboard> {
  final c = Get.find<ApiService>();

  var paginate = 0;
  var loaddata = false;
  var pencarian = false;
  var datakategori = false;
  var loaddataPencarian = false;

  var filtercari = '';
  var filterkategori = '';
  var loadkategori = '';

  @override
  void initState() {
    super.initState();
    referensiProduk();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      tampilkanReff1(),
      Container(
          margin: EdgeInsets.all(11),
          child: Column(
            children: [
              IconButton(
                  icon: Icon(Icons.arrow_forward_ios,
                      size: 44, color: Colors.grey),
                  onPressed: () {
                    Get.to(() => EtalaseMarketplace());
                  }),
              Text('Lihat Produk Lainnya',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ))
            ],
          ))
    ]);
  }

  void referensiProduk() async {
    jsonDataBarang = [];
    if (c.refmarketplaceDashboard == '') {
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
          '{"pid":"$pid","skip":"$paginate","lat":"$latitude","long":"$longitude" }';
      var bytes = utf8.encode(datarequest + '$token' + user);
      var signature = md5.convert(bytes).toString();

      var url =
          Uri.parse('${c.baseURLmp}/mobileAppsUser/cekProdukuntukDashboard');

      final response = await http.post(url, body: {
        "user": user,
        "appid": c.appid,
        "data_request": datarequest,
        "sign": signature,
        "package": c.packageName
      });

      paginate++;

      // print('LOADING DATA MARKETPLACE- ' + user);
      // print(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> hasil = jsonDecode(response.body);
        if (hasil['status'] == 'success') {
          c.refmarketplaceDashboard = response.body;
          dbbox.put('referensiMP', response.body);
          if (mounted) {
            jsonReff1 = hasil['referensi1'];
            jsonKateg1 = hasil['kategori1'];

            setState(() {
              loaddata = true;
            });
          }
        }
      }
    } else {
      Map<String, dynamic> hasil = jsonDecode(c.refmarketplaceDashboard);

      if (hasil['status'] == 'success') {
        if (mounted) {
          jsonReff1 = hasil['referensi1'];
          jsonKateg1 = hasil['kategori1'];

          setState(() {
            loaddata = true;
          });
        }
      }
    }
  }

  List jsonDataBarang = [];
  List<Container> listdatabarang = [];

  List<Container> finalList = [];

  List jsonReff1 = [];
  var jsonKateg1 = '';
  List<Container> listReferensi1 = [];

  tampilkanReff1() {
    if (jsonReff1.length > 0) {
      for (var i = 0; i < jsonReff1.length; i++) {
        var valHistory = jsonReff1[i];

        listReferensi1.add(
          Container(
              width: Get.width * 0.42,
              child: GestureDetector(
                onTap: () {
                  c.idOutletPilihanMP.value = valHistory[1].toString();

                  if ((c.idOutletpadakeranjangMP.value ==
                          c.idOutletPilihanMP.value) ||
                      (c.idOutletpadakeranjangMP.value == '0')) {
                    c.namaOutletMP.value = valHistory[7];
                    c.namaOutletMP.value = valHistory[7];
                    c.tagIdMPC.value = valHistory[1].toString();
                    c.namaMPC.value = valHistory[2];
                    c.gambarMPC.value = valHistory[3];
                    c.namaoutletMPC.value = valHistory[7];
                    c.hargaMPC.value = valHistory[5];
                    c.lokasiMPC.value = valHistory[4];
                    c.deskripsiMPC.value = valHistory[10];
                    c.hargaIntMPC.value = valHistory[8];
                    c.idOutletMPC.value = valHistory[1].toString();
                    c.itemIdMPC.value = valHistory[11].toString();

                    Get.to(() => DetailOtletMarketplace());
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
                                      c.idOutletpadakeranjangMP.value = '0';
                                      c.jumlahItemMP.value = 0;
                                      c.hargaKeranjangMP.value = 0;
                                      c.jumlahBarangMP.value = 0;

                                      c.keranjangMP.clear();
                                      c.idOutletPilihanMP.value =
                                          valHistory[1].toString();
                                      c.namaoutletpadakeranjangMP.value =
                                          'dalam keranjangmu';

                                      c.namaOutletMP.value = valHistory[7];
                                      c.tagIdMPC.value =
                                          valHistory[1].toString();
                                      c.namaMPC.value = valHistory[2];
                                      c.gambarMPC.value = valHistory[3];
                                      c.namaoutletMPC.value = valHistory[7];
                                      c.hargaMPC.value = valHistory[5];
                                      c.lokasiMPC.value = valHistory[4];
                                      c.deskripsiMPC.value = valHistory[10];
                                      c.hargaIntMPC.value = valHistory[8];
                                      c.idOutletMPC.value =
                                          valHistory[1].toString();
                                      c.itemIdMPC.value =
                                          valHistory[11].toString();

                                      //Get.off(DetailOtletMarketplace());
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
                    elevation: 1,
                    //color: Colors.lightGreen[50],
                    margin: EdgeInsets.all(5),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          CachedNetworkImage(
                              width: Get.width * 0.38,
                              height: Get.width * 0.38,
                              imageUrl: valHistory[3],
                              errorWidget: (context, url, error) {
                                print(error);
                                return Icon(Icons.error);
                              }),
                          Padding(
                              padding: EdgeInsets.only(left: Get.width * 0.01)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: Get.width * 0.50,
                                child: Text(
                                  valHistory[2],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 16, color: Warna.grey),
                                ),
                              ),
                              SizedBox(
                                width: Get.width * 0.55,
                                child: Text(
                                  valHistory[7],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 12, color: Warna.grey),
                                ),
                              ),
                              Padding(padding: EdgeInsets.only(top: 15)),
                              (valHistory[14] == 'Rp.0')
                                  ? Padding(padding: EdgeInsets.only(top: 12))
                                  : Text(
                                      valHistory[14],
                                      style: TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: 12,
                                        color: Warna.grey,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                              Text(
                                valHistory[5],
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Warna.grey,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.left,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: Get.width * 0.2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: Get.width * 0.27,
                                          child: Text(
                                            valHistory[4],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 9, color: Warna.grey),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on_rounded,
                                                  color: Warna.grey,
                                                  size: 12,
                                                ),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 3)),
                                                Text(
                                                  valHistory[6],
                                                  style: TextStyle(
                                                      fontSize: 9,
                                                      color: Warna.grey),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(left: 11)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: Get.width * 0.1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'images/sellerbadge/${valHistory[15]}',
                                          width: Get.width * 0.05,
                                        ),
                                        Text(
                                          valHistory[16],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 6, color: Warna.grey),
                                        ),
                                      ],
                                    ),
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
    jsonReff1 = [];
    return Row(children: listReferensi1);
  }
}
