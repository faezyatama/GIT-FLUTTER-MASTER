import 'dart:convert';
import 'dart:io';
// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:crypto/crypto.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import '../../base/notifikasiBuatAkun.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:async/async.dart';

class SettingBuatPin extends StatefulWidget {
  @override
  _SettingBuatPinState createState() => _SettingBuatPinState();
}

class _SettingBuatPinState extends State<SettingBuatPin> {
  //SETTING FOCUS NODE

  FocusNode focuspin1;
  FocusNode focusTanya;
  FocusNode focusJawab;

  @override
  void initState() {
    super.initState();
    focuspin1 = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    focuspin1.dispose();
    focusTanya.dispose();
    focusJawab.dispose();
    super.dispose();
  }
  //===================END FOCUS NODE

  final cpin1 = TextEditingController();
  final cpin2 = TextEditingController();
  final ctanya = TextEditingController();
  final cjawab = TextEditingController();

  String selectedItem = '';
  String hasiltanya = '';
  String ktp = '';

  List<String> pertanyaan = [
    'Nama hewan kesayangan ?',
    'Negara yang ingin dikunjungi ?',
    'Nama pacar pertama saya ?',
    'Makanan kesukaan ?',
    'Nama ibu kandung saya ?',
    'Buat pertanyaan keamanan sendiri'
  ];
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
                    Text('Buat PIN',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black54)),
                    Text('(Personal Identification Number)'),
                  ],
                ),
                Image.asset(
                  'images/secure.png',
                  width: Get.width * 0.2,
                )
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 22)),
            Padding(padding: EdgeInsets.only(top: 10)),
            Text(
                'Untuk alasan keamanan jangan memberitahukan PIN ini kepada siapapun termasuk pihak ${c.namaAplikasi}'),
            Padding(padding: EdgeInsets.only(top: 33)),
            Text(
              '1.  Buat PIN',
              style: TextStyle(fontSize: 20),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(30, 5, 5, 0),
              child: Text(
                  'PIN adalah 6 angka unik yang dipakai untuk melakukan transaksi keuangan, Gunakan PIN yang mudah diingat dan pastikan PIN ini cuma kamu yang tahu',
                  style: TextStyle(color: Warna.grey)),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(30, 5, 5, 0),
              child: TextField(
                focusNode: focuspin1,
                maxLength: 6,
                controller: cpin1,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: 'PIN Baru',
                    prefixIcon: Icon(Icons.security_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            Container(
              margin: EdgeInsets.fromLTRB(30, 5, 5, 0),
              child: TextField(
                controller: cpin2,
                maxLength: 6,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: 'PIN Baru',
                    prefixIcon: Icon(Icons.security_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 30)),
            Text(
              '2. Pertanyaan Keamanan',
              style: TextStyle(fontSize: 20),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(30, 5, 5, 0),
              child: Text(
                  'Buatlah/pilih pertanyaan keamanan berserta jawaban kamu, ${c.namaAplikasi} akan menanyakannya apabila kamu lupa PIN yang telah dibuat',
                  style: TextStyle(color: Warna.grey)),
            ),
            Padding(padding: EdgeInsets.only(top: 5)),
            Container(
              margin: EdgeInsets.fromLTRB(30, 11, 5, 0),
              child: DropdownSearch<String>(
                  popupProps: PopupProps.menu(
                    showSelectedItems: true,
                    disabledItemFn: (String s) => s.startsWith('I'),
                  ),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Pertanyaan Kemanan",
                    ),
                  ),
                  items: pertanyaan,
                  onChanged: (v) {
                    setState(() {
                      selectedItem = v;
                    });
                  },
                  selectedItem: 'Nama pacar pertama saya ?'),
            ),
            (selectedItem == 'Buat pertanyaan keamanan sendiri')
                ? Container(
                    margin: EdgeInsets.fromLTRB(30, 5, 5, 0),
                    child: TextField(
                      controller: ctanya,
                      maxLength: 50,
                      focusNode: focusTanya,
                      decoration: InputDecoration(
                          labelText: 'Pertanyaan keamanan',
                          prefixIcon: Icon(Icons.question_answer),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  )
                : Padding(padding: EdgeInsets.only(top: 5)),
            Container(
              margin: EdgeInsets.fromLTRB(30, 5, 5, 0),
              child: TextField(
                controller: cjawab,
                maxLength: 50,
                focusNode: focusJawab,
                decoration: InputDecoration(
                    labelText: 'Jawaban kamu',
                    prefixIcon: Icon(Icons.check),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 30)),
            Text(
              '3. Upload Identitas',
              style: TextStyle(fontSize: 20),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(30, 5, 5, 0),
              child: GestureDetector(
                  onTap: () {
                    if (c.loginAsPenggunaKita.value == 'Member') {
                      getImageCamera();
                    } else {
                      var judulF = 'Pengaturan PIN';
                      var subJudul =
                          'Untuk bertransaksi di ${c.namaAplikasi} membutuhkan PIN untuk memanfaatkan fitur ini, Yuk Buka akun ${c.namaAplikasi} sekarang';

                      bukaLoginPage(judulF, subJudul);
                    }
                  },
                  child: (ktp == '')
                      ? Image.asset(
                          'images/ktp.png',
                          width: 222,
                          height: 190,
                          fit: BoxFit.fitWidth,
                        )
                      : Image.file(
                          _image,
                          width: 222,
                          height: 190,
                          fit: BoxFit.fitWidth,
                        )),
            ),
            GestureDetector(
              onTap: () {
                if (c.loginAsPenggunaKita.value == 'Member') {
                  getImageCamera();
                } else {
                  var judulF = 'Pengaturan PIN';
                  var subJudul =
                      'Untuk bertransaksi di ${c.namaAplikasi} membutuhkan PIN untuk memanfaatkan fitur ini, Yuk Buka akun ${c.namaAplikasi} sekarang';

                  bukaLoginPage(judulF, subJudul);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    color: Colors.blue,
                  ),
                  Text('Klik untuk membuka kamera',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            Padding(padding: EdgeInsets.only(top: 11)),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Warna.warnautama),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: Warna.warnautama)))),
              onPressed: () {
                if (c.loginAsPenggunaKita.value == 'Member') {
                  if (selectedItem == 'Buat pertanyaan keamanan sendiri') {
                    hasiltanya = ctanya.text;
                  } else {
                    hasiltanya = selectedItem;
                  }

                  buatPinBaru(cpin1.text, cpin2.text, hasiltanya, cjawab.text);
                } else {
                  var judulF = 'Pengaturan PIN';
                  var subJudul =
                      'Untuk bertransaksi di ${c.namaAplikasi} membutuhkan PIN untuk memanfaatkan fitur ini, Yuk Buka akun ${c.namaAplikasi} sekarang';

                  bukaLoginPage(judulF, subJudul);
                }
              },
              child: Text(
                'Update PIN Sekarang',
                style: TextStyle(color: Warna.putih),
              ),
            ),
          ],
        ));
    //
  }

  void buatPinBaru(pin1, pin2, tanya, jawab) async {
    var cpassword = TextEditingController();

    if (pin1.length != 6) {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        title: 'Pengaturan PIN',
        desc: 'Opps... PIN hanya boleh terdiri dari 6 angka, Silahkan diulangi',
        btnCancelText: 'OK',
        btnCancelOnPress: () {},
      )..show();
    } else if (pin1 != pin2) {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        title: 'Pengaturan PIN',
        desc: 'Opps... PIN yang dimasukan tidak sama',
        btnCancelText: 'OK',
        btnCancelOnPress: () {
          focuspin1.requestFocus();
        },
      )..show();
    } else if (tanya == '') {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        title: 'Pengaturan PIN',
        desc: 'Opps... Kamu belum membuat pertanyaan keamanan',
        btnCancelText: 'OK',
        btnCancelOnPress: () {
          focusTanya.requestFocus();
        },
      )..show();
    } else if (jawab == '') {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        title: 'Pengaturan PIN',
        desc: 'Opps... Kamu belum membuat JAWABAN dari pertanyaan keamanan',
        btnCancelText: 'OK',
        btnCancelOnPress: () {
          focusJawab.requestFocus();
        },
      )..show();
    } else if (ktp == '') {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        title: 'Pengaturan PIN',
        desc:
            'Kami membutuhkan KTP/SIM untuk melakukkan verifikasi data. Silahkan Foto KTP/SIM kamu ya',
        btnOkIcon: Icons.camera_alt,
        btnOkOnPress: () {},
        btnOkText: 'Buka Kamera',
      )..show();
    } else {
      AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.warning,
          animType: AnimType.rightSlide,
          customHeader: Center(
              child: Icon(
            Icons.lock,
            size: Get.width * 0.15,
            color: Warna.warnautama,
          )),
          title: '',
          desc: '',
          body: Column(
            children: [
              Text(
                  'Password dibutuhkan untuk membuat PIN, Silahkan masukan password kamu'),
              Padding(padding: EdgeInsets.only(top: 8)),
              TextField(
                controller: cpassword,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: 'Password Dibutuhkan',
                    prefixIcon: Icon(Icons.vpn_key),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ],
          ),
          btnOkText: 'Buat PIN Sekarang',
          btnOkColor: Warna.warnautama,
          btnOkOnPress: () {
            if (cpassword.text == '') {
              AwesomeDialog(
                context: Get.context,
                dialogType: DialogType.noHeader,
                animType: AnimType.rightSlide,
                title: 'Pengaturan PIN',
                desc: 'Opps... Password dibutuhkan untuk membuat pin',
                btnCancelText: 'OK',
                btnCancelOnPress: () {},
              )..show();
            } else {
              prosesUploadData(pin1, pin2, tanya, jawab, cpassword.text);
            }
          })
        ..show();
    }
  }

  File _image;
  final picker = ImagePicker();
  final myController = TextEditingController();

  Future getImageCamera() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera, maxWidth: 800.0);
    if (pickedFile == null) {
      print('Foto tidak jadi diambil');
    } else {
      setState(() {
        ktp = 'Gambar sudah dipilih';
        _image = File(pickedFile.path);
      });
    }
  }

