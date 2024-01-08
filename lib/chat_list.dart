import 'package:flutter/material.dart';

import 'detail_chat.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List Chat"),
      ),
      body: ListView.builder(
          itemCount: 2,
          itemBuilder: (context, index) {
            return Column(
              children: [
                ListTile(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (ctx)=>DetailChat()));
                  },
                  trailing: Icon(Icons.arrow_forward_ios),
                  tileColor: Colors.black12,
                  title: Text("Sapi"),
                  leading: Image.asset("assets/sapi.jpg",),
                  subtitle: Column(
                    children: [
                      Row(
                        children: [
                          Row(
                            children: [
                              Image.asset("assets/icon_umur.png",height: 20,),
                              Text("15",)
                            ],
                          ),
                          SizedBox(width: 50,),
                          Row(
                            children: [
                              Image.asset("assets/icon_tinggi.png",height: 20),
                              Text("1,5")
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Row(
                            children: [
                              Image.asset("assets/icon_bobot.png",height: 20),
                              Text("15")
                            ],
                          ),
                          SizedBox(width: 40,),
                          Row(
                            children: [
                              Image.asset("assets/icon_harga.png",height: 20),
                              Text("1,5")
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3,)
              ],
            );

          },)
    );
  }
}
