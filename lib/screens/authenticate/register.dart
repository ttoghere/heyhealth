import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:heyhealth/shared/constants.dart';
import 'package:heyhealth/shared/loading.dart';
import 'package:heyhealth/localisations/local_lang.dart';
import 'package:heyhealth/services/database.dart';
import 'package:heyhealth/models/user.dart';

class Register extends StatefulWidget {
  Register();

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;

  double screenHeight;

  final focus1 = FocusNode();
  final focus2 = FocusNode();
  final focus3 = FocusNode();
  final focus4 = FocusNode();
  final focus5 = FocusNode();

  String email;
  String name;
  String phone;
  String address;
  String gender;
  String dob;
  String regdate;
  auth.User user;

  int genderRadio;
  @override
  void initState() {
    this.user = auth.FirebaseAuth.instance.currentUser;
    super.initState();
    genderRadio = 0;
    fromregistered = true;
  }

  DateTime registeredDate = DateTime.now();
  DateTime selectedDate = DateTime.now();
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1920, 1),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        dob = selectedDate.day.toString() +
            '/' +
            selectedDate.month.toString() +
            '/' +
            selectedDate.year.toString();
        regdate = registeredDate.day.toString() +
            '/' +
            registeredDate.month.toString() +
            '/' +
            registeredDate.year.toString();
      });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    return StreamBuilder<UserData>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserData userData = snapshot.data;
            print(userData.phone);
            return Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.blueGrey[900],
                  elevation: 0.0,
                  title: Text(DemoLocalization.of(context)
                      .translate("register_with_heyhealth")),
                ),
                body: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  child: Form(
                    key: _formKey,
                    child: Container(
                      child: SingleChildScrollView(
                        reverse: false,
                        child: Column(
                          children: <Widget>[
                            FittedBox(
                              fit: BoxFit.fill,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.asset(
                                    'assets/auth/patient-register.jpg',
                                    width: 240.0,
                                    height: 150),
                              ),
                            ),
                            SizedBox(height: 10.0),
                            /*
                            Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: TextFormField(
                                decoration: textInputDecoration.copyWith(
                                  labelText: DemoLocalization.of(context)
                                      .translate("email"),
                                  enabledBorder: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(15.0),
                                    borderSide:
                                        BorderSide(color: Colors.teal[50]),
                                  ),
                                  focusedBorder: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(15.0),
                                    borderSide:
                                        BorderSide(color: Colors.teal[900]),
                                  ),
                                ),
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (v) {
                                  FocusScope.of(context).requestFocus(focus1);
                                },
                                onChanged: (val) {
                                  setState(() => email = val);
                                },
                              ),
                            ),
                            */
                            SizedBox(height: 10.0),
                            Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: TextFormField(
                                focusNode: focus1,
                                initialValue: userData.name,
                                decoration: textInputDecoration.copyWith(
                                  labelText: DemoLocalization.of(context)
                                      .translate("your_name"),
                                  enabledBorder: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(15.0),
                                    borderSide:
                                        BorderSide(color: Colors.teal[50]),
                                  ),
                                  focusedBorder: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(15.0),
                                    borderSide:
                                        BorderSide(color: Colors.teal[900]),
                                  ),
                                ),
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (v) {
                                  FocusScope.of(context).requestFocus(focus2);
                                },
                                validator: (val) => val.length < 3
                                    ? DemoLocalization.of(context)
                                        .translate("enter_valid_name")
                                    : null,
                                onChanged: (val) {
                                  setState(() => name = val);
                                },
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: TextFormField(
                                focusNode: focus2,
                                initialValue: userData.phone,
                                decoration: textInputDecoration.copyWith(
                                  labelText: DemoLocalization.of(context)
                                      .translate("phone_no"),
                                  enabledBorder: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(15.0),
                                    borderSide:
                                        BorderSide(color: Colors.teal[50]),
                                  ),
                                  focusedBorder: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(15.0),
                                    borderSide:
                                        BorderSide(color: Colors.teal[900]),
                                  ),
                                ),
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (v) {
                                  FocusScope.of(context).requestFocus(focus3);
                                },
                                validator: (val) => val.length != 10
                                    ? DemoLocalization.of(context)
                                        .translate("invalid_phone_no")
                                    : null,
                                onChanged: (val) {
                                  setState(() => phone = val);
                                },
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: TextFormField(
                                focusNode: focus3,
                                initialValue: userData.address,
                                decoration: textInputDecoration.copyWith(
                                  labelText: DemoLocalization.of(context)
                                      .translate("address"),
                                  enabledBorder: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(15.0),
                                    borderSide:
                                        BorderSide(color: Colors.teal[50]),
                                  ),
                                  focusedBorder: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(15.0),
                                    borderSide:
                                        BorderSide(color: Colors.teal[900]),
                                  ),
                                ),
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (v) {
                                  FocusScope.of(context).requestFocus(focus4);
                                },
                                validator: (val) => val.length < 10
                                    ? DemoLocalization.of(context)
                                        .translate("invalid_address")
                                    : null,
                                onChanged: (val) {
                                  setState(() => address = val);
                                },
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: TextFormField(
                                focusNode: focus4,
                                readOnly: true,
                                enabled: true,
                                initialValue: userData.dob,
                                decoration: textInputDecoration.copyWith(
                                  hintStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.0,
                                  ),
                                  prefixText: dob,
                                  labelText: DemoLocalization.of(context)
                                          .translate("DOB") +
                                      '   DD/MM/YYYY',
                                  prefixIcon: Icon(Icons.calendar_today),
                                  enabledBorder: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(15.0),
                                    borderSide:
                                        BorderSide(color: Colors.teal[50]),
                                  ),
                                  focusedBorder: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(15.0),
                                    borderSide:
                                        BorderSide(color: Colors.teal[900]),
                                  ),
                                ),
                                onTap: () => _selectDate(context),
                                onChanged: (val) {
                                  setState(() => dob = val);
                                },
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              DemoLocalization.of(context).translate("gender"),
                              style: new TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Radio(
                                  value: 1,
                                  groupValue: genderRadio,
                                  onChanged: (val) {
                                    setState(() {
                                      genderRadio = val;
                                      gender = 'Male';
                                    });
                                  },
                                ),
                                new Text(
                                  DemoLocalization.of(context)
                                      .translate("male"),
                                  style: new TextStyle(fontSize: 15.0),
                                ),
                                Radio(
                                  value: 2,
                                  groupValue: genderRadio,
                                  onChanged: (val) {
                                    setState(() {
                                      genderRadio = val;
                                      gender = 'Female';
                                    });
                                  },
                                ),
                                new Text(
                                  DemoLocalization.of(context)
                                      .translate("female"),
                                  style: new TextStyle(
                                    fontSize: 15.0,
                                  ),
                                ),
                                Radio(
                                  value: 3,
                                  groupValue: genderRadio,
                                  onChanged: (val) {
                                    setState(() {
                                      genderRadio = val;
                                      gender = 'Other';
                                    });
                                  },
                                ),
                                Text(
                                  DemoLocalization.of(context)
                                      .translate("other"),
                                  style: new TextStyle(
                                    fontSize: 15.0,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.0),
                            Container(
                              height: 50,
                              width: double.infinity,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Color.fromRGBO(03, 43, 68, 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: EdgeInsets.all(12),
                                  ),
                                  child: Text(
                                    DemoLocalization.of(context)
                                        .translate("register"),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState.validate()) {
                                      setState(() => loading = true);
                                      DatabaseService(uid: user.uid)
                                          .updateProfileData(
                                              name ?? snapshot.data.name,
                                              phone ?? snapshot.data.phone,
                                              address ?? snapshot.data.address,
                                              gender ?? snapshot.data.gender,
                                              dob ?? snapshot.data.dob,
                                              regdate);
                                      /*
                                        dynamic result = 
                                        if (result == null) {
                                          setState(() {
                                            setState(() => loading = true);
                                            error =
                                                DemoLocalization.of(context).translate("invalid_email");
                                          });
                                          }
                                          */
                                    }
                                  }),
                            ),
                            SizedBox(height: 5.0),
                            Text(
                              error,
                              style:
                                  TextStyle(color: Colors.red, fontSize: 10.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ));
          } else {
            return Loading();
          }
        });
  }
}
