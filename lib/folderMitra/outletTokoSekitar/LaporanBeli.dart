import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';
import 'laporanBeliKonsinyasi.dart';
import 'laporanBeliKredit.dart';
import 'laporanBeliLunas.dart';

class LaporanPembelianProduk extends StatefulWidget {
  @override
  _LaporanPembelianProdukState createState() => _LaporanPembelianProdukState();
}

class _LaporanPembelianProdukState extends State<LaporanPembelianProduk> {
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
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Laporan Pembelian/Stok'),
            backgroundColor: Colors.green,
            bottom: TabBar(
              indicatorColor: Colors.amber,
              tabs: [
                Tab(icon: Icon(Icons.online_prediction), text: 'Lunas'),
                Tab(icon: Icon(Icons.local_mall), text: 'Kredit'),
                Tab(icon: Icon(Icons.local_mall), text: 'Konsinyasi'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              LaporanBeliLunas(),
              LaporanBeliKredit(),
              LaporanBeliKonsinyasi(),
            ],
          ),
        ));
  }
}
