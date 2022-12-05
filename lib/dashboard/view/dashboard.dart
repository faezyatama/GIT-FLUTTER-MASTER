import 'dart:async';
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../modulFooter/footerBody.dart';
import '../modulFooter/footerMenu.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/dashboard/view/ilkanSplash.dart';
import '/screen1/login.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../folderMitra/driver/DetailPesananBarangUmum.dart';
import '../../folderMitra/driver/daftarAntaranIntegrasi.dart';
import '../../folderMitra/driver/konfirmasiAntaranUmum.dart';
import '../../folderMitra/driver/konfirmasiOrderOjek.dart';
import '../../folderMitra/driver/orderOjek.dart';
import '../../folderUmum/payment/payment.dart';
import 'dashboardisi.dart';
import '../modulDrawer/drawer.dart';
import 'package:http/http.dart' as http;

class Dashboardku extends StatefulWidget {
  @override
  _DashboardkuState createState() => _DashboardkuState();
}

class _DashboardkuState extends State<Dashboardku> {
  final c = Get.find<ApiService>();

  var badge = '';

  var tabsaatini = 2;
  var isiMenuContainer;
  //BOTTOM NAVIGATION BAR
  var isiMenu = 'dashboard';

  Timer timer;
  Timer timerDriver;
  Timer timerPerpanjang;
  Timer timer15detik;
  Timer timerUpdateLokasi;
  Timer cekSaldo;
  Timer timerApakahAkunIniDriverDCN;
  Timer timerUpdateLokasiDriver;

  Position hasil;
  double latitude;
  double longitude;

  @override
  void initState() {
    super.initState();

    determinePosition();
    cekSesionLoginPengguna();
    getDataJuduldanGambar();
    //CEK LOGIN DULU
    isiMenuContainer = DashboardkuIsi();
    timer =
        Timer.periodic(Duration(seconds: 8), (Timer t) => statusAkunTerbaru());

    timerApakahAkunIniDriverDCN = Timer.periodic(
        Duration(seconds: 10), (Timer t) => cekDriverAktifdiDCN());

    timerDriver = Timer.periodic(
        Duration(seconds: 7), (Timer t) => statusDriverTerbaru());

    cekSaldo =
        Timer.periodic(Duration(seconds: 15), (Timer t) => cekSaldokuDulu());

    //notifikasi
    AwesomeNotifications().initialize(
        'resource://drawable/logo',
        [
          NotificationChannel(
              channelKey: 'basic_channel',
              channelName: 'Basic notifications',
              channelDescription: 'Notification channel for basic tests',
              defaultColor: Color(0xFF1E939D),
              ledColor: Colors.white),
        ],
        debug: true);
    //end notifikasi inisialisasi
  }

  @override
  void dispose() {
    timer?.cancel();
    timerDriver?.cancel();
    timerPerpanjang?.cancel();
    timerApakahAkunIniDriverDCN?.cancel();
    timerUpdateLokasiDriver?.cancel();
    super.dispose();
  }

  reloadDriverStatusSaatSelesai() {
    if (c.reloadDriver == true) {
      timerDriver?.cancel();
      timerPerpanjang?.cancel();

      timerDriver = Timer.periodic(
          Duration(seconds: 7), (Timer t) => statusDriverTerbaru());

      c.reloadDriver = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: DrawerProfil(),
        body: BodyMenuFooter(),
        bottomNavigationBar: FooterMenuUtama());
    //
  }

