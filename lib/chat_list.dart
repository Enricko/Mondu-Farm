import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'detail_chat.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  String idUser = "";
  Future<void> getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      idUser = pref.getString('id_user')!;
    });
  }

  Future<String> getImageFromStorage(String pathName, String kategori) {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("ternak").child(kategori.toLowerCase()).child(pathName);

    return ref.getDownloadURL();
  }

  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List Chat"),
      ),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref().child("pesan").child("-Nnm_V8tHL_EsqxSsCxd").onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && (snapshot.data!).snapshot.value != null) {
            // Variable data mempermudah memanggil data pada database
            Map<dynamic, dynamic> data =
                Map<dynamic, dynamic>.from((snapshot.data! as DatabaseEvent).snapshot.value as Map<dynamic, dynamic>);

            List<Map<dynamic, dynamic>> dataList = [];
            data.forEach((key, value) {
              // Setiap data yang di perulangkan bakal di simpan ke dalam list
              final currentData = Map<String, dynamic>.from(value);
              // Mensetting variable dengan total lembur dan gaji)
              dataList.add({
                'uid': key,
                'data': currentData['data'],
                'kategori': currentData['kategori'],
                'last_chat_user': currentData['last_chat_user'],
              });
            });
            dataList.sort((a, b) {
              var aDate = DateTime.parse(a["last_chat_user"]);
              var bDate = DateTime.parse(b["last_chat_user"]);
              return aDate.compareTo(bDate);
            });
            return ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                return Column(
                  children: dataList.map(
                    (e) {
                      Future<Map<dynamic, dynamic>>? dataTernak = FirebaseDatabase.instance
                          .ref()
                          .child("ternak")
                          .child("${dataList[index]["kategori"]}")
                          .child("${dataList[index]["uid"]}")
                          .get()
                          .then((value) {
                        return value.value as Map<dynamic, dynamic>;
                      });
                      return FutureBuilder(
                          future: dataTernak,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var data = snapshot.data!;
                              return ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailChat(
                                        idTernak: dataList[index]['uid'],
                                        kategori: dataList[index]['kategori'],
                                      ),
                                    ),
                                  );
                                },
                                trailing: Icon(Icons.arrow_forward_ios),
                                tileColor: Colors.black12,
                                title: Text("Sapi"),
                                leading: FutureBuilder(
                                  future: getImageFromStorage(data['gambar'], dataList[index]['kategori']),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Image.network(
                                        snapshot.data!,
                                        width: 125,
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
                                subtitle: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                              "assets/icon_umur.png",
                                              height: 20,
                                            ),
                                            Text(
                                              "${data['usia']}",
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          width: 25,
                                        ),
                                        Row(
                                          children: [
                                            Image.asset("assets/icon_tinggi.png", height: 20),
                                            Text("${data['tinggi']}")
                                          ],
                                        ),
                                        SizedBox(
                                          width: 25,
                                        ),
                                        Row(
                                          children: [
                                            Image.asset("assets/icon_bobot.png", height: 20),
                                            Text("${data['berat']}")
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    Row(
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset("assets/icon_harga.png", height: 20),
                                            Text(
                                              "${currencyFormatter.format(data['harga'])}",
                                              maxLines: 3,
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          });
                    },
                  ).toList(),
                );
              },
            );
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
