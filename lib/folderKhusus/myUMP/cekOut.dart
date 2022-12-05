import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import 'pdfreader.dart';
import 'package:intl/intl.dart' as intl;

class CekOutRitzuka extends StatefulWidget {
  @override
  _CekOutRitzukaState createState() => _CekOutRitzukaState();
}

class _CekOutRitzukaState extends State<CekOutRitzuka> {
  final c = Get.find<ApiService>();
  var quantity = 1.obs;
  final controllerPin = TextEditingController();
  var isChecked = false.obs;
  final ctrJumlahUnit = TextEditingController();
  var rpSubJumlah = '0'.obs;

  @override
  void initState() {
    super.initState();
    tambah('Manual Input');
    kurang();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CekOut UMP'),
        backgroundColor: Colors.blue[700],
      ),
      body: ListView(
        children: [
          CachedNetworkImage(
              width: Get.width * 1,
              height: Get.width * 0.8,
              imageUrl: c.fotoCekOutRitzuka.value,
              errorWidget: (context, url, error) {
                print(error);
                return Icon(Icons.error);
              }),
          Container(
            color: Colors.grey[200],
            padding: EdgeInsets.fromLTRB(22, 11, 22, 11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      'Jumlah Pembelian UMP :',
                      style: TextStyle(color: Warna.grey, fontSize: 12),
                    ),
                    Obx(() => Text('Rp. ${rpSubJumlah.value}',
                        style: TextStyle(
                            color: Warna.grey,
                            fontSize: 20,
                            fontWeight: FontWeight.w600))),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        kurang();
                      },
                      child: Icon(
                        Icons.remove_circle_outline,
                        color: Warna.grey,
                        size: 33,
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(left: 12)),
                    Obx(() => Text(quantity.value.toString(),
                        style: TextStyle(
                            color: Warna.grey,
                            fontSize: 20,
                            fontWeight: FontWeight.w600))),
                    Padding(padding: EdgeInsets.only(left: 12)),
                    GestureDetector(
                      onTap: () {
                        tambah('Button');
                      },
                      child: Icon(
                        Icons.add_circle_outline,
                        color: Warna.grey,
                        size: 33,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 24)),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(22, 11, 22, 4),
                child: Text(
                  c.namaCekOutRitzuka.value, // nama ritzuka
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      color: Warna.grey,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                c.alamatCekOutRitzuka.value, // alamat
                style: TextStyle(fontSize: 12, color: Warna.grey),
              ),
              Text(
                c.hargaDevCekOutRitzuka.value, // nama ritzuka
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                    fontSize: 28,
                    color: Warna.grey,
                    fontWeight: FontWeight.w300),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RawMaterialButton(
                    onPressed: () {},
                    constraints: BoxConstraints(),
                    elevation: 1.0,
                    fillColor: Colors.blueGrey,
                    child: Text(
                      c.umpmasukCekOutRitzuka.value, //unit
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(left: 11)),
                  RawMaterialButton(
                    onPressed: () {},
                    constraints: BoxConstraints(),
                    elevation: 1.0,
                    fillColor: Colors.blueGrey,
                    child: Text(
                      c.satuanCekOutRitzuka.value,
                      style: TextStyle(color: Warna.putih, fontSize: 14),
                    ),
                    padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(left: 11)),
                  RawMaterialButton(
                    onPressed: () {},
                    constraints: BoxConstraints(),
                    elevation: 1.0,
                    fillColor: Colors.blueGrey,
                    child: Text(
                      c.persenCekOutRitzuka.value,
                      style: TextStyle(color: Warna.putih, fontSize: 14),
                    ),
                    padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                    ),
                  ),
                ],
              ),
              Text(
                'Status Saat ini :',
                style: TextStyle(color: Warna.grey, fontSize: 12),
              ),
              Text(c.tahapanCekOutRitzuka.value,
                  style: TextStyle(
                      color: Warna.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              Padding(padding: EdgeInsets.all(5)),
              Divider(),
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Perhatian :',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                        'Pembelian Unit Modal Penyertaan ${c.namaCekOutRitzuka.value} hanya di peruntukan kepada anggota Koperasi Konsumen Sasuka Online Indonesia aktif. ',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        )),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                        'Anggota yang belum memiliki pengetahuan dan pengalaman dalam mengikuti penyertaan modal disarankan untuk tidak menggunakan layanan ini.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        )),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                        'Resiko kerugian dari berjalannya unit usaha ${c.namaCekOutRitzuka.value} sepenuhnya menjadi tanggung jawab bersama (seluruh anggota & koperasi) sebatas unit modal penyertaan yang di setorkan.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        )),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                        'Anggota harus mempertimbangkan porsi bagi hasil yang akan diterimanya sesuai kemampuan modal penyertaan masing-masing anggota.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        )),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                        'Anggota harus membaca dan memahami informasi ini sebelum membuat keputusan.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        )),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                        'Pembelian Unit Modal Penyertaan tidak dapat di batalkan setelah transaksi pembelian unit, jika unit usaha telah beroperasi sampai batas waktu yang di sepakati bersama.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        )),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                        'Anggota harus melakukan analisa terhadap unit usaha yang ingin di miliki dan mempelajari setiap informasi yang disajikan di dalam aplikasi dengan cermat.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        )),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                        'Pengelolaan ${c.namaCekOutRitzuka.value} dilakukan secara otonom dengan pengelolaan full bisnis management yang langsung bertanggung jawab kepada Pengurus Koperasi.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        )),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                        'Pengalihan unit modal penyertaan dapat di lakukan setelah unit usaha ${c.namaCekOutRitzuka.value} beroperasi minimal 5 Tahun (60 Bulan) sehingga Anggota kemungkinan tidak bisa menjual kembali unit modal penyertaan dengan cepat.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        )),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                        'Pengalihan unit modal penyertaan hanya dapat dilakukan kepada anggota koperasi yang lain dengan harga terupdate.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        )),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                        'Anggota yang mengalihkan unit modal penyertaan kepada anggota lain sebelum jatuh tempo di kenakan penalty 20% dan kedua belah pihak menanggung seluruh biaya yang timbul atas pengalihan unit modal penyertaan yang terjadi.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        )),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                        'Dengan membeli Unit Modal Penyertaan ${c.namaCekOutRitzuka.value} berarti Anggota sudah menyetujui seluruh syarat dan ketentuan serta memahami semua risiko yang terjadi termasuk resiko kehilangan sebagian atau seluruh modal yang di sertakan.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(5, 0, 5, 3),
              child: RawMaterialButton(
                onPressed: () {
                  //cek apakah anggota koperasi atau bukan
                  if (c.cl.value != 0) {
                    if (c.saldoInt.value < c.totalBayarCekoutRitzuka.value) {
                      AwesomeDialog(
                        context: Get.context,
                        dialogType: DialogType.warning,
                        animType: AnimType.rightSlide,
                        title: 'PERHATIAN !',
                        desc:
                            'Sepertinya saldo kamu tidak cukup. Silahkan topup saldo terlebih dahulu',
                        btnCancelText: 'OK',
                        btnCancelColor: Colors.amber,
                        btnCancelOnPress: () {
                          Get.back();
                        },
                      )..show();
                    } else {
                      termOfService(quantity);
                    }
                  } else {
                    AwesomeDialog(
                      context: Get.context,
                      dialogType: DialogType.warning,
                      animType: AnimType.rightSlide,
                      title: 'PERHATIAN !',
                      desc:
                          'Untuk membeli Unit Modal Penyertaan (UMP), kamu harus terlebih dahulu menjadi Anggota Koperasi Aktif dengan membayar Simpanan Pokok dan Simpanan Wajib',
                      btnCancelText: 'OK',
                      btnCancelColor: Colors.amber,
                      btnCancelOnPress: () {
                        Get.back();
                      },
                    )..show();
                  }
                },
                constraints: BoxConstraints(),
                elevation: 1.0,
                fillColor: Colors.blue[700],
                child: Text(
                  'Beli UMP',
                  style: TextStyle(color: Warna.putih, fontSize: 18),
                ),
                padding: EdgeInsets.fromLTRB(122, 15, 122, 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(9)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void pinDibutuhkan(kuantity) {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Text(c.namaCekOutRitzuka.value,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
          Text(
              'Silahkan masukan PIN untuk membeli Unit Modal Penyertaan (UMP) sebanyak $kuantity Unit dengan jumlah Rp. ${rpSubJumlah.value} ',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center),
          Padding(padding: EdgeInsets.only(top: 9)),
          Text('',
              style: TextStyle(
                  fontSize: 20, color: Warna.grey, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
          Text(
            c.detailpulsa.value,
            style: TextStyle(fontSize: 14, color: Warna.grey),
          ),
          Divider(
            color: Warna.grey,
          ),
          Padding(padding: EdgeInsets.only(top: 8)),
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
                beliRitzukaSekarang(kuantity);
              }
            },
          ),
        ],
      ),
    )..show();
  }

  void termOfService(kuantity) {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Container(
        padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
        child: Column(
          children: [
            Text('Syarat & Ketentuan',
                style: TextStyle(
                    fontSize: 20,
                    color: Warna.grey,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            Text(
                '$kuantity Unit Modal Penyertaan (UMP)  dengan Total Rp. ${rpSubJumlah.value}',
                style: TextStyle(fontSize: 14, color: Warna.grey),
                textAlign: TextAlign.center),
            Divider(
              color: Warna.grey,
            ),
            Padding(padding: EdgeInsets.only(top: 16)),
            Text(
                'Sebelum melakukan pembelian UMP ini pastikan kamu telah membaca dan memahami syarat dan ketentuan yang berlaku. Kamu bisa membaca syarat dan ketentuan layanan dibawah ini. ',
                style: TextStyle(fontSize: 14, color: Warna.grey),
                textAlign: TextAlign.center),
            Padding(padding: EdgeInsets.only(top: 15)),
            GestureDetector(
              onTap: () {
                Get.back();
                Get.to(() => PdfReader());
              },
              child: Text(
                'Syarat & Ketentuan',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                    color: Colors.blueAccent),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 15)),
            Row(
              children: [
                Obx(() => Checkbox(
                      value: isChecked.value,
                      onChanged: (value) {
                        isChecked.value = value;
                      },
                    )),
                SizedBox(
                  width: Get.width * 0.5,
                  child: GestureDetector(
                    child: Text('Saya sudah membaca syarat dan ketentuan ini.',
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey),
                        textAlign: TextAlign.left),
                  ),
                ),
              ],
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
                if ((isChecked.value == false)) {
                  controllerPin.text = '';
                  Get.back();
                  AwesomeDialog(
                    context: Get.context,
                    dialogType: DialogType.noHeader,
                    animType: AnimType.rightSlide,
                    title: 'PERHATIAN !',
                    desc:
                        'Silahkan centang saya sudah membaca Syarat dan Ketentuan UMP',
                    btnCancelText: 'OK',
                    btnCancelColor: Colors.amber,
                    btnCancelOnPress: () {},
                  )..show();
                } else {
                  Get.back();
                  pinDibutuhkan(kuantity);
                }
              },
            ),
          ],
        ),
      ),
    )..show();
  }

  beliRitzukaSekarang(kuantity) async {
    bool conn = await cekInternet();
    if (conn) {
      Box dbbox = Hive.box<String>('sasukaDB');
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');
      var idRitz = c.idCekOutRitzuka.value;
      var pin = controllerPin.text;

      var datarequest =
          '{"pid":"$pid","idritz":"$idRitz","quantity":"$kuantity","pin":"$pin"}';
      var bytes = utf8.encode(datarequest + '$token');
      var signature = md5.convert(bytes).toString();
      var user = dbbox.get('loginSebagai');

      var url = Uri.parse('${c.baseURL}/sasuka/beliRitzukaSekarang');

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
          c.saldo.value = hasil['saldo'];

          if (mounted) {
            AwesomeDialog(
              context: Get.context,
              dialogType: DialogType.success,
              animType: AnimType.rightSlide,
              title: 'PEMBELIAN BERHASIL',
              desc:
                  'Terimakasih telah melakukan pembelian Unit Modal Penyertaan (UMP) Ritzuka',
              btnCancelText: 'OK',
              btnCancelColor: Colors.green,
              btnCancelOnPress: () {
                Get.back();
                Get.back();
                Get.back();
              },
            )..show();
          }
        } else if (hasil['status'] == 'failed') {
          AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.error,
            animType: AnimType.rightSlide,
            title: 'TRANSAKSI GAGAL',
            desc: hasil['message'],
            btnCancelText: 'OK',
            btnCancelColor: Colors.red,
            btnCancelOnPress: () {
              Get.back();
              Get.back();
            },
          )..show();
        }
      }
    }
  }

  void kurang() {
    if (quantity.value == 1) {
      Get.snackbar(
          'Minimum UMP', 'Opps... maaf, Minimum pembelian UMP adalah 1 Unit');
    } else {
      quantity.value = quantity.value - 1;
      ctrJumlahUnit.text = quantity.value.toString();
      c.totalBayarCekoutRitzuka.value =
          c.hargaIntCekOutRitzuka.value * quantity.value;
    }
    rpSubJumlah.value = intl.NumberFormat.decimalPattern()
        .format(c.totalBayarCekoutRitzuka.value);
  }

  void tambah(String inputan) {
    if (inputan == 'Manual Input') {
      if (quantity.value < c.maxCekOutRitzuka.value) {
        quantity.value = quantity.value + 1;
        c.totalBayarCekoutRitzuka.value =
            c.hargaIntCekOutRitzuka.value * quantity.value;
        ctrJumlahUnit.text = quantity.value.toString();
      } else {
        quantity.value = c.maxCekOutRitzuka.value;
        c.totalBayarCekoutRitzuka.value =
            c.hargaIntCekOutRitzuka.value * quantity.value;
        ctrJumlahUnit.text = quantity.value.toString();
        Get.snackbar('Maximum UMP',
            'Opps... maaf, inilah batas maximum UMP yang tersedia');
      }
    } else {
      if (quantity.value > 9) {
        manualInputJumlahUMP();
      } else {
        if (quantity.value < c.maxCekOutRitzuka.value) {
          quantity.value = quantity.value + 1;
          c.totalBayarCekoutRitzuka.value =
              c.hargaIntCekOutRitzuka.value * quantity.value;
          ctrJumlahUnit.text = quantity.value.toString();
        } else {
          quantity.value = c.maxCekOutRitzuka.value;
          c.totalBayarCekoutRitzuka.value =
              c.hargaIntCekOutRitzuka.value * quantity.value;
          ctrJumlahUnit.text = quantity.value.toString();
          Get.snackbar('Maximum UMP',
              'Opps... maaf, inilah batas maximum UMP yang tersedia');
        }
      }
    }
    rpSubJumlah.value = intl.NumberFormat.decimalPattern()
        .format(c.totalBayarCekoutRitzuka.value);
  }

  void manualInputJumlahUMP() {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Container(
        padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
        child: Column(
          children: [
            Text('Jumlah Unit',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            Text('Masukan jumlah Unit Modal Penyertaan (UMP) yang diinginkan',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center),
            Padding(padding: EdgeInsets.only(top: 16)),
            Container(
              width: Get.width * 0.7,
              child: TextField(
                textAlign: TextAlign.center,
                maxLength: 4,
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    color: Warna.grey),
                controller: ctrJumlahUnit,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2))),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 8)),
            RawMaterialButton(
              constraints: BoxConstraints(minWidth: Get.width * 0.7),
              elevation: 1.0,
              fillColor: Warna.warnautama,
              child: Text(
                'Atur Jumlah ini',
                style: TextStyle(color: Warna.putih, fontSize: 14),
              ),
              padding: EdgeInsets.fromLTRB(18, 9, 18, 9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(7)),
              ),
              onPressed: () {
                Get.back();
                quantity.value = int.parse(ctrJumlahUnit.text) - 1;
                tambah('Manual Input');
              },
            ),
          ],
        ),
      ),
    )..show();
  }
}
