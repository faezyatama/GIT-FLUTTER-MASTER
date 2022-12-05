import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';
import 'orderKirimTS.dart';
import 'orderMasukTS.dart';
import 'orderProsesTS.dart';
import 'orderSelesaiTS.dart';

class PesananTS extends StatefulWidget {
  @override
  _PesananTSState createState() => _PesananTSState();
}

class _PesananTSState extends State<PesananTS> {
  //BOTTOM NAVIGATION BAR
  // @override
  void initState() {
    super.initState();
  }

  final c = Get.find<ApiService>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: c.selectedIndexOrderTSKU.value,
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Pesanan / Order'),
            backgroundColor: Colors.green,
            bottom: TabBar(
              isScrollable: true,
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
              OrderMasukTS(),
              OrderProsesTS(),
              OrderKirimTS(),
              OrderSelesaiTS(),
            ],
          ),
        ));
  }
}
