// ignore: import_of_legacy_library_into_null_safe
import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../modulDashboard/headerUtamaAtas.dart';
import '/base/warna.dart';
import '/dashboard/view/mainmenu.dart';
import '/dashboard/modulDashboard/referensifreshmart.dart';
import '/dashboard/modulDashboard/referensimakanan.dart';
import '/dashboard/modulDashboard/referensimarketplace.dart';
import '/dashboard/modulDashboard/sliderTengahOk.dart';
import '/base/api_service.dart';
import '../modulDrawer/drawer.dart';
import '../modulDashboard/sliderAtasOk.dart';
import 'keuangan.dart';

class DashboardkuIsi extends StatefulWidget {
  @override
  _DashboardkuIsiState createState() => _DashboardkuIsiState();
}

class _DashboardkuIsiState extends State<DashboardkuIsi> {
  final c = Get.put(ApiService());
  var scaffoldKey = GlobalKey<ScaffoldState>();

  Box dbbox = Hive.box<String>('sasukaDB');
  Timer timer;

  void initState() {
    super.initState();
    c.selectedIndexBar.value = 2;
  }

  @override
  void dispose() {
    super.dispose();
  }

  var test = '';
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        key: scaffoldKey,
        drawer: DrawerProfil(),
        body: Stack(
          children: [
            //LIST VIEW
            ListView(
              children: [
                Padding(padding: EdgeInsets.only(top: Get.height * 0.08)),
                IklanAtas(),

                Keuangan(), //keuangan
                Padding(padding: EdgeInsets.only(top: 11)),

                MainMenu(),
                Padding(padding: EdgeInsets.only(top: 28)),

                Center(
                  child: Text(
                    c.judul1.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54),
                  ),
                ),
                Center(
                  child: Text(
                    c.judul1sub.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w200,
                        color: Colors.black54),
                  ),
                ),
                IklanTengah(),
                Padding(padding: EdgeInsets.only(top: 22)),
                Center(
                  child: Obx(() => Text(
                        c.judulMarketplaceText.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54),
                      )),
                ),
                Center(
                  child: Obx(() => Text(
                        c.marketplaceText.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      )),
                ),
                Obx(() => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: (c.mitraMarketplace.value == '1')
                        ? ReferensiDashboard()
                        : Container())),
                //iklan atas
                Padding(padding: EdgeInsets.only(top: 22)),
                //    IklanAtas(), //iklan atas
                Padding(padding: EdgeInsets.only(top: 22)),
                Obx(() => Center(
                      child: (c.mitraMakanan.value == '1')
                          ? Container(
                              width: Get.width * 0.8,
                              child: Column(
                                children: [
                                  Text(
                                    c.judulMakananText.value,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 11)),
                                  AutoSizeText(
                                    c.makananText.value,
                                    style: TextStyle(color: Colors.black54),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                    )),
                Obx(() => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: (c.mitraMakanan.value == '1')
                        ? ReferensiMakanan()
                        : Container())),
                Padding(padding: EdgeInsets.only(top: 22)),
                Padding(padding: EdgeInsets.only(top: 22)),
                Obx(() => Center(
                      child: (c.mitraFreshmart.value == '1')
                          ? Container(
                              width: Get.width * 0.8,
                              child: Column(
                                children: [
                                  Text(
                                    c.judulFreshmartText.value,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 11)),
                                  AutoSizeText(
                                    c.freshmartText.value,
                                    style: TextStyle(color: Colors.black54),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                    )),
                Obx(() => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: (c.mitraMakanan.value == '1')
                        ? ReferensiFreshmart()
                        : Container())),

                Padding(padding: EdgeInsets.only(top: 22)),
                Obx(() => Center(
                      child: Text(
                        c.judul3.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54),
                      ),
                    )),
                Obx(() => Center(
                      child: Text(
                        c.judul3sub.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    )),
                Padding(padding: EdgeInsets.only(top: 6)),
                Obx(() => RawMaterialButton(
                    highlightColor: Colors.black,
                    onPressed: () {},
                    child: Image.network(c.judul3gambar.value))),
                Padding(padding: EdgeInsets.only(top: 22)),

                Padding(padding: EdgeInsets.only(top: 22)),
                Obx(() => Center(
                      child: Text(
                        c.judul4.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54),
                      ),
                    )),

                Obx(() => Center(
                      child: Container(
                        width: Get.width * 0.8,
                        child: AutoSizeText(
                          c.judul4sub.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                          maxLines: 3,
                        ),
                      ),
                    )),
                Padding(padding: EdgeInsets.only(top: 11)),

                Obx(() => RawMaterialButton(
                    highlightColor: Colors.black,
                    onPressed: () {},
                    child: Image.network(c.judul4gambar.value))),
                Padding(padding: EdgeInsets.only(top: 2)),
              ],
            ),

            //--------------------Modul Header Utama Atas navbar
            HeaderUtamaAtas(),
          ],
        ),
      ),
    );
    //
  }

  void tampilkanBesar(s, a, f) {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.bottomSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Image.asset(
            s,
            width: Get.width * 0.75,
          ),
          Container(
            padding: EdgeInsets.all(11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: Get.width * 0.6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a,
                          style: TextStyle(
                              fontSize: 18,
                              color: Warna.warnautama,
                              fontWeight: FontWeight.w600)),
                      Text(
                        f,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Padding(padding: EdgeInsets.only(top: 9)),
                    ],
                  ),
                ),
                GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Icon(
                      Icons.cancel,
                      size: 27,
                      color: Colors.grey,
                    ))
              ],
            ),
          ),
        ],
      ),
    )..show();
  }
}
