// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class LupaPassword extends StatefulWidget {
  @override
  _LupaPasswordState createState() => _LupaPasswordState();
}

class _LupaPasswordState extends State<LupaPassword> {
  File _image;
  final picker = ImagePicker();
  final myController = TextEditingController();
  String gambar = '';
  var filenameKtp = '';
  final c = Get.find<ApiService>();

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

  //GET IMAGE DARI KAMERA
  Future getImageCamera() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera, maxWidth: 500.0);
    if (pickedFile == null) {
      //  print('ga jadi pick');
    } else {
      setState(() {
        gambar = 'Gambar sudah dipilih';
        filenameKtp = 'Foto Sudah Dipilih';
        _image = File(pickedFile.path);
      });
      // getImageAndUpload();
    }
  }

  Future getImageAndUpload() async {
    // EasyLoading.instance
    //   ..userInteractions = false
    //   ..dismissOnTap = false;
    EasyLoading.show(status: 'Mengirimkan Permintaan Password...');

    var stream = new http.ByteStream(DelegatingStream(_image.openRead()));
    var length = await _image.length();
    var uri = Uri.parse(c.baseURL + '/mobileApps/lupaPassword');

    var request = new http.MultipartRequest('POST', uri);
    var multipartFile = new http.MultipartFile('file1', stream, length,
        filename: basename(_image.path));

    var hp = myController.text;
    //BODY YANG DIKIRIM
    var user = 'Non Registered User';
    var datarequest = '{"hp":"$hp"}';
    var bytes = utf8.encode(datarequest + 'cbf4aq3' + user + c.appid);
    var signature = md5.convert(bytes).toString();

    request.fields['user'] = 'Non Registered User';
    request.fields['data_request'] = datarequest;
    request.fields['sign'] = signature;
    request.fields['appid'] = c.appid;

    request.files.add(multipartFile);

    var response = await request.send();
    var responseString = await response.stream.bytesToString();
    print(responseString);

    EasyLoading.dismiss();

    Map<String, dynamic> hasil = jsonDecode(responseString);
    if (hasil['status'] == 'success') {
      c.requestPassword.value = hasil['fileName'];
      AwesomeDialog(
        context: Get.context,
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        title: 'Permintaan Terkirim',
        desc:
            'Permintaan reset password akan segera kami tinjau dan segera dikirimkan melalui SMS/Whatsapp ke nomor kamu.',
        btnOkText: 'OK',
        btnOkOnPress: () {
          Navigator.pop(Get.context);
        },
      )..show();
    } else if (hasil['status'] == 'nomor tidak ditemukan') {
      Get.snackbar('Nomor HP Tidak Terdaftar',
          'Opps... sepertinya nomor hp yang dimasukan tidak terdaftar');
    } else {
      print(responseString);
    }
  }

