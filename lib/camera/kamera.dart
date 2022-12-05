import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import '/camera/galeri.dart';

class Camera extends StatefulWidget {
  @override
  _CameraState createState() => new _CameraState();
}

class _CameraState extends State<Camera> {
  final c = Get.find<ApiService>();
  final cropKey = GlobalKey<CropState>();
  File _file;
  File _sample;
  File _lastCropped;
  void initState() {
    super.initState();
    getImageCamera();
  }

  @override
  void dispose() {
    super.dispose();
    _file.delete();
    _sample.delete();
    _lastCropped.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.warnautama,
        title: Text('Foto Profil'),
      ),
      body: Center(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
          child: Center(
            child:
                // ignore: unnecessary_null_comparison
                (_sample == null) ? GantiFotoKosong() : _buildCroppingImage(),
          ),
        ),
      ),
    );
  }

  Widget _buildCroppingImage() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Crop.file(
            _sample,
            key: cropKey,
            aspectRatio: 3.0 / 3.0,
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 20.0),
          alignment: AlignmentDirectional.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              ElevatedButton(
                child: Text('Update Foto Profile'),
                onPressed: () => cropAndUpdate(),
              ),
            ],
          ),
        )
      ],
    );
  }

  final picker = ImagePicker();

  Future getImageCamera() async {
    final filenya = await picker.pickImage(source: ImageSource.camera);
    if (filenya == null) {
      //  print('ga jadi pick');
      Get.back();
    } else {
      File _image = File(filenya.path);
      final sample = await ImageCrop.sampleImage(
        file: _image,
        preferredSize: 1200, //context.size.longestSide.ceil(),
      );
      print(filenya);
      // _sample.delete();
      // _file.delete();

      setState(() {
        _sample = sample;
        _file = _image;
      });
    }
  } // tutup asinc

  Future<void> cropAndUpdate() async {
    EasyLoading.instance
      ..userInteractions = false
      ..dismissOnTap = false;
    EasyLoading.show(status: 'Mengganti Foto Profile ...');

    final scale = cropKey.currentState.scale;
    final area = cropKey.currentState.area;
    if (area == null) {
      // cannot crop, widget is not setup
      return;
    }

    // scale up to use maximum possible number of pixels
    // this will sample image in higher resolution to make cropped image larger
    final sample = await ImageCrop.sampleImage(
      file: _file,
      preferredSize: (700 / scale).round(),
    );

    final file = await ImageCrop.cropImage(
      file: sample,
      area: area,
    );

    //sample.delete();

    //_lastCropped.delete();
    _lastCropped = file;

    debugPrint('$file');
    File _image = _lastCropped;

    //UPLOAD DATA
    var stream = new http.ByteStream(DelegatingStream(_image.openRead()));
    var length = await _image.length();
    var uri = Uri.parse(c.baseURL + '/mobileApps/gantiFotoProfil');

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
    try {
      var response = await request.send();
      var responseString = await response.stream.bytesToString();
      EasyLoading.dismiss();

      Map<String, dynamic> hasil = jsonDecode(responseString);
      if (hasil['status'] == 'success') {
        dbbox.put('foto', hasil['foto']);
        c.foto.value = hasil['foto'];
        Navigator.pop(this.context);
      } else {
        Navigator.pop(this.context);
      }
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar('Error Terjadi',
          'Opps Sepertinya error terjadi, silahkan ulangi proses');
    }
  }
}
