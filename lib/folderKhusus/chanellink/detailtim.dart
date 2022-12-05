import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
// ignore: import_of_legacy_library_into_null_safe
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_image/network.dart';

class DetailTim extends StatefulWidget {
  @override
  _DetailTimState createState() => _DetailTimState();
}

class _DetailTimState extends State<DetailTim> {
  final c = Get.find<ApiService>();
  var suka = true.obs;
  var paginate = 0;

  List dataku = ['', '', '', '', '', '', '', '', '', '', '', ''];

  @override
  void initState() {
    super.initState();
    loadDataFollower(paginate);
  }

  loadDataFollower(halaman) async {
    //LOAD DATA TOPUP
    //  EasyLoading.show(status: 'Mencari followers...');

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    //item search
    var nama = textController.text;

    var datarequest =
        '{"pid":"$pid","skip":"$halaman","nama":"$nama","view":"${c.pidpilihan.value}"}';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse('${c.baseURL}/sasuka/Level1');

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
          dataku = hasil['mydata'];
          dataFollowers = hasil['data'];
          // listdaftar();
        });
      } else if (hasil['status'] == 'no data') {
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.warning,
          animType: AnimType.rightSlide,
          title: 'Detail Belum ada',
          desc:
              'Opps... Sepertinya tidak ada data yang bisa di tampilkan, Ayo bantu teman kamu untuk mendapatkan SHU dan ajari mereka mengembangkan tim',
          btnCancelText: 'OK',
          btnCancelColor: Colors.amber,
          btnCancelOnPress: () {},
        )..show();
      }
    }
    //END LOAD DATA TOP UP
  }

  List<dynamic> dataFollowers = [];
  List<Container> listbank = [];
  listdaftar() {
    if (dataFollowers.length > 0) {
      for (var i = 0; i < dataFollowers.length; i++) {
        var foll = dataFollowers[i];
        String kodess = foll[2];
        listbank.add(
          Container(
            padding: EdgeInsets.only(left: 6, right: 6),
            child: SizedBox(
                height: Get.height * 0.09,
                child: Card(
                  elevation: 0.3,
                  child: Container(
                    padding: EdgeInsets.only(left: 5, right: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: Get.width * 0.12,
                                child: Image(
                                  image: NetworkImageWithRetry(
                                      'https://sasuka.online/sasuka.online/foto/${foll[1]}'),
                                ),
                              ),
                              Padding(padding: EdgeInsets.only(left: 11)),
                              Container(
                                width: Get.width * 0.45,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      foll[0],
                                      style: TextStyle(
                                          fontSize: 17,
                                          color: Warna.grey,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Padding(padding: EdgeInsets.only(top: 4)),
                                    Text(
                                      kodess,
                                      style: TextStyle(
                                          fontSize: 11, color: Warna.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(padding: EdgeInsets.only(left: 9)),
                              GestureDetector(
                                onTap: () {
                                  if (foll[3] != '1') {
                                    c.pidpilihan.value = foll[4];
                                    _onRefresh();
                                  } else {
                                    AwesomeDialog(
                                      context: Get.context,
                                      dialogType: DialogType.warning,
                                      animType: AnimType.rightSlide,
                                      title: 'Detail Belum ada',
                                      desc:
                                          'Opps... Sepertinya tidak ada data yang bisa di tampilkan, Ayo bantu teman kamu untuk mendapatkan SHU dan ajari mereka mengembangkan tim',
                                      btnCancelText: 'OK',
                                      btnCancelColor: Colors.amber,
                                      btnCancelOnPress: () {},
                                    )..show();
                                  }
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person_search,
                                      size: 30,
                                      color: Warna.warnautama,
                                    ),
                                    Container(
                                      width: Get.width * 0.15,
                                      child: Text(
                                        foll[3],
                                        style: TextStyle(
                                            color: Warna.warnautama,
                                            fontSize: 16),
                                      ),
                                    )
                                  ],
                                ),
                              )
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
    // monitor network fetch
    paginate = 0;
    listbank = [];
    dataFollowers = [];
    textController.text = '';
    await loadDataFollower(paginate);

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await loadDataFollower(paginate);

    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  TextEditingController textController = TextEditingController();
  var filterlove = Colors.white;
  var loveInt = 0;
  var iconlove = Icons.favorite;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Tim'),
        backgroundColor: Warna.warnautama,
        actions: [
          Padding(padding: EdgeInsets.only(left: 9)),
        ],
      ),
      body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: WaterDropHeader(),
          footer: CustomFooter(
            builder: (BuildContext context, LoadStatus mode) {
              Widget body;
              if (mode == LoadStatus.idle) {
                body = Text("Sepertinya semua tim telah ditampilkan");
              } else if (mode == LoadStatus.loading) {
                body = CupertinoActivityIndicator();
              } else if (mode == LoadStatus.failed) {
                body = Text("Gagal memuat ! Silahkan ulangi lagi !");
              } else if (mode == LoadStatus.canLoading) {
                body = Text("lepaskan untuk load lainnya");
              } else {
                body = Text("Tidak ada data");
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
              Padding(padding: EdgeInsets.only(top: 3)),
              Card(
                margin: EdgeInsets.all(18),
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(Get.width * 0.1),
                            child: Image(
                              image: NetworkImageWithRetry(dataku[1]),
                              width: Get.width * 0.2,
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(9)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dataku[0],
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Warna.grey,
                                      fontWeight: FontWeight.w600)),
                              Container(
                                width: Get.width * 0.5,
                                child: Text(
                                    'Ini adalah detail tim dari grup kamu, berikan semangat kepada mereka untuk terus meningkatkan penghasilan'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top: 16)),
                      Container(
                        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Text(dataku[2],
                                        style: TextStyle(
                                            fontSize: 30,
                                            color: Warna.grey,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                Text('Total Tim kamu',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Warna.grey,
                                    ))
                              ],
                            ),
                            Column(
                              children: [
                                Text(dataku[3],
                                    style: TextStyle(
                                        fontSize: 30,
                                        color: Warna.grey,
                                        fontWeight: FontWeight.w600)),
                                Text('Calon Anggota',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Warna.grey,
                                    ))
                              ],
                            ),
                            Column(
                              children: [
                                Text(dataku[4],
                                    style: TextStyle(
                                        fontSize: 30,
                                        color: Warna.grey,
                                        fontWeight: FontWeight.w600)),
                                Text('Channellink',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Warna.grey,
                                    ))
                              ],
                            )
                          ],
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(6)),
                      Container(
                        padding: EdgeInsets.all(17),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Image.asset(
                                  'images/whitelabelMainMenu/makan.png',
                                  width: Get.width * 0.12,
                                ),
                                Text('Outlet / Resto',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    )),
                                Text(dataku[8],
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600)),
                                Padding(padding: EdgeInsets.all(10)),
                                Image.asset(
                                  'images/whitelabelMainMenu/samotor.png',
                                  width: Get.width * 0.12,
                                ),
                                Text('Driver & Kurir',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    )),
                                Text(dataku[5],
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Column(
                              children: [
                                Image.asset(
                                  'images/whitelabelMainMenu/freshmart.png',
                                  width: Get.width * 0.12,
                                ),
                                Text('Freshmart',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    )),
                                Text(dataku[7],
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600)),
                                Padding(padding: EdgeInsets.all(10)),
                                Image.asset(
                                  'images/whitelabelMainMenu/ritzuka.png',
                                  width: Get.width * 0.12,
                                ),
                                Text('Ritzuka',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    )),
                                Text(dataku[9],
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Column(
                              children: [
                                Image.asset(
                                  'images/whitelabelMainMenu/mall.png',
                                  width: Get.width * 0.12,
                                ),
                                Text('Marketplace',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    )),
                                Text(dataku[6],
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600)),
                                Padding(padding: EdgeInsets.all(10)),
                                Image.asset(
                                  'images/whitelabelMainMenu/tokosekitar.png',
                                  width: Get.width * 0.12,
                                ),
                                Text('Toko Sekitar',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    )),
                                Text(dataku[10],
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people,
                      color: Colors.grey,
                      size: 30,
                    ),
                    Padding(padding: EdgeInsets.only(left: 11)),
                    Text('Daftar Tim ${dataku[0]}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Warna.grey,
                        )),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 15)),
              listdaftar(),
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
