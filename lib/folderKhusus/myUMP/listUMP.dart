import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import 'beliUMP.dart';
import 'detailUMP.dart';

class MyRitzuka extends StatefulWidget {
  @override
  _MyRitzukaState createState() => _MyRitzukaState();
}

class _MyRitzukaState extends State<MyRitzuka> {
  final c = Get.find<ApiService>();
  @override
  void initState() {
    super.initState();
    cekmyritz();
  }

  var totalHargaUmp = 'Rp. 0';
  var totalUnit = '0';
  var totalPendapatanUmp = 'Rp. 0';

  var myGroup = AutoSizeGroup();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My UMP',
        ),
        backgroundColor: Colors.blue[700],
      ),
      body: Container(
        child: ListView(
          children: [
            Padding(padding: EdgeInsets.only(top: 22)),
            Container(
                padding: EdgeInsets.fromLTRB(12, 7, 12, 5),
                child: Text(
                  'Daftar Unit Modal Penyertaan(UMP) Milikmu :',
                  style: TextStyle(color: Warna.grey),
                )),
            (dataRitzuka == [])
                ? Center(
                    child: Column(
                      children: [
                        Image.asset('images/null.png', width: Get.width * 0.5),
                        Text(
                          'Unit Modal Penyertaan(UMP) Belum Ada',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Sepertinya kamu belum mempunyai Unit Modal Penyertaan (UMP), Tambah Unit Modal Penyertaan(UMP) dan dapatkan bagi hasil terbaik',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        )
                      ],
                    ),
                  )
                : buatdataRitzuka()
          ],
        ),
      ),
      bottomNavigationBar: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(12, 5, 12, 5),
              child: Card(
                child: Container(
                    padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Jumlah Total UMP (Rp.)',
                              style: TextStyle(fontSize: 12, color: Warna.grey),
                            ),
                            Padding(padding: EdgeInsets.only(left: 22)),
                            Text(
                              totalHargaUmp,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Warna.grey,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Pendapatan UMP (Rp.)',
                              style: TextStyle(fontSize: 12, color: Warna.grey),
                            ),
                            Padding(padding: EdgeInsets.only(left: 22)),
                            Text(
                              totalPendapatanUmp,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Warna.grey,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Unit UMP',
                              style: TextStyle(fontSize: 12, color: Warna.grey),
                            ),
                            Padding(padding: EdgeInsets.only(left: 22)),
                            Text(
                              totalUnit,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Warna.grey,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    )),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(5, 0, 5, 3),
              child: RawMaterialButton(
                onPressed: () {
                  Get.to(() => HomeRitzuka());
                },
                constraints: BoxConstraints(),
                elevation: 1.0,
                fillColor: Colors.blue[700],
                child: Text(
                  'Lihat Listing UMP',
                  style: TextStyle(color: Warna.putih, fontSize: 18),
                ),
                padding: EdgeInsets.fromLTRB(88, 15, 88, 15),
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

  List dataRitzuka = [];
  List<Container> ritzukaContainer = [];
  buatdataRitzuka() {
    for (var a = 0; a < dataRitzuka.length; a++) {
      var data = dataRitzuka[a];

      ritzukaContainer.add(Container(
        padding: EdgeInsets.fromLTRB(12, 5, 12, 5),
        child: Card(
          child: Container(
            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
            child: Row(
              children: [
                CachedNetworkImage(
                    width: Get.width * 0.3,
                    height: Get.width * 0.2,
                    imageUrl: data[4],
                    errorWidget: (context, url, error) {
                      print(error);
                      return Icon(Icons.error);
                    }),
                Padding(padding: EdgeInsets.only(left: 11)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: Get.width * 0.55,
                        child: AutoSizeText(
                          data[1], // nama ritzuka
                          style: TextStyle(fontSize: 18, color: Warna.grey),
                          maxLines: 2,
                        )),
                    Text(
                      data[3], // alamat
                      style: TextStyle(fontSize: 12, color: Warna.grey),
                    ),
                    Row(
                      children: [
                        RawMaterialButton(
                          onPressed: () {},
                          constraints: BoxConstraints(),
                          elevation: 1.0,
                          fillColor: Colors.amber,
                          child: AutoSizeText(data[2], //unit
                              group: myGroup,
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(9)),
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(left: 11)),
                        RawMaterialButton(
                          onPressed: () {
                            c.idritzukapilihan.value = data[0];
                            c.fotoritzpilihan.value = data[4];
                            c.namaritzPilihan.value = data[1];
                            c.alamatRitzPilihan.value = data[3];
                            c.unitRitzPilihan.value = data[2];
                            c.totalUmpRitzPilihan.value = data[5];
                            Get.to(() => DetailRitzuka());
                          },
                          constraints: BoxConstraints(),
                          elevation: 1.0,
                          fillColor: Colors.green,
                          child: AutoSizeText('Detail',
                              group: myGroup,
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(9)),
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ));
    }
    return Column(
      children: ritzukaContainer,
    );
  }

  cekmyritz() async {
    bool conn = await cekInternet();
    if (conn) {
      Box dbbox = Hive.box<String>('sasukaDB');
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');

      var datarequest = '{"pid":"$pid"}';
      var bytes = utf8.encode(datarequest + '$token');
      var signature = md5.convert(bytes).toString();
      var user = dbbox.get('loginSebagai');

      var url = Uri.parse('${c.baseURL}/sasuka/daftarRitzukaKu');

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
          if (mounted) {
            setState(() {
              totalHargaUmp = hasil['totalump'];
              totalPendapatanUmp = hasil['totalpendapatan'];
              totalUnit = hasil['totalunit'];
              dataRitzuka = hasil['data'];
            });
          }
        } else if (hasil['status'] == 'no data') {}
      }
    }
  }
}
