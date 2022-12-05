import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import "package:flutter/material.dart";
import 'package:get/get.dart';

import '../../base/api_service.dart';
import '../../folderUmum/antarin/antarin.dart';
import '../../folderUmum/chat/view/chatDariLuar.dart';
import '../../folderUmum/chat/view/homechat.dart';
import '../../folderUmum/pesanan/pesanan.dart';
import '../../folderUmum/transaksi/transaksi.dart';
import '../view/dashboardisi.dart';

class BodyMenuFooter extends StatelessWidget {
  final c = Get.find<ApiService>();
  @override
  Widget build(BuildContext context) {
    return DoubleBackToCloseApp(
      snackBar: const SnackBar(
        content: Text('Tap sekali lagi untuk keluar aplikasi'),
      ),
      child: Obx(() => Container(
          child: (c.tabsaatini.value == 0)
              ? Pesananku()
              : (c.tabsaatini.value == 1)
                  ? Antarin()
                  : (c.tabsaatini.value == 2)
                      ? DashboardkuIsi()
                      : (c.tabsaatini.value == 3)
                          ? Transaksiku()
                          : (c.tabsaatini.value == 4)
                              ? (c.loginAsPenggunaKita.value == 'Member')
                                  ? ChatApp()
                                  : LuarLiveSupportChatDetailPage()
                              : Container())),
    );
  }
}
