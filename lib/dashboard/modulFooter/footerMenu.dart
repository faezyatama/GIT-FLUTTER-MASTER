import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:satuaja/base/api_service.dart';
import '../../base/warna.dart';

class FooterMenuUtama extends StatefulWidget {
  @override
  State<FooterMenuUtama> createState() => _FooterMenuUtamaState();
}

class _FooterMenuUtamaState extends State<FooterMenuUtama> {
  final c = Get.find<ApiService>();

  var isiMenuContainer;

  List<TabItem> items = [
    TabItem(
        icon: Icon(
          Icons.shop,
          color: Colors.grey,
        ),
        title: 'Pesanan'),
    TabItem(
      icon: Icon(
        Icons.hail,
        color: Colors.grey,
      ),
      title: 'Antarin',
    ),
    TabItem(
      icon: Icon(
        Icons.home,
        color: Colors.grey,
      ),
      title: 'Beranda',
    ),
    TabItem(
      icon: Icon(
        Icons.assignment,
        color: Colors.grey,
      ),
      title: 'Transaksi',
    ),
    TabItem(
      icon: Icon(
        Icons.chat,
        color: Colors.grey,
      ),
      title: 'Chat',
    ),
  ];

  void _onItemTapped(int index) {
    if ((index == 4) && (c.tabsaatini.value != 4)) {
      c.tabsaatini.value = 4;
    } else if ((index == 2) && (c.tabsaatini.value != 2)) {
      c.tabsaatini.value = 2;
    } else if ((index == 0) && (c.tabsaatini.value != 0)) {
      c.tabsaatini.value = 0;
      c.indexTabPesanan.value = 0;
    } else if ((index == 1) && (c.tabsaatini.value != 1)) {
      c.tabsaatini.value = 1;
    } else if ((index == 3) && (c.tabsaatini.value != 3)) {
      c.tabsaatini.value = 3;
    }
  }

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
          backgroundColor: Colors.grey[100],
          color: Warna.grey,
          style: TabStyle.react,
          activeColor: Colors.amber,
          items: items,
          initialActiveIndex: c.selectedIndexBar.value,
          onTap: (int i) => _onItemTapped(i),
        ));
  }
}
