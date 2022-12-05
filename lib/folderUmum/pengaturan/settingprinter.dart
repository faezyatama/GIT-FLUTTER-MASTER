import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../base/notifikasiBuatAkun.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import '/cetak/testCetak.dart';

class SettingPrinter extends StatefulWidget {
  @override
  _SettingPrinterState createState() => _SettingPrinterState();
}

class _SettingPrinterState extends State<SettingPrinter> {
  final controllerTagline = TextEditingController();
  final controllerPesan = TextEditingController();
  final controllernamaOutlet = TextEditingController();
  var hargaDiatur = '';
  final c = Get.find<ApiService>();

  @override
  void initState() {
    super.initState();

    Box dbbox = Hive.box<String>('sasukaDB');
    var namaOutlet = dbbox.get('namaOutlet');
    var tagLine = dbbox.get('tagLine');
    var hargaDiatur = dbbox.get('hargaDiatur');
    var footer = dbbox.get('footer');

    if (namaOutlet == null) {
      controllernamaOutlet.text = '${c.namaAplikasi}';
    } else {
      controllernamaOutlet.text = namaOutlet;
    }
    if (tagLine == null) {
      controllerTagline.text = ' --APLIKASI MULTIFUNGSI-- ';
    } else {
      controllerTagline.text = tagLine;
    }
    if (hargaDiatur == null) {
      hargaDiatur = 'SATUAJA';
    } else {
      hargaDiatur = 'SENDIRI';
    }
    if (footer == null) {
      controllerPesan.text = 'Terima Kasih telah bertransaksi bersama kami';
    } else {
      controllerPesan.text = footer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(22),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pengaturan Printer',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black54)),
                    Text('Bluetooth printer'),
                  ],
                ),
                Image.asset(
                  'images/Printer.png',
                  width: Get.width * 0.2,
                )
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 22)),
            Text(
                'Aplikasi ${c.namaAplikasi} mendukung mesin cetak dengan koneksi Bluetooth, kamu dapat mencetak struk untuk pulsa dan berbagai pembayaran tagihan bulanan'),
            Padding(padding: EdgeInsets.only(top: 10)),
            Text('Pastikan printer kamu mendukung fitur ini'),
            Padding(padding: EdgeInsets.only(top: 33)),
            Container(
              // margin: EdgeInsets.fromLTRB(25, 25, 25, 0),
              child: TextField(
                controller: controllernamaOutlet,
                decoration: InputDecoration(
                    labelText: 'Nama Outlet Kamu',
                    //prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            Container(
              // margin: EdgeInsets.fromLTRB(25, 25, 25, 0),
              child: TextField(
                controller: controllerTagline,
                decoration: InputDecoration(
                    labelText: 'Tag Line',
                    //prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            Container(
              // margin: EdgeInsets.fromLTRB(25, 25, 25, 0),
              child: TextField(
                controller: controllerPesan,
                decoration: InputDecoration(
                    labelText: 'Ketik Pesan pada struk',
                    //prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                child: DropdownSearch<String>(
                    popupProps: PopupProps.menu(
                      showSelectedItems: true,
                      disabledItemFn: (String s) => s.startsWith('I'),
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Pengaturan harga",
                      ),
                    ),
                    items: ['aplikasi ${c.namaAplikasi}', 'Sendiri'],

                    // popupItemDisabled: (String s) => s.startsWith('I'),
                    onChanged: (harga) {
                      Hive.box<String>('sasukaDB').put('hargaDiatur', harga);
                    },
                    selectedItem:
                        Hive.box<String>('sasukaDB').get('hargaDiatur'))),
            Padding(padding: EdgeInsets.only(top: 11)),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Warna.warnautama),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: Warna.putih)))),
              onPressed: () {
                Get.to(TestCetak());
              },
              child: Text(
                'Test Cetak',
                style: TextStyle(color: Warna.putih),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Warna.warnautama),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: Warna.putih)))),
              onPressed: () {
                if (c.loginAsPenggunaKita.value == 'Member') {
                  Hive.box<String>('sasukaDB')
                      .put('namaOutlet', controllernamaOutlet.text);
                  Hive.box<String>('sasukaDB')
                      .put('tagLine', controllerTagline.text);
                  Hive.box<String>('sasukaDB')
                      .put('footer', controllerPesan.text);
                  Get.snackbar('Pengaturan Sukses',
                      'Pengaturan Cetak Struk telah selesai');

                  AwesomeDialog(
                    context: Get.context,
                    dialogType: DialogType.success,
                    animType: AnimType.rightSlide,
                    title: 'STRUK TELAH DI SET',
                    desc: 'Kamu telah berhasil mengatur tampilan struk cetak',
                    btnOkText: 'OK',
                    btnOkOnPress: () {},
                  )..show();
                } else {
                  var judulF = 'Pengaturan Printer';
                  var subJudul =
                      'Mencetak struk transaksi dengan mudah menggunakan aplikasi ini, Yuk Buka akun ${c.namaAplikasi} sekarang';

                  bukaLoginPage(judulF, subJudul);
                }
              },
              child: Text(
                'Update Pengaturan Printer',
                style: TextStyle(color: Warna.putih),
              ),
            ),
          ],
        ));
    //
  }
}
