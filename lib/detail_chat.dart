import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mondu_farm/utils/audio_chat/audio_chat_widget.dart';
import 'package:mondu_farm/utils/audio_chat/record_chat_widget.dart';
import 'package:mondu_farm/utils/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailChat extends StatefulWidget {
  const DetailChat(
      {Key? key,
      required this.idTernak,
      required this.kategori,
      required this.dataTernak})
      : super(key: key);
  final String idTernak;
  final String kategori;
  final Map<dynamic, dynamic> dataTernak;

  @override
  State<DetailChat> createState() => _DetailChatState();
}

class _DetailChatState extends State<DetailChat> {
  String idUser = "";

  Future<void> getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      idUser = pref.getString('id_user')!;
    });
  }

  Future<String> getImageFromStorage(String pathName, String kategori) {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage
        .ref()
        .child("ternak")
        .child(kategori.toLowerCase())
        .child(pathName);

    return ref.getDownloadURL();
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Chat"),
      ),
      body:
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  // margin: EdgeInsets.all(15),
                  child: FutureBuilder(
                    future: getImageFromStorage(widget.dataTernak['gambar'], widget.kategori),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return SizedBox(
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              snapshot.data!,
                              fit: BoxFit.fill,
                              // width: 125,
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Text("Terjadi Kesalahan");
                      }
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
                SizedBox(height: 10,),
                StreamBuilder(
                  stream: FirebaseDatabase.instance
                      .ref()
                      .child("pesan")
                      .child(idUser)
                      .child("${widget.idTernak}")
                      .child("data")
                      .orderByChild("metrics/tanggal")
                      .onValue,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && (snapshot.data!).snapshot.value != null) {
                      // Variable data mempermudah memanggil data pada database
                      Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
                          (snapshot.data! as DatabaseEvent).snapshot.value as Map<dynamic, dynamic>);

                      List<Map<dynamic, dynamic>> dataList = [];
                      data.forEach((key, value) {
                        // Setiap data yang di perulangkan bakal di simpan ke dalam list
                        final currentData = Map<String, dynamic>.from(value);
                        // Mensetting variable dengan total lembur dan gaji)
                        dataList.add({
                          'uid': key,
                          'durasi': currentData['durasi'],
                          'pesan': currentData['pesan'],
                          'pesan_dari': currentData['pesan_dari'],
                          'tanggal': currentData['tanggal'],
                          'type': currentData['type'],
                        });
                      });
                      dataList.sort((a, b) {
                        var aDate = DateTime.parse(a["tanggal"]);
                        var bDate = DateTime.parse(b["tanggal"]);
                        return aDate.compareTo(bDate);
                      });
                      return Expanded(
                        child: SingleChildScrollView(
                          reverse: true,
                          child: Column(
                              children: dataList.map((e) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              child: Row(
                                mainAxisAlignment: e['pesan_dari'] == "user" ? MainAxisAlignment.end : MainAxisAlignment.start,
                                children: <Widget>[
                                  AudioChatWidget(data: e),
                                ],
                              ),
                            );
                          }).toList()),
                        ),
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
              ],
            ),
          ),
      //     CustomScrollView(
      //   slivers: <Widget>[
      //     SliverAppBar(
      //       backgroundColor: Warna.ungu,
      //       expandedHeight: 200.0,
      //       floating: true,
      //       // Set to true if you want the app bar to be floating
      //       pinned: true,
      //       // Set to true if you want the app bar to be pinned
      //       flexibleSpace: FlexibleSpaceBar(
      //         // title: Text(widget.kategori),
      //         background: FutureBuilder(
      //           future: getImageFromStorage(
      //               widget.dataTernak['gambar'], widget.kategori),
      //           builder: (context, snapshot) {
      //             if (snapshot.hasData) {
      //               return Image.network(
      //                 snapshot.data!,
      //                 fit: BoxFit.cover,
      //                 // width: 125,
      //               );
      //             }
      //             if (snapshot.hasError) {
      //               return Text("Terjadi Kesalahan");
      //             }
      //             return Center(
      //               child: CircularProgressIndicator(),
      //             );
      //           },
      //         ),
      //       ),
      //     ),
      //     StreamBuilder(
      //       stream: FirebaseDatabase.instance
      //           .ref()
      //           .child("pesan")
      //           .child(idUser)
      //           .child("${widget.idTernak}")
      //           .child("data")
      //           .orderByChild("metrics/tanggal")
      //           .onValue,
      //       builder: (context, snapshot) {
      //         if (snapshot.hasData && (snapshot.data!).snapshot.value != null) {
      //           // Variable data mempermudah memanggil data pada database
      //           Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
      //               (snapshot.data! as DatabaseEvent).snapshot.value
      //                   as Map<dynamic, dynamic>);
      //
      //           List<Map<dynamic, dynamic>> dataList = [];
      //           data.forEach((key, value) {
      //             // Setiap data yang di perulangkan bakal di simpan ke dalam list
      //             final currentData = Map<String, dynamic>.from(value);
      //             // Mensetting variable dengan total lembur dan gaji)
      //             dataList.add({
      //               'uid': key,
      //               'durasi': currentData['durasi'],
      //               'pesan': currentData['pesan'],
      //               'pesan_dari': currentData['pesan_dari'],
      //               'tanggal': currentData['tanggal'],
      //               'type': currentData['type'],
      //             });
      //           });
      //           dataList.sort((a, b) {
      //             var aDate = DateTime.parse(a["tanggal"]);
      //             var bDate = DateTime.parse(b["tanggal"]);
      //             return aDate.compareTo(bDate);
      //           });
      //           return SliverList(
      //             delegate: SliverChildBuilderDelegate(
      //                 (BuildContext context, int index) {
      //               dataList.map((e) {
      //                 return Container(
      //                   margin: const EdgeInsets.symmetric(horizontal: 15),
      //                   child: Row(
      //                     mainAxisAlignment: e['pesan_dari'] == "user"
      //                         ? MainAxisAlignment.end
      //                         : MainAxisAlignment.start,
      //                     children: <Widget>[
      //                       AudioChatWidget(data: e),
      //                     ],
      //                   ),
      //                 );
      //               }).toList();
      //             }, childCount: dataList.length),
      //           );
      //           //   SingleChildScrollView(
      //           //   reverse: true,
      //           //   child: Column(
      //           //       children: dataList.map((e) {
      //           //         return Container(
      //           //           margin: const EdgeInsets.symmetric(horizontal: 15),
      //           //           child: Row(
      //           //             mainAxisAlignment: e['pesan_dari'] == "user" ? MainAxisAlignment.end : MainAxisAlignment.start,
      //           //             children: <Widget>[
      //           //               AudioChatWidget(data: e),
      //           //             ],
      //           //           ),
      //           //         );
      //           //       }).toList()),
      //           // );
      //         }
      //         if (snapshot.hasData) {
      //           return Center(
      //             child: Text("Belum ada pesan masuk"),
      //           );
      //         }
      //         return Center(
      //           child: CircularProgressIndicator(),
      //         );
      //       },
      //     ),
      //     // SliverList(
      //     //   delegate: SliverChildBuilderDelegate(
      //     //     (BuildContext context, int index) {
      //     //       return StreamBuilder(
      //     //         stream: FirebaseDatabase.instance
      //     //             .ref()
      //     //             .child("pesan")
      //     //             .child(idUser)
      //     //             .child("${widget.idTernak}")
      //     //             .child("data")
      //     //             .orderByChild("metrics/tanggal")
      //     //             .onValue,
      //     //         builder: (context, snapshot) {
      //     //           if (snapshot.hasData &&
      //     //               (snapshot.data!).snapshot.value != null) {
      //     //             // Variable data mempermudah memanggil data pada database
      //     //             Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
      //     //                 (snapshot.data! as DatabaseEvent).snapshot.value
      //     //                     as Map<dynamic, dynamic>);
      //     //
      //     //             List<Map<dynamic, dynamic>> dataList = [];
      //     //             data.forEach((key, value) {
      //     //               // Setiap data yang di perulangkan bakal di simpan ke dalam list
      //     //               final currentData = Map<String, dynamic>.from(value);
      //     //               // Mensetting variable dengan total lembur dan gaji)
      //     //               dataList.add({
      //     //                 'uid': key,
      //     //                 'durasi': currentData['durasi'],
      //     //                 'pesan': currentData['pesan'],
      //     //                 'pesan_dari': currentData['pesan_dari'],
      //     //                 'tanggal': currentData['tanggal'],
      //     //                 'type': currentData['type'],
      //     //               });
      //     //             });
      //     //             dataList.sort((a, b) {
      //     //               var aDate = DateTime.parse(a["tanggal"]);
      //     //               var bDate = DateTime.parse(b["tanggal"]);
      //     //               return aDate.compareTo(bDate);
      //     //             });
      //     //             return SingleChildScrollView(
      //     //               reverse: true,
      //     //               child: Column(
      //     //                   children: dataList.map((e) {
      //     //                 return Container(
      //     //                   margin: const EdgeInsets.symmetric(horizontal: 15),
      //     //                   child: Row(
      //     //                     mainAxisAlignment: e['pesan_dari'] == "user"
      //     //                         ? MainAxisAlignment.end
      //     //                         : MainAxisAlignment.start,
      //     //                     children: <Widget>[
      //     //                       AudioChatWidget(data: e),
      //     //                     ],
      //     //                   ),
      //     //                 );
      //     //               }).toList()),
      //     //             );
      //     //           }
      //     //           if (snapshot.hasData) {
      //     //             return Center(
      //     //               child: Text("Belum ada pesan masuk"),
      //     //             );
      //     //           }
      //     //           return Center(
      //     //             child: CircularProgressIndicator(),
      //     //           );
      //     //         },
      //     //       );
      //     //     },
      //     //     childCount: 1,
      //     //   ),
      //     // ),
      //   ],
      // ),
      bottomNavigationBar: SizedBox(
        height: 125,
        child: RecordChatWidget(
          idUser: idUser,
          idTernak: widget.idTernak,
          kategori: widget.kategori,
        ),
      ),
    );
  }
}
