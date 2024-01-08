import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:lottie/lottie.dart';


class Alerts {
  static showMessage(String message, BuildContext context) {
    // print("item deleted!");
    showToast(
      message,
      context: context,
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.fade,
      position: StyledToastPosition.center,
      animDuration: Duration(seconds: 1),
      duration: Duration(seconds: 2),
      curve: Curves.elasticOut,
    );
  }

  static showAlert(String message, BuildContext context) {
    // print("item deleted!");
    showToast(
      message,
      context: context,
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.fade,
      position: StyledToastPosition.center,
      animDuration: Duration(seconds: 1),
      duration: Duration(seconds: 5),
      curve: Curves.elasticOut,
    );
  }

  static showAlertYesNo(
      {
        required VoidCallback onPressYes,
        required VoidCallback onPressNo,
        required BuildContext context}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          icon: SizedBox(
              height: 80,
              child: Lottie.asset("assets/lottie/booking.json")),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
                onPressed: onPressYes,
                child:Icon(Icons.check,color: Colors.white,),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(
                          color: Colors.black38,
                        ),
                      ),
                    )),
                onPressed: onPressNo,
                child: Icon(Icons.close)),
              ),

          ],
        );
      },
    );
  }

  static showAlertYesNoLogout(
      {required String title,
      required VoidCallback onPressYes,
      required VoidCallback onPressNo,
      required BuildContext context}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          icon: SizedBox(
            height: 80,
            width: 80,
            child: Icon(Icons.logout),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          // judul
          title: Text(
            title,
            style: TextStyle(fontSize: 20),
          ),
          actions: [
            // tombel yes
            SizedBox(
              width: 90,
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4))),
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                ),
                onPressed: onPressYes,
                child: Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ),
            //tombol no
            SizedBox(
              width: 90,
              child: TextButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: BorderSide(
                      color: Colors.black38,
                    ),
                  ),
                )),
                onPressed: onPressNo,
                child: Text('No', style: TextStyle(color: Colors.black38)),
              ),
            ),
          ],
        );
      },
    );
  }

  // static showAlertYesNoConfirm(
  //     {required String title,
  //     required VoidCallback onPressYes,
  //     required VoidCallback onPressNo,
  //     required BuildContext context}) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) {
  //       return AlertDialog(
  //         icon: SizedBox(
  //           height: 80,
  //           width: 80,
  //           child: Lottie.asset(
  //             'assets/lottie/mail.json',
  //             fit: BoxFit.contain,
  //           ),
  //           // child: Lottie.asset('assets/lottie/animation_delete.json',
  //           //   fit: BoxFit.contain,
  //           // ),
  //         ),
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
  //         // judul
  //         title: Text(
  //           title,
  //           style: TextStyle(fontSize: 20),
  //         ),
  //         actions: [
  //           // tombel yes
  //           SizedBox(
  //             width: 120,
  //             child: ElevatedButton(
  //               style: ButtonStyle(
  //                 shape: MaterialStateProperty.all(RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(4))),
  //                 backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
  //               ),
  //               onPressed: onPressYes,
  //               child: Text('Send Mail', style: TextStyle(color: Colors.white)),
  //             ),
  //           ),
  //           //tombol no
  //           SizedBox(
  //             width: 90,
  //             child: TextButton(
  //               style: ButtonStyle(
  //                   shape: MaterialStateProperty.all(
  //                 RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(4),
  //                   side: BorderSide(
  //                     color: Colors.black38,
  //                   ),
  //                 ),
  //               )),
  //               onPressed: onPressNo,
  //               child: Text('No', style: TextStyle(color: Colors.black38)),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}