import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heyhealth/models/dawai.dart';
import 'package:heyhealth/models/user.dart';
import 'package:heyhealth/pages/dawai_tile.dart';
import 'package:heyhealth/services/notification_plugin.dart';
import 'package:heyhealth/services/database.dart';
import 'package:heyhealth/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:heyhealth/localisations/local_lang.dart';

class Prescription extends StatefulWidget {
  @override
  PrescriptionState createState() {
    return PrescriptionState();
  }
}

// Define a custom Form widget.
class DawaiForm extends StatefulWidget {
  @override
  DawaiFormState createState() {
    return DawaiFormState();
  }
}

bool afterMeal = false;
bool morning = false;
bool night = false;
bool afternoon = false;
String name = '';
String dosage = '';
DateTime _durStart = DateTime.now();
DateTime _durEnd = DateTime.now();
bool notify = true;
String durStart = '';
String durEnd = '';
NotificationPlugin plugin = new NotificationPlugin();

class DawaiFormState extends State<DawaiForm> {
  Future<void> selectStart(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020, 1, 1),
        lastDate: DateTime(2099, 12, 31));
    if (picked != null && picked != _durStart)
      setState(() {
        _durStart = picked;
      });
  }

  Future<void> selectEnd(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _durStart,
        firstDate: _durStart,
        lastDate: DateTime(2099, 12, 31));
    if (picked != null && picked != _durEnd)
      setState(() {
        _durEnd = picked;
      });
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    return Form(
        key: _formKey,
        child: Column(children: <Widget>[
          TextFormField(
            decoration:
                textInputDecoration.copyWith(labelText: 'Medicine name'),
            validator: (value) {
              if (value.isEmpty) {
                return DemoLocalization.of(context).translate("invalid_name");
              }
              return null;
            },
            onChanged: (val) => setState(() => name = val),
          ),
          TextFormField(
            decoration: InputDecoration(
                labelText: DemoLocalization.of(context).translate("dosage")),
            onChanged: (val) => setState(() => dosage = val),
          ),
          SwitchListTile(
            title: Text(DemoLocalization.of(context).translate("after_meal")),
            value: afterMeal,
            onChanged: (bool value) {
              setState(() {
                afterMeal = value;
              });
            },
            secondary: const Icon(Icons.fastfood),
          ),
          CheckboxListTile(
            title: Text(DemoLocalization.of(context).translate("morning")),
            value: morning,
            onChanged: (bool value) {
              setState(() {
                morning = value;
              });
            },
            secondary: const Icon(Icons.hourglass_empty),
          ),
          CheckboxListTile(
            title: Text(DemoLocalization.of(context).translate("afternoon")),
            value: afternoon,
            onChanged: (bool value) {
              setState(() {
                afternoon = value;
              });
            },
            secondary: const Icon(Icons.hourglass_empty),
          ),
          CheckboxListTile(
            title: Text(DemoLocalization.of(context).translate("night")),
            value: night,
            onChanged: (bool value) {
              setState(() {
                night = value;
              });
            },
            secondary: const Icon(Icons.hourglass_empty),
          ),
          TextFormField(
            enabled: true,
            readOnly: true,
            decoration: textInputDecoration.copyWith(
              hintText: DemoLocalization.of(context).translate("from") +
                  ':  ${_durStart.day}-${_durStart.month}-${_durStart.year}',
              prefixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () => selectStart(context),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            enabled: true,
            readOnly: true,
            decoration: textInputDecoration.copyWith(
              hintText: DemoLocalization.of(context).translate("to") +
                  '     ${_durEnd.day}-${_durEnd.month}-${_durEnd.year} ',
              prefixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () => selectEnd(context),
          ),
          SwitchListTile(
            title: Text(DemoLocalization.of(context).translate("notify")),
            value: notify,
            onChanged: (bool value) {
              setState(() {
                notify = value;
              });
            },
            secondary: const Icon(Icons.notifications),
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.red),
              child: Text(
                DemoLocalization.of(context).translate("add"),
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                int uid = DateTime.now().hashCode;
                if (_formKey.currentState.validate()) {
                  await DatabaseService(uid: user.uid).addDawai(
                      uid.toString(),
                      name,
                      dosage,
                      '${_durStart.day}-${_durStart.month}-${_durStart.year}',
                      '${_durEnd.day}-${_durEnd.month}-${_durEnd.year}',
                      notify,
                      afterMeal,
                      morning,
                      afternoon,
                      night);
                  if (notify) {
                    if (afterMeal) {
                      if (morning)
                        plugin.showNotification(
                          RecievedNotification(
                              id: ((uid ~/ 10) * 10 + 1),
                              title: name + ' (' + dosage + ' mg)',
                              body: DemoLocalization.of(context)
                                      .translate("time_to_take_pill") +
                                  " " +
                                  DemoLocalization.of(context)
                                      .translate("after_meal"),
                              payload: "test"),
                          Time(9, 0, 0),
                        );
                      if (afternoon)
                        plugin.showNotification(
                          RecievedNotification(
                              id: ((uid ~/ 10) * 10 + 2),
                              title: name + ' (' + dosage + ' mg)',
                              body: DemoLocalization.of(context)
                                      .translate("time_to_take_pill") +
                                  " " +
                                  DemoLocalization.of(context)
                                      .translate("after_meal"),
                              payload: "test"),
                          Time(14, 0, 0),
                        );
                      if (night)
                        plugin.showNotification(
                          RecievedNotification(
                              id: ((uid ~/ 10) * 10 + 3),
                              title: name + ' (' + dosage + ' mg)',
                              body: DemoLocalization.of(context)
                                      .translate("time_to_take_pill") +
                                  " " +
                                  DemoLocalization.of(context)
                                      .translate("after_meal"),
                              payload: "test"),
                          Time(21, 30, 0),
                        );
                    } else {
                      if (morning)
                        plugin.showNotification(
                          RecievedNotification(
                              id: ((uid ~/ 10) * 10 + 1),
                              title: name + ' (' + dosage + ' mg)',
                              body: DemoLocalization.of(context)
                                      .translate("time_to_take_pill") +
                                  " " +
                                  DemoLocalization.of(context)
                                      .translate("before_meal"),
                              payload: "test"),
                          Time(7, 0, 0),
                        );
                      if (afternoon)
                        plugin.showNotification(
                          RecievedNotification(
                              id: ((uid ~/ 10) * 10 + 2),
                              title: name + ' (' + dosage + ' mg)',
                              body: DemoLocalization.of(context)
                                      .translate("time_to_take_pill") +
                                  " " +
                                  DemoLocalization.of(context)
                                      .translate("before_meal"),
                              payload: "test"),
                          Time(12, 30, 0),
                        );
                      if (night)
                        plugin.showNotification(
                          RecievedNotification(
                              id: ((uid ~/ 10) * 10 + 3),
                              title: name + ' (' + dosage + ' mg)',
                              body: DemoLocalization.of(context)
                                      .translate("time_to_take_pill") +
                                  " " +
                                  DemoLocalization.of(context)
                                      .translate("before_meal"),
                              payload: "test"),
                          Time(19, 30, 0),
                        );
                    }
                  }
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              }),
        ]));
  }
}