  void statusAkunTerbaru() async {
    reloadDriverStatusSaatSelesai();
    //URUTAN PENGECEKAN 1

    // if (c.timerDashboardUtama.value == false) {
    //   return;
    // }

    bool conn = await cekInternet();
    if (conn) {
      //BODY YANG DIKIRIM
      Box dbbox = Hive.box<String>('sasukaDB');
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');

      var user = dbbox.get('loginSebagai');
      var datarequest = '{"pid":"$pid"}';
      var bytes = utf8.encode(datarequest + '$token' + user);
      var signature = md5.convert(bytes).toString();

      if (user != 'Member') {
        return;
      }

      var url = Uri.parse('${c.baseURL}/mobileApps/cekSatusAkunTerbaru');

      final response = await http.post(url, body: {
        "user": user,
        "appid": c.appid,
        "data_request": datarequest,
        "sign": signature
      });

      // print(response.body);
      // print('statusAkunTerbaru-Dashboardku');

      if (response.statusCode == 200) {
        Map<String, dynamic> hasil = jsonDecode(response.body);
        if (hasil['status'] == 'success') {
          //NOTIF PAYMENT
          if (c.notifPayment.value != hasil['notifPayment']) {
            if (hasil['notifPayment'] > c.notifPayment.value) {
              lokalNotifikasiTerbaik(
                  9,
                  c.namaAplikasi + ' : Pembayaran Transaksi',
                  'Kamu menerima permintaan pembayaran, klik untuk melihat');
              AwesomeDialog(
                  context: Get.context,
                  dialogType: DialogType.noHeader,
                  animType: AnimType.rightSlide,
                  title: 'Permintaan Pembayaran',
                  desc:
                      'Kamu menerima permintaan pembayaran, Klik untuk melihat detailnya',
                  btnCancelText: 'Nanti Saja',
                  btnCancelColor: Colors.amber,
                  btnCancelOnPress: () {
                    Get.back();
                  },
                  btnOkText: 'Lihat',
                  btnOkOnPress: () {
                    Get.to(() => PaymentPoint());
                  })
                ..show();
            }
            c.notifPayment.value = hasil['notifPayment'];
          } else {
            c.notifPayment.value = hasil['notifPayment'];
          }

          //NOTIF MAKAN
          if (c.notifMakan.value != hasil['notifMakan']) {
            c.notifMakan.value = hasil['notifMakan'];
            if (hasil['notifMakan'] != 'Makanan') {
              lokalNotifikasiTerbaik(2, c.namaAplikasi + ' : Order makanan',
                  'Kamu menerima order makanan, yuk proses pesanan ini');
            }
          } else {
            c.notifMakan.value = hasil['notifMakan'];
          }

          //NOTIF FRESHMART
          if (c.notifFreshmart.value != hasil['notifFreshmart']) {
            c.notifFreshmart.value = hasil['notifFreshmart'];
            if (hasil['notifFreshmart'] != 'Freshmart') {
              lokalNotifikasiTerbaik(3, c.namaAplikasi + ' : Order Freshmart',
                  'Kamu menerima order freshmart, yuk proses pesanan ini');
            }
          } else {
            c.notifFreshmart.value = hasil['notifFreshmart'];
          }

          //NOTIF MARKETPLACE
          if (c.notifMarketplace.value != hasil['notifMarketplace']) {
            c.notifMarketplace.value = hasil['notifMarketplace'];
            if (hasil['notifMarketplace'] != 'Marketplace') {
              lokalNotifikasiTerbaik(4, c.namaAplikasi + ' : Order Marketplace',
                  'Kamu menerima order Marketplace, yuk proses pesanan ini');
            }
          } else {
            c.notifMarketplace.value = hasil['notifMarketplace'];
          }

          c.saldo.value = hasil['saldo'];
          c.saldoInt.value = hasil['saldoInt'];
          c.pointReward.value = hasil['pointReward'];

          //NOTIFIKASI INFO
          // c.notifIndexbar.value = hasil['notifikasi'];
          if (c.notifIndexbar.value != hasil['notifikasi']) {
            c.notifIndexbar.value = hasil['notifikasi'];
            if (c.notifIndexbar.value != '') {
              lokalNotifikasiTerbaik(
                  10,
                  c.namaAplikasi + ' : Info terbaru buat kamu',
                  'Ada pemberitahuan terbaru yang perlu kamu lihat, yuk buka sekarang..!');
            }
          } else {
            c.notifIndexbar.value = hasil['notifikasi'];
          }

          //CHAT SOUND
          if (c.chatIndexBar.value != hasil['chat']) {
            c.chatIndexBar.value = hasil['chat'];
            if (hasil['chat'] != '') {
              lokalNotifikasiTerbaik(1, c.namaAplikasi + ' : Pesan diterima',
                  'Seseorang mengirim pesan untukmu, yuk buka pesannya');
            }
          } else {
            c.chatIndexBar.value = hasil['chat'];
          }

          c.antarinIndexBar.value = hasil['antarin'];
          c.pesananIndexBar.value = hasil['pesanan'];
          if (mounted) {
            setState(() {
              c.keranjangIndexbar.value = hasil['keranjang'];
            });
          }
        } else if (hasil['status'] == 'session destroy') {
          timer?.cancel();
          Hive.box<String>('sasukaDB').put('token', '');
          Hive.box<String>('sasukaDB').put('nama', '');
          Hive.box<String>('sasukaDB').put('person_id', '');
          Hive.box<String>('sasukaDB').put('kodess', '');
          Hive.box<String>('sasukaDB').put('saldo', '');
          Hive.box<String>('sasukaDB').put('foto', '');
          Hive.box<String>('sasukaDB').put('introScreen', '');

          Get.offAll(LoginPage());
        }
      }
    }
    cekUpdate();
  }

