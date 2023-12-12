import 'package:heyhealth/models/user.dart';
import 'package:heyhealth/services/database.dart';
import 'package:heyhealth/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:heyhealth/shared/loading.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // For Image Picker
import 'package:heyhealth/localisations/local_lang.dart';

class Profile extends StatefulWidget {
  Profile({this.isfromdrawer});
  final bool isfromdrawer;
  @override
  _SettingsFormState createState() => _SettingsFormState();
}

class _SettingsFormState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  XFile _image;
  String _uploadedFileURL;
  auth.User user;
  // form values
  String _currentName;
  String _currentPhone;
  String _currentDob;
  String _currentAddress;
  String _currentGender;
  @override
  void initState() {
    super.initState();
    this.user = auth.FirebaseAuth.instance.currentUser;
    _uploadedFileURL = 'https://image.flaticon.com/icons/png/512/50/50446.png';
    try {
      Reference storageReference =
          FirebaseStorage.instance.ref().child('profiles/${user.uid}.jpg');
      print(storageReference);
      downloadS(storageReference).then((String result) {
        if (result != null) {
          setState(() {
            _uploadedFileURL = result;
          });
        }
      });
    } catch (error) {}
  }

  Future<void> add2DB(imageLocation) async {
    final ref = FirebaseStorage.instance.ref().child(imageLocation);
    var imageurl = await ref.getDownloadURL();
    print(DemoLocalization.of(context).translate("hello") + imageurl);
    await FirebaseFirestore.instance
        .collection('patients')
        .doc(user.uid)
        .update({
      "profilelocation": imageLocation,
      "profileurl": imageurl.toString()
    });
  }

  Future<String> downloadS(Reference s) async {
    try {
      return await s.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserData>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          print("checking has data");
          print(snapshot.data);
          if (snapshot.hasData) {
            UserData userData = snapshot.data;
            return Scaffold(
              appBar: (widget.isfromdrawer == true)
                  ? AppBar(
                      //iconTheme: IconThemeData(color: Colors.black),
                      backgroundColor: Colors.teal[900],
                      title: Text(DemoLocalization.of(context)
                          .translate("heyhealth_profile")),
                    )
                  : null,
              body: Container(
                color: Colors.grey[100],
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Container(
                          alignment: Alignment.center,
                          child: SingleChildScrollView(
                            // new line
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(top: 20, left: 5),
                                  child: Text(
                                    DemoLocalization.of(context)
                                        .translate("profile_picture"),
                                    style: TextStyle(
                                      fontFamily: "Montserrat-Bold",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  child: Container(
                                      width: 140,
                                      height: 140,
                                      margin: EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        borderRadius: new BorderRadius.all(
                                          Radius.circular(20.0),
                                        ),
                                        image: DecorationImage(
                                            image: userData.profileurl != ""
                                                ? NetworkImage(
                                                    userData.profileurl)
                                                : NetworkImage(
                                                    _uploadedFileURL),
                                            fit: BoxFit.scaleDown),
                                      )),
                                  onTap: () async {
                                    //_uploadedFileURL = await storageReference.getDownloadURL();
                                  },
                                ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.teal[900],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding: EdgeInsets.all(12),
                                    ),
                                    child: Text(
                                      DemoLocalization.of(context)
                                          .translate("change_picture"),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                    onPressed: () async {
                                      _image = await ImagePicker().pickImage(
                                          source: ImageSource.gallery,
                                          maxHeight: 256,
                                          maxWidth: 256);
                                      String imageLocation =
                                          'patient_profiles/${user.uid}.jpg';
                                      Reference storageReference =
                                          FirebaseStorage.instance
                                              .ref()
                                              .child(imageLocation);
                                      UploadTask uploadTask = storageReference
                                          .putFile(File(_image.path));
                                      uploadTask.then((res) {
                                        add2DB(imageLocation);
                                        print(DemoLocalization.of(context)
                                            .translate("file_uploaded"));
                                      });
                                    }),
                                SizedBox(height: 20.0),
                                TextFormField(
                                  //readOnly: true,
                                  initialValue: userData.name,
                                  decoration: textInputDecoration.copyWith(
                                      hintText: DemoLocalization.of(context)
                                          .translate("your_name"),
                                      labelText: DemoLocalization.of(context)
                                          .translate("full_name")),
                                  validator: (val) => val.isEmpty
                                      ? DemoLocalization.of(context)
                                          .translate("enter_name")
                                      : null,
                                  onChanged: (val) =>
                                      setState(() => _currentName = val),
                                ),
                                SizedBox(height: 20.0),
                                TextFormField(
                                  initialValue: userData.phone,
                                  decoration: textInputDecoration.copyWith(
                                      hintText: DemoLocalization.of(context)
                                          .translate("phone_no"),
                                      labelText: DemoLocalization.of(context)
                                          .translate("phone_no")),
                                  validator: (val) => val.isEmpty
                                      ? DemoLocalization.of(context)
                                          .translate("invalid_phone_no")
                                      : null,
                                  onChanged: (val) =>
                                      setState(() => _currentPhone = val),
                                ),
                                SizedBox(height: 20.0),
                                TextFormField(
                                  initialValue: userData.address,
                                  decoration: textInputDecoration.copyWith(
                                      hintText: DemoLocalization.of(context)
                                          .translate("hint_Address"),
                                      labelText: DemoLocalization.of(context)
                                          .translate("address")),
                                  validator: (val) => val.isEmpty
                                      ? DemoLocalization.of(context)
                                          .translate("invalid_address")
                                      : null,
                                  onChanged: (val) =>
                                      setState(() => _currentAddress = val),
                                ),
                                SizedBox(height: 20.0),
                                TextFormField(
                                  readOnly: true,
                                  initialValue: userData.gender,
                                  decoration: textInputDecoration.copyWith(
                                      labelText: DemoLocalization.of(context)
                                          .translate("gender"),
                                      hintText: DemoLocalization.of(context)
                                          .translate("male/female")),
                                  validator: (val) => val.isEmpty
                                      ? DemoLocalization.of(context)
                                          .translate("gender_can't_empty")
                                      : null,
                                  onChanged: (val) =>
                                      setState(() => _currentGender = val),
                                ),
                                SizedBox(height: 20.0),
                                TextFormField(
                                  initialValue: userData.dob.toString(),
                                  decoration: textInputDecoration.copyWith(
                                      labelText: DemoLocalization.of(context)
                                          .translate("label_DOB"),
                                      hintText: DemoLocalization.of(context)
                                          .translate("hint_DOB")),
                                  onChanged: (val) =>
                                      setState(() => _currentDob = val),
                                ),
                                Divider(),
                                SizedBox(height: 10.0),
                                SizedBox(
                                  width: 300,
                                  height: 50,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.teal[600],
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30))),
                                      child: Text(
                                        DemoLocalization.of(context)
                                            .translate("update"),
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                      onPressed: () async {
                                        print("**xy**");
                                        if (_formKey.currentState.validate()) {
                                          print("**xx**");
                                          await DatabaseService(uid: user.uid)
                                              .updateProfileData(
                                                  _currentName ??
                                                      snapshot.data.name,
                                                  _currentPhone ??
                                                      snapshot.data.phone,
                                                  _currentAddress ??
                                                      snapshot.data.address,
                                                  _currentGender ??
                                                      snapshot.data.gender,
                                                  _currentDob ??
                                                      snapshot.data.dob,
                                                  snapshot.data.regdate == null
                                                      ? ""
                                                      : snapshot.data.regdate);
                                          Navigator.popUntil(context,
                                              (route) => route.isFirst);
                                        } else {
                                          Navigator.popUntil(context,
                                              (route) => route.isFirst);
                                        }
                                      }),
                                ),
                                SizedBox(height: 10.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Loading();
          }
        });
  }
}
