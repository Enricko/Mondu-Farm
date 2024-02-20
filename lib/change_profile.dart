

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangeProfile{

  static void insert(String photo_url,BuildContext context)async{
    try{
      EasyLoading.show(status: 'loading...');
      SharedPreferences pref = await SharedPreferences.getInstance();
      var id_user = pref.getString('id_user');
      await FirebaseDatabase.instance
          .ref()
          .child("users")
          .child(id_user!)
          .update({
        "photo_url": photo_url,
      }).whenComplete(() {
        EasyLoading.showSuccess('Berhasil',
            dismissOnTap: true, duration: const Duration(seconds: 5));
        Navigator.pop(context);
        return;
      });

    } on Exception catch (e) {
      EasyLoading.showError('Ada Sesuatu Kesalahan : $e',
          dismissOnTap: true, duration: const Duration(seconds: 5));
    }
  }
}