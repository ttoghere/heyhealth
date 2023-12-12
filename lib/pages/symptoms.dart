// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:heyhealth/localisations/local_lang.dart';

class Symptoms extends StatefulWidget {
  final dynamic docdetails;
  final String dateDoc;
  final String selectedslot;
  final String bookingtype;
  final String docaddress;
  const Symptoms({
    Key? key,
    required this.docdetails,
    required this.dateDoc,
    required this.selectedslot,
    required this.bookingtype,
    required this.docaddress,
  }) : super(key: key);
  @override
  _SymptomslistState createState() => _SymptomslistState(
      docdetails, dateDoc, selectedslot, bookingtype, docaddress);
  //@override
  //SymptomslistState createState() => new SymptomslistState();
}

class _SymptomslistState extends State<Symptoms> {
  dynamic doctordetails;
  String date;
  String slot;
  String appointmenttype;
  String doctorworkplaceaddress;
  _SymptomslistState(
      doctordetails, date, slot, appointmenttype, doctorworkplaceaddress);

  @override
  void initState() {
    doctordetails = (widget.docdetails);
    date = (widget.dateDoc);
    slot = (widget.selectedslot);
    appointmenttype = (widget.bookingtype);
    doctorworkplaceaddress = (widget.docaddress);
    super.initState();
  }

  Map<String, bool> symptomsList = {
    "Cough": false,
    "Sneezing": false,
    "Running Nose": false,
    'Fever': false,
    'Nausea': false,
    'Nasal Congestion': false,
    'Sputum': false,
    'Chest Congestion': false,
    'Muscle pain': false,
    'Bone pain': false,
    'Chest pain': false,
    'Vomiting': false,
    'Fatigue': false,
    'Abdominal pain': false,
    'Loss of appetite': false,
    'Diarrhoea': false,
  };

  var holder_1 = [];

  Future<void> _addSymptomsToDatabase(String did, String dat, String tim,
      var symptomsarray, String type) async {
    try {
      // Add location and url to database
      await FirebaseFirestore.instance
          .collection('doctor')
          .doc(did)
          .collection('bookings')
          .doc(dat)
          .update({"booked_slots.$tim.symptoms": symptomsarray});
    } catch (e) {
      print(e.message);

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message),
            );
          });
    }
  }

  getItems() {
    symptomsList.forEach((key, value) {
      if (value == true) {
        holder_1.add(key);
      }
    });
    _addSymptomsToDatabase(
        doctordetails.id, date, slot, holder_1, appointmenttype);
    // Printing all selected items on Terminal screen.
    print(holder_1);
    // Here you will get all your selected Checkbox items.

    // Clear array after use.
    holder_1.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            padding: EdgeInsets.only(top: 40),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    color: Theme.of(context).primaryColor,
                    padding: EdgeInsets.only(left: 10, top: 20),
                    child: Text(
                      DemoLocalization.of(context).translate("symptoms"),
                      style: TextStyle(
                        fontFamily: "Montserrat-Bold",
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: Theme.of(context).primaryColor,
                    padding: EdgeInsets.only(left: 10, top: 10, bottom: 15),
                    child: Text(
                      DemoLocalization.of(context).translate("select_problem"),
                      style: TextStyle(
                        fontFamily: "Montserrat-Bold",
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: symptomsList.keys.map((String key) {
                        return new Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            child: CheckboxListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              tileColor: Colors.blueGrey[50],
                              selectedTileColor: Colors.teal,
                              title: new Text(
                                DemoLocalization.of(context).translate(key),
                                style: TextStyle(
                                    color: symptomsList[key] == false
                                        ? Colors.black
                                        : Colors.white),
                              ),
                              selected: symptomsList[key],
                              value: symptomsList[key],
                              activeColor: Colors.teal,
                              checkColor: Colors.white,
                              onChanged: (bool value) {
                                setState(() {
                                  symptomsList[key] = value;
                                });
                              },
                            ));
                      }).toList(),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[900],
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    child: TextButton(
                      child:
                          Text(DemoLocalization.of(context).translate("submit"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                              )),
                      onPressed: () {
                        getItems();
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                    ),
                  ),
                ])));
  }
}
