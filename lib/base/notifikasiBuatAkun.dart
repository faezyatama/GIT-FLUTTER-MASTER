import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:get/get.dart';
import 'package:satuaja/base/warna.dart';

import '../screen1/daftar.dart';
import '../screen1/login.dart';

void bukaLoginPage(judulF, subJudul) {
  AwesomeDialog(
    context: Get.context,
    dialogType: DialogType.noHeader,
    animType: AnimType.rightSlide,
    title: judulF,
    desc: subJudul,
    btnOkOnPress: () {
      Get.to(() => DaftarAplikasi());
    },
    btnOkText: 'Buat Akun',
    btnCancelText: 'Login',
    btnCancelColor: Warna.warnautama,
    btnCancelOnPress: () {
      Get.to(() => LoginPage());
    },
  )..show();
}
