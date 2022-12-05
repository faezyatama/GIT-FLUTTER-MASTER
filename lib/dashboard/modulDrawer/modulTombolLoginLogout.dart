import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:satuaja/base/api_service.dart';

import '../../base/warna.dart';
import '../../screen1/login.dart';

class TombolLoginLogout extends StatelessWidget {
  final c = Get.find<ApiService>();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ((Hive.box<String>('sasukaDB').get('loginSebagai') == 'Tamu') ||
                ((Hive.box<String>('sasukaDB').get('loginSebagai') ==
                    'Non Registered User')))
            ? Container(
                padding: EdgeInsets.fromLTRB(12, 2, 12, 2),
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(color: Warna.warnautama)))),
                  onPressed: () {
                    Get.offAll(LoginPage());
                  },
                  child: Text(
                    'Log in / Masuk ke Akun',
                    style: TextStyle(color: Warna.warnautama),
                  ),
                ),
              )
            : Container(
                padding: EdgeInsets.fromLTRB(12, 2, 12, 2),
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(color: Warna.warnautama)))),
                  onPressed: () {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.warning,
                      animType: AnimType.bottomSlide,
                      title: 'Yakin akan logout?',
                      desc:
                          'Apakah benar kamu akan logout dari akun ini ?, ataukah hanya ingin keluar sebentar ?',
                      btnCancelText: 'LogOut',
                      btnOkText: 'Keluar',
                      btnCancelColor: Colors.amber,
                      btnOkOnPress: () {
                        Get.back();
                        SystemChannels.platform
                            .invokeMethod('SystemNavigator.pop');
                      },
                      btnCancelOnPress: () {
                        //  Navigator.pop(context);
                        Hive.box<String>('sasukaDB').put('token', '');
                        Hive.box<String>('sasukaDB').put('nama', '');
                        Hive.box<String>('sasukaDB').put('person_id', '');
                        Hive.box<String>('sasukaDB').put('kodess', '');
                        Hive.box<String>('sasukaDB').put('saldo', '');
                        Hive.box<String>('sasukaDB').put('foto', '');
                        Hive.box<String>('sasukaDB').put('introScreen', '');
                        Hive.box<String>('sasukaDB').put('loginSebagai', '');
                        Hive.box<String>('sasukaDB').put('apiToken', '');
                        Hive.box<String>('sasukaDB').put('iklanSplash', '');
                        Hive.box<String>('sasukaDB').put('grup', '');
                        Hive.box<String>('sasukaDB').put('getPromoFrom', '');

                        //STATE MANAGER
                        c.namaPenggunaKita.value = '';
                        c.ssPenggunaKita.value = '';
                        c.pinStatus.value = '';
                        c.pinBlokir.value = '';
                        c.btnpokok.value = '';
                        c.btnwajib.value = '';
                        c.cl.value = 0;
                        c.follower.value = '';
                        c.follow.value = '';
                        c.refferal.value = 0;
                        c.foto.value = '';
                        c.saldo.value = '';
                        c.npwp.value = '';
                        c.autoDebetWajib.value = 0;
                        c.clLogo.value = '';
                        c.shu.value = '';
                        c.pokok.value = '';
                        c.wajib.value = '';
                        c.bank.value = '';
                        c.norek.value = '';
                        c.nomorAnggota.value = '';
                        c.versiTerbaru = '';
                        c.scrollTextSHU.value = '';
                        c.driverAktif.value = 0;
                        c.adaOutletTSKU.value = '';
                        c.lisensiTS.value = 'Waiting';
                        Get.off(LoginPage());
                      },
                    )..show();
                  },
                  child: Text(
                    'Log Out / Keluar',
                    style: TextStyle(color: Warna.warnautama),
                  ),
                ),
              ),
      ],
    );
  }
}
