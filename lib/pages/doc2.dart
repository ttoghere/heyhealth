// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';

import 'package:heyhealth/localisations/local_lang.dart';
import 'package:heyhealth/maps/docpagemap.dart';
import 'package:heyhealth/screens/bookingsequence/offlineslottable.dart';

class DocPage2 extends StatefulWidget {
  DocPage2(
      {Key key, this.title, this.clickedDoc, this.appointmentfromreception})
      : super(key: key);
  final String title;
  final String clickedDoc;
  final bool appointmentfromreception;
  @override
  DocPage2State createState() =>
      DocPage2State(title, clickedDoc, appointmentfromreception);
}

class DocPage2State extends State<DocPage2> {
  bool click = false;
  bool appointment = true;
  Color _starColor = Colors.white;
  var _starIcon = Icons.favorite;
  String docpagetitle = '';
  String docpageDoc = '';
  bool fromreception = false;
  var bookedata;
  String error;
  DocPage2State(docpagetitle, docpageDoc, fromreception);
  String _linkMessage;
  bool _isCreatingLink = false;
  //List docdata = [];
  bool _toBook = false;
  List<String> carouselImages = [
    "assets/onboard/find_docs.png",
    "assets/onboard/appointment.png",
    "assets/auth/patient-login.png",
    "assets/auth/patient-register.jpg",
  ];

  @override
  void initState() {
    docpagetitle = (widget.title);
    docpageDoc = (widget.clickedDoc);
    fromreception = (widget.appointmentfromreception);
    super.initState();
  }

  void setError(e) {
    setState(() {
      this.error = e.toString();
    });
  }

