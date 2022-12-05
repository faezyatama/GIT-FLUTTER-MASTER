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

class CameraSimpanan extends StatefulWidget {
  @override
  _CameraSimpananState createState() => new _CameraSimpananState();
}

class _CameraSimpananState extends State<CameraSimpanan> {
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

  final c = Get.find<ApiService>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.warnautama,
        title: Text('Lampiran Pembukaan Rekening'),
      ),
      body: Center(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
          child: Center(
            child:
                // ignore: unnecessary_null_comparison
                (_sample == null) ? Container() : _buildCroppingImage(),
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
            // aspectRatio: 3.0 / 3.0,
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 20.0),
          alignment: AlignmentDirectional.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              ElevatedButton(
                child: Text('Kirim Gambar ini'),
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
      Get.back();
    } else {
      File _image = File(filenya.path);
      final sample = await ImageCrop.sampleImage(
        file: _image,
        preferredSize: 1000, //context.size.longestSide.ceil(),
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
    EasyLoading.show(status: 'Sedang mengirim gambar ...');

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
      preferredSize: (500 / scale).round(),
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
    var link = '';
    if (c.uploadTo.value == 'profil') {
      link = '${c.baseURL}/mobileApps/uploadPasFoto';
    } else if (c.uploadTo.value == 'ktp') {
      link = '${c.baseURL}/mobileApps/uploadKTP';
    } else {
      link = '${c.baseURL}/mobileApps/uploadSelfiKTP';
    }
    var uri = Uri.parse(link);

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
    request.fields['package'] = c.packageName;

    request.files.add(multipartFile);

    var response = await request.send();
    var responseString = await response.stream.bytesToString();

    Map<String, dynamic> hasil = jsonDecode(responseString);
    EasyLoading.dismiss();
    if (hasil['status'] == 'success') {
      if (c.uploadTo.value == 'profil') {
        c.filePasFoto.value = hasil['fileName'];
        c.filePasFotoDisplay.value = hasil['uploadDone'];
      } else if (c.uploadTo.value == 'ktp') {
        c.fileKTP.value = hasil['fileName'];
        c.fileKTPDisplay.value = hasil['uploadDone'];
      } else if (c.uploadTo.value == 'selfi') {
        c.fileSelfiKTP.value = hasil['fileName'];
        c.fileSelfiKTPDisplay.value = hasil['uploadDone'];
      }
      Navigator.pop(this.context);
    } else {
      Get.snackbar('Upload Gagal',
          'Opps sepertinya proses pengiriman gambar gagal dilakukan');
      Navigator.pop(this.context);
    }
  }
}
