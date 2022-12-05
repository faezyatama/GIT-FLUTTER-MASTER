import 'dart:convert';
import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:async/async.dart';

class LupaPIN extends StatefulWidget {
  @override
  _LupaPINState createState() => _LupaPINState();
}

class _LupaPINState extends State<LupaPIN> {
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
  final c = Get.find<ApiService>();

  final cjawab = TextEditingController();

  String selectedItem = '';
  String hasiltanya = '';
  String ktp = '';
  String selfi = '';
  String filenamektp = '';
  String filenameselfi = '';

  String upload1 = '';
  String upload2 = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset PIN'),
        backgroundColor: Warna.warnautama,
      ),
      body: Container(
          padding: EdgeInsets.all(22),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'images/secure.png',
                    width: Get.width * 0.15,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lupa PIN ?',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black54)),
                      Text('(Personal Identification Number)'),
                    ],
                  )
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 22)),
              Padding(padding: EdgeInsets.only(top: 10)),
              Text(
                  'Jangan khawatir, ikuti langkah dibawah ini untuk mengembalikan PIN kamu, bila masih ada kendala hubungi SCS melalui LiveChat ya'),
              Padding(padding: EdgeInsets.only(top: 33)),
              Obx(() => Text(
                    '1. ' + c.pertanyaanKeamanan.value + '?',
                    style: TextStyle(fontSize: 17),
                  )),
              Padding(padding: EdgeInsets.only(top: 5)),
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
                '2. Upload Identitas (KTP/SIM)',
                style: TextStyle(fontSize: 17),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(30, 5, 5, 0),
                child: GestureDetector(
                    onTap: () {
                      getImageAndUpload();
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
                  getImageAndUpload();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, color: Warna.warnautama, size: 25),
                    Text(
                      'Klik untuk buka kamera',
                      style: TextStyle(
                        color: Warna.warnautama,
                      ),
                    )
                  ],
                ),
              ),
              (upload1 != '')
                  ? Container(
                      padding: EdgeInsets.only(left: 30, right: 5),
                      child: LinearProgressIndicator())
                  : Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 33)),
              Text(
                '3. Foto Kamu bersama (KTP/SIM)',
                style: TextStyle(fontSize: 17),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(30, 5, 5, 0),
                child: GestureDetector(
                    onTap: () {
                      getImageAndUpload2();
                    },
                    child: (selfi == '')
                        ? Image.asset(
                            'images/selfie.png',
                            width: 222,
                            height: 190,
                            fit: BoxFit.fitWidth,
                          )
                        : Image.file(
                            _image2,
                            width: 222,
                            height: 190,
                            fit: BoxFit.fitWidth,
                          )),
              ),
              GestureDetector(
                onTap: () {
                  getImageAndUpload2();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, color: Warna.warnautama, size: 25),
                    Text(
                      'Klik untuk buka kamera',
                      style: TextStyle(
                        color: Warna.warnautama,
                      ),
                    )
                  ],
                ),
              ),
              (upload2 != '')
                  ? Container(
                      padding: EdgeInsets.only(left: 30),
                      child: LinearProgressIndicator())
                  : Padding(padding: EdgeInsets.only(top: 11)),
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
                  resetPinSekarang(cjawab.text);
                },
                child: Text(
                  'Proses Lupa PIN Sekarang',
                  style: TextStyle(color: Warna.putih),
                ),
              ),
            ],
          )),
    );
    //
  }

  File _image;
  File _image2;
  final picker = ImagePicker();
  final picker2 = ImagePicker();

  Future getImageAndUpload() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera, maxWidth: 800.0);
    if (pickedFile == null) {
      //  print('Foto tidak jadi diambil');
    } else {
      setState(() {
        ktp = 'Gambar sudah dipilih';
        upload1 = 'Sedang Upload';
        _image = File(pickedFile.path);
      });

      //UPLOAD DATA
      EasyLoading.instance
        ..userInteractions = false
        ..dismissOnTap = false;
      EasyLoading.show(status: 'Wait ...');

      var stream = new http.ByteStream(DelegatingStream(_image.openRead()));
      var length = await _image.length();
      var uri = Uri.parse(c.baseURL + '/mobileApps/uploadKtp');

      var request = new http.MultipartRequest('POST', uri);
      var multipartFile = new http.MultipartFile('file1', stream, length,
          filename: basename(_image.path));

      //BODY YANG DIKIRIM
      Box dbbox = Hive.box<String>('sasukaDB');
      var pid = dbbox.get('person_id');
      var token = dbbox.get('token');
      var user = dbbox.get('loginSebagai');

      var datarequest = '{"pid":"$pid"}';
      var bytes = utf8.encode(datarequest + '$token' + user);
      var signature = md5.convert(bytes).toString();

      request.fields['user'] = dbbox.get('loginSebagai');
      request.fields['data_request'] = datarequest;
      request.fields['sign'] = signature;
      request.fields['appid'] = c.appid;

      request.files.add(multipartFile);

      var response = await request.send();
      var responseString = await response.stream.bytesToString();
      EasyLoading.dismiss();

      Map<String, dynamic> hasil = jsonDecode(responseString);
      print(responseString);
      if (hasil['status'] == 'success') {
        print(responseString);
        setState(() {
          upload1 = '';
          filenamektp = hasil['fileName'];
        });
      } else {
        print(responseString);
      }
    }
  }
