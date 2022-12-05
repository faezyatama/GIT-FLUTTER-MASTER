import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';
import '/base/warna.dart';

import 'orderKirimMakanan.dart';
import 'orderMasukMakan.dart';
import 'orderProsesMakan.dart';
import 'orderSelesaiMakanan.dart';

class PesananMakanan extends StatefulWidget {
  @override
  _PesananMakananState createState() => _PesananMakananState();
}

class _PesananMakananState extends State<PesananMakanan> {
  //BOTTOM NAVIGATION BAR
  // @override
  void initState() {
    super.initState();
  }

  final c = Get.find<ApiService>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: c.selectedIndexOrderMakanan.value,
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Pesanan / Order'),
            backgroundColor: Warna.warnautama,
            bottom: TabBar(
              indicatorColor: Colors.amber,
              tabs: [
                Obx(() => Tab(
                    icon: Icon(Icons.shopping_cart), text: c.stMasukMK.value)),
                Obx(() => Tab(
                    icon: Icon(Icons.engineering), text: c.stProsesMK.value)),
                Obx(() => Tab(
                    icon: Icon(Icons.emoji_transportation),
                    text: c.stKirimMK.value)),
                Tab(icon: Icon(Icons.verified), text: 'Selesai'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              OrderMasukMakanan(),
              OrderProsesMakanan(),
              OrderKirimMakanan(),
              OrderSelesaiMakanan(),
            ],
          ),
        ));
  }
}
