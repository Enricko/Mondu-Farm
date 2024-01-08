import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  final formkey = GlobalKey<FormState>();
  bool ignorePointer = false;
  Timer? ignorePointerTimer;

  void login() {
    var name = nameController.text;
    var phoneNumber = phoneNumberController.text;
      var data = {
        'name': name,
        'phone_number': phoneNumber,
      };
      Auth.login(data, context);
  }

  void cekUser()async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? isLogin = pref.getBool('isUserLoggedIn');
    if (isLogin == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Home()));
      });
    }
  }

  void initState() {
    cekUser();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/icon_handphone.png"),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 20),
                  child: Column(
                    children: [
                      Form(
                        key: formkey,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Image.asset("assets/icon_nama.png",height: 50),
                                SizedBox(width: 5,),
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
                                      fillColor: const Color(0xFFFCFDFE),
                                      hintText: "Nama Lengkap",
                                      hintStyle: const TextStyle(
                                        color: Color(0xFF696F79),
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                      ),
                                      isDense: true,
                                      contentPadding:
                                      const EdgeInsets.fromLTRB(15, 30, 15, 0),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(13),
                                        borderSide: const BorderSide(
                                            width: 1, color: Color(0xFFDEDEDE)),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 1, color: Colors.redAccent),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 20,),
                            Row(
                              children: [
                                Image.asset("assets/icon_notelepon.png",height: 50),
                                SizedBox(width: 5,),
                                Expanded(
                                  child: TextFormField(
                                    controller: phoneNumberController,
                                    keyboardType: TextInputType.number,
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
                                      fillColor: const Color(0xFFFCFDFE),
                                      hintText: "Nomor Telepon",
                                      hintStyle: const TextStyle(
                                        color: Color(0xFF696F79),
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                      ),
                                      isDense: true,
                                      contentPadding:
                                      const EdgeInsets.fromLTRB(15, 30, 15, 0),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(13),
                                        borderSide: const BorderSide(
                                            width: 1, color: Color(0xFFDEDEDE)),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 1, color: Colors.redAccent),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 30,),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        width: 100,
                        child: ElevatedButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.deepPurple)),
                          onPressed: (){
                            if (formkey.currentState!.validate()) {
                              setState(() {
                                ignorePointer = true;
                                ignorePointerTimer = Timer(const Duration(seconds: 2), () {
                                  setState(() {
                                    ignorePointer = false;
                                  });
                                });
                              });
                              // Menjalanan kan logic Simpan data lembur
                              login();
                            }

                          }, child: Text(""),),
                      ),
                    ],
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
