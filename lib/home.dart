import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mondu_farm/booking.dart';
import 'package:mondu_farm/list_booking.dart';
import 'package:mondu_farm/list_kategori.dart';
import 'package:mondu_farm/chat_list.dart';
import 'package:mondu_farm/login_page.dart';
import 'package:mondu_farm/utils/alerts.dart';
import 'package:mondu_farm/utils/color.dart';
import 'package:mondu_farm/utils/voice_over.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}





class _HomeState extends State<Home> {
  String? nama;
  String id_user = "";

  final FlutterTts flutterTts = FlutterTts();

  Future<void> getUserFromFirebase() async {
    try {
      FirebaseDatabase.instance
          .ref()
          .child("users")
          .child(id_user)
          .onValue
          .listen((event) {
        var snapshot = event.snapshot.value as Map;
        setState(() {
          nama = snapshot['nama'];
        });
        print(nama);
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }


  void logout(BuildContext context) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("isUserLoggedIn");
    await prefs.remove("id_user");
    await prefs.remove("nama");
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => LoginPage()));
  }

  Future<void> playVoiceover(String text) async {
    await flutterTts.setLanguage("id-ID");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);

    await flutterTts.speak(text);
  }


  Future<void> getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      id_user = pref.getString('id_user')!;
      nama = pref.getString('nama')!;
    });
    playVoiceover("maiwa pilih jenis mbada napa mbuham ");
    // setState(()  {
    //    getUserFromFirebase();
    // });
  }

  @override
  void initState() {
    super.initState();
    getPref();
    // test();

  }

  void test(){
    flutterTts.getVoices.then((value) {
      try{
        List<Map> voices = List<Map>.from(value);
        print(voices);
      }catch(e){
        print(e);
      }
    });
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Icon(Icons.person,color: Colors.white,),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          nama ?? "",
                          style: TextStyle(fontSize: 16,color: Colors.white),
                        )
            
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          Alerts.showAlertYesNo(
                            url: "assets/lottie/logout.json",
                            onPressYes: () async {
                              logout(context);
                            },
                            onPressNo: () {
                              Navigator.pop(context);
                            },
                            context: context,
                          );

                        },
                        icon: Icon(Icons.logout,color: Colors.white,))
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.asset(
                      "assets/logo_mondu.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    crossAxisSpacing: 15, // Spacing between columns
                    mainAxisSpacing: 15, // Spacing between rows
                  ),
                  itemCount: 4, // Number of items
                  itemBuilder: (context, index) {
                    // Return a container for each item
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (ctx) => (index == 0)
                                    ? CategoryList(kategori: 'Sapi',)
                                    : (index == 1)
                                        ? CategoryList(kategori: "Kuda",)
                                        : (index == 2)
                                            ? CategoryList(kategori: "Kerbau",)
                                            : CategoryList(kategori: "Kambing",)));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                          child: Image.asset(
                        "assets/category_${index}.jpg",
                        fit: BoxFit.cover,
                      )),
                    );
                  },
                ),
                SizedBox(height: 40,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        style: ButtonStyle(
                            padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(18,10,18,18)),
                            backgroundColor:
                                MaterialStateProperty.all(Warna.secondary)),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (ctx)=>ChatList()));
                        },
                        icon: SizedBox(
                            width: 80,
                            child: Image.asset("assets/icon_chat2.png"))),
                    IconButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(18,10,18,18)),
                            backgroundColor:
                                MaterialStateProperty.all(Warna.secondary)),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (ctx)=>ListBooking()));
                        },
                        icon: SizedBox(
                            width: 80,
                            child: Image.asset("assets/list.png",))),
                  ],
                ),
                SizedBox(height: 20,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