//PROSES UPLOAD DATA

  final c = Get.find<ApiService>();
  void prosesUploadData(pin1, pin2, tanya, jawab, password) async {
    EasyLoading.instance
      ..userInteractions = false
      ..dismissOnTap = false;
    EasyLoading.show(status: 'Wait ...');
//UPLOAD DATA
    var stream = new http.ByteStream(DelegatingStream(_image.openRead()));
    var length = await _image.length();
    var uri = Uri.parse(c.baseURL + '/mobileApps/buatpin');

    var request = new http.MultipartRequest('POST', uri);
    var multipartFile = new http.MultipartFile('image', stream, length,
        filename: basename(_image.path));

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var pid = dbbox.get('person_id');
    var token = dbbox.get('token');
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","pinBaru":"$pin1","psw":"$password","tanya":"$tanya","jawab":"$jawab"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    request.fields['user'] = dbbox.get('loginSebagai');
    request.fields['data_request'] = datarequest;
    request.fields['sign'] = signature;
    request.fields['appid'] = c.appid;

    request.files.add(multipartFile);

    try {
      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      EasyLoading.dismiss();
      Map<String, dynamic> hasil = jsonDecode(responseString);
      print(responseString);
      if (hasil['status'] == 'success') {
        print(responseString);

        dbbox.put('pinStatus', hasil['pinStatus']);
        c.pinStatus.value = hasil['pinStatus'];
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'BERHASIL',
          desc: 'PIN telah berhasil dibuat.',
          btnOkText: 'OK',
          btnOkOnPress: () {
            Get.back();
          },
        )..show();
      } else {
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'PEMBUATAN PIN GAGAL',
          desc: 'Password yang dimasukan tidak sesuai, Silahkan ulangi',
          btnCancelText: 'OK',
          btnCancelOnPress: () {},
        )..show();
      }
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar('Error Terjadi',
          'Opps Sepertinya error terjadi, silahkan ulangi proses');
    }
  }
}
