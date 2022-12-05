import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../base/notifikasiBuatAkun.dart';
import '/base/api_service.dart';

import '../../folderUmum/keranjang/keranjang.dart';
import '../../folderUmum/notifikasi/notifikasi.dart';
import '../../folderUmum/payment/payment.dart';

// ignore: must_be_immutable
class HeaderAtas extends StatelessWidget {
  Box dbbox = Hive.box<String>('sasukaDB');
  final c = Get.find<ApiService>();
  //var _scanBarcode = '';

  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            c.selectedIndexBar.value = 2;
            Get.to(() => KeranjangBelanja());
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(7, 16, 7, 2),
            child: Obx(() => Badge(
                  elevation: 0,
                  position: BadgePosition.topEnd(top: 0, end: 3),
                  animationDuration: Duration(milliseconds: 300),
                  animationType: BadgeAnimationType.slide,
                  badgeColor: (c.keranjangIndexbar.value == '')
                      ? Colors.transparent
                      : Colors.red,
                  badgeContent: Text(
                    c.keranjangIndexbar.value,
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.shopping_cart, size: 25, color: Colors.grey),
                      Text(
                        'Cart',
                        style: TextStyle(fontSize: 9),
                      )
                    ],
                  ),
                )),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (c.loginAsPenggunaKita.value == 'Member') {
              Get.to(() => PaymentPoint());
            } else {
              var judulF = 'Bayar Tagihan ?';
              var subJudul =
                  'Berbagai tagihan dengan mudah dibayarkan dengan aplikasi ${c.namaAplikasi}, Yuk Buka akun ${c.namaAplikasi} sekarang';

              bukaLoginPage(judulF, subJudul);
            }
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(7, 16, 7, 2),
            child: Badge(
              elevation: 0,
              position: BadgePosition.topEnd(top: 0, end: 3),
              animationDuration: Duration(milliseconds: 300),
              animationType: BadgeAnimationType.slide,
              badgeColor: Colors.transparent,
              child: Column(
                children: [
                  Icon(Icons.qr_code, size: 25, color: Colors.grey),
                  Text(
                    'Pay',
                    style: TextStyle(fontSize: 9),
                  )
                ],
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            c.selectedIndexBar.value = 2;
            Get.to(() => NotifikasiAplikasi());
          },
          child: Obx(() => Container(
                padding: EdgeInsets.fromLTRB(7, 16, 7, 2),
                child: Badge(
                  elevation: 0,
                  position: BadgePosition.topEnd(top: 0, end: 3),
                  animationDuration: Duration(milliseconds: 300),
                  animationType: BadgeAnimationType.slide,
                  badgeColor: (c.notifIndexbar.value == '')
                      ? Colors.transparent
                      : Colors.red,
                  badgeContent: Text(
                    c.notifIndexbar.value,
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.notifications,
                        size: 25,
                        color: Colors.grey,
                      ),
                      Text('Info', style: TextStyle(fontSize: 9)),
                    ],
                  ),
                ),
              )),
        ),
        //
      ],
    );
    //;
  }
}
