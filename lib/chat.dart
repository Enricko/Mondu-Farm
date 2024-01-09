import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import "package:http/http.dart" as http;
import 'package:mondu_farm/utils/custom_extension.dart';

class Chat {
  static Future<Uint8List> convertBlobUrlToUint8List(String blobUrl) async {
    // Fetch the data from the Blob URL
    var response = await http.get(Uri.parse(blobUrl));

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Convert the response body (which contains the Blob data) to Uint8List
      Uint8List uint8list = Uint8List.fromList(response.bodyBytes);
      return uint8list;
    } else {
      // Handle the error if the request fails
      throw Exception('Failed to fetch data from Blob URL');
    }
  }


  static Future<void> InsertChat(String filePath, String recorderTxt,String idUser) async {
    print("File : ${File(filePath).existsSync()}");
    // -NnJThg-A5k5iNE8Z1VT
    var metadata = SettableMetadata(
      contentType: "video/mp4",
    );
    String fileName = "${generateRandomString(10)}-${DateTime.now()}.mp4";
    var fileStorage = FirebaseStorage.instance.ref().child("audio").child(fileName);

    if (!kIsWeb) {
      await fileStorage.putFile(File(filePath), metadata).whenComplete(() async {
        String linkPath = await fileStorage.getDownloadURL();
        Map<String, dynamic> data = {
          "pesan": linkPath,
          "pesan_dari": "user",
          "durasi": recorderTxt,
          "type": "voice",
          "tanggal": DateTime.now().toString(),
        };
        await FirebaseDatabase.instance
            .ref()
            .child("pesan")
            .child(idUser)
            .push()
            .set(data)
            .whenComplete(() {
          EasyLoading.showSuccess('Pesan telah di tambahkan', dismissOnTap: true, duration: Duration(seconds: 3));
        });
      });
    } else {
      fileStorage.putData(await convertBlobUrlToUint8List(filePath), metadata).then((p0) async {
        String linkPath = await fileStorage.getDownloadURL();
        Map<String, dynamic> data = {
          "pesan": linkPath,
          "pesan_dari": "user",
          "durasi": recorderTxt,
          "type": "voice",
          "tanggal": DateTime.now().toString(),
        };
        await FirebaseDatabase.instance
            .ref()
            .child("pesan")
            .child(idUser)
            .push()
            .set(data)
            .whenComplete(() {
          EasyLoading.showSuccess('Pesan telah di tambahkan', dismissOnTap: true, duration: Duration(seconds: 3));
        });
      });
    }
  }
  
}
