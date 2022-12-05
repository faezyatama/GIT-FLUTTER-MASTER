import "package:flutter/material.dart";
import 'package:get/get.dart';

import '../base/api_service.dart';
import '../base/warna.dart';
import 'lihatProdukSimpanan.dart';
import 'lihatProdukSimpananBerjangka.dart';
import 'lihatProdukSimpananRencana.dart';

class ListProdukSimpanan extends StatelessWidget {
  final c = Get.find<ApiService>();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height * 0.2,
      child: Container(
        padding: EdgeInsets.all(12),
        child: Center(
          child: Column(
            children: [
              Text(
                "Lihat Produk Simpanan",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w200,
                    color: Warna.warnautama),
              ),
              Padding(padding: EdgeInsets.only(top: 11)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(padding: EdgeInsets.only(left: 3)),
                  SizedBox(
                    width: Get.width * 0.23,
                    child: GestureDetector(
                      onTap: () {
                        if (c.loginAsPenggunaKita.value == 'Member') {
                          Get.off(LihatProdukSimpanan());
                        } else {
                          var judulF = 'Produk Simpanan Umum';
                          var subJudul =
                              'Silahkan membuat akun terlebih dahulu';
                          Get.snackbar(judulF, subJudul);
                        }
                      },
                      child: Column(
                        children: [
                          Image.asset('images/whitelabelMainMenu/sipok.png',
                              width: Get.width * 0.12),
                          Text(
                            'Simpanan Umum',
                            style: TextStyle(color: Warna.grey, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: Get.width * 0.23,
                    child: GestureDetector(
                      onTap: () {
                        if (c.loginAsPenggunaKita.value == 'Member') {
                          Get.off(LihatProdukSimpananBerjangka());
                        } else {
                          var judulF = 'Produk Simpanan Berjangka';
                          var subJudul =
                              'Silahkan membuat akun terlebih dahulu';
                          Get.snackbar(judulF, subJudul);
                        }
                      },
                      child: Column(
                        children: [
                          Image.asset('images/whitelabelMainMenu/siwa.png',
                              width: Get.width * 0.12),
                          Text(
                            'Simpanan Berjangka',
                            style: TextStyle(color: Warna.grey, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: Get.width * 0.23,
                    child: GestureDetector(
                      onTap: () {
                        if (c.loginAsPenggunaKita.value == 'Member') {
                          Get.off(LihatProdukSimpananRencana());
                        } else {
                          var judulF = 'Produk Simpanan Rencana';
                          var subJudul =
                              'Silahkan membuat akun terlebih dahulu';
                          Get.snackbar(judulF, subJudul);
                        }
                      },
                      child: Column(
                        children: [
                          Image.asset('images/whitelabelMainMenu/autodebet.png',
                              width: Get.width * 0.12),
                          Text(
                            'Simpanan Rencana',
                            style: TextStyle(color: Warna.grey, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(left: 3)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
