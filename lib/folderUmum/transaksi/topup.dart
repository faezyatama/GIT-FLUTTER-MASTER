import 'dart:convert';
import 'dart:io';
// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:clipboard/clipboard.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:easy_mask/easy_mask.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';

class TopupSaldo extends StatefulWidget {
  @override
  _TopupSaldoState createState() => _TopupSaldoState();
}

class _TopupSaldoState extends State<TopupSaldo> {
  @override
  void initState() {
    super.initState();
    cekTopupBerjalan();
  }

  final c = Get.find<ApiService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Obx(() => Container(
            child: (c.requestTopup.value == 'tidak')
                ? RequestTidakAda()
                : RequestAda())));
  }

  void cekTopupBerjalan() async {
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/cekTopup');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        if (hasil['request'] == 'ada') {
          setState(() {
            c.requestTopup.value = hasil['request'];
          });
          var data = hasil['data'];

          c.jumlahTopup.value = data[0];
          c.tanggalTopup.value = data[1];
          c.logobankTopup.value = data[3];
          c.bankTopup.value = data[2];
          c.noRekTopup.value = data[4];
          c.atasNamaTopup.value = data[5];
          c.jumlahTopupCopy.value = data[6].toString();
          c.kodetrxTopup.value = data[7];
        } else {
          setState(() {
            c.requestTopup.value = hasil['request'];
            c.bankTersedia.value = hasil['bankTP'];
          });
        }
      }
    }
  }
}

class RequestAda extends StatelessWidget {
  final c = Get.find<ApiService>();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(Get.width * 0.22, 33, 11, 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Topup On Proses',
                    style: TextStyle(
                        color: Warna.grey,
                        fontSize: 22,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Silahkan melakukan transfer ke nomor rekening yang tertera dibawah ini. Pastikan kamu transfer sesuai dengan nominal yang tertera',
                    style: TextStyle(
                      color: Warna.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(11, 11, 11, 0),
              child: Row(
                children: [
                  Image.asset(
                    'images/topup.png',
                    width: Get.width * 0.15,
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(11, 11, 11, 0),
                    width: Get.width * 0.7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              c.jumlahTopup.value,
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Warna.grey,
                                  fontWeight: FontWeight.w600),
                            ),
                            Padding(padding: EdgeInsets.only(left: 12)),
                            GestureDetector(
                              onTap: () {
                                FlutterClipboard.copy(c.jumlahTopupCopy.value);
                                Get.snackbar("Copy to Clipboard",
                                    "Jumlah topup ${c.jumlahTopupCopy.value} berhasil di copy");
                              },
                              child: Icon(
                                Icons.copy_rounded,
                                size: 18,
                                color: Colors.blue,
                              ),
                            )
                          ],
                        ),
                        Text(
                          'Harap transfer sesuai nominal diatas untuk memudahkan verifikasi',
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(Get.width * 0.22, 0, 11, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: EdgeInsets.only(top: 11)),
                  Image.network(
                    c.logobankTopup.value,
                    width: 100,
                    height: 70,
                    fit: BoxFit.fitWidth,
                  ),
                  Text(
                    c.bankTopup.value,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Warna.grey),
                  ),
                  Row(
                    children: [
                      Text(
                        c.noRekTopup.value,
                        style: TextStyle(fontSize: 20, color: Warna.grey),
                      ),
                      Padding(padding: EdgeInsets.only(left: 10)),
                      GestureDetector(
                        onTap: () {
                          FlutterClipboard.copy(c.noRekTopup.value);
                          Get.snackbar("Copy to Clipboard",
                              "Nomor rekening ${c.noRekTopup.value}  berhasil dicopy");
                        },
                        child: Icon(
                          Icons.copy_rounded,
                          size: 18,
                          color: Colors.blue,
                        ),
                      )
                    ],
                  ),
                  Text(
                    c.atasNamaTopup.value,
                    style: TextStyle(fontSize: 16, color: Warna.grey),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        konfirmasiSudahTransfer(c.kodetrxTopup.value);
                      },
                      child: Text('Konfirmasi Sudah Transfer')),
                  ElevatedButton(
                      onPressed: () {
                        AwesomeDialog(
                            context: Get.context,
                            dialogType: DialogType.noHeader,
                            animType: AnimType.bottomSlide,
                            title: 'Batalkan Topup',
                            desc:
                                'Apakah benar kamu akan membatalkan topup ini ?',
                            btnOkOnPress: () {
                              batalkanTopup(c.kodetrxTopup.value);
                            },
                            btnOkText: 'Ya Batalkan',
                            btnCancelOnPress: () {},
                            btnCancelText: 'Tidak')
                          ..show();
                      },
                      child: Text('Batalkan'))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void konfirmasiSudahTransfer(String kodetrx) {
    AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.bottomSlide,
        title: 'Sudah transfer ?',
        desc:
            'Konfirmasi sudah transfer untuk mempercepat proses pengecekan. Apakah kamu ingin melampirkan bukti transfer ?',
        btnOkOnPress: () {
          konfirmasiDenganBukti(kodetrx);
        },
        btnOkText: 'Lampirkan bukti',
        btnCancelOnPress: () {
          konfirmasiTanpaBerkas(kodetrx);
        },
        btnCancelColor: Colors.blueAccent,
        btnCancelText: 'Konfirmasi saja')
      ..show();
  }
}

