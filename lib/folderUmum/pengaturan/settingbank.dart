import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../base/notifikasiBuatAkun.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable

class SettingBank extends StatefulWidget {
  @override
  _SettingBankState createState() => _SettingBankState();
}

class _SettingBankState extends State<SettingBank> {
  @override
  void initState() {
    super.initState();
    cNorek.text = c.norek.value;
  }

  List<String> namaBank = [
    'ANZ-Panin',
    'Bank Aceh',
    'Bank Agroniaga',
    'Bank Andara',
    'Bank Artos Indonesia',
    'Bank Bengkulu',
    'Bank BJB',
    'Bank BJB Syariah',
    'Bank BRI Syariah',
    'Bank Bali',
    'Bank Central Asia (BCA)',
    'Bank DIY',
    'Bank Kalsel',
    'Bank Kalteng',
    'Bank Kaltim',
    'Bank Bukopin',
    'Bank Capital',
    'Bank CIMB Niaga',
    'Bank Commonwealth',
    'Bank Danamon',
    'Bank DBS',
    'Bank DKI',
    'Bank Ekonomi',
    'Bank Ganesha',
    'Bank ICB Bumiputera',
    'Bank ICBC',
    'Bank Ina Perdana',
    'Bank Index',
    'Bank Internasional Indonesia',
    'Bank Jambi',
    'Bank Jateng',
    'Bank Jatim',
    'Bank Kalbar',
    'Bank Kesejahteraan',
    'Bank Lampung',
    'Bank Maluku',
    'Bank Mandiri',
    'Bank Mayapada Internasional',
    'Bank Mayora',
    'Bank Mega',
    'Bank Mestika',
    'Bank Muamalat',
    'Bank Mutiara',
    'Bank Nagari',
    'Bank Negara Indonesia (BNI)',
    'Bank Nobu',
    'Bank NTB',
    'Bank NTT',
    'Bank Nusantara Parahyangan',
    'Bank OCBC NISP',
    'Bank of China',
    'Bank of India Indonesia',
    'Bank Panin',
    'Bank Papua',
    'Bank Permata',
    'Bank Pundi',
    'Bank QNB Kesawan',
    'Bank Rabobank Indonesia',
    'Bank Rakyat Indonesia',
    'Bank Riau Kepri',
    'Bank Saudara',
    'Bank Sinarmas',
    'Bank Sulselbar',
    'Bank Sulteng',
    'Bank Sultra',
    'Bank Sulut',
    'Bank Sumsel Babel',
    'Bank Sumut',
    'Bank Syariah Indonesia',
    'Bank Syariah Mega Indonesia',
    'Bank Tabungan Negara',
    'Bank Tabungan Pensiunan Nasional',
    'Bank UOB Indonesia',
    'BPR Eka Bumi Artha',
    'BPR Karyajatnika Sadaya',
    'BPR Semoga Jaya',
    'Citibank',
    'HSBC',
    'Standard Chartered Bank'
  ];

  var selectedItem = "Bank Mandiri";

  final cNorek = TextEditingController();

