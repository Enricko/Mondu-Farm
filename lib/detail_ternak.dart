import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:mondu_farm/booking.dart';
import 'package:mondu_farm/detail_chat.dart';
import 'package:mondu_farm/success.dart';
import 'package:mondu_farm/utils/alerts.dart';
import 'package:mondu_farm/utils/color.dart';
import 'package:mondu_farm/utils/custom_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailTernak extends StatefulWidget {
  final String uid;
  final String url1;
  final String url2;
  final String url3;
  final String kategori;

  const DetailTernak(
      {Key? key,
      required this.url1,
      required this.kategori,
      required this.uid,
      required this.url2,
      required this.url3})
      : super(key: key);

  @override
  State<DetailTernak> createState() => _DetailTernakState();
}

class _DetailTernakState extends State<DetailTernak> {
  final FlutterTts flutterTts = FlutterTts();
  String id_user = "";
  String nama = "";
  String no_telepon = "";

  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Future<void> playVoiceover(String text) async {
    await flutterTts.setLanguage("id-ID");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVoice({"name": "Karen", "locale": "id-ID"});

    await flutterTts.speak(text);
  }

  Future<void> getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      id_user = pref.getString('id_user')!;
    });
    setState(() {
      getUserFromFirebase();
    });
    playVoiceover("Maiwa melalui tawar menawar ndang langsung tek");
  }

  Future<void> getUserFromFirebase() async {
    try {
      FirebaseDatabase.instance.ref().child("users").child(id_user).onValue.listen((event) {
        var snapshot = event.snapshot.value as Map;
        nama = snapshot['nama'];
        no_telepon = snapshot['no_telepon'];
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<DataSnapshot> fetchList() async {
    const path = 'SET YOUR PATH HERE';
    return await FirebaseDatabase.instance.ref(path).get();
  }

  // List listImg = [];
  //
  // String? url1;
  // String? url2;
  // String? url3;

  List listUrl = [];

  // getImageUrl() async {
  //   FirebaseStorage storage = FirebaseStorage.instance;
  //   Reference ref1 =
  //       storage.ref().child("ternak").child(widget.kategori.toLowerCase()).child(widget.url1);
  //   Reference ref2 =
  //       storage.ref().child("ternak").child(widget.kategori.toLowerCase()).child(widget.url2);
  //   Reference ref3 =
  //       storage.ref().child("ternak").child(widget.kategori.toLowerCase()).child(widget.url3);
  //   var url1 = await ref1.getDownloadURL();
  //   var url2 = await ref2.getDownloadURL();
  //   var url3 = await ref3.getDownloadURL();

  //   listUrl.add(url1);
  //   listUrl.add(url2);
  //   listUrl.add(url3);
  // }
  Future<String> getImageUrl(String url) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("ternak").child(widget.kategori.toLowerCase()).child(url);
    var getUrl = await ref.getDownloadURL();
    return getUrl;
  }

  @override
  void initState() {
    super.initState();
    getPref();
    // FirebaseStorage storage = FirebaseStorage.instance;
    // Reference ref1 = storage.ref().child("ternak").child(widget.kategori.toLowerCase()).child("gambar_1");
    // Reference ref2 = storage.ref().child("ternak").child(widget.kategori.toLowerCase()).child("gambar_2");
    // Reference ref3 = storage.ref().child("ternak").child(widget.kategori.toLowerCase()).child("gambar_3");
    // url1 = ref1.getDownloadURL();
    // url2 = ref2.getDownloadURL();
    // url3 = ref3.getDownloadURL();
    // listImg.add(
    //   {
    //     "gambar_1" : widget.url1,
    //     "gambar_2" : widget.url2,
    //     "gambar_3" : widget.url3,
    //   }
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.latar,
      ),
      backgroundColor: Warna.latar,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FutureBuilder(
                        future: getImageUrl(widget.url1),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Image.network(
                              snapshot.data!,
                              fit: BoxFit.fill,
                            );
                          }
                          
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }),
                  ),
                ),
                // FutureBuilder(
                //     future:,
                //     builder: builder
                // ),
                CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: true,
                    aspectRatio: 2.0,
                    enlargeCenterPage: true,
                  ),
                  items: listUrl
                      .map((item) => Container(
                            child: Container(
                              margin: EdgeInsets.all(5.0),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  child: Stack(
                                    children: <Widget>[
                                      Image.network(item.toString(),
                                          fit: BoxFit.cover, width: 1000.0),
                                    ],
                                  )),
                            ),
                          ))
                      .toList(),
                ),
                SizedBox(
                  height: 15,
                ),
                StreamBuilder(
                  stream: FirebaseDatabase.instance
                      .ref()
                      .child("ternak")
                      .child(widget.kategori.toLowerCase())
                      .child(widget.uid)
                      .onValue,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && (snapshot.data!).snapshot.value != null) {
                      Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
                          (snapshot.data! as DatabaseEvent).snapshot.value
                              as Map<dynamic, dynamic>);
                      return Column(
                        children: [
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                          //   children: [
                          //     Expanded(
                          //         child: DetailInfo(
                          //             icon: "assets/icon_umur.png",
                          //             value: data['usia'].toString(),
                          //           height: 70,
                          //         ),
                          //     ),
                          //     SizedBox(
                          //       width: 10,
                          //     ),
                          //     Expanded(
                          //       child: DetailInfo(
                          //         icon: "assets/icon_bobot.png",
                          //         value: "${data['berat'].toString()} Kg",
                          //         height: 70,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          DetailInfo(
                            icon: "assets/trend.png",
                            value: "${data['usia'].toString()} Tahun",
                            height: 65,
                          ),
                          DetailInfo(
                            icon: "assets/scale.png",
                            value: "${data['berat'].toString()} Kg",
                            height: 60,
                          ),
                          DetailInfo(
                            icon: "assets/roll.png",
                            value: "${data['tinggi'].toString()} Meter",
                            height: 60,
                          ),
                          DetailInfo(
                            icon: "assets/money2.png",
                            value: currencyFormatter.format(
                              data['harga'],
                            ),
                            height: 60,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                  style: ButtonStyle(
                                      padding: MaterialStateProperty.all(
                                          EdgeInsets.fromLTRB(18, 10, 18, 18)),
                                      backgroundColor: MaterialStateProperty.all(Warna.secondary)),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailChat(
                                          idTernak: snapshot.data!.snapshot.key!,
                                          kategori: widget.kategori,
                                          dataTernak: data,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: SizedBox(
                                      height: 80, child: Image.asset("assets/icon_chat2.png"))),
                              IconButton(
                                  style: ButtonStyle(
                                      padding: MaterialStateProperty.all(
                                          EdgeInsets.fromLTRB(18, 10, 18, 18)),
                                      backgroundColor: MaterialStateProperty.all(Warna.secondary)),
                                  onPressed: () {
                                    playVoiceover("apakah  nyum yakin?");
                                    Alerts.showAlertYesNo(
                                      url: "assets/lottie/booking.json",
                                      onPressYes: () async {
                                        Booking.insert(context, {
                                          "id_user": id_user,
                                          'nama': nama,
                                          'no_telepon': no_telepon,
                                          'id_ternak': widget.uid,
                                          'url_gambar': widget.url1,
                                          'kategori': widget.kategori,
                                          'tanggal_booking':
                                              // "2024-01-14 14:22:29.368050",
                                              DateTime.now().toString(),
                                          // DateTime.now().subtract(Duration(days: 3)).toString(), // Testing
                                          'status_booking': "Sedang Di Booking",
                                        });
                                      },
                                      onPressNo: () {
                                        Navigator.pop(context);
                                      },
                                      context: context,
                                    );
                                  },
                                  icon: SizedBox(
                                      height: 80, child: Image.asset("assets/shopping-cart1.png"))),
                            ],
                          )
                        ],
                      );
                    }
                    if (snapshot.hasData) {
                      return Center(
                          child: Text(
                        "Ternak Tidak Tersedia",
                      ));
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> imageSliders(List imgList) => imgList
      .map((item) => Container(
            child: Container(
              margin: EdgeInsets.all(5.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: Stack(
                    children: <Widget>[
                      Image.network(item, fit: BoxFit.cover, width: 1000.0),
                    ],
                  )),
            ),
          ))
      .toList();
}