void konfirmasiDenganBukti(String kodetrx) {
  AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.bottomSlide,
      title: 'Lampirkan Bukti',
      desc:
          'Kamu bisa melampirkan bukti transfer dari Galery ataupun Camera, Pilih metode ambil gambar',
      btnOkOnPress: () {
        bukaCamera(kodetrx);
      },
      btnOkText: 'Camera',
      btnOkIcon: Icons.camera_alt_sharp,
      btnCancelOnPress: () {
        bukaGalery(kodetrx);
      },
      btnCancelColor: Colors.blueAccent,
      btnCancelIcon: Icons.file_copy,
      btnCancelText: 'Galery')
    ..show();
}

Future bukaCamera(String kodetrx) async {
  File _image;
  final picker = ImagePicker();
  final pickedFile =
      await picker.pickImage(source: ImageSource.camera, maxWidth: 800.0);
  if (pickedFile == null) {
    print('Foto tidak jadi diambil');
  } else {
    _image = File(pickedFile.path);
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.bottomSlide,
      title: 'Kirim Konfirmasi',
      desc: '',
      body: Column(
        children: [
          Text('Konfirmasi Topup',
              style: TextStyle(
                  fontSize: 20,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w600)),
          Padding(padding: EdgeInsets.only(top: 11)),
          Container(
            width: Get.width * 0.7,
            child: Text(
                'Kirim berkas ini untuk melakukan konfirmasi sebagi bukti sudah transfer'),
          ),
          Image.file(
            _image,
            width: Get.width * 0.7,
            height: Get.width * 0.9,
          ),
          Padding(padding: EdgeInsets.only(top: 8)),
          ElevatedButton(
              onPressed: () {
                uploadBukti(kodetrx, _image);
              },
              child: Text('Konfirmasi Topup'))
        ],
      ),
    )..show();
  }
}

void uploadBukti(String kodetrx, File image) async {
  var c = Get.find<ApiService>();
  File _image = image;
  EasyLoading.instance
    ..userInteractions = false
    ..dismissOnTap = false;
  EasyLoading.show(status: 'Kirim konfirmasi topup ...');
//UPLOAD DATA
  var stream = new http.ByteStream(DelegatingStream(_image.openRead()));
  var length = await _image.length();
  var uri = Uri.parse(c.baseURL + '/mobileApps/konfirmasiBuktiTopup');

  var request = new http.MultipartRequest('POST', uri);
  var multipartFile = new http.MultipartFile('file1', stream, length,
      filename: basename(_image.path));

  //BODY YANG DIKIRIM
  Box dbbox = Hive.box<String>('sasukaDB');
  var pid = dbbox.get('person_id');
  var token = dbbox.get('token');
  var user = dbbox.get('loginSebagai');

  var datarequest = '{"pid":"$pid","kodetrx":"$kodetrx"}';
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
    // print(responseString);

    c.requestTopup.value = 'tidak';
    AwesomeDialog(
      context: Get.context,
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: 'BERHASIL',
      desc:
          'Terimakasih telah melakukan konfirmasi. Mohon tunggu beberapa saat, top up kamu akan segera kami proses..',
      btnOkText: 'OK',
      btnOkOnPress: () {
        Get.back();
        Get.back();
      },
    )..show();
  } else {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: 'GAGAL',
      desc: 'Sepertinya proses konfirmasi gagal, Silahkan ulangi ya',
      btnCancelText: 'OK',
      btnCancelOnPress: () {},
    )..show();
  }
}

