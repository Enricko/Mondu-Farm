import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mondu_farm/utils/color.dart';
import 'package:mondu_farm/utils/custom_extension.dart';
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
    Reference ref = storage
        .ref()
        .child("ternak")
        .child(kategori.toLowerCase())
        .child(pathName);

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
        backgroundColor: Warna.latar,
      ),
      backgroundColor: Warna.latar,
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseDatabase.instance
              .ref()
              .child("pesan")
              .child(idUser)
              // .child("-Nnm_V8tHL_EsqxSsCxd")  -Hanya Untuk Testing
              .onValue,
          builder: (context, snapshot) {
            if (snapshot.hasData && (snapshot.data!).snapshot.value != null) {
              // Variable data mempermudah memanggil data pada database
              Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
                  (snapshot.data! as DatabaseEvent).snapshot.value
                      as Map<dynamic, dynamic>);

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
                  Future<Map<dynamic, dynamic>>? dataTernak = FirebaseDatabase
                      .instance
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
                        return Column(
                          children: [
                            ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailChat(
                                      idTernak: dataList[index]['uid'],
                                      kategori: dataList[index]['kategori'],
                                      dataTernak: data,
                                    ),
                                  ),
                                );
                              },
                              trailing: Icon(Icons.arrow_forward_ios),
                              tileColor: Colors.black12,
                              leading: SizedBox(
                                width: 125,
                                height: 50,
                                child: FutureBuilder(
                                  future: getImageFromStorage(data['gambar'],
                                      dataList[index]['kategori']),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Image.network(
                                        snapshot.data!,
                                        height: 130,
                                        fit: BoxFit.fill,
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
                              subtitle: Row(
                                children: [
                                  Column(
                                    children: [
                                      Image.asset(
                                        "assets/icon_umur.png",
                                        height: 20,
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Image.asset("assets/icon_tinggi.png",
                                          height: 20),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Image.asset("assets/icon_bobot.png",
                                          height: 20),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Image.asset("assets/icon_harga.png",
                                          height: 20),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${data['usia']} Tahun",
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text("${data['tinggi']} Meter"),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text("${data['berat']} Kg"),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        "${currencyFormatter.format(data['harga'])}",
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            )
                          ],
                        );
                      }
                      return Column(
                        children: [
                          ListTile(
                            onTap: null,
                            trailing: Icon(Icons.arrow_forward_ios),
                            tileColor: Colors.black12,
                            leading: SizedBox(
                              width: 125,
                              height: 50,
                              child: Image.asset("assets/placeholder.png"),
                            ),
                            subtitle: Row(
                              children: [
                                Column(
                                  children: [
                                    Image.asset(
                                      "assets/icon_umur.png",
                                      height: 20,
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Image.asset("assets/icon_tinggi.png",
                                        height: 20),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Image.asset("assets/icon_bobot.png",
                                        height: 20),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Image.asset("assets/icon_harga.png",
                                        height: 20),
                                  ],
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      " - Tahun",
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(" - Meter"),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(" - Kg"),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      "Rp -",
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          )
                        ],
                      );
                    },
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
      ),
    );
  }
}
