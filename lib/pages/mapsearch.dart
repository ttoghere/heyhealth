import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:heyhealth/localisations/local_lang.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleMapController mapController;

  String searchAddr;
  LatLng _center = const LatLng(29.107433850716166, 77.92174274909304);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        GoogleMap(
          onMapCreated: onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 17.0,
          ),
        ),
        Positioned(
          top: 30.0,
          right: 15.0,
          left: 15.0,
          child: Container(
            height: 50.0,
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0), color: Colors.white),
            child: TextField(
              decoration: InputDecoration(
                  hintText:
                      DemoLocalization.of(context).translate("enter_address"),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                  suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: searchandNavigate,
                      iconSize: 30.0)),
              onChanged: (val) {
                setState(() {
                  searchAddr = val;
                });
              },
            ),
          ),
        )
      ],
    ));
  }

  searchandNavigate() {
    locationFromAddress(searchAddr).then((result) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(result[0].latitude, result[0].longitude),
          zoom: 15.0)));
    });
  }

  void onMapCreated(controller) {
    setState(() {
      mapController = controller;
    });
  }
}
