import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:path_download/path_download.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'dart:math';

class SertifikatRitzuka extends StatefulWidget {
  @override
  _SertifikatRitzukaState createState() => _SertifikatRitzukaState();
}

class _SertifikatRitzukaState extends State<SertifikatRitzuka> {
  var qrdata = '345678998765456789876545678987gg65';
  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();
  final c = Get.find<ApiService>();
  var sertifikat = 'no sertifikat'.obs;
  var idsertifikat = ''.obs;
  var namaRitz = ''.obs;
  var pemilik = ''.obs;
  var pidanggota = ''.obs;
  var unit = ''.obs;
  var alamat = ''.obs;
  var terbit = ''.obs;
  var ketua = ''.obs;
  var qr = ''.obs;
  var tanggal = ''.obs;
  var kodeRitzuka = ''.obs;

  Directory _downloadsDirectory;
  @override
  void initState() {
    super.initState();
    initDownloadsDirectoryState();

    sertifikatLoad();
  }

  Future<void> initDownloadsDirectoryState() async {
    Directory downloadsDirectory;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      downloadsDirectory =
          (await PathDownload().pathDownload(TypeFileDirectory.pictures));
    } on PlatformException {
      print('Could not get the downloads directory');
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _downloadsDirectory = downloadsDirectory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
        body: (sertifikat.value == 'success')
            ? Screenshot(
                controller: screenshotController,
                child: Container(
                  width: Get.width * 1,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("images/bgsertifikat.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: ListView(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(top: Get.height * 0.03)),
                          Image.asset(
                            'images/whitelabelUtama/sasukakop.png',
                            width: Get.width * 0.33,
                          ),
                          AutoSizeText(
                            'KOPERASI SASUKA ONLINE INDONESIA',
                            style: TextStyle(fontSize: 15),
                            maxLines: 1,
                          ),
                          AutoSizeText(
                            'Jln. Kaliurang Km.10.5 Ngaglik-Sleman Yogyakarta',
                            style: TextStyle(fontSize: 12),
                            maxLines: 1,
                          ),
                          AutoSizeText(
                            'No.AHU : AHU-0006345.AH.01.26.TAHUN 2020',
                            style: TextStyle(fontSize: 12),
                            maxLines: 1,
                          ),
                          AutoSizeText(
                            'No.Induk Koperasi (NIK) : 3404100030081',
                            style: TextStyle(fontSize: 12),
                            maxLines: 1,
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: Get.height * 0.02)),
                          AutoSizeText(
                            'e-Sertifikat UMP',
                            style: TextStyle(fontSize: 33),
                            maxLines: 1,
                          ),
                          Text(
                            'Sertifikat ID',
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          AutoSizeText(
                            idsertifikat.value,
                            style: TextStyle(fontSize: 14),
                            maxLines: 1,
                          ),
                          AutoSizeText(
                            namaRitz.value,
                            style: TextStyle(fontSize: 13),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                          AutoSizeText(
                            kodeRitzuka.value,
                            style: TextStyle(fontSize: 13),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: Get.height * 0.05)),
                          Text(
                            'Sertifikat ini diberikan kepada :',
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          AutoSizeText(
                            pemilik.value,
                            style: TextStyle(fontSize: 25),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                          Text(
                            pidanggota.value,
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            unit.value,
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: Get.height * 0.05)),
                          Container(
                            padding: EdgeInsets.fromLTRB(22, 0, 22, 0),
                            child: AutoSizeText(
                              'e-Sertifikat ini adalah bukti kepemilikan modal penyertaan pada ${namaRitz.value} yang beralamat di ${alamat.value}',
                              style: TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                              maxLines: 4,
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: Get.height * 0.03)),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                  width: Get.width * 0.3,
                                  image: CachedNetworkImageProvider(
                                    'https://chart.googleapis.com/chart?cht=qr&chs=200x200&chl=${qr.value}',
                                  )),
                              Padding(
                                  padding:
                                      EdgeInsets.only(top: Get.width * 0.02)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoSizeText(
                                    'Diterbitkan pada : ${terbit.value}',
                                    style: TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                  ),
                                  AutoSizeText(
                                    'Koperasi Sasuka Online Indonesia',
                                    style: TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          top: Get.height * 0.02)),
                                  AutoSizeText(
                                    ketua.value,
                                    style: TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    'Ketua Koperasi',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(padding: EdgeInsets.only(top: Get.height * 0.05)),
                    Image.asset(
                      'images/whitelabelUtama/sasukakop.png',
                      width: Get.width * 0.33,
                    ),
                    Text(
                      'KOPERASI SASUKA ONLINE INDONESIA',
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      'Jln. Kaliurang km.10.5 Ngaglik-Sleman Yogyakarta',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    Padding(padding: EdgeInsets.only(top: Get.height * 0.05)),
                    Text(
                      'e-Sertifikat UMP',
                      style:
                          TextStyle(fontSize: 33, fontWeight: FontWeight.w100),
                    ),
                    Text(
                      'MENCARI SERTIFIKAT',
                      style: TextStyle(fontSize: 16),
                    ),
                    LinearProgressIndicator(),
                  ],
                ),
              ),
        bottomNavigationBar: (sertifikat.value == 'success')
            ? RawMaterialButton(
                onPressed: () {
                  takeSertifikat();
                },
                constraints: BoxConstraints(),
                elevation: 1.0,
                fillColor: Colors.black,
                child: Text(
                  'Download e-Sertifikat',
                  style: TextStyle(color: Warna.putih, fontSize: 14),
                ),
                padding: EdgeInsets.fromLTRB(22, 11, 22, 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(1)),
                ),
              )
            : RawMaterialButton(
                onPressed: () {},
                constraints: BoxConstraints(),
                elevation: 1.0,
                fillColor: Colors.black,
                child: Text(
                  'e-Sertifikat',
                  style: TextStyle(color: Warna.putih, fontSize: 14),
                ),
                padding: EdgeInsets.fromLTRB(22, 11, 22, 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(1)),
                ),
              )));
  }

  void takeSertifikat() async {
    await screenshotController
        .capture(delay: const Duration(milliseconds: 10))
        .then((Uint8List image) async {
      if (image != null) {
        Random random = new Random();
        int randomNumber = random.nextInt(100);
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
        final directory = _downloadsDirectory.absolute;
        String tempPath = directory.path;
        final imagePath =
            await File('$tempPath/${idsertifikat.value}$randomNumber.png')
                .create();
        await imagePath.writeAsBytes(image);

        /// Share Plugin
        await Share.shareFiles([imagePath.path]);
        Get.snackbar(
            'Download Berhasil', 'e-Sertifikat UMP telah berhasil di download',
            snackPosition: SnackPosition.BOTTOM,
            colorText: Colors.white,
            backgroundColor: Colors.black);
      }
    });
  }

  sertifikatLoad() async {
    bool conn = await cekInternet();
    if (conn) {
      Box dbbox = Hive.box<String>('sasukaDB');
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');
      var idRitz = c.idritzukapilihan.value;

      var datarequest = '{"pid":"$pid","idritz":"$idRitz"}';
      var bytes = utf8.encode(datarequest + '$token');
      var signature = md5.convert(bytes).toString();
      var user = dbbox.get('loginSebagai');

      var url = Uri.parse('${c.baseURL}/sasuka/sertifikatUMP');

      final response = await http.post(url, body: {
        "user": user,
        "appid": c.appid,
        "data_request": datarequest,
        "sign": signature
      });

      // EasyLoading.dismiss();
      print(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> hasil = jsonDecode(response.body);
        if (hasil['status'] == 'success') {
          sertifikat.value = hasil['status'];
          idsertifikat.value = hasil['idSertifikat'];
          namaRitz.value = hasil['namaRitzuka'];
          pemilik.value = hasil['pemilik'];
          pidanggota.value = hasil['pidanggota'];
          unit.value = hasil['unit'];
          alamat.value = hasil['alamat'];
          terbit.value = hasil['tglTerbit'];
          ketua.value = hasil['ketua'];
          qr.value = hasil['link'];
          kodeRitzuka.value = hasil['kodeRitzuka'];
        } else if (hasil['status'] == 'no sertifikat') {
          sertifikat.value = hasil['status'];
        }
      }
    }
  }
}
