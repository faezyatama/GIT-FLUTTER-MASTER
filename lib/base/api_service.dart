import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ApiService extends GetxController {
  //----------------------------------------------------//
  //BERDASARKAN MASING-MASING APLIKASI
  //----------------------------------------------------//
  var versiApkSaarini = '1.0.5';
  //----------------------------------------------------//
  var namaAplikasi = 'LUNAS APPS';
  var ssAwalPengganti = 'LUNAS APPS';
  var baseURL = 'https://core.koperasilunas.com';
  var packageName = 'com.lunas.online';
  var baseURLDeepLink = 'https://my.dcn-indonesia.com/lunas/';
  var baseURLplaystore =
      'https://play.google.com/store/apps/details?id=com.lunas.online';

  var fitUsp = "YA";
  var jenisKoperasi = "KSP";
  var bigMenu = false;
  var gabungMenuAngkutan = true;
  var gabungMenuMarketplace = true;

  var sebutanUntukMitra = 'Bangun Bisnis Online';
  var sebutanUntukMitra2 = 'Jadilah mitra usaha bersama kami';

  var nNamafitPulsa = 'Pulsa HP';
  var nNamafitPln = 'Token PLN';
  var nNamafitEmoney = 'E-money';
  var nNamafitPPob = 'PPOB';
  var nNamafitGame = 'VoucherGame'; //'Pandu Voucher';
  var nNamafitTosek = 'Lunas UMKM'; //'Teman Pandu';
  var nNamafitMobil = 'Mobil'; //'Pandu Mobil';
  var nNamafitMotor = 'Motor'; // 'Pandu Motor';
  var nNamafitPickup = 'Angkutan'; // 'Pandu Angkut';
  var nNamafitMakan = 'Makanan'; // 'Dapur Pandu';
  var nNamafitFreshmart = 'Freshmart'; // 'Pasar Pandu';
  var nNamafitMarketplace = 'Marketplace'; //'Kedai Pandu';
  var nNamafitTv = 'TV Berlangganan'; //'Kedai Pandu';
  var nNamafitSiPi = 'Simpan Pinjam'; //'Kedai Pandu';
  var nNamafitGabungAngkutan = 'Lunas Transport'; //'Kedai Pandu';
  var nNamafitGabungMarketplace = 'Lunas Market'; //'Kedai Pandu';

  //simpan pinjan
  var idsimpanan = 0;
  var idpinjaman = 0;
  var jenisSimpanan = 'Simpanan Umum';
  var jenisPinjaman = 'Pinjaman Umum';
  var simpananPilihan = 'Simpanan Umum';
  var pinjamanPilihan = 'Pinjaman Umum';
  var nomorRekeningPilihan = '';
  var imageTTD = '';

  var fileKTP = ''.obs;
  var fileKTPIstri = ''.obs;
  var fileSelfiKTP = ''.obs;
  var filePasFoto = ''.obs;

  var fileBerkas1 = ''.obs;
  var fileBerkas2 = ''.obs;
  var fileBerkas3 = ''.obs;
  var fileBerkas4 = ''.obs;

  var fileKTPDisplay = 'https://images.sasuka.online/umum/ktp.png'.obs;
  var fileKTPIstriDisplay = 'https://images.sasuka.online/umum/ktp.png'.obs;
  var fileSelfiKTPDisplay = 'https://images.sasuka.online/umum/selfie.png'.obs;
  var filePasFotoDisplay = 'https://images.sasuka.online/umum/pasfoto.jpg'.obs;

  var fileBerkasDisplay1 =
      'https://images.sasuka.online/umum/uploadberkas.jpg'.obs;
  var fileBerkasDisplay2 =
      'https://images.sasuka.online/umum/uploadberkas.jpg'.obs;
  var fileBerkasDisplay3 =
      'https://images.sasuka.online/umum/uploadberkas.jpg'.obs;
  var fileBerkasDisplay4 =
      'https://images.sasuka.online/umum/uploadberkas.jpg'.obs;
  var fileBerkasDisplay5 =
      'https://images.sasuka.online/umum/uploadberkas.jpg'.obs;

  var notifMakan = 'Makanan'.obs; // 'Dapur Pandu'.obs;
  var notifFreshmart = 'Freshmart'.obs; // 'Pasar Pandu'.obs;
  var notifMarketplace = 'Marketplace'.obs; //'Kedai Pandu'.obs;

  var namaAwalPengganti = 'Selamat Datang di Aplikasi Terintegrasi';
  var scrool = 'Selamat Datang di Aplikasi Terintegrasi';
  var judul1 = 'Aplikasi Multifungsi Untuk Kamu'.obs;
  var judul1sub =
      'Nikmati berbagai kemudahan dalam bertansaksi menggunakan Aplikasi Multifungsi'
          .obs;

  var judulMarketplaceText = 'Banyak Pilihan Tersedia'.obs;
  var marketplaceText =
      'Dengan berbagai fitur extra kamu bisa memilih berbagai kebutuhanmu disini'
          .obs;
  var judulFreshmartText = 'Freshmart'.obs;
  var freshmartText = 'Belanja Sayur mayur dipasar hanya dari rumah'.obs;

  var judulMakananText = 'Makanan Online'.obs;
  var makananText =
      'Pilih kategori makanan kesukaanmu, dan makanan favorit segera datang'
          .obs;

  var judul3 = 'Perbanyak Transaksi dan Dapatkan Poin'.obs;
  var judul3sub = 'Tukarkan poin kamu dengan berbagai hadiah menarik'.obs;
  var judul4 = 'Lindungi Data Kamu'.obs;
  var judul4sub =
      'Jaga kerahasiaan data kamu dengan menjaga PIN dan Password'.obs;

  //-------------------------------------------------------------------------
  //-------------------------------------------------------------------------
  //-------------------------------------------------------------------------
  var baseURLdriver = 'https://driver.satuaja.id';
  var baseURLmakan = 'https://makan.satuaja.id';
  var baseURLfreshmart = 'https://freshmart.satuaja.id';
  var baseURLmp = 'https://belanjaaja.satuaja.id';
  var baseURLtokosekitar = 'https://apk.tokosekitar.com';
  var baseURLchat = 'https://chat.satuaja.id';
  var sipokAnggota = 'Rp. 0,-';
  var siwaAnggota = 'Rp. 0,-';
  var defaultMyShool = false;
  //-------------------------------------------------------------------------
  var kodePembayaranVoucher = '';
  var tabsaatini = 2.obs;
  var requestPassword = ''.obs;
  var requestPasswordHP = ''.obs;
  var otpPass = '';
  List daftarMenuUtama = [];
  var mitraFreshmart = '0'.obs;
  var mitraTokosekitar = '0'.obs;
  var mitraTransportasi = '0'.obs;
  var mitraMarketplace = '0'.obs;
  var mitraMakanan = '0'.obs;
  var mitraReferal = '0'.obs;
  var mainmenuloaddata = '';
  var splashLink = '';
  var iklanSplash = '';
  var appid = '';
  var splashTampil = '';
  var judul4gambar = ''.obs;
  var judul3gambar = ''.obs;
  var versiTerbaru = '';
  var debug1aja = 'DeepLink initialized'.obs;
  var cekLoginStatus = 'loading'.obs;

  var timerDashboardUtama = true.obs;
  var timerDashboardDriver = true.obs;
  var timerDetailPesananBarangIntegrasi = true.obs;
  var timerDaftarAntaranIntegrasi = true.obs;

  var sedangTampilButuhGPS = false.obs;
  var sedangTampilNoInternet = false.obs;

  var foto = ''.obs;
  var namaPenggunaKita = ''.obs;
  var ssPenggunaKita = ''.obs;
  var loginAsPenggunaKita = ''.obs;
  var saldo = ''.obs;
  var saldoInt = 0.obs;
  var pointReward = 0.obs;
  var voucherBelanja = '0'.obs;
  var nomorAnggota = ''.obs;
  var clLogo = ''.obs;
  var cl = 0.obs;
  var shu = ''.obs;
  var pokok = ''.obs;
  var wajib = ''.obs;
  var autoDebetWajib = 0.obs;
  var bank = ''.obs;
  var btnwajib = ''.obs;
  var btnpokok = ''.obs;
  var norek = ''.obs;
  var npwp = ''.obs;
  var pinStatus = ''.obs;
  var pinBlokir = ''.obs;
  var pinUnblock = 'Pin lama'.obs;
  var pinReff = ''.obs;
  var kirimkeSS = ''.obs;
  var scrollTextSHU = ''.obs;
  var tglTerakhirSplash = ''.obs;
  var besarinGambar = ''.obs;
  var besarinGambarNama = ''.obs;

  //REGISTER OTP
  var hpOTP = ''.obs;

  //CETAK BLUETOOTH
  var hargaCetak = 'Rp.0'.obs;
  var kodeCetak = ''.obs;
  var barisCetak1 = ''.obs;
  var barisCetak2 = ''.obs;
  var barisCetak3 = ''.obs;
  var barisCetak4 = ''.obs;
  var barisCetak5 = ''.obs;
  var barisCetak6 = ''.obs;
  var barisCetak7 = ''.obs;
  var barisCetak8 = ''.obs;

  //PAYMENT PINT
  var paymentID = ''.obs;

  //STATE NAVIGATION BAR
  var selectedIndexBar = 2.obs;
  var pesananIndexBar = ''.obs;
  var antarinIndexBar = ''.obs;
  var chatIndexBar = ''.obs;
  var keranjangIndexbar = ''.obs;
  var notifIndexbar = ''.obs;

  var pesananStatus = 'Pesanan Berlangsung'.obs;
  var indexTabPesanan = 0.obs;

  var notifPayment = 0.obs;

  var notifKurirIntegrasi = 0.obs;
  var notifKurirUmum = 0.obs;
  var notifOjek = 0.obs;
  var kodeJualPengantaranDriver = ''.obs;
  var buttonTerimaOrderKurir = false.obs;
  var telahTerimaOrder = false.obs;

  //LOCATION SERVICE
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;
  var tempLat = 0.0.obs;
  var tempLong = 0.0.obs;
  var tempLatJemput = 0.0.obs;
  var tempLongJemput = 0.0.obs;
  var izinLokasi = Hive.box<String>('sasukaDB').get('izinLokasi').obs;

  //AGENSI
  var namaAgensi = ''.obs;
  var kodeAgensi = ''.obs;
  var alamatAgensi = ''.obs;
  var kotaAgensi = ''.obs;
  var jumlahAgen = '0'.obs;
  var akumulasiPendapatanAgensi = 'Rp.0'.obs;
  var pilihanDetailPelanggan = ''.obs;

  var pertanyaanKeamanan = 'No Access to Question'.obs;
  var jumlahTopup = ''.obs;
  var jumlahTopupCopy = ''.obs;
  var tanggalTopup = ''.obs;
  var logobankTopup = ''.obs;
  var kodetrxTopup = ''.obs;
  var requestTopup = 'tidak'.obs;
  var bankTopup = ''.obs;
  var atasNamaTopup = ''.obs;
  var noRekTopup = ''.obs;
  var bankTersedia = ''.obs; //bank yang tersedia untuk topup
  var follower = '0'.obs;
  var follow = '0'.obs;
  var refferal = 1.obs;
  var pidpilihan = 0.obs;
  var driverAktif = 0.obs;
  var reloadDriver = false;

  //LISENSIn POS
  var dataCetakStruk = [];
  var tanggalPOS = '';
  var bayarRp = '';
  var kembaliRp = '';
  var totalRp = '';
  var nomorTransaksiPOS = '';
  var kodeOutletPOS = '';
  var namaTokoPOS = '';
  var alamatTokoPOS = '';

//PULSA DAN PPOB
  var pulsadetail = ''.obs;
  var operatorpilihan = ''.obs;
  var kodepulsa = ''.obs;
  var detailpulsa = ''.obs;

  var kategoriPPOB = ''.obs;
  var produk = ''.obs;
  var logoPPOB = ''.obs;
  var subProduk = ''.obs;
  var logosubproduk = 'https://sasuka.online/icon/SPEEDY.png'.obs;
  var kodeppob = ''.obs;

  //OUTLET MAKAN
  var idOutletPilihan = ''.obs;
  var namaOutlet = ''.obs;
  var jumlahItem = 0.obs;
  var hargaKeranjang = 0.obs;
  var namaoutletpadakeranjang = 'Pesanan kamu'.obs;
  var idOutletpadakeranjangMakan = '0'.obs;
  var keranjangMakan = [].obs;
  var jumlahBarang = 0.obs;
  var ongkirMakan = 0.obs;
  var pilihanKurir = 'kurir'.obs;
  var alamatKirim = ''.obs;

  //TEMP DASHBOARD
  var refmakanDashboard = '';
  var reffreshmartDashboard = '';
  var refmarketplaceDashboard = '';
  var refiklanatas = '';
  var refiklantengah = '';

  var namaPreview = ''.obs;
  var gambarPreview = ''.obs;
  var gambarPreviewhiRess = ''.obs;
  var namaoutletPreview = ''.obs;
  var hargaPreview = ''.obs;
  var lokasiPreview = ''.obs;
  var itemidPreview = 0.obs;
  var deskripsiPreview = ''.obs;

  var alamatKirimNasionalSaveAs = ''.obs;
  var alamatKirimNasional = ''.obs;
  var alamatKirimNasionalKec = ''.obs;
  var alamatKirimNasionalKab = ''.obs;
  var alamatKirimNasionalIDKec = ''.obs;
  var alamatKirimNasionalPenerima = ''.obs;
  var expedisiNasionalDipilih = ''.obs;
  var hargaexpedisiNasionalDipilih = 0.obs;

  var iddrivermakan = 0.obs;
  var kodetransaksimakan = ''.obs;

  var stMasukMK = 'Masuk'.obs;
  var stProsesMK = 'Proses'.obs;
  var stKirimMK = 'Kirim'.obs;
  bool perhitunganHppMakan = false;
  bool perhitunganStokMakan = false;

  //FRESHMART
  var idOutletPilihanFm = ''.obs;
  var namaOutletFm = ''.obs;
  var jumlahItemFm = 0.obs;
  var hargaKeranjangFm = 0.obs;
  var namaoutletpadakeranjangFm = 'Pesanan kamu'.obs;
  var idOutletpadakeranjangFm = '0'.obs;
  var keranjangFm = [].obs;
  var jumlahBarangFm = 0.obs;
  var ongkirFm = 0.obs;
  var pilihanKurirFm = 'kurir'.obs;
  var alamatKirimFm = ''.obs;
  var iddriverFm = 0.obs;
  var kodetransaksiFm = ''.obs;

  var namaPreviewFM = ''.obs;
  var gambarPreviewFM = ''.obs;
  var gambarPreviewFMhiRess = ''.obs;
  var namaoutletPreviewFM = ''.obs;
  var hargaPreviewFM = ''.obs;
  var lokasiPreviewFM = ''.obs;
  var itemidPreviewFM = 0.obs;
  var deskripsiPreviewFM = ''.obs;

  var stMasukFM = 'Masuk'.obs;
  var stProsesFM = 'Proses'.obs;
  var stKirimFM = 'Kirim'.obs;
  bool perhitunganHppFreshmart = false; //false
  bool perhitunganStokFreshmart = false;

  //MARKETPLACE
  var idOutletPilihanMP = ''.obs;
  var namaOutletMP = ''.obs;
  var jumlahItemMP = 0.obs;
  var hargaKeranjangMP = 0.obs;
  var namaoutletpadakeranjangMP = 'Pesanan kamu'.obs;
  var idOutletpadakeranjangMP = '0'.obs;
  var keranjangMP = [].obs;
  var jumlahBarangMP = 0.obs;
  var ongkirMP = 0.obs;
  var pilihanKurirMP = 'kurir'.obs;
  var alamatKirimMP = ''.obs;
  var iddriverMP = 0.obs;
  var kodetransaksiMP = ''.obs;
  var ekspedisiNasional = false.obs;
  var hargaKeranjangMPTotal = 0.obs;

  //TOKO SEKITAR USER
  var idOutletPilihanTOSEK = 0.obs;
  var namaOutletTOSEK = ''.obs;
  var jumlahItemTOSEK = 0.obs;
  var hargaKeranjangTOSEK = 0.obs;
  var namaoutletpadakeranjangTOSEK = 'Pesanan kamu'.obs;
  var idOutletpadakeranjangTOSEK = 0.obs;
  var keranjangTOSEK = [].obs;
  var jumlahBarangTOSEK = 0.obs;
  var ongkirTOSEK = 0.obs;
  var pilihanKurirTOSEK = 'kurir'.obs;
  var alamatKirimTOSEK = ''.obs;
  var iddriverTOSEK = 0.obs;
  var kodetransaksiTOSEK = ''.obs;
  var ekspedisiNasionalTOSEK = false.obs;
  var hargaKeranjangTOSEKTotal = 0.obs;
  var kodePembayaranTOSEK = ''.obs;

  //SELECT MP
  var namaTOSEKC = ''.obs;
  var gambarTOSEKC = ''.obs;
  var gambarTOSEKChiRess = ''.obs;
  var tagIdTOSEKC = ''.obs;
  var namaoutletTOSEKC = ''.obs;
  var hargaTOSEKC = ''.obs;
  var lokasiTOSEKC = ''.obs;
  var deskripsiTOSEKC = ''.obs;
  var hargaIntTOSEKC = 0.obs;
  var beratTOSEKC = ''.obs;
  var idOutletTOSEKC = ''.obs;
  var itemIdTOSEKC = ''.obs;
  var dataResponseTokoTOSEKC = ''.obs;
  var dataResponseIdTokoTOSEKC = 0.obs;

  var stMasukMP = 'Masuk'.obs;
  var stProsesMP = 'Proses'.obs;
  var stKirimMP = 'Kirim'.obs;
  bool perhitunganHppMarketplace = false;
  bool perhitunganStokMarketplace = false;

  //PENGIRIMAN NASIONAL

  //SELECT MP
  var namaMPC = ''.obs;
  var gambarMPC = ''.obs;
  var gambarMPChiRess = ''.obs;
  var tagIdMPC = ''.obs;
  var namaoutletMPC = ''.obs;
  var hargaMPC = ''.obs;
  var lokasiMPC = ''.obs;
  var deskripsiMPC = ''.obs;
  var hargaIntMPC = 0.obs;
  var beratMPC = ''.obs;
  var idOutletMPC = ''.obs;
  var itemIdMPC = ''.obs;
  var dataResponseTokoMPC = ''.obs;
  var dataResponseIdTokoMPC = ''.obs;

  //OJEK MOTOR
  var ketTujuan = ''.obs;
  var alamatTujuan = ''.obs;
  var latTujuan = 0.0.obs;
  var longTujuan = 0.0.obs;
  var hargaPerjalananMotor = 'Rp. 0,-'.obs;
  var hargaIntPerjalananMotor = 0.obs;

  var ketJemput = ''.obs;
  var alamatJemput = ''.obs;
  var latJemput = 0.0.obs;
  var longJemput = 0.0.obs;
  var arrIdDriver = [].obs;
  var kodeTransaksiMotor = ''.obs;

  //OJEK MOBIL
  var ketTujuanMobil = ''.obs;
  var alamatTujuanMobil = ''.obs;
  var latTujuanMobil = 0.0.obs;
  var longTujuanMobil = 0.0.obs;
  var hargaPerjalananMobil = 'Rp. 0,-'.obs;
  var hargaIntPerjalananMobil = 0.obs;

  var ketJemputMobil = ''.obs;
  var alamatJemputMobil = ''.obs;
  var latJemputMobil = 0.0.obs;
  var longJemputMobil = 0.0.obs;
  var arrIdDriverMobil = [].obs;
  var kodeTransaksiMobil = ''.obs;

  //OJEK PICKUP
  var ketTujuanPickup = ''.obs;
  var alamatTujuanPickup = ''.obs;
  var latTujuanPickup = 0.0.obs;
  var longTujuanPickup = 0.0.obs;
  var hargaPerjalananPickup = 'Rp. 0,-'.obs;
  var hargaIntPerjalananPickup = 0.obs;

  var ketJemputPickup = ''.obs;
  var alamatJemputPickup = ''.obs;
  var latJemputPickup = 0.0.obs;
  var longJemputPickup = 0.0.obs;
  var arrIdDriverPickup = [].obs;
  var kodeTransaksiPickup = ''.obs;

  //TIKET
  var urlTiket = 'https://tiket-sasuka.com'.obs;
  var urlchatScsTamu = ''.obs;

  //chat
  var idChatLawan = '0'.obs;
  var namaChatLawan = ''.obs;
  var fotoChatLawan = ''.obs;
  var statusChatLawan = 'Waiting'.obs;

  //RITZUKA
  var idritzukapilihan = 0.obs;
  var fotoritzpilihan = ''.obs;
  var namaritzPilihan = ''.obs;
  var alamatRitzPilihan = ''.obs;
  var unitRitzPilihan = '0 unit'.obs;
  var totalUmpRitzPilihan = 'Rp.0'.obs;

  var idCekOutRitzuka = 0.obs;
  var fotoCekOutRitzuka = ''.obs;
  var namaCekOutRitzuka = ''.obs;
  var alamatCekOutRitzuka = ''.obs;
  var hargaDevCekOutRitzuka = ''.obs;
  var persenCekOutRitzuka = ''.obs;
  var satuanCekOutRitzuka = ''.obs;
  var umpmasukCekOutRitzuka = ''.obs;
  var tahapanCekOutRitzuka = ''.obs;
  var maxCekOutRitzuka = 0.obs;
  var hargaIntCekOutRitzuka = 0.obs;
  var totalBayarCekoutRitzuka = 0.obs;
  var spmpkopPilihan = ''.obs;

  //OUTLET UMUM
  var picProduk1 = 'noimage.jpg'.obs;
  var picProduk2 = 'noimage.jpg'.obs;
  var picProduk3 = 'noimage.jpg'.obs;
  var picProduk4 = 'noimage.jpg'.obs;
  var picProduk5 = 'noimage.jpg'.obs;
  var picProduk6 = 'noimage.jpg'.obs;
  var uploadTo = ''.obs;

  //MAKAN
  var latOutletMakanku = 0.0.obs;
  var longOutletMakanku = 0.0.obs;
  var adaOutletMakan = 'Tidak Ada'.obs;
  var namaOutletMakan = ''.obs;
  var alamatOutletMakan = ''.obs;
  var kabupatenMakan = ''.obs;
  var deskripsiMakan = ''.obs;
  var kunjunganMakan = ''.obs;
  var terjualMakan = ''.obs;
  var produkMakan = ''.obs;
  var selectedIndexMakanan = 0.obs;
  var selectedIndexOrderMakanan = 0.obs;
  var itemEditPilihan = '0'.obs;

  //FM

  var latOutletFMKU = 0.0.obs;
  var longOutletFMKU = 0.0.obs;
  var adaOutletFMKU = 'Tidak Ada'.obs;
  var namaOutletFMKU = ''.obs;
  var alamatOutletFMKU = ''.obs;
  var kabupatenFMKU = ''.obs;
  var deskripsiFMKU = ''.obs;
  var kunjunganFMKU = ''.obs;
  var terjualFMKU = ''.obs;
  var produkFMKU = ''.obs;
  var selectedIndexFMKU = 0.obs;
  var selectedIndexOrderFMKU = 0.obs;
  var itemEditPilihanFMKU = '0'.obs;

  var helper2 = ''.obs;
  var helper5 = ''.obs;
  var helper7 = ''.obs;

  //toko SEKITAR
  var namaOutletTracking = ''.obs;
  var lisensiTS = 'Waiting'.obs;
  var versiTosek = ''.obs; //STANDART / PREMIUM / WEB BASE

  var latOutletTSKU = 0.0.obs;
  var longOutletTSKU = 0.0.obs;
  var adaOutletTSKU = ''.obs;
  var namaOutletTSKU = ''.obs;
  var alamatOutletTSKU = ''.obs;
  var kabupatenTSKU = ''.obs;
  var deskripsiTSKU = ''.obs;
  var kunjunganTSKU = ''.obs;
  var terjualTSKU = ''.obs;
  var produkTSKU = ''.obs;
  var selectedIndexTSKU = 0.obs;
  var selectedIndexOrderTSKU = 0.obs;
  var itemEditPilihanTSKU = '0'.obs;
  var pilihanSupplierTS = 'Supplier Umum'.obs;
  var idPilihanOutletTS = 0.obs;
  var kodePembelianTokoSekitar = ''.obs;
  var kodePenjualanTokoSekitar = ''.obs;
  var logoTokoSekitar = ''.obs;

  //MP
  var latOutletMPKU = 0.0.obs;
  var longOutletMPKU = 0.0.obs;
  var adaOutletMPKU = 'Tidak Ada'.obs;
  var namaOutletMPKU = ''.obs;
  var alamatOutletMPKU = ''.obs;
  var kabupatenMPKU = ''.obs;
  var deskripsiMPKU = ''.obs;
  var kunjunganMPKU = ''.obs;
  var terjualMPKU = ''.obs;
  var produkMPKU = ''.obs;
  var selectedIndexMPKU = 0.obs;
  var selectedIndexOrderMPKU = 0.obs;
  var itemEditPilihanMPKU = '0'.obs;

  //DRIVER
  var dashboardDriver = 0.obs;
  var fotoKtpDriver = 'noimage.png'.obs;
  var fotoSimDriver = 'noimage.png'.obs;
  var fotoStnkDriver = 'noimage.png'.obs;
  var fotoProfilDriver = 'no-avatar2.png'.obs;
  var antaranIntegrasi = 0.obs;
  var antaranOjek = 0.obs;
  var kodeTransaksiIntegrasi = ''.obs;
  var kodeTransaksiKurirUmum = ''.obs;
  var kodeTransaksiOjek = ''.obs;
  var tahapanOjek = ''.obs;
  var keteranganButtonOjek = ''.obs;
  var btnOnlineOffline = ''.obs;
}
