import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import 'ppob-inquiry.dart';

class PpobOperator extends StatefulWidget {
  @override
  _PpobOperatorState createState() => _PpobOperatorState();
}

class _PpobOperatorState extends State<PpobOperator> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var halamans = 0;

  @override
  void initState() {
    super.initState();
    openSubProdukList();
  }

  void _onRefresh() async {
    halamans = 0;
    listbank = [];
    openSubProdukList();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    if (mounted) setState(() {});
    openSubProdukList();
    _refreshController.loadComplete();
  }

  final c = Get.find<ApiService>();
  final controllerCari = TextEditingController();
  var countppob = '0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.warnautama,
        title: Text('Pilih Operator'),
      ),
      body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: WaterDropHeader(
            waterDropColor: Warna.warnautama,
          ),
          footer: CustomFooter(
            builder: (BuildContext context, LoadStatus mode) {
              Widget body;
              if (mode == LoadStatus.idle) {
                body = Text("Mohon tunggu load data ...");
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
              SizedBox(
                width: 99,
                height: 99,
                child: Image.asset(
                  c.logoPPOB.value,
                ),
              ),
              Text('Pilih operator pembayaran di bawah ini',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center),
              Text('$countppob',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center),
              Padding(padding: EdgeInsets.only(top: 7)),
              Container(
                padding: EdgeInsets.only(left: 33, right: 33),
                width: Get.width * 0.7,
                child: TextField(
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Warna.grey),
                  controller: controllerCari,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                          icon: Icon(
                            Icons.search,
                            size: 28,
                          ),
                          onPressed: () async {
                            setState(() {
                              dataHistory = [];
                              listbank = [];
                            });
                            openSubProdukList();
                          }),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(33))),
                ),
              ),
              listdaftar(),
            ],
          )),
    );
  }

  void openSubProdukList() async {
    //  EasyLoading.show(status: 'Cek Operator Pembayaran...');
    dataHistory = [];
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var kategoriPPOB = c.kategoriPPOB.value;
    var cari = controllerCari.text;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid", "kategori":"$kategoriPPOB","cari":"$cari","skip":"$halamans"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/cekprodukppob');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });
    setState(() {
      controllerCari.text = '';
      halamans = halamans + 1;
    });

    //  EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        if (mounted) {
          setState(() {
            dataHistory = hasil['data'];
            countppob = hasil['count'].toString();
            //listdaftar();
          });
        }
      }
    }
  }

  List dataHistory = [];
  List<Container> listbank = [];

  listdaftar() {
    if (dataHistory.length > 0) {
      for (var i = 0; i < dataHistory.length; i++) {
        var valHistory = dataHistory[i];

        listbank.add(
          Container(
              padding: EdgeInsets.only(left: 3, right: 3, bottom: 5),
              child: SizedBox(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white, // background
                    onPrimary: Colors.grey, // foreground
                    elevation: 0,
                  ),
                  onPressed: () {
                    print('shdfsf');
                    c.subProduk.value = valHistory[0];
                    c.kodeppob.value = valHistory[1];
                    c.logosubproduk.value = valHistory[2];
                    Get.off(PpobInquiry());
                  },
                  child: Container(
                    margin: EdgeInsets.all(3),
                    child: Container(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.water_damage),
                          Text(
                            valHistory[0],
                            style: TextStyle(fontSize: 16, color: Warna.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
        );
      }
    }
    return Column(
      children: listbank,
    );
  }
}
