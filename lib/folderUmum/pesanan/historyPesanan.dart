import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import 'pesananSelesaiFM.dart';
import 'pesananSelesaiMP.dart';
import 'pesananSelesaiTS.dart';
import 'pesananselesai.dart';

class HistoryPesananku extends StatefulWidget {
  @override
  _HistoryPesanankuState createState() => _HistoryPesanankuState();
}

class _HistoryPesanankuState extends State<HistoryPesananku> {
  //BOTTOM NAVIGATION BAR

  @override
  void initState() {
    super.initState();
    // c.selectedIndexBar.value = 0;
  }

  final c = Get.find<ApiService>();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: Text('History Order'),
              actions: [
                Row(
                  children: [
                    Text(
                      'On Process',
                      style: TextStyle(color: Colors.white, fontSize: 9),
                    ),
                    IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: Icon(Icons.move_to_inbox)),
                  ],
                ),
              ],
              backgroundColor: Warna.grey,
              bottom: TabBar(
                indicatorColor: Colors.amber,
                isScrollable: true,
                tabs: [
                  Tab(icon: Icon(Icons.food_bank), text: 'Makanan'),
                  Tab(icon: Icon(Icons.bug_report), text: 'Freshmart'),
                  Tab(icon: Icon(Icons.mediation), text: 'Marketplace'),
                  Tab(icon: Icon(Icons.shopping_basket), text: 'TokoSekitar'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                PesananSelesaiMakanan(),
                PesananSelesaiFreshmart(),
                PesananSelesaiMarketPlace(),
                PesananSelesaiTokoSekitar(),
              ],
            ),
          )),
    );
  }
}
