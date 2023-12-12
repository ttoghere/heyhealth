import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heyhealth/pages/doc2.dart';
import 'package:heyhealth/shared/loading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heyhealth/localisations/local_lang.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'dart:ui' as ui;
import 'dart:async';
//import 'dart:io';
//import 'dart:typed_data';
//import 'package:flutter/services.dart';

class SearchBar extends StatefulWidget {
  final availabledoctors, city;

  SearchBar({Key key, this.availabledoctors, this.city}) : super(key: key);

  @override
  SearchBarState createState() => SearchBarState(availabledoctors);
}

class SearchBarState extends State<SearchBar> {
  TextEditingController editingController = TextEditingController();

  final duplicateItems = List<String>.generate(100, (i) => "Doc $i");
  var items = [];
  String query = "";
  String doctors = "";
  List doctorslist = [];
  SearchBarState(doctors);
  GoogleMapController _controller;

  bool loading = true;
  bool isLoading = false; // track if products fetching
  bool hasMore = true; // flag for more products available or not
  int documentLimit = 2; // documents to be fetched per request
  DocumentSnapshot
      lastDocument; // flag for last document from where next 10 records to be fetched
  //List<Marker> allMarkers = [];
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  BitmapDescriptor pinLocationIcon;

  PageController _pageController;
  int prevPage;

