import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/api_service.dart';
import '../../base/notifikasiBuatAkun.dart';
import '../../base/warna.dart';
import '../../folderMitra/driver/mainControl.dart';
import '../../folderMitra/outletFm/homeOutletFM.dart';
import '../../folderMitra/outletMakan/homeOutlet.dart';
import '../../folderMitra/outletMp/homeOutletMP.dart';
import '../../folderMitra/outletTokoSekitar/homeOutletTS.dart';

// ignore: must_be_immutable
class ModulMitraUsaha extends StatelessWidget {
  final c = Get.find<ApiService>();
  TextStyle styleHurufkecil = TextStyle(fontSize: 8, color: Warna.grey);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(16, 1, 1, 1),
          child: Text(
            c.sebutanUntukMitra,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600, color: Warna.grey),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(16, 1, 1, 1),
          child: Text(
            c.sebutanUntukMitra2,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w200, color: Warna.grey),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(15, 1, 1, 1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: (c.mitraMakanan.value == '1')
                    ? GestureDetector(
                        onTap: () {
                          if (c.loginAsPenggunaKita.value == 'Member') {
                            Get.to(() => DashboardOutlet());
                          } else {
                            var judulF = 'Mau berjualan Makanan ?';
                            var subJudul =
                                'Dapatkan penghasilan extra dengan membuka otlet makanan online di ${c.namaAplikasi}, Yuk Buka akun ${c.namaAplikasi} sekarang';

                            bukaLoginPage(judulF, subJudul);
                          }
                        },
                        child: Column(
                          children: [
                            Image.asset(
                              'images/whitelabelMainMenu/makan.png',
                              width: 60,
                            ),
                            Obx(() => Text(
                                  c.notifMakan.value,
                                  style: styleHurufkecil,
                                ))
                          ],
                        ),
                      )
                    : Padding(padding: EdgeInsets.only(left: 1)),
              ),
              //
              Padding(padding: EdgeInsets.only(left: 22)),
              Container(
                child: (c.mitraTransportasi.value == '1')
                    ? GestureDetector(
                        onTap: () {
                          if (c.loginAsPenggunaKita.value == 'Member') {
                            // Get.snackbar('Comming Soon',
                            //     'Fitur ini akan segera tersedia');

                            Get.to(() => DashboardDriver());
                          } else {
                            var judulF = 'Mau menjadi driver/kurir ?';
                            var subJudul =
                                'Dapatkan penghasilan extra dengan menjadi driver/kurir online di ${c.namaAplikasi}, Yuk Buka akun ${c.namaAplikasi} sekarang';

                            bukaLoginPage(judulF, subJudul);
                          }
                        },
                        child: Column(
                          children: [
                            Image.asset(
                              'images/whitelabelMainMenu/samotor.png',
                              width: 60,
                            ),
                            Text(
                              'Driver/kurir',
                              style: styleHurufkecil,
                            )
                          ],
                        ),
                      )
                    : Padding(padding: EdgeInsets.only(left: 1)),
              ),
              //
              Padding(padding: EdgeInsets.only(left: 22)),
              Container(
                child: (c.mitraFreshmart.value == '1')
                    ? GestureDetector(
                        onTap: () {
                          if (c.loginAsPenggunaKita.value == 'Member') {
                            Get.to(() => DashboardOutletFM());
                          } else {
                            var judulF = 'Mau jualan Sayur/Freshmart ?';
                            var subJudul =
                                'Dapatkan penghasilan extra dengan berjualan freshmart di ${c.namaAplikasi}, Yuk Buka akun ${c.namaAplikasi} sekarang';

                            bukaLoginPage(judulF, subJudul);
                          }
                        },
                        child: Column(
                          children: [
                            Image.asset(
                              'images/whitelabelMainMenu/freshmart.png',
                              width: 60,
                            ),
                            Obx(() => Text(
                                  c.notifFreshmart.value,
                                  style: styleHurufkecil,
                                ))
                          ],
                        ),
                      )
                    : Padding(padding: EdgeInsets.only(left: 15)),
              ),
            ],
          ),
        ),
        Padding(padding: EdgeInsets.only(top: 11)),
        Container(
          padding: EdgeInsets.fromLTRB(15, 1, 1, 1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: (c.mitraTokosekitar.value == '1')
                    ? GestureDetector(
                        onTap: () {
                          if (c.loginAsPenggunaKita.value == 'Member') {
                            // Get.snackbar('Comming Soon',
                            //     'Fitur ini akan segera tersedia');
                            Get.to(() => DashboardOutletTS());
                          } else {
                            var judulF = 'Daftarkan Toko kamu ?';
                            var subJudul =
                                'Dapatkan penghasilan extra dengan berjualan toko sekitar di ${c.namaAplikasi}, Yuk Buka akun ${c.namaAplikasi} sekarang';

                            bukaLoginPage(judulF, subJudul);
                          }
                        },
                        child: Column(
                          children: [
                            Image.asset(
                              'images/whitelabelMainMenu/tokosekitar.png',
                              width: 60,
                            ),
                            Text(
                              '${c.nNamafitTosek}',
                              style: styleHurufkecil,
                            )
                          ],
                        ),
                      )
                    : Padding(padding: EdgeInsets.only(left: 1)),
              ),
              //
              Padding(padding: EdgeInsets.only(left: 22)),

              Container(
                child: (c.mitraMarketplace.value == '1')
                    ? GestureDetector(
                        onTap: () {
                          if (c.loginAsPenggunaKita.value == 'Member') {
                            Get.to(() => DashboardOutletMP());
                          } else {
                            var judulF = 'Mau Jualan di Marketplace ?';
                            var subJudul =
                                'Dapatkan penghasilan extra dengan berjualan Marketplace di ${c.namaAplikasi}, Yuk Buka akun ${c.namaAplikasi} sekarang';

                            bukaLoginPage(judulF, subJudul);
                          }
                        },
                        child: Column(
                          children: [
                            Image.asset(
                              'images/whitelabelMainMenu/mall.png',
                              width: 60,
                            ),
                            Obx(() => Text(
                                  c.notifMarketplace.value,
                                  style: styleHurufkecil,
                                ))
                          ],
                        ),
                      )
                    : Padding(padding: EdgeInsets.only(left: 1)),
              ),
              //

              //-------------------------
            ],
          ),
        ),
      ],
    );
  }
}
