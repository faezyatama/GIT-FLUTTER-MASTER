import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';
import '/base/warna.dart';

import '../view/chatDetailPage.dart';

// ignore: must_be_immutable
class ConversationList extends StatefulWidget {
  String name;
  String messageText;
  String imageUrl;
  String time;
  bool isMessageRead;
  String idlawan;
  String dibaca;

  ConversationList(
      {this.name,
      this.messageText,
      this.imageUrl,
      this.time,
      this.isMessageRead,
      this.idlawan,
      this.dibaca});
  @override
  _ConversationListState createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  final c = Get.find<ApiService>();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        c.idChatLawan.value = widget.idlawan;
        c.namaChatLawan.value = widget.name;
        c.fotoChatLawan.value = widget.imageUrl;
        Get.to(() => ChatDetailPage());
      },
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.imageUrl),
                    maxRadius: Get.width * 0.06,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.name,
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Text(
                            widget.messageText,
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: widget.isMessageRead
                                    ? FontWeight.bold
                                    : FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  widget.time,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: widget.isMessageRead
                          ? FontWeight.bold
                          : FontWeight.normal),
                ),
                (widget.dibaca != '')
                    ? RawMaterialButton(
                        onPressed: () {},
                        constraints: BoxConstraints(),
                        elevation: 0,
                        fillColor: Colors.green,
                        child: Text(
                          widget.dibaca,
                          style: TextStyle(color: Warna.putih, fontSize: 10),
                        ),
                        padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9)),
                        ),
                      )
                    : Container()
              ],
            ),
          ],
        ),
      ),
    );
  }
}
