import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mondu_farm/demo_page.dart';
import 'package:mondu_farm/utils/color.dart';

import 'firebase_options.dart';
import 'login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  Intl.defaultLocale = 'id_ID';
  await initializeDateFormatting('id_ID');

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      builder: EasyLoading.init(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          primary: Colors.white,
        ),
          appBarTheme:  const AppBarTheme(
              iconTheme: IconThemeData(color: Colors.white)),
          scaffoldBackgroundColor: Warna.latar,
        useMaterial3: true,
          fontFamily: 'Poppins'
      ),
      home: LoginPage()
      // DemoPage(),
    );
  }
}
