import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as https;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../base/notifikasiBuatAkun.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../folderUmum/chat/view/chatDetailPage.dart';
import 'package:share/share.dart';
import 'cekoutKeranjang.dart';

class DetailOtletTS extends StatefulWidget {
  @override
  _DetailOtletTSState createState() => _DetailOtletTSState();
}

class _DetailOtletTSState extends State<DetailOtletTS> {
  final c = Get.find<ApiService>();

  List keranjangMakan = [];
  List dataOutlet = [];
  List dataBarang = [];
  bool dataSiap = false;
  var jarak = '00 Km+'.obs;
  var dilihat = '00 Views'.obs;
  var terjual = 'Terjual'.obs;
  var jumlahProduk = '00 Produk'.obs;
  var loading = true.obs;
  var kategoriPilihan = '';
  var cariPilihan = '';
  var dataBarangSiap = false;

  var namaBadge = 'Seller'.obs;
  var badge = 'tokosekitargrey.png'.obs;
  var namaOutlet = 'Toko Sekitar'.obs;
  var kabupaten = 'Belanja mudah di sekitar kita'.obs;
  var idchat = '0';
  var fungsiPencarian = false;

  int jumlah = 1;

  tambahJumlah() {
    setState(() {
      jumlah = jumlah + 1;
    });
  }

  void kurangiJumlah() {
    if (jumlah > 1) {
      setState(() {
        jumlah = jumlah - 1;
      });
    }
  }

  var paginate = 0;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    listdatabarang = [];
    jsonDataBarang = [];

