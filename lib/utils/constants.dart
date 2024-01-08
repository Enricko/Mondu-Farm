import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Constants {
  ///text style
  static TextStyle title1 = GoogleFonts.inter(
      fontSize: 35, color: Colors.white, fontWeight: FontWeight.w700);
  static TextStyle button1 =
      GoogleFonts.inter(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold);
  static TextStyle labelstyle = TextStyle(
      color: Colors.black,
      fontSize: 16,fontWeight: FontWeight.w600);

  static double getPointX(BuildContext context) {
    return 40;
  }

  // static List<int>? extractKMLDataFromKMZ(List<int> kmzData) {
  //   final archive = ZipDecoder().decodeBytes(Uint8List.fromList(kmzData));
  //
  //   for (final file in archive) {
  //     if (file.name.endsWith('.kml')) {
  //       return file.content;
  //     }
  //   }
  //
  //   return null;
  // }

  
}