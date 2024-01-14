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
  final String url;
  final String kategori;

  const DetailTernak(
      {Key? key, required this.url, required this.kategori, required this.uid})
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
  }

  Future<void> getUserFromFirebase() async {
    try {
      FirebaseDatabase.instance
          .ref()
          .child("users")
          .child(id_user)
          .onValue
          .listen((event) {
        var snapshot = event.snapshot.value as Map;
        nama = snapshot['nama'];
        no_telepon = snapshot['no_telepon'];
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    playVoiceover("Lakukan Negosiasi atau Booking langsung");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.latar,
      ),
        backgroundColor: Warna.latar,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 15),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.url,
                      fit: BoxFit.fill,
                    ),
                  ),
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
                    if (snapshot.hasData &&
                        (snapshot.data!).snapshot.value != null) {
                      Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
                          (snapshot.data! as DatabaseEvent).snapshot.value
                              as Map<dynamic, dynamic>);
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                  child: DetailInfo(
                                      icon: "assets/icon_umur.png",
                                      value: data['usia'].toString())),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  child: DetailInfo(
                                icon: "assets/icon_tinggi.png",
                                value: "${data['tinggi'].toString()} M",
                              )),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          DetailInfo(
                            icon: "assets/icon_bobot.png",
                            value: "${data['berat'].toString()} Kg",
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          DetailInfo(
                              icon: "assets/icon_harga.png",
                              value: currencyFormatter.format(
                                data['harga'],
                              )),
                          SizedBox(
                            height: 40,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(
                                          Colors.purple)),
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
                                  icon: Image.asset("assets/icon_chat.png")),
                              IconButton(
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(
                                          Colors.purple)),
                                  onPressed: () {
                                    playVoiceover("Apakah anda yakin?");
                                    Alerts.showAlertYesNo(
                                      onPressYes: () async {
                                        Booking.insert(context, {
                                          "id_user": id_user,
                                          'nama': nama,
                                          'no_telepon': no_telepon,
                                          'id_ternak': widget.uid,
                                          'kategori': widget.kategori,
                                          'tanggal_booking':
                                              DateTime.now().toString(),
                                          'status_booking': "Sedang Di Booking",
                                        });
                                      },
                                      onPressNo: () {
                                        Navigator.pop(context);
                                      },
                                      context: context,
                                    );
                                  },
                                  icon: Image.asset("assets/icon_booking.png")),
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
}

class DetailInfo extends StatelessWidget {
  final String icon;
  final String value;

  const DetailInfo({
    super.key,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        // width: 150,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: Colors.purple,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                bottomLeft: Radius.circular(50),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.asset(icon, height: 60),
            Text(
              value,
              style: TextStyle(fontSize: 30, color: Colors.white),
            )
          ],
        ));
  }
}
