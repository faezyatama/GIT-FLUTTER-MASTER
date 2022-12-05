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

class GaleriProduk extends StatefulWidget {
  @override
  _GaleriProdukState createState() => new _GaleriProdukState();
}

class _GaleriProdukState extends State<GaleriProduk> {
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
        title: Text('Tambah Foto Produk'),
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
                child: Text('Pilih Gambar ini'),
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
      //print('ga jadi pick');
    } else {
      File _image = File(filenya.path);
      final sample = await ImageCrop.sampleImage(
        file: _image,
        preferredSize: 1000, //context.size.longestSide.ceil(),
      );
      setState(() {
        _sample = sample;
        _file = _image;
      });
    }
  } // tutup asinc

  Future<void> cropAndUpdate() async {
    EasyLoading.instance
      ..userInteractions = false
      ..dismissOnTap = true;
    EasyLoading.show(status: 'Sedang menambahkan gambar...');

    //final scale = cropKey.currentState.scale;
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
      preferredSize: 1000, //context.size.longestSide.ceil(),
    );

    final file = await ImageCrop.cropImage(
      file: sample,
      area: area,
    );

    _lastCropped = file;
    File _image = _lastCropped;

    //UPLOAD DATA
    var stream = new http.ByteStream(DelegatingStream(_image.openRead()));
    var length = await _image.length();
    var uri = Uri.parse('https://images.sasuka.online/uploadProduk.php');

    var request = new http.MultipartRequest('POST', uri);
    var multipartFile = new http.MultipartFile('image', stream, length,
        filename: basename(_image.path));

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var pid = dbbox.get('person_id');
    var datarequest = '{"pid":"$pid"}';
    var token = dbbox.get('token');

    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();

    request.fields['user'] = dbbox.get('loginSebagai');
    request.fields['data_request'] = datarequest;
    request.fields['sign'] = signature;

    request.files.add(multipartFile);

    var response = await request.send();
    var responseString = await response.stream.bytesToString();
    EasyLoading.dismiss();

    print(responseString);
    Map<String, dynamic> hasil = jsonDecode(responseString);
    if (hasil['status'] == 'success') {
      if (c.uploadTo.value == 'pic1') {
        c.picProduk1.value = hasil['filename'];
      } else if (c.uploadTo.value == 'pic2') {
        c.picProduk2.value = hasil['filename'];
      } else if (c.uploadTo.value == 'pic3') {
        c.picProduk3.value = hasil['filename'];
      } else if (c.uploadTo.value == 'pic4') {
        c.picProduk4.value = hasil['filename'];
      } else if (c.uploadTo.value == 'pic5') {
        c.picProduk5.value = hasil['filename'];
      } else if (c.uploadTo.value == 'pic6') {
        c.picProduk6.value = hasil['filename'];
      }

      Navigator.pop(this.context);
    } else {
      Navigator.pop(this.context);
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
            image: DecorationImage(image: NetworkImage(''), fit: BoxFit.cover),
          ),
        ),
        Padding(padding: EdgeInsets.only(top: 33)),
        ElevatedButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Batal Pilih Foto'))
      ],
    ));
  }
}
