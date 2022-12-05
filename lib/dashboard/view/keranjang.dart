import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/warna.dart';

import '../../folderUmum/antarin/antarin.dart';
import '../../folderUmum/chat/view/homechat.dart';
import '../../folderUmum/pesanan/pesanan.dart';
import '../../folderUmum/transaksi/transaksi.dart';

class Keranjang extends StatefulWidget {
  @override
  _KeranjangState createState() => _KeranjangState();
}

class _KeranjangState extends State<Keranjang> {
  //BOTTOM NAVIGATION BAR
  int _selectedIndex = 3;
  void _onItemTapped(int index) {
    setState(() {
      if (index == 0) {
        Get.back();
      } else if (index == 1) {
        Get.off(Pesananku());
      } else if (index == 2) {
        Get.off(Antarin());
      } else if (index == 3) {
        Get.off(Transaksiku());
      } else if (index == 4) {
        Get.off(ChatApp());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Keranjang'),
          backgroundColor: Warna.warnautama,
        ),
        body: Container(
          child: Stack(
            children: [
              //LIST VIEW

              ListView(
                children: [],
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shop),
              label: 'Pesanan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.hail),
              label: 'Antarin',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Transaksi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chat',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
        ));
  }
}