//
  // //UPLOAD DATA
  // kirimDataSekarang(filename, hpuser) async {
  //   EasyLoading.instance
  //     ..userInteractions = false
  //     ..dismissOnTap = false;
  //   EasyLoading.show(status: 'Wait ...');
  //   Box dbbox = Hive.box<String>('sasukaDB');

  //   String appid = dbbox.get('appid');

  //   var user = 'Non Registered User';
  //   var datarequest =
  //       '{"hp":"$hpuser","filename":"$filename","appid":"$appid"}';
  //   var bytes = utf8.encode(datarequest + 'cbf4aq3' + user + c.appid);
  //   var signature = md5.convert(bytes).toString();

  //   var url = Uri.parse('${c.baseURL}/sasuka/lupapassword');

  //   final response = await http.post(url, body: {
  //     "user": user,
  //     "appid": c.appid,
  //     "data_request": datarequest,
  //     "sign": signature
  //   });
  //   print(response.body);

  //   EasyLoading.dismiss();
  //   Map<String, dynamic> cekLogin = jsonDecode(response.body);
  //   if (cekLogin['status'] == 'success') {
  //     AwesomeDialog(
  //       context: Get.context,
  //       dialogType: DialogType.success,
  //       animType: AnimType.scale,
  //       title: 'Permintaan Terkirim',
  //       desc:
  //           'Permintaan reset password akan segera kami tinjau dan segera dikirimkan melalui SMS ke nomor kamu.',
  //       btnOkText: 'OK',
  //       btnOkOnPress: () {
  //         Navigator.pop(Get.context);
  //       },
  //     )..show();
  //   } else {
  //     AwesomeDialog(
  //       context: Get.context,
  //       dialogType: DialogType.noHeader,
  //       animType: AnimType.rightSlide,
  //       title: 'Gagal Upload',
  //       desc:
  //           'Opps maaf sepertinya upload ktp kamu gagal dilakukan. ulangi beberapa saat lagi atau silahkan menghubungi SCS dengan kode kesalahan Err-443',
  //       btnOkOnPress: () {
  //         Get.back();
  //       },
  //     )..show();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.warnautama,
        title: Text('Password Recovery'),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(11),
        child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Warna.warnautama),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(color: Warna.warnautama)))),
          onPressed: () {
            if (myController.text == '') {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.noHeader,
                animType: AnimType.rightSlide,
                title: 'Lupa Password ?',
                desc:
                    'Opps... sepertinya nomor HP belum dimasukan dengan benar',
                btnOkOnPress: () {
                  myFocusNode.requestFocus();
                },
              )..show();
            } else if (filenameKtp == '') {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.noHeader,
                animType: AnimType.rightSlide,
                title: 'Foto Identitas ?',
                desc:
                    'Opps... sepertinya identitas belum dipilih. Kamu bisa mengambil gambar KTP/SIM',
                btnOkIcon: Icons.camera_alt,
                btnOkText: 'Buka Kamera',
                btnOkOnPress: () {
                  getImageCamera();
                },
              )..show();
            } else {
              getImageAndUpload();
              //kirimDataSekarang(filenameKtp, myController.text);
            }
          },
          child: Text('Kirim permintaan password baru'),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: ListView(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, 22, 0, 22),
              child: Text(
                  'Kamu tidak dapat mengakses akun kamu ?? tenang jangan khawatir ikuti langkah berikut untuk kembalikan password kamu.'),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
              child: TextField(
                focusNode: myFocusNode,
                controller: myController,
                keyboardType: TextInputType.phone,
                maxLength: 15,
                onChanged: (value) {},
                decoration: InputDecoration(
                    labelText: 'Masukan nomor HP',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            Padding(padding: EdgeInsets.all(11)),
            Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.amber,
                  size: 44,
                ),
                SizedBox(
                    width: Get.width * 0.75,
                    child: Text(
                        'Perhatian!!... Agar kami dapat melakukan verifikasi terhadap akun anda, mohon sertakan kartu identitas seperti KTP/SIM/IDENTITAS LAIN')),
              ],
            ),
            Padding(padding: EdgeInsets.all(11)),
            Column(
              children: [
                GestureDetector(
                    onTap: () {
                      getImageCamera();
                    },
                    // ignore: unnecessary_null_comparison
                    child: (_image == null)
                        ? Image.asset('images/ktp.png')
                        : SizedBox(
                            width: 300,
                            height: 200,
                            child: Image.file(
                              _image,
                              fit: BoxFit.fitWidth,
                            ))),
                Center(
                  child: RawMaterialButton(
                    onPressed: () {
                      getImageCamera();
                    },
                    constraints: BoxConstraints(),
                    elevation: 1.0,
                    fillColor: Colors.blue,
                    child: Text('Klik untuk membuka kamera !',
                        style: TextStyle(
                            color: Warna.putih,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                    padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                    ),
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.fromLTRB(0, 22, 0, 0)),
          ],
        ),
      ),
    );
  }
}
