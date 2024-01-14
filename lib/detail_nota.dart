import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/intl.dart';
import 'package:mondu_farm/detail_ternak.dart';
import 'package:mondu_farm/utils/color.dart';

class DetailNota extends StatefulWidget {
  final String idUser;
  final String idNota;
  final String nama;
  final String no_telepon;

  const DetailNota(
      {Key? key,
      required this.nama,
      required this.no_telepon,
      required this.idUser,
      required this.idNota})
      : super(key: key);

  @override
  State<DetailNota> createState() => _DetailNotaState();
}

class _DetailNotaState extends State<DetailNota> {
  formatteddate(String date) {
    var formatteddate =
    DateFormat('d MMMM y', 'id_ID').format(DateTime.parse(date));
    return formatteddate;
  }

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Nota"),
        centerTitle: true,
        backgroundColor: Warna.latar,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset("assets/icon_nama.png", width: 50),
                    SizedBox(
                      width: 5,
                    ),
                    Container(
                      width: 170,
                      color: Warna.abuabu,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Center(child: Text(widget.nama)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/icon_notelepon.png", width: 50),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                    width: 170,
                    color: Warna.abuabu,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Center(child: Text(widget.no_telepon)),
                  ),
                ],
              ),
              StreamBuilder(
                stream: FirebaseDatabase.instance
                    .ref()
                    .child("nota")
                    .child(widget.idUser)
                    .child(widget.idNota)
                    .onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      (snapshot.data!).snapshot.value != null) {
                    Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
                        (snapshot.data! as DatabaseEvent).snapshot.value
                        as Map<dynamic, dynamic>);
                    print(data['tanggal_booking']);
                    return Column(
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          width: width,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              "assets/model_sapi.png",
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: DetailInfo(
                                    icon: "assets/icon_umur.png", value: "${data['umur']}")),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: DetailInfo(
                                    icon: "assets/icon_bobot.png",
                                    value: "${data['berat']}")),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        DetailInfo(
                            icon: "assets/icon_tinggi.png", value: "${data['tinggi']}"),
                        SizedBox(
                          height: 10,
                        ),
                        DetailInfo(
                            icon: "assets/icon_harga.png", value: "${data['harga']}"),
                        SizedBox(
                          height: 10,
                        ),
                        DetailInfo(
                            icon: "assets/icon_kalender.png", value: "${data['tanggal_booking']}"),
                        SizedBox(
                          height: 10,
                        ),
                        DetailInfo(
                            icon: "assets/icon_truk.png", value: "${DateTime.parse(data['tanggal_booking']).add(Duration(days: 2))}"),
                      ],
                    );
                  }
                  ;
                  if (snapshot.hasData) {
                    return Center(
                      child: Text("Kosong"),
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
