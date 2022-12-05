import 'dart:async';
import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as https;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import '../mobil/pembayaranMobil.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;

class DimanaDijemputMobil extends StatefulWidget {
  @override
  _DimanaDijemputMobilState createState() => _DimanaDijemputMobilState();
}

class _DimanaDijemputMobilState extends State<DimanaDijemputMobil> {
  Box dbbox = Hive.box<String>('sasukaDB');
  final controllerHp = TextEditingController();

  Completer<GoogleMapController> _controller = Completer();
  BitmapDescriptor destinationIcon;

  List<Marker> _markers = [];

  LatLng currentLocation;
  LatLng destinationLocation;

  final c = Get.find<ApiService>();

  var dataSiap = false.obs;
  var outlet = ''.obs;
  var keterangan = 'Mohon tunggu'.obs;

  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];

  Timer timer;
  @override
  void initState() {
    super.initState();
    setSourceAndDestinationMarkerIcon();
    setInitialLocation();
    dataSiap.value = true;
    c.alamatJemputMobil.value = '';
    // timer = Timer.periodic(
    //     Duration(seconds: 8), (Timer t) => cekStatusPerPeriode());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void setSourceAndDestinationMarkerIcon() async {
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.0), 'images/JEMPUT.png');
  }

  void setInitialLocation() {
    destinationLocation = LatLng(c.latitude.value, c.longitude.value);
    c.tempLat.value = c.latitude.value;
    c.tempLong.value = c.longitude.value;
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: Text('Dimana dijemput ?'),
          backgroundColor: Colors.blue[900],
        ),
        bottomNavigationBar: SizedBox(
          height: Get.height * 0.13,
          child: Column(
            children: [
              Padding(padding: EdgeInsets.only(top: 7)),
              Row(
                children: [
                  Padding(padding: EdgeInsets.only(left: 11)),
                  SizedBox(
                    width: Get.width * 0.9,
                    child: Obx(() => Row(
                          children: [
                            (c.alamatJemput.value == '')
                                ? Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          color: Colors.grey, size: 30),
                                      Text(
                                        'Alamat Belum ditentukan',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.grey),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          color: Colors.blue[900], size: 30),
                                      SizedBox(
                                        width: Get.width * 0.75,
                                        child: Text(
                                          c.alamatJemput.value,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3,
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.blue[900]),
                                        ),
                                      ),
                                    ],
                                  )
                          ],
                        )),
                  ),
                ],
              ),
              SizedBox(
                width: Get.width * 0.8,
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue[900]),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    side: BorderSide(color: Colors.white)))),
                    onPressed: () {
                      if (c.alamatJemputMobil.value != '') {
                        c.latJemputMobil.value = c.tempLatJemput.value;
                        c.longJemputMobil.value = c.tempLongJemput.value;
                        Get.to(() => PembayaranPerjalananMobil());
                      } else {
                        Get.snackbar('Alamat Belum Ditentukan',
                            'Tentukan alamat penjemputan, Gunakan pencarian atau geser penanda pada peta',
                            snackPosition: SnackPosition.BOTTOM);
                      }
                    },
                    child: Text('Jemput disini')),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            (dataSiap.value == false)
                ? Container()
                : Container(
                    padding: EdgeInsets.only(top: Get.height * 0.11),
                    child: GoogleMap(
                        compassEnabled: false,
                        mapType: MapType.normal,
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                          showPinonMaps();
                        },
                        markers: _markers.toSet(),
                        polylines: _polylines,
                        initialCameraPosition: CameraPosition(
                            zoom: CAMERA_ZOOM,
                            tilt: CAMERA_TILT,
                            bearing: CAMERA_BEARING,
                            target: destinationLocation)),
                  ),
            Container(
              margin: EdgeInsets.fromLTRB(12, 5, 12, 12),
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      child: TextField(
                        style: TextStyle(fontSize: 22),
                        controller: controllerHp,
                        decoration: InputDecoration(
                            labelText: 'Atur lokasi penjemputan ?',
                            labelStyle: TextStyle(fontSize: 15),
                            prefixIcon: Icon(Icons.map),
                            suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.search,
                                  size: 33,
                                ),
                                onPressed: () {
                                  carilokasigoogle();
                                  Focus.of(Get.context).unfocus();
                                }),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(45))),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(padding: EdgeInsets.only(left: 11)),
                        SizedBox(
                          width: Get.width * 0.8,
                          child: Obx(() => Text(
                                c.alamatJemputMobil.value,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                                style: TextStyle(
                                    fontSize: 15, color: Colors.blue[900]),
                              )),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        )));
  }

  void showPinonMaps() {
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId('destinationpin'),
          draggable: true,
          onDragEnd: (LatLng ltng) async {
            onDragEnd(ltng);
          },
          position: destinationLocation,
          infoWindow: InfoWindow(
              title: 'Pilih lokasi penjemputan',
              snippet: 'Tap dan geser penanda ya'),
          icon: destinationIcon));
    });
  }

  void onDragEnd(ltng) async {
    c.alamatJemputMobil.value = 'Alamat ditentukan pada koordinat peta';
    c.tempLatJemput.value = ltng.latitude;
    c.tempLongJemput.value = ltng.longitude;
    controllerHp.text = '';

    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(c.tempLatJemput.value, c.tempLongJemput.value),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
  }

  void carilokasigoogle() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var latTujuan = c.latTujuanMobil.value;
    var longTujuan = c.longTujuanMobil.value;
    var cari = (controllerHp.text);
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","latTujuan":"$latTujuan","longTujuan":"$longTujuan","cari":"$cari"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLdriver}/mobileAppsUser/cekJemputMobil');

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
        c.tempLatJemput.value = hasil['latitude'];
        c.tempLongJemput.value = hasil['longitude'];

        c.ketJemputMobil.value = controllerHp.text;
        c.alamatJemputMobil.value = hasil['alamat'];
        c.latJemputMobil.value = hasil['latitude'];
        c.longJemputMobil.value = hasil['longitude'];

        setState(() {
          _markers.remove(_markers.firstWhere(
              (Marker marker) => marker.markerId.value == 'destinationpin'));

          _markers.add(Marker(
              markerId: MarkerId('destinationpin'),
              position: LatLng(c.tempLatJemput.value, c.tempLongJemput.value),
              icon: destinationIcon));
        });
        CameraPosition cPosition = CameraPosition(
          zoom: CAMERA_ZOOM,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING,
          target: LatLng(c.tempLatJemput.value, c.tempLongJemput.value),
        );
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
      } else if (hasil['status'] == 'not found') {
        c.alamatJemputMobil.value = '';
      } else if (hasil['status'] == 'diluar jangkauan') {
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          title: '',
          desc: '',
          body: Column(
            children: [
              Image.asset(
                'images/noorder.png',
                width: Get.width * 0.5,
              ),
              Text('DILUAR JANGKAUAN',
                  style: TextStyle(
                      fontSize: 18,
                      color: Warna.warnautama,
                      fontWeight: FontWeight.w600)),
              Text(
                  'Sepertinya tujuan kamu terlalu jauh, cari lokasi terdekat ya... Pengantaran kami maksimal  30 Km',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center),
              Padding(padding: EdgeInsets.only(top: 9)),
            ],
          ),
        )..show();
      }
    }
  }
}
