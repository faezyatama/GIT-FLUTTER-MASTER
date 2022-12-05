import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';

import 'orderKirimFM.dart';
import 'orderMasukFM.dart';
import 'orderProsesFM.dart';
import 'orderSelesaiFM.dart';

class PesananFM extends StatefulWidget {
  @override
  _PesananFMState createState() => _PesananFMState();
}

class _PesananFMState extends State<PesananFM> {
  //BOTTOM NAVIGATION BAR
  // @override
  void initState() {
    super.initState();
  }

  final c = Get.find<ApiService>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: c.selectedIndexOrderFMKU.value,
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Pesanan / Order'),
            backgroundColor: Colors.green,
            bottom: TabBar(
              indicatorColor: Colors.amber,
              tabs: [
                Obx(() => Tab(
                    icon: Icon(Icons.shopping_cart), text: c.stMasukFM.value)),
                Obx(() => Tab(
                    icon: Icon(Icons.engineering), text: c.stProsesFM.value)),
                Obx(() => Tab(
                    icon: Icon(Icons.emoji_transportation),
                    text: c.stKirimFM.value)),
                Tab(icon: Icon(Icons.verified), text: 'Selesai'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              OrderMasukFM(),
              OrderProsesFM(),
              OrderKirimFM(),
              OrderSelesaiFM(),
            ],
          ),
        ));
  }
}
