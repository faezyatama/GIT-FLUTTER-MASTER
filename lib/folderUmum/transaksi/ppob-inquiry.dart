import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../base/notifikasiBuatAkun.dart';
import '/base/api_service.dart';
import '/base/warna.dart';

class PpobInquiry extends StatefulWidget {
  @override
  _PpobInquiryState createState() => _PpobInquiryState();
}

class _PpobInquiryState extends State<PpobInquiry> {
  final c = Get.find<ApiService>();
  final controllerHp = TextEditingController();
  final controllerPin = TextEditingController();

  var namacontactdipilih = ''.obs;
  var nocontact = ''.obs;
  var namapelanggan = '';
  var golongan = '';
  var indikator = false;
  var butonbayar = false;
  var kodeInquiry = '';

  String nama = '';
  String nomor = '';
  String detail1 = '';
  String detail2 = '';
  String detail3 = '';
  String detail4 = '';
  String detail5 = '';
  String tagihan = 'Rp.0,-';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(c.kategoriPPOB.value),
        backgroundColor: Warna.warnautama,
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.only(top: 11, bottom: 11),
            color: Colors.grey[200],
            child: Column(
              children: [
                Image.network(
                  c.logosubproduk.value,
                  width: Get.height * 0.12,
                ),
                SizedBox(
                  width: Get.width * 0.8,
                  child: Text(c.subProduk.value,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                          color: Warna.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
                Padding(padding: EdgeInsets.only(top: 22)),
                Text('Masukan Nomor Pelanggan :',
                    style: TextStyle(color: Warna.grey, fontSize: 16)),
                Container(
                  padding: EdgeInsets.only(left: 22, top: 10, right: 22),
                  child: Container(
                    width: Get.width * 0.8,
                    child: TextField(
                      onChanged: (text) {},
                      style: TextStyle(fontSize: 22),
                      keyboardType: TextInputType.phone,
                      controller: controllerHp,
                      decoration: InputDecoration(
                          labelText: namacontactdipilih.value,
                          labelStyle: TextStyle(fontSize: 15),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.phone_android),
                            onPressed: () async {
                              PhoneContact contact =
                                  await FlutterContactPicker.pickPhoneContact();

                              // ignore: unnecessary_null_comparison
                              if (contact != null) {
                                String clear =
                                    contact.phoneNumber.number.toString();
                                String clear2 = clear.replaceAll(' ', '');
                                String clear3 = clear2.replaceAll('-', '');

                                setState(() {
                                  controllerHp.text = clear3;
                                  nocontact.value = clear3;
                                  namacontactdipilih.value =
                                      contact.fullName.toString();
                                });
                              }
                            },
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(33))),
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 4)),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(color: Colors.blue)))),
                  onPressed: () {
                    setState(() {
                      if (controllerHp.text == '') {
                        AwesomeDialog(
                          context: Get.context,
                          dialogType: DialogType.noHeader,
                          animType: AnimType.rightSlide,
                          title: c.subProduk.value,
                          desc:
                              'Opps... sepertinya nomor pelanggan belum dimasukan dengan benar',
                          btnCancelText: 'OK SIAP',
                          btnCancelOnPress: () {},
                        )..show();
                      } else {
                        indikator = true;
                        kodeInquiry = '';
                        FocusScope.of(context).requestFocus(FocusNode());
                        cekInquiryPelanggan();
                      }
                    });
                  },
                  child: Container(
                    width: Get.width * 0.4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.send,
                          color: Colors.blue,
                        ),
                        Padding(padding: EdgeInsets.only(left: 10)),
                        Text(
                          'Cek Tagihan',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          (indikator == true)
              ? LinearProgressIndicator()
              : Padding(padding: EdgeInsets.only(bottom: 0)),
          Padding(padding: EdgeInsets.only(bottom: 11)),
          Container(
              child: Container(
            padding: EdgeInsets.only(left: 44, right: 44),
            child: Column(
              children: [
                Padding(padding: EdgeInsets.only(top: 11)),
                Row(
                  children: [
                    Text('Nama Pelanggan',
                        style: TextStyle(fontSize: 12, color: Warna.grey)),
                  ],
                ),
                Container(
                    width: Get.width * 0.9,
                    color: Colors.grey[100],
                    padding: EdgeInsets.all(5),
                    child: SizedBox(
                      child: Text(nama,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              color: Warna.grey,
                              fontWeight: FontWeight.w600)),
                    )),
                Row(
                  children: [
                    Text('Nomor',
                        style: TextStyle(fontSize: 12, color: Warna.grey)),
                  ],
                ),
                Container(
                  width: Get.width * 0.9,
                  color: Colors.grey[100],
                  padding: EdgeInsets.all(5),
                  child: SizedBox(
                      child: Text(nomor,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              color: Warna.grey,
                              fontWeight: FontWeight.w600))),
                ),
                Padding(padding: EdgeInsets.only(top: 12)),
                Row(
                  children: [
                    Text('Detail Pembayaran',
                        style: TextStyle(fontSize: 12, color: Warna.grey)),
                  ],
                ),
                Container(
                  width: Get.width * 0.9,
                  color: Colors.grey[100],
                  padding: EdgeInsets.all(2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: Get.width * 0.7,
                        child: Text(detail1,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 16,
                                color: Warna.grey,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: Get.width * 0.9,
                  color: Colors.grey[100],
                  padding: EdgeInsets.all(2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: Get.width * 0.7,
                        child: Text(detail2,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 16,
                                color: Warna.grey,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: Get.width * 0.9,
                  color: Colors.grey[100],
                  padding: EdgeInsets.all(2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: Get.width * 0.7,
                        child: Text(detail3,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 16,
                                color: Warna.grey,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: Get.width * 0.9,
                  color: Colors.grey[100],
                  padding: EdgeInsets.all(2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: Get.width * 0.7,
                        child: Text(detail4,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 16,
                                color: Warna.grey,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: Get.width * 0.9,
                  color: Colors.grey[100],
                  padding: EdgeInsets.all(2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: Get.width * 0.7,
                        child: Text(detail5,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 16,
                                color: Warna.grey,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 8)),
                Padding(padding: EdgeInsets.only(top: 33)),
                Row(
                  children: [
                    Text('Total Tagihan',
                        style: TextStyle(fontSize: 12, color: Warna.grey)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tagihan,
                        style: TextStyle(fontSize: 29, color: Warna.grey)),
                    (butonbayar == true)
                        ? ElevatedButton(
                            onPressed: () {
                              //TAMU OR MEMBER
                              if (c.loginAsPenggunaKita.value == 'Member') {
                                pinDanPembayaran();
                              } else {
                                var judulF =
                                    'Akun ${c.namaAplikasi} Dibutuhkan ?';
                                var subJudul =
                                    'Yuk Buka akun ${c.namaAplikasi} sekarang, hanya beberapa langkah akun kamu sudah aktif loh...';
                                bukaLoginPage(judulF, subJudul);
                              }
                              //END TAMU OR MEMBER
                            },
                            child: Container(child: Text('Bayar !')))
                        : Padding(padding: EdgeInsets.only(left: 12))
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void cekInquiryPelanggan() async {
//  EasyLoading.show(status: 'Cek Tagihan...');
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var kategoriPPOB = c.kategoriPPOB.value;
    var kodeproduk = c.kodeppob.value;
    var nopelanggan = controllerHp.text;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid", "kategori":"$kategoriPPOB","kodeproduk":"$kodeproduk","nopelanggan":"$nopelanggan"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/inquiry');
    print(datarequest);
    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });
    setState(() {
      indikator = false;
    });

    //  EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        if (mounted) {
          setState(() {
            butonbayar = true;
            var res = hasil['data'];
            kodeInquiry = res[5];
            nama = res[1];
            nomor = res[3];
            tagihan = res[2];
            detail1 = res[6];
            detail2 = res[7];
            detail3 = res[8];
            detail4 = res[9];
            detail5 = res[10];
          });
        }
      } else {
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: c.subProduk.value,
          desc: hasil['message'],
          btnCancelText: 'OK SIAP',
          btnCancelOnPress: () {},
        )..show();
      }
    }
  }

  void pinDanPembayaran() {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Image.network(c.logosubproduk.value),
          Text(
              'Apakah kamu benar akan melakukan pembayaran tagihan atas nomor tujuan dan nominal ini ?',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center),
          Padding(padding: EdgeInsets.only(top: 9)),
          Text(nama,
              style: TextStyle(
                  fontSize: 20, color: Warna.grey, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
          Text(
            nomor,
            style: TextStyle(fontSize: 14, color: Warna.grey),
          ),
          Text(
            detail1,
            style: TextStyle(fontSize: 14, color: Warna.grey),
          ),
          Text(
            tagihan,
            style: TextStyle(fontSize: 25, color: Warna.grey),
          ),
          Padding(padding: EdgeInsets.only(top: 18)),
          Text('PIN DIBUTUHKAN',
              style: TextStyle(
                  fontSize: 18,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w600)),
          Padding(padding: EdgeInsets.only(top: 7)),
          Padding(padding: EdgeInsets.only(top: 7)),
          Container(
            width: Get.width * 0.7,
            child: TextField(
              obscureText: true,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: TextStyle(
                  fontSize: 25, fontWeight: FontWeight.w600, color: Warna.grey),
              controller: controllerPin,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.vpn_key),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          RawMaterialButton(
            constraints: BoxConstraints(minWidth: Get.width * 0.7),
            elevation: 1.0,
            fillColor: Warna.warnautama,
            child: Text(
              'Proses Transaksi Ini',
              style: TextStyle(color: Warna.putih, fontSize: 14),
            ),
            padding: EdgeInsets.fromLTRB(18, 9, 18, 9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            onPressed: () {
              if ((controllerPin.text == '') ||
                  (controllerPin.text.length != 6)) {
                controllerPin.text = '';
                Get.back();
                AwesomeDialog(
                  context: Get.context,
                  dialogType: DialogType.noHeader,
                  animType: AnimType.rightSlide,
                  title: 'PERHATIAN !',
                  desc:
                      'Pin tidak dimasukan dengan benar, Pin hanya berisi 6 angka',
                  btnCancelText: 'OK',
                  btnCancelColor: Colors.amber,
                  btnCancelOnPress: () {},
                )..show();
              } else {
                prosesBayarTagihanSekarang();
              }
            },
          ),
        ],
      ),
    )..show();
  }

  void prosesBayarTagihanSekarang() async {
    EasyLoading.show(status: 'Mohon tunggu transaksi...', dismissOnTap: false);
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var pin = controllerPin.text;
    var kodeinq = kodeInquiry;
    var tujuan = controllerHp.text;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","kodeinquiry":"$kodeinq","tujuan":"$tujuan","pin":"$pin"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/bayarPPOB');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature
    });

    EasyLoading.dismiss();
    controllerPin.text = '';

    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        c.saldo.value = hasil['saldo'];
        c.pinBlokir.value = hasil['pinBlokir'];

        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'TRANSAKSI DIPROSES',
          desc:
              'Mohon tunggu beberapa saat, kami sedang memproses transaksi kamu',
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
          title: 'PERHATIAN !',
          desc: hasil['message'],
          btnCancelText: 'OK',
          btnCancelOnPress: () {
            Get.back();
          },
        )..show();
      }
    } else {
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'PERHATIAN !',
        desc: 'Connection error.. Please check your connection',
        btnCancelText: 'OK',
        btnCancelOnPress: () {
          Get.back();
        },
      )..show();
    }
  }
}
