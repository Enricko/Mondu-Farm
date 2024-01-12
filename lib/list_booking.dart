import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListBooking extends StatefulWidget {
  const ListBooking({Key? key}) : super(key: key);

  @override
  State<ListBooking> createState() => _ListBookingState();
}

class _ListBookingState extends State<ListBooking> {

  String? id_user;
  Future<void> getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      id_user = pref.getString('id_user')!;
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
      appBar: AppBar(
        title: Text("List Booking"),
      ),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance
            .ref()
            .child("booking")
            .onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && (snapshot.data!).snapshot.value != null) {
            Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
                (snapshot.data! as DatabaseEvent).snapshot.value
                as Map<dynamic, dynamic>);
            List<Map<dynamic, dynamic>> dataList = [];
            data.forEach((key, value) {
              final currentData = Map<String, dynamic>.from(value);
              dataList.add({
                'id_user': currentData['id_user'],
                'nama': currentData['nama'],
                'kategori': currentData['kategori'],
              });
            });
            List<Map<dynamic, dynamic>> filteredList = dataList
                .where((entry) => entry['id_user'] == id_user)
                .toList();

            // dataList.sort((a, b) {
            //   var statusA = a['id_user'] == id_user;
            //   var statusB = b['id_user'] == id_user;
            //
            //   if (statusA && !statusB) {
            //     return -1;
            //   } else if (!statusA && statusB) {
            //     return 1;
            //   } else {
            //     return 0;
            //   }
            // });
            return ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
               return ListTile(
                 title: Text(filteredList[index]["nama"]),
                 subtitle: Text(filteredList[index]["kategori"]),
                 trailing: ElevatedButton(onPressed: (){},child: Text("Lihat Nota")),
               );
              },
            );
          }
          if (snapshot.hasData) {
            return Center(
              child: Text("Kosong"),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