    outletToko();
    loadProdukToko();
    paginate = 0;
    _refreshController.refreshCompleted();
  }

  void _onLoading() {
    // monitor network fetch
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    hideKeyboard();
    outletToko();
    loadProdukToko();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List jsonDataBarang = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: EasySearchBar(
            backgroundColor: Warna.warnautama,
            suggestionBackgroundColor: Colors.grey,
            title: Text(
              namaOutlet.value,
              style: TextStyle(color: Colors.white),
            ),
            searchCursorColor: Color.fromARGB(255, 146, 140, 140),
            searchHintText: 'Cari apa di toko ini ?',
            searchHintStyle: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 135, 130, 130),
                fontStyle: FontStyle.italic),
            onSearch: (value) {
              pencarianBarangToko(value);
            }),
        floatingActionButton: SpeedDial(
          icon: Icons.auto_awesome,
          activeIcon: Icons.remove,
          buttonSize: Size(56.0, 56),
          visible: true,
          closeManually: false,
          renderOverlay: false,
          curve: Curves.bounceIn,
          overlayColor: Colors.black,
          overlayOpacity: 0.5,
          onOpen: () => print('OPENING DIAL'),
          onClose: () => print('DIAL CLOSED'),
          tooltip: 'Speed Dial',
          heroTag: 'speed-dial-hero-tag',
          backgroundColor: Color.fromARGB(255, 179, 171, 171),
          foregroundColor: Colors.black87,
          elevation: 8.0,
          shape: CircleBorder(),
          children: [
            SpeedDialChild(
              child: Icon(Icons.chat),
              backgroundColor: Colors.amber,
              label: 'Chat ke Outlet',
              labelStyle: TextStyle(fontSize: 16.0, color: Warna.grey),
              onTap: () {
                //TAMU OR MEMBER
                if (c.loginAsPenggunaKita.value == 'Member') {
                  c.idChatLawan.value = idchat;
                  c.namaChatLawan.value = c.namaTOSEKC.value;
                  c.fotoChatLawan.value = c.gambarTOSEKC.value;

                  Get.to(() => ChatDetailPage());
                } else {
                  var judulF = 'Akun ${c.namaAplikasi} Dibutuhkan ?';

                  var subJudul =
                      'Yuk Buka akun ${c.namaAplikasi} sekarang, hanya beberapa langkah akun kamu sudah aktif loh...';

                  bukaLoginPage(judulF, subJudul);
                }
                //END TAMU OR MEMBER
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.favorite),
              backgroundColor: Colors.blue[300],
              label: 'Suka / Wishlist',
              labelStyle: TextStyle(fontSize: 16.0, color: Warna.grey),
              onTap: () {
                //TAMU OR MEMBER
                if (c.loginAsPenggunaKita.value == 'Member') {
                  sukaTokoIni();
                  Get.snackbar(c.namaTOSEKC.value,
                      'Terima kasih telah menyukai toko ini');
                } else {
                  var judulF = 'Akun ${c.namaAplikasi} Dibutuhkan ?';
                  var subJudul =
                      'Yuk Buka akun ${c.namaAplikasi} sekarang, hanya beberapa langkah akun kamu sudah aktif loh...';

                  bukaLoginPage(judulF, subJudul);
                }
                //END TAMU OR MEMBER
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.share),
              backgroundColor: Colors.pink[300],
              label: 'Rekomendasikan toko ini ke teman',
              labelStyle: TextStyle(fontSize: 16.0, color: Warna.grey),
              onTap: () {
                Box dbbox = Hive.box<String>('sasukaDB');
                var sscode = dbbox.get('kodess');
                var namaToko =
                    c.namaTOSEKC.value.replaceAll(RegExp('[^A-Za-z0-9]'), '-');
                var url =
                    'https://my.satuaja.id?tokosekitar=$namaToko&c=${c.idPilihanOutletTS.value}&promo=$sscode';
                Share.share(url, subject: 'Share Transaksi');
              },
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(5),
          child: RawMaterialButton(
            onPressed: () {
              //TAMU OR MEMBER
              if (c.loginAsPenggunaKita.value == 'Member') {
                if (c.hargaKeranjangTOSEK.value > 0) {
                  Get.to(() => LokasidanKeranjangTS());
                }
              } else {
                var judulF = 'Akun ${c.namaAplikasi} Dibutuhkan ?';
                var subJudul =
                    'Yuk Buka akun ${c.namaAplikasi} sekarang, hanya beberapa langkah akun kamu sudah aktif loh...';

                bukaLoginPage(judulF, subJudul);
              }
              //END TAMU OR MEMBER
            },
            constraints: BoxConstraints(),
            elevation: 1.0,
            fillColor: Warna.warnautama,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                          '${c.jumlahItemTOSEK.value} item',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w200,
                              color: Warna.putih),
                        )),
                    Obx(() => SizedBox(
                          width: Get.width * 0.35,
                          child: Text(
                            c.namaoutletpadakeranjangTOSEK.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Warna.putih, fontSize: 9),
                          ),
                        )),
                  ],
                ),
                Row(
                  children: [
                    Obx(() => Text(
                          'Rp. ${c.hargaKeranjangTOSEK.value},-',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w200,
                              color: Warna.putih),
                        )),
                    Padding(padding: EdgeInsets.only(left: 11)),
                    Icon(
                      Icons.shopping_cart,
                      size: 25,
                      color: Colors.white,
                    )
                  ],
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(33)),
            ),
          ),
        ),
        body: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            header: WaterDropHeader(
              waterDropColor: Warna.warnautama,
            ),
            footer: CustomFooter(
              builder: (BuildContext context, LoadStatus mode) {
                Widget body;
                if (mode == LoadStatus.idle) {
                  body = Text("Mencari produk ...");
                } else if (mode == LoadStatus.loading) {
                  body = CupertinoActivityIndicator();
                } else if (mode == LoadStatus.failed) {
                  body = Text("Gagal memuat ! Silahkan ulangi lagi !");
                } else if (mode == LoadStatus.canLoading) {
                  body = Text("release to load more");
                } else {
                  body = Text("No more Data");
                }
                return Container(
                  height: 55.0,
                  child: Center(child: body),
                );
              },
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: ListView(children: [
              Container(
                color: Colors.grey[300],
                padding: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: Get.width * 0.2,
                      child: Column(
                        children: [
                          Obx(() => Image.asset(
                                'images/sellerbadge/${badge.value}',
                                width: Get.width * 0.1,
                              )),
                          Obx(() => Text(
                                namaBadge.value,
                                style: TextStyle(
                                    color: Color.fromARGB(255, 118, 117, 114),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(left: 11)),
                    SizedBox(
                      width: Get.width * 0.7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Toko :',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              color: Warna.warnautama,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Obx(() => Text(
                                namaOutlet.value,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                    color: Warna.warnautama,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.right,
                              )),
                          Padding(padding: EdgeInsets.only(top: 12)),
                          Obx(() => Text(
                                kabupaten.value,
                                style: TextStyle(color: Warna.grey),
                              )),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.visibility,
                                    color: Warna.grey,
                                    size: 18,
                                  ),
                                  Obx(() => Text(
                                        dilihat.value,
                                        style: TextStyle(
                                            color: Warna.grey, fontSize: 11),
                                      )),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.place,
                                    color: Warna.grey,
                                    size: 18,
                                  ),
                                  Obx(() => Text(
                                        jarak.value,
                                        style: TextStyle(
                                            color: Warna.grey, fontSize: 11),
                                      )),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.pages,
                                    color: Warna.grey,
                                    size: 18,
                                  ),
                                  Obx(() => Text(
                                        jumlahProduk.value,
                                        style: TextStyle(
                                            color: Warna.grey, fontSize: 11),
                                      )),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() => Container(
                    child: (loading.value == true)
                        ? LinearProgressIndicator(
                            color: Colors.amberAccent,
                          )
                        : Container(
                            height: 2,
                          ),
                  )),
              Container(
                padding: EdgeInsets.all(5),
                child: Row(
                  children: [
                    SizedBox(
                        width: Get.width * 0.23, child: Text('Kategori : ')),
                    SizedBox(
                      width: Get.width * 0.73,
                      child: listKategoriProduk(),
                    ),
                  ],
                ),
              ),
              Column(children: listdaftarBarangToko())
            ])));
  }

  tambahKeKeranjang(String gambar, String nama, String detail, String harga,
      int itemid, int intHarga, int idOutlet, int maxStok) {
    final c = Get.find<ApiService>();
    //hitung keranjang
    var jb = 0;
    for (var i = 0; i < c.keranjangTOSEK.length; i++) {
      if (c.keranjangTOSEK[i] == itemid) {
        jb++;
      }
    }
    c.jumlahBarangTOSEK.value = jb;
    //end hitung keranjang

    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          CachedNetworkImage(
            imageUrl: gambar,
            width: Get.width * 0.8,
            height: Get.width * 0.8,
          ),
          Padding(padding: EdgeInsets.only(top: 9)),
          Text(nama,
              style: TextStyle(
                  fontSize: 20, color: Warna.grey, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
          Container(
            padding: EdgeInsets.fromLTRB(22, 7, 22, 11),
            child: Text(
              detail,
              style: TextStyle(fontSize: 14, color: Warna.grey),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 16)),
          Text(harga,
              style: TextStyle(
                  fontSize: 18,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w600)),
          Padding(padding: EdgeInsets.only(top: 7)),
          Padding(padding: EdgeInsets.only(top: 7)),
          Divider(),
          Container(
            padding: EdgeInsets.only(left: 9, right: 9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: Warna.warnautama,
                      size: 25,
                    ),
                    onPressed: () {
                      if (c.jumlahBarangTOSEK.value > 0) {
                        c.jumlahItemTOSEK.value--;
                        var hrgSatuan = intHarga;
                        c.hargaKeranjangTOSEK.value =
                            c.hargaKeranjangTOSEK.value - hrgSatuan;
                        var kurang = 0;
                        for (var i = 0; i < c.keranjangTOSEK.length; i++) {
                          if (c.keranjangTOSEK[i] == itemid) {
                            if (kurang == 0) {
                              c.keranjangTOSEK.remove(itemid);
                              kurang = 1;
                            }
                          }
                        }
                        var jb = 0;
                        for (var i = 0; i < c.keranjangTOSEK.length; i++) {
                          if (c.keranjangTOSEK[i] == itemid) {
                            jb++;
                          }
                        }
                        c.jumlahBarangTOSEK.value = jb;

                        // print(c.keranjangMakan);
                      } else {
                        c.idOutletpadakeranjangTOSEK.value = 0;
                      }
                    }),
                Obx(() => Text(c.jumlahBarangTOSEK.value.toString(),
                    style: TextStyle(
                        fontSize: 18,
                        color: Warna.warnautama,
                        fontWeight: FontWeight.w400))),
                IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: Warna.warnautama,
                      size: 25,
                    ),
                    onPressed: () {
                      if (c.jumlahBarangTOSEK.value >= maxStok) {
                        Get.snackbar('Stok tersedia',
                            'Opps... sepertinya stok tersedia : $maxStok',
                            colorText: Colors.white);
                        return;
                      }
                      var hrgSatuan = intHarga;
                      c.hargaKeranjangTOSEK.value =
                          c.hargaKeranjangTOSEK.value + hrgSatuan;
                      c.jumlahItemTOSEK.value++;
                      c.keranjangTOSEK.add(itemid);
                      var jb = 0;
                      for (var i = 0; i < c.keranjangTOSEK.length; i++) {
                        if (c.keranjangTOSEK[i] == itemid) {
                          jb++;
                        }
                      }
                      c.jumlahBarangTOSEK.value = jb;
                      c.idOutletpadakeranjangTOSEK.value = idOutlet;
                    }),
                RawMaterialButton(
                  onPressed: () {
                    Get.back();
                  },
                  constraints: BoxConstraints(),
                  elevation: 1.0,
                  fillColor: Warna.warnautama,
                  child: Text(
                    'Tambahkan',
                    style: TextStyle(color: Warna.putih),
                  ),
                  padding: EdgeInsets.fromLTRB(9, 3, 9, 3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(9)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )..show();
  }

  cekBarangDiLokal(idMakanan) {
    var hasil = 0;

    for (var i = 0; i < c.keranjangTOSEK.length; i++) {
      if (c.keranjangTOSEK[i].itemid == idMakanan) {
        hasil = c.keranjangTOSEK[i].jumlah;
      }
    }

    return hasil;
  }

  void sukaTokoIni() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var idOutlet = c.idPilihanOutletTS.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","idOutlet":"$idOutlet"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLtokosekitar}/mobileAppsUser/sukaTokoIni');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    // EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {}
    }
  }

  void loadProdukToko() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    loading.value = true;
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var tokoPilihan = c.idPilihanOutletTS.value;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","tokoPilihan":"$tokoPilihan","kategori":"$kategoriPilihan","cari":"$cariPilihan"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLtokosekitar}/mobileAppsUser/tokoDanProduk');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    // EasyLoading.dismiss();
    print(response.body);
    loading.value = false;
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        setState(() {
          jsonDataBarang = hasil['dataBarang'];
          dataBarangSiap = true;
          jumlahProduk.value = '${hasil['totalBarang']} Produk';
        });
      }
    }
  }

  hideKeyboard() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    FocusScope.of(context).requestFocus(FocusNode());
  }

  outletToko() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    loading.value = true;
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var latitude = c.latitude.value;
    var longitude = c.longitude.value;
    var idoutlet = c.idPilihanOutletTS.value;

    // EasyLoading.dismiss();
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","lat":"$latitude","long":"$longitude","idOutlet":"$idoutlet"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLtokosekitar}/mobileAppsUser/outletTSDetail');
    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });
    print(response.body);

    c.dataResponseTokoTOSEKC.value = response.body;
    c.dataResponseIdTokoTOSEKC.value = c.idOutletPilihanTOSEK.value;

    loading.value = false;

    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);

      if (hasil['status'] == 'success') {
        namaOutlet.value = hasil['namaOutlet'];
        kabupaten.value = hasil['alamat'];
        jarak.value = hasil['jarak'].toString();
        terjual.value = hasil['terjual'].toString();
        dilihat.value = hasil['dilihat'].toString();
        idchat = hasil['idchat'];

        c.namaTOSEKC.value = hasil['namaOutlet'];
        c.gambarTOSEKC.value = hasil['foto'];
        badge.value = hasil['badge'];
        namaBadge.value = hasil['namaBadge'];
        kategori = hasil['kategoriProduk'];
        setState(() {});
      }
    }
  }

  var kategori = [];
  List<Container> listKate = [];
  listKategoriProduk() {
    listKate = [];

    for (var i = 0; i < kategori.length; i++) {
      var namakate = kategori[i];
      listKate.add(Container(
        child: OutlinedButton(
          onPressed: () {
            cariPilihan = '';
            kategoriPilihan = namakate;
            _onRefresh();
          },
          child: Text(
            '$namakate',
            style:
                TextStyle(color: Warna.warnautama, fontWeight: FontWeight.w500),
          ),
        ),
      ));
    }
    return Container(
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, child: Row(children: listKate)),
    );
  }

  List<Container> listdatabarang = [];
  List<Container> nodataList = [];

  listdaftarBarangToko() {
    if (jsonDataBarang.length > 0) {
      for (var i = 0; i < jsonDataBarang.length; i++) {
        var valHistory = jsonDataBarang[i];

        listdatabarang.add(
          Container(
            child: Card(
              elevation: 0,
              //color: Colors.lightGreen[50],
              margin: EdgeInsets.all(5),

              child: InkWell(
                onTap: () {
                  var gambar = valHistory[7];
                  var nama = valHistory[1];
                  var detail = valHistory[2];
                  var harga = valHistory[6];
                  int itemid = valHistory[0];
                  int intHarga = valHistory[8];
                  int idOutlet = valHistory[10];
                  int maxStok = valHistory[9];
                  tambahKeKeranjang(gambar, nama, detail, harga, itemid,
                      intHarga, idOutlet, maxStok);
                },
                child: Container(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: CachedNetworkImage(
                              width: Get.width * 0.3,
                              height: Get.width * 0.3,
                              imageUrl: valHistory[7],
                              errorWidget: (context, url, error) {
                                print(error);
                                return Icon(Icons.shopping_bag_outlined,
                                    color: Warna.warnautama, size: 25);
                              }),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(left: Get.width * 0.02)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: Get.width * 0.55,
                            child: Text(
                              valHistory[1], //NAMA BARANG
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(fontSize: 17, color: Warna.grey),
                            ),
                          ),
                          SizedBox(
                            width: Get.width * 0.55,
                            child: Text(
                              valHistory[2], //DESKRIPSI
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(fontSize: 12, color: Warna.grey),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 12)),
                          Container(
                            width: Get.width * 0.55,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      // width: Get.width * 0.25,
                                      child: Text(
                                        valHistory[5], //LOKASI
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Warna.grey,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    SizedBox(
                                      // width: Get.width * 0.25,
                                      child: Text(
                                        valHistory[6], //HARGA
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Warna.grey,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                RawMaterialButton(
                                  onPressed: () {
                                    var gambar = valHistory[7];
                                    var nama = valHistory[1];
                                    var detail = valHistory[2];
                                    var harga = valHistory[6];
                                    int itemid = valHistory[0];
                                    int intHarga = valHistory[8];
                                    int idOutlet = valHistory[10];
                                    int maxStok = valHistory[9];
                                    tambahKeKeranjang(
                                        gambar,
                                        nama,
                                        detail,
                                        harga,
                                        itemid,
                                        intHarga,
                                        idOutlet,
                                        maxStok);
                                  },
                                  constraints: BoxConstraints(),
                                  elevation: 1.0,
                                  fillColor: Warna.warnautama,
                                  child: Text(
                                    'Beli',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  padding: EdgeInsets.fromLTRB(12, 4, 12, 4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(9)),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(11, 0, 11, 0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.green[500],
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Text(
                              'Stok : ${valHistory[9]}', //stok
                              style:
                                  TextStyle(color: Colors.green, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
      jsonDataBarang = [];
      return listdatabarang;
    } else {
      nodataList = [];
      nodataList.add(Container(
        padding: EdgeInsets.fromLTRB(22, Get.height * 0.2, 22, 2),
        child: Column(
          children: [
            // CircularProgressIndicator(),
            Padding(padding: EdgeInsets.only(top: 20)),
            Center(
                child: Text(
              'Produk tidak ditemukan ...',
              style: TextStyle(
                fontSize: 12,
                color: Warna.grey,
              ),
              textAlign: TextAlign.center,
            )),
          ],
        ),
      ));
      if (listdatabarang.length == 0) {
        return nodataList;
      } else {
        nodataList = [];
        return listdatabarang;
      }
    }
  }

  void pencarianBarangToko(String value) {
    if (value.length > 3) {
      cariPilihan = value;
      kategoriPilihan = '';
      _onRefresh();
    }
  }
}
