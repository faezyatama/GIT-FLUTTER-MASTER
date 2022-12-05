// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:satuaja/folderUmum/transaksi/tukarPoint.dart';
import '../../base/notifikasiBuatAkun.dart';
import '/base/warna.dart';
import '/camera/galeri.dart';
import '/camera/kamera.dart';
import '/base/api_service.dart';

import '../../folderUmum/pengaturan/setting.dart';

class FotoProfile extends StatefulWidget {
  @override
  _FotoProfileState createState() => _FotoProfileState();
}

class _FotoProfileState extends State<FotoProfile> {
  Box dbbox = Hive.box<String>('sasukaDB');
  final c = Get.find<ApiService>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.27,
      padding: EdgeInsets.fromLTRB(25, 11, 25, 0),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/whitelabelUtama/headerprofiles.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.only(top: Get.height * 0.07)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(padding: EdgeInsets.only(left: 11)),
                  RawMaterialButton(
                    onPressed: () {
                      Get.back();
                      Get.to(() => PengaturanUmum());
                    },
                    constraints: BoxConstraints(),
                    elevation: 1.0,
                    fillColor: Colors.amber,
                    child: Text(
                      'PENGATURAN',
                      style: TextStyle(color: Warna.grey, fontSize: 10),
                    ),
                    padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(padding: EdgeInsets.only(top: Get.height * 0.005)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      //============= GANTI FOTO PROFIL =============
                      AwesomeDialog(
                        context: context,
                        animType: AnimType.scale,
                        dialogType: DialogType.noHeader,
                        body: Center(
                          child: Column(
                            children: [
                              Container(
                                width: Get.width * 0.25,
                                height: Get.width * 0.25,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: NetworkImage(c.foto.toString()),
                                      fit: BoxFit.cover),
                                ),
                              ),
                              Padding(padding: EdgeInsets.only(top: 12)),
                              Obx(() => Text(
                                    c.namaPenggunaKita.value,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 22),
                                  )),
                              Padding(padding: EdgeInsets.only(top: 12)),
                              Text(
                                  'Yuk ganti foto kamu yang terbaru, kamu bisa pilih melalui galery atau kamera',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                        btnOkText: 'Camera',
                        btnCancelText: 'Galery',
                        btnOkIcon: Icons.camera_alt,
                        btnCancelIcon: Icons.perm_media,
                        btnCancelColor: Colors.blueAccent,
                        btnCancelOnPress: () {
                          if (c.loginAsPenggunaKita.value == 'Member') {
                            Get.to(() => Galeri());
                          } else {
                            var judulF = 'Ubah Foto Profile';
                            var subJudul =
                                'Untuk menambahkan foto profile, dibutuhkan akun ${c.namaAplikasi}, Yuk Buka akun ${c.namaAplikasi} sekarang';

                            bukaLoginPage(judulF, subJudul);
                          }
                        }, //GET FROM LIBRARY
                        btnOkOnPress: () {
                          if (c.loginAsPenggunaKita.value == 'Member') {
                            Get.to(() => Camera());
                          } else {
                            var judulF = 'Ubah Foto Profile';
                            var subJudul =
                                'Untuk menambahkan foto profile, dibutuhkan akun ${c.namaAplikasi}, Yuk Buka akun ${c.namaAplikasi} sekarang';

                            bukaLoginPage(judulF, subJudul);
                          }
                        }, //GET FROM CAMERA
                      )..show();
                    },
                    child: Obx(() => Container(
                          width: Get.width * 0.16,
                          height: Get.width * 0.16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: NetworkImage(c.foto.value),
                                fit: BoxFit.cover),
                          ),
                        )),
                  ),
                  Padding(padding: EdgeInsets.only(left: 6)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: Get.width * 0.45,
                        child: Container(
                          //constraints: BoxConstraints(maxWidth: Get.width * 0.4),
                          child: Obx(() => Text(
                                c.namaPenggunaKita.value,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                    color: Warna.putih,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800),
                              )),
                        ),
                      ),
                      Row(
                        children: [
                          Obx(() => Text(
                                c.ssPenggunaKita.value,
                                style: TextStyle(
                                  color: Warna.putih,
                                  fontSize: 9,
                                ),
                              )),
                          Text(
                            ' | ',
                            style: TextStyle(
                              color: Warna.putih,
                              fontSize: 11,
                            ),
                          ),
                          Obx(() => Text(
                                c.nomorAnggota.value,
                                style: TextStyle(
                                  color: Warna.putih,
                                  fontSize: 9,
                                ),
                              )),
                        ],
                      ),
                      (c.pointReward.value > 0)
                          ? Row(
                              children: [
                                RawMaterialButton(
                                  onPressed: () {
                                    Get.back();
                                    Get.to(() => TukarkanPoint());
                                  },
                                  constraints: BoxConstraints(),
                                  elevation: 1.0,
                                  fillColor: Colors.amber,
                                  child: Obx(() => Text(
                                        c.pointReward.value.toString() +
                                            ' POINT REWARD',
                                        style: TextStyle(
                                            color: Warna.grey, fontSize: 10),
                                      )),
                                  padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(9)),
                                  ),
                                ),
                              ],
                            )
                          : Padding(padding: EdgeInsets.only(left: 1))
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
    //
  }
}
