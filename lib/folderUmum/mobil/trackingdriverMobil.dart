import 'dart:async';
import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as https;
// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../../folderUmum/chat/view/chatDetailPage.dart';
import '/dashboard/view/dashboard.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:smooth_star_rating/smooth_star_rating.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;

class TrackingDriverMobil extends StatefulWidget {
  @override
  _TrackingDriverMobilState createState() => _TrackingDriverMobilState();
}

class _TrackingDriverMobilState extends State<TrackingDriverMobil> {
  Box dbbox = Hive.box<String>('sasukaDB');

  Completer<GoogleMapController> _controller = Completer();
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  BitmapDescriptor kuriricon;

  List<Marker> _markers = [];

  LatLng currentLocation;
  LatLng destinationLocation;

  final c = Get.find<ApiService>();
  var latJemput = -7.7;
  var longJemput = 110.4;
  var latDriver = 0.0;
  var longDriver = 0.0;
  var latTujuan = 0.0;
  var longTujuan = 0.0;
  var dataSiap = false.obs;
  var trackingDriver = false.obs;
  var btnSelesai = false.obs;
  var iddriver = '0'.obs;
  var gambarDriver = ''.obs;
  var namaDriver = ''.obs;
  var kendaraanDriver = ''.obs;
  var platNomorDriver = ''.obs;
  var alamatTujuan = ''.obs;
  var alamatJemput = ''.obs;
  var ketTujuan = ''.obs;
  var ketJemput = ''.obs;
  var ratingDriver = 5.0.obs;
  var statusDriver = ''.obs;
  var outlet = ''.obs;
  var keterangan = 'Mohon tunggu'.obs;
  var tahapan = 0;

  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;

  Timer timer;
  Timer timerCekStatus;
  Timer timeLokasiGpsDriver;
  Timer timerGakKetemuDriver;

  @override
  void initState() {
    super.initState();
    cekLokasidanOutlet();
    timerGakKetemuDriver =
        Timer.periodic(Duration(seconds: 45), (Timer t) => gakKetemuDriver());

    timerCekStatus =
        Timer.periodic(Duration(seconds: 5), (Timer t) => cekLokasidanOutlet());
    polylinePoints = PolylinePoints();
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    timerCekStatus?.cancel();
    timeLokasiGpsDriver?.cancel();
    timerGakKetemuDriver?.cancel();
  }