  void filterSearchResults(String query) {
    List<String> dummySearchList = [];
    dummySearchList.addAll(duplicateItems);
    if (query.isNotEmpty) {
      List<String> dummyListData = [];
      dummySearchList.forEach((item) {
        if (item.contains(query)) {
          dummyListData.add(item);
        }
      });

      // printf(dummyListData.length);
      if (dummyListData.length == 0) {
        dummyListData.add('Match not found');
      }
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
      });
    }
  }

  @override
  void initState() {
    items.addAll(duplicateItems);
    doctors = (widget.availabledoctors);
    /*
    FirebaseFirestore.instance
        .collection('doctor')
        .where('specialization', isEqualTo: doctors)
        .get()
        .then((docs) {
      if (docs.docs.isNotEmpty) {
        for (int i = 0; i < docs.docs.length; i++) {
          initMarker(docs.docs[i].data, docs.docs[i].id);
          doctorslist = docs.docs.toList();
        }
        print(docs.docs.length);
      }
    });
    */
    fetchdoctorslist();
    super.initState();
    /*
    coffeeShops.forEach((element) {
      allMarkers.add(Marker(
          markerId: MarkerId(element.shopName),
          draggable: false,
          infoWindow:
              InfoWindow(title: element.shopName, snippet: element.address),
          position: element.locationCoords));
    });
    */

    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(48, 48)),
            'assets/inside/mapmarkerlogo.png')
        .then((onValue) {
      pinLocationIcon = onValue;
    });
    _pageController = PageController(initialPage: 0, viewportFraction: 0.4)
      ..addListener(_onScroll);
  }

  getmoreDoctors() async {
    if (!hasMore) {
      print(DemoLocalization.of(context).translate("no_more_products"));
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot;
    /*
    if (lastDocument == null) {
      querySnapshot = await FirebaseFirestore.instance
          .collection('doctor')
          .where('specialization', isEqualTo: doctors)
          .limit(documentLimit)
          .get();
    }
    */
    if (lastDocument != null) {
      querySnapshot = await FirebaseFirestore.instance
          .collection('doctor')
          .where('specialization', isEqualTo: doctors)
          .startAfterDocument(lastDocument)
          .limit(documentLimit)
          .get();
      print('got the 2nd query');
    }
    if (querySnapshot.docs.length < documentLimit) {
      hasMore = false;
    }
    lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      initMarker(querySnapshot.docs[i], querySnapshot.docs[i].id);
    }
    doctorslist.addAll(querySnapshot.docs);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchdoctorslist() async {
    await FirebaseFirestore.instance
        .collection('doctor')
        .where('specialization', isEqualTo: doctors)
        .limit(documentLimit)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        if (snapshot.docs.length != 0) {
          setState(() => loading = false);
          lastDocument = snapshot.docs[snapshot.docs.length - 1];
          for (int i = 0; i < snapshot.docs.length; i++) {
            print(snapshot.docs[i].data());
            initMarker(snapshot.docs[i], snapshot.docs[i].id);
            doctorslist = snapshot.docs.toList();
          }
          print(snapshot.docs.length);
          print('yes');
        } else {}
      } else {
        print('no    oiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii');
      }
    });
  }

  void initMarker(doctordocument, documentid) {
    var markerIdVal = documentid;
    final MarkerId markerId = MarkerId(markerIdVal);

    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      icon: pinLocationIcon,
      position: LatLng(
          double.parse(doctordocument.data()['workplacecoordinates1'][0]),
          double.parse(doctordocument.data()['workplacecoordinates1']
              [1])), //LatLng(lugar['Latitud'], lugar['Longitud']),
      infoWindow: InfoWindow(
          title: doctordocument.data()['name'],
          snippet: doctordocument.data()['specialization']),
    );

    setState(() {
      // adding a new marker to map
      markers[markerId] = marker;
    });
  }

  void _onScroll() {
    if (_pageController.page.toInt() != prevPage) {
      prevPage = _pageController.page.toInt();
      moveCamera();
    }
    if (_pageController.page.toInt() == (doctorslist.length - 2) &&
        (hasMore == true)) {
      getmoreDoctors();
    }
  }

  Widget _coffeeShopList(index, data) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (BuildContext context, Widget widget) {
        double value = 1;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page - index;
          value = (1 - (value.abs() * 0.29) + 0.06).clamp(0.0, 1.0);
        }
        return Center(
          child: SizedBox(
            height: Curves.easeInOut.transform(value) * 215.0,
            width: Curves.easeInOut.transform(value) * 400,
            child: widget,
          ),
        );
      },
      child: appointmentcard(index, data),
    );
  }

  void mapCreated(controller) async {
    _controller = controller;
    String value = await DefaultAssetBundle.of(context)
        .loadString('assets/map_styles/doclocation.json');
    _controller.setMapStyle(value);
  }

  moveCamera() {
    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(
            double.parse(doctorslist[_pageController.page.toInt()]
                .data()['workplacecoordinates1'][0]),
            double.parse(doctorslist[_pageController.page.toInt()]
                .data()['workplacecoordinates1'][1])),
        zoom: 16.0,
        bearing: 45.0,
        tilt: 45.0)));
  }

  @override
  Widget build(BuildContext context) {
    /*
    StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctor')
            .where('specialization', isEqualTo: doctors)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Loading();
          for (int i = 0; i < snapshot.data.docs.length; i++) {
            // printf('${snapshot.data.documents.length}');
            doctorslist = snapshot.data.docs.toList();
          }
          */
    if (loading == true) {
      return Loading();
    } else {
      return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
            title: Text(
              DemoLocalization.of(context).translate('view_dr') +
                  " " +
                  DemoLocalization.of(context).translate(doctors),
              style: GoogleFonts.manrope(color: Colors.black),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 15, right: 10, bottom: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.place,
                      color: Colors.blue,
                    ),
                    Text(
                      "${widget.city}",
                      style: GoogleFonts.manrope(color: Colors.black),
                    ),
                  ],
                ),
              )
            ],
          ),
          body: Stack(
            children: <Widget>[
              // Replace this container with your Map widget
              Container(
                child: Stack(children: <Widget>[
                  Positioned(
                    bottom: 5.0,
                    child: Container(
                      height: MediaQuery.of(context).size.height * .69,
                      width: MediaQuery.of(context).size.width,
                      child: PageView(
                        scrollDirection: Axis.vertical,
                        controller: _pageController,
                        children: doctorslist.asMap().entries.map((element) {
                          int idx = element.key;

                          return _coffeeShopList(
                              idx,
                              element
                                  .value); //appointmentcard(idx,element.value);
                        }).toList(),
                      ),
                    ),
                  ),
                  Positioned(
                    height: MediaQuery.of(context).size.height / 2.9,
                    width: MediaQuery.of(context).size.width,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                          target: LatLng(
                              double.parse(doctorslist[0]
                                  .data()['workplacecoordinates1'][0]),
                              double.parse(doctorslist[0]
                                  .data()['workplacecoordinates1'][1])),
                          zoom: 15.0,
                          tilt: 35.0),
                      markers: Set<Marker>.of(
                          markers.values), //Set.from(allMarkers),
                      onMapCreated: mapCreated,
                    ),
                  ),
                  /*
                  DraggableScrollableSheet(
                    initialChildSize: 0.6,
                    minChildSize: 0.2,
                    maxChildSize: .9,
                    builder: (BuildContext context, myscrollController) {
                      // printf('we are $doctors');
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListView(
                          controller: myscrollController,
                          children: doctorslist.asMap().entries.map((element) {
                            int idx = element.key;

                            return _coffeeShopList(
                                idx,
                                element
                                    .value); //appointmentcard(idx,element.value);
                          }).toList(),
                        ),
                      );
                    },
                  ),
                  */
                ]),
              ),
              /*
              Positioned(
                top: 55,
                right: 15,
                left: 15,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorDark,
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextField(
                          readOnly: true,
                          cursorColor: Colors.black,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.go,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Bar()),
                            );
                          },
                          onChanged: (value) {
                            filterSearchResults(value);
                          },
                          controller: editingController,
                          decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 15),
                              hintText: "Tap to search ...",
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(18.0)))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              */
            ],
          ));
    }
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
          style: GoogleFonts.manrope(
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

  Widget appointmentcard(index, data) {
    // print(data.data);
    return InkWell(
      splashColor: Colors.blue.withAlpha(30),
      onTap: () {
        //print(data);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DocPage2(
                    title: data['specialization'],
                    clickedDoc: data.id,
                  )),
        );
      },
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 3,
          color: Colors.white,
          child: Container(
              padding: EdgeInsets.only(top: 10, left: 10, right: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Container(
                          height: 90,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[50],
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),

                            //padding: EdgeInsets.only(top: 10, bottom: 10),
                            image: DecorationImage(
                              fit: BoxFit.contain,
                              image: NetworkImage(data.data()['profileurl'] ==
                                      ""
                                  ? 'https://icons.iconarchive.com/icons/aha-soft/free-large-boss/512/Head-Physician-icon.png'
                                  : data.data()['profileurl']),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 25,
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
                                style: GoogleFonts.manrope(
                                  fontSize: 17,
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                data['specialization'],
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(0, 0, 0, 0.9),
                                ),
                              ),
                              /*
                          Text(
                            DemoLocalization.of(context)
                                .translate("10_years_exp"),
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              color: Color.fromRGBO(0, 0, 0, 0.9),
                            ),
                          ),
                          */
                              ratingBar(3.67),
                              Text(
                                data['workplaceaddress1'],
                                textAlign: TextAlign.left,
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                ),
                              ),
                              /*  Text(
                            data['workplaceaddress1'],
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              color: Color.fromRGBO(0, 0, 0, 1),
                            ),
                          ),*/
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  //Expanded(child:
                  /*
             Container(             
               width:500,
               margin:EdgeInsets.only(left:95,bottom:8,right: 10),
              child: Text(
                            data['workplaceaddress1'],
                             textAlign: TextAlign.left,
                            style: GoogleFonts.manrope(
                              fontSize: 13,       
                              fontWeight: FontWeight.w400,                     
                              color: Color.fromRGBO(0, 0, 0, 1),
                            ),
                          ),),
                          */
                  //   Expanded( child:SizedBox(height: 0,),),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin:
                              EdgeInsets.only(right: 10, left: 5, bottom: 10),
                          padding:
                              EdgeInsets.symmetric(vertical: 14, horizontal: 5),
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(0xff00296b),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: Text(
                            DemoLocalization.of(context)
                                .translate("book_appointment"),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      data['teleconsulting'] == true
                          ? Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                    left: 10, right: 5, bottom: 10),
                                padding: EdgeInsets.symmetric(
                                    vertical: 11, horizontal: 5),
                                height: 48,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    border: Border.all(
                                        color: Color(0xff032B44), width: 2)),
                                child: Text(
                                  DemoLocalization.of(context)
                                      .translate("book_video_consult"),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.manrope(
                                    color: Color(0xff032B44),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(
                              width: 5,
                            ),
                    ],
                  ),
                ],
              ))),
    );
  }
}
