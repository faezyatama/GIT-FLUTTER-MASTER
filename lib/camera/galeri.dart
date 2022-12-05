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
import '/base/warna.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import '/base/api_service.dart';

class Galeri extends StatefulWidget {
  @override
  _GaleriState createState() => new _GaleriState();
}

class _GaleriState extends State<Galeri> {
  final c = Get.put(ApiService());

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
        title: Text('FotoProfil'),
      ),
      body: Center(
        child: Container(
          color: Colors.transparent,
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
    final filenya = await picker.pickImage(source: ImageSource.gallery);
    if (filenya == null) {
      Get.back();
    } else {
      File _image = File(filenya.path);
      final sample = await ImageCrop.sampleImage(
        file: _image,
        preferredSize: 1200, //context.size.longestSide.ceil(),
      );

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
    // ignore: unnecessary_null_comparison
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

    // sample.delete();

    // _lastCropped.delete();
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

    request.fields['user'] = user;
    request.fields['data_request'] = datarequest;
    request.fields['sign'] = signature;
    request.fields['appid'] = c.appid;

    request.files.add(multipartFile);
    try {
      var response = await request.send();
      var responseString = await response.stream.bytesToString();
      EasyLoading.dismiss();
      print(responseString);
      Map<String, dynamic> hasil = jsonDecode(responseString);
      if (hasil['status'] == 'success') {
        print(responseString);

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

class GantiFotoKosong extends StatelessWidget {
  final c = Get.find<ApiService>();

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Padding(padding: EdgeInsets.only(top: 11)),
        Container(
          width: Get.width * 0.99,
          height: Get.width * 0.99,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            image: DecorationImage(
                image: NetworkImage(c.foto.value), fit: BoxFit.cover),
          ),
        ),
        Padding(padding: EdgeInsets.only(top: 33)),
        ElevatedButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Batal Update Foto'))
      ],
    ));
  }
}
