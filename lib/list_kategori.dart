import 'dart:ffi';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mondu_farm/detail_ternak.dart';
import 'package:mondu_farm/utils/custom_extension.dart';

class CategoryList extends StatefulWidget {
  final String kategori;
  const CategoryList({Key? key, required this.kategori,}) : super(key: key);

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {

  final FlutterTts flutterTts = FlutterTts();


  Future<String> getImageFromStorage(String pathName) {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("ternak").child(widget.kategori.toLowerCase()).child(pathName);

    return ref.getDownloadURL();
  }

  Future<void> playVoiceover(String text) async {
    await flutterTts.setLanguage("id-ID");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);

    await flutterTts.speak(text);
  }
  @override
  Widget build(BuildContext context) {
    playVoiceover('Silahkan memilih ${widget.kategori} yang di inginkan');
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.kategori.title()}"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10,),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20,),
              SizedBox(
                width: double.infinity,
                child: Card(
                  child: Image.asset("assets/banner_category.png",fit: BoxFit.fill,),
                ),
              ),
              SizedBox(height: 20,),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseDatabase.instance
                      .ref()
                      .child("ternak")
                  .child(widget.kategori.toLowerCase())
                      .onValue,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && (snapshot.data!).snapshot.value != null) {
                      Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
                          (snapshot.data! as DatabaseEvent).snapshot.value as Map<dynamic, dynamic>);
                      List<Map<dynamic, dynamic>> dataList = [];
                      data.forEach((key, value) {
                        final currentData = Map<String, dynamic>.from(value);
                          dataList.add({
                            'key': key,
                            'gambar': currentData['gambar'],
                            'usia': currentData['usia'],
                            'tinggi': currentData['tinggi'],
                            'berat': currentData['berat'],
                            'harga': currentData['harga'],
                          });
                      });
                      if (dataList.length != 0) {
                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Number of columns
                            crossAxisSpacing: 5, // Spacing between columns
                            mainAxisSpacing: 5, // Spacing between rows
                          ),
                          itemCount: dataList.length, // Number of items
                          itemBuilder: (context, index){
                            return FutureBuilder(
                              future: getImageFromStorage(dataList[index]['gambar']),
                              builder: (context,snapshot) {
                                if (snapshot.hasData) {
                                  return GestureDetector(
                                      onTap: (){
                                        Navigator.push(context, MaterialPageRoute(builder: (ctx) => DetailTernak(url: snapshot.data!, kategori: widget.kategori.toLowerCase(), uid: dataList[index]['key'],)));
                                      },
                                      child: Card(
                                          child: Image.network( snapshot.data!,fit: BoxFit.fill)));
                                }
                                if (snapshot.hasError) {
                                  return Text("Terjadi Kesalahan");
                                }
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );
                          },
                        );
                      }
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
