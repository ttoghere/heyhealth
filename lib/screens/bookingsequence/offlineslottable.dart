import 'package:flutter/material.dart';
import 'package:heyhealth/screens/bookingsequence/offlinebooking.dart';
import 'package:heyhealth/shared/methods.dart';
import 'package:provider/provider.dart';
import 'package:heyhealth/models/user.dart';
import 'package:heyhealth/services/database.dart';
import 'package:heyhealth/shared/loading.dart';
import 'package:heyhealth/localisations/local_lang.dart';

/*var hours = [
  {'start': '8:47', 'end': '12:00'},
  {'start': '15:50', 'end': '18:25'}
];
*/
//var bookedSlots = ['08:48', '11:00', '11:24', '16:00'];
/*
var bookedSlots = {
  "10:00": {"completion": '', "booking": '', "pid": '', "reporting": ''},
  "09:00": {"completion": '', "booking": '', "pid": '', "reporting": ''},
  "08:48": {"completion": '', "booking": '', "pid": '', "reporting": ''},
  "16:00": {"completion": '', "booking": '', "pid": '', "reporting": ''},
};
*/
bool inrange(var rng, var thishr, var thismn, var slotdur) {
  int shrslot = int.parse(rng['start'].split(':')[0]);
  int smnslot = int.parse(rng['start'].split(':')[1]);
  int ehrslot = int.parse(rng['end'].split(':')[0]);
  int emnslot = int.parse(rng['end'].split(':')[1]);
  double x = thishr + (thismn / 60.0);
  double y = thishr + (thismn + slotdur) / 60.0;
  double s = shrslot + (smnslot / 60.0);
  double e = ehrslot + (emnslot / 60.0);
  bool ans = false;
  if ((x >= s) & (y <= e)) {
    ans = true;
  }
  return ans;
}

List generateGridslot(
    var workinghrs, int slotsPerHour, Map bookedslots, String type) {
  int n = workinghrs.length;
  int slotdur = (60.0 / slotsPerHour).round();
  int starthr = int.parse(workinghrs[0]['start'].split(':')[0]);
  int endhr = int.parse(workinghrs[n - 1]['end'].split(':')[0]);
  List valhrs = [];
  for (int i = 0; i < endhr - starthr + 1; i++) {
    var mnslot = [];
    for (int j = 0; j < slotsPerHour; j++) {
      for (int k = 0; k < n; k++) {
        var thishr = i + starthr;
        var thismn = j * slotdur;
        if (inrange(workinghrs[k], thishr, thismn, slotdur)) {
          mnslot.add(thishr.toString().padLeft(2, '0') +
              ':' +
              thismn.toString().padLeft(2, '0'));
          break;
        }
      }
    }
    if (mnslot.length > 0) {
      valhrs.add(mnslot);
    }
  }
  var rhrs = [];
  for (int i = 0; i < valhrs.length; i++) {
    int idx = 0;
    for (int j = 0; j < slotsPerHour; j++) {
      Color active = Colors.grey;
      String smin = (j * slotdur).toString().padLeft(2, '0');
      String stime = valhrs[i][0].split(':')[0] + ':' + smin;
      if (idx < valhrs[i].length) {
        String valmin = valhrs[i][idx].split(':')[1];
        if (valmin == smin) {
          idx += 1;
          if (type == "offline") {
            active = Colors.green[100];
          } else {
            active = Colors.pink[50];
          }
        }
      }
      /*
      if (idy < bookedSlots.length) {
        String bktime = bookedSlots[idy];
        if (bktime == stime) {
          idy += 1;
          active = Colors.red;
        }
      }
      */
      if ((bookedslots) != null) {
        if (bookedslots.containsKey(stime)) {
          if (type == "offline") {
            active = Colors.red;
          } else {
            active = Colors.deepPurpleAccent;
          }
        }
      }
      rhrs.add([stime, active]);
    }
  }
  return rhrs;
}

class Offlineslottable extends StatefulWidget {
  final int docslotperhr;
  final Map bslots;
  final List timings;
  final dynamic docuidoffline;
  final String date;
  final String type;
  final bool reception;
  Offlineslottable(
      {this.docslotperhr,
      this.timings,
      this.bslots,
      this.docuidoffline,
      this.date,
      this.type,
      this.reception});
  @override
  _OfflineBookslotState createState() => _OfflineBookslotState(
      docslotperhr, timings, bslots, docuidoffline, date, type, reception);
}

