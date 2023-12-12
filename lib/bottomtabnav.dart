// Flutter code sample for BottomNavigationBar

// This example shows a [BottomNavigationBar] as it is used within a [Scaffold]
// widget. The [BottomNavigationBar] has three [BottomNavigationBarItem]
// widgets and the [currentIndex] is set to index 0. The selected item is
// amber. The `_onItemTapped` function changes the selected item's index
// and displays a corresponding message in the center of the [Scaffold].
//
// ![A scaffold with a bottom navigation bar containing three bottom navigation
// bar items. The first one is selected.](https://flutter.github.io/assets-for-api-docs/assets/material/bottom_navigation_bar.png)

// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:heyhealth/main.dart';
//import 'package:heyhealth/pages/mapsearch.dart';
import 'package:heyhealth/pages/searchscreen.dart';
import 'package:heyhealth/screens/pickup.dart';
import 'package:heyhealth/services/auth.dart';
import 'package:showcaseview/showcaseview.dart';
import 'pages/appointment.dart';
import 'pages/reports.dart';
import 'pages/profile.dart';
import 'pages/doc.dart';
import 'pages/prescriptions.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'shared/constants.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:heyhealth/localisations/local_lang.dart';
import 'package:heyhealth/localisations/lang_const.dart';
import 'package:new_version/new_version.dart';

/// This Widget is the main application widget.
class BottomTab extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) {
    BottomTabState? state = context.findAncestorStateOfType<BottomTabState>();
    state?.setLocale(newLocale);
  }

  @override
  BottomTabState createState() => BottomTabState();
}

