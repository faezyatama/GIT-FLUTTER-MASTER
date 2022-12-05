import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';
import 'LaporanOfflineTS.dart';
import 'LaporanOnlineTS.dart';

class LaporanTS extends StatefulWidget {
  @override
  _LaporanTSState createState() => _LaporanTSState();
}

class _LaporanTSState extends State<LaporanTS> {
  //BOTTOM NAVIGATION BAR
  // @override
  void initState() {
    super.initState();
  }

  final c = Get.find<ApiService>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: c.selectedIndexMakanan.value,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Laporan penjualan Toko'),
            backgroundColor: Colors.green,
            bottom: TabBar(
              indicatorColor: Colors.amber,
              tabs: [
                Tab(icon: Icon(Icons.online_prediction), text: 'Online'),
                Tab(icon: Icon(Icons.local_mall), text: 'Offline'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              LaporannOnlineTS(),
              LaporannOfflineTS(),
            ],
          ),
        ));
  }
}
