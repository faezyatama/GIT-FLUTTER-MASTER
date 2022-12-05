import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:crypto/crypto.dart';
import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
// ignore: import_of_legacy_library_into_null_safe
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import '/cetak/cetak.dart';
import 'package:share/share.dart';

class MutasiPln extends StatefulWidget {
  @override
  _MutasiPlnState createState() => _MutasiPlnState();
}

class _MutasiPlnState extends State<MutasiPln> {
  final c = Get.find<ApiService>();
  final controllerHarga = TextEditingController();
  var hargaDiatur = Hive.box<String>('sasukaDB').get('hargaDiatur');

  var paginate = 0;
  bool datasiap = false;
  var adaDataDitampilkan = 'blank';
  @override
  void initState() {
    super.initState();
    loadDataMutasi(paginate);
  }

  loadDataMutasi(halaman) async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    //item search
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","skip":"$halaman"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/mutasiPln');

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
        paginate = paginate + 1;
        setState(() {
          dataMutasi = hasil['data'];
          datasiap = true;
          if ((paginate == 1) && (dataMutasi.length == 0)) {
            adaDataDitampilkan = 'tidak';
          } else {
            adaDataDitampilkan = 'ada';
          }
        });
      } else {
        setState(() {
          adaDataDitampilkan = 'tidak';
        });
      }
    }
    //END LOAD DATA TOP UP
  }

  List<dynamic> dataMutasi = [].obs;
  List<Container> listbank = [];
  listdaftar() {
    if (dataMutasi.length > 0) {
      for (var i = 0; i < dataMutasi.length; i++) {
        var mutasi = dataMutasi[i];

        listbank.add(
          Container(
            child: SizedBox(
                child: GestureDetector(
              onTap: () {
                AwesomeDialog(
                  context: Get.context,
                  dialogType: DialogType.noHeader,
                  animType: AnimType.rightSlide,
                  title: '',
                  body: Column(
                    children: [
                      Text('CETAK / SHARE',
                          style: TextStyle(
                              fontSize: 18,
                              color: Warna.warnautama,
                              fontWeight: FontWeight.w600)),
                      Padding(padding: EdgeInsets.only(top: 7)),
                      Container(
                        padding: EdgeInsets.only(left: 7, right: 7),
                        child: Text(
                            'Apakah kamu akan mencetak struk ini atau Share transaksi ini ?'),
                      ),
                      Padding(padding: EdgeInsets.only(top: 16)),
                      Text(mutasi[1],
                          style: TextStyle(
                              fontSize: 18,
                              color: Warna.grey,
                              fontWeight: FontWeight.w600)),
                      (hargaDiatur == 'Sendiri')
                          ? Container(
                              width: Get.width * 0.7,
                              child: TextField(
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600,
                                    color: Warna.grey),
                                controller: controllerHarga,
                                inputFormatters: [
                                  TextInputMask(mask: [
                                    '999.999.999.999',
                                    '999.999.9999.999'
                                  ], reverse: true)
                                ],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.money),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                              ),
                            )
                          : Container(),
                      Padding(padding: EdgeInsets.only(top: 33)),
                      RawMaterialButton(
                        constraints: BoxConstraints(minWidth: Get.width * 0.7),
                        elevation: 1.0,
                        fillColor: Warna.warnautama,
                        child: Text(
                          'Cetak',
                          style: TextStyle(color: Warna.putih, fontSize: 14),
                        ),
                        padding: EdgeInsets.fromLTRB(18, 11, 18, 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(11)),
                        ),
                        onPressed: () {
                          if ((hargaDiatur == 'Sendiri')) {
                            if ((controllerHarga.text == '')) {
                              controllerHarga.text = '';
                              Get.back();
                              AwesomeDialog(
                                context: Get.context,
                                dialogType: DialogType.noHeader,
                                animType: AnimType.rightSlide,
                                title: 'PERHATIAN !',
                                desc:
                                    'Harga belum dimasukan dengan benar, Silahkan atur harga untuk dicetak/share',
                                btnCancelText: 'OK',
                                btnCancelColor: Colors.amber,
                                btnCancelOnPress: () {},
                              )..show();
                            } else {
                              c.kodeCetak.value = mutasi[4];
                              c.barisCetak1.value = mutasi[7];
                              c.barisCetak2.value = mutasi[8];
                              c.barisCetak3.value = mutasi[9];
                              c.barisCetak4.value = mutasi[10];
                              c.barisCetak5.value = mutasi[11];
                              c.barisCetak6.value = mutasi[12];
                              c.barisCetak7.value = mutasi[13];
                              c.barisCetak8.value = mutasi[14];
                              c.hargaCetak.value =
                                  'Rp. ${controllerHarga.text}';
                              controllerHarga.text = '';
                              Get.back();
                              Get.to(() => TTcetak());
                            }
                          } else {
                            c.kodeCetak.value = mutasi[4];
                            c.barisCetak1.value = mutasi[7];
                            c.barisCetak2.value = mutasi[8];
                            c.barisCetak3.value = mutasi[9];
                            c.barisCetak4.value = mutasi[10];
                            c.barisCetak5.value = mutasi[11];
                            c.barisCetak6.value = mutasi[12];
                            c.barisCetak7.value = mutasi[13];
                            c.barisCetak8.value = mutasi[14];
                            c.hargaCetak.value = mutasi[5];
                            Get.back();
                            Get.to(() => TTcetak());
                          }
                        },
                      ),
                      RawMaterialButton(
                        constraints: BoxConstraints(minWidth: Get.width * 0.7),
                        elevation: 1.0,
                        fillColor: Warna.warnautama,
                        child: Text(
                          'Share',
                          style: TextStyle(color: Warna.putih, fontSize: 14),
                        ),
                        padding: EdgeInsets.fromLTRB(18, 11, 18, 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(11)),
                        ),
                        onPressed: () {
                          Get.back();
                          Share.share(mutasi[6], subject: 'Share Transaksi');
                        },
                      ),
                    ],
                  ),
                )..show();
              },
              child: Card(
                elevation: 0.2,
                child: Container(
                  padding: EdgeInsets.fromLTRB(22, 5, 22, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'images/logopulsa/${mutasi[2]}.png',
                        width: Get.width * 0.2,
                      ),
                      Padding(padding: EdgeInsets.only(left: 12)),
                      SizedBox(
                        width: Get.width * 0.6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mutasi[1],
                                style:
                                    TextStyle(fontSize: 18, color: Warna.grey)),
                            Padding(padding: EdgeInsets.only(top: 7)),
                            Text(mutasi[5],
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Warna.grey,
                                    fontWeight: FontWeight.w600)),
                            Text(mutasi[3],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Warna.grey,
                                )),
                            Text(
                              mutasi[0],
                              style: TextStyle(fontSize: 12, color: Warna.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
          ),
        );
      }
    }
    return Column(
      children: listbank,
    );
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    paginate = 0;
    listbank = [];
    dataMutasi = [];
    await loadDataMutasi(paginate);
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await loadDataMutasi(paginate);

    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: WaterDropHeader(
          waterDropColor: Warna.warnautama,
        ),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = Text("Sepertinya semua follower telah ditampilkan");
            } else if (mode == LoadStatus.loading) {
              body = CupertinoActivityIndicator();
            } else if (mode == LoadStatus.failed) {
              body = Text("Gagal memuat ! Silahkan ulangi lagi !");
            } else if (mode == LoadStatus.canLoading) {
              body = Text("release to load more");
            } else {
              body = Text("No more Data");
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: ListView(
          children: [
            (adaDataDitampilkan == 'ada') ? listdaftar() : Container(),
            (adaDataDitampilkan == 'tidak')
                ? Container(
                    padding: EdgeInsets.fromLTRB(22, 63, 22, 2),
                    child: Column(
                      children: [
                        Image.asset(
                          'images/nodata.png',
                          width: Get.width * 0.6,
                        ),
                        Text(
                          'Sepertinya belum ada transaksi disini',
                          style: TextStyle(fontSize: 22, color: Colors.grey),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  )
                : Container()
          ],
        ));
  }

  // from 1.5.0, it is not necessary to add this line
  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
