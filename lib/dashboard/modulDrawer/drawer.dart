import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../base/notifikasiBuatAkun.dart';
import '../view/dashboard.dart';
import 'modulAgensi.dart';
import 'modulMitra.dart';
import 'modulPrivacy.dart';
import 'modulSimpanPinjam.dart';
import 'modulSimpanan.dart';
import 'modulTombolLoginLogout.dart';
import '/base/warna.dart';
import '/base/api_service.dart';
import '../../folderUmum/pengaturan/setting.dart';
import '../../folderUmum/pengaturan/setting2.dart';
import '../../folderUmum/transaksi/viewpenarikan.dart';
import 'fotoprofil.dart';
import 'package:http/http.dart' as http;

class DrawerProfil extends StatefulWidget {
  @override
  _DrawerProfilState createState() => _DrawerProfilState();
}

class _DrawerProfilState extends State<DrawerProfil> {
  final controllerPin = TextEditingController();
  final controllerPinW = TextEditingController();
  final controllerSS = TextEditingController();

//pengaturan kamera
  Box dbbox = Hive.box<String>('sasukaDB');
  final c = Get.find<ApiService>();

  TextStyle styleHuruf1 =
      TextStyle(fontSize: 14, color: Warna.grey, fontWeight: FontWeight.w600);
  TextStyle styleHuruf2 = TextStyle(
      fontSize: 27, color: Warna.warnautama, fontWeight: FontWeight.w600);
  TextStyle styleHurufkecil = TextStyle(fontSize: 8, color: Warna.grey);

