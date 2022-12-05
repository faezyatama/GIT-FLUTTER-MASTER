import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/api_service.dart';
import '../../base/notifikasiBuatAkun.dart';
import '../../folderSimpanPinjam/homepinjaman.dart';
import '../../folderSimpanPinjam/homesimpanan.dart';

class ModulSimpanPinjam extends StatefulWidget {
  @override
  State<ModulSimpanPinjam> createState() => _ModulSimpanPinjamState();
}

class _ModulSimpanPinjamState extends State<ModulSimpanPinjam> {
  final c = Get.find<ApiService>();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(padding: EdgeInsets.only(left: 3)),
        SizedBox(
          width: Get.width * 0.23,
          child: GestureDetector(
            onTap: () {
              if (c.loginAsPenggunaKita.value == 'Member') {
                Get.to(HomeSimpanan());
              } else {
                Get.snackbar(
                    'Akun Dibutuhkan', 'Silahkan membuka akun terlebih dahulu');
              }
            },
            child: Column(
              children: [
                Image.asset('images/whitelabelMainMenu/iconsimpanan.png',
                    width: Get.width * 0.12),
                Text(
                  'Produk Simpanan',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
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
                Get.to(HomePinjaman());
              } else {
                Get.snackbar(
                    'Akun Dibutuhkan', 'Silahkan membuka akun terlebih dahulu');
              }
            },
            child: Column(
              children: [
                Image.asset('images/whitelabelMainMenu/iconpinjaman.png',
                    width: Get.width * 0.12),
                Text(
                  'Produk Pinjaman',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
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
                Get.snackbar('Fitur Akan Segera Aktif', 'Opps.. Comming Soon');
              } else {
                var judulF = 'Pindah Saldo';
                var subJudul =
                    'Kemudahan dalam bertransaksi untuk memindahkan saldo tabungan dan simpanan sukarela';
                bukaLoginPage(judulF, subJudul);
              }
            },
            child: Column(
              children: [
                Image.asset('images/whitelabelMainMenu/iconautodebet.png',
                    width: Get.width * 0.12),
                Text(
                  'Pindah Saldo',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        Padding(padding: EdgeInsets.only(left: 3)),
      ],
    );
  }
}
