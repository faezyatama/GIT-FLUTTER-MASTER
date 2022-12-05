import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

import '../chat/view/homechat.dart';
import '../pesanan/pesanan.dart';
import '../transaksi/transaksi.dart';

class BottomNavigationAntarin extends StatefulWidget {
  @override
  _BottomNavigationAntarinState createState() =>
      _BottomNavigationAntarinState();
}

class _BottomNavigationAntarinState extends State<BottomNavigationAntarin> {
  //BOTTOM NAVIGATION BAR
  final c = Get.find<ApiService>();

  void _onItemTapped(int index) {
    if (index == 0) {
      Get.off(Pesananku());
    } else if (index == 1) {
    } else if (index == 2) {
      Get.back();
    } else if (index == 3) {
      Get.off(Transaksiku());
    } else if (index == 4) {
      Get.off(ChatApp());
    }
  }

  List<TabItem> items = [
    TabItem(
        icon: Icon(
          Icons.shop,
          color: Colors.white,
        ),
        title: 'Pesanan'),
    TabItem(
      icon: Icon(
        Icons.hail,
        color: Colors.white,
      ),
      title: 'Antarin',
    ),
    TabItem(
      icon: Icon(
        Icons.home,
        color: Colors.white,
      ),
      title: 'Beranda',
    ),
    TabItem(
      icon: Icon(
        Icons.assignment,
        color: Colors.white,
      ),
      title: 'Transaksi',
    ),
    TabItem(
      icon: Icon(
        Icons.chat,
        color: Colors.white,
      ),
      title: 'Chat',
    ),
  ];
  var badge = '';
  @override
  Widget build(BuildContext context) {
    return Obx(() => ConvexAppBar.badge(
          {
            0: '${c.pesananIndexBar.value}',
            1: '${c.antarinIndexBar.value}',
            4: '${c.chatIndexBar.value}'
          },
          badgeMargin: EdgeInsets.only(bottom: 11, left: 11),
          disableDefaultTabController: true,
          backgroundColor: Colors.grey,
          style: TabStyle.reactCircle,
          activeColor: Colors.grey[350],
          items: items,
          initialActiveIndex: 1,
          onTap: (int i) => _onItemTapped(i),
        ));
  }
}
