import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:heyhealth/shared/loading.dart';
import 'package:heyhealth/pages/doc.dart';
import 'package:heyhealth/shared/loading.dart';
import 'searchbar.dart';
import 'searchresults.dart';
import 'package:heyhealth/localisations/local_lang.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class Bar extends StatefulWidget {
  Bar({Key key, this.title}) : super(key: key);
  final String title;

  @override
  BarState createState() => BarState();
}

class BarState extends State<Bar> {
  TextEditingController editingController = TextEditingController();

  final duplicateItems = List<String>.generate(100, (i) => "Doc $i");
  var items = [];
  String qrCodeResult = "Not Yet Scanned";
  String location = 'Null, Press Button';
  String Address = null;
  String time = '';
  String dropdownValue = 'Physician';
  String docimgurl = '';
  String docspec = '';
  var queryResultSet = [];
  var searcheddoctors = [];
  bool addressDone = true;
  DateTime selectedDate = DateTime.now();
  // bool _isConnected=false;
  //
  // // This function is triggered when the floating button is pressed
  // Future<void> _checkInternetConnection() async {
  //   try {
  //     final response = await InternetAddress.lookup('www.google.com');
  //     if (response.isNotEmpty) {
  //       setState(() {
  //         _isConnected = true;
  //       });
  //     }
  //   } on SocketException catch (err) {
  //     setState(() {
  //       _isConnected = false;
  //     });
  //     print(err);
  //   }
  // }
  Connectivity _connection = Connectivity();
  StreamSubscription _stream;
  bool status = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkConnectionRealTime();
  }

  void checkConnectionRealTime() {
    _stream = _connection.onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.mobile ||
          event == ConnectivityResult.wifi) {
        status = true;
      } else {
        status = false;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _stream.cancel();
    super.dispose();
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> GetAddressFromLatLong(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    //print(placemarks);
    Placemark place = placemarks[0];
    var locality = place.locality;
    setState(() {
      Address = locality;
      addressDone = true;
    });
  }

  //date time picker widget
  doctorTile(String docspec, String docimgurl) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: new InkWell(
        onTap: () async {
          setState(() {
            addressDone = false;
          });
          Position position = await _getGeoLocationPosition();
          print('Position taken');
          location = 'Lat: ${position.latitude} , Long: ${position.longitude}';
          await GetAddressFromLatLong(position);
          // print("LocationL:"+location);
          print("Address 22 :" + Address);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchBar(
                availabledoctors: docspec,
                city: Address,
              ),
            ),
          );
        },
        child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: Color.fromRGBO(3, 43, 68, 1),
                  width: 1,
                )),
            padding: const EdgeInsets.all(5),
            child: Column(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 5)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image(
                      image: NetworkImage(docimgurl),
                      width: 60,
                      height: 60,
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 5)),
                Text(DemoLocalization.of(context).translate(docspec),
                    style: GoogleFonts.manrope(fontSize: 10)),
              ],
            )),
      ),
    );
  }

  symptomTile(String docspec, String docimgurl) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: new InkWell(
        onTap: () async {
          setState(() {
            addressDone = false;
          });
          Position position = await _getGeoLocationPosition();
          print('Position taken');
          location = 'Lat: ${position.latitude} , Long: ${position.longitude}';
          await GetAddressFromLatLong(position);
          // print("LocationL:"+location);
          print("Address 22 :" + Address);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SearchBar(
                      availabledoctors: docspec,
                      city: Address,
                    )),
          );
        },
        child: Container(
            width: 110,
            height: 100,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: Color.fromRGBO(3, 43, 68, 1),
                  width: 1,
                )),
            padding: const EdgeInsets.all(5),
            child: Column(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 5)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image(
                      image: NetworkImage(docimgurl),
                      width: 80,
                      height: 80,
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  docspecializedlist(String value) {}
  @override
  Widget build(BuildContext context) {
    // for(int i=0;i<snapshot.data.documents.length;i++){
    // printf('This is ${snapshot.data.documents[0]}');
    //}
    return Scaffold(
      backgroundColor: Colors.white,

      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   actions: [
      //     Padding(
      //       padding: const EdgeInsets.only(right: 20),
      //       child: Image.asset(
      //         "assets/onboard/logo.png",
      //         width: 54,
      //       ),
      //     ),
      //   ],
      //   title: Row(
      //     children: [
      //
      //       Text("Find Doctor",
      //           style: GoogleFonts.manrope(
      //               color: Color.fromRGBO(3, 43, 68, 1),
      //               fontSize: 24,
      //               fontWeight: FontWeight.bold))
      //     ],
      //   ),
      // ),

      //   backgroundColor: Theme.of(context).primaryColor,
      body: addressDone
          ? Container(
              child: SingleChildScrollView(
                child: !status
                    ? AlertDialog(
                        title: Text("Internet not Connected!"),
                      )
                    : Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Container(
                                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: TextField(
                                        readOnly: true,
                                        cursorColor: Colors.black,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.go,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SearchResultScreen()),
                                          );
                                        },
                                        controller: editingController,
                                        decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                            borderSide: BorderSide(
                                              width: 2.0,
                                              color:
                                                  Color.fromRGBO(3, 43, 68, 1),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                            borderSide: BorderSide(
                                              width: 2.0,
                                              color:
                                                  Color.fromRGBO(3, 43, 68, 1),
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 0,
                                            vertical: 0,
                                          ),
                                          hintText:
                                              "Doctors/Clinics/Hospitals ...",
                                          hintStyle: GoogleFonts.manrope(
                                            fontSize: 15,
                                          ),
                                          prefixIcon: Icon(
                                            Icons.search,
                                            color:
                                                Color.fromRGBO(03, 43, 68, 1),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    /*
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      padding: EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Color(0xff00509d),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: Icon(
                        Icons.star_border,
                        color: Colors.white,
                        size: 30,
                      ),
                      //Text("Active Prescription",style: GoogleFonts.manrope(color: Colors.white),)),
                    ),
                    */
                                  ],
                                )),
                          ),
                          /*
          Container(
            height: 45,
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 15,vertical: 3),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                // padding: EdgeInsets.only(top:10,bottom:12,),
                primary: Color.fromRGBO(5, 105, 255, 1),
              ),
              child: Text(
                  DemoLocalization.of(context).translate("search_doctor"),
                  style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchResultScreen()),
                );
              },
            ),
          ),
          */
                          Container(
                            height: 50,
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 3),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                //  padding: EdgeInsets.all(12),
                                primary: Color.fromRGBO(5, 105, 255, 1),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code_scanner,
                                    size: 28,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                      //DemoLocalization.of(context).translate("Scan QR"),
                                      "Scan QR",
                                      style: GoogleFonts.manrope(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                              onPressed: () async {
                                String codeScanner =
                                    await FlutterBarcodeScanner.scanBarcode(
                                        '#ff6666',
                                        'Cancel',
                                        true,
                                        ScanMode.QR); //barcode scnner
                                var parts = codeScanner.split("_");
                                print(parts[1]);
                                if (parts[0] == "doctor") {
                                  setState(() {
                                    qrCodeResult = parts[1];
                                  });
                                  if (parts[2] == "profileqr") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DocPage(
                                                title:
                                                    DemoLocalization.of(context)
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
                                                title:
                                                    DemoLocalization.of(context)
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
                            ),
                          ),
                          Address == null
                              ? SizedBox()
                              : Padding(
                                  padding:
                                      const EdgeInsets.only(right: 15, top: 5),
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(
                                          Icons.place,
                                          color: Colors.blue,
                                        ),
                                        Text(
                                          Address,
                                          style: GoogleFonts.manrope(
                                              color: Colors.blue),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          SizedBox(
                            width: double.infinity,
                            child: Container(
                              padding: EdgeInsets.only(
                                left: 15,
                                top: 5,
                              ),
                              child: Text("Search by Category",
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.manrope(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),

                          /* Text("Search by Category", 
                //  DemoLocalization.of(context).translate("search_doctor"),
                  style: GoogleFonts.manrope(
                   
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),*/
                          Container(
                            height: 230,
                            child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 9.5, right: 9.5),
                                child: Card(
                                  elevation: 0,
                                  child: SingleChildScrollView(
                                      child: Row(
                                        children: <Widget>[
                                          Column(children: <Widget>[
                                            doctorTile('Physician',
                                                'https://icons.iconarchive.com/icons/aha-soft/free-large-boss/512/Head-Physician-icon.png'),
                                            doctorTile('Dentist',
                                                'https://i.dlpng.com/static/png/6781543_preview.png'),
                                          ]),
                                          Column(children: <Widget>[
                                            doctorTile('Gynaecologist',
                                                'https://clipartstation.com/wp-content/uploads/2018/10/pregnant-clipart-2.png'),
                                            doctorTile('Paediatrician',
                                                'https://img.freepik.com/free-vector/pediatrician-doctor-woman-examining-baby-boy_3446-535.jpg?size=338&ext=jpg'),
                                          ]),
                                          Column(children: <Widget>[
                                            doctorTile('Orthopedician',
                                                'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRganxy9QFvGXNepzMqrStiDmcxRqYAr0LIpQjmwjHCI-kUlkGS&usqp=CAU'),
                                            doctorTile('Radiologist',
                                                'https://cdn4.iconfinder.com/data/icons/medical-checkup/275/patient-treatment-01-004-512.png'),
                                          ]),
                                          Column(children: <Widget>[
                                            doctorTile('Nutritionist',
                                                'https://banner2.cleanpng.com/20180627/hfe/kisspng-dietetica-dietitian-nutrition-gorzw-wielkopolski-dite-5b338863d3a4b0.6074815115301039078669.jpg'),
                                            doctorTile('Cardiologist',
                                                'https://previews.123rf.com/images/mr_vector/mr_vector1603/mr_vector160302006/52947551-cardiology-heart-doctor-vector-icon.jpg'),
                                          ]),
                                          Column(children: <Widget>[
                                            doctorTile('Neurologist',
                                                "https://cdn2.iconfinder.com/data/icons/lose-gain-weigh-filled-outline/64/Brain_Health-Neurologist-Neurosurgeon-Health-Neurology-512.png"),
                                            doctorTile('Surgeon',
                                                'https://cdn1.iconfinder.com/data/icons/hospital-45/64/surgeon-doctor-operation-surgery-medical-hospital-512.png'),
                                          ]),
                                          Column(children: <Widget>[
                                            doctorTile('ENT',
                                                'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTG2OVN-F-XpJ4TVmjkB6zem0Cnu07lQuV0AlFu3A-iqL37sQ3P&usqp=CAU'),
                                            doctorTile('Ophthalmologist',
                                                'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcS9PMBMzwBuxYu1LsR6gBuQBvs6B5hG832N-JY3_OJyUm-gECvL&usqp=CAU'),
                                          ]),
                                          Column(children: <Widget>[
                                            doctorTile('Dermatologist',
                                                'https://www.curemd.com/images/dermatology/designed-by-dermatorlogy.png'),
                                            doctorTile('Cancer',
                                                'https://cdn1.iconfinder.com/data/icons/medical-health-care-1-3/380/7-512.png'),
                                          ]),
                                        ],
                                      ),
                                      scrollDirection: Axis.horizontal),
                                )),
                          ),
                          /* Expanded(
            child: Card(
              elevation: 2,
              child: Container(
                color: Colors.white,
                child: GridView.count(
                  //  scrollDirection: Axis.horizontal,
                  primary: true,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(
                      top: 9, left: 5, right: 5, bottom: 9),
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  crossAxisCount: 4,
                  childAspectRatio: 1,
                  children: <Widget>[
                    doctorTile('Physician',
                        'https://icons.iconarchive.com/icons/aha-soft/free-large-boss/512/Head-Physician-icon.png'),
                    doctorTile('Dentist',
                        'https://i.dlpng.com/static/png/6781543_preview.png'),
                    doctorTile('Gynaecologist',
                        'https://clipartstation.com/wp-content/uploads/2018/10/pregnant-clipart-2.png'),
                    doctorTile('Pediatrician',
                        'https://img.freepik.com/free-vector/pediatrician-doctor-woman-examining-baby-boy_3446-535.jpg?size=338&ext=jpg'),
                    doctorTile('Orthopedist',
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRganxy9QFvGXNepzMqrStiDmcxRqYAr0LIpQjmwjHCI-kUlkGS&usqp=CAU'),
                    doctorTile('Radiologist',
                        'https://cdn4.iconfinder.com/data/icons/medical-checkup/275/patient-treatment-01-004-512.png'),
                    doctorTile('Nutritionist',
                        'https://banner2.cleanpng.com/20180627/hfe/kisspng-dietetica-dietitian-nutrition-gorzw-wielkopolski-dite-5b338863d3a4b0.6074815115301039078669.jpg'),
                    doctorTile('Cardiologist',
                        'https://previews.123rf.com/images/mr_vector/mr_vector1603/mr_vector160302006/52947551-cardiology-heart-doctor-vector-icon.jpg'),
                    doctorTile('Neurologist',
                        "https://cdn2.iconfinder.com/data/icons/lose-gain-weigh-filled-outline/64/Brain_Health-Neurologist-Neurosurgeon-Health-Neurology-512.png"),
                    doctorTile('Surgeon',
                        'https://cdn1.iconfinder.com/data/icons/hospital-45/64/surgeon-doctor-operation-surgery-medical-hospital-512.png'),
                    doctorTile('ENT',
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTG2OVN-F-XpJ4TVmjkB6zem0Cnu07lQuV0AlFu3A-iqL37sQ3P&usqp=CAU'),
                    doctorTile('Ophthalmologist',
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcS9PMBMzwBuxYu1LsR6gBuQBvs6B5hG832N-JY3_OJyUm-gECvL&usqp=CAU'),
                    doctorTile('Dermatologist',
                        'https://www.curemd.com/images/dermatology/designed-by-dermatorlogy.png'),
                    doctorTile('Cancer',
                        'https://cdn1.iconfinder.com/data/icons/medical-health-care-1-3/380/7-512.png')
                  ],
                ),
              ),
            ),
          ),*/

                          SizedBox(
                            width: double.infinity,
                            child: Container(
                              padding: EdgeInsets.only(
                                left: 15,
                                top: 10,
                              ),
                              child: Text("Search by Symptom",
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.manrope(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                          Container(
                            height: 230,
                            child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Card(
                                  elevation: 0,
                                  child: SingleChildScrollView(
                                      child: Row(
                                        children: <Widget>[
                                          Column(children: <Widget>[
                                            symptomTile('Physician',
                                                'https://cdn2.iconfinder.com/data/icons/covid-19-2/64/07-Fever-512.png'),
                                            symptomTile('Dentist',
                                                'https://www.pngitem.com/pimgs/m/723-7237587_toothache-hd-png-download.png'),
                                          ]),
                                          Column(children: <Widget>[
                                            symptomTile('Gynaecologist',
                                                'https://png.pngtree.com/png-vector/20200911/ourlarge/pngtree-cartoon-hand-drawn-gynecology-explaining-plant-illustration-png-image_2343760.jpg'),
                                            //'https://clipartstation.com/wp-content/uploads/2018/10/pregnant-clipart-2.png'),
                                            symptomTile('Paediatrician',
                                                'https://thumbs.dreamstime.com/b/pediatrician-child-female-pediatrician-listens-stethoscope-to-baby-vector-illustration-111560294.jpg'),
                                          ]),
                                          Column(children: <Widget>[
                                            symptomTile('Orthopedician',
                                                'https://cdn-icons-png.flaticon.com/512/421/421276.png'),
                                            symptomTile('Radiologist',
                                                'http://assets.stickpng.com/categories/8085.png'),
                                          ]),
                                          /*
                    Column(children: <Widget>[
                      symptomTile('Nutritionist',
                          'https://banner2.cleanpng.com/20180627/hfe/kisspng-dietetica-dietitian-nutrition-gorzw-wielkopolski-dite-5b338863d3a4b0.6074815115301039078669.jpg'),
                      symptomTile('Cardiologist',
                          'https://previews.123rf.com/images/mr_vector/mr_vector1603/mr_vector160302006/52947551-cardiology-heart-doctor-vector-icon.jpg'),
                    ]),
                    Column(children: <Widget>[
                      symptomTile('Neurologist',
                          "https://cdn2.iconfinder.com/data/icons/lose-gain-weigh-filled-outline/64/Brain_Health-Neurologist-Neurosurgeon-Health-Neurology-512.png"),
                      symptomTile('Surgeon',
                          'https://cdn1.iconfinder.com/data/icons/hospital-45/64/surgeon-doctor-operation-surgery-medical-hospital-512.png'),
                    ]),
                    Column(children: <Widget>[
                      symptomTile('ENT',
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTG2OVN-F-XpJ4TVmjkB6zem0Cnu07lQuV0AlFu3A-iqL37sQ3P&usqp=CAU'),
                      symptomTile('Ophthalmologist',
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcS9PMBMzwBuxYu1LsR6gBuQBvs6B5hG832N-JY3_OJyUm-gECvL&usqp=CAU'),
                    ]),
                    Column(children: <Widget>[
                      symptomTile('Dermatologist',
                          'https://www.curemd.com/images/dermatology/designed-by-dermatorlogy.png'),
                      symptomTile('Cancer',
                          'https://cdn1.iconfinder.com/data/icons/medical-health-care-1-3/380/7-512.png'),
                    ]),
                    */
                                        ],
                                      ),
                                      scrollDirection: Axis.horizontal),
                                )),
                          ),
                        ],
                      ),
              ),
            )
          : Loading(),
    );
  }
}
