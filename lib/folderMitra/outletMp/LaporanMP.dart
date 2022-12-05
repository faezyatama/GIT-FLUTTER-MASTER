import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';

import 'LaporanOfflineMP.dart';
import 'LaporanOnlineMP.dart';

class LaporanMP extends StatefulWidget {
  @override
  _LaporanMPState createState() => _LaporanMPState();
}

class _LaporanMPState extends State<LaporanMP> {
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
            title: Text('Laporan penjualan marketplace'),
            backgroundColor: Colors.blue,
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
              LaporannOnlineMP(),
              LaporannOfflineMP(),
            ],
          ),
        ));
  }
}
