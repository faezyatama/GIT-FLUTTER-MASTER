import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';

import 'daftarProdukMP.dart';
import 'tambahProdukMP.dart';

class ProdukMP extends StatefulWidget {
  @override
  _ProdukMPState createState() => _ProdukMPState();
}

class _ProdukMPState extends State<ProdukMP> {
  //BOTTOM NAVIGATION BAR
  // @override
  void initState() {
    super.initState();
  }

  final c = Get.find<ApiService>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: c.selectedIndexMPKU.value,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Produk'),
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
              DaftarProdukMP(),
              TambahProdukMP(),
            ],
          ),
        ));
  }
}
