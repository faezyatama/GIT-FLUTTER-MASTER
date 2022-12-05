import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import '/camera/galeriProfilTS.dart';
import '/dashboard/view/dashboard.dart';
import 'LaporanBeli.dart';
import 'LaporanTS.dart';
import 'PembelianPos.dart';
import 'aturStokProduk.dart';
import 'bukaOutletBaruTS.dart';
import 'listProdukToko.dart';
import 'pengaturanAdmin.dart';
import 'pengaturanCetak.dart';
import 'pengaturanOutletTS.dart';
import 'pengaturanPengiriman.dart';
import 'pesananTS.dart';
import 'pointOfSale.dart';
import 'tambahProdukTS.dart';
import 'package:intl/intl.dart' as intl;

import '../../folderUmum/chat/view/chatLiveSupport.dart';
import '../../folderUmum/chat/view/chatpage.dart';
import 'iklanAtasTS.dart';

class DashboardOutletTS extends StatefulWidget {
  @override
  _DashboardOutletTSState createState() => _DashboardOutletTSState();
}

class _DashboardOutletTSState extends State<DashboardOutletTS> {
  TextStyle styleHuruf1 = TextStyle(
    fontSize: 14,
    color: Warna.grey,
  );
  TextStyle styleHurufBesar =
      TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.w600);
  TextStyle smallhuruf = TextStyle(
      fontSize: 14, color: Warna.warnautama, fontWeight: FontWeight.w300);
  TextStyle styleHurufkecil = TextStyle(fontSize: 11, color: Warna.grey);

  @override
  void initState() {
    super.initState();
    cekAdaOutletGak();
  }

  final c = Get.find<ApiService>();
  var detailOutlet = [];
  var bukatutup = 'false';
  var showButton = false.obs;
  var dataReady = false;
  var badgeImage = ''.obs;
  var badgeTitle = ''.obs;
  var validThru = ''.obs;
  var dataPaketLisensi = false.obs;
  var arrayPaketLisensi = [];
  var pilihanLisensi = '';
  final controllerPin = TextEditingController();
  var hargaFinal = 'Rp.0,-'.obs;
  var arrayHargaLisensi = [];
  var hargaAwal = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Toko Sekitar'),
            actions: [
              (c.adaOutletTSKU.value == 'Ada')
                  ? GestureDetector(
                      onTap: () {
                        if (c.lisensiTS.value == 'Aktif') {
                          cekLisensiAktif();
                        } else if (c.lisensiTS.value == 'Tidak Aktif') {
                          cekLisensiNonAktif();
                        } else {
                          Get.snackbar('Mohon tunggu..',
                              'Mohon tunggu sedang membuka data toko');
                        }
                      },
                      child: (c.versiTosek.value == 'PREMIUM')
                          ? Image.asset('images/crown.png',
                              width: Get.width * 0.1)
                          : Image.asset('images/crownbw.png',
                              width: Get.width * 0.1),
                    )
                  : Padding(padding: EdgeInsets.only(left: 11)),
              Padding(padding: EdgeInsets.only(left: 11))
            ],
            backgroundColor: Colors.green),
        bottomNavigationBar: Obx(() => Container(
            padding: EdgeInsets.only(
              left: 11,
              right: 11,
            ),
            child: SizedBox(
              height: Get.height * 0.08,
              //  width: Get.width * 0.98,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(padding: EdgeInsets.only(left: 11)),
                  Obx(() => ((c.versiTosek.value != 'WEB BASE') &&
                          (c.versiTosek.value != ''))
                      ? Badge(
                          elevation: 0,
                          position: BadgePosition.bottomEnd(bottom: 15, end: 7),
                          animationDuration: Duration(milliseconds: 300),
                          animationType: BadgeAnimationType.fade,
                          badgeColor: (c.chatIndexBar.value == '')
                              ? Colors.transparent
                              : Colors.red,
                          badgeContent: Text(
                            c.chatIndexBar.value,
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                          child: IconButton(
                              onPressed: () {
                                if (c.adaOutletTSKU.value == 'Ada') {
                                  Get.to(() => ChatPage());
                                } else {
                                  Get.to(() => LiveSupportChatDetailPage());
                                }
                              },
                              icon: Icon(
                                Icons.chat,
                                size: 30,
                                color: Colors.green,
                              )),
                        )
                      : Padding(padding: EdgeInsets.all(1))),
                  (c.adaOutletTSKU.value == 'Ada')
                      ? RawMaterialButton(
                          onPressed: () {
                            if (bukatutup == 'false') {
                              bukaToko('true');
                            } else {
                              bukaToko('false');
                            }
                          },
                          constraints: BoxConstraints(),
                          elevation: 1.0,
                          fillColor: (showButton.value == false)
                              ? Colors.grey
                              : (bukatutup == 'false')
                                  ? Colors.grey
                                  : Colors.green,
                          child: (bukatutup == 'false')
                              ? Text('Offline / Tutup',
                                  style: TextStyle(
                                      color: Warna.putih, fontSize: 16))
                              : Text(
                                  'Online / Buka',
                                  style: TextStyle(
                                      color: Warna.putih, fontSize: 16),
                                ),
                          padding: EdgeInsets.fromLTRB(55, 11, 55, 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(9)),
                          ),
                        )
                      : Container(),
                  (c.adaOutletTSKU.value == 'Tidak Ada')
                      ? RawMaterialButton(
                          onPressed: () {
                            Get.to(() => BuatOutletBaruTS());
                          },
                          constraints: BoxConstraints(),
                          elevation: 1.0,
                          fillColor: Colors.green,
                          child: Column(
                            children: [
                              Text(
                                'Tunggu apa lagi ?',
                                style:
                                    TextStyle(color: Warna.putih, fontSize: 13),
                              ),
                              Text(
                                'Buka Toko Kamu Sekarang !',
                                style: TextStyle(
                                    color: Warna.putih,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.fromLTRB(33, 11, 33, 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(9)),
                          ),
                        )
                      : Container(
                          width: 1,
                        ),
                ],
              ),
            ))),
        body: Obx(() => Container(
              child: (c.adaOutletTSKU.value == 'Ada')
                  ? ListView(
                      children: [
                        IklanAtasTS(),
                        Container(
                          padding: EdgeInsets.fromLTRB(11, 1, 11, 11),
                          child: Row(
                            children: [
                              SizedBox(
                                width: Get.width * 0.65,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Obx(() => Text(
                                          c.namaOutletTSKU.value,
                                          textAlign: TextAlign.right,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: styleHurufBesar,
                                        )),
                                    Obx(() => Text(
                                          c.alamatOutletTSKU.value,
                                          textAlign: TextAlign.right,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: styleHuruf1,
                                        )),
                                    Obx(() => Text(
                                          c.kabupatenTSKU.value,
                                          textAlign: TextAlign.right,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: styleHuruf1,
                                        )),
                                    Obx(() => Text(
                                          c.deskripsiTSKU.value,
                                          textAlign: TextAlign.right,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: styleHuruf1,
                                        )),
                                  ],
                                ),
                              ),
                              Padding(padding: EdgeInsets.only(left: 5)),
                              Obx(() => InkWell(
                                    onTap: () {
                                      gantiLogoTokoSekitar();
                                    },
                                    child: Column(
                                      children: [
                                        (c.logoTokoSekitar.value == '')
                                            ? Column(
                                                children: [
                                                  Image.asset(
                                                    'images/noimage.jpg',
                                                    width: Get.width * 0.2,
                                                  ),
                                                  Text(
                                                    'Pilih Logo Usaha',
                                                    style:
                                                        TextStyle(fontSize: 10),
                                                  )
                                                ],
                                              )
                                            : SizedBox(
                                                width: Get.width * 0.2,
                                                child: CachedNetworkImage(
                                                    fit: BoxFit.fill,
                                                    imageUrl:
                                                        c.logoTokoSekitar.value,
                                                    errorWidget:
                                                        (context, url, error) {
                                                      print(error);
                                                      return Icon(
                                                          Icons
                                                              .camera_alt_rounded,
                                                          size: 44,
                                                          color: Colors.grey);
                                                    }),
                                              ),
                                      ],
                                    ),
                                  ))
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(11),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.pets,
                                    color: Warna.warnautama,
                                    size: 22.0,
                                  ),
                                  Obx(() => Text(
                                        c.kunjunganTSKU.value,
                                        style: smallhuruf,
                                      )),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.stars,
                                    color: Warna.warnautama,
                                    size: 22.0,
                                  ),
                                  Obx(() => Text(
                                        c.terjualTSKU.value,
                                        style: smallhuruf,
                                      )),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.loyalty,
                                    color: Warna.warnautama,
                                    size: 22.0,
                                  ),
                                  Obx(() => Text(
                                        c.produkTSKU.value,
                                        style: smallhuruf,
                                      )),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(22, 4, 22, 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: Get.width * 0.2,
                                child: InkWell(
                                  onTap: () {
                                    Get.to(() => ListProdukToko());
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/icontokosekitar/listProduk.png',
                                        width: 55,
                                      ),
                                      Text(
                                        'List Produk Toko',
                                        textAlign: TextAlign.center,
                                        style: styleHurufkecil,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: Get.width * 0.2,
                                child: InkWell(
                                  onTap: () {
                                    Get.to(() => TambahProdukTS());
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/icontokosekitar/tambahProduk.png',
                                        width: 55,
                                      ),
                                      Text(
                                        'Tambah Produk Baru',
                                        textAlign: TextAlign.center,
                                        style: styleHurufkecil,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: Get.width * 0.2,
                                child: InkWell(
                                  onTap: () {
                                    Get.to(() => AturStokProduk());
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/icontokosekitar/aturStok.png',
                                        width: 55,
                                      ),
                                      Text(
                                        'Atur Stok Produk',
                                        textAlign: TextAlign.center,
                                        style: styleHurufkecil,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: Get.width * 0.2,
                                child: InkWell(
                                  onTap: () {
                                    c.pilihanSupplierTS.value = 'Supplier Umum';
                                    Get.to(() => PembelianPOS());
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/icontokosekitar/tambahStok.png',
                                        width: 55,
                                      ),
                                      Text(
                                        'Tambah Stok Produk',
                                        textAlign: TextAlign.center,
                                        style: styleHurufkecil,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 4)),
                        Container(
                          margin: EdgeInsets.fromLTRB(22, 4, 22, 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: Get.width * 0.2,
                                child: InkWell(
                                  onTap: () {
                                    cekLisensiPenjualanOnline();
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/icontokosekitar/penjualanOnline.png',
                                        width: 55,
                                      ),
                                      Text(
                                        'Penjualan Online',
                                        textAlign: TextAlign.center,
                                        style: styleHurufkecil,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: Get.width * 0.2,
                                child: InkWell(
                                  onTap: () {
                                    cekLisensiPenjualanOffline();
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/icontokosekitar/penjualanOffline.png',
                                        width: 55,
                                      ),
                                      Text(
                                        'Penjualan Offline',
                                        textAlign: TextAlign.center,
                                        style: styleHurufkecil,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: Get.width * 0.2,
                                child: InkWell(
                                  onTap: () {
                                    Get.to(() => LaporanTS());
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/icontokosekitar/laporanJual.png',
                                        width: 55,
                                      ),
                                      Text(
                                        'Laporan Penjualan',
                                        textAlign: TextAlign.center,
                                        style: styleHurufkecil,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: Get.width * 0.2,
                                child: InkWell(
                                  onTap: () {
                                    Get.to(() => LaporanPembelianProduk());
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/icontokosekitar/laporanStok.png',
                                        width: 55,
                                      ),
                                      Text(
                                        'Laporan Pembelian Produk',
                                        textAlign: TextAlign.center,
                                        style: styleHurufkecil,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 4)),
                        Container(
                          margin: EdgeInsets.fromLTRB(22, 4, 22, 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: Get.width * 0.2,
                                child: InkWell(
                                  onTap: () {
                                    Get.to(() => PengaturanOutletTS());
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/icontokosekitar/aturToko.png',
                                        width: 55,
                                      ),
                                      Text(
                                        'Pengaturan Toko',
                                        textAlign: TextAlign.center,
                                        style: styleHurufkecil,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: Get.width * 0.2,
                                child: InkWell(
                                  onTap: () {
                                    if (c.versiTosek.value == 'PREMIUM') {
                                      Get.to(() => PengaturanAdminTS());
                                    } else {
                                      Get.snackbar('Fitur Premium',
                                          'Fitur ini hanya ada di versi Premium, dapatkan Diskon 80 %');
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/icontokosekitar/aturAdmin.png',
                                        width: 55,
                                      ),
                                      Text(
                                        'Pengaturan Admin',
                                        textAlign: TextAlign.center,
                                        style: styleHurufkecil,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: Get.width * 0.2,
                                child: InkWell(
                                  onTap: () {
                                    Get.to(() => PengaturanPengirimanTS());
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/icontokosekitar/aturPengiriman.png',
                                        width: 55,
                                      ),
                                      Text(
                                        'Pengaturan Pengiriman',
                                        textAlign: TextAlign.center,
                                        style: styleHurufkecil,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: Get.width * 0.2,
                                child: InkWell(
                                  onTap: () {
                                    Get.to(() => PengaturanCetakTS());
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/icontokosekitar/cetakStruk.png',
                                        width: 55,
                                      ),
                                      Text(
                                        'Pengaturan Cetak',
                                        textAlign: TextAlign.center,
                                        style: styleHurufkecil,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : (dataReady == true)
                      ? Container(
                          padding: EdgeInsets.all(28),
                          child: Center(
                            child: ListView(
                              children: [
                                Image.asset(
                                  'images/nopaket.png',
                                  width: Get.width * 0.6,
                                ),
                                Text(
                                  'Sepertinya kamu belum memiliki Outlet Toko Sekitar',
                                  style: styleHurufBesar,
                                  textAlign: TextAlign.center,
                                ),
                                Padding(padding: EdgeInsets.only(top: 22)),
                                Text(
                                  'Mudah loh menjadikan usaha kamu menjadi Online di ${c.namaAplikasi}, Cukup ikuti beberapa langkah mudah dan Outlet Toko Sekitar Online kamu akan segera aktif',
                                  style: styleHuruf1,
                                  textAlign: TextAlign.center,
                                ),
                                Padding(padding: EdgeInsets.only(top: 22)),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Image.asset(
                                        'images/icontokosekitar/tokooffline.png',
                                        width: Get.width * 0.2),
                                    Image.asset(
                                        'images/icontokosekitar/Pengantaran.png',
                                        width: Get.width * 0.2),
                                    Image.asset(
                                        'images/icontokosekitar/TokoOnline.png',
                                        width: Get.width * 0.2),
                                    Image.asset(
                                        'images/icontokosekitar/cs24.png',
                                        width: Get.width * 0.2)
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(top: 22)),
                                Text(
                                  'Ayo jadikan Toko kamu bisa melayani Online dan Offline dalam Satu Aplikasi',
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.green),
                                  textAlign: TextAlign.center,
                                ),
                                Padding(padding: EdgeInsets.only(top: 22)),
                                Text(
                                  'No Ribet dengan sistem penjualan terbaik, yang memudahkan kamu memantau Stok, Menambah Barang, dan Melihat Laporan Rugi/Laba. Keuangan Toko jadi semakin rapi',
                                  style: styleHuruf1,
                                  textAlign: TextAlign.center,
                                ),
                                Padding(padding: EdgeInsets.only(top: 22)),
                                Text(
                                  'Mudah mengatur Integrasi Kurir, kamu bahkan bisa membuat armada Pengiriman sendiri',
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.green),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  'Pengantaran pesanan ke pelanggan jadi mudah dengan sistem tokosekitar yang memungkinkan kamu memilih Kurir Umum atau menggunakan kurir sendiri yang dapat diatur biaya pengantaran sesuka kamu',
                                  style: styleHuruf1,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(),
            )));
  }

  void cekAdaOutletGak() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLtokosekitar}/mobileAppsOutlet/punyaOutletTidakTS');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        if (hasil['outlet'] == 'Ada') {
          if (hasil['versi'] == 'WEB BASE') {
            c.lisensiTS.value = hasil['lisensi'];
            c.versiTosek.value = hasil['versi'];
            AwesomeDialog(
              context: context,
              animType: AnimType.scale,
              dialogType: DialogType.noHeader,
              dismissOnBackKeyPress: false,
              dismissOnTouchOutside: false,
              body: Center(
                child: Column(
                  children: [
                    Image.asset('images/crown.png', width: Get.width * 0.25),
                    Padding(padding: EdgeInsets.only(top: 12)),
                    Text('LISENSI ${c.versiTosek.value} AKTIF',
                        style: TextStyle(
                            color: Warna.grey,
                            fontSize: 20,
                            fontWeight: FontWeight.w600)),
                    Text(
                        'Saat ini kamu sedang menggunakan aplikasi tokosekitar versi ${c.versiTosek.value}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Warna.grey, fontSize: 14)),
                    Text(
                        'Silahkan login menggunakan Web Browser untuk menggunakan Aplikasi POS TokoSekitar',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Warna.grey, fontSize: 14)),
                  ],
                ),
              ),
              btnCancelOnPress: () {
                Get.offAll(Dashboardku());
              },
              btnCancelText: 'Ok',
              btnCancelColor: Color.fromARGB(255, 156, 156, 156),
            )..show();
          } else {
            setState(() {
              dataReady = true;
              c.adaOutletTSKU.value = hasil['outlet'];
              detailOutlet = hasil['detailOutlet'];
              badgeImage.value = hasil['badge'];
              badgeTitle.value = hasil['badgeTitle'];
              c.lisensiTS.value = hasil['lisensi'];
              c.versiTosek.value = hasil['versi'];
              validThru.value = hasil['validThru'];
              arrayPaketLisensi = List<String>.from(hasil['arrayPaketLisensi']);
              arrayHargaLisensi = hasil['arrayHargaLisensi'];

              c.namaTokoPOS = detailOutlet[0];
              c.namaOutletTSKU.value = detailOutlet[0];
              c.alamatOutletTSKU.value = detailOutlet[1];
              c.kabupatenTSKU.value = detailOutlet[2];
              c.deskripsiTSKU.value = detailOutlet[3];
              c.kunjunganTSKU.value = detailOutlet[4];
              c.terjualTSKU.value = detailOutlet[5];
              c.produkTSKU.value = detailOutlet[6];
              c.logoTokoSekitar.value = detailOutlet[8];
              bukatutup = detailOutlet[7];
              showButton.value = true;
              hitungHargaPromoFinal('default price');
            });
          }
        } else {
          setState(() {
            dataReady = true;
            c.adaOutletTSKU.value = hasil['outlet'];
          });
        }
      }
    }
  }

  void bukaToko(String s) async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","bukatutup":"$s"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLtokosekitar}/mobileAppsOutlet/bukaTutupTS');

    final response = await http.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        showButton.value = true;
        setState(() {
          if (hasil['message'] == 'true') {
            bukatutup = 'true';
          } else {
            bukatutup = 'false';
          }
        });
      }
    }
  }

  void gantiLogoTokoSekitar() {
    //============= GANTI FOTO PROFIL =============
    AwesomeDialog(
      context: context,
      animType: AnimType.scale,
      dialogType: DialogType.noHeader,
      body: Center(
        child: Column(
          children: [
            Container(
              width: Get.width * 0.3,
              height: Get.width * 0.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: NetworkImage(c.logoTokoSekitar.value.toString()),
                    fit: BoxFit.cover),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 12)),
            Text(
              'Ganti Logo / Foto Outlet',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22),
            ),
            Padding(padding: EdgeInsets.only(top: 12)),
            Text(
                'Yuk ganti foto/logo outlet kamu yang terbaru, kamu bisa pilih melalui galery',
                style: TextStyle(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center),
          ],
        ),
      ),
      btnOkText: 'Buka Galery',
      btnOkIcon: Icons.camera_alt,

      btnOkOnPress: () {
        Get.to(() => GaleriProfilTS());
      }, //GET FROM CAMERA
    )..show();
  }

  void cekLisensiPenjualanOnline() {
    if (c.lisensiTS.value == 'Aktif') {
      c.selectedIndexOrderTSKU.value = 0;
      Get.to(() => PesananTS());
    } else if (c.lisensiTS.value == 'Tidak Aktif') {
      cekLisensiNonAktif();
    } else {
      Get.snackbar('Mohon tunggu..', 'Mohon tunggu sedang membuka data toko');
    }
  }

  void cekLisensiPenjualanOffline() {
    if (c.lisensiTS.value == 'Aktif') {
      Box dbbox = Hive.box<String>('sasukaDB');
      var pid = dbbox.get('person_id');
      c.kodeOutletPOS = 'TS-$pid';
      c.namaTokoPOS = c.namaOutletTSKU.value;
      c.alamatTokoPOS = c.alamatOutletTSKU.value;
      Get.to(() => PointOfSale());
    } else if (c.lisensiTS.value == 'Tidak Aktif') {
      cekLisensiNonAktif();
    } else {
      Get.snackbar('Mohon tunggu..', 'Mohon tunggu sedang membuka data toko');
    }
  }

  void cekLisensiAktif() {
    AwesomeDialog(
      context: context,
      animType: AnimType.scale,
      dialogType: DialogType.noHeader,
      body: Center(
        child: Column(
          children: [
            Image.asset('images/crown.png', width: Get.width * 0.25),
            Padding(padding: EdgeInsets.only(top: 12)),
            Text('LISENSI ${c.versiTosek.value} AKTIF',
                style: TextStyle(
                    color: Warna.grey,
                    fontSize: 20,
                    fontWeight: FontWeight.w600)),
            Text(
                'Saat ini kamu sedang menggunakan aplikasi tokosekitar versi ${c.versiTosek.value},',
                textAlign: TextAlign.center,
                style: TextStyle(color: Warna.grey, fontSize: 14)),
            (c.versiTosek.value == 'STANDART')
                ? Text(
                    'Untuk mendapatkan fitur extra kamu perlu mengaktifkan fitur premium sesuai dengan kebutuhan toko kamu. ',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Warna.grey, fontSize: 14))
                : Container(),
            Divider(),
            Text(validThru.value,
                textAlign: TextAlign.center,
                style: TextStyle(color: Warna.grey, fontSize: 14))
          ],
        ),
      ),
      btnOkText: 'Premium Go',
      btnOkColor: Warna.warnautama,
      btnOkOnPress: () {
        perpanjangLisensiTokoSekitar();
      },
      btnCancelOnPress: () {},
      btnCancelText: 'Ok',
      btnCancelColor: Color.fromARGB(255, 156, 156, 156),
    )..show();
  }

  void cekLisensiNonAktif() {
    AwesomeDialog(
      context: context,
      animType: AnimType.scale,
      dialogType: DialogType.noHeader,
      body: Center(
        child: Column(
          children: [
            Image.asset('images/crownbw.png', width: Get.width * 0.25),
            Padding(padding: EdgeInsets.only(top: 12)),
            Text('LISENSI PREMIUM EXPIRE',
                style: TextStyle(
                    color: Warna.grey,
                    fontSize: 20,
                    fontWeight: FontWeight.w600)),
            Text(validThru.value,
                textAlign: TextAlign.center,
                style: TextStyle(color: Warna.grey, fontSize: 14)),
            Padding(padding: EdgeInsets.only(top: 7)),
            Text(
                'Aktifkan masa lisensi untuk dapat menggunakan semua fitur unggulan dari TokoSekitar',
                textAlign: TextAlign.center,
                style: TextStyle(color: Warna.grey, fontSize: 14))
          ],
        ),
      ),
      btnOkText: 'Aktifkan',
      btnOkColor: Warna.warnautama,
      btnOkOnPress: () {
        perpanjangLisensiTokoSekitar();
      },
      btnCancelOnPress: () {},
      btnCancelText: 'Siap',
      btnCancelColor: Colors.green,
    )..show();
  }

  void perpanjangLisensiTokoSekitar() {
    AwesomeDialog(
      context: context,
      animType: AnimType.scale,
      dialogType: DialogType.noHeader,
      isDense: true,
      body: Center(
        child: Column(
          children: [
            Image.asset('images/crown.png', width: Get.width * 0.25),
            Padding(padding: EdgeInsets.only(top: 12)),
            Text('PROMO..!',
                style: TextStyle(
                    color: Warna.grey,
                    fontSize: 25,
                    fontWeight: FontWeight.w600)),
            Text('LISENSI PREMIUM',
                style: TextStyle(
                    color: Warna.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            Text(
                'Dapatkan banyak potongan harga bagi pengguna dengan Kemitraan Khusus sampai dengan 80%',
                textAlign: TextAlign.center,
                style: TextStyle(color: Warna.grey, fontSize: 14)),
            Padding(padding: EdgeInsets.only(top: 7)),
            Text(
                'Upgrade Fitur Premium untuk dapat menggunakan semua fitur unggulan dari TokoSekitar',
                textAlign: TextAlign.center,
                style: TextStyle(color: Warna.grey, fontSize: 14)),
            Container(
              padding: EdgeInsets.fromLTRB(22, 9, 22, 9),
              child: DropdownSearch<String>(
                  popupProps: PopupProps.menu(
                    showSelectedItems: true,
                    disabledItemFn: (String s) => s.startsWith('I'),
                  ),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Lisensi",
                    ),
                  ),
                  items: arrayPaketLisensi,
                  onChanged: (lisVal) {
                    print('Pilih lisensi');
                    pilihanLisensi = lisVal;
                    hitungHargaPromoFinal(lisVal);
                  },
                  selectedItem: arrayPaketLisensi[0]),
            ),
            Text('++ Diskon Special ++',
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            Text(
                'Bagi kamu yang menjadi Anggota Koperasi Aktif / Mitra Khusus, ada potongan tambahan',
                textAlign: TextAlign.center,
                style: TextStyle(color: Warna.grey, fontSize: 14)),
            Padding(padding: EdgeInsets.only(top: 8)),
            Row(children: [
              Image.asset('images/80persen.png', width: Get.width * 0.22),
              Column(
                children: [
                  Text('Saat ini kamu cukup bayar :',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Warna.grey, fontSize: 16)),
                  Obx(() => Text(hargaFinal.value,
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 22,
                          fontWeight: FontWeight.w600))),
                ],
              )
            ]),
            Divider(),
          ],
        ),
      ),
      btnOkText: 'Aktifkan Sekarang',
      btnOkColor: Warna.warnautama,
      btnOkOnPress: () {
        pinDibutuhkan();
      },
    )..show();
  }

  void pinDibutuhkan() {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Image.asset(
            'images/crown.png',
            width: Get.width * 0.25,
          ),
          Text('AKTIFKAN LISENSI PREMIUM',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.amber[700],
                  fontWeight: FontWeight.w600)),
          Text(
              'Untuk mengaktifkan Lisensi TokoSekitar saldo kamu akan terpotong sesuai dengan nominal dibawah ini',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center),
          Padding(padding: EdgeInsets.only(top: 9)),
          Obx(() => Text(hargaFinal.value,
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.amber[700],
                  fontWeight: FontWeight.w600))),
          Padding(padding: EdgeInsets.only(top: 16)),
          Divider(),
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
                prosesBeliLisensiTS();
              }
            },
          ),
        ],
      ),
    )..show();
  }

  void prosesBeliLisensiTS() async {
    EasyLoading.show(status: 'Mohon tunggu transaksi...', dismissOnTap: false);
    //BODY YANG DIKIRIM
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var pin = controllerPin.text;
    var lisensi = hargaAwal;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","lisensi":"$lisensi","pin":"$pin"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURL}/mobileApps/perpanjangLisensiTS');

    try {
      final response = await http.post(url, body: {
        "user": user,
        "appid": c.appid,
        "data_request": datarequest,
        "sign": signature,
        "package": c.packageName
      });

      EasyLoading.dismiss();
      controllerPin.text = '';

      print(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> hasil = jsonDecode(response.body);
        if (hasil['status'] == 'perpanjangan sukses') {
          setState(() {
            c.saldo.value = hasil['saldo'];
            c.lisensiTS.value = hasil['lisensi'];
            c.versiTosek.value = hasil['versi'];
            validThru.value = hasil['validThru'];
          });

          AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.success,
            animType: AnimType.rightSlide,
            dismissOnBackKeyPress: false,
            dismissOnTouchOutside: false,
            title: 'LISENSI BERHASIL DIUPGRADE',
            desc: 'Terima kasih telah mengaktifkan lisensi Toko Sekitar',
            btnOkText: 'OK',
            btnOkOnPress: () {
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
      }
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar('Koneksi tidak stabil',
          'Sepertinya koneksi internet kamu tidak stabil...');
    }
  }

  void hitungHargaPromoFinal(String lisVal) {
    var indexawal = 0;
    for (var i = 0; i < arrayPaketLisensi.length; i++) {
      if (arrayPaketLisensi[i] == lisVal) {
        indexawal = i;
      }
    }

    hargaAwal = arrayHargaLisensi[indexawal].toDouble();
    var hfinal = hargaAwal;
    var ribuan = intl.NumberFormat.decimalPattern().format(hfinal);
    hargaFinal.value = 'Rp. $ribuan,-';
    print(hfinal);
  }
}
