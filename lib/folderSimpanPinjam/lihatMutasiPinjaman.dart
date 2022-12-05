import 'dart:convert';
import 'package:crypto/crypto.dart';
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

class MutasiPinjaman extends StatefulWidget {
  @override
  _MutasiPinjamanState createState() => _MutasiPinjamanState();
}

class _MutasiPinjamanState extends State<MutasiPinjaman> {
  final c = Get.find<ApiService>();
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

    var datarequest =
        '{"pid":"$pid","skip":"$halaman","norek":"${c.nomorRekeningPilihan}"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/MutasiPinjamanUSP');

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
                child: Card(
              elevation: 0.2,
              child: Container(
                padding: EdgeInsets.fromLTRB(22, 5, 22, 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: Get.width * 0.65,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mutasi[1],
                              style:
                                  TextStyle(fontSize: 18, color: Warna.grey)),
                          Padding(padding: EdgeInsets.only(top: 11)),
                          Text(mutasi[2],
                              style:
                                  TextStyle(fontSize: 12, color: Warna.grey)),
                          Text(
                            mutasi[0],
                            style: TextStyle(fontSize: 12, color: Warna.grey),
                          ),
                          (mutasi[7] > 0)
                              ? Text(
                                  mutasi[6],
                                  style: TextStyle(
                                      fontSize: 12, color: Warna.grey),
                                )
                              : Padding(padding: EdgeInsets.only(top: 1))
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          child: (mutasi[4] == 'LUNAS')
                              ? RawMaterialButton(
                                  onPressed: () {},
                                  constraints: BoxConstraints(),
                                  elevation: 0,
                                  fillColor: Colors.green,
                                  child: Text(
                                    mutasi[3],
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 11),
                                  ),
                                  padding: EdgeInsets.fromLTRB(11, 4, 11, 4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(9)),
                                  ),
                                )
                              : (mutasi[4] == 'JATUH TEMPO')
                                  ? RawMaterialButton(
                                      onPressed: () {},
                                      constraints: BoxConstraints(),
                                      elevation: 0,
                                      fillColor: Colors.redAccent,
                                      child: Text(
                                        mutasi[3],
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 11),
                                      ),
                                      padding:
                                          EdgeInsets.fromLTRB(11, 4, 11, 4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(9)),
                                      ),
                                    )
                                  : RawMaterialButton(
                                      onPressed: () {},
                                      constraints: BoxConstraints(),
                                      elevation: 0,
                                      fillColor:
                                          Color.fromARGB(255, 182, 160, 158),
                                      child: Text(
                                        mutasi[3],
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 11),
                                      ),
                                      padding:
                                          EdgeInsets.fromLTRB(11, 4, 11, 4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(9)),
                                      ),
                                    ),
                        ),
                        (mutasi[4] == 'LUNAS')
                            ? Text(
                                'LUNAS',
                                style:
                                    TextStyle(fontSize: 11, color: Warna.grey),
                              )
                            : Text(
                                mutasi[5],
                                style:
                                    TextStyle(fontSize: 11, color: Warna.grey),
                              )
                      ],
                    ),
                  ],
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Riwayat Pembayaran Pinjaman"),
        backgroundColor: Warna.warnautama,
      ),
      body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          footer: CustomFooter(
            builder: (BuildContext context, LoadStatus mode) {
              Widget body;
              if (mode == LoadStatus.idle) {
                body = Text("Sepertinya semua data telah ditampilkan");
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
          )),
    );
  }

  // from 1.5.0, it is not necessary to add this line
  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