  final cNpwp = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(22),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pengaturan Bank',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54)),
                Image.asset(
                  'images/Bank.png',
                  width: Get.width * 0.15,
                )
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 5)),
            Text(
                'Kamu bisa melakukan penarikan dana ke akun Bank yang kamu daftarkan.'),
            Padding(padding: EdgeInsets.only(top: 10)),
            Text(
                'Untuk alasan keamanan, Nama di rekening kamu harus sama dengan nama pada akun ' +
                    c.namaAplikasi),
            Padding(padding: EdgeInsets.only(top: 11)),
            Row(
              children: [
                Image.network(
                  c.baseURL + '/img/bank/${c.bank.value}.png',
                  width: Get.width * 0.22,
                ),
                Padding(padding: EdgeInsets.only(left: 12)),
                Container(
                  width: Get.width * 0.62,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Data Bank Saat ini :',
                          style: TextStyle(color: Warna.grey, fontSize: 11)),
                      Obx(
                        () => Text(c.bank.value,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                color: Warna.warnautama,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Obx(() => Text('Rek : ${c.norek.value}',
                          style: TextStyle(
                              color: Warna.warnautama, fontSize: 16))),
                      Obx(() => Text('NPWP : ${c.npwp.value}',
                          style: TextStyle(
                              color: Warna.warnautama, fontSize: 14))),
                    ],
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 22)),
            Container(
              // margin: EdgeInsets.fromLTRB(25, 25, 25, 0),
              child: TextField(
                controller: cNorek,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Nomor Rekening',
                    //prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 11)),
            DropdownSearch<String>(
                popupProps: PopupProps.menu(
                  showSelectedItems: true,
                  disabledItemFn: (String s) => s.startsWith('I'),
                ),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Nama Bank",
                  ),
                ),
                items: namaBank,
                onChanged: (v) {
                  selectedItem = v;
                  print(selectedItem);
                },
                selectedItem: c.bank.value),
            Padding(padding: EdgeInsets.only(top: 11)),
            Container(
              // margin: EdgeInsets.fromLTRB(25, 25, 25, 0),
              child: TextField(
                controller: cNpwp,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'NPWP (Optional)',
                    //prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 22)),
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
                  updateDataBank(cNorek.text, selectedItem, cNpwp.text);
                } else {
                  var judulF = 'Pengaturan Data Bank';
                  var subJudul =
                      'Kamu bisa mengatur data bank untuk penarikan dana dari akun ${c.namaAplikasi}, Yuk Buka akun ${c.namaAplikasi} sekarang';

                  bukaLoginPage(judulF, subJudul);
                }
              },
              child: Text(
                'Update Data Bank',
                style: TextStyle(color: Warna.putih),
              ),
            ),
          ],
        ));
    //
  }
}

final c = Get.find<ApiService>();
void updateDataBank(norek, bank, npwp) async {
  if (norek == '') {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: 'Update Data Bank',
      desc: 'Opps... sepertinya Nomor Rekening belum dimasukan dengan benar',
      btnCancelText: 'OK SIAP',
      btnCancelOnPress: () {},
    )..show();
  } else {
    //PROSES UPDATE BANK
    EasyLoading.instance
      ..userInteractions = false
      ..dismissOnTap = false;
    EasyLoading.show(status: 'Update data bank ...');
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","norek":"$norek","bank":"$bank","npwp":"$npwp"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/updateBank');

    try {
      final response = await http.post(url, body: {
        "user": user,
        "appid": c.appid,
        "data_request": datarequest,
        "sign": signature
      });

      if (response.statusCode == 200) {
        EasyLoading.dismiss();

        Map<String, dynamic> resultnya = jsonDecode(response.body);
        if (resultnya['status'] == 'success') {
          // Box dbbox = Hive.box<String>('sasukaDB');

          // dbbox.put('bank', resultnya['bank']);
          // dbbox.put('norek', resultnya['norek']);

          c.bank.value = bank;
          c.norek.value = norek;
          c.npwp.value = npwp;

          print(response.body);
          AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.success,
            animType: AnimType.rightSlide,
            title: 'Update data Bank',
            desc: 'Data ' + bank + ' berhasil di update dengan nomor ' + norek,
            btnOkText: 'Ok',
            btnOkOnPress: () {
              Get.back();
            },
          )..show();
        } else {
          AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.error,
            animType: AnimType.rightSlide,
            title: 'Update data Bank',
            desc: 'data bank GAGAL diupdate Silahkan ulangi proses',
            btnCancelText: 'Ok',
            btnCancelOnPress: () {},
          )..show();

          print(response.body);
        }
      } else {
        print(response.body);
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'Update data Bank',
          desc: 'data bank GAGAL diupdate Silahkan ulangi proses',
          btnCancelText: 'Ok',
          btnCancelOnPress: () {},
        )..show();
      }
    } catch (e) {
      Get.snackbar('Error Terjadi',
          'Opps Sepertinya error terjadi, silahkan ulangi proses');
    }
  }
}
