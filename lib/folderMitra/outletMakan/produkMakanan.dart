import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';
import '/base/warna.dart';

import 'daftarProdukMakanan.dart';
import 'tambahProdukMakanan.dart';

class ProdukMakanan extends StatefulWidget {
  @override
  _ProdukMakananState createState() => _ProdukMakananState();
}

class _ProdukMakananState extends State<ProdukMakanan> {
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
            title: Text('Produk / Menu Makanan'),
            backgroundColor: Warna.warnautama,
            bottom: TabBar(
              indicatorColor: Colors.amber,
              tabs: [
                Tab(icon: Icon(Icons.menu_book), text: 'Produk / Menu'),
                Tab(icon: Icon(Icons.add), text: 'Tambah Baru'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              DaftarProdukMakanan(),
              TambahProdukMakanan(),
            ],
          ),
        ));
  }
}
