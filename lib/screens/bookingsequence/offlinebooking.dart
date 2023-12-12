// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:heyhealth/pages/symptoms.dart';
import 'package:heyhealth/shared/loading.dart';
import 'package:heyhealth/shared/methods.dart';
import 'package:provider/provider.dart';
import 'package:heyhealth/services/notification_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:heyhealth/localisations/local_lang.dart';

class Bookingscreen extends StatefulWidget {
  final dynamic details;
  final String dateDoc;
  final String selecslot;
  final String bookingtype;
  final String docaddress;
  final String patientuid;
  final String patientname;
  final String patientdob;
  final String patientphone;
  final String patientgender;
  final String patientaddress;
  final bool patientfromreception;
  const Bookingscreen({
    Key? key,
    required this.details,
    required this.dateDoc,
    required this.selecslot,
    required this.bookingtype,
    required this.docaddress,
    required this.patientuid,
    required this.patientname,
    required this.patientdob,
    required this.patientphone,
    required this.patientgender,
    required this.patientaddress,
    required this.patientfromreception,
  }) : super(key: key);
  @override
  _BookingscreenState createState() => _BookingscreenState(
      details,
      dateDoc,
      selecslot,
      bookingtype,
      docaddress,
      patientuid,
      patientname,
      patientdob,
      patientphone,
      patientgender,
      patientaddress,
      patientfromreception);
}

class _BookingscreenState extends State<Bookingscreen> {
  dynamic doctordetails;
  String date;
  String slot;
  String appointmenttype;
  String doctorworkplaceaddress;
  String patuid;
  String patname;
  String patdob;
  String patphone;
  String patgender;
  String pataddress;
  bool fromreception;
  _BookingscreenState(
      doctordetails,
      date,
      slot,
      appointmenttype,
      doctorworkplaceaddress,
      patuid,
      patname,
      patdob,
      patphone,
      patgender,
      pataddress,
      fromreception);
  NotificationPlugin plugin = new NotificationPlugin();

  Razorpay _razorpay;
  bool fromreceptionbooking = false;
  int genderRadio;
  final _otherbookingformKey = GlobalKey<FormState>();