  void cekUpdate() {
    var saatIni = c.versiApkSaarini.replaceAll('.', '');
    var terbaru = c.versiTerbaru.replaceAll('.', '');
    var verSaatIni = int.parse(saatIni);
    var versiTerbaru = int.parse(terbaru);
    if (verSaatIni < versiTerbaru) {
      c.versiApkSaarini = c.versiTerbaru;
      AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.warning,
          animType: AnimType.rightSlide,
          title: 'Update Tersedia !',
          desc:
              'Sepertinya update ${c.namaAplikasi} sudah tersedia di Playstore, yuk Update aplikasi ini biar fiturnya lebih sempurna',
          btnCancelText: 'Nanti Saja',
          btnCancelColor: Colors.amber,
          btnCancelOnPress: () {
            Get.back();
          },
          btnOkText: 'Update',
          btnOkOnPress: () async {
            await launchUrl(Uri.parse('${c.baseURLplaystore}'));
          })
        ..show();
    }
  }

  void lokalNotifikasiTerbaik(
      int idNotif, String titleNotif, String pesanNotif) {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // Insert here your friendly dialog box before call the request method
        // This is very important to not harm the user experience
        AwesomeNotifications().requestPermissionToSendNotifications();
      } else {
        AwesomeNotifications().createNotification(
            content: NotificationContent(
                id: idNotif,
                channelKey: 'basic_channel',
                title: titleNotif,
                body: pesanNotif));
      }
    });
  }

  void cekSesionLoginPengguna() async {
    if (c.cekLoginStatus.value == 'login ok') {
      return;
    }

    bool conn = await cekInternet();
    if (conn) {
      //BODY YANG DIKIRIM
      Box dbbox = Hive.box<String>('sasukaDB');

      var tokenCadangan = dbbox.get('tokenCadangan');
      var pidCadangan = dbbox.get('pidCadangan');

      var user = 'Member';
      var datarequest = '{"pid":"$pidCadangan"}';
      var bytes = utf8.encode(datarequest + '$tokenCadangan' + user);
      var signature = md5.convert(bytes).toString();

      var url = Uri.parse('${c.baseURL}/mobileApps/cekLoginPengguna');

      final response = await http.post(url, body: {
        "user": user,
        "appid": c.appid,
        "data_request": datarequest,
        "sign": signature
      });

      //print(response.body);
      //print('Cek Sesi Pengguna');

      if (response.statusCode == 200) {
        Map<String, dynamic> cekLogin = jsonDecode(response.body);
        if (cekLogin['status'] == 'success') {
          c.cekLoginStatus.value = 'login ok';

          Box dbbox = Hive.box<String>('sasukaDB');
          dbbox.put('tokenCadangan', '');
          dbbox.put('pidCadangan', '');

          dbbox.put('loginSebagai', cekLogin['loginSebagai']);
          dbbox.put('token', cekLogin['token']);
          dbbox.put('apiToken', cekLogin['apiToken']);

          dbbox.put('nama', cekLogin['nama']);
          dbbox.put('person_id', cekLogin['person_id'].toString());
          dbbox.put('kodess', cekLogin['kodess']);
          dbbox.put('iklanSplash', cekLogin['iklanSplash']);
          dbbox.put('grup', cekLogin['grup'].toString());

          //STATE MANAGER
          c.splashLink = cekLogin['splashLink'];
          c.iklanSplash = cekLogin['iklanSplash'];

          c.namaPenggunaKita.value = cekLogin['nama'];
          c.ssPenggunaKita.value = cekLogin['kodess'];
          c.loginAsPenggunaKita.value = cekLogin['loginSebagai'];

          c.pinStatus.value = cekLogin['pinStatus'].toString();
          c.pinBlokir.value = cekLogin['pinBlokir'];
          c.btnpokok.value = cekLogin['btnpokok'];
          c.btnwajib.value = cekLogin['btnwajib'];
          c.sipokAnggota = cekLogin['sipokAnggota'];
          c.siwaAnggota = cekLogin['siwaAnggota'];

          c.cl.value = cekLogin['cl'];
          c.follower.value = cekLogin['follower'];
          c.follow.value = cekLogin['follow'];
          c.refferal.value = cekLogin['refferal'];
          c.foto.value = cekLogin['foto'];
          c.saldo.value = cekLogin['saldo'];
          c.saldoInt.value = cekLogin['saldoInt'];
          c.npwp.value = cekLogin['npwp'];
          c.autoDebetWajib.value = cekLogin['autodebet'];
          c.clLogo.value = cekLogin['clLogo'];
          c.shu.value = cekLogin['shu'];
          c.pokok.value = cekLogin['pokok'];
          c.wajib.value = cekLogin['wajib'];
          c.bank.value = cekLogin['bank'];
          c.norek.value = cekLogin['norek'];
          c.nomorAnggota.value = cekLogin['nomorAnggota'];
          c.versiTerbaru = cekLogin['versiApk'];
          c.scrollTextSHU.value = cekLogin['scroll'];
          c.pointReward.value = cekLogin['point'];
          c.voucherBelanja.value = cekLogin['voucher'];
        } else {
          c.cekLoginStatus.value = 'login dibutuhkan';
        }
      }
    }
    splashIklan();
  }

  statusDriverTerbaru() async {
    if (c.driverAktif.value == 1) {
      await determinePosition();

      // if (c.timerDashboardUtama.value == false) {
      //   return;
      // }

      bool conn = await cekInternet();
      if (conn) {
        //BODY YANG DIKIRIM
        Box dbbox = Hive.box<String>('sasukaDB');
        var token = dbbox.get('token');
        var pid = dbbox.get('person_id');
        var latt = c.latitude.value;
        var longg = c.longitude.value;
        var user = dbbox.get('loginSebagai');

        var datarequest = '{"pid":"$pid","lat":"$latt","long":"$longg"}';
        var bytes = utf8.encode(datarequest + '$token' + user);
        var signature = md5.convert(bytes).toString();
        if (user != 'Member') {
          return;
        }

        var url = Uri.parse(
            '${c.baseURLdriver}/mobileAppsMitraDriver/cekSatusDriverTerbaru');

        final response = await http.post(url, body: {
          "user": user,
          "data_request": datarequest,
          "sign": signature,
          "package": c.packageName
        });

        // print(response.body);
        // print('statusDriverTerbaru-Dashboardku');
        if (response.statusCode == 200) {
          Map<String, dynamic> hasil = jsonDecode(response.body);
          if (hasil['status'] == 'success') {
            //NOTIF KURIR INTEGRASI
            if (hasil['orderKurirIntegrasi'] != null) {
              if (c.notifKurirIntegrasi.value < hasil['orderKurirIntegrasi']) {
                c.notifKurirIntegrasi.value = hasil['orderKurirIntegrasi'];
                if (hasil['orderKurirIntegrasi'] != 0) {
                  lokalNotifikasiTerbaik(
                      5,
                      c.namaAplikasi + ' : Pengantaran Kurir',
                      'Ada pengantaran barang/paket yang masuk buat kamu, Yuk di buka');

                  if (mounted) {
                    Get.back();
                    AwesomeDialog(
                        context: Get.context,
                        dialogType: DialogType.noHeader,
                        animType: AnimType.scale,
                        title: 'Ada order Masuk',
                        desc: 'Kamu mendapatkan order pengantaran paket/barang',
                        btnOkText: 'Buka Order',
                        btnOkOnPress: () async {
                          Get.to(() => DaftarAntaran());
                        })
                      ..show();
                  }
                }
              } else {
                c.notifKurirIntegrasi.value = hasil['orderKurirIntegrasi'];
              }
            }

            //NOTIF KURIR UMUM
            // print(c.notifKurirUmum.value);
            c.notifKurirUmum.value = 0;
            if (hasil['orderKurirUmum'] != null) {
              if (c.notifKurirUmum.value < hasil['orderKurirUmum']) {
                if ((hasil['orderKurirUmum'] != 0) &&
                    (c.kodeJualPengantaranDriver.value !=
                        hasil['kodeJualKurirUmum'])) {
                  lokalNotifikasiTerbaik(
                      6,
                      c.namaAplikasi + ' : Pengantaran Kurir Umum',
                      'Ada pengantaran paket/barang yang masuk buat kamu, Yuk di buka');

                  c.kodeJualPengantaranDriver.value =
                      hasil['kodeJualKurirUmum'];
                  c.notifKurirUmum.value = hasil['orderKurirUmum'];

                  //KALAU AUTOBID LANGSUNG KE DAFTAR ANTARAN
                  if (hasil['autobid'] == 'Aktif') {
                    Get.back();
                    Get.to(() => DaftarPesananDriverUmum());
                  } else {
                    if (mounted) {
                      Get.back();
                      AwesomeDialog(
                          context: Get.context,
                          dialogType: DialogType.noHeader,
                          animType: AnimType.scale,
                          title: 'Ada order Masuk',
                          desc:
                              'Kamu mendapatkan order pengantaran paket/barang',
                          btnOkText: 'Buka Order',
                          btnOkOnPress: () async {
                            perpanjangWaktuDanCekExpire();
                          })
                        ..show();
                      timerDriver?.cancel();
                      timer15detik = Timer.periodic(Duration(seconds: 15),
                          (Timer t) => limaBelasDetikHabis());
                    }
                  }
                }
              } else {
                c.notifKurirUmum.value = hasil['orderKurirUmum'];
              }
            }

            //NOTIF OJEK PENGANTARAN
            if (hasil['orderOjek'] != null) {
              if (c.notifOjek.value < hasil['orderOjek']) {
                if ((hasil['orderOjek'] != 0) &&
                    (c.kodeJualPengantaranDriver.value !=
                        hasil['kodeJualOjek'])) {
                  lokalNotifikasiTerbaik(
                      7,
                      c.namaAplikasi + ' : Pengantaran Umum',
                      'Ada pengantaran yang masuk buat kamu, Yuk di buka');

                  c.kodeJualPengantaranDriver.value = hasil['kodeJualOjek'];
                  c.notifOjek.value = hasil['orderOjek'];

                  //KALAU AUTOBID LANGSUNG KE DAFTAR ANTARAN
                  if (hasil['autobid'] == 'Aktif') {
                    Get.back();
                    Get.to(() => DaftarPesananDriverUmum());
                  } else {
                    if (mounted) {
                      Get.back();
                      AwesomeDialog(
                          context: Get.context,
                          dialogType: DialogType.noHeader,
                          animType: AnimType.scale,
                          title: 'Ada permintaan pengantaran',
                          desc: 'Kamu mendapatkan order pengantaran ',
                          btnOkText: 'Buka Order',
                          btnOkOnPress: () async {
                            perpanjangWaktuDanCekExpireOjek();
                          })
                        ..show();
                      timerDriver?.cancel();
                      timer15detik = Timer.periodic(Duration(seconds: 15),
                          (Timer t) => limaBelasDetikHabis());
                    }
                  }
                }
              } else {
                c.notifOjek.value = hasil['orderOjek'];
              }
            }

            //UPDATE IN PROSES ORDER
          } else if (hasil['status'] == 'on proses order') {
            //UPDATE LOKASI TERUS
            if (c.kodeJualPengantaranDriver.value != hasil['kodetrx']) {
              if (hasil['fitur'] == 'Ojek') {
                c.kodeJualPengantaranDriver.value = hasil['kodetrx'];
                lokalNotifikasiTerbaik(
                    8,
                    c.namaAplikasi + ' : Pengantaran Umum',
                    'Ada pengantaran yang masuk buat kamu via Autobid, Yuk di buka');
                AwesomeDialog(
                    context: Get.context,
                    dialogType: DialogType.noHeader,
                    animType: AnimType.scale,
                    title: 'Ada permintaan pengantaran',
                    desc: 'Kamu mendapatkan order pengantaran ',
                    btnOkText: 'Buka Order',
                    btnOkOnPress: () async {
                      Get.to(() => OrderPengantaranOjek());
                    })
                  ..show();
              }
            }
            timerDriver?.cancel();
            timerDriver = Timer.periodic(
                Duration(seconds: 9), (Timer t) => statusDriverTerbaru());
          }
        }
      }
    }
  }

  void perpanjangWaktuDanCekExpire() async {
    timer15detik?.cancel();
    timerDriver?.cancel();
    bool conn = await cekInternet();
    if (conn) {
      //BODY YANG DIKIRIM
      Box dbbox = Hive.box<String>('sasukaDB');
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');
      var kodeJual = c.kodeJualPengantaranDriver.value;
      var user = dbbox.get('loginSebagai');

      var datarequest = '{"pid":"$pid","kodeJual":"$kodeJual"}';
      var bytes = utf8.encode(datarequest + '$token' + user);
      var signature = md5.convert(bytes).toString();
      if (user != 'Member') {
        return;
      }
      var url = Uri.parse(
          '${c.baseURLdriver}/mobileAppsMitraDriver/perpanjangWaktuKurir');

      final response = await http.post(url, body: {
        "user": user,
        "appid": c.appid,
        "data_request": datarequest,
        "sign": signature,
        "package": c.packageName
      });

      // print(response.body);
      // print('perpanjangWaktuDanCekExpire-Dashboardku');
      if (response.statusCode == 200) {
        Map<String, dynamic> hasil = jsonDecode(response.body);
        if (hasil['status'] == 'success') {
          timerPerpanjang =
              Timer.periodic(Duration(seconds: 28), (Timer t) => waktuExpire());
          Get.to(() => KonfirmasiKurirUmum());
        } else if (hasil['status'] == 'expire') {
          AwesomeDialog(
              context: Get.context,
              dialogType: DialogType.noHeader,
              animType: AnimType.scale,
              title: 'Order Selesai',
              desc:
                  'Opps... sepertinya order ini telah diselesaikan, Order berikutnya akan segera datang, Segera buka order dan menerima pengantaran ya...',
              btnOkText: 'Ok, Siap',
              btnOkOnPress: () async {
                Get.back();
              })
            ..show();
        }
      }
    }
  }

  waktuExpire() {
    timerDriver?.cancel();
    timerDriver = Timer.periodic(
        Duration(seconds: 8), (Timer t) => statusDriverTerbaru());

    if (c.telahTerimaOrder.value == true) {
      return;
    }
    if (c.btnOnlineOffline.value == 'Offline') {
      return;
    }

    c.buttonTerimaOrderKurir.value = false;
    timerPerpanjang?.cancel();

    Get.back();

    AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.scale,
        title: 'Order Telah Diselesaikan',
        desc:
            'Opps... sepertinya order ini telah diselesaikan, Order berikutnya akan segera datang, Segera buka order dan menerima pengantaran ya...',
        btnOkText: 'Tutup',
        btnOkOnPress: () async {
          Get.back();
        })
      ..show();

    timer15detik = Timer.periodic(
        Duration(seconds: 15), (Timer t) => limaBelasDetikHabis());
  }

  limaBelasDetikHabis() {
    Get.back();
    timer15detik?.cancel();
    c.kodeJualPengantaranDriver.value = '';
    timerDriver?.cancel();
    timerDriver = Timer.periodic(
        Duration(seconds: 5), (Timer t) => statusDriverTerbaru());
  }

  void perpanjangWaktuDanCekExpireOjek() async {
    timer15detik?.cancel();
    timerDriver?.cancel();
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var kodeJual = c.kodeJualPengantaranDriver.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","kodeJual":"$kodeJual"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();
    if (user != 'Member') {
      return;
    }
    var url = Uri.parse(
        '${c.baseURLdriver}/mobileAppsMitraDriver/perpanjangWaktuOjek');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    print(response.body);
    print('perpanjangWaktuDanCekExpireOjek-Dashboardku');
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        timerPerpanjang =
            Timer.periodic(Duration(seconds: 28), (Timer t) => waktuExpire());
        Get.to(() => KonfirmasiOrderOjek());
      } else if (hasil['status'] == 'expire') {
        AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.noHeader,
            animType: AnimType.scale,
            title: 'Order Telah Diselesaikan',
            desc:
                'Opps... sepertinya order ini telah Diselesaikan, Order berikutnya akan segera datang, Segera buka order dan menerima pengantaran ya...',
            btnOkText: 'Ok, Siap',
            btnOkOnPress: () async {
              Get.back();
            })
          ..show();
      }
    }
  }

  void getDataJuduldanGambar() async {
    Box dbbox = Hive.box<String>('sasukaDB');
    var pid = dbbox.get('person_id');
    var user = 'Non Registered User';
    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + 'cbf4aq3' + user + c.appid);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/getDataJuduldanGambar');
    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    // EasyLoading.dismiss();
    //print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        c.scrool = hasil['runningText'];
        c.judul3.value = hasil['judul3'];
        c.judul3sub.value = hasil['judul3sub'];
        c.judul3gambar.value = hasil['judul3gambar'];
        c.judul4sub.value = hasil['judul4sub'];
        c.judul4gambar.value = hasil['judul4gambar'];
        c.daftarMenuUtama = hasil['daftarMenuUtama'];

        c.judul1.value = hasil['judul1'];
        c.judul1sub.value = hasil['judul1sub'];

        c.judulMarketplaceText.value = hasil['judulMarketplaceText'];
        c.marketplaceText.value = hasil['marketplaceText'];

        c.freshmartText.value = hasil['freshmartText'];
        c.makananText.value = hasil['makananText'];

        c.judulFreshmartText.value = hasil['judulFreshmartText'];
        c.judulMakananText.value = hasil['judulMakananText'];
      }
    }
  }

  void cekSaldokuDulu() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/ceksaldo');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
    });
    //print(response.body);

    // EasyLoading.dismiss();
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        c.saldo.value = hasil['saldo'];
        c.saldoInt.value = hasil['saldoInt'];
      }
    }
  }

  var cek3x = 0;
  void cekDriverAktifdiDCN() async {
    cek3x = cek3x + 1;
    if (cek3x > 3) {
      timerApakahAkunIniDriverDCN?.cancel();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLdriver}/mobileAppsMitraDriver/terdaftarDriver');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    // print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        c.driverAktif.value = hasil['aktif'];
        timerApakahAkunIniDriverDCN?.cancel();
        timerUpdateLokasiDriver = Timer.periodic(
            Duration(seconds: 10), (Timer t) => updateLokasiDriver());
      }
    }
  }

  void updateLokasiDriver() async {
    await determinePosition();
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var latt = c.latitude.value;
    var longg = c.longitude.value;
    var user = dbbox.get('loginSebagai');
    var datarequest = '{"pid":"$pid","lat":"$latt","long":"$longg"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();
    var url = Uri.parse(
        '${c.baseURLdriver}/mobileAppsMitraDriver/updateLokasiDriver');
    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });
    if (response.statusCode == 200) {
      // print(response.body);
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {}
    }
  }
}