Future bukaGalery(String kodetrx) async {
  File _image;
  final picker = ImagePicker();
  final pickedFile =
      await picker.pickImage(source: ImageSource.gallery, maxWidth: 800.0);
  if (pickedFile == null) {
    print('Foto tidak jadi diambil');
  } else {
    _image = File(pickedFile.path);
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.bottomSlide,
      title: 'Kirim Konfirmasi',
      desc: '',
      body: Column(
        children: [
          Text('Konfirmasi Topup',
              style: TextStyle(
                  fontSize: 20,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w600)),
          Padding(padding: EdgeInsets.only(top: 11)),
          Container(
            width: Get.width * 0.7,
            child: Text(
                'Kirim berkas ini untuk melakukan konfirmasi sebagi bukti sudah transfer'),
          ),
          Image.file(
            _image,
            width: Get.width * 0.7,
            height: Get.width * 0.9,
          ),
          Padding(padding: EdgeInsets.only(top: 8)),
          ElevatedButton(
              onPressed: () {
                uploadBukti(kodetrx, _image);
              },
              child: Text('Konfirmasi Topup'))
        ],
      ),
    )..show();
  }
}

void konfirmasiTanpaBerkas(String kodetrx) async {
  final c = Get.find<ApiService>();

  //print(nominal);
  EasyLoading.instance
    ..userInteractions = false
    ..dismissOnTap = false;
  EasyLoading.show(status: 'Konfirmasi topup...');

  //BODY YANG DIKIRIM
  Box dbbox = Hive.box<String>('sasukaDB');
  var token = dbbox.get('token');
  var pid = dbbox.get('person_id');
  var user = dbbox.get('loginSebagai');

  var datarequest = '{"pid":"$pid","kodetrx":"$kodetrx"}';
  var bytes = utf8.encode(datarequest + '$token' + user);
  var signature = md5.convert(bytes).toString();

  var url = Uri.parse('${c.baseURL}/mobileApps/konfirmasiTopup');

  final response = await http.post(url, body: {
    "user": user,
    "appid": c.appid,
    "data_request": datarequest,
    "sign": signature
  });

  EasyLoading.dismiss();
  print(response.body);
  if (response.statusCode == 200) {
    Map<String, dynamic> hasil = jsonDecode(response.body);
    if (hasil['status'] == 'success') {
      c.requestTopup.value = 'tidak';
      AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.bottomSlide,
          title: 'KONFIRMASI',
          desc:
              'Konfirmasi atas topup yang kamu lakukan telah kami terima, mohon tunggu beberapa saat untuk topup kamu aktif',
          btnOkOnPress: () {
            Get.back();
            Get.back();
          },
          btnOkText: 'OK')
        ..show();
    } else {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Topup Gagal',
        desc: 'Opps maaf, data tidak ditemukan',
      )..show();
    }
  }
}

void batalkanTopup(String kodetrx) async {
  final c = Get.find<ApiService>();
//print(nominal);
  EasyLoading.instance
    ..userInteractions = false
    ..dismissOnTap = false;
  EasyLoading.show(status: 'Request topup...');

  //BODY YANG DIKIRIM
  Box dbbox = Hive.box<String>('sasukaDB');
  var token = dbbox.get('token');
  var pid = dbbox.get('person_id');
  var user = dbbox.get('loginSebagai');

  var datarequest = '{"pid":"$pid","kodetrx":"$kodetrx"}';
  var bytes = utf8.encode(datarequest + '$token' + user);
  var signature = md5.convert(bytes).toString();

  var url = Uri.parse('${c.baseURL}/mobileApps/batalTopup');

  final response = await http.post(url, body: {
    "user": user,
    "appid": c.appid,
    "data_request": datarequest,
    "sign": signature
  });

  EasyLoading.dismiss();
  print(response.body);
  if (response.statusCode == 200) {
    Map<String, dynamic> hasil = jsonDecode(response.body);
    if (hasil['status'] == 'success') {
      Get.back();
    } else {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Topup Gagal',
        desc: 'Opps maaf, data tidak ditemukan',
      )..show();
    }
  }
}

