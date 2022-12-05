import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import 'puk.dart';
import 'terblokirpin.dart';
import 'settingbank.dart';
import 'settingbuatpin.dart';
import 'settingpassword.dart';
import 'settingpin.dart';
import 'settingprinter.dart';

class PengaturanUmum extends StatefulWidget {
  @override
  _PengaturanUmumState createState() => _PengaturanUmumState();
}

class _PengaturanUmumState extends State<PengaturanUmum> {
  final c = Get.find<ApiService>();

  //BOTTOM NAVIGATION BAR
  String pinku = '0';

  Box dbbox = Hive.box<String>('sasukaDB');

  // @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
            length: 4,
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Get.back();
                  },
                ),
                title: Text('Pengaturan'),
                backgroundColor: Warna.warnautama,
                bottom: TabBar(
                  indicatorColor: Colors.amber,
                  tabs: [
                    Tab(icon: Icon(Icons.monetization_on), text: 'Bank'),
                    Tab(icon: Icon(Icons.lock), text: 'Password'),
                    Tab(icon: Icon(Icons.security_rounded), text: 'PIN'),
                    Tab(icon: Icon(Icons.print), text: 'Printer'),
                  ],
                ),
              ),
              body: Obx(() => TabBarView(
                    children: [
                      SettingBank(),
                      SettingPassword(),
                      (c.pinStatus.value == '0')
                          ? SettingBuatPin()
                          : (c.pinBlokir.value == 'terblokir')
                              ? (c.pinUnblock.value != 'Pin lama')
                                  ? PinUnblock()
                                  : Terblokir()
                              : SettingPin(),
                      SettingPrinter()
                    ],
                  )),
            )));
  }
}
