// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heyhealth/localisations/local_lang.dart';
import 'package:heyhealth/services/auth.dart';
import 'package:heyhealth/shared/constants.dart';
import 'package:heyhealth/shared/loading.dart';
import 'package:heyhealth/shared/otp_form.dart';
import 'package:mobile_number/mobile_number.dart';

enum ShowState {
  sim1,
  sim2,
}

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
  bool state1 = true;
  bool state2 = false;
  TextEditingController phoneNumberFormField = TextEditingController();

  final focus1 = FocusNode();
  String email = '';
  String password = '';
  String phoneNumber = '';
  double screenHeight;
  double screenWidth;
  String smsCode = '';
  String _mobileNumber = '';
  List<SimCard> _simCard = <SimCard>[];
  bool showVerifyNumberWidget = true;
  bool showVerificationCodeWidget = false;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initMobileNumberState() async {
    if (!await MobileNumber.hasPhonePermission) {
      await MobileNumber.requestPhonePermission;
      return;
    }
    String mobileNumber = "";
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      mobileNumber = (await MobileNumber.mobileNumber);
      _simCard = (await MobileNumber.getSimCards);
    } on PlatformException catch (error) {
      print("Failed to get mobile number because of '${error.message}'");
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _mobileNumber = mobileNumber;
    });
  }

  void textChange(String mobileNumber) {
    setState(() {
      phoneNumberFormField.text = _mobileNumber;
    });
  }

  void changeView(ShowState showState) {
    if (showState == ShowState.sim1) {
      setState(() {
        state1 = true;
        state2 = false;
      });
    } else if (showState == ShowState.sim2) {
      setState(() {
        state1 = false;
        state2 = true;
      });
    }
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

  // @override
  // void initState() {
  //   super.initState();
  //   MobileNumber.listenPhonePermission((isPermissionGranted) {
  //     if (isPermissionGranted) {
  //       initMobileNumberState();
  //     } else {}
  //   });

  //   initMobileNumberState();
  // }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return loading
        ? Loading()
        : Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 25,
                    ),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Login",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                        Icon(Icons.person_outline_outlined),
                                      ],
                                    ),
                                    Text("Welcome to heyhealth"),
                                  ],
                                ),
                                Image.asset('assets/inside/logo.png',
                                    width: 85.0, height: 85.0)
                              ],
                            ),
                            Form(
                              key: _formKey,
                              child: Container(
                                color: Colors.white,
                                child: SingleChildScrollView(
                                  reverse: false,
                                  child: Column(
                                    children: <Widget>[
                                      FittedBox(
                                        fit: BoxFit.contain,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Image.asset(
                                            'assets/inside/auth.png',
                                            height: 272,
                                            width: 229,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10.0),
                                      if (showVerifyNumberWidget)
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                width: 1,
                                                color: Color(0xFFDCD8D8)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: TextFormField(
                                                        controller:
                                                            phoneNumberFormField,
                                                        focusNode: focus1,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        inputFormatters: <TextInputFormatter>[
                                                          FilteringTextInputFormatter
                                                              .digitsOnly
                                                        ],
                                                        decoration:
                                                            textInputDecoration
                                                                .copyWith(
                                                          hintText:
                                                              "+91 8905336393",
                                                          hintStyle: TextStyle(
                                                              fontSize: 18),
                                                          focusedBorder:
                                                              InputBorder.none,
                                                          enabledBorder:
                                                              InputBorder.none,
                                                          errorBorder:
                                                              InputBorder.none,
                                                          disabledBorder:
                                                              InputBorder.none,
                                                        ),
                                                        style: TextStyle(
                                                            fontSize: 21),
                                                        validator: (val) => val
                                                                    .length !=
                                                                10
                                                            ? DemoLocalization
                                                                    .of(context)
                                                                .translate(
                                                                    "enter_10_digit_PhNo")
                                                            : null,
                                                        onChanged: (val) {
                                                          setState(() =>
                                                              phoneNumber =
                                                                  val);
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  Platform.isIOS
                                                      ? Container()
                                                      : Expanded(
                                                          flex: 1,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            10),
                                                                child: Row(
                                                                  children: [
                                                                    SimCardWidget(
                                                                      voidFunc: () =>
                                                                          changeView(
                                                                              ShowState.sim1),
                                                                      number:
                                                                          "1",
                                                                      state:
                                                                          state1,
                                                                    ),
                                                                    SizedBox(
                                                                        width:
                                                                            5),
                                                                    SimCardWidget(
                                                                        voidFunc: () =>
                                                                            changeView(ShowState
                                                                                .sim2),
                                                                        number:
                                                                            "2",
                                                                        state:
                                                                            state2)
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          "Need help ?",
                                          style: TextStyle(
                                            color: Color.fromRGBO(0, 0, 0, 0.6),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 30.0),
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
                                                primary: Color.fromRGBO(
                                                    3, 43, 68, 1),
                                              ),
                                              child: Text(
                                                DemoLocalization.of(context)
                                                    .translate("login"),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 22),
                                              ),
                                              onPressed: () async {
                                                await _auth.verifyPhoneNumber(
                                                    phoneNumber, context);
                                                displayMessage(
                                                    DemoLocalization.of(context)
                                                        .translate(
                                                            "check_sms"));
                                                setState(() {
                                                  showVerifyNumberWidget =
                                                      false;
                                                  showVerificationCodeWidget =
                                                      true;
                                                });
                                              }),
                                        ),
                                      if (showVerificationCodeWidget)
                                        Text(
                                          DemoLocalization.of(context)
                                              .translate("detect_otp"),
                                          style: TextStyle(
                                              color: Color(0xFF032B44),
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      if (showVerificationCodeWidget) OtpForm(),
                                      if (showVerificationCodeWidget)
                                        TextButton(
                                          style: TextButton.styleFrom(
                                              padding:
                                                  EdgeInsets.only(left: 220),
                                              primary:
                                                  Color.fromRGBO(0, 0, 0, 0.6)),
                                          onPressed: () {},
                                          child: Text("Resend OTP?"),
                                        ),
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
                                                  .translate("login"),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 22),
                                            ),
                                            onPressed: () async {
                                              if (_formKey.currentState
                                                  .validate()) {
                                                await _auth
                                                    .signInWithPhoneNumber(
                                                        smsCode,
                                                        phoneNumber,
                                                        context);
                                                displayMessage(DemoLocalization
                                                        .of(context)
                                                    .translate(
                                                        "success_signed_in"));
                                              }
                                            },
                                          ),
                                        ),
                                      if (showVerifyNumberWidget)
                                        Center(
                                          child: Text(
                                              DemoLocalization.of(context)
                                                  .translate("or")),
                                        ),
                                      SizedBox(height: 10.0),
                                      Text(
                                        error,
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(03, 43, 68, 1),
                                            fontSize: 15.0),
                                      ),
                                      if (showVerifyNumberWidget)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              DemoLocalization.of(context)
                                                  .translate("is_doctor"),
                                              style: TextStyle(
                                                  color: Colors.blueGrey,
                                                  fontSize: 15),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              DemoLocalization.of(context)
                                                  .translate("doc_companion"),
                                              style: TextStyle(
                                                  color: Colors.blueGrey,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      if (showVerificationCodeWidget)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              DemoLocalization.of(context)
                                                  .translate(
                                                      "incorrect_details"),
                                              style: TextStyle(
                                                  color: Colors.blueGrey,
                                                  fontSize: 15),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              DemoLocalization.of(context)
                                                  .translate("edit_phone"),
                                              style: TextStyle(
                                                  color: Colors.blueGrey,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: Color(0xFFA7BAFF),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                      alignment: Alignment.bottomCenter,
                      height: 30,
                      width: double.infinity,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      height: 70,
                      width: double.infinity,
                      child: Align(
                        alignment: Alignment(0, 0.7),
                        child: Divider(
                          color: Colors.black,
                          thickness: 4,
                          indent: 100,
                          endIndent: 100,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFA7BAFF),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(
                            10,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

class SimCardWidget extends StatelessWidget {
  final String number;
  final bool state;
  final VoidCallback voidFunc;
  const SimCardWidget({
    Key key,
    @required this.number,
    @required this.state,
    @required this.voidFunc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: voidFunc,
      child: Stack(
        children: [
          Image.asset(state
              ? "assets/inside/sim-filled.png"
              : "assets/inside/sim-empty.png"),
          Positioned(
            left: 5,
            top: 4,
            child: Text(
              number,
              style: TextStyle(color: state ? Colors.white : Color(0xFF032B44)),
            ),
          ),
        ],
      ),
    );
  }
}
