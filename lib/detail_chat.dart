import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mondu_farm/utils/audio_chat/audio_chat_widget.dart';
import 'package:mondu_farm/utils/audio_chat/record_chat_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailChat extends StatefulWidget {
  const DetailChat({Key? key}) : super(key: key);

  @override
  State<DetailChat> createState() => _DetailChatState();
}

class _DetailChatState extends State<DetailChat> {
  String id_user = "";
  Future<void> getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      id_user = pref.getString('id_user')!;
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail Chat"),),
        body: StreamBuilder(
          stream: FirebaseDatabase.instance.ref().child("pesan").child("-NnJThg-A5k5iNE8Z1VT").onValue,
          builder: (context, snapshot) {
            if (snapshot.hasData && (snapshot.data!).snapshot.value != null) {
              // Variable data mempermudah memanggil data pada database
              Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
                  (snapshot.data! as DatabaseEvent).snapshot.value as Map<dynamic, dynamic>);

              // List<Map<dynamic, dynamic>> dataList = [];
              // data.forEach((key, value) {
              //   // Setiap data yang di perulangkan bakal di simpan ke dalam list
              //   final currentData = Map<String, dynamic>.from(value);
              //   // Mensetting variable dengan total lembur dan gaji)
              //   dataList.add({
              //     'uid': key,
              //     'durasi': currentData['durasi'],
              //     'pesan': currentData['pesan'],
              //     'pesan_dari': currentData['pesan_dari'],
              //     'tanggal': currentData['tanggal'],
              //     'type': currentData['type'],
              //   });
              // });
              // dataList.sort((a, b) {
              //   var aDate = DateTime.parse(a["tanggal"]);
              //   var bDate = DateTime.parse(b["tanggal"]);
              //   return aDate.compareTo(bDate);
              // });
              return SingleChildScrollView(
                reverse: true,
                child: Column(
                    children: data.entries.map((e) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment:
                          e.value['pesan_dari'] == "admin" ? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: <Widget>[
                            AudioChatWidget(data: e.value, maxDurasi: durationStringToDouble(e.value['durasi']))
                          ],
                        ),
                      );
                    }).toList()),
              );
            }
            if (snapshot.hasData) {
              return Center(
                child: Text("Belum ada pesan masuk"),
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
        // CustomScrollView(
        //   slivers: <Widget>[
        //     SliverAppBar(
        //       expandedHeight: 200.0,
        //       floating: true,
        //       // Set to true if you want the app bar to be floating
        //       pinned: true,
        //       // Set to true if you want the app bar to be pinned
        //       flexibleSpace: FlexibleSpaceBar(
        //         title: Text('SliverAppBar Example'),
        //         background: Image.asset(
        //           'assets/sapi.jpg',
        //           fit: BoxFit.cover,
        //         ),
        //       ),
        //     ),
        //     StreamBuilder(
        //         stream: FirebaseDatabase.instance
        //             .ref()
        //             .child("pesan")
        //             .child("-NnJThg-A5k5iNE8Z1VT")
        //             .onValue,
        //         builder: (context, snapshot) {
        //           if (snapshot.hasData &&
        //               (snapshot.data!).snapshot.value != null) {
        //             // Variable data mempermudah memanggil data pada database
        //             Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
        //                 (snapshot.data! as DatabaseEvent).snapshot.value
        //                     as Map<dynamic, dynamic>);
        //             return SliverList(
        //               delegate: SliverChildBuilderDelegate(
        //                 (BuildContext context, int index) {
        //                   data.entries.map((e) {
        //                     return Container(
        //                       margin: const EdgeInsets.symmetric(horizontal: 15),
        //                       child: Row(
        //                         mainAxisAlignment:
        //                         e.value['pesan_dari'] == "admin" ? MainAxisAlignment.end : MainAxisAlignment.start,
        //                         children: <Widget>[
        //                           AudioChatWidget(data: e.value, maxDurasi: durationStringToDouble(e.value['durasi']))
        //                         ],
        //                       ),
        //                     );
        //                   }).toList();
        //                 },
        //                 childCount: 20,
        //               ),
        //             );
        //           }
        //           if (snapshot.hasData) {
        //             return Center(
        //               child: Text("Belum ada pesan masuk"),
        //             );
        //           }
        //           return Center(
        //             child: CircularProgressIndicator(),
        //           );
        //
        //         }),
        //   ],
        // ),
        bottomNavigationBar: RecordChatWidget(idUser: id_user,),
        // Container(
        //   padding: EdgeInsets.fromLTRB(10, 17, 10, 20),
        //   color: Colors.green,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     children: [
        //       IconButton(
        //           style: ButtonStyle(
        //               backgroundColor: MaterialStateProperty.all(Color(0xFFA095DE))),
        //           onPressed: () {},
        //           icon: Icon(
        //             Icons.mic,
        //             size: 35,
        //           )),
        //       SizedBox(width: 5,),
        //       IconButton(
        //           style: ButtonStyle(
        //               backgroundColor: MaterialStateProperty.all(Color(0xFFA095DE))),
        //           onPressed: () {},
        //           icon: Icon(
        //             Icons.send,
        //             size: 35,
        //           ))
        //     ],
        //   ),
        // )
    );
  }

  double durationStringToDouble(String durasi) {
    double durationDouble = 1.0;
    String durationString = durasi; // Example duration string in mm:ss:SS format

    List<String> parts = durationString.split(':');

    // Assuming the string format is "mm:ss:SS"
    int minutes = int.parse(parts[0]);
    int seconds = int.parse(parts[1]);
    int milliseconds = int.parse(parts[2]);

    // Convert the duration to a double representation in milliseconds
    durationDouble = (minutes * 60 * 1000) + (seconds * 1000) + milliseconds as double;
    return durationDouble;
  }
}
