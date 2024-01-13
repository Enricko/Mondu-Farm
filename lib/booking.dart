import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mondu_farm/success.dart';

class Booking {
  static void insert(BuildContext context, Map<dynamic, dynamic> data) async {
    try {
      var key = FirebaseDatabase.instance.ref().child('users').push().key;
      var id_booking = FirebaseDatabase.instance.ref().push().key;

      EasyLoading.show(status: 'loading...');
      await FirebaseDatabase.instance.ref()
          .child("booking")
          // .child(key!)
      .push()
          .set({
        "id_user": data['id_user'].toString(),
        "nama": data['nama'].toString(),
        "no_telepon": data['no_telepon'].toString(),
        "id_ternak": data['id_ternak'].toString(),
        "kategori": data['kategori'].toString(),
        "tanggal_booking": data['tanggal_booking'].toString(),
        "status_booking": data['status_booking'].toString(),
      }).whenComplete(() {
        EasyLoading.showSuccess('Booking Berhasil',
            dismissOnTap: true, duration: const Duration(seconds: 5));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (ctx) => Success(),
          ),
          (route) => false,
        );
        return;
      }).onError((error, stackTrace) {
        EasyLoading.showError("Ada Sesuatu Kesalahan: $error",
            dismissOnTap: true, duration: const Duration(seconds: 5));
      });
    } on Exception catch (e) {
      EasyLoading.showError('Ada Sesuatu Kesalahan : $e',
          dismissOnTap: true, duration: const Duration(seconds: 5));
    }
  }
}
