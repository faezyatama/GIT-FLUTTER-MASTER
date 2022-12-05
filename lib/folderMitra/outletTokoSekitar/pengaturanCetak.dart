import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/warna.dart';

class PengaturanCetakTS extends StatefulWidget {
  @override
  _PengaturanCetakTSState createState() => _PengaturanCetakTSState();
}

class _PengaturanCetakTSState extends State<PengaturanCetakTS> {
  final ctrlFooter = TextEditingController();
  final ctrlFooter2 = TextEditingController();
  final ctrlTagline = TextEditingController();

  @override
  void initState() {
    super.initState();
    Box dbbox = Hive.box<String>('sasukaDB');

    ctrlTagline.text = dbbox.get('taglineTS');
    ctrlFooter.text = dbbox.get('footerTS');
    ctrlFooter2.text = dbbox.get('footerTS2');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Atur Pencetakan Struk'),
        backgroundColor: Colors.green,
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(11),
        child: RawMaterialButton(
          onPressed: () {
            Box dbbox = Hive.box<String>('sasukaDB');
            dbbox.put('taglineTS', ctrlTagline.text);
            dbbox.put('footerTS', ctrlFooter.text);
            dbbox.put('footerTS2', ctrlFooter2.text);

            Get.back();
            AwesomeDialog(
              context: Get.context,
              dialogType: DialogType.noHeader,
              animType: AnimType.scale,
              title: 'Pengaturan Berhasil',
              desc:
                  'Pengaturan pencetakan struk penjualan telah berhasil dilakukan',
              btnOkText: 'Ok Siap',
              btnOkColor: Colors.green,
              btnOkOnPress: () {},
            )..show();
          },
          constraints: BoxConstraints(),
          elevation: 1.0,
          fillColor: Colors.green,
          child: Text(
            'Atur pencetakan sekarang !',
            style: TextStyle(color: Warna.putih, fontSize: 16),
          ),
          padding: EdgeInsets.fromLTRB(22, 11, 22, 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(9)),
          ),
        ),
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            child: Text(
              'Pencetakan Struk',
              style: TextStyle(
                  fontSize: 33, color: Warna.grey, fontWeight: FontWeight.w200),
            ),
          ),
          Container(
            padding: EdgeInsets.all(12),
            child: Text(
              'Untuk mencetak struk transaksi penjualan online dan offline kamu bisa menggunakan Printer Bluetooth yang kompatibel dengan HP Android',
              style: TextStyle(
                fontSize: 14,
                color: Warna.grey,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(12),
            child: Text(
              'Pastikan bluetooth pada HP telah aktif dan telah dipasangkan/pairing ke printer Bluetooth, dan setelah Pairing berhasil kamu sudah bisa mencetak struk',
              style: TextStyle(
                fontSize: 14,
                color: Warna.grey,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(12),
            child: Text(
              'Kamu bisa juga bisa memodifikasi / mengganti Tagline toko pada bagian atas struk, atau mengganti ucapan Footer pada bagian bawah struk',
              style: TextStyle(
                fontSize: 14,
                color: Warna.grey,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(12, 3, 12, 3),
            child: TextField(
              onChanged: (ss) {},
              maxLength: 30,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Warna.warnautama),
              controller: ctrlTagline,
              decoration: InputDecoration(
                  labelText: 'Tagline',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(12, 3, 12, 3),
            child: TextField(
              onChanged: (ss) {},
              maxLength: 50,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Warna.warnautama),
              controller: ctrlFooter,
              decoration: InputDecoration(
                  labelText: 'Footer Baris 1',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(12, 3, 12, 3),
            child: TextField(
              onChanged: (ss) {},
              maxLength: 50,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Warna.warnautama),
              controller: ctrlFooter2,
              decoration: InputDecoration(
                  labelText: 'Footer Baris 2',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
        ],
      ),
    );
  }
}
