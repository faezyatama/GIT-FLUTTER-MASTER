import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';

import '../../base/api_service.dart';
import '../../base/warna.dart';
import 'headeratas.dart';

// ignore: must_be_immutable
class HeaderUtamaAtas extends StatelessWidget {
  final c = Get.find<ApiService>();
  var scaffoldKey = GlobalKey<ScaffoldState>();

  void openDrawer() {
    scaffoldKey.currentState.openDrawer();
  }

  void closeDrawer() {
    scaffoldKey.currentState.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        height: Get.height * 0.125,
        padding: EdgeInsets.fromLTRB(10, Get.height * 0.025, 5, 5),
        color: Warna.putih,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    openDrawer();
                  },
                  child: Obx(() => Container(
                      width: Get.width * 0.11,
                      height: Get.width * 0.11,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: NetworkImage(c.foto.value),
                            fit: BoxFit.cover),
                      ))),
                ),
                Padding(padding: EdgeInsets.only(left: 2, right: 2)),
                Container(
                  width: Get.width * 0.43,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(() => Text(
                            c.namaPenggunaKita.value,
                            overflow: TextOverflow.fade,
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Warna.grey),
                          )),
                      Obx(() => Text(
                            c.ssPenggunaKita.value,
                            style: TextStyle(fontSize: 11, color: Warna.grey),
                          ))
                    ],
                  ),
                ),
              ],
            ),
            HeaderAtas(),
          ],
        ),
      ), // BUKA DRAWAL
      Obx(() => Container(
          height: Get.height * 0.02,
          margin: EdgeInsets.fromLTRB(6, 0, 11, 6),
          color: Colors.grey[100],
          child: Marquee(
            text: c.scrollTextSHU.value,
            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 10),
            scrollAxis: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            blankSpace: 20.0,
            velocity: 35.0,
            startPadding: 10.0,
            accelerationCurve: Curves.linear,
            decelerationCurve: Curves.easeOut,
          ))),
    ]);
  }
}
