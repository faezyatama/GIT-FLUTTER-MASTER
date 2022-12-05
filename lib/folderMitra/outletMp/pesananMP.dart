import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';

import 'orderKirimMP.dart';
import 'orderMasukMP.dart';
import 'orderProsesMP.dart';
import 'orderSelesaiMP.dart';

class PesananMP extends StatefulWidget {
  @override
  _PesananMPState createState() => _PesananMPState();
}

class _PesananMPState extends State<PesananMP> {
  //BOTTOM NAVIGATION BAR
  // @override
  void initState() {
    super.initState();
  }

  final c = Get.find<ApiService>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: c.selectedIndexOrderMPKU.value,
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Pesanan / Order'),
            bottom: TabBar(
              indicatorColor: Colors.amber,
              tabs: [
                Obx(() => Tab(
                    icon: Icon(Icons.shopping_cart), text: c.stMasukMP.value)),
                Obx(() => Tab(
                    icon: Icon(Icons.engineering), text: c.stProsesMP.value)),
                Obx(() => Tab(
                    icon: Icon(Icons.emoji_transportation),
                    text: c.stKirimMP.value)),
                Tab(icon: Icon(Icons.verified), text: 'Selesai'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              OrderMasukMP(),
              OrderProsesMP(),
              OrderKirimMP(),
              OrderSelesaiMP(),
            ],
          ),
        ));
  }
}
