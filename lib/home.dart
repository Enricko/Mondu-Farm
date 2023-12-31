import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mondu_farm/category_sapi.dart';
import 'package:mondu_farm/chat_list.dart';
import 'package:mondu_farm/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}
 String? name;
String id_user = "";




class _HomeState extends State<Home> {

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
          name = snapshot['name'];
        });
        print(name);
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }


  void logout(BuildContext context) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("isUserLoggedIn");
    await prefs.remove("id_user");
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => LoginPage()));
  }


  Future<void> getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      id_user = pref.getString('id_user')!;
    });
    setState(() {
      getUserFromFirebase();
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
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
                      Icon(Icons.person),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        name ?? "",
                        style: TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                  IconButton(
                      onPressed: () {
                        logout(context);
                      },
                      icon: Icon(Icons.logout))
                ],
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                child: Card(
                  child: Image.asset(
                    "assets/banner_home.jpg",
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    crossAxisSpacing: 5, // Spacing between columns
                    mainAxisSpacing: 5, // Spacing between rows
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
                      child: Card(
                          child: Image.asset(
                        "assets/category_${index}.jpg",
                        fit: BoxFit.fill,
                      )),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 50,
              ),
              IconButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.purple)),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx)=>ChatList()));
                  },
                  icon: Image.asset("assets/icon_chat.png")),
              SizedBox(
                height: 70,
              )
            ],
          ),
        ),
      ),
    );
  }
}