  @override
  void initState() {
    super.initState();
    // cekApakahAgency();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Container(
      child: Stack(
        children: [
          ListView(
            children: [
              FotoProfile(),
              Container(
                padding: EdgeInsets.fromLTRB(11, 11, 11, 11),
                child: Column(
                  children: [
                    Obx(() => Container(
                          child: (c.mitraReferal.value == '1')
                              ? Container(
                                  child: (c.refferal.value > 1)
                                      ? Column(
                                          children: [
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(top: 5)),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Center(
                                              child: Text(
                                                  'Masukan Kode Refferal',
                                                  style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 43, 35, 35),
                                                      fontSize: 14)),
                                            ),
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  25, 10, 25, 0),
                                              child: TextField(
                                                maxLength: 8,
                                                controller: controllerSS,
                                                decoration: InputDecoration(
                                                    suffixIcon: IconButton(
                                                      icon: Icon(Icons.search),
                                                      onPressed: () {
                                                        if (c.loginAsPenggunaKita
                                                                .value ==
                                                            'Member') {
                                                          if (controllerSS.text
                                                                  .length ==
                                                              8) {
                                                            periksaKodeSS();
                                                          } else {
                                                            Get.snackbar(
                                                                'Error',
                                                                'Kode Anggota tidak valid',
                                                                colorText:
                                                                    Colors
                                                                        .white);
                                                          }
                                                        } else {
                                                          var judulF =
                                                              'Kode referal';
                                                          var subJudul =
                                                              'Untuk menambahkan kode referal kamu memerlukan akun ${c.namaAplikasi}, Yuk Buka akun ${c.namaAplikasi} sekarang';

                                                          bukaLoginPage(
                                                              judulF, subJudul);
                                                        }
                                                      },
                                                    ),
                                                    prefixIcon:
                                                        Icon(Icons.link),
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10))),
                                              ),
                                            ),
                                          ],
                                        ),
                                )
                              : Container(),
                        )),
                    Padding(padding: EdgeInsets.only(top: 22)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Saldo SS',
                            style: TextStyle(fontSize: 12, color: Warna.grey)),
                        Obx(() => Text(
                              c.saldo.value,
                              style: styleHuruf1,
                            )),
                      ],
                    ),
                    //
                    Padding(padding: EdgeInsets.only(top: 7)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Simpanan Pokok',
                            style: TextStyle(fontSize: 12, color: Warna.grey)),
                        Obx(() => Text(
                              c.pokok.value,
                              style: styleHuruf1,
                            )),
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(top: 7)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        (c.autoDebetWajib.value == 0)
                            ? Text('Simpanan Wajib',
                                style:
                                    TextStyle(fontSize: 12, color: Warna.grey))
                            : Text('Simpanan Wajib (Auto)',
                                style:
                                    TextStyle(fontSize: 12, color: Warna.grey)),
                        Obx(() => Text(
                              c.wajib.value,
                              style: styleHuruf1,
                            ))
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(top: 7)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Voucher Belanja',
                            style: TextStyle(fontSize: 12, color: Warna.grey)),
                        Obx(() => Text(
                              c.voucherBelanja.value,
                              style: styleHuruf1,
                            )),
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(top: 7)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Point',
                            style: TextStyle(fontSize: 12, color: Warna.grey)),
                        Obx(() => Text(
                              c.pointReward.value.toString(),
                              style: styleHuruf1,
                            )),
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(top: 7)),
                    ModulSimpananSipokSiwa(),
                    Padding(padding: EdgeInsets.only(top: 15)),
                    (c.jenisKoperasi == 'KSP')
                        ? ModulSimpanPinjam()
                        : Container(),
                    Divider(color: Warna.grey),
                    Padding(padding: EdgeInsets.only(top: 11)),

                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Bank ',
                            style: TextStyle(fontSize: 12, color: Warna.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Obx(() => Flexible(
                                child: Text(
                                  c.bank.value,
                                  style: styleHuruf1,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              )),
                        ],
                      ),
                    ),
                    //
                    Padding(padding: EdgeInsets.only(top: 11)),
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Nomor Rekening',
                                style:
                                    TextStyle(fontSize: 12, color: Warna.grey)),
                            Text(
                              c.norek.value,
                              style: styleHuruf1,
                            )
                          ],
                        )),
                    Obx(() => Container(
                          child: (c.norek.value == 'Belum dibuat')
                              ? RawMaterialButton(
                                  onPressed: () {
                                    Get.to(() => PengaturanUmum());
                                  },
                                  constraints: BoxConstraints(),
                                  elevation: 1.0,
                                  fillColor: Warna.warnautama,
                                  child: Text(
                                    'Masukan Data Bank',
                                    style: TextStyle(color: Warna.putih),
                                  ),
                                  padding: EdgeInsets.fromLTRB(11, 4, 11, 4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                )
                              : RawMaterialButton(
                                  onPressed: () {
                                    if (c.loginAsPenggunaKita.value ==
                                        'Member') {
                                      if (c.pinStatus.value == '0') {
                                        AwesomeDialog(
                                            context: Get.context,
                                            dialogType: DialogType.noHeader,
                                            animType: AnimType.rightSlide,
                                            title: 'PIN Dibutuhkan',
                                            desc:
                                                'Opss... Sepertinya kamu belum membuat PIN, PIN dibutuhkan untuk melakukan transaksi finansial. Apakah kamu mau membuat pin ?',
                                            btnCancelText: 'Tidak',
                                            btnCancelOnPress: () {},
                                            btnOkText: 'Ya',
                                            btnOkOnPress: () {
                                              Get.offAll(Dashboardku());
                                              Get.to(() => PengaturanUmumPin());
                                            })
                                          ..show();
                                      } else {
                                        Get.offAll(Dashboardku());
                                        Get.to(() => ViewPenarikan());
                                      }
                                    } else {
                                      var judulF = 'Penarikan Dana';
                                      var subJudul =
                                          'Tarik saldo dan pindahkan ke rekening Bank kamu dengan mudah, Yuk Buka akun ${c.namaAplikasi} sekarang';

                                      bukaLoginPage(judulF, subJudul);
                                    }
                                  },
                                  constraints: BoxConstraints(),
                                  elevation: 1.0,
                                  fillColor: Warna.warnautama,
                                  child: Text(
                                    'Buat penarikan dana',
                                    style: TextStyle(color: Warna.putih),
                                  ),
                                  padding: EdgeInsets.all(4.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(9)),
                                  ),
                                ),
                        )),

                    //
                    Divider(color: Warna.grey),
                    Padding(padding: EdgeInsets.only(top: 11)),
                    //-----------------------------------------------------------
                    //-------------------Modul Mitra Usaha
                    ModulMitraUsaha(),
                    Padding(padding: EdgeInsets.only(top: 11)),
                    Divider(),
                    //-----------------------------------------------------------
                    //-------------------Modul Agensi
                    ModulAgensi(),
                    TombolLoginLogout(),
                    Padding(padding: EdgeInsets.only(top: 22)),
                    //-----------------------------------------------------------
                    //-------------------Modul Privacy Policy
                    ModulPrivacyPolicy(),
                    //
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  void periksaKodeSS() async {
    var kodess = controllerSS.text;

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    //item search
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","kodess":"$kodess"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/cekSS');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    // EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        controllerSS.text = '';
        var dataku = hasil['data'];

        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: '',
          desc: '',
          body: Column(
            children: [
              Image.network(
                '${c.baseURL}/img/avatars/${dataku[2]}',
                width: Get.width * 0.4,
              ),
              Padding(padding: EdgeInsets.only(top: 9)),
              Text(dataku[0],
                  style: TextStyle(
                      fontSize: 18,
                      color: Warna.grey,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
              Text(
                dataku[1],
                style: TextStyle(fontSize: 14, color: Warna.grey),
              ),
              Divider(
                color: Warna.grey,
              ),
              Text(
                  'Kode Akun ${c.namaAplikasi} yang kamu masukan adalah ${dataku[0]}, Klik untuk memasukan kode refferal',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center),
              Padding(padding: EdgeInsets.only(top: 8)),
              ElevatedButton(
                  onPressed: () {
                    prosesReferal(dataku[1]);
                  },
                  child: Text('Proses Refferal')),
            ],
          ),
        )..show();
      } else {
        controllerSS.text = '';
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.warning,
          animType: AnimType.rightSlide,
          title: 'Pencarian Gagal',
          desc: 'Opps... sepertinya kode SS yang kamu masukan tidak sesuai',
          btnCancelText: 'OK SIAP',
          btnCancelColor: Colors.amber,
          btnCancelOnPress: () {},
        )..show();
      }
    }
  }

  void prosesReferal(kodessteman) async {
//BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    //item search
    var datarequest = '{"pid":"$pid","kodess":"$kodessteman"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/referalNow');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    // EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        Get.back();
        c.refferal.value = hasil['uplink'];
        Get.snackbar(
            'Proses Berhasil', "Proses penambahan referal berhasil dilakukan",
            snackPosition: SnackPosition.BOTTOM);
      } else {
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.warning,
          animType: AnimType.rightSlide,
          title: 'PROSES GAGAL',
          desc: 'Opps... Gagal Menambahkan Referal',
          btnCancelText: 'OK SIAP',
          btnCancelColor: Colors.amber,
          btnCancelOnPress: () {},
        )..show();
      }
    }
  }
}