class DetailInfo extends StatelessWidget {
  final String icon;
  final String value;
  final double? height;

  const DetailInfo({
    super.key,
    required this.icon,
    required this.value,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ClipOval(
                child: Container(
                    width: 80.0,
                    // Adjust the width and height as needed
                    height: 80.0,
                    padding: EdgeInsets.all(height! - 50),
                    color: Warna.secondary,
                    child: Image.asset(
                      icon,
                      //     height: height,
                      // width:height,
                    ))),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: TextFormField(
                initialValue: value,
                style: TextStyle(color: Colors.black),
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Warna.tersier,
                  // hintText: "Mond**",
                  // hintStyle: const TextStyle(
                  //   color: Color(0xFF696F79),
                  //   fontSize: 14,
                  //   fontFamily: 'Poppins',
                  //   fontWeight: FontWeight.w400,
                  // ),
                  isDense: true,
                  contentPadding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(width: 1, color: Color(0xFFDEDEDE)),
                  ),
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
    // Container(
    //   // width: 150,
    //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    //   decoration: BoxDecoration(
    //       color: Colors.purple,
    //       borderRadius: BorderRadius.only(
    //           topLeft: Radius.circular(50),
    //           bottomLeft: Radius.circular(50),
    //           topRight: Radius.circular(20),
    //           bottomRight: Radius.circular(20))),
    //   child: Row(
    //     mainAxisAlignment: MainAxisAlignment.spaceAround,
    //     children: [
    //       Image.asset(icon, height: height),
    //       Expanded(
    //         child: FittedBox(
    //           fit: BoxFit.scaleDown,
    //           child: Text(
    //             value,
    //             style: TextStyle(fontSize: 30, color: Colors.white),
    //           ),
    //         ),
    //       )
    //     ],
    //   ));
  }
}
