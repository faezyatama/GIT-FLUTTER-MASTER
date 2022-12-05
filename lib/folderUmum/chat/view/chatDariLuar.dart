import 'dart:async';
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/camera/LuarGaleriChatSupport.dart';

import '../models/chatMessegeModel.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

class LuarLiveSupportChatDetailPage extends StatefulWidget {
  @override
  _LuarLiveSupportChatDetailPageState createState() =>
      _LuarLiveSupportChatDetailPageState();
}

class _LuarLiveSupportChatDetailPageState
    extends State<LuarLiveSupportChatDetailPage> {
  @override
  void initState() {
    super.initState();
    detailPageChat();
    timeDetailChat =
        Timer.periodic(Duration(seconds: 10), (Timer t) => detailPageChat());
  }

  @override
  void dispose() {
    super.dispose();
    timeDetailChat?.cancel();
  }

  final c = Get.find<ApiService>();
  final controllerPesan = TextEditingController();
  Timer timeDetailChat;
  var idChatLawan = '';

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  void _onRefresh() async {
    // monitor network fetch

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch

    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  var paginate = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 2,
                ),
                CircleAvatar(
                  backgroundImage:
                      AssetImage('images/whitelabelUtama/logo.png'),
                  maxRadius: 20,
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: Get.width * 0.65,
                        child: Text(
                          '${c.namaAplikasi} Live Support',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Obx(() => Text(
                            c.statusChatLawan.value,
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13),
                          )),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    AwesomeDialog(
                        context: Get.context,
                        dialogType: DialogType.noHeader,
                        animType: AnimType.rightSlide,
                        title: 'Layanan Pelanggan',
                        desc:
                            'Ini adalah layanan Pelanggan untuk aplikasi ${c.namaAplikasi}, Apabila ada kendala kamu dapat menghubungi kami melalui fitur Live Support ini',
                        btnOkText: 'Terima Kasih',
                        btnOkOnPress: () {})
                      ..show();
                  },
                  child: Icon(
                    Icons.verified_user,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SmartRefresher(
        enablePullDown: false,
        enablePullUp: true,
        header: WaterDropHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: ListView(
          reverse: true,
          children: <Widget>[
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        //============= GANTI KIRIM FOTO =============
                        Get.to(() => LuarGaleriChatSupport());
                      },
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: TextField(
                        controller: controllerPesan,
                        decoration: InputDecoration(
                            hintText: "Tulis pesan...",
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        if (controllerPesan.text != '') {
                          kirimChat();
                        } else {
                          Get.snackbar('Tidak Terkirim',
                              'Opps...sepertinya tidak ada pesan yang dikirim',
                              snackPosition: SnackPosition.BOTTOM);
                        }
                      },
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                      backgroundColor: Colors.blue,
                      elevation: 0,
                    ),
                  ],
                ),
              ),
            ),
            ListView.builder(
              itemCount: messages.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 10, bottom: 10),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  padding:
                      EdgeInsets.only(left: 14, right: 14, top: 3, bottom: 3),
                  child: Align(
                    alignment: (messages[index].messageType == "receiver"
                        ? Alignment.topLeft
                        : Alignment.topRight),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: (messages[index].messageType == "receiver"
                              ? Colors.grey.shade200
                              : Colors.blue[200]),
                        ),
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: (messages[index].messegePicture == '')
                            ? Text(
                                messages[index].messageContent,
                                style: TextStyle(fontSize: 15),
                              )
                            : Column(
                                children: [
                                  Image.network(
                                    messages[index].messegePicture,
                                    width: Get.width * 0.7,
                                  ),
                                  Text(
                                    messages[index].messageContent,
                                    style: TextStyle(fontSize: 15),
                                  )
                                ],
                              )),
                  ),
                );
              },
            ),
            Padding(padding: EdgeInsets.only(top: 55)),
          ],
        ),
      ),
    );
  }

  detailPageChat() async {
    bool conn = await cekInternet();
    if (conn) {
      Box dbbox = Hive.box<String>('sasukaDB');
      var pid = dbbox.get('appid');
      var idlawan = 'SUPPORT';
      var user = 'Non Registered User';
      var datarequest =
          '{"pid":"$pid","skip":"$paginate","idlawan":"$idlawan"}';
      var bytes = utf8.encode(datarequest + 'cbf4aq3' + user + c.appid);
      var signature = md5.convert(bytes).toString();

      var url = Uri.parse('${c.baseURLchat}/mobileApps/detailChatSupportTamu');

      final response = await http.post(url, body: {
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
          paginate++;
          if (mounted) {
            setState(() {
              dataChat = hasil['data'];
              c.statusChatLawan.value = hasil['terakhirOnline'];
              idChatLawan = hasil['idchatLawan'];
              messages = [];
              buatdatachat();
            });
          }
        } else if (hasil['status'] == 'no data') {}
      }
    }
  }

  List dataChat = [];
  List<ChatMessage> messages = [];
  void buatdatachat() {
    for (var a = 0; a < dataChat.length; a++) {
      var data = dataChat[a];
      messages.add(ChatMessage(
          messageContent: data[0],
          messageType: data[1],
          messegePicture: data[2]));
    }
  }

  kirimChat() async {
    bool conn = await cekInternet();
    if (conn) {
      Box dbbox = Hive.box<String>('sasukaDB');
      var pid = dbbox.get('appid');
      var idlawan = 'SUPPORT';
      var user = 'Non Registered User';

      var pesan = controllerPesan.text;
      var datarequest = '{"pid":"$pid","idlawan":"$idlawan","pesan":"$pesan"}';
      var bytes = utf8.encode(datarequest + 'cbf4aq3' + user + c.appid);
      var signature = md5.convert(bytes).toString();

      var url = Uri.parse('${c.baseURLchat}/mobileApps/sendChatSupportTamu');

      final response = await http.post(url, body: {
        "user": user,
        "appid": c.appid,
        "data_request": datarequest,
        "sign": signature,
        "package": c.packageName
      });

      controllerPesan.text = '';
      // EasyLoading.dismiss();
      print(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> hasil = jsonDecode(response.body);
        if (hasil['status'] == 'success') {
          if (mounted) {
            setState(() {
              messages = [];
              dataChat = [];
              dataChat = hasil['data'];

              buatdatachat();
            });
          }
        } else if (hasil['status'] == 'no data') {}
      }
    }
  }
}
