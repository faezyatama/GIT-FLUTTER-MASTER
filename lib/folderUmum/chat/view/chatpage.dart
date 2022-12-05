import 'dart:async';
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';

import '../models/chatUsersModel.dart';
import '../widgets/conversationList.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Timer listChat;
  @override
  void initState() {
    super.initState();
    cekDaftarChatAku();
    listChat =
        Timer.periodic(Duration(seconds: 10), (Timer t) => cekDaftarChatAku());
  }

  @override
  void dispose() {
    super.dispose();
    listChat?.cancel();
  }

  var paginate = 0;
  var dataCari = false;
  final c = Get.find<ApiService>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 33, left: 16, right: 16),
              child: TextField(
                onChanged: (valu) {
                  setState(() {
                    if (valu.length > 0) {
                      dataCari = true;
                      buatdatachatFilter(valu);
                    } else {
                      dataCari = false;
                    }
                  });
                },
                decoration: InputDecoration(
                  hintText: "Cari chat...",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey.shade100)),
                ),
              ),
            ),
            (dataCari == false)
                ? ListView.builder(
                    itemCount: chatUsers.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 16),
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Container(
                        child: GestureDetector(
                          onLongPress: () {
                            AwesomeDialog(
                                context: Get.context,
                                dialogType: DialogType.noHeader,
                                animType: AnimType.rightSlide,
                                title: 'HAPUS CHAT',
                                desc: 'Apakah kamu akan menghapus chat ini?',
                                btnCancelText: 'Hapus',
                                btnCancelOnPress: () {
                                  hapusChat(chatUsers[index].idlawan);
                                },
                                btnOkText: 'Tidak',
                                btnOkOnPress: () {})
                              ..show();
                          },
                          child: Container(
                            child: ConversationList(
                              name: chatUsers[index].name,
                              messageText: chatUsers[index].messageText,
                              imageUrl: chatUsers[index].imageURL,
                              time: chatUsers[index].time,
                              idlawan: chatUsers[index].idlawan,
                              dibaca: chatUsers[index].dibaca,
                              isMessageRead: false,
                              // (index == 0 || index == 3) ? true : false,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: chatUsersFilter.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 16),
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Container(
                        child: GestureDetector(
                          onLongPress: () {
                            AwesomeDialog(
                                context: Get.context,
                                dialogType: DialogType.noHeader,
                                animType: AnimType.rightSlide,
                                title: 'HAPUS CHAT',
                                desc: 'Apakah kamu akan menghapus chat ini?',
                                btnCancelText: 'Hapus',
                                btnCancelOnPress: () {
                                  hapusChat(chatUsersFilter[index].idlawan);
                                },
                                btnOkText: 'Tidak',
                                btnOkOnPress: () {})
                              ..show();
                          },
                          child: Container(
                            child: ConversationList(
                              name: chatUsersFilter[index].name,
                              messageText: chatUsersFilter[index].messageText,
                              imageUrl: chatUsersFilter[index].imageURL,
                              time: chatUsersFilter[index].time,
                              idlawan: chatUsersFilter[index].idlawan,
                              dibaca: chatUsersFilter[index].dibaca,
                              isMessageRead: false,
                              // (index == 0 || index == 3) ? true : false,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  List dataChat = [];
  List<ChatUsers> chatUsers = [];

  List<ChatUsers> chatUsersFilter = [];
  buatdatachatFilter(cari) {
    chatUsersFilter = [];
    for (var a = 0; a < dataChat.length; a++) {
      var data = dataChat[a];
      var namaCari = data[1].toUpperCase();
      var filterCari = cari.toUpperCase();

      if (namaCari.contains(filterCari)) {
        chatUsersFilter.add(ChatUsers(
            name: data[1],
            messageText: data[2],
            imageURL: data[3],
            time: data[4],
            idlawan: data[5],
            dibaca: data[8]));
      }
    }
  }

  buatdatachat() {
    chatUsers = [];
    for (var a = 0; a < dataChat.length; a++) {
      var data = dataChat[a];

      chatUsers.add(ChatUsers(
          name: data[1],
          messageText: data[2],
          imageURL: data[3],
          time: data[4],
          idlawan: data[5],
          dibaca: data[8]));
    }
  }

  cekDaftarChatAku() async {
    bool conn = await cekInternet();
    if (conn) {
      Box dbbox = Hive.box<String>('sasukaDB');
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');
      var user = dbbox.get('loginSebagai');

      var datarequest = '{"pid":"$pid","skip":"$paginate"}';
      var bytes = utf8.encode(datarequest + '$token' + user);
      var signature = md5.convert(bytes).toString();

      var url = Uri.parse('${c.baseURLchat}/mobileApps/listChat');

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
              dataCari = false;
              dataChat = hasil['data'];
              buatdatachat();
            });
          }
        } else if (hasil['status'] == 'no data') {}
      }
    }
  }

  void hapusChat(String idlawan) async {
    bool conn = await cekInternet();
    if (conn) {
      Box dbbox = Hive.box<String>('sasukaDB');
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');
      var user = dbbox.get('loginSebagai');

      var datarequest = '{"pid":"$pid","idLawan":"$idlawan"}';
      var bytes = utf8.encode(datarequest + '$token' + user);
      var signature = md5.convert(bytes).toString();

      var url = Uri.parse('${c.baseURLchat}/mobileApps/hapusChat');

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
          cekDaftarChatAku();
        }
      }
    }
  }
}