  void setSourceAndDestinationMarkerIcon() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.0), 'images/JEMPUT.png');
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.0), 'images/TUJUAN.png');
    kuriricon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.0), 'images/mapDRIVER.png');
  }

  void setInitialLocation() {
    currentLocation = LatLng(latJemput, longJemput);
    destinationLocation = LatLng(latTujuan, longTujuan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Perjalanan ' + c.nNamafitMobil),
          backgroundColor: Warna.warnautama,
        ),
        bottomNavigationBar: (trackingDriver.value == false)
            ? Container(
                child: RawMaterialButton(
                  onPressed: () {
                    AwesomeDialog(
                      context: Get.context,
                      dialogType: DialogType.warning,
                      animType: AnimType.rightSlide,
                      title: 'PERHATIAN !',
                      desc:
                          'Apa kamu yakin akan membatalkan perjalanan ini ???',
                      btnOkText: 'Tidak',
                      btnOkOnPress: () {},
                      btnCancelText: 'Batalkan',
                      btnCancelColor: Colors.amber,
                      btnCancelOnPress: () {
                        batalkanPesananini();
                      },
                    )..show();
                  },
                  constraints: BoxConstraints(),
                  elevation: 1.0,
                  fillColor: Warna.warnautama,
                  child: Text('Batalkan Perjalanan',
                      style: TextStyle(color: Colors.white)),
                  padding: EdgeInsets.fromLTRB(22, 11, 22, 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(33)),
                  ),
                ),
              )
            : (btnSelesai.value == true)
                ? Container(
                    child: RawMaterialButton(
                      onPressed: () {
                        alertPerjalananSelesai();
                      },
                      constraints: BoxConstraints(),
                      elevation: 1.0,
                      fillColor: Colors.blue,
                      child: Text('Selesaikan Perjalanan',
                          style: TextStyle(color: Colors.white)),
                      padding: EdgeInsets.fromLTRB(22, 11, 22, 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(33)),
                      ),
                    ),
                  )
                : Text(''),
        body: Stack(
          children: [
            (dataSiap.value == false)
                ? Container()
                : Container(
                    margin: EdgeInsets.only(top: Get.height * 0.23),
                    child: GoogleMap(
                        compassEnabled: false,
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                          showPinonMaps();
                          setPolylines();
                        },
                        markers: _markers.toSet(),
                        polylines: _polylines,
                        initialCameraPosition: CameraPosition(
                            zoom: CAMERA_ZOOM,
                            tilt: CAMERA_TILT,
                            bearing: CAMERA_BEARING,
                            target: currentLocation)),
                  ),
            Container(
              margin: EdgeInsets.fromLTRB(5, 11, 5, 1),
              child: Column(
                children: [
                  Card(
                    child: RawMaterialButton(
                      onPressed: () {
                        moveMapTo(latJemput, longJemput);
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Row(
                          children: [
                            SizedBox(
                              width: Get.width * 0.15,
                              child: Icon(
                                Icons.location_city,
                                size: 25,
                                color: Colors.redAccent,
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(left: 11)),
                            SizedBox(
                              width: Get.width * 0.7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lokasi Penjemputan',
                                    style: TextStyle(
                                        color: Warna.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Obx(() => Text(
                                        alamatJemput.value,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                            color: Warna.grey, fontSize: 12),
                                      )),
                                  Obx(() => Text(
                                        'Ket : ${ketJemput.value}',
                                        style: TextStyle(
                                            color: Warna.grey, fontSize: 12),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    child: RawMaterialButton(
                      onPressed: () {
                        moveMapTo(latTujuan, longTujuan);
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Row(
                          children: [
                            SizedBox(
                              width: Get.width * 0.15,
                              child: Icon(
                                Icons.map,
                                size: 25,
                                color: Colors.green,
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(left: 11)),
                            SizedBox(
                              width: Get.width * 0.7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tujuan Perjalanan',
                                    style: TextStyle(
                                        color: Warna.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Obx(() => Text(
                                        alamatTujuan.value,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                            color: Warna.grey, fontSize: 12),
                                      )),
                                  Obx(() => Text(
                                        'Ket : ${ketTujuan.value}',
                                        style: TextStyle(
                                            color: Warna.grey, fontSize: 12),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  (trackingDriver.value == false)
                      ? Column(
                          children: [
                            Text('Mencari Driver ...',
                                style: TextStyle(
                                  color: Warna.grey,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w200,
                                )),
                            Text('Mohon tunggu, sedang menghubungi driver',
                                style: TextStyle(
                                  color: Warna.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                )),
                            Padding(padding: EdgeInsets.only(top: 11)),
                            SizedBox(
                                width: Get.width * 0.7,
                                child: LinearProgressIndicator()),
                          ],
                        )
                      : Card(
                          child: RawMaterialButton(
                            onPressed: () {
                              moveMapTo(latDriver, longDriver);
                              setState(() {
                                _markers.remove(_markers.firstWhere(
                                    (Marker marker) =>
                                        marker.markerId.value == 'kurirpin'));
                                _markers.add(Marker(
                                    markerId: MarkerId('kurirpin'),
                                    position: LatLng(latDriver, longDriver),
                                    icon: kuriricon));
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(5),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: Get.width * 0.15,
                                    child: CircleAvatar(
                                      radius: Get.width * 0.06,
                                      backgroundImage:
                                          NetworkImage(gambarDriver.value),
                                      backgroundColor: Colors.transparent,
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(left: 11)),
                                  SizedBox(
                                    width: Get.width * 0.6,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Pengemudi :',
                                            style: TextStyle(
                                              color: Warna.grey,
                                              fontSize: 11,
                                            )),
                                        Obx(() => Text(
                                              namaDriver.value,
                                              style: TextStyle(
                                                  color: Warna.grey,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600),
                                            )),
                                        Obx(() => Text(
                                              '${platNomorDriver.value} - ${kendaraanDriver.value}',
                                              style: TextStyle(
                                                color: Warna.grey,
                                                fontSize: 12,
                                              ),
                                            )),
                                        Padding(
                                            padding: EdgeInsets.only(top: 5)),
                                        LinearProgressIndicator(
                                          color: Warna.warnautama,
                                        ),
                                        Obx(() => Text(
                                              statusDriver.value,
                                              style: TextStyle(
                                                  color: Warna.warnautama,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500),
                                            ))
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Get.to(() => ChatDetailPage());
                                    },
                                    icon: Icon(Icons.chat,
                                        color: Warna.warnautama),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            )
          ],
        ));
  }

  moveMapTo(moveLat, moveLong) async {
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(moveLat, moveLong),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
  }

  cekLokasidanOutlet() async {
    timeLokasiGpsDriver?.cancel();
    var cekin = await cekInternet();
    if (cekin == true) {
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');
      var user = dbbox.get('loginSebagai');

      var datarequest = '{"pid":"$pid"}';
      var bytes = utf8.encode(datarequest + '$token' + user);
      var signature = md5.convert(bytes).toString();

      var url =
          Uri.parse('${c.baseURLdriver}/mobileAppsUser/cekPetaPerjalananMobil');

      final response = await https.post(url, body: {
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
          latJemput = hasil['latJemput'];
          longJemput = hasil['longJemput'];
          latTujuan = hasil['latTujuan'];
          longTujuan = hasil['longTujuan'];
          latDriver = hasil['latDriver'];
          longDriver = hasil['longDriver'];
          alamatJemput.value = hasil['alamatJemput'];
          alamatTujuan.value = hasil['alamatTujuan'];
          ketJemput.value = hasil['ketJemput'];
          ketTujuan.value = hasil['ketTujuan'];
          c.kodeTransaksiMotor.value = hasil['kodetrx'];
          iddriver.value = hasil['idDriver'];
          if (iddriver.value == '0') {
          } else {
            var detDriver = hasil['detailDriver'];
            gambarDriver.value = detDriver[3];
            namaDriver.value = detDriver[0];
            kendaraanDriver.value = detDriver[1];
            platNomorDriver.value = detDriver[2];

            c.idChatLawan.value = hasil['idDriver'];
            c.namaChatLawan.value = detDriver[0];
            c.fotoChatLawan.value = detDriver[3];

            setState(() {
              trackingDriver.value = true;
              timerCekStatus?.cancel();
            });

            timeLokasiGpsDriver = Timer.periodic(
                Duration(seconds: 7), (Timer t) => trackingGpsDriver());
          }

          setState(() {
            setSourceAndDestinationMarkerIcon();
            setInitialLocation();
            dataSiap.value = true;
          });
        } else if (hasil['status'] == 'failed') {
          // Get.back();
          // Get.snackbar('Tidak ada pengantaran',
          //     'Opps.. sepertinya tidak ada yang ditampilkan');
        }
      }
    }
  }

  void setPolylines() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyDDjqHtIUkj8UebTWpEmlbPexH8GZXoWOI',
        PointLatLng(latJemput, longJemput),
        PointLatLng(latTujuan, longTujuan));
    if (result.status == 'OK') {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      setState(() {
        _polylines.add(Polyline(
            width: 10,
            color: Colors.blue,
            polylineId: PolylineId('polyline'),
            points: polylineCoordinates));
      });
    }
  }

  Future cekInternet() async {
    bool conn = true;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if ((connectivityResult == ConnectivityResult.mobile) ||
        (connectivityResult == ConnectivityResult.wifi)) {
      conn = true;
    } else {
      conn = false;
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        title: '',
        desc: '',
        body: Column(
          children: [
            Image.asset('images/nointernet.png'),
            Text('Opps..sepertinya internet tidak ditemukan',
                style: TextStyle(
                    fontSize: 20,
                    color: Warna.grey,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            Container(
              padding: EdgeInsets.fromLTRB(22, 7, 22, 11),
              child: Text(
                'periksa kembali koneksi internet kamu agar ${c.namaAplikasi} bisa mencari data yang kamu perlukan',
                style: TextStyle(fontSize: 14, color: Warna.grey),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 16)),
          ],
        ),
      )..show();
    }
    return conn;
  }

  void showPinonMaps() {
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId('sourcepin'),
          position: currentLocation,
          icon: sourceIcon));

      _markers.add(Marker(
          markerId: MarkerId('kurirpin'),
          position: destinationLocation,
          icon: kuriricon));

      _markers.add(Marker(
          markerId: MarkerId('destinationpin'),
          position: destinationLocation,
          icon: destinationIcon));
    });
  }

  void batalkanPesananini() async {
    var cekin = await cekInternet();
    if (cekin == true) {
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');
      var kodetrx = c.kodeTransaksiMotor.value;
      var user = dbbox.get('loginSebagai');

      var datarequest = '{"pid":"$pid","kodetrx":"$kodetrx"}';
      var bytes = utf8.encode(datarequest + '$token' + user);
      var signature = md5.convert(bytes).toString();

      var url = Uri.parse(
          '${c.baseURLdriver}/mobileAppsUser/batalkanPerjalananMobil');

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
        if (hasil['status'] == 'success') {
          if (mounted) {
            Get.back();
          }
        } else if (hasil['status'] == 'failed') {
          AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.warning,
            animType: AnimType.rightSlide,
            title: 'PERHATIAN !',
            desc: hasil['message'],
          )..show();
        }
      }
    }
  }

  void alertDriverTidakTersedia() {
    if (!mounted) {
      return;
    }
    AwesomeDialog(
      context: Get.context,
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Image.asset(
            'images/nodriver.png',
            width: Get.width * 0.5,
          ),
          Text('DRIVER SEDANG SIBUK',
              style: TextStyle(
                  fontSize: 18,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w600)),
          Text(
              'Opps.. maaf saat ini driver kami sedang sibuk semua, kami belum bisa menemukan driver untukmu.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center),
          Padding(padding: EdgeInsets.only(top: 9)),
          RawMaterialButton(
            onPressed: () {
              batalkanPesananini();
              Get.offAll(Dashboardku());
            },
            constraints: BoxConstraints(),
            elevation: 1.0,
            fillColor: Warna.warnautama,
            child: Text(
              'Batalkan perjalanan',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Warna.putih),
            ),
            padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(33)),
            ),
          ),
          RawMaterialButton(
            onPressed: () {
              timerGakKetemuDriver = Timer.periodic(
                  Duration(seconds: 45), (Timer t) => gakKetemuDriver());
              Get.back();
            },
            constraints: BoxConstraints(),
            elevation: 1.0,
            fillColor: Colors.green,
            child: Text(
              'Coba cari 1x lagi',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Warna.putih),
            ),
            padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(33)),
            ),
          ),
        ],
      ),
    )..show();
  }

  void alertPerjalananSelesai() {
    var rating = 0.0;
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Image.asset(
            'images/nodriver.png',
            width: Get.width * 0.5,
          ),
          Text('PERJALANAN SELESAI',
              style: TextStyle(
                  fontSize: 18,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w600)),
          Text(
              'Terima kasih telah melakukan perjalanan bersama kami, Tolong berikan penilaian atas pelayanan driver kami',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center),
          Padding(padding: EdgeInsets.only(top: 9)),
          SmoothStarRating(
              allowHalfRating: false,
              color: Colors.amber,
              borderColor: Colors.amber,
              onRated: (v) {
                ratingDriver.value = v;
              },
              rating: rating,
              isReadOnly: false,
              filledIconData: Icons.star,
              halfFilledIconData: Icons.star_half,
              defaultIconData: Icons.star_border,
              starCount: 5,
              spacing: 0.0),
          Padding(padding: EdgeInsets.only(top: 9)),
          RawMaterialButton(
            onPressed: () {
              perjalananSelesai();
              Get.offAll(Dashboardku());
            },
            constraints: BoxConstraints(),
            elevation: 1.0,
            fillColor: Warna.warnautama,
            child: Text(
              'Selesaikan perjalanan',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Warna.putih),
            ),
            padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(33)),
            ),
          ),
        ],
      ),
    )..show();
  }

  var driverDipanggil = 0;

  cekStatusPengantaran() async {
    var cekin = await cekInternet();
    if (cekin == true) {
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');
      var kodetrx = c.kodeTransaksiMotor.value;
      var user = dbbox.get('loginSebagai');

      var datarequest = '{"pid":"$pid","kodetrx":"$kodetrx"}';
      var bytes = utf8.encode(datarequest + '$token' + user);
      var signature = md5.convert(bytes).toString();

      var url = Uri.parse(
          '${c.baseURLdriver}/mobileAppsUser/cekStatusPengantaranMobil');

      final response = await https.post(url, body: {
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
          // terhubung dengan driver
          timer?.cancel();
          timerCekStatus?.cancel();

          cekLokasidanOutlet();

          trackingGpsDriver();
        } else if (hasil['status'] == 'Driver tidak siap') {
          timer?.cancel();
          timerCekStatus?.cancel();
        }
      }
    }
  }

  void perjalananSelesai() async {
    var cekin = await cekInternet();
    if (cekin == true) {
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');
      var kodetrx = c.kodeTransaksiMotor.value;
      var v = ratingDriver.value;
      var user = dbbox.get('loginSebagai');

      var datarequest = '{"pid":"$pid","kodetrx":"$kodetrx","rating":"$v"}';
      var bytes = utf8.encode(datarequest + '$token' + user);
      var signature = md5.convert(bytes).toString();

      var url = Uri.parse(
          '${c.baseURLdriver}/mobileAppsUser/perjalananSelesaiUserMobil');

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
        if (hasil['status'] == 'success') {
          if (mounted) {
            Get.back();
          }
        } else if (hasil['status'] == 'failed') {
          AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.warning,
            animType: AnimType.rightSlide,
            title: 'PERHATIAN !',
            desc: hasil['message'],
          )..show();
        }
      }
    }
  }

  trackingGpsDriver() async {
    print('Opps sepertinya id driver belum ditemukan');

    var cekin = await cekInternet();
    if (!mounted) {
      timeLokasiGpsDriver?.cancel();
    }

    if (cekin == true) {
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');
      var kodetrx = c.kodeTransaksiMotor.value;
      var user = dbbox.get('loginSebagai');

      var datarequest = '{"pid":"$pid","kodetrx":"$kodetrx"}';
      var bytes = utf8.encode(datarequest + '$token' + user);
      var signature = md5.convert(bytes).toString();

      var url = Uri.parse(
          '${c.baseURLdriver}/mobileAppsUser/cekStatusdanLokasiMobil');

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
        if (hasil['status'] == 'success') {
          statusDriver.value = hasil['alasan'];
          latDriver = hasil['latDriver'];
          longDriver = hasil['longDriver'];
          tahapan = hasil['tahapan'];

          moveMapTo(latDriver, longDriver);
          setState(() {
            _markers.remove(_markers.firstWhere(
                (Marker marker) => marker.markerId.value == 'kurirpin'));
            _markers.add(Marker(
                markerId: MarkerId('kurirpin'),
                position: LatLng(latDriver, longDriver),
                icon: kuriricon));
          });

          if (tahapan == 5) {
            timeLokasiGpsDriver?.cancel();
            setState(() {
              btnSelesai.value = true;
            });
            alertPerjalananSelesai();
          }
        } else if (hasil['status'] == 'failed') {
          AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.warning,
            animType: AnimType.rightSlide,
            title: 'PERHATIAN !',
            desc: hasil['message'],
          )..show();
        }
      }
    }
  }

  gakKetemuDriver() {
    if (iddriver.value == '0') {
      timerGakKetemuDriver?.cancel();
      alertDriverTidakTersedia();
    } else {
      timerGakKetemuDriver?.cancel();
    }
  }
}
