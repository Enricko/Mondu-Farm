import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mondu_farm/home.dart';

class Success extends StatelessWidget {
  const Success({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset("assets/lottie/success.json"),
            SizedBox(height: 20,),
            IconButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.purple)),
                padding: EdgeInsets.all(20),
                onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => Home()));
                }, icon: Icon(Icons.home,color: Colors.white,size: 70,))
          ],
        ),
      ),
    );
  }
}
