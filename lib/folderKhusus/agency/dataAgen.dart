import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '/base/api_service.dart';
import '/base/warna.dart';

import '../../folderUmum/chat/view/chatDetailPage.dart';

class DataAgenku extends StatefulWidget {
  @override
  _DataAgenkuState createState() => _DataAgenkuState();
}

class _DataAgenkuState extends State<DataAgenku> {
  final c = Get.find<ApiService>();
  var paginate = 0;

  @override
  void initState() {
    super.initState();
    loadDataAgen(paginate);
  }

  loadDataAgen(halaman) async {
    //LOAD DATA TOPUP
    EasyLoading.show(status: 'Mencari Agen...');

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    //item search
    var nama = textController.text;

    var datarequest = '{"pid":"$pid","skip":"$halaman","nama":"$nama"}';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse('${c.baseURL}/agensi/dataAgen');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        paginate = paginate + 1;
        setState(() {
          dataFollowers = hasil['data'];
          // listdaftar();
        });
      }
    }
    //END LOAD DATA TOP UP
  }

  List<dynamic> dataFollowers = [].obs;
  List<Container> listbank = [];
  listdaftar() {
    if (dataFollowers.length > 0) {
      for (var i = 0; i < dataFollowers.length; i++) {
        var foll = dataFollowers[i];
        String kodess = foll[2];
        listbank.add(
          Container(
            child: SizedBox(
                height: Get.height * 0.12,
                child: Card(
                  elevation: 0.3,
                  child: Container(
                    padding: EdgeInsets.only(left: 5, right: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            kodeSSpilihan.value = kodess;
                            // detailOrang(i, kodess, foll[2], foll[0]);
                          },
                          child: Row(
                            children: [
                              Image(
                                  width: Get.width * 0.12,
                                  image: CachedNetworkImageProvider(
                                    'https://sasuka.online/sasuka.online/foto/${foll[1]}',
                                  )),
                              Padding(padding: EdgeInsets.only(left: 11)),
                              Container(
                                width: Get.width * 0.4,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      foll[0],
                                      style: TextStyle(
                                          fontSize: 15,
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
                            ],
                          ),
                        ),
                        Container(
                          child: IconButton(
                              icon: Icon(Icons.chat_rounded,
                                  size: 25, color: Warna.warnautama),
                              onPressed: () {
                                c.idChatLawan.value = foll[4];
                                c.namaChatLawan.value = foll[0];
                                c.fotoChatLawan.value =
                                    'https://sasuka.online/sasuka.online/foto/' +
                                        foll[1];
                                Get.to(() => ChatDetailPage());
                              }),
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

  var bisnisku = [];
  var dataku = [];
  var follbackangka = 0.obs;
  var kodeSSpilihan = ''.obs;
  var isLikeobs = false.obs;
  var indexing = 0;

  void detailOrang(indeks, ss, foto, nama) async {
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    //item search

    var datarequest = '{"pid":"$pid","kodess":"$ss"}';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse('${c.baseURL}/sasuka/detailFollow');

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
        bisnisku = hasil['bisnis'];
        isLikeobs.value = bisnisku[6];
      }
    }

    //VARIABEL LOVE
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 9, right: 9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      Get.back();
                    }),
              ],
            ),
          ),
          Image(
            width: Get.width * 0.55,
            image: CachedNetworkImageProvider(
                'https://sasuka.online/sasuka.online/foto/$foto'),
            fit: BoxFit.cover,
          ),
          Padding(padding: EdgeInsets.only(top: 9)),
          Row(
            children: [
              Container(
                width: Get.width * 0.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      nama,
                      style: TextStyle(
                          fontSize: 17,
                          color: Warna.grey,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      ss,
                      style: TextStyle(
                        fontSize: 18,
                        color: Warna.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(left: 9)),
              IconButton(
                  icon: Icon(
                    Icons.favorite,
                    size: 29,
                    color: Colors.pink,
                  ),
                  onPressed: () {
                    _onRefresh();
                    Get.back();
                  }),
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 22)),
          Divider(
            color: Warna.grey,
          ),
        ],
      ),
    )..show();
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    paginate = 0;
    listbank = [];
    dataFollowers = [];
    await loadDataAgen(paginate);
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await loadDataAgen(paginate);

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
            title: Text('Dashboard Agensi'), backgroundColor: Colors.amber),
        bottomNavigationBar: SizedBox(
          height: Get.height * 0.1,
          child: Container(
            padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Center(
                        child: Obx(() => Text(
                              c.jumlahAgen.value,
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber),
                            )),
                      ),
                      Center(
                        child: Text(
                          'Agen',
                          style: TextStyle(fontSize: 11, color: Warna.grey),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Center(
                        child: Obx(() => Text(
                              c.akumulasiPendapatanAgensi.value,
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber),
                            )),
                      ),
                      Center(
                        child: Text(
                          'Total Akumulasi Pendapatan Agensi',
                          style: TextStyle(fontSize: 11, color: Warna.grey),
                        ),
                      ),
                    ],
                  )
                ]),
          ),
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
                body = Text("Sepertinya semua agen telah ditampilkan");
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
              listdaftar(),
            ],
          ),
        ));
  }

  // from 1.5.0, it is not necessary to add this line
  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