  Future<void> addbookingdate(String date) async {
    try {
      // Get image URL from firebase
      print(date);

      if (FirebaseFirestore.instance
              .collection('doctor')
              .doc(docpageDoc)
              .collection('bookings') ==
          null) {
        FirebaseFirestore.instance
            .collection('doctor')
            .doc(docpageDoc)
            .collection('bookings')
            .add({});
        print('created');
        await FirebaseFirestore.instance
            .collection('doctor')
            .doc(docpageDoc)
            .collection('bookings')
            .doc(date)
            .set({'booked_slots': {}});
      }
      final snapShot = await FirebaseFirestore.instance
          .collection('doctor')
          .doc(docpageDoc)
          .collection('bookings')
          .doc(date)
          .get();
      if (!snapShot.exists) {
        //it does not exists
        await FirebaseFirestore.instance
            .collection('doctor')
            .doc(docpageDoc)
            .collection('bookings')
            .doc(date)
            .set({'booked_slots': {}});
      }
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

  Widget tabledate(text, dataofdoc, which, noofplaces) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctor')
            .doc(docpageDoc)
            .collection('bookings')
            .doc(text)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          //print('This here ${snapshot.data}');
          bookedata = snapshot.data;
          //print(bookedata['booked_slots']);
          return (which == "offline")
              ? (noofplaces == "1")
                  ? fromreception == true
                      ? Container(
                          color: Colors.teal[50],
                          child: Offlineslottable(
                            docslotperhr: dataofdoc['slots_per_hour1'],
                            timings: dataofdoc['working_hours1'],
                            bslots: bookedata['booked_slots'],
                            docuidoffline: dataofdoc,
                            date: text,
                            type: which,
                            reception: true,
                          ))
                      : Container(
                          color: Colors.white,
                          child: Offlineslottable(
                            docslotperhr: dataofdoc['slots_per_hour1'],
                            timings: dataofdoc['working_hours1'],
                            bslots: bookedata['booked_slots'],
                            docuidoffline: dataofdoc,
                            date: text,
                            type: which,
                          ))
                  : fromreception == true
                      ? Container(
                          color: Colors.teal[50],
                          child: Offlineslottable(
                            docslotperhr: dataofdoc['slots_per_hour1'],
                            timings: dataofdoc['working_hours1'],
                            bslots: bookedata['booked_slots'],
                            docuidoffline: dataofdoc,
                            date: text,
                            type: which,
                            reception: true,
                          ))
                      : Container(
                          color: Colors.white,
                          child: Offlineslottable(
                            docslotperhr: dataofdoc['slots_per_hour2'],
                            timings: dataofdoc['working_hours2'],
                            bslots: bookedata['booked_slots'],
                            docuidoffline: dataofdoc,
                            date: text,
                            type: which,
                          ))
              : Container(
                  color: Colors.white,
                  child: Offlineslottable(
                    docslotperhr: dataofdoc['videocall_per_hour'],
                    timings: dataofdoc['teleworking_hours'],
                    bslots: bookedata['booked_slots'],
                    docuidoffline: dataofdoc,
                    date: text,
                    type: which,
                  ));
        });
  }

  Widget ratingBar(rating) {
    List<Widget> stars = [];
    for (var i = 0; i < rating.floor(); i++) {
      stars.add(
        Icon(
          Icons.star,
          color: Colors.black,
        ),
      );
    }
    if (rating - rating.floor() >= 0.5) {
      stars.add(
        Icon(
          Icons.star_half,
          color: Colors.black,
        ),
      );
      for (var i = 0; i < 4 - rating.floor(); i++) {
        stars.add(
          Icon(
            Icons.star,
            color: Color.fromRGBO(0, 0, 0, 0.3),
          ),
        );
      }
    } else {
      for (var i = 0; i < 5 - rating.floor(); i++) {
        stars.add(
          Icon(
            Icons.star,
            color: Color.fromRGBO(0, 0, 0, 0.3),
          ),
        );
      }
    }
    stars.add(
      Container(
        margin: EdgeInsets.only(
          top: 2.5,
          left: 5,
        ),
        child: Text(
          "(123)",
          style: TextStyle(
            color: Color.fromRGBO(0, 0, 0, 0.9),
            fontSize: 15,
          ),
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Customer Reviews",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Row(
          children: stars,
        ),
      ],
    );
  }

  Widget appointmentcard2(data) {
    return Container(
      // color: Color(0xFFF5F5F5),

      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CarouselSlider(
                options: CarouselOptions(height: 200.0),
                items: carouselImages.map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(color: Colors.amber),
                        child: Image.asset(
                          i,
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Color(0xFF04385F),
                      width: 4,
                    ),
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        data.data()['profileurl'] == ""
                            ? 'https://icons.iconarchive.com/icons/aha-soft/free-large-boss/512/Head-Physician-icon.png'
                            : data.data()['profileurl'],
                        fit: BoxFit.cover,
                      )),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DemoLocalization.of(context).translate("dr") + data['name'],
                  style: TextStyle(
                    fontSize: 21,
                    color: Color.fromRGBO(0, 0, 0, 1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  data['specialization'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(0, 0, 0, 0.9),
                  ),
                ),
                /*
                          Text(
                            DemoLocalization.of(context)
                                .translate("10_years_exp"),
                            style: TextStyle(
                              fontSize: 13,
                              color: Color.fromRGBO(0, 0, 0, 0.9),
                            ),
                          ),
                          */

                Text(
                  data['workplaceaddress1'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Color.fromRGBO(0, 0, 0, 1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Fee/Consult first time",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Fee/Subsequent time",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Divider(
            color: Color(0xFFEEEEEE),
          ),
          // ratingBar(3.67),
        ],
      ),
    );
  }

  Widget appointmentcard(data) {
    return InkWell(
      splashColor: Colors.blue.withAlpha(30),
      onTap: () {},
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 5,
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Container(
                      height: 110,
                      width: 90,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[50],
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),

                        //padding: EdgeInsets.only(top: 10, bottom: 10),
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(data.data()['profileurl'] == ""
                                ? 'https://icons.iconarchive.com/icons/aha-soft/free-large-boss/512/Head-Physician-icon.png'
                                : data.data()['profileurl'])),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DemoLocalization.of(context).translate("dr") +
                                data['name'],
                            style: TextStyle(
                              fontSize: 21,
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            data['specialization'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromRGBO(0, 0, 0, 0.9),
                            ),
                          ),
                          /*
                          Text(
                            DemoLocalization.of(context)
                                .translate("10_years_exp"),
                            style: TextStyle(
                              fontSize: 13,
                              color: Color.fromRGBO(0, 0, 0, 0.9),
                            ),
                          ),
                          */
                          ratingBar(3.67),
                          Text(
                            data['workplaceaddress1'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Color.fromRGBO(0, 0, 0, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  // Widget workplaceadd(String address, String name) {
  //   return Container(
  //       width: double.infinity,
  //       margin: EdgeInsets.symmetric(vertical: 5, horizontal: 3),
  //       padding: EdgeInsets.all(10),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.all(
  //           Radius.circular(5),
  //         ),
  //       ),
  //       //height: (facilities.length) * 35.0 + 70,
  //       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  //         Text(
  //           name,
  //           style: TextStyle(
  //             fontSize: 20,
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //         Divider(),
  //         Text(
  //           address,
  //           style: TextStyle(fontSize: 16),
  //         ),
  //       ]));
  // }

  Widget facilitiesOffered(List facilities) {
    if (facilities != null)
      return Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 3),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
        height: (facilities.length) * 35.0 + 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DemoLocalization.of(context).translate("facilities_offered"),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Stack(
                        children: [
                          Image.asset("assets/star_frame.png"),
                          Positioned(
                              left: 10,
                              top: 12,
                              child: Image.asset("assets/thick_icon.png")),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Image.asset("assets/xray.png")
                    ],
                  ),
                  FacilityImages(
                    asset1: "assets/thick_shield.png",
                    asset2: "assets/neu_quality.png",
                  ),
                  FacilityImages(
                    asset1: "assets/mobile.png",
                    asset2: "assets/return_service.png",
                  ),
                ],
              ),
            ),
            Divider(),
            for (var i = 0; i < facilities.length; i++)
              Container(
                margin: EdgeInsets.only(top: i == 0 ? 2 : 6),
                child: Row(
                  children: [
                    Text(
                      '\u2022',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      facilities[i] != null ? facilities[i] : '',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    return Container();
  }

  Widget addresstab(todaydate, tomorrowdate, data, value) {
    return Column(
      children: [
        fromreception == true
            ? Container()
            : Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DemoLocalization.of(context).translate("overview"),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Divider(),
                      Text(
                          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.")
                    ],
                  ),
                ),
              ),
        fromreception == true
            ? Container()
            : Container(
                color: Colors.white,
                child: DocPageMap(data),
              ),
        // fromreception == true
        //     ? Container()
        //     : Padding(padding: EdgeInsets.only(top: 5)),

        // fromreception == true
        //     ? Container()
        //     : Padding(padding: EdgeInsets.only(top: 10)),
        fromreception == true
            ? Container()
            : value == "1"
                ? facilitiesOffered(data.data()['facilities1'])
                : facilitiesOffered(data.data()['facilities2']),
        // fromreception == true
        //     ? Container()
        //     : Padding(padding: EdgeInsets.only(top: 20)),
        Container(),
        fromreception == true
            ? Container(
                color: Colors.teal[50],
                child: tabledate(todaydate, data, "offline", value))
            : Container(),
        //// Randevu Slotları
        //  DefaultTabController(
        //     length: 2,
        //     child: Container(
        //       //color: Colors.teal[900],
        //       height: value == "1"
        //           ? 160.0 + data.data()['slots_per_hour1'] * 50
        //           : 160.0 + data.data()['slots_per_hour2'] * 50,
        //       child: Column(
        //         children: <Widget>[
        //           Container(
        //             //height: 70,
        //             padding:
        //                 EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        //             decoration: BoxDecoration(
        //               color: Colors.green[50],
        //               borderRadius: new BorderRadius.all(
        //                 Radius.circular(20.0),
        //               ),
        //             ),
        //             child: TabBar(
        //               labelColor: Colors.white,
        //               unselectedLabelColor: Colors.blueGrey,
        //               indicator: BoxDecoration(
        //                 color: Colors.teal[700],
        //                 borderRadius: BorderRadius.circular(15.0),
        //               ),
        //               tabs: <Widget>[
        //                 Tab(
        //                   text: DemoLocalization.of(context)
        //                       .translate("today"),
        //                 ),
        //                 Tab(
        //                   text: DemoLocalization.of(context)
        //                       .translate("tomorrow"),
        //                 )
        //               ],
        //             ),
        //           ),
        //           Expanded(
        //             child: TabBarView(
        //               children: <Widget>[
        //                 Container(
        //                     color: Colors.white,
        //                     child: tabledate(
        //                         todaydate, data, "offline", value)),
        //                 Container(
        //                     color: Colors.white,
        //                     child: tabledate(
        //                         tomorrowdate, data, "offline", value)),
        //               ],
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        /*
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          elevation: 2,
          color: Theme.of(context).primaryColorDark,
          child: Container(
              width: double.infinity,
              padding:
                  EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
              child: Column(
                children: <Widget>[
                  Text(
                    "Please provide your Feedback",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.radio_button_unchecked),
                        color: Theme.of(context).primaryColor,
                        padding: EdgeInsets.only(
                            top: 20, right: 25.0, left: 20.0, bottom: 20),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.radio_button_unchecked),
                        color: Theme.of(context).primaryColor,
                        padding: EdgeInsets.only(
                            top: 20, right: 25.0, left: 25.0, bottom: 20),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.radio_button_unchecked),
                        color: Theme.of(context).primaryColor,
                        padding: EdgeInsets.only(
                            top: 20, right: 25.0, left: 25.0, bottom: 20),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.radio_button_unchecked),
                        color: Theme.of(context).primaryColor,
                        padding: EdgeInsets.only(
                            top: 20, right: 25.0, left: 25.0, bottom: 20),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.radio_button_unchecked),
                        color: Theme.of(context).primaryColor,
                        padding: EdgeInsets.only(
                            top: 20, right: 20.0, left: 25.0, bottom: 20),
                        onPressed: () {},
                      ),
                    ],
                  )
                ],
              )),
        ),
        

              RaisedButton(
                highlightElevation: 10,
                elevation: 1,
                highlightColor: Colors.green,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Booking(
                              docuid: data['slots'],
                              timings: data['hours'],
                            )),
                  );
                },

                color: Colors.blue,
                textColor: Colors.white,
                child: Text('Book Appointment'),
                padding: EdgeInsets.all(15),
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
              ),
              */
        // Padding(padding: EdgeInsets.only(top: 25)),
        // fromreception == true ? Container() : Container(),
        //  Container(
        //     height: 55,
        //     width: double.infinity,
        //     color: Colors.deepPurple[100],
        //     alignment: Alignment.center,
        //     padding: EdgeInsets.symmetric(horizontal: 10),
        //     child: Text(
        //       DemoLocalization.of(context)
        //           .translate("tap_below_for_dirxns"),
        //       style: TextStyle(
        //           color: Colors.black,
        //           fontSize: 20,
        //           fontWeight: FontWeight.bold),
        //     ),
        //   ),

        fromreception == true
            ? Container()
            : data.data()['rev_1'] != null
                ? patientReviews(data)
                : Container(),
      ],
    );
  }

  Column patientReviews(data) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Color.fromRGBO(0, 0, 0, 0.3),
                width: 1,
              ),
            ),
          ),
          child: Text(
            DemoLocalization.of(context).translate("patient_reviews"),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
        ),
        for (var ind = 1; ind < 4; ind++)
          if (data.data()['rev_$ind'] != null)
            Container(
              padding: EdgeInsets.only(
                top: 10,
                left: 10,
                right: 3,
                bottom: 10,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color.fromRGBO(0, 0, 0, 0.3),
                    width: 1,
                  ),
                ),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.amber,
                              child: Text(
                                data.data()['rev_$ind']['patientname'] != null
                                    ? data.data()['rev_$ind']['patientname'][0]
                                    : 'J',
                                style: TextStyle(fontSize: 25),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data.data()['rev_$ind']['patientname'] !=
                                            null
                                        ? ' ' +
                                            data.data()['rev_$ind']
                                                ['patientname']
                                        : DemoLocalization.of(context)
                                            .translate("john_doe"),
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    data.data()['rev_$ind']['date'] != null
                                        ? '  ' + data.data()['rev_$ind']['date']
                                        : '  24-03-20',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        width: 162,
                        transform: Matrix4.translationValues(0.0, -6.0, 0.0),
                        child: ratingBar(
                          double.parse(data.data()['rev_$ind']['rating']),
                        ),
                      ),
                    ],
                  ),
                  data.data()['rev_$ind']['pros'] != null
                      ? Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.thumb_up,
                                color: Colors.green,
                              ),
                              // Text(
                              //   '  ' + data.data['rev_$ind']['pros'],
                              //   style: TextStyle(
                              //     fontWeight: FontWeight.w500,
                              //   ),
                              // ),
                            ],
                          ),
                        )
                      : Container(),
                  data.data()['rev_$ind']['cons'] != null
                      ? Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.thumb_down,
                                color: Colors.red,
                              ),
                              // Text(
                              //   '  ' + data.data['rev_$ind']['cons'],
                              //   style: TextStyle(
                              //     fontWeight: FontWeight.w500,
                              //   ),
                              // ),
                            ],
                          ),
                        )
                      : Container(),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 10),
                    child: Text(
                      data.data()['rev_$ind']['review'] != null
                          ? data.data()['rev_$ind']['review']
                          : DemoLocalization.of(context)
                              .translate("another_random_Review"),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }

  Column DocPageMap(data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            "Location",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Container(
          alignment: Alignment.center,
          width: double.infinity,
          margin: EdgeInsets.symmetric(
            //vertical: 5,
            horizontal: 3,
          ),
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Docpagemap(
            workplacecoord: data.data()['workplacecoordinates1'],
          ),
        ),
      ],
    );
  }

  Widget docinfo(data) {
    var todaydatevariable = DateTime.now().toString();
    var todaydateParse = DateTime.parse(todaydatevariable);

    var nextdayParse =
        DateTime.parse(DateTime.now().add(Duration(days: 1)).toString());
    var tommDate = nextdayParse.day.toString().padLeft(2, '0') +
        "-" +
        nextdayParse.month.toString().padLeft(2, '0') +
        "-" +
        nextdayParse.year.toString();
    var todayDate = todaydateParse.day.toString().padLeft(2, '0') +
        "-" +
        todaydateParse.month.toString().padLeft(2, '0') +
        "-" +
        todaydateParse.year.toString();
    print(todayDate);
    print(tommDate);
    addbookingdate(todayDate);
    addbookingdate(tommDate);
    //addbookingdate("26-07-2020");
    //addbookingdate("07-09-2020");
    return Column(
      children: <Widget>[
        appointmentcard2(data),
        //Padding(padding: EdgeInsets.only(top: 10)),
        //Booking Slots
        Column(
          children: [
            Container(
              color: Color(0xFF008577),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Text(
                              "${DateFormat.MMMM().format(DateTime.now())}",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white54),
                            ),
                            Text(
                              "${DateTime.now().day}",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white54),
                            ),
                            Text(
                              "${DateFormat.EEEE().format(DateTime.now())}",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      DatePicker.showDatePicker(
                        context,
                        showTitleActions: true,
                        minTime: DateTime.now(),
                        maxTime: DateTime.now().add(
                          Duration(days: 31),
                        ),
                        onConfirm: (time) {},
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.calendar_view_day_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 300,
              child: !_toBook
                  ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4),
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () {
                          print(TimeSlot.elementAt(index));
                          setState(() {
                            _toBook = !_toBook;
                          });
                          //  Offlineslottable(
                          //                 docslotperhr: dataofdoc['slots_per_hour1'],
                          //                 timings: dataofdoc['working_hours1'],
                          //                 bslots: bookedata['booked_slots'],
                          //                 docuidoffline: dataofdoc,
                          //                 date: text,
                          //                 type: which,
                          //                 reception: true,
                          //               )
                        },
                        child: Card(
                          child: GridTile(
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("${TimeSlot.elementAt(index)}"),
                                  Text("Availible"),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      itemCount: TimeSlot.length,
                    )
                  : tabledate(tommDate, data, "", ""),
            ),
          ],
        ),
        //Booking Slots
        fromreception == true
            ? Container()
            : data.data()['teleconsulting'] == true
                ? Container(
                    height: 55,
                    width: double.infinity,
                    color: Colors.purple[200],
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Text(
                      DemoLocalization.of(context)
                          .translate("video_consulting_slots"),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                : Container(),
        fromreception == true
            ? Container()
            : data.data()['teleconsulting'] == true
                ? bookingTab(todayDate, data, tommDate)
                : Container(),
        // fromreception == true
        //     ? Container()
        //     : Padding(padding: EdgeInsets.only(top: 5)),
        fromreception == true ? Container() : Container(),
        // : Container(
        //     height: 55,
        //     width: double.infinity,
        //     color: Colors.indigo[50],
        //     alignment: Alignment.center,
        //     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        //     child: Text(
        //       DemoLocalization.of(context)
        //           .translate("doctor_is_available_at"),
        //       style: TextStyle(
        //           color: Colors.black,
        //           fontSize: 20,
        //           fontWeight: FontWeight.bold),
        //     ),
        //   ),
        data.data()['no_of_workplace'] == "1"
            ? addresstab(todayDate, tommDate, data, "1")
            : DefaultTabController(
                length: 2,
                child: Container(
                  height: 1500,
                  color: Colors.indigo[900],
                  child: Column(
                    children: <Widget>[
                      TabBar(
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        indicator: BoxDecoration(
                          color: Colors.lightBlue[100],
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                        tabs: <Widget>[
                          Tab(
                            text: data['workplaceaddress1'],
                          ),
                          Tab(
                            text: data['workplaceaddress2'],
                          )
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          physics: NeverScrollableScrollPhysics(),
                          children: <Widget>[
                            Container(
                                color: Colors.lightBlue[50],
                                child: addresstab(todayDate, tommDate, data,
                                    "1")), //tabledate("26-07-2020", data, "")),
                            Container(
                                color: Colors.teal[50],
                                child: addresstab(todayDate, tommDate, data,
                                    "2")), //tabledate("07-09-2020", data, "")),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  DefaultTabController bookingTab(String todayDate, data, String tommDate) {
    return DefaultTabController(
      length: 2,
      child: Container(
        height: 160.0 + 225,
        child: Column(
          children: <Widget>[
            Container(
              height: 70,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              decoration: BoxDecoration(
                color: Colors.pink[50],
                borderRadius: new BorderRadius.all(
                  Radius.circular(20.0),
                ),
              ),
              child: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.blueGrey,
                indicator: BoxDecoration(
                  color: Colors.deepPurple[900],
                  borderRadius: BorderRadius.circular(15.0),
                ),
                tabs: <Widget>[
                  Tab(
                    text: DemoLocalization.of(context).translate("today"),
                  ),
                  Tab(
                    text: DemoLocalization.of(context).translate("tomorrow"),
                  )
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  Container(
                      color: Colors.white,
                      child: tabledate(todayDate, data, "", "")),
                  Container(
                      color: Colors.white,
                      child: tabledate(tommDate, data, "", "")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createDynamicLink(bool short, String id, String name) async {
    setState(() {
      _isCreatingLink = true;
    });

    final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: 'https://heyhealth.page.link',
        link: Uri.parse('https://heyhealth.page.link/refer?refId=' + id),
        androidParameters: AndroidParameters(
          packageName: 'com.heyhealth.heyhealth',
          minimumVersion: 0,
        ),
        dynamicLinkParametersOptions: DynamicLinkParametersOptions(
          shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
        ),
        iosParameters: IosParameters(
          bundleId: 'com.heyhealth.heyhealth',
          minimumVersion: '0',
        ),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: DemoLocalization.of(context).translate("view_dr") +
              " " +
              name +
              " " +
              DemoLocalization.of(context).translate("on_heyhealth"),
          description:
              DemoLocalization.of(context).translate("heyhealth_description"),
          imageUrl: Uri(
              scheme: 'https',
              path:
                  'https://res-3.cloudinary.com/crunchbase-production/image/upload/c_lpad,h_170,w_170,f_auto,b_white,q_auto:eco/zb104qvexylrksbpisd6'),
        ));

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink = await parameters.buildShortLink();
      url = shortLink.shortUrl;
    } else {
      url = await parameters.buildUrl();
    }

    setState(() {
      _linkMessage = url.toString();
      _isCreatingLink = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctor')
            .doc(docpageDoc)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          //print('This here ${snapshot.data}');
          var docdata = snapshot.data;
          return Scaffold(
            backgroundColor: Color(0xFFF5F5F5),
            appBar: AppBar(
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.black),
              title: Text(
                DemoLocalization.of(context).translate('doctor'),
                style: TextStyle(color: Colors.black),
              ),
              elevation: 0,
              actions: <Widget>[
                IconButton(
                  enableFeedback: true,
                  splashColor: Colors.white,
                  icon: Icon(click ? Icons.favorite : Icons.favorite_outline,
                      color: click ? Colors.red : Colors.black),
                  onPressed: () {
                    // printf("tapped star");
                    setState(() {
                      click = !click;
                    });
                  },
                ),
                IconButton(
                  onPressed: !_isCreatingLink
                      ? () async {
                          await _createDynamicLink(
                              true, docpageDoc, docdata['name']);
                          print(_linkMessage);
                          final RenderBox box = context.findRenderObject();
                          Share.share(
                            _linkMessage,
                            /*
                        subject:
                            DemoLocalization.of(context).translate("view") +
                                docdata['name'] +
                                DemoLocalization.of(context)
                                    .translate("on_heyhealth"),
                                    */
                            sharePositionOrigin:
                                box.localToGlobal(Offset.zero) & box.size,
                          );
                        }
                      : null,
                  icon: Icon(Icons.share),
                ),
                IconButton(onPressed: () {}, icon: Icon(Icons.qr_code_scanner))
                // IconButton(
                //   icon: Icon(
                //     Icons.share_sharp,
                //     color: Colors.black,
                //   ),
                // onPressed: !_isCreatingLink
                //     ? () async {
                //         await _createDynamicLink(
                //             true, docpageDoc, docdata['name']);
                //         print(_linkMessage);
                //         final RenderBox box = context.findRenderObject();
                //         Share.share(
                //           _linkMessage,
                //           /*
                //           subject:
                //               DemoLocalization.of(context).translate("view") +
                //                   docdata['name'] +
                //                   DemoLocalization.of(context)
                //                       .translate("on_heyhealth"),
                //                       */
                //           sharePositionOrigin:
                //               box.localToGlobal(Offset.zero) & box.size,
                //         );
                //       }
                //     : null,
                // ),
              ],
            ),
            body: Container(
                color: Color(0xFFF5F5F5),
                child: SingleChildScrollView(
                  child: docinfo(docdata),
                )
                /*ListView(
                  children: docdata.map((element) {
                    return docinfo(element);
                  }).toList(),
                )
                */
                ),
          );
        });
  }
}

class FacilityImages extends StatelessWidget {
  final String asset1;
  final String asset2;
  const FacilityImages({
    Key key,
    this.asset1,
    this.asset2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(asset1),
        SizedBox(
          height: 5,
        ),
        Image.asset(asset2),
      ],
    );
  }
}

//mesaja tarih eklenecek....!!!!!!
const TimeSlot = {
  "9:00 - 9:30",
  "9:30 - 10:00",
  "10:00 - 10:30",
  "10:30 - 11:00",
  "11:00 - 11:30",
  "11:30 - 12:00",
  "12:00 - 12:30",
  "12:30 - 13:00",
  "13:00 - 13:30",
  "13:30 - 14:00",
  "14:00 - 14:30",
  "14:30 - 15:00",
  "15:00 - 15:30",
  "15:30 - 16:00",
  "16:00 - 16:30",
  "16:30 - 17:00",
};
