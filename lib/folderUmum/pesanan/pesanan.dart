import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import 'berlangsungFreshmart.dart';
import 'berlangsungMakanan.dart';
import 'berlangsungMarketplace.dart';
import 'berlangsungTokoSekitar.dart';

import 'historyPesanan.dart';

class Pesananku extends StatefulWidget {
  @override
  _PesanankuState createState() => _PesanankuState();
}

class _PesanankuState extends State<Pesananku> with TickerProviderStateMixin {
  //BOTTOM NAVIGATION BAR

  @override
  void initState() {
    super.initState();
    _controller = new TabController(
        length: 4, vsync: this, initialIndex: c.indexTabPesanan.value);
  }

  TabController _controller;

  final c = Get.find<ApiService>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Pesanan Berlangsung'),
            actions: [
              Row(
                children: [
                  Text(
                    'History',
                    style: TextStyle(color: Colors.white, fontSize: 9),
                  ),
                  IconButton(
                      onPressed: () {
                        Get.to(() => HistoryPesananku());
                      },
                      icon: Icon(Icons.move_to_inbox)),
                ],
              ),
            ],
            backgroundColor: Warna.warnautama,
            bottom: TabBar(
              indicatorColor: Colors.amber,
              isScrollable: true,
              controller: _controller,
              tabs: [
                Tab(icon: Icon(Icons.food_bank), text: 'Makanan'),
                Tab(icon: Icon(Icons.bug_report), text: 'Freshmart'),
                Tab(icon: Icon(Icons.mediation), text: 'Marketplace'),
                Tab(icon: Icon(Icons.shopping_basket), text: 'TokoSekitar'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _controller,
            children: [
              PesananBerlangsungMakanan(),
              PesananBerlangsungFreshmart(),
              PesananBerlangsungMarketplace(),
              PesananBerlangsungTokoSekitar(),
            ],
          ),
        ));
  }
}
