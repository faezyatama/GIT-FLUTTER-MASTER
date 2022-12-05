import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';
import '/base/warna.dart';

import 'antaranBerlangsung.dart';
import 'antaranSelesai.dart';

class Antarin extends StatefulWidget {
  @override
  _AntarinState createState() => _AntarinState();
}

class _AntarinState extends State<Antarin> {
  //BOTTOM NAVIGATION BAR
  // @override
  void initState() {
    super.initState();
  }

  final c = Get.find<ApiService>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Antarin'),
            backgroundColor: Warna.warnautama,
            bottom: TabBar(
              indicatorColor: Colors.amber,
              tabs: [
                Tab(icon: Icon(Icons.motorcycle), text: 'Perjalanan kamu'),
                Tab(icon: Icon(Icons.history_edu), text: 'History'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              AntaranBerlangsung(),
              AntaranSelesai(),
            ],
          ),
        ));
  }
}
