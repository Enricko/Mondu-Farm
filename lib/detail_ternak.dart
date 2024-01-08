import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mondu_farm/success.dart';
import 'package:mondu_farm/utils/alerts.dart';

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
  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Image.network(
                    widget.url,
                    fit: BoxFit.contain,
                  )),
              SizedBox(
                height: 10,
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
                              value: data['tinggi'].toString(),
                            )),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        DetailInfo(
                          icon: "assets/icon_bobot.png",
                          value: data['berat'].toString(),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        DetailInfo(
                            icon: "assets/icon_harga.png",
                            value: currencyFormatter.format(
                              data['harga'],
                            )),
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
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.purple)),
                      onPressed: () {},
                      icon: Image.asset("assets/icon_chat.png")),
                  IconButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.purple)),
                      onPressed: () {
                        Alerts.showAlertYesNo(
                          onPressYes: () async {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => Success(),
                              ),
                              (route) => false,
                            );
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
