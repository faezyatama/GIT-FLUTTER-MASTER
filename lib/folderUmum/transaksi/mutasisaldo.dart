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

class MutasiSaldo extends StatefulWidget {
  @override
  _MutasiSaldoState createState() => _MutasiSaldoState();
}

class _MutasiSaldoState extends State<MutasiSaldo> {
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

    var datarequest = '{"pid":"$pid","skip":"$halaman"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/mutasiSaldo');

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
                child: Card(
              elevation: 0.2,
              child: Container(
                padding: EdgeInsets.fromLTRB(22, 5, 22, 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: Get.width * 0.45,
                      child: Column(
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
                        ],
                      ),
                    ),
                    (mutasi[4] == 'M')
                        ? RawMaterialButton(
                            onPressed: () {},
                            constraints: BoxConstraints(),
                            elevation: 0,
                            fillColor: Colors.green,
                            child: Text(
                              'K',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 11),
                            ),
                            padding: EdgeInsets.fromLTRB(7, 4, 7, 4),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(9)),
                            ),
                          )
                        : RawMaterialButton(
                            onPressed: () {},
                            constraints: BoxConstraints(),
                            elevation: 0,
                            fillColor: Colors.red,
                            child: Text(
                              'D',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 11),
                            ),
                            padding: EdgeInsets.fromLTRB(7, 4, 7, 4),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(9)),
                            ),
                          ),
                    SizedBox(
                      width: Get.width * 0.25,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(mutasi[3],
                                  style: TextStyle(
                                      fontSize: 18, color: Warna.grey)),
                            ],
                          ),
                        ],
                      ),
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