class _OfflineBookslotState extends State<Offlineslottable> {
  int docofflineslot;
  Map docofflinebookedslots;
  List doctimings;
  dynamic uidoffline;
  String dateuid;
  String typeofslot;
  bool fromreception;
  _OfflineBookslotState(docofflineslot, doctimings, docofflinebookedslots,
      uidoffline, dateuid, typeofslot, fromreception);

  String selectedslot = '';

  @override
  void initState() {
    docofflineslot = (widget.docslotperhr);
    doctimings = (widget.timings);
    docofflinebookedslots = (widget.bslots);
    uidoffline = (widget.docuidoffline);
    dateuid = (widget.date);
    typeofslot = (widget.type);
    fromreception = (widget.reception);
    super.initState();
  }

  List qrslotlist = [];
  List qrtokenlist = [];

  @override
  Widget build(BuildContext context) {
    var gridslot = generateGridslot(
        doctimings, docofflineslot, docofflinebookedslots, typeofslot);
    for (int j = 0; j < gridslot.length; j++) {
      if (gridslot[j][1] == Colors.green[100]) {
        qrtokenlist.add(j + 1);
        qrslotlist.add(gridslot[j][0]);
      }
    }
    User user = Provider.of<User>(context);
    return StreamBuilder<UserData>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserData userData = snapshot.data;
            return Column(
              children: [
                fromreception == true
                    ? SizedBox(height: 10)
                    : Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextButton(
                              style: ElevatedButton.styleFrom(
                                primary: (typeofslot == "offline")
                                    ? Colors.green[100]
                                    : Colors.pink[50],
                                onPrimary: (typeofslot == "offline")
                                    ? Colors.black
                                    : Colors.pink[900],
                                padding: EdgeInsets.all(15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                              ),
                              onPressed: () {},
                              //borderSide: BorderSide(color: gridslot[id][index][1]),
                              child: Text(DemoLocalization.of(context)
                                  .translate("available")),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            TextButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: (typeofslot == "offline")
                                    ? Colors.red
                                    : Colors.deepPurpleAccent,
                                elevation: 1,
                                padding: EdgeInsets.all(15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                              ),
                              onPressed: () {},
                              //borderSide: BorderSide(color: gridslot[id][index][1]),
                              child: Text(DemoLocalization.of(context)
                                  .translate("booked")),
                            ),
                          ],
                        ),
                      ),
                fromreception == true
                    ? Container()
                    : Divider(
                        color: Colors.blueGrey,
                      ),
                fromreception == true
                    ? Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                        child: Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.blueGrey.withOpacity(.1),
                                      offset: Offset(0, 8),
                                      blurRadius: 5)
                                ],
                                gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [Colors.grey[50], Colors.white]),
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(color: Colors.blueGrey)),
                            padding: EdgeInsets.only(
                                left: 5, right: 5, top: 10, bottom: 5),
                            child: Column(children: [
                              Padding(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  child: Text(
                                      "Patient token :  " +
                                          qrtokenlist[0].toString(),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold))),
                              Expanded(
                                  child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.teal[900],
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20)),
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 1,
                                    onPrimary: Colors.white,
                                    primary: Colors.cyan[900],
                                    padding: EdgeInsets.all(5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20)),
                                    ),
                                  ),
                                  //highlightElevation: 10,
                                  onPressed: () {
                                    print(userData.uid + userData.name);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Bookingscreen(
                                                details: uidoffline,
                                                dateDoc: dateuid,
                                                selecslot: qrslotlist[0],
                                                bookingtype: "",
                                                docaddress: "offline",
                                                patientuid: userData.uid,
                                                patientname: userData.name,
                                                patientdob: userData.dob,
                                                patientphone: userData.phone,
                                                patientgender: userData.gender,
                                                patientaddress:
                                                    userData.address,
                                                patientfromreception: true,
                                              )),
                                    );
                                  },
                                  //borderSide: BorderSide(color: gridslot[id][index][1]),
                                  //color: pressAttention ? Colors.green : Colors.blue,
                                  child: Text(
                                    DemoLocalization.of(context)
                                        .translate("accept_slot"),
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                /*
                                      ListTile(
                        title: Text(
                          DemoLocalization.of(context).translate("accept_slot"),
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize:22.0,
                              fontWeight: FontWeight.bold),
                        ),
                        trailing: Icon(Icons.arrow_forward_outlined,
                            size: 30, color: Colors.white),
                      )
                      */
                              ))
                            ])))
                    : Container(
                        height: (typeofslot == "offline")
                            ? docofflineslot * 50.0
                            : (gridslot.length / docofflineslot) * 75,
                        child: GridView.count(
                          scrollDirection: (typeofslot == "offline")
                              ? Axis.horizontal
                              : Axis.vertical,
                          crossAxisSpacing: 4,
                          childAspectRatio:
                              (typeofslot == "offline") ? .55 : 1.6,
                          mainAxisSpacing: 20,
                          crossAxisCount: docofflineslot,
                          children: List.generate(gridslot.length, (index) {
                            if (typeofslot == "offline") {
                              return (gridslot[index][1] == Colors.green[100])
                                  ? ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 1,
                                        onPrimary: Colors.green[900],
                                        primary: gridslot[index][1],
                                        padding: EdgeInsets.all(5),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0)),
                                      ),
                                      //highlightElevation: 10,
                                      onPressed: () {
                                        setState(() {
                                          selectedslot = gridslot[index][0];
                                        });

                                        //selectedslot = gridslot[index][0];
                                        print(selectedslot);
                                        print(userData.uid + userData.name);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Bookingscreen(
                                                      details: uidoffline,
                                                      dateDoc: dateuid,
                                                      selecslot: selectedslot,
                                                      bookingtype: "",
                                                      docaddress: "offline",
                                                      patientuid: userData.uid,
                                                      patientname:
                                                          userData.name,
                                                      patientdob: userData.dob,
                                                      patientphone:
                                                          userData.phone,
                                                      patientgender:
                                                          userData.gender,
                                                      patientaddress:
                                                          userData.address)),
                                        );
                                      },
                                      //borderSide: BorderSide(color: gridslot[id][index][1]),
                                      //color: pressAttention ? Colors.green : Colors.blue,
                                      child: Text(to12hr(gridslot[index][0])),
                                    )
                                  : TextButton(
                                      style: TextButton.styleFrom(
                                        primary: gridslot[index][1],
                                        onSurface: Colors.white,
                                        padding: EdgeInsets.all(5),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(
                                                    30.0)),
                                      ),
                                      child: Text(to12hr(gridslot[index][0])),
                                      onPressed: () {},
                                      //borderSide: BorderSide(color: gridslot[id][index][1]),
                                    );
                            } else {
                              return (gridslot[index][1] == Colors.pink[50])
                                  ? ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        onSurface: Colors.black,
                                        primary: gridslot[index][1],
                                        elevation: 1,
                                        onPrimary: Colors.pinkAccent[700],
                                        padding: EdgeInsets.all(5),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0)),
                                      ),

                                      onPressed: () {
                                        setState(() {
                                          selectedslot = gridslot[index][0];
                                        });

                                        //selectedslot = gridslot[index][0];
                                        print(selectedslot);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Bookingscreen(
                                                      details: uidoffline,
                                                      dateDoc: dateuid,
                                                      selecslot: selectedslot,
                                                      bookingtype: "video",
                                                      docaddress: "online",
                                                      patientuid: userData.uid,
                                                      patientname:
                                                          userData.name,
                                                      patientdob: userData.dob,
                                                      patientphone:
                                                          userData.phone,
                                                      patientgender:
                                                          userData.gender,
                                                      patientaddress:
                                                          userData.address)),
                                        );
                                      },
                                      //borderSide: BorderSide(color: gridslot[id][index][1]),
                                      //color: pressAttention ? Colors.green : Colors.blue,
                                      child: Text(to12hr(gridslot[index][0])),
                                    )
                                  : TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                        primary: gridslot[index][1],
                                        onSurface: Colors.white,
                                        padding: EdgeInsets.all(5),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0)),
                                      ),
                                      //borderSide: BorderSide(color: gridslot[id][index][1]),
                                      child: Text(to12hr(gridslot[index][0])),
                                    );
                            }
                            //robohash.org api provide you different images for any number you are giving
                          }),
                        ),
                      )
              ],
            );
          }

          return Loading();
        });
  }
}
