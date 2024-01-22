import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mondu_farm/detail_nota.dart';
import 'package:mondu_farm/utils/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListBooking extends StatefulWidget {
  const ListBooking({Key? key}) : super(key: key);

  @override
  State<ListBooking> createState() => _ListBookingState();
}

class _ListBookingState extends State<ListBooking> {
  String id_user = "";

  Future<void> getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      id_user = pref.getString('id_user')!;
    });
  }

  String formatteddate(String date) {
    var formatteddate =
        DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
    return formatteddate;
  }

   iconKategori(String kategori){
    switch(kategori){
      case 'sapi':{
       return Image.asset("assets/icon_sapi.png",height: 50,alignment: Alignment.topLeft);
      }
      case 'kuda':{
       return Image.asset("assets/icon_kuda.png",height: 50,alignment: Alignment.topLeft,);
      }
      case 'kerbau':{
        return Image.asset("assets/icon_kerbau.png",height: 50,alignment: Alignment.topLeft);
      }
      case 'kambing':{
        return Image.asset("assets/icon_kambing.png",height: 50,alignment: Alignment.topLeft,);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Warna.latar),
      backgroundColor: Warna.latar,
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref().child("booking").onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && (snapshot.data!).snapshot.value != null) {
            Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
                (snapshot.data! as DatabaseEvent).snapshot.value
                    as Map<dynamic, dynamic>);
            List<Map<dynamic, dynamic>> dataList = [];
            data.forEach((key, value) {
              final currentData = Map<String, dynamic>.from(value);
              dataList.add({
                'id_user': currentData['id_user'],
                'nama': currentData['nama'],
                'no_telepon': currentData['no_telepon'],
                'kategori': currentData['kategori'],
                'tanggal_booking': currentData['tanggal_booking'],
                'id_nota': currentData['id_nota']
              });
            });
            List<Map<dynamic, dynamic>> filteredList =
                dataList.where((entry) => entry['id_user'] == id_user).toList();
            if (filteredList.isNotEmpty) {
              return ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        title: iconKategori(filteredList[index]["kategori"].toString().toLowerCase()),
                        subtitle: Row(
                          children: [
                            Image.asset("assets/icon_kalender2.png",height: 30),
                            SizedBox(width: 10,),
                            Text("${formatteddate(filteredList[index]["tanggal_booking"].toString())}"),
                          ],
                        ),

                        trailing: (filteredList[index]['id_nota'] == "null")
                            ? Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CircleAvatar(
                                    backgroundColor: Warna.ungu,
                                    child: Icon(Icons.sync,color: Colors.white,)),
                                SizedBox(width: 15,)
                              ],
                            )
                            : ElevatedButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Warna.ungu)),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (ctx) => DetailNota(
                                                nama: filteredList[index]
                                                    ['nama'],
                                                no_telepon:
                                                    filteredList[index]
                                                        ['no_telepon'],
                                                idUser: id_user,
                                                idNota: filteredList[index]
                                                    ['id_nota'],
                                              )));
                                },
                                child: Icon(Icons.file_copy,color: Colors.white,)),
                      ),
                      Divider(
                        color: Colors.black,
                        indent: 10,
                        endIndent: 10,
                      )
                    ],
                  );
                },
              );
            } else {
              return Center(
                child: Text("Kosong"),
              );
            }
          }
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
    );
  }
}
