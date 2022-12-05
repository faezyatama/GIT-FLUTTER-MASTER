import 'dart:convert';
import 'package:anim_search_bar/anim_search_bar.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

class Subsriber2 extends StatefulWidget {
  @override
  _Subsriber2State createState() => _Subsriber2State();
}

class _Subsriber2State extends State<Subsriber2> {
  final c = Get.find<ApiService>();
  var suka = true.obs;
  var paginate = 0;

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
        '{"pid":"$pid","skip":"$halaman","nama":"$nama","follback":"$loveInt"}';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse('${c.baseURL}/sasuka/subscribers');

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
          dataFollowers = hasil['data'];
          // listdaftar();
        });
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
        String kodess = foll['kodepromo'];

        bool pilihsuka = false;
        if (foll['follback'] == 2) {
          pilihsuka = true;
        }

        listbank.add(
          Container(
            padding: EdgeInsets.only(left: 11, right: 11),
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
                            suka.value = pilihsuka;
                            detailOrang(
                                i, kodess, foll['foto'], foll['first_name']);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image(
                                  width: Get.width * 0.12,
                                  image: CachedNetworkImageProvider(
                                    'https://sasuka.online/sasuka.online/foto/${foll['foto']}',
                                  )),
                              Padding(padding: EdgeInsets.only(left: 11)),
                              Container(
                                width: Get.width * 0.55,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      foll['first_name'],
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
                              (dataFollowers[i]['follback'] == 2)
                                  ? Icon(
                                      Icons.favorite,
                                      size: 28,
                                      color: Colors.pink,
                                    )
                                  : Icon(
                                      Icons.favorite_border,
                                      size: 28,
                                      color: Colors.pink,
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

  void detailOrang(indeks, ss, foto, nama) {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
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
              GestureDetector(child: Icon(Icons.favorite)),
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 22)),
          Divider(
            color: Warna.grey,
          ),
          Text('yuk lihat bisnis yang aku lakukan :'),
          Padding(padding: EdgeInsets.only(top: 8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'images/whitelabelMainMenu/makangrey.png',
                width: Get.width * 0.1,
              ),
              Image.asset(
                'images/whitelabelMainMenu/freshmartgrey.png',
                width: Get.width * 0.1,
              ),
              Image.asset(
                'images/whitelabelMainMenu/mallgrey.png',
                width: Get.width * 0.1,
              ),
              Image.asset(
                'images/whitelabelMainMenu/samotorgrey.png',
                width: Get.width * 0.1,
              ),
              Image.asset(
                'images/whitelabelMainMenu/tokosekitargrey.png',
                width: Get.width * 0.1,
              ),
              Image.asset(
                'images/whitelabelMainMenu/ritzukagrey.png',
                width: Get.width * 0.1,
              ),
            ],
          )
        ],
      ),
    )..show();
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    paginate = 0;
    listbank = [];
    dataFollowers = [];
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
        title: Text('Subscribers ku'),
        backgroundColor: Warna.warnautama,
        actions: [
          IconButton(
              icon: Icon(iconlove, color: filterlove, size: 29),
              onPressed: () {
                paginate = 0;
                listbank = [];
                dataFollowers = [];
                setState(() {
                  if (loveInt == 0) {
                    filterlove = Colors.pink;
                    loveInt = 1;
                    iconlove = Icons.favorite_border;
                  } else if (loveInt == 1) {
                    filterlove = Colors.pink;
                    loveInt = 2;
                    iconlove = Icons.favorite;
                  } else {
                    filterlove = Colors.white;
                    loveInt = 0;
                    iconlove = Icons.favorite;
                  }
                  loadDataFollower(paginate);
                });
              }),
          Padding(padding: EdgeInsets.only(left: 9)),
          AnimSearchBar(
            suffixIcon: Icon(
              Icons.search,
              color: Warna.warnautama,
            ),
            autoFocus: true,
            closeSearchOnSuffixTap: true,
            prefixIcon: Icon(
              Icons.search,
              color: Warna.warnautama,
            ),
            width: Get.width * 0.6,
            textController: textController,
            onSuffixTap: () {
              paginate = 0;
              listbank = [];
              dataFollowers = [];
              setState(() {
                loadDataFollower(paginate);
                //print('cari objek ini');
                // textController.clear();
              });
            },
          ),
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
