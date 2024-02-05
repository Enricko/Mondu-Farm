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
  String formatteddate(String date) {
    var formatteddate = DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
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
        centerTitle: true,
        backgroundColor: Warna.latar,
      ),
      backgroundColor: Warna.latar,
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
                    Image.asset("assets/id-card.png", width: 50),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: 170,
                      decoration: BoxDecoration(
                          color: Warna.tersier,
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Center(child: Text(widget.nama,style: TextStyle(color: Colors.black),)),
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
                  Image.asset("assets/phones.png", width: 50),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 170,

                    decoration: BoxDecoration(
                        color: Warna.tersier,
                      borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Center(child: Text(widget.no_telepon,style: TextStyle(color: Colors.black),)),
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
                            child: Image.network(
                              data["urlGambar"],
                              // "assets/model_sapi.png",
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        // Row(
                        //   children: [
                        //     Expanded(
                        //         child: DetailInfo(
                        //             icon: "assets/icon_umur.png", value: "${data['umur']}")),
                        //     SizedBox(
                        //       width: 10,
                        //     ),
                        //     Expanded(
                        //         child: DetailInfo(
                        //             icon: "assets/icon_bobot.png",
                        //             value: "${data['berat']}")),
                        //   ],
                        // ),
                        DetailInfo(
                            icon: "assets/trend.png",
                            height: 65,
                            value: "${data['umur']} Tahun"),
                        DetailInfo(
                            icon: "assets/scale.png",
                            height: 60,
                            value: "${data['berat']} Kg"),
                        DetailInfo(
                            icon: "assets/roll.png",
                            height: 60,
                            value: "${data['tinggi']} Meter"),
                        DetailInfo(
                            icon: "assets/money2.png",
                            height: 60,
                            value: "${data['harga']}"),
                        DetailInfo(
                            icon: "assets/calendar.png",
                            height: 65,
                            value: "${formatteddate(data['tanggal_booking'])}"),
                        DetailInfo(
                            icon: "assets/icon_truk.png",
                            value:
                                "${formatteddate(DateTime.parse(data['tanggal_booking']).add(Duration(days: 2)).toString())}"),
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
