import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mondu_farm/utils/color.dart';
import 'package:mondu_farm/utils/voice_over.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/login.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  final FlutterTts flutterTts = FlutterTts();

  final formkey = GlobalKey<FormState>();
  bool ignorePointer = false;
  Timer? ignorePointerTimer;

  void login() {
    var name = nameController.text;
    var phoneNumber = phoneNumberController.text;
    var data = {
      'nama': name,
      'no_telepon': phoneNumber,
    };
    Auth.login(data, context);
  }

  Future<void> playVoiceover(String text) async {
    await flutterTts.setLanguage("id-ID");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);

    await flutterTts.speak(text);
  }

  void cekUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? isLogin = pref.getBool('isUserLoggedIn');
    if (isLogin == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) => Home()));
      });
    }
  }

  void initState() {
    super.initState();
    cekUser();
    // flutterTts.setLanguage("id-ID");
    // flutterTts.setPitch(1.0);
    // flutterTts.setSpeechRate(0.5);
  }

  @override
  Widget build(BuildContext context) {
    flutterTts.speak("maiwa ko daftar melalui Isi ngara ndang nomor telepon");
    return Scaffold(
      backgroundColor: Warna.latar,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SizedBox(height: 100,),
              // ClipRRect(
              //     borderRadius: BorderRadius.circular(10),
              //     child: Image.asset(
              //       "assets/logo_mondu.png",
              //       fit: BoxFit.cover,
              //     )),
              // SizedBox(height: 10,),
              ClipRRect(
                // borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    decoration: new BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey.shade200.withOpacity(0.3)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 25),
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            "assets/icon_login2.svg",
                            height: 150,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Form(
                            key: formkey,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 50,
                                      child: Image.asset(
                                        "assets/id-card.png",
                                        // scale: 0.7,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        controller: nameController,
                                        keyboardType: TextInputType.text,
                                        validator: (value) {
                                          if (value == null ||
                                              value.isEmpty ||
                                              value == "") {
                                            return "Nama Lengkap harus di isi!";
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Warna.terang,
                                          hintText: "Mond**",
                                          hintStyle: const TextStyle(
                                            color: Color(0xFF696F79),
                                            fontSize: 14,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400,
                                          ),
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  15, 30, 15, 0),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(13),
                                            borderSide: const BorderSide(
                                                width: 1,
                                                color: Color(0xFFDEDEDE)),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 1,
                                                color: Colors.redAccent),
                                            borderRadius:
                                                BorderRadius.circular(13),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 50,
                                      child: Image.asset(
                                        "assets/phones.png",
                                        scale: 0.7,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        controller: phoneNumberController,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null ||
                                              value.isEmpty ||
                                              value == "") {
                                            return "Nomor Telepon harus di isi!";
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Warna.terang,
                                          hintText: "0851********",
                                          hintStyle: const TextStyle(
                                            color: Color(0xFF696F79),
                                            fontSize: 14,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400,
                                          ),
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  15, 30, 15, 0),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(13),
                                            borderSide: const BorderSide(
                                                width: 1,
                                                color: Color(0xFFDEDEDE)),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 1,
                                                color: Colors.redAccent),
                                            borderRadius:
                                                BorderRadius.circular(13),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 60,
                            width: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              gradient: LinearGradient(colors: [
                                Warna.latar,
                                Warna.primary,
                                // Color.fromARGB(225, 0, 111, 186),
                                // Color.fromARGB(225, 58, 171, 249)
                              ]),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                
                                // padding: MaterialStateProperty.all(EdgeInsets.all(10)),
                                //   side: MaterialStateProperty.all(BorderSide(color: Warna.tersier)),
                                  backgroundColor: MaterialStateProperty.all(
                                    // LinearGradient(colors: <Color>[Colors.green, Colors.black],)
                                      Colors.transparent
                                  ),
                                shadowColor: MaterialStateProperty.all(Colors.transparent)

                              ),
                              onPressed: () {
                                if (formkey.currentState!.validate()) {
                                  setState(() {
                                    ignorePointer = true;
                                    ignorePointerTimer =
                                        Timer(const Duration(seconds: 2), () {
                                      setState(() {
                                        ignorePointer = false;
                                      });
                                    });
                                  });
                                  // Menjalanan kan logic Simpan data lembur
                                  login();
                                }
                              },
                              child: Icon(Icons.arrow_forward,color: Colors.white,size: 30,)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
