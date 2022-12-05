import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import 'daftar_no_hp.dart';

class DaftarAplikasi extends StatefulWidget {
  @override
  _DaftarAplikasiState createState() => _DaftarAplikasiState();
}

class _DaftarAplikasiState extends State<DaftarAplikasi> {
  final controllerNama = TextEditingController();
  final controllerJK = TextEditingController();
  final c = Get.find<ApiService>();
  var goldar = '';
  var jk = '';
  //SETTING FOCUS NODE
  FocusNode myFocusNode;
  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();
    super.dispose();
  }
  //===================END FOCUS NODE

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.warnautama,
        title: Text('Daftar Akun'),
      ),
      body: Container(
        margin: EdgeInsets.all(0),
        child: ListView(
          children: [
            Image.asset('images/whitelabelRegister/daftar.png'),
            Container(
              margin: EdgeInsets.only(left: 22, right: 22),
              child: Text(
                'Hallo sahabatku...',
                style: TextStyle(
                    color: Warna.grey,
                    fontSize: 26,
                    fontWeight: FontWeight.w300),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 22, right: 22),
              child: Text(
                'Membuat akun di ${c.namaAplikasi} sangat mudah loh, ikuti langkah berikut ya...',
                style: TextStyle(color: Warna.grey, fontSize: 16),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(22, 22, 22, 3),
              child: Text('Nama Lengkap (Sesuai KTP)',
                  style: TextStyle(fontSize: 10, color: Warna.warnautama)),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(22, 0, 22, 5),
              child: TextField(
                focusNode: myFocusNode,
                controller: controllerNama,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5))),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            Container(
              margin: EdgeInsets.fromLTRB(22, 0, 22, 0),
              child: Text('Jenis Kelamin',
                  style: TextStyle(fontSize: 10, color: Warna.warnautama)),
            ),
            Container(
                margin: EdgeInsets.fromLTRB(22, 0, 22, 5),
                child: DropdownSearch<String>(
                    items: ['Laki-laki', 'Perempuan'],
                    onChanged: (jkValue) {
                      jk = jkValue;
                      Hive.box<String>('sasukaDB')
                          .put('regJenisKelamin', jkValue);
                    },
                    selectedItem: '')),
            Padding(padding: EdgeInsets.only(top: 11)),
            Container(
              margin: EdgeInsets.fromLTRB(22, 0, 22, 0),
              child: Text('Golongan Darah',
                  style: TextStyle(fontSize: 10, color: Warna.warnautama)),
            ),
            Container(
                margin: EdgeInsets.fromLTRB(22, 0, 22, 5),
                child: DropdownSearch<String>(
                    items: ['A', 'B', 'AB', 'O'],

                    // popupItemDisabled: (String s) => s.startsWith('I'),
                    onChanged: (propValue) {
                      goldar = propValue;
                      Hive.box<String>('sasukaDB').put('reggoldar', propValue);
                    },
                    selectedItem: '')),
            Padding(padding: EdgeInsets.only(top: 11)),
            Container(
              margin: EdgeInsets.fromLTRB(22, 0, 22, 5),
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Warna.warnautama),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(color: Warna.warnautama)))),
                onPressed: () {
                  print(jk);
                  if ((controllerNama.text == '')) {
                    Get.snackbar('Register', 'Nama lengkap kamu belum diisi',
                        snackPosition: SnackPosition.BOTTOM);
                    myFocusNode.requestFocus();
                  } else if (jk == '') {
                    Get.snackbar('Register', 'Pilih jenis kelamin',
                        snackPosition: SnackPosition.BOTTOM);
                  } else if (goldar == '') {
                    Get.snackbar('Register', 'Pilih Golongan Darah',
                        snackPosition: SnackPosition.BOTTOM);
                  } else {
                    Hive.box<String>('sasukaDB')
                        .put('regNama', controllerNama.text);

                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      return DaftarkanHp();
                    }));
                  }
                },
                child: Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