  @override
  void initState() {
    doctordetails = (widget.details);
    date = (widget.dateDoc);
    slot = (widget.selecslot);
    appointmenttype = (widget.bookingtype);
    doctorworkplaceaddress = (widget.docaddress);
    patuid = (widget.patientuid);
    patname = (widget.patientname);
    patdob = (widget.patientdob);
    patphone = (widget.patientphone);
    patgender = (widget.patientgender);
    pataddress = (widget.patientaddress);
    fromreception = (widget.patientfromreception);
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout() async {
    var options = {
      'key': 'rzp_live_40oWNn1jW8c9HN',
      'amount': '3900',
      'name': 'heyhealth',
      'timeout': 240,
      'description': 'Booking convenience fee',
      'prefill': {
        'contact': '91' + patphone,
        'email': 'startupdoc2020@gmail.com'
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    await _addBookingToDatabase(
        patuid,
        doctordetails.id,
        date,
        slot,
        doctordetails['name'],
        appointmenttype,
        patname,
        patdob,
        patphone,
        patgender,
        pataddress,
        false);
    appointmenttype == "video"
        ? Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Symptoms(
                      docdetails: doctordetails,
                      dateDoc: date,
                      selectedslot: slot,
                      bookingtype: "video",
                      docaddress: "online",
                    )),
          )
        : Navigator.popUntil(context, (route) => route.isFirst);
    Fluttertoast.showToast(
        msg: "SUCCESS: " + response.paymentId, toastLength: Toast.LENGTH_SHORT);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "ERROR: " + response.code.toString() + " - " + response.message,
        toastLength: Toast.LENGTH_SHORT);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName,
        toastLength: Toast.LENGTH_SHORT);
  }

  Future<void> _addBookingToDatabase(
      String uid,
      String did,
      String dat,
      String tim,
      String docname,
      String type,
      String patname,
      String patage,
      String patphone,
      String patgender,
      String pataddress,
      bool onsitebooking) async {
    try {
      int appId = DateTime.now().hashCode;
      plugin.appointment(
          RecievedNotification(
              id: ((appId ~/ 10) * 10 + 1),
              title: DemoLocalization.of(context)
                      .translate("appointment_with_dr") +
                  docname +
                  DemoLocalization.of(context).translate("with"),
              body: DemoLocalization.of(context)
                  .translate("reminder_appointment_today_in_an_hour"),
              // $docname at " +
              // to12hr(tim) +
              // " on $did",
              payload: "test"),
          tim,
          dat,
          docname);
      plugin.bookingconfirmed(
          RecievedNotification(
              id: ((appId ~/ 10) * 10 + 2),
              title: DemoLocalization.of(context)
                      .translate("appointment_with_dr") +
                  docname +
                  DemoLocalization.of(context).translate("with"),
              body:
                  DemoLocalization.of(context).translate("appointment_booked"),
              // $docname at " +
              // to12hr(tim) +
              // " on $did",
              payload: "test"),
          tim,
          dat,
          docname);

      if (FirebaseFirestore.instance
              .collection('patients')
              .doc(uid)
              .collection('appointments') ==
          null) {
        FirebaseFirestore.instance
            .collection('patients')
            .doc(uid)
            .collection('appointments')
            .add({});
      } else {
        (appointmenttype == "video")
            ?
            // Add location and url to database
            await FirebaseFirestore.instance
                .collection('doctor')
                .doc(did)
                .collection('bookings')
                .doc(dat)
                .update({
                "booked_slots.$tim": {
                  "Patient_name": patname,
                  "patient_age": patage,
                  "Patient_phoneno": patphone,
                  "Patient_address": pataddress,
                  "gender": patgender,
                  "app_use": true,
                  "booking": 'true',
                  "pid": uid,
                  "completion": "",
                  "reporting": 0,
                  "booking_type": "teleconsult"
                }
              })
            : await FirebaseFirestore.instance
                .collection('doctor')
                .doc(did)
                .collection('bookings')
                .doc(dat)
                .update({
                "booked_slots.$tim": {
                  "Patient_name": patname,
                  "patient_age": patage,
                  "Patient_phoneno": patphone,
                  "Patient_address": pataddress,
                  "gender": patgender,
                  "app_use": true,
                  "booking": 'true',
                  "pid": uid,
                  "completion": "",
                  "reporting": 0,
                }
              });
        if (appointmenttype == "video") {
          await FirebaseFirestore.instance
              .collection('doctor')
              .doc(did)
              .update({
            "patients_count.$dat": FieldValue.increment(1),
            "patients_count_teleconsult.$dat": FieldValue.increment(1)
          });
        }
        if ((appointmenttype != "video") && (onsitebooking == true)) {
          await FirebaseFirestore.instance
              .collection('doctor')
              .doc(did)
              .update({
            "patients_count.$dat": FieldValue.increment(1),
            "patients_count_app_onsite.$dat": FieldValue.increment(1)
          });
        }
        if ((appointmenttype != "video") && (onsitebooking == false)) {
          await FirebaseFirestore.instance
              .collection('doctor')
              .doc(did)
              .update({
            "patients_count.$dat": FieldValue.increment(1),
            "patients_count_app_remote.$dat": FieldValue.increment(1)
          });
        }
        await FirebaseFirestore.instance
            .collection('patients')
            .doc(uid)
            .collection('appointments')
            .doc()
            .set({
          'doctorid': did,
          'docspecialization': doctordetails['specialization'],
          'docname': doctordetails['name'],
          'patientid': uid,
          'appointmenttime': tim,
          'appointmentdate': dat,
          'appointmenttype': type,
          'bookingtimestamp': FieldValue.serverTimestamp(),
        });
        if (appointmenttype == "video") {
          await FirebaseFirestore.instance
              .collection('patients')
              .doc(uid)
              .update({
            "bookings_count": FieldValue.increment(1),
            "bookings_count_teleconsult": FieldValue.increment(1),
            "booked_specialization.${doctordetails['specialization']}.count":
                FieldValue.increment(1),
            "booked_doctors.$did.count": FieldValue.increment(1),
            "booked_doctors.$did.docname": doctordetails['name'],
            "booked_doctors.$did.docspecialization":
                doctordetails['specialization'],
          });
        }
        if ((appointmenttype != "video") && (onsitebooking == true)) {
          await FirebaseFirestore.instance
              .collection('patients')
              .doc(uid)
              .update({
            "bookings_count": FieldValue.increment(1),
            "bookings_count_app_onsite": FieldValue.increment(1),
            "booked_specialization.${doctordetails['specialization']}.count":
                FieldValue.increment(1),
            "booked_doctors.$did.count": FieldValue.increment(1),
            "booked_doctors.$did.docname": doctordetails['name'],
            "booked_doctors.$did.docspecialization":
                doctordetails['specialization'],
          });
        }
        if ((appointmenttype != "video") && (onsitebooking == false)) {
          await FirebaseFirestore.instance
              .collection('patients')
              .doc(uid)
              .update({
            "bookings_count": FieldValue.increment(1),
            "bookings_count_app_remote": FieldValue.increment(1),
            "booked_specialization.${doctordetails['specialization']}.count":
                FieldValue.increment(1),
            "booked_doctors.$did.count": FieldValue.increment(1),
            "booked_doctors.$did.docname": doctordetails['name'],
            "booked_doctors.$did.docspecialization":
                doctordetails['specialization'],
          });
        }
      }

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      print(e.message);
      setState(() {
        fromreceptionbooking = false;
      });
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message),
            );
          });
    }
  }

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
        patdob = selectedDate.day.toString() +
            '/' +
            selectedDate.month.toString() +
            '/' +
            selectedDate.year.toString();
      });
  }

  Widget otherbooking() {
    return StatefulBuilder(builder: (context, setState) {
      return Form(
          key: _otherbookingformKey,
          child: Container(
            padding: EdgeInsets.only(top: 10, bottom: 5),
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    color: Colors.teal[50],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back,
                              size: 30,
                            )),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          "Relative Details ",
                          style: TextStyle(
                            color: Colors.teal[900],
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Patient Name ',
                        hintText: 'eg : Ravi kumar',
                        contentPadding: EdgeInsets.all(8),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Name can not be empty!';
                        }
                        return null;
                      },
                      onChanged: (val) => setState(() => patname = val),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Patient Age ',
                        hintText: 'eg : 34',
                        contentPadding: EdgeInsets.all(8),
                      ),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Age can not be empty!';
                        }
                        return null;
                      },
                      onChanged: (val) =>
                          setState(() => patdob = val.toString()),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Patient Address ',
                        hintText: 'eg : house no 4 ,abc road , city',
                        contentPadding: EdgeInsets.all(8),
                      ),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Address can not be empty!';
                        }
                        return null;
                      },
                      onChanged: (val) => setState(() => pataddress = val),
                    ),
                  ),
                  /*
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Gender ',
                      hintText: 'eg : Male/Female',
                    ),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w400,
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Gender can not be empty!';
                      }
                      return null;
                    },
                    onChanged: (val) => setState(() => patgender = val),
                  ),
                ),
                */
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    'Patient Gender ',
                    style: new TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontSize: 19.0,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Radio(
                          fillColor: MaterialStateColor.resolveWith(
                              (states) => Colors.black),
                          value: 1,
                          groupValue: genderRadio,
                          onChanged: (val) {
                            // printf("Radio $val");
                            setState(() {
                              genderRadio = val;
                              // printf(gender);
                              patgender = 'Male';
                            });
                          },
                        ),
                        new Text(
                          'Male',
                          style: new TextStyle(
                            fontSize: 18.0,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Radio(
                          value: 2,
                          groupValue: genderRadio,
                          fillColor: MaterialStateColor.resolveWith(
                              (states) => Colors.black),
                          onChanged: (val) {
                            // printf("Radio $val");
                            setState(() {
                              genderRadio = val;
                              patgender = 'Female';
                            });
                          },
                        ),
                        new Text(
                          'Female',
                          style: new TextStyle(
                            fontSize: 18.0,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 70,
                    width: 200,
                    padding: const EdgeInsets.all(15.0),
                    child: MaterialButton(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: () async {
                        if (_otherbookingformKey.currentState.validate()) {
                          print(patgender);
                          _otherbookingformKey.currentState.save();
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ));
    });
  }

  void _showotherbookingPanel() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * .8,
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
            child: SingleChildScrollView(child: otherbooking()),
          );
        });
  }

  Widget bookingpage(data) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctor')
            .doc(doctordetails.id)
            .collection('bookings')
            .doc(date)
            .snapshots(),
        builder: (context, snapshot) {
          return Container(
            child: Column(children: [
              Row(
                children: <Widget>[
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Container(
                        padding: const EdgeInsets.all(3),
                        child: Column(
                          children: <Widget>[
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image(
                                  image: NetworkImage(data
                                              .data()['profileurl'] ==
                                          ""
                                      ? 'https://icons.iconarchive.com/icons/aha-soft/free-large-boss/512/Head-Physician-icon.png'
                                      : data.data()['profileurl']),
                                  width: 100,
                                  height: 110,
                                ),
                              ),
                            ),
                          ],
                        )),
                  ),
                  Expanded(
                      child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(bottom: 5, left: 15),
                        child: Text(
                          DemoLocalization.of(context).translate("dr") +
                              data['name'],
                          style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(bottom: 5, left: 15),
                        child: Text(
                          data['specialization'],
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(top: 5, bottom: 5, left: 15),
                          child: Text(
                              appointmenttype != "video"
                                  ? DemoLocalization.of(context)
                                      .translate("one_to_one_appointment")
                                  : DemoLocalization.of(context).translate(
                                      "video_consultation_appointment"),
                              style: TextStyle(
                                  color: appointmenttype != "video"
                                      ? Colors.cyan[800]
                                      : Colors.purple[800],
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500))),
                      /*
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(bottom: 5, left: 15),
                  child: Text(
                    doctorworkplaceaddress,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16.0,
                    ),
                  ),
                ),
                */
                    ],
                  ))
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Table(columnWidths: {
                  0: FlexColumnWidth(1), // fixed to 100 width
                  1: FlexColumnWidth(1),
                }, children: [
                  TableRow(children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: Text(
                        DemoLocalization.of(context)
                            .translate("time_of_appointment"),
                        style: TextStyle(
                          color: Colors.blueGrey[800],
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: Text(
                        DemoLocalization.of(context)
                            .translate("date_of_appointment"),
                        style: TextStyle(
                          color: Colors.blueGrey[800],
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ]),
                  TableRow(children: [
                    Container(
                      margin: EdgeInsets.only(right: 10, top: 5),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: appointmenttype != "video"
                            ? Colors.teal[50]
                            : Colors.deepPurple[50],
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      child: Text(
                        to12hr(slot),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 10, top: 5),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: appointmenttype != "video"
                            ? Colors.teal[50]
                            : Colors.deepPurple[50],
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      child: Text(
                        date,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ]),
                ]),
              ),
              Divider(color: Colors.black38),
              Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  height: 60,
                  child: ElevatedButton(
                    //highlightElevation: 10,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(5),
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0)),
                      primary: Colors.blueGrey[800],
                      onPrimary: Colors.white,
                    ),
                    onPressed: () => _showotherbookingPanel(),

                    //borderSide: BorderSide(color: gridslot[id][index][1]),
                    //color: pressAttention ? Colors.green : Colors.blue,
                    child: Text(
                      "Book Slot for Relative",
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                  )),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 15, bottom: 5, left: 15),
                child: Text(
                  DemoLocalization.of(context).translate("your_details"),
                  style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Table(columnWidths: {
                  0: FlexColumnWidth(2), // fixed to 100 width
                  1: FlexColumnWidth(5),
                }, children: [
                  TableRow(children: [
                    Text(
                      DemoLocalization.of(context).translate("name"),
                      style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      patname,
                      style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600),
                    ),
                  ]),
                  TableRow(children: [
                    Text(
                      DemoLocalization.of(context).translate("Ph_No"),
                      style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      patphone,
                      style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600),
                    ),
                  ]),
                  TableRow(children: [
                    Text(
                      DemoLocalization.of(context).translate("DOB"),
                      style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      patdob,
                      style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600),
                    ),
                  ]),
                  TableRow(children: [
                    Text(
                      DemoLocalization.of(context).translate("gender"),
                      style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      patgender,
                      style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600),
                    ),
                  ]),
                  TableRow(children: [
                    Text(
                      DemoLocalization.of(context).translate("address"),
                      style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      pataddress,
                      style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600),
                    ),
                  ])
                ]),
              ),
              Divider(color: Colors.black38),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 5, bottom: 5, left: 15),
                child: Text(
                  fromreception == true
                      ? ""
                      : "heyhealth booking convenience fee :  39 Rs",
                  style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Divider(color: Colors.black38),
              Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[900],
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: ElevatedButton(
                    //highlightElevation: 10,
                    style: ElevatedButton.styleFrom(
                      elevation: 1,
                      padding: EdgeInsets.all(5),
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(12.0)),
                      onPrimary: Colors.green,
                      primary: appointmenttype != "video"
                          ? Color.fromRGBO(5, 105, 255, 1)
                          : Colors.deepPurple[700],
                    ),
                    onPressed: () {
                      if (fromreception != true) {
                        if (snapshot.data["booked_slots"][slot] == null) {
                          openCheckout();
                        } else {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Try Booking Again"),
                                  content: Text(
                                      "The slot has already been booked by someone else"),
                                );
                              });
                        }
                      } else {
                        if (snapshot.data["booked_slots"][slot] == null) {
                          setState(() {
                            fromreceptionbooking = true;
                          });
                          _addBookingToDatabase(
                              patuid,
                              doctordetails.id,
                              date,
                              slot,
                              doctordetails['name'],
                              appointmenttype,
                              patname,
                              patdob,
                              patphone,
                              patgender,
                              pataddress,
                              true);
                        } else {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Scan QR Code Again"),
                                  content: Text(
                                      "The slot has already been booked by someone else"),
                                );
                              });
                        }
                      }
                    },

                    //borderSide: BorderSide(color: gridslot[id][index][1]),
                    //color: pressAttention ? Colors.green : Colors.blue,
                    child: Text(
                      fromreception == true
                          ? DemoLocalization.of(context)
                              .translate("confirm_booking")
                          : "proceed to pay",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ))
            ]),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    print(date);

    //User user = Provider.of<User>(context);
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.blueGrey[100],
          title: Text(
            DemoLocalization.of(context).translate("booking_details"),
            style: TextStyle(color: Colors.black),
          ),
          elevation: 0,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Container(
                height: screenHeight,
                color: Theme.of(context).primaryColor,
                child: SingleChildScrollView(
                  child: fromreceptionbooking == false
                      ? bookingpage(doctordetails)
                      : Loading(),
                )),
          ],
        ));
  }
}
