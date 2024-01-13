
import "package:firebase_database/firebase_database.dart";
import "package:flutter/material.dart";
import "package:flutter_easyloading/flutter_easyloading.dart";
import "package:intl/intl.dart";
import "package:mondu_farm/home.dart";
import "package:shared_preferences/shared_preferences.dart";

class Auth {
  static login(Map<dynamic, dynamic> data, BuildContext context) async {
    try {
      EasyLoading.show(status: 'loading...');
      var key = FirebaseDatabase.instance.ref().child('users').push().key;
      FirebaseDatabase.instance
          .ref()
          .child("users")
      .child(key!)
          .set(data)
          .whenComplete(() async{
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setBool("isUserLoggedIn", true);
        pref.setString("id_user", key);
        pref.setString("nama", data['nama']);
        EasyLoading.showSuccess('Login Berhasil..',
            dismissOnTap: true, duration: const Duration(seconds: 5));
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Home()));
        return;
      }).onError((error, stackTrace) {
        EasyLoading.showError("Something went wrong : $error",
            dismissOnTap: true, duration: const Duration(seconds: 5));
      });
    } on Exception catch (e) {
      EasyLoading.showError('Ada Sesuatu Kesalahan : $e',
          dismissOnTap: true, duration: const Duration(seconds: 5));
    }
  }




}