class PrescriptionState extends State<Prescription> {
  bool isSwitched = true;

  @override
  void initState() {
    super.initState();
    //plugin.setOnNotificationClick(onNotificationClick);
  }

  void onNotificationClick(String payload) {
    print(ModalRoute.of(context)?.settings?.name);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Prescription()),
    );
  }

  @override
  Widget build(BuildContext context) {
    void _showDawaiPanel() {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: new SingleChildScrollView(child: DawaiForm()),
            );
          });
    }

    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   actions: [
      //     Padding(
      //       padding: const EdgeInsets.only(right: 20),
      //       child: Image.asset("assets/onboard/logo.png",width: 54,),
      //     ),
      //   ],
      //   title: Row(children: [
      //   Image.asset("assets/onboard/prescription.png",height: 25,),
      //   SizedBox(width: 5,),
      //   Text("Prescription",style:GoogleFonts.manrope(color: Colors.black,fontSize:24,fontWeight: FontWeight.bold ))
      // ],),),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _showDawaiPanel(),
          child: Icon(Icons.alarm_add),
          backgroundColor: Theme.of(context).colorScheme.secondary),
    );
  }

  Widget _buildBody(BuildContext context) {
    User user = Provider.of<User>(context);
    return StreamProvider<List<Dawai>>.value(
      initialData: [],
      value: DatabaseService(uid: user.uid).dawais,
      child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: SingleChildScrollView(
                physics: ScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Padding(
                    //   padding: EdgeInsets.only(left: 10, top: 20),
                    //   child: Text(
                    //     DemoLocalization.of(context).translate('prescriptions'),
                    //     style: TextStyle(
                    //       fontFamily: "Futura-Medium",
                    //       fontSize: 25,
                    //       fontWeight: FontWeight.w500,
                    //     ),
                    //   ),
                    // ),
                    // Padding(
                    //   padding: EdgeInsets.only(
                    //     left: 10,
                    //   ),
                    //   child: Text(DemoLocalization.of(context).translate("active_prescriptions_displayed"),
                    //     style: TextStyle(
                    //       fontFamily: "Montserrat-Bold",
                    //       fontSize: 15,
                    //       fontWeight: FontWeight.w400,
                    //     ),
                    //   ),
                    // ),
                    // Container(
                    //   margin: EdgeInsets.only(top: 25, bottom: 5),
                    //   decoration: BoxDecoration(
                    //       gradient: LinearGradient(
                    //           colors: [
                    //             Colors.white,
                    //             Colors.grey[50],
                    //           ],
                    //           begin: Alignment.topCenter,
                    //           end: Alignment.bottomCenter),
                    //       borderRadius: BorderRadius.only(
                    //           bottomLeft: Radius.circular(30),
                    //           bottomRight: Radius.circular(30)),
                    //       boxShadow: [
                    //         BoxShadow(
                    //             color: Colors.blueGrey.withOpacity(.35),
                    //             offset: Offset(0, 8),
                    //             blurRadius: 8)
                    //       ]),
                    //   child: FittedBox(
                    //     fit: BoxFit.contain,
                    //     child: ClipRRect(
                    //       borderRadius: BorderRadius.circular(10.0),
                    //       child: Image.asset('assets/inside/presc.png',
                    //           width: 450.0, height: 250),
                    //     ),
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.blue)),
                          onPressed: null,
                          child: Text(
                            "Active Prescription",
                            style: GoogleFonts.manrope(color: Colors.white),
                          )),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    DawaiList(),
                    SizedBox(
                      height: 100,
                    ),
                  ],
                ),
              ))),
    );
  }
}