//

  Future getImageAndUpload2() async {
    final pickedFile2 =
        await picker2.pickImage(source: ImageSource.camera, maxWidth: 800.0);
    if (pickedFile2 == null) {
      print('Foto tidak jadi diambil');
    } else {
      setState(() {
        selfi = 'Gambar sudah dipilih';
        upload2 = 'Sedang Upload';
        _image2 = File(pickedFile2.path);
      });

      //UPLOAD DATA
      EasyLoading.instance
        ..userInteractions = false
        ..dismissOnTap = false;
      EasyLoading.show(status: 'Wait ...');

      var stream = new http.ByteStream(DelegatingStream(_image2.openRead()));
      var length = await _image2.length();
      var uri = Uri.parse(c.baseURL + '/mobileApps/uploadKtp');

      var request = new http.MultipartRequest('POST', uri);
      var multipartFile = new http.MultipartFile('file1', stream, length,
          filename: basename(_image.path));

      //BODY YANG DIKIRIM
      Box dbbox = Hive.box<String>('sasukaDB');
      var pid = dbbox.get('person_id');
      var token = dbbox.get('token');
      var user = dbbox.get('loginSebagai');

      var datarequest = '{"pid":"$pid"}';
      var bytes = utf8.encode(datarequest + '$token' + user);
      var signature = md5.convert(bytes).toString();

      request.fields['user'] = dbbox.get('loginSebagai');
      request.fields['data_request'] = datarequest;
      request.fields['sign'] = signature;
      request.fields['appid'] = c.appid;

      request.files.add(multipartFile);

      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      Map<String, dynamic> hasil = jsonDecode(responseString);
      EasyLoading.dismiss();
      print(responseString);
      if (hasil['status'] == 'success') {
        print(responseString);
        setState(() {
          upload2 = '';
          filenameselfi = hasil['fileName'];
        });
      } else {
        print(responseString);
      }
    }
  }
//

  void resetPinSekarang(jawab) async {
    if (jawab == '') {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        title: 'RESET PIN',
        desc:
            'Kamu belum menjawab pertanyaan keamanan untuk bisa melakukan proses reset pin',
        btnCancelText: 'Ok',
        btnCancelOnPress: () {},
      )..show();
    } else if ((filenameselfi == '') || (filenamektp == '')) {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        title: 'RESET PIN',
        desc:
            'Foto KTP dan Foto Selfi bersama KTP diperlukan untuk melakukan proses reset pin',
        btnCancelText: 'Ok',
        btnCancelOnPress: () {},
      )..show();
    } else {
      // UPDATE PERMOHONAN RESET PIN
      //BODY YANG DIKIRIM
      EasyLoading.instance
        ..userInteractions = false
        ..dismissOnTap = false;
      EasyLoading.show(status: 'Wait ...');

      Box dbbox = Hive.box<String>('sasukaDB');
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');
      var user = dbbox.get('loginSebagai');

      var datarequest =
          '{"pid":"$pid","jawaban":"$jawab","fotoktp":"$filenamektp","fotoselfi":"$filenameselfi"}';
      var bytes = utf8.encode(datarequest + '$token' + user);
      var signature = md5.convert(bytes).toString();

      var url = Uri.parse('${c.baseURL}/mobileApps/ResetPin');

      try {
        final response = await http.post(url, body: {
          "user": user,
          "appid": c.appid,
          "data_request": datarequest,
          "sign": signature
        });

        EasyLoading.dismiss();
        if (response.statusCode == 200) {
          Map<String, dynamic> resultnya = jsonDecode(response.body);
          if (resultnya['status'] == 'success') {
            print(response.body);

            c.pinBlokir.value = 'terblokir';
            // c.pinReff.value = (resultnya['pinUnblock']).toString();

            AwesomeDialog(
              context: Get.context,
              dialogType: DialogType.success,
              animType: AnimType.rightSlide,
              title: 'RESET PIN',
              desc:
                  'Permohonan Reset PIN telah kami terima, mohon menunggu beberapa saat untuk kami periksa berkas kamu. PIN akan kami kirim melalui SMS ke nomor terdaftar. Silahkan menghubungi SCS apabila kamu mengalami kendala',
              btnOkText: 'Ok',
              btnOkOnPress: () {
                Get.back();
              },
            )..show();
          } else {
            AwesomeDialog(
              context: Get.context,
              dialogType: DialogType.noHeader,
              animType: AnimType.rightSlide,
              title: 'RESET PIN',
              desc: 'Reset PIN gagal dilakukan. SIlahkan mengulang kembali',
              btnCancelText: 'Ok',
              btnCancelOnPress: () {},
            )..show();
          }
        }
      } catch (e) {
        EasyLoading.dismiss();

        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: 'RESET PIN',
          desc: 'Reset PIN gagal dilakukan. SIlahkan mengulang kembali',
          btnCancelText: 'Ok',
          btnCancelOnPress: () {},
        )..show();
      }
    }
  }
}
