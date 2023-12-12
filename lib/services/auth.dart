import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:heyhealth/models/user.dart';
import 'package:heyhealth/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:heyhealth/localisations/local_lang.dart';
import "dart:io";

class AuthService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
    "https://www.googleapis.com/auth/user.addresses.read",
    "https://www.googleapis.com/auth/user.birthday.read",
    "https://www.googleapis.com/auth/user.gender.read",
    "https://www.googleapis.com/auth/user.phonenumbers.read",
  ]);
  String userDOB = "";
  String userGender = "";
  String userPhone = "";
  String userAddress = "";
  String _verificationId = "";

  User? _userFromFirebaseUser(auth.User user) {
    return User(uid: user.uid, name: user.displayName!);
  }

  // Stream<User> get user {
  //   return _auth.authStateChanges().map(_userFromFirebaseUser);
  // }

  Future usePeopleAPI(_currentUser) async {
    final host = "https://people.googleapis.com";
    final endpoint =
        "/v1/people/me?personFields=addresses,genders,birthdays,phoneNumbers";

    log("Starting API connection");
    final header = await _currentUser.authHeaders;

    final request =
        await http.get(Uri.parse("$host$endpoint"), headers: header);

    if (request.statusCode == 200) {
      Map<String, dynamic> responseMap = json.decode(request.body);
      log(request.body);
      try {
        userGender = responseMap['genders'][0]["value"];
        if (responseMap['addresses'] != null)
          userAddress = responseMap["addresses"][0]["streetAddress"];
        var dob = responseMap['birthdays'][0]["date"];
        String doby = (dob["year"] ?? "2000").toString();
        String dobm = (dob["month"] ?? "01").toString();
        String dobd = (dob["day"] ?? "01").toString();
        userDOB = doby + "/" + dobm + "/" + dobd;
        if (responseMap['phoneNumbers'] != null)
          userPhone =
              (responseMap['phoneNumbers'][0]["value"] ?? "").toString();
      } catch (e) {
        log("Error is here ::::........." + e.toString());
        return null;
      }
    } else {
      log("API request failed");
    }
  }

  Future signInWithGoogle(BuildContext context) async {
    try {
      bool newUser = false;
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleSignInAuthentication =
          await googleSignInAccount?.authentication;

      final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication?.accessToken,
        idToken: googleSignInAuthentication?.idToken,
      );

      final auth.UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final fa.User? user = authResult.user;
      await usePeopleAPI(googleSignInAccount);
      if (user != null) {
        //assert(!user.isAnonymous);
        //assert(await user.getIdToken() != null);
        if (authResult.additionalUserInfo!.isNewUser) {
          newUser = true;
          await DatabaseService(uid: user.uid).updateData(user.displayName!,
              userPhone, userAddress, userGender, userDOB, "");
        }
      }
      stdout.write("signInWithGoogle_succeeded");
      log(user.toString());
      return newUser;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future addToDatabase(auth.UserCredential authResult, String phoneNumber,
      BuildContext context) async {
    final fa.User? user = authResult.user;
    if (user != null) {
      // assert(!user.isAnonymous);
      //if (await user.getIdToken() != null)
      if (authResult.additionalUserInfo!.isNewUser) {
        log("Creating New User");
        /*
        showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) {
              return Dialog(
                child: Profile(),
              );
            });*/
        await DatabaseService(uid: user.uid).updateData(user.displayName!,
            phoneNumber, userAddress, userGender, userDOB, "");
        log(user.uid);
      }
      //}
    }
  }

  Future<String?> verifyPhoneNumber(
      String phoneNumber, BuildContext context) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+90' + phoneNumber,
        verificationCompleted: (fa.PhoneAuthCredential credential) async {
          auth.UserCredential authResult =
              await _auth.signInWithCredential(credential);
          await addToDatabase(authResult, phoneNumber, context);
          log("Phone number is automatically verified");
        },
        verificationFailed: (fa.FirebaseAuthException e) {
          log(e.toString());
          log("Failed to Verify Phone Number: $phoneNumber");
        },
        codeSent: (String verificationId, [int? forceResendingToken]) async {
          log("check_sms");
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      return _verificationId;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<bool> signInWithPhoneNumber(
      String smsCode, String phoneNumber, BuildContext context) async {
    try {
      final fa.PhoneAuthCredential credential = fa.PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );
      auth.UserCredential authResult =
          await _auth.signInWithCredential(credential);
      await addToDatabase(authResult, phoneNumber, context);

      log("success_signed_in");

      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      auth.UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      fa.User? user = result.user;
      return user;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future registerWithEmailAndPassword(
      String email,
      String password,
      String name,
      String phone,
      String address,
      String gender,
      String dob,
      String profileurl) async {
    try {
      auth.UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      fa.User? user = result.user;
      await DatabaseService(uid: user!.uid)
          .updateData(name, phone, address, gender, dob, profileurl);
      return _userFromFirebaseUser(user);
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      await googleSignIn.disconnect();
      return await _auth.signOut();
    } catch (e) {
      return await _auth.signOut();
    }
  }
}
