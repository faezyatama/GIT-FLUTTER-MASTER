import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '/screen1/login.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );

    return MaterialApp(
      title: 'Introduction screen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: OnBoardingPage(),
    );
  }
}

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  Box dbbox = Hive.box<String>('sasukaDB');

  final introKey = GlobalKey<IntroductionScreenState>();

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      // descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "Aplikasi Dengan Segudang Fitur",
          body: "Aplikasi dengan segudang fitur ",
          image: Image.asset(
            'images/whitelabelRegister/a.png',
            height: 300,
            width: Get.width * 0.51,
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Jalan-Jalan yuk",
          body:
              "Sekarang mau liburan lebih mudah, kamu bisa pesan tiket pesawat, kereta api, hotel, kapal pelni, dan berbagai transportasi online melalui aplikasi ini. ",
          image: Image.asset('images/whitelabelRegister/b.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Pusat Belanja dan Bisnis",
          body:
              "Cari barang menjadi lebih mudah dengan disini, kamupun bisa juga berjualan  dengan jangkauan di seluruh Indonesia.",
          image: Image.asset('images/whitelabelRegister/c.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Belanja mudah dari rumah.. ",
          body:
              "Tak perlu keluar rumah lagi.. tinggal ambil HP kamu, dan pesan berbagai kebutuhan kamu disini",
          image: Image.asset('images/whitelabelRegister/d.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Belanja Aman ",
          body:
              "Tenang aja, kamu bisa berbelanja dengan aman dengan aplikasi kami.. Jadi gak perlu khawatir dengan penipuan.",
          image: Image.asset('images/whitelabelRegister/e.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Tingkatkan pendapatan",
          body:
              "Tingkatkan transaksi kamu bersama kami. Di sini semakin banyak yang belanja, semakin besar penghasilan yang kamu dapatkan.",
          image: Image.asset('images/whitelabelRegister/f.png'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () {
        dbbox.put('introScreen', 'Sudah pernah buka intro');
        Get.off(LoginPage());
      },
      onSkip: () {
        // print('object');
        dbbox.put('introScreen', 'Sudah pernah buka intro');
        Get.off(LoginPage());
      }, // You can override onSkip callback
      showSkipButton: true,
      // skipFlex: 0,
      nextFlex: 0,
      skip: const Text('Login'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
