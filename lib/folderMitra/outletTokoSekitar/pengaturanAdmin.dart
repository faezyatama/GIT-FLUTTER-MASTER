import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import 'package:http/http.dart' as https;

class PengaturanAdminTS extends StatefulWidget {
  @override
  _PengaturanAdminTSState createState() => _PengaturanAdminTSState();
}

class _PengaturanAdminTSState extends State<PengaturanAdminTS> {
  final ctrlSS = TextEditingController();
  final c = Get.find<ApiService>();
  var cariSS = '';
  var sspilihan = '';
  bool dataSiap = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var paginate = 0;
  var adaDataDitampilkan = 'blank'.obs;

  @override
  void initState() {
    super.initState();
    cekAdminToko();
  }

  void _onRefresh() async {
    // monitor network fetch
    dataAdmin = [];
    containerAdmin = [];
    cekAdminToko();
    // if (mounted) setState(() {});
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    dataAdmin = [];
    containerAdmin = [];

    cekAdminToko();
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Atur Admin / Kasir'),
          backgroundColor: Colors.green,
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(11),
          child: RawMaterialButton(
            onPressed: () {
              prosesTambahAdmin();
            },
            constraints: BoxConstraints(),
            elevation: 1.0,
            fillColor: Colors.green,
            child: Text(
              'Tambah admin sekarang !',
              style: TextStyle(color: Warna.putih, fontSize: 16),
            ),
            padding: EdgeInsets.fromLTRB(22, 11, 22, 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(9)),
            ),
          ),
        ),
        body: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            header: WaterDropHeader(),
            footer: CustomFooter(
              builder: (BuildContext context, LoadStatus mode) {
                Widget body;
                if (mode == LoadStatus.idle) {
                  body = Text("");
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
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Admin Toko',
                        style: TextStyle(
                            fontSize: 28,
                            color: Warna.grey,
                            fontWeight: FontWeight.w200),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Butuh tambahan admin dan kasir untuk mengelola toko kamu??? tenang kamu bisa memanfaatkan fitur ini untuk menambahkan admin/kasir/keuangan',
                        style: TextStyle(
                          fontSize: 14,
                          color: Warna.grey,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Caranya sangat mudah loh... Cukup masukan Kode Anggota admin dan semua beres.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Warna.grey,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(12, 3, 12, 3),
                      child: TextField(
                        onChanged: (ss) {
                          if ((ss.length == 8) && (cariSS != ss)) {
                            FocusScope.of(context).requestFocus(FocusNode());
                            cekKodeSSAdmin(ss);
                          }
                        },
                        maxLength: 8,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Warna.warnautama),
                        controller: ctrlSS,
                        decoration: InputDecoration(
                            labelText: 'Masukan Kode Anggota Admin',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10))),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 10)),
                    Container(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'List Admin',
                        style: TextStyle(
                            fontSize: 22,
                            color: Warna.grey,
                            fontWeight: FontWeight.w200),
                      ),
                    ),
                  ],
                ),
                (adaDataDitampilkan.value == 'ada')
                    ? listdaftar()
                    : Container(),
                (adaDataDitampilkan.value == 'tidak')
                    ? Container(
                        padding: EdgeInsets.fromLTRB(22, 3, 22, 2),
                        child: Column(
                          children: [
                            Image.asset(
                              'images/nodata.png',
                              width: Get.width * 0.5,
                            ),
                            Text(
                              'Kamu belum memiliki admin yang membantu mengelola toko',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      )
                    : Container()
              ],
            )));
  }

  cekAdminToko() async {
    bool conn = await cekInternet();
    if (!conn) {
      return;
    }
    dataAdmin = [];
    containerAdmin = [];
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var fitur = 'Toko Sekitar';
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","fitur":"$fitur"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLtokosekitar}/mobileAppsOutlet/cekAdminToko');

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
        dataAdmin = hasil['data'];
        adaDataDitampilkan.value = 'ada';
        setState(() {});
      } else if (hasil['status'] == 'belum ada admin') {
        adaDataDitampilkan.value = 'tidak';
        setState(() {});
      }
    }
  }

  List dataAdmin = [];
  List<Container> containerAdmin = [];
  listdaftar() {
    containerAdmin = [];
    for (var a = 0; a < dataAdmin.length; a++) {
      var ord = dataAdmin[a];

      containerAdmin.add(Container(
        padding: EdgeInsets.fromLTRB(22, 2, 22, 2),
        child: GestureDetector(
          onTap: () {},
          child: Card(
              child: Container(
            margin: EdgeInsets.all(11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: Get.width * 0.12,
                  height: Get.width * 0.12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: NetworkImage(ord[3]), fit: BoxFit.cover),
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: 12)),
                SizedBox(
                  width: Get.width * 0.5,
                  child: GestureDetector(
                    onTap: () {},
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: Get.width * 0.6,
                          child: Text(
                            ord[0], //name
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Warna.grey,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(
                          width: Get.width * 0.6,
                          child: Text(
                            '${ord[1]} / ${ord[2]}', //HARGA
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Warna.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w200),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      AwesomeDialog(
                        context: Get.context,
                        dialogType: DialogType.warning,
                        animType: AnimType.rightSlide,
                        title: 'Hapus Admin',
                        desc:
                            'Apakah kamu yakin akan menghapus admin ini dari daftar ?',
                        btnCancelText: 'Ya, Hapus Sekarang',
                        btnCancelColor: Colors.amber,
                        btnCancelOnPress: () {
                          prosesHapusAdmin(ord[4].toString());
                        },
                      )..show();
                    },
                    icon: Icon(Icons.delete_forever, color: Warna.grey))
              ],
            ),
          )),
        ),
      ));
    }
    return Column(children: containerAdmin);
  }

  void cekKodeSSAdmin(String ss) async {
    cariSS = ss;
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');

    //PARAMETER BUKA OUTLET
    var ssAdmin = ss;
    var fitur = 'Toko Sekitar';
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","ss":"$ssAdmin","fitur":"$fitur"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLtokosekitar}/mobileAppsOutlet/cekSSAdminPOS');

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
        sspilihan = hasil['kodeSS'];
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: hasil['namaAdmin'],
          desc: 'Kode Anggota Ditemukan',
          btnCancelText: 'OK',
          btnCancelColor: Colors.amber,
          btnCancelOnPress: () {},
        )..show();
      } else if (hasil['status'] == 'failed') {
        var messege = hasil['message'];
        sspilihan = '';
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: 'Kode tidak ditemukan',
          desc: messege,
          btnCancelText: 'OK',
          btnCancelColor: Colors.amber,
          btnCancelOnPress: () {},
        )..show();
      } else if (hasil['status'] == 'admin sudah terdaftar') {
        sspilihan = '';
        ctrlSS.text = '';
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: 'SS Tidak dapat menjadi admin ',
          desc:
              'Kode Anggota yang kamu masukan tidak dapat menjadi admin, karena saat ini telah menjadi admin',
          btnCancelText: 'OK',
          btnCancelColor: Colors.amber,
          btnCancelOnPress: () {},
        )..show();
      }
    }
  }

  void prosesTambahAdmin() async {
    bool conn = await cekInternet();
    if (!conn) {
      return;
    }

    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","ss":"$sspilihan"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLtokosekitar}/mobileAppsOutlet/tambahAdmin');

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
      //clearkan data
      sspilihan = '';
      ctrlSS.text = '';
      cariSS = '';
      _onRefresh();

      if (hasil['status'] == 'success') {
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: 'Proses Berhasil',
          desc: 'Penambahan admin untuk toko/outlet berhasil',
          btnCancelText: 'OK',
          btnCancelColor: Colors.amber,
          btnCancelOnPress: () {},
        )..show();
      } else if (hasil['status'] == 'failed') {
        var messege = hasil['message'];
        sspilihan = '';
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: 'Proses Gagal',
          desc: messege,
          btnCancelText: 'OK',
          btnCancelColor: Colors.amber,
          btnCancelOnPress: () {},
        )..show();
      } else if (hasil['status'] == 'admin sudah terdaftar') {
        sspilihan = '';
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: 'SS Tidak dapat menjadi admin ',
          desc:
              'Kode Anggota yang kamu masukan tidak dapat menjadi admin, karena saat ini telah menjadi admin',
          btnCancelText: 'OK',
          btnCancelColor: Colors.amber,
          btnCancelOnPress: () {},
        )..show();
      }
    }
  }

  void prosesHapusAdmin(String idAdmin) async {
    bool conn = await cekInternet();
    if (!conn) {
      return;
    }

    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var fitur = 'Toko Sekitar';
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","idAdmin":"$idAdmin","fitur":"$fitur"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLtokosekitar}/mobileAppsOutlet/hapusAdmin');

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
      _onRefresh();
    }
  }
}
