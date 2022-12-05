import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';

import 'daftarProdukFM.dart';
import 'tambahProdukFM.dart';

class ProdukFM extends StatefulWidget {
  @override
  _ProdukFMState createState() => _ProdukFMState();
}

class _ProdukFMState extends State<ProdukFM> {
  //BOTTOM NAVIGATION BAR
  // @override
  void initState() {
    super.initState();
  }

  final c = Get.find<ApiService>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: c.selectedIndexFMKU.value,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Produk Freshmart'),
            backgroundColor: Colors.green,
            bottom: TabBar(
              indicatorColor: Colors.amber,
              tabs: [
                Tab(icon: Icon(Icons.menu_book), text: 'Produk'),
                Tab(icon: Icon(Icons.add), text: 'Tambah Baru'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              DaftarProdukFM(),
              TambahProdukFM(),
            ],
          ),
        ));
  }
}