class RequestTidakAda extends StatefulWidget {
  @override
  _RequestTidakAdaState createState() => _RequestTidakAdaState();
}

class _RequestTidakAdaState extends State<RequestTidakAda> {
  final controller = TextEditingController();
  final c = Get.find<ApiService>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // IklanAtas(),
        Container(
          padding: EdgeInsets.only(top: Get.height * 0.02),
          child: Center(
            child: Container(
              width: Get.width * 0.75,
              child: ListView(children: [
                Row(
                  children: [
                    Image.asset(
                      'images/topup.png',
                      width: 77,
                    ),
                    Padding(padding: EdgeInsets.only(left: 7)),
                    Container(
                      width: Get.width * 0.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Topup Saldo',
                              style:
                                  TextStyle(fontSize: 22, color: Warna.grey)),
                          Text(
                              'Mudah bertransaksi di ${c.namaAplikasi} , Cukup topup saldo kamu dan mulailah bertransaksi dengan mudah'),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.only(top: 22)),
                RawMaterialButton(
                  constraints: BoxConstraints(minWidth: Get.width * 0.7),
                  elevation: 1.0,
                  fillColor: Warna.warnautama,
                  child: Text(
                    'Rp. 50.000,-',
                    style: TextStyle(color: Warna.putih, fontSize: 20),
                  ),
                  padding: EdgeInsets.fromLTRB(18, 9, 18, 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                  ),
                  onPressed: () {
                    pilihBankTersedia('50000');
                  },
                ),
                RawMaterialButton(
                  constraints: BoxConstraints(minWidth: Get.width * 0.7),
                  elevation: 1.0,
                  fillColor: Warna.warnautama,
                  child: Text(
                    'Rp. 100.000,-',
                    style: TextStyle(color: Warna.putih, fontSize: 20),
                  ),
                  padding: EdgeInsets.fromLTRB(18, 9, 18, 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                  ),
                  onPressed: () {
                    pilihBankTersedia('100000');
                  },
                ),
                RawMaterialButton(
                  constraints: BoxConstraints(minWidth: Get.width * 0.7),
                  elevation: 1.0,
                  fillColor: Warna.warnautama,
                  child: Text(
                    'Rp. 200.000,-',
                    style: TextStyle(color: Warna.putih, fontSize: 20),
                  ),
                  padding: EdgeInsets.fromLTRB(18, 9, 18, 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                  ),
                  onPressed: () {
                    pilihBankTersedia('200000');
                  },
                ),
                RawMaterialButton(
                  constraints: BoxConstraints(minWidth: Get.width * 0.7),
                  elevation: 1.0,
                  fillColor: Warna.warnautama,
                  child: Text(
                    'Rp. 500.000,-',
                    style: TextStyle(color: Warna.putih, fontSize: 20),
                  ),
                  padding: EdgeInsets.fromLTRB(18, 9, 18, 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                  ),
                  onPressed: () {
                    pilihBankTersedia('500000');
                  },
                ),
                RawMaterialButton(
                  constraints: BoxConstraints(minWidth: Get.width * 0.7),
                  elevation: 1.0,
                  fillColor: Warna.warnautama,
                  child: Text(
                    'Rp. 1.000.000,-',
                    style: TextStyle(color: Warna.putih, fontSize: 20),
                  ),
                  padding: EdgeInsets.fromLTRB(18, 9, 18, 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                  ),
                  onPressed: () {
                    pilihBankTersedia('1000000');
                  },
                ),
                Padding(padding: EdgeInsets.only(top: 22)),
                Text('Masukan nominal lain'),
                Padding(padding: EdgeInsets.only(top: 11)),
                Container(
                  width: Get.width * 0.7,
                  child: TextField(
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Warna.grey),
                    controller: controller,
                    inputFormatters: [
                      TextInputMask(
                          mask: ['999.999.999.999', '999.999.9999.999'],
                          reverse: true)
                    ],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        // prefixIcon: Icon(Icons.vpn_key),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
                RawMaterialButton(
                  constraints: BoxConstraints(minWidth: Get.width * 0.7),
                  elevation: 1.0,
                  fillColor: Warna.warnautama,
                  child: Text(
                    'Buat Top Up',
                    style: TextStyle(color: Warna.putih, fontSize: 16),
                  ),
                  padding: EdgeInsets.fromLTRB(18, 9, 18, 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                  ),
                  onPressed: () {
                    pilihBankTersedia(controller.text);
                  },
                ),
                Padding(padding: EdgeInsets.only(top: 22))
              ]),
            ),
          ),
        ),
      ],
    );
  }

  void pilihBankTersedia(String jumlah) {
    var nominal = jumlah.replaceAll('.', '');
    var nom = int.parse(nominal);
    if (nom >= 20000) {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        title: '',
        desc: '',
        body: Column(
          children: [
            Text('Pilih Bank',
                style: TextStyle(
                    fontSize: 26,
                    color: Warna.warnautama,
                    fontWeight: FontWeight.w300)),
            Text(
              'Pilih bank tujuan transfer untuk melakukan topup saldo',
              style: TextStyle(fontSize: 16, color: Warna.grey),
              textAlign: TextAlign.center,
            ),
            Padding(padding: EdgeInsets.only(top: 8)),
            daftarBank(jumlah),
          ],
        ),
      )..show();
    } else {
      print('Kurang dari 20000');
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        title: 'PERHATIAN !',
        desc: 'Minimal topup adalah Rp. 20.000,-',
        btnCancelText: 'OK',
        btnCancelColor: Colors.amber,
        btnCancelOnPress: () {},
      )..show();
    }
  }

  daftarBank(String jumlah) {
    var bank = c.bankTersedia.value.split(',');
    //print(bank);

    List<Container> listbank = [];

    for (var i = 0; i < bank.length; i++) {
      var valueBank = bank[i];
      print(valueBank);
      if (valueBank != '') {
        listbank.add(
          Container(
              child: GestureDetector(
            onTap: () {
              print(valueBank);
              Get.back();
              buatRequestTopup(jumlah, valueBank);
            },
            child: Card(
              elevation: 1.0,
              child: SizedBox(
                width: Get.width * 0.5,
                child: Image.network(
                  c.baseURL + '/img/bank/$valueBank.png',
                  height: 75,
                ),
              ),
            ),
          )),
        );
      }
    }
    if (listbank.length == 0) {
      listbank.add(
        Container(
          padding: EdgeInsets.all(8),
          child: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Column(
                children: [
                  Divider(),
                  Text(
                    'Saat ini layanan topup belum dapat dilakukan, silahkan mencoba beberapa saat kedepan',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              )),
        ),
      );
    }

    return Column(
      children: listbank,
    );
  }

  void buatRequestTopup(String jumlah, String bankTP) async {
    var nominal = jumlah.replaceAll('.', '');
    print(bankTP);

    //print(nominal);
    EasyLoading.instance
      ..userInteractions = false
      ..dismissOnTap = false;
    EasyLoading.show(status: 'Request topup...');

    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","nominal":"$nominal","bankTP":"$bankTP"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/buatTopup');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        setState(() {
          c.requestTopup.value = hasil['request'];
        });
        var data = hasil['data'];

        c.jumlahTopup.value = data[0];
        c.tanggalTopup.value = data[1];
        c.logobankTopup.value = data[3];
        c.bankTopup.value = data[2];
        c.noRekTopup.value = data[4];
        c.atasNamaTopup.value = data[5];
        c.jumlahTopupCopy.value = data[6].toString();
        c.kodetrxTopup.value = data[7];
      } else {
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Topup gagal dilakukan',
          desc:
              'Opss maaf... Topup gagal dilakukan. kamu bisa mengulanginya lagi',
        )..show();
      }
    }
  }
}
