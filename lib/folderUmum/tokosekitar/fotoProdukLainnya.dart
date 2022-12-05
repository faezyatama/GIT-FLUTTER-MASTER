import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
// ignore: import_of_legacy_library_into_null_safe
// ignore: import_of_legacy_library_into_null_safe
import 'package:carousel_slider/carousel_slider.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/besarinGambar.dart';
import '/base/conn.dart';

class FotoProdukLainTS extends StatefulWidget {
  @override
  _FotoProdukLainTSState createState() => _FotoProdukLainTSState();
}

class _FotoProdukLainTSState extends State<FotoProdukLainTS> {
  final c = Get.find<ApiService>();
  bool datasiap = false;

  @override
  void initState() {
    super.initState();
    defaultGambar();
    cekKategori();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: CarouselSlider(
            options: CarouselOptions(
              aspectRatio: 1 / 1,
              viewportFraction: 1,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 8),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              //onPageChanged: callbackFunction,
              scrollDirection: Axis.horizontal,
            ),
            items: (datasiap == true) ? listkategori() : listkategori()));
    //end iklan
  }

  List<Container> listKategori = [];
  List kategori = [];

  defaultGambar() {
    listKategori.add(
      Container(
        child: SizedBox(
            child: GestureDetector(
          onTap: () {
            c.besarinGambarNama.value = c.namaTOSEKC.value;
            c.besarinGambar.value = c.gambarTOSEKChiRess.value;
            Get.to(() => BesarinGambar());
          },
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)),
            child: Image(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(c.gambarTOSEKC.value)),
          ),
        )),
      ),
    );
  }

  cekKategori() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var idProduk = c.itemIdTOSEKC.value;

    var datarequest = '{"pid":"$pid","idProduk":"$idProduk"}';
    var bytes = utf8.encode(datarequest + '$token');
    var signature = md5.convert(bytes).toString();
    var user = dbbox.get('loginSebagai');

    var url = Uri.parse('${c.baseURL}/sasuka/FotoProdukLain');

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
        kategori = hasil['data'];
        if (mounted) {
          setState(() {
            datasiap = true;
          });
        }
      }
    }
    //END LOAD DATA TOP UP
  }

  listkategori() {
    if (kategori.length > 0) {
      for (var i = 0; i < kategori.length; i++) {
        listKategori.add(
          Container(
              child: SizedBox(
                  child: GestureDetector(
            onTap: () {
              c.besarinGambar.value = kategori[i].replaceAll('/400/', '/600/');
              c.besarinGambarNama.value = c.namaTOSEKC.value;

              Get.to(() => BesarinGambar());
            },
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25)),
              child: Image(
                image: CachedNetworkImageProvider(kategori[i]),
                fit: BoxFit.cover,
              ),
            ),
          ))),
        );
      }
    }
    return listKategori;
  }
}
