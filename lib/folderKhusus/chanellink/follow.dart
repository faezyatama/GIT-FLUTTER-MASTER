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

import '../../folderUmum/chat/view/chatDetailPage.dart';

class Follow extends StatefulWidget {
  @override
  _FollowState createState() => _FollowState();
}

class _FollowState extends State<Follow> {
  final controllerSS = TextEditingController();

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

    var url = Uri.parse('${c.baseURL}/sasuka/datafollow');

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

  List<dynamic> dataFollowers = [].obs;
  List<Container> listbank = [];
  listdaftar() {
    if (dataFollowers.length > 0) {
      for (var i = 0; i < dataFollowers.length; i++) {
        var foll = dataFollowers[i];
        String kodess = foll[2];
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
                        Container(
                          child: IconButton(
                              icon: Icon(Icons.assignment_turned_in,
                                  size: 25, color: Colors.green),
                              onPressed: () {
                                kodeSSpilihan.value = kodess;
                                indexing = i;
                                detailOrang(i, kodess, foll[1], foll[0]);
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
                    onLikeButtonTapped();
                    _onRefresh();
                    Get.back();
                  }),
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 22)),
          Divider(
            color: Warna.grey,
          ),
          //   Text('yuk lihat bisnis yang aku lakukan :'),
          //   Padding(padding: EdgeInsets.only(top: 8)),
          //   Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       (bisnisku[0] == 0)
          //           ? Image.asset(
          //               'images/whitelabelMainMenu/makangrey.png',
          //               width: Get.width * 0.1,
          //             )
          //           : Image.asset(
          //               'images/whitelabelMainMenu/makan.png',
          //               width: Get.width * 0.1,
          //             ),
          //       (bisnisku[1] == 0)
          //           ? Image.asset(
          //               'images/whitelabelMainMenu/freshmartgrey.png',
          //               width: Get.width * 0.1,
          //             )
          //           : Image.asset(
          //               'images/whitelabelMainMenu/freshmart.png',
          //               width: Get.width * 0.1,
          //             ),
          //       (bisnisku[2] == 0)
          //           ? Image.asset(
          //               'images/whitelabelMainMenu/mallgrey.png',
          //               width: Get.width * 0.1,
          //             )
          //           : Image.asset(
          //               'images/whitelabelMainMenu/mall.png',
          //               width: Get.width * 0.1,
          //             ),
          //       (bisnisku[3] == 0)
          //           ? Image.asset(
          //               'images/whitelabelMainMenu/samotorgrey.png',
          //               width: Get.width * 0.1,
          //             )
          //           : Image.asset(
          //               'images/whitelabelMainMenu/samotor.png',
          //               width: Get.width * 0.1,
          //             ),
          //       (bisnisku[4] == 0)
          //           ? Image.asset(
          //               'images/whitelabelMainMenu/ritzukagrey.png',
          //               width: Get.width * 0.1,
          //             )
          //           : Image.asset(
          //               'images/whitelabelMainMenu/ritzuka.png',
          //               width: Get.width * 0.1,
          //             ),
          //       (bisnisku[5] == 0)
          //           ? Image.asset(
          //               'images/whitelabelMainMenu/tokosekitargrey.png',
          //               width: Get.width * 0.1,
          //             )
          //           : Image.asset(
          //               'images/whitelabelMainMenu/tokosekitar.png',
          //               width: Get.width * 0.1,
          //             ),
          //     ],
          //   )
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
    await loadDataFollower(paginate);
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
        title: Text('I like to Follow'),
        backgroundColor: Warna.warnautama,
        actions: [
          IconButton(
              icon: Icon(Icons.add, color: Colors.white, size: 29),
              onPressed: () {
                tambahkanFollow();
              }),
          Padding(padding: EdgeInsets.only(left: 5)),
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
          Padding(padding: EdgeInsets.only(left: 5)),
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
              });
            },
          ),
        ],
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

  void onLikeButtonTapped() async {
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    //item search
    var lov = isLikeobs.value;
    var loveSS = kodeSSpilihan.value;
    var datarequest = '{"pid":"$pid","kodess":"$loveSS","follback":"$lov" }';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse('${c.baseURL}/sasuka/follow');

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
        if (mounted) {
          follbackangka.value = hasil['follback'];
          c.follow.value = hasil['follow'].toString();
          c.follower.value = hasil['follower'].toString();

          Get.snackbar('Un Follow', 'Un Follow berhasil dilakukan',
              colorText: Colors.white,
              duration: Duration(milliseconds: 1700),
              animationDuration: Duration(milliseconds: 250));
        }
      }
    }
    isLikeobs.value = false;
  }

  void tambahkanFollow() {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(7, 5, 7, 0),
            child: TextField(
              maxLength: 8,
              controller: controllerSS,
              decoration: InputDecoration(
                  labelText: 'Kode Anggota',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 9)),
          Divider(
            color: Warna.grey,
          ),
          Text('Masukan Kode Anggota untuk follow teman kamu'),
          Padding(padding: EdgeInsets.only(top: 8)),
          ElevatedButton(
              onPressed: () {
                if (controllerSS.text.length == 8) {
                  periksaKodeSS();
                } else {
                  Get.snackbar(
                      'Error', 'Kode Anggota yang dimasukkan tidak sesuai',
                      colorText: Colors.white);
                }
              },
              child: Text('Periksa Kode Anggota')),
        ],
      ),
    )..show();
  }

  void periksaKodeSS() async {
    var kodess = controllerSS.text;

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    //item search

    var datarequest = '{"pid":"$pid","kodess":"$kodess"}';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse('${c.baseURL}/sasuka/cekSS');

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
        controllerSS.text = '';
        var dataku = hasil['data'];

        Get.back();
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: '',
          desc: '',
          body: Column(
            children: [
              Image.network(
                'https://sasuka.online/sasuka.online/foto/${dataku[2]}',
                width: Get.width * 0.4,
              ),
              Padding(padding: EdgeInsets.only(top: 9)),
              Text(dataku[0],
                  style: TextStyle(
                      fontSize: 18,
                      color: Warna.grey,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
              Text(
                dataku[1],
                style: TextStyle(fontSize: 14, color: Warna.grey),
              ),
              Divider(
                color: Warna.grey,
              ),
              Text(
                  'Kamu akan mengikuti ${dataku[0]}, dan mendapatkan berita terbaru darinya',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center),
              Padding(padding: EdgeInsets.only(top: 8)),
              ElevatedButton(
                  onPressed: () {
                    ikutiTemanSayaSekarang(dataku[1]);
                  },
                  child: Text('Ikuti Teman Saya')),
            ],
          ),
        )..show();
      } else {
        controllerSS.text = '';
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.warning,
          animType: AnimType.rightSlide,
          title: 'Pencarian Gagal',
          desc:
              'Opps... sepertinya Kode Anggota yang kamu masukan tidak sesuai',
          btnCancelText: 'OK SIAP',
          btnCancelColor: Colors.amber,
          btnCancelOnPress: () {},
        )..show();
      }
    }
  }

  void ikutiTemanSayaSekarang(kodessteman) async {
//BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    //item search
    var datarequest = '{"pid":"$pid","kodess":"$kodessteman"}';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse('${c.baseURL}/sasuka/followNow');

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
        c.follow.value = hasil['follow'].toString();
        c.follower.value = hasil['follower'].toString();
        _onRefresh();
        Get.back();
      } else {
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.warning,
          animType: AnimType.rightSlide,
          title: 'GAGAL MENGIKUTI',
          desc: 'Opps... Gagal Mengikuti teman kamu',
          btnCancelText: 'OK SIAP',
          btnCancelColor: Colors.amber,
          btnCancelOnPress: () {},
        )..show();
      }
    }
  }
}