class BottomTabState extends State<BottomTab> {
  late Locale _locale;
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  static const String _title = 'heyhealth';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        primaryColorDark: Colors.blueGrey[900],
        primaryColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.black),
      ),
      debugShowCheckedModeBanner: false,
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key? key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  final AuthService _auth = AuthService();
  String qrCodeResult = "Not Yet Scanned";
  bool fromreception = false;

  void _changeLanguage(Language language) async {
    Locale _locale = await setLocale(language.languageCode);
    BottomTab.setLocale(context, _locale);
  }

  @override
  void initState() {
    super.initState();
    _checkversion();
    initDynamicLinks();
    initDeviceID();
    tz.initializeTimeZones();

    controller = TabController(initialIndex: 0, length: 4, vsync: this);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;
      if (notification != null && android != null) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          notification.hashCode,
          notification.title,
          notification.body,
          tz.TZDateTime.now(tz.local).add(const Duration(seconds: 0)),
          NotificationDetails(
              android: AndroidNotificationDetails(channel.id, channel.name,
                  channelDescription: channel.description)),
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    });
  }

  void _checkversion() async {
    final newVersion = NewVersion(
      androidId: "com.heyhealth.heyhealth",
    );
    final status = await newVersion.getVersionStatus();
    //newVersion.showAlertIfNecessary(context: context);
    status!.canUpdate
        ? newVersion.showUpdateDialog(
            context: context,
            versionStatus: status,
            dialogTitle: "Update heyhealth",
            dialogText: "A newer version with improvements is available",
          )
        : null;
    log("Device:${status.localVersion}");
    log("Store:${status.storeVersion}");
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void initDeviceID() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? token = await FirebaseMessaging.instance.getToken();
      log("device_token: $token");
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(user.uid)
          .update({'device_token': token});
    } else {
      log("illegal access!");
    }
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink;
  }

  void fixfromreg() {
    setState(() {
      fromregistered = false;
    });
  }

  GlobalKey _one = GlobalKey();
  GlobalKey _two = GlobalKey();
  GlobalKey _three = GlobalKey();
  GlobalKey _four = GlobalKey();
  GlobalKey _five = GlobalKey();
  //GlobalKey _six = GlobalKey();
  List title = ["Find Doctor", "Reports", "Prescriptions", "Appointments"];

  int currenttab = 0;
  Widget currentScreen = Bar();
  PageStorageBucket bucket = PageStorageBucket();
  String head = "Find Doctors";

  @override
  Widget build(BuildContext context) {
    if (fromregistered) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          ShowCaseWidget.of(context)
              .startShowCase([_one, _two, _three, _four, _five]));
      fixfromreg();
    }
    return PickupLayout(
        scaffold: Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Image.asset(
                "assets/onboard/logo.png",
                width: 54,
              ),
            ),
          ],
          title: Row(
            children: [
              /*
            Icon(
              Icons.search,
              size: 30,
              color: Color.fromRGBO(3, 43, 68, 1),
            ),
            SizedBox(
              width: 5,
            ),
            */
              Text(head,
                  style: const TextStyle(
                      color: Color.fromRGBO(3, 43, 68, 1),
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          centerTitle: true,
          leading: Builder(
              builder: (context) => IconButton(
                    icon: Icon(
                      Icons.menu_rounded,
                      color: Theme.of(context).primaryColorDark,
                      size: 33,
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ))),
      /*
      AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: FittedBox(
            fit: BoxFit.contain,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset('assets/inside/logo.png',
                  width: 80.0, height: 35),
            ),
          ),
          actions: <Widget>[
            /*
          IconButton(
            onPressed: () async {
              await [Permission.camera, Permission.microphone]
                          .request();
                Navigator.push(context,
                 CallUtils.dial(
                    from: searchedUser,
                    to:seaUser,
                    context: context,
                  )
                );
              },
            icon: Icon(Icons.video_call,
                color: Theme.of(context).primaryColorDark),
          ),
          */
            Showcase(
              key: _five,
              overlayColor: Colors.white,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              title: DemoLocalization.of(context).translate("share"),
              titleTextStyle: TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              descTextStyle: TextStyle(fontSize: 13, color: Colors.grey[200]),
              description:
                  DemoLocalization.of(context).translate("scan_QR_codes"),
              showcaseBackgroundColor: Colors.blueGrey[800],
              textColor: Colors.white,
              shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: IconButton(
                onPressed: () async {
                  String codeScanner = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.QR);//barcode scnner
                  var parts = codeScanner.split("_");
                  log(parts[1]);
                  if (parts[0] == "doctor") {
                    setState(() {
                      qrCodeResult = parts[1];
                    });
                    if (parts[2] == "profileqr") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DocPage(
                                  title: DemoLocalization.of(context)
                                      .translate("doctor"),
                                  clickedDoc: qrCodeResult,
                                  appointmentfromreception: false,
                                )),
                      );
                    }
                    if (parts[2] == "workplace1qr") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DocPage(
                                  title: DemoLocalization.of(context)
                                      .translate("doctor"),
                                  clickedDoc: qrCodeResult,
                                  appointmentfromreception: true,
                                )),
                      );
                    }
                    if (parts[2] == "workplace2qr") {}
                  }
                  // String codeScanner = scanned.rawContent;
                },
                icon: Icon(Icons.qr_code_scanner,size: 30,
                    color: Theme.of(context).primaryColorDark),
              ),
            ),
          ],
          centerTitle: true,
          leading: Builder(
              builder: (context) => IconButton(
                    icon: Icon(
                      Icons.menu_rounded,
                      color: Theme.of(context).primaryColorDark,
                      size: 33,
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ))),
                  */
      drawer: Drawer(
        child: Container(
          color: Theme.of(context).primaryColor,
          child: ListView(
            children: <Widget>[
              SizedBox(
                child: Image.asset('assets/inside/images.png'),
              ),
              const Divider(
                height: 5.0,
                color: Colors.black45,
              ),

              /*
              Container(
                child: ListTile(
                  title: Text(
                    DemoLocalization.of(context).translate('name'),
                    style: TextStyle(fontSize: 18.0, color: Colors.black),
                  ),
                  leading: Icon(Icons.list),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage()),
                    );
                  },
                ),
              ),
              Divider(
                height: 5.0,
                color: Colors.black45,
              ),
              Container(
                child: ListTile(
                  title: Text(
                    DemoLocalization.of(context).translate('about_us'),
                    style: TextStyle(fontSize: 18.0, color: Colors.black),
                  ),
                  leading: Icon(Icons.bookmark_border),
                  onTap: () {},
                ),
              ),
              Divider(
                height: 5.0,
                color: Colors.black45,
              ),
              Container(
                child: ListTile(
                  title: Text(
                    DemoLocalization.of(context).translate('feedback'),
                    style: TextStyle(fontSize: 18.0, color: Colors.black),
                  ),
                  leading: Icon(Icons.flash_on),
                  onTap: () {},
                ),
              ),
              Divider(
                height: 2.0,
              ),
              */
            ],
          ),
        ),
      ),
      body: PageStorage(bucket: bucket, child: currentScreen),

      // TabBarView(
      //   physics: NeverScrollableScrollPhysics(),
      //   children: <Widget>[
      //     /*
      //     SearchBar(
      //       availabledoctors: '',
      //     ),
      //     */
      //     Bar(),
      //     Report(),
      //     Prescription(),
      //     Appointment(),
      //     //FitnessScreen(),
      //   ],
      //   controller: controller,
      // ),

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Showcase(
                    key: _one,
                    overlayColor: Colors.white,
                    tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 20),
                    title: DemoLocalization.of(context)?.translate("doctors"),
                    titleTextStyle: const TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    descTextStyle:
                        TextStyle(fontSize: 13, color: Colors.grey[200]),
                    description: DemoLocalization.of(context)
                        ?.translate("find_a_doctor"),
                    tooltipBackgroundColor: Colors.teal[800]!,
                    textColor: Colors.white,
                    targetShapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: MaterialButton(
                      onPressed: () {
                        setState(() {
                          currenttab = 0;

                          currentScreen = Bar();
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_search_rounded,
                            color: currenttab == 0
                                ? const Color(0xff00296b)
                                : Colors.blueGrey,
                            size: currenttab == 0 ? 37 : 24,
                          ),
                          currenttab == 0
                              ? Container()
                              : Text(
                                  "Doctors",
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: currenttab == 0
                                          ? Colors.teal[900]
                                          : Colors.blueGrey),
                                )
                        ],
                      ),
                    ),
                  ),
                  Showcase(
                    key: _two,
                    overlayColor: Colors.white,
                    tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 20),
                    title: "reports",
                    titleTextStyle: const TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    descTextStyle:
                        TextStyle(fontSize: 13, color: Colors.grey[200]),
                    description: DemoLocalization.of(context)
                        ?.translate("view_reports_and_insights"),
                    tooltipBackgroundColor: Colors.lightBlue[700]!,
                    textColor: Colors.white,
                    targetShapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: MaterialButton(
                      onPressed: () {
                        setState(() {
                          currenttab = 1;
                          head = "Reports";
                          currentScreen = Report();
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note_add,
                            color: currenttab == 1
                                ? const Color(0xff00296b)
                                : Colors.blueGrey,
                            size: currenttab == 1 ? 37 : 24,
                          ),
                          currenttab == 1
                              ? Container()
                              : Text(
                                  "Reports",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: currenttab == 1
                                        ? const Color(0xff00296b)
                                        : Colors.blueGrey,
                                  ),
                                )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Showcase(
                    key: _three,
                    overlayColor: Colors.white,
                    tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 20),
                    title: "Prescriptions",
                    titleTextStyle: const TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    descTextStyle:
                        TextStyle(fontSize: 13, color: Colors.grey[200]),
                    description: DemoLocalization.of(context)
                        ?.translate("never_loose_track_of_course"),
                    tooltipBackgroundColor: Colors.cyan[900]!,
                    textColor: Colors.white,
                    targetShapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: MaterialButton(
                      onPressed: () {
                        setState(() {
                          currenttab = 2;
                          head = "Prescriptions";
                          currentScreen = Prescription();
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_parking,
                            color: currenttab == 2
                                ? const Color(0xff00296b)
                                : Colors.blueGrey,
                            size: currenttab == 2 ? 37 : 24,
                          ),
                          currenttab == 2
                              ? Container()
                              : Text(
                                  "Prescriptions",
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: currenttab == 2
                                          ? Colors.teal[900]
                                          : Colors.blueGrey),
                                )
                        ],
                      ),
                    ),
                  ),
                  Showcase(
                    key: _four,
                    overlayColor: Colors.white,
                    tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 20),
                    title: "Appointments",
                    titleTextStyle: const TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    descTextStyle:
                        TextStyle(fontSize: 13, color: Colors.grey[200]),
                    description: "Listed Appointments are here",
                    tooltipBackgroundColor: Colors.purple[900]!,
                    textColor: Colors.white,
                    targetShapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: MaterialButton(
                      onPressed: () {
                        setState(() {
                          currenttab = 3;
                          head = "appointments";
                          currentScreen = Appointment();
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_active,
                            color: currenttab == 3
                                ? const Color(0xff00296b)
                                : Colors.blueGrey,
                            size: currenttab == 3 ? 37 : 24,
                          ),
                          currenttab == 3
                              ? Container()
                              : Text(
                                  "appointments",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: currenttab == 3
                                        ? Colors.teal[900]
                                        : Colors.blueGrey,
                                  ),
                                )
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),

      // bottomNavigationBar: new Material(
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
      //   elevation: 5,
      //   color: Theme.of(context).primaryColor,
      //   child: new TabBar(
      //     indicatorColor: Colors.teal[700],
      //     labelColor: Colors.teal[700],
      //     unselectedLabelColor: Colors.black54,
      //     tabs: <Widget>[
      //       Showcase(
      //         key: _one,
      //         overlayColor: Colors.white,
      //         contentPadding:
      //             EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      //         title: DemoLocalization.of(context).translate("doctors"),
      //         titleTextStyle: TextStyle(
      //             fontSize: 17,
      //             color: Colors.white,
      //             fontWeight: FontWeight.bold),
      //         descTextStyle: TextStyle(fontSize: 13, color: Colors.grey[200]),
      //         description:
      //             DemoLocalization.of(context).translate("find_a_doctor"),
      //         showcaseBackgroundColor: Colors.teal[800],
      //         textColor: Colors.white,
      //         shapeBorder: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(15)),
      //         child: new Tab(
      //           icon: new Icon(
      //             Icons.search,
      //             size: 30.0,
      //           ),
      //           iconMargin: EdgeInsets.only(bottom: 3),
      //           text: DemoLocalization.of(context).translate("doctors"),
      //         ),
      //       ),
      //       Showcase(
      //         key: _two,
      //         overlayColor: Colors.white,
      //         contentPadding:
      //             EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      //         title: DemoLocalization.of(context).translate("reports"),
      //         titleTextStyle: TextStyle(
      //             fontSize: 17,
      //             color: Colors.white,
      //             fontWeight: FontWeight.bold),
      //         descTextStyle: TextStyle(fontSize: 13, color: Colors.grey[200]),
      //         description: DemoLocalization.of(context)
      //             .translate("view_reports_and_insights"),
      //         showcaseBackgroundColor: Colors.lightBlue[700],
      //         textColor: Colors.white,
      //         shapeBorder: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(15)),
      //         child: new Tab(
      //             icon: new Icon(
      //               Icons.note_add,
      //               size: 30.0,
      //             ),
      //             iconMargin: EdgeInsets.only(bottom: 3),
      //             text: DemoLocalization.of(context).translate("reports")),
      //       ),
      //       Showcase(
      //         key: _three,
      //         overlayColor: Colors.white,
      //         contentPadding:
      //             EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      //         title: DemoLocalization.of(context).translate("prescriptions"),
      //         titleTextStyle: TextStyle(
      //             fontSize: 17,
      //             color: Colors.white,
      //             fontWeight: FontWeight.bold),
      //         descTextStyle: TextStyle(fontSize: 13, color: Colors.grey[200]),
      //         description: DemoLocalization.of(context)
      //             .translate("never_loose_track_of_course"),
      //         showcaseBackgroundColor: Colors.cyan[900],
      //         textColor: Colors.white,
      //         shapeBorder: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(15)),
      //         child: new Tab(
      //           icon: new Icon(
      //             Icons.local_parking,
      //             size: 30.0,
      //           ),
      //           iconMargin: EdgeInsets.only(bottom: 3),
      //           text: DemoLocalization.of(context).translate("prescriptions"),
      //         ),
      //       ),
      //       Showcase(
      //         key: _four,
      //         overlayColor: Colors.white,
      //         contentPadding:
      //             EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      //         title: DemoLocalization.of(context).translate("appointments"),
      //         titleTextStyle: TextStyle(
      //             fontSize: 17,
      //             color: Colors.white,
      //             fontWeight: FontWeight.bold),
      //         descTextStyle: TextStyle(fontSize: 13, color: Colors.grey[200]),
      //         description: DemoLocalization.of(context)
      //             .translate("listed_appointments_are_here"),
      //         showcaseBackgroundColor: Colors.purple[900],
      //         textColor: Colors.white,
      //         shapeBorder: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(15)),
      //         child: new Tab(
      //             icon: new Icon(
      //               Icons.notifications_active,
      //               size: 30.0,
      //             ),
      //             iconMargin: EdgeInsets.only(bottom: 3),
      //             text: DemoLocalization.of(context).translate("appointments")),
      //       ),
      //       /*
      //       Showcase(
      //         key: _five,
      //         overlayColor: Colors.white,
      //         contentPadding:
      //             EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      //         title: "Fitness",
      //         titleTextStyle: TextStyle(
      //             fontSize: 17,
      //             color: Colors.white,
      //             fontWeight: FontWeight.bold),
      //         descTextStyle: TextStyle(fontSize: 13, color: Colors.grey[200]),
      //         description: 'Fit India with heyhealth!',
      //         showcaseBackgroundColor: Colors.cyan[900],
      //         textColor: Colors.white,
      //         shapeBorder: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(15)),
      //         child: new Tab(
      //           icon: new Icon(
      //             Icons.fitness_center,
      //             size: 30.0,
      //           ),
      //         ),
      //       ),
      //       */
      //     ],
      //     controller: controller,
      //   ),
      // ),
    ));
  }
}
