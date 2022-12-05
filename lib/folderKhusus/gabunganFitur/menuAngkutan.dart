import 'dart:async';
// ignore: import_of_legacy_library_into_null_safe
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:satuaja/base/warna.dart';
import '../../dashboard/view/mainmenu.dart';
import '/base/api_service.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;

class GabunganFiturAngkutan extends StatefulWidget {
  @override
  _GabunganFiturAngkutanState createState() => _GabunganFiturAngkutanState();
}

class _GabunganFiturAngkutanState extends State<GabunganFiturAngkutan> {
  Box dbbox = Hive.box<String>('sasukaDB');
  final controllerHp = TextEditingController();

  Completer<GoogleMapController> _controller = Completer();
  BitmapDescriptor destinationIcon;

  List<Marker> _markers = [];

  LatLng currentLocation;
  LatLng destinationLocation;

  final c = Get.find<ApiService>();
  var latPenerima = -7.7;
  var longPenerima = 110.4;
  var latKurir = 0.0;
  var longKurir = 0.0;
  var latOutlet = 0.0;
  var longOutlet = 0.0;
  var dataSiap = false.obs;

  var outlet = ''.obs;
  var keterangan = 'Mohon tunggu'.obs;

  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  static double ukuranicon = 60;
  var lebar = 0.3;
  var myGroup = AutoSizeGroup();

  Timer timer;
  @override
  void initState() {
    super.initState();
    setSourceAndDestinationMarkerIcon();
    setInitialLocation();
    dataSiap.value = true;
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void setSourceAndDestinationMarkerIcon() async {
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.0), 'images/TUJUAN.png');
  }

  void setInitialLocation() {
    c.alamatTujuanMobil.value = '';
    destinationLocation = LatLng(c.latitude.value, c.longitude.value);
    c.tempLat.value = c.latitude.value;
    c.tempLong.value = c.longitude.value;
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: Text(
            c.nNamafitGabungAngkutan,
          ),
          backgroundColor: Warna.warnautama,
        ),
        bottomNavigationBar: SizedBox(
          height: Get.height * 0.25,
          child: Column(
            children: [
              Padding(padding: EdgeInsets.only(top: Get.height * 0.05)),
              Text(
                  'Mau kemana aja semakin mudah dengan layanan transportasi ' +
                      c.namaAplikasi,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Warna.warnautama,
                    fontSize: 18,
                    fontWeight: FontWeight.w200,
                  )),
              Padding(padding: EdgeInsets.only(top: 11)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      cekDuluTransaksiMobil();
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          'images/whitelabelMainMenu/mobil.png',
                          width: ukuranicon,
                        ),
                        AutoSizeText(
                          c.nNamafitMobil,
                          style: TextStyle(color: Warna.grey),
                          group: myGroup,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      cekDuluTransaksiMotor();
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          'images/whitelabelMainMenu/samotor.png',
                          width: ukuranicon,
                        ),
                        AutoSizeText(
                          c.nNamafitMotor,
                          style: TextStyle(color: Warna.grey),
                          group: myGroup,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      cekDuluTransaksiPickup();
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          'images/whitelabelMainMenu/pickup.png',
                          width: ukuranicon,
                        ),
                        AutoSizeText(
                          c.nNamafitPickup,
                          style: TextStyle(color: Warna.grey),
                          group: myGroup,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            (dataSiap.value == false)
                ? Container()
                : Container(
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
          ],
        )));
  }

  void showPinonMaps() {
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId('destinationpin'),
          draggable: true,
          onDragEnd: (LatLng ltng) async {
            print('woke');
            onDragEnd(ltng);
          },
          position: destinationLocation,
          infoWindow: InfoWindow(
              title: 'Pilih lokasi Tujuan',
              snippet: 'Tap dan geser penanda ya'),
          icon: destinationIcon));
    });
  }

  void onDragEnd(ltng) async {
    c.alamatTujuanMobil.value = 'Alamat ditentukan pada koordinat peta';
    c.tempLat.value = ltng.latitude;
    c.tempLong.value = ltng.longitude;
    controllerHp.text = '';

    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(c.tempLat.value, c.tempLong.value),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
  }
}
