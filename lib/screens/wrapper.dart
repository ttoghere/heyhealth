import 'dart:developer';
import 'dart:io';
import 'package:heyhealth/screens/authenticate/register.dart';
import 'package:heyhealth/services/database.dart';
import 'package:flutter/material.dart';
import 'package:heyhealth/bottomtabnav.dart';
import 'package:heyhealth/models/user.dart';
import 'package:heyhealth/screens/authenticate/authenticate.dart';
import 'package:heyhealth/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart' as auth;

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  //auth.User signeduser;
  @override
  void initState() {
    super.initState();
    //this.signeduser = auth.FirebaseAuth.instance.currentUser;
  }

  final CollectionReference paitentCollection =
      FirebaseFirestore.instance.collection('patients');
  Future<void> createData(String uid) async {
    return await paitentCollection.doc(uid).set({
      'register_issue': true,
      'name': '',
      'phone': '',
      'address': '',
      'dob': '',
      'gender': '',
      'profileurl': '',
      'reg_date': ''
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    if (user == null) {
      return Authenticate();
    } else {
      return StreamBuilder<UserData>(
          stream: DatabaseService(uid: user.uid).userData,
          builder: (context, snapshot) {
            print("checking has data " + user.uid.toString());
            print(snapshot.data);
            if (snapshot.connectionState == ConnectionState.waiting) {
              print("Step 1");
              return Loading();
            }
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.active &&
                snapshot.data != null) {
              print("Step 2");
              UserData userData = snapshot.data;
              if ((userData.name == '') ||
                  (userData.phone == '') ||
                  (userData.dob == '') ||
                  (userData.address == '') ||
                  (userData.gender == '')) {
                return Register();
              } else {
                return Scaffold(
                  body: ShowCaseWidget(
                    onStart: (index, key) {
                      log('onStart: $index, $key');
                    },
                    onComplete: (index, key) {
                      log('onComplete: $index, $key');
                    },
                    builder: Builder(builder: (context) => BottomTab()),
                    autoPlay: true,
                    autoPlayDelay: Duration(seconds: 3),
                    autoPlayLockEnable: true,
                  ),
                );
              }
            } else {
              print("Step 3");
              UserData userDatax = snapshot.data;
              if (userDatax == null) {
                print("Step 4");
                createData(user.uid);
              }
              return Register();

              /*
              else{
                return Scaffold(
                  body: ShowCaseWidget(
                    onStart: (index, key) {
                      log('onStart: $index, $key');
                    },
                    onComplete: (index, key) {
                      log('onComplete: $index, $key');
                    },
                    builder: Builder(builder: (context) => BottomTab()),
                    autoPlay: true,
                    autoPlayDelay: Duration(seconds: 3),
                    autoPlayLockEnable: true,
                  ),
                );
              }
              */
            }
          });
    }
  }
}
