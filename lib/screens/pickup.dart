import 'package:flutter/material.dart';
import 'package:heyhealth/models/call.dart';
import 'package:heyhealth/screens/callscreen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:heyhealth/models/user.dart';
//import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:heyhealth/localisations/local_lang.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final CallMethods callMethods = CallMethods();

  PickupLayout({
    @required this.scaffold,
  });
  Future<bool> check(uid) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("video_consulting")
        .doc(uid)
        .get();

    if (documentSnapshot.exists) {
      return true;
    } else
      return false;
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);

    return (user.uid != null)
        ? StreamBuilder<DocumentSnapshot>(
            stream: callMethods.callStream(uid: user.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data.exists) {
                Call call = Call.fromMap(snapshot.data.data());
                if (!call.hasDialled) {
                  return PickupScreen(call: call);
                }
              }
              return scaffold;
            },
          )
        : Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}

class PickupScreen extends StatelessWidget {
  final Call call;
  final CallMethods callMethods = CallMethods();

  PickupScreen({
    @required this.call,
  });

  @override
  Widget build(BuildContext context) {
    //FlutterRingtonePlayer.playRingtone();
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              DemoLocalization.of(context).translate("incoming"),
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            SizedBox(height: 50),
            Text(
              DemoLocalization.of(context).translate("video_consult_with"),
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 50),
            Text(
              DemoLocalization.of(context).translate("dr") + call.callerName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 75),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.call_end),
                  color: Colors.redAccent,
                  onPressed: () async {
                    //FlutterRingtonePlayer.stop();
                    await callMethods.endCall(call: call);
                  },
                ),
                SizedBox(width: 25),
                IconButton(
                    icon: Icon(Icons.call),
                    color: Colors.green,
                    onPressed: () async {
                      await [Permission.camera, Permission.microphone]
                          .request();
                      //FlutterRingtonePlayer.stop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CallScreen(call: call),
                        ),
                      );
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
