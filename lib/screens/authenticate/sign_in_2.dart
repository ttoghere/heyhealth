import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heyhealth/screens/authenticate/authenticate.dart';
import 'package:heyhealth/services/auth.dart';
import 'package:heyhealth/shared/constants.dart';
import 'package:heyhealth/shared/loading.dart';
import 'package:heyhealth/localisations/local_lang.dart';

class SignIn extends StatefulWidget {
  //final Function toggleView;
  SignIn();

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;

  final focus1 = FocusNode();
  String email = '';
  String password = '';
  String phoneNumber = '';
  double screenHeight;
  double screenWidth;
  String smsCode = '';

  bool showVerifyNumberWidget = true;
  bool showVerificationCodeWidget = false;

  // bool _isConnected=false;
  //
  // // This function is triggered when the floating button is pressed
  // Future<void> _checkInternetConnection() async {
  //   try {
  //     final response = await InternetAddress.lookup('www.google.com');
  //     if (response.isNotEmpty) {
  //       setState(() {
  //         _isConnected = true;
  //       });
  //     }
  //   } on SocketException catch (err) {
  //     setState(() {
  //       _isConnected = false;
  //     });
  //     print(err);
  //   }
  // }
  Connectivity _connection = Connectivity();
  StreamSubscription _stream;
  bool status = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkConnectionRealTime();
  }

  void checkConnectionRealTime() {
    _stream = _connection.onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.mobile ||
          event == ConnectivityResult.wifi) {
        status = true;
      } else {
        status = false;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _stream.cancel();
    super.dispose();
  }

  void displayMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 20),
      action: SnackBarAction(
        label: "X",
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0.0,
                title: Image.asset('assets/inside/logo.png',
                    width: 85.0, height: 85.0)
                /*
              actions: <Widget>[
                TextButton.icon(
                  icon: Icon(Icons.person),
                  label: Text('Register'),
                  style: TextButton.styleFrom(primary: Colors.white),
                  onPressed: () => widget.toggleView(),
                ),
              ],*/
                ),
            body: Padding(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Container(
                decoration: BoxDecoration(
                  //color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Form(
                    key: _formKey,
                    child: Container(
                        child: SingleChildScrollView(
                      reverse: false,
                      child: !status
                          ? Column(
                              children: [
                                FittedBox(
                                    fit: BoxFit.contain,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.asset(
                                        'assets/auth/signindoc.png',
                                        height: 380,
                                        width: 400,
                                      ),
                                    )),
                                Text(
                                  "Check Your Internet Connection!",
                                  style: TextStyle(color: Colors.black),
                                )
                              ],
                            )
                          : Column(
                              children: <Widget>[
                                FittedBox(
                                    fit: BoxFit.contain,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.asset(
                                        'assets/auth/signindoc.png',
                                        height: 380,
                                        width: 400,
                                      ),
                                    )),
                                SizedBox(height: 10.0),
                                if (showVerifyNumberWidget)
                                  Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      child: Container(
                                          decoration: BoxDecoration(
                                            //hintText: '10 Digit Phone Number',
                                            border: Border.all(
                                                color: Color.fromRGBO(
                                                    03, 43, 68, 1),
                                                width: 2.0),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    10.0) //                 <--- border radius here
                                                ),
                                          ),
                                          child: ListTile(
                                            leading: Text(
                                              '+91',
                                              style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      03, 43, 68, 1),
                                                  fontSize: 20),
                                            ),
                                            title: TextFormField(
                                              focusNode: focus1,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              decoration:
                                                  textInputDecoration.copyWith(
                                                hintText: DemoLocalization.of(
                                                        context)
                                                    .translate(
                                                        "10_digit_phone_no"),
                                                hintStyle:
                                                    TextStyle(fontSize: 18),
                                                focusedBorder: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                errorBorder: InputBorder.none,
                                                disabledBorder:
                                                    InputBorder.none,
                                              ),
                                              style: TextStyle(fontSize: 21),
                                              validator: (val) => val.length !=
                                                      10
                                                  ? DemoLocalization.of(context)
                                                      .translate(
                                                          "enter_10_digit_PhNo")
                                                  : null,
                                              onChanged: (val) {
                                                setState(
                                                    () => phoneNumber = val);
                                              },
                                            ),
                                          ))),
                                SizedBox(height: 15.0),
                                if (showVerifyNumberWidget)
                                  Container(
                                    height: 55,
                                    width: double.infinity,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 5,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: EdgeInsets.all(12),
                                          primary:
                                              Color.fromRGBO(03, 43, 68, 1),
                                        ),
                                        child: Text(
                                          DemoLocalization.of(context)
                                              .translate("verify_number"),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22),
                                        ),
                                        onPressed: () async {
                                          await _auth.verifyPhoneNumber(
                                              phoneNumber, context);
                                          displayMessage(
                                              DemoLocalization.of(context)
                                                  .translate("check_sms"));
                                          setState(() {
                                            showVerifyNumberWidget = false;
                                            showVerificationCodeWidget = true;
                                          });
                                        }),
                                  ),
                                if (showVerificationCodeWidget)
                                  SizedBox(height: 15.0),
                                if (showVerificationCodeWidget)
                                  Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      child: Container(
                                          decoration: BoxDecoration(
                                            //hintText: '10 Digit Phone Number',
                                            border: Border.all(
                                                color: Color.fromRGBO(
                                                    03, 43, 68, 1),
                                                width: 2.0),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    10.0) //                 <--- border radius here
                                                ),
                                          ),
                                          child: ListTile(
                                            title: TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              decoration:
                                                  textInputDecoration.copyWith(
                                                hintText: DemoLocalization.of(
                                                        context)
                                                    .translate("6_digit_code"),
                                                focusedBorder: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                errorBorder: InputBorder.none,
                                                disabledBorder:
                                                    InputBorder.none,
                                              ),
                                              validator: (val) => val.length !=
                                                      6
                                                  ? DemoLocalization.of(context)
                                                      .translate(
                                                          "enter_six_digit_code")
                                                  : null,
                                              onChanged: (val) {
                                                setState(() => smsCode = val);
                                              },
                                            ),
                                          ))),
                                if (showVerificationCodeWidget)
                                  SizedBox(height: 15.0),
                                if (showVerificationCodeWidget)
                                  Container(
                                    height: 60,
                                    width: double.infinity,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 5,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: EdgeInsets.all(12),
                                          primary:
                                              Color.fromRGBO(03, 43, 68, 1),
                                        ),
                                        child: Text(
                                          DemoLocalization.of(context)
                                              .translate("sign_in"),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22),
                                        ),
                                        onPressed: () async {
                                          if (_formKey.currentState
                                              .validate()) {
                                            await _auth.signInWithPhoneNumber(
                                                smsCode, phoneNumber, context);
                                            displayMessage(
                                                DemoLocalization.of(context)
                                                    .translate(
                                                        "success_signed_in"));
                                          }
                                        }),
                                  ),
                                SizedBox(height: 20.0),
                                if (showVerificationCodeWidget)
                                  Container(
                                    height: 50,
                                    width: double.infinity,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 5,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: EdgeInsets.all(12),
                                          primary: Colors.white,
                                        ),
                                        child: Text(
                                          "Try again",
                                          style: TextStyle(
                                              color:
                                                  Color.fromRGBO(03, 43, 68, 1),
                                              fontSize: 15),
                                        ),
                                        onPressed: () async {
                                          setState(() {
                                            showVerifyNumberWidget = true;
                                            showVerificationCodeWidget = false;
                                          });
                                        }),
                                  ),
                                if (showVerifyNumberWidget)
                                  Text(DemoLocalization.of(context)
                                      .translate("or")),
                                SizedBox(height: 15.0),
                                if (showVerifyNumberWidget)
                                  Center(child: GoogleButton()),
                                Text(
                                  error,
                                  style: TextStyle(
                                      color: Color.fromRGBO(03, 43, 68, 1),
                                      fontSize: 15.0),
                                ),
                                SizedBox(height: 30.0),
                                Text(
                                  DemoLocalization.of(context)
                                      .translate("agree_to_privacy_policy"),
                                  style: TextStyle(
                                      color: Colors.blueGrey, fontSize: 15),
                                )
                              ],
                            ),
                    ))),
              ),
            ));
  }
}
