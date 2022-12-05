import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';
import '/base/warna.dart';

import 'laporanOffline.dart';
import 'laporanOnline.dart';

class LaporanMakanan extends StatefulWidget {
  @override
  _LaporanMakananState createState() => _LaporanMakananState();
}

class _LaporanMakananState extends State<LaporanMakanan> {
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
            title: Text('Laporan penjualan makanan'),
            backgroundColor: Warna.warnautama,
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
              LaporanOnlineMakanan(),
              LaporanOfflineMakanan(),
            ],
          ),
        ));
  }
}
