import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import 'mutasipascabayar.dart';
import 'mutasipln.dart';
import 'mutasipulsa.dart';
import 'mutasisaldo.dart';

class Transaksiku extends StatefulWidget {
  @override
  _TransaksikuState createState() => _TransaksikuState();
}

class _TransaksikuState extends State<Transaksiku> {
  //BOTTOM NAVIGATION BAR

  final c = Get.find<ApiService>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Transaksi kamu'),
            backgroundColor: Warna.warnautama,
            bottom: TabBar(
              isScrollable: true,
              indicatorColor: Colors.amber,
              tabs: [
                Tab(icon: Icon(Icons.exit_to_app), text: 'Saldo'),
                Tab(icon: Icon(Icons.phone), text: 'Prabayar'),
                Tab(icon: Icon(Icons.water_damage), text: 'PLN'),
                Tab(icon: Icon(Icons.how_to_vote), text: 'PascaBayar'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              MutasiSaldo(),
              MutasiPulsa(),
              MutasiPln(),
              MutasiPascabayar(),
            ],
          ),
        ));
  }
}
