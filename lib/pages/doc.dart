import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heyhealth/maps/docpagemap.dart';
import 'package:heyhealth/screens/bookingsequence/offlineslottable.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share/share.dart';
import 'package:heyhealth/localisations/local_lang.dart';

class DocPage extends StatefulWidget {
  DocPage({Key key, this.title, this.clickedDoc, this.appointmentfromreception})
      : super(key: key);
  final String title;
  final String clickedDoc;
  final bool appointmentfromreception;
  @override
  DocPageState createState() =>
      DocPageState(title, clickedDoc, appointmentfromreception);
}

class DocPageState extends State<DocPage> {
  Color _starColor = Colors.white;
  var _starIcon = Icons.star_border;
  String docpagetitle = '';
  String docpageDoc = '';
  bool fromreception = false;
  var bookedata;
  String error;
  DocPageState(docpagetitle, docpageDoc, fromreception);
  String _linkMessage;
  bool _isCreatingLink = false;
  //List docdata = [];

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
          color: Color.fromRGBO(252, 211, 3, 1),
        ),
      );
    }
    if (rating - rating.floor() >= 0.5) {
      stars.add(
        Icon(
          Icons.star_half,
          color: Color.fromRGBO(252, 211, 3, 1),
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
          (rating * 20).toStringAsFixed(0) + '%',
          style: TextStyle(
            color: Color.fromRGBO(0, 0, 0, 0.9),
            fontSize: 15,
          ),
        ),
      ),
    );
    return Row(
      children: stars,
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
                          image: NetworkImage(
                            data.data()['profileurl'] == ""
                                ? 'https://icons.iconarchive.com/icons/aha-soft/free-large-boss/512/Head-Physician-icon.png'
                                : data.data()['profileurl'],
                          ),
                        ),
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

  Widget workplaceadd(String address, String name) {
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
        //height: (facilities.length) * 35.0 + 70,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          Divider(),
          Text(
            address,
            style: TextStyle(fontSize: 16),
          ),
        ]));
  }

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
        height: (facilities.length) * 35.0 + 70,
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
            : Padding(padding: EdgeInsets.only(top: 5)),
        value == "1"
            ? workplaceadd(
                data.data()['workplaceaddress1'], data.data()['workplacename1'])
            : workplaceadd(data.data()['workplaceaddress2'],
                data.data()['workplacename2']),
        fromreception == true
            ? Container()
            : Padding(padding: EdgeInsets.only(top: 10)),
        fromreception == true
            ? Container()
            : value == "1"
                ? facilitiesOffered(data.data()['facilities1'])
                : facilitiesOffered(data.data()['facilities2']),
        fromreception == true
            ? Container()
            : Padding(padding: EdgeInsets.only(top: 20)),
        Container(
          height: 55,
          width: double.infinity,
          color: Colors.teal[100],
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Text(
            fromreception == true
                ? "Alloted Slot"
                : DemoLocalization.of(context)
                    .translate("in_person_appointment_slots"),
            style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        fromreception == true
            ? Container(
                color: Colors.teal[50],
                child: tabledate(todaydate, data, "offline", value))
            : DefaultTabController(
                length: 2,
                child: Container(
                  //color: Colors.teal[900],
                  height: value == "1"
                      ? 160.0 + data.data()['slots_per_hour1'] * 50
                      : 160.0 + data.data()['slots_per_hour2'] * 50,
                  child: Column(
                    children: <Widget>[
                      Container(
                        //height: 70,
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: new BorderRadius.all(
                            Radius.circular(20.0),
                          ),
                        ),
                        child: TabBar(
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.blueGrey,
                          indicator: BoxDecoration(
                            color: Colors.teal[700],
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          tabs: <Widget>[
                            Tab(
                              text: DemoLocalization.of(context)
                                  .translate("today"),
                            ),
                            Tab(
                              text: DemoLocalization.of(context)
                                  .translate("tomorrow"),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: <Widget>[
                            Container(
                                color: Colors.white,
                                child: tabledate(
                                    todaydate, data, "offline", value)),
                            Container(
                                color: Colors.white,
                                child: tabledate(
                                    tomorrowdate, data, "offline", value)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
        Padding(padding: EdgeInsets.only(top: 25)),
        fromreception == true
            ? Container()
            : Container(
                height: 55,
                width: double.infinity,
                color: Colors.deepPurple[100],
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  DemoLocalization.of(context)
                      .translate("tap_below_for_dirxns"),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
        fromreception == true
            ? Container()
            : Container(
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
        fromreception == true
            ? Container()
            : data.data()['rev_1'] != null
                ? Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        padding:
                            EdgeInsets.symmetric(horizontal: 4, vertical: 10),
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
                          DemoLocalization.of(context)
                              .translate("patient_reviews"),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 22,
                                            backgroundColor: Colors.amber,
                                            child: Text(
                                              data.data()['rev_$ind']
                                                          ['patientname'] !=
                                                      null
                                                  ? data.data()['rev_$ind']
                                                      ['patientname'][0]
                                                  : 'J',
                                              style: TextStyle(fontSize: 25),
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  data.data()['rev_$ind']
                                                              ['patientname'] !=
                                                          null
                                                      ? ' ' +
                                                          data.data()[
                                                                  'rev_$ind']
                                                              ['patientname']
                                                      : DemoLocalization.of(
                                                              context)
                                                          .translate(
                                                              "john_doe"),
                                                  overflow: TextOverflow.fade,
                                                  softWrap: false,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                Text(
                                                  data.data()['rev_$ind']
                                                              ['date'] !=
                                                          null
                                                      ? '  ' +
                                                          data.data()[
                                                                  'rev_$ind']
                                                              ['date']
                                                      : '  24-03-20',
                                                  style:
                                                      TextStyle(fontSize: 12),
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
                                      transform: Matrix4.translationValues(
                                          0.0, -6.0, 0.0),
                                      child: ratingBar(
                                        double.parse(
                                            data.data()['rev_$ind']['rating']),
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
                                        margin:
                                            EdgeInsets.symmetric(vertical: 10),
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
                  )
                : Container(),
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
        appointmentcard(data),
        //Padding(padding: EdgeInsets.only(top: 10)),
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
                ? DefaultTabController(
                    length: 2,
                    child: Container(
                      height: 160.0 + 225,
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 70,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 5),
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
                                  text: DemoLocalization.of(context)
                                      .translate("today"),
                                ),
                                Tab(
                                  text: DemoLocalization.of(context)
                                      .translate("tomorrow"),
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
                  )
                : Container(),
        fromreception == true
            ? Container()
            : Padding(padding: EdgeInsets.only(top: 5)),
        fromreception == true ? Container() : Divider(),
        fromreception == true
            ? Container()
            : Container(
                height: 55,
                width: double.infinity,
                color: Colors.indigo[50],
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Text(
                  DemoLocalization.of(context)
                      .translate("doctor_is_available_at"),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
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
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.black),
              title: Text(
                DemoLocalization.of(context).translate('view_dr'),
                style: TextStyle(color: Colors.black),
              ),
              elevation: 0,
              centerTitle: false,
              actions: <Widget>[
                //Buradan Başla Favori/Bildirim/QR Code
                IconButton(
                  icon: Icon(
                    Icons.share_sharp,
                    color: Colors.black,
                  ),
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
                ),
                IconButton(
                  enableFeedback: true,
                  splashColor: Colors.white,
                  icon: Icon(_starIcon, color: _starColor),
                  onPressed: () {
                    // printf("tapped star");

                    setState(() {
                      if (_starColor == Colors.white) {
                        _starIcon = Icons.star;
                        _starColor = Colors.cyan[100];
                      } else {
                        _starIcon = Icons.star_border;
                        _starColor = Colors.white;
                      }
                    });
                  },
                ),
              ],
            ),
            body: Container(
                color: Colors.blueGrey[50],
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
//mesaja tarih eklenecek....!!!!!!
