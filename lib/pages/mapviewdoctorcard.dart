import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heyhealth/models/maplistdoctor.dart';
import 'package:heyhealth/localisations/local_lang.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController _controller;

  List<Marker> allMarkers = [];

  PageController _pageController;

  int prevPage;

  @override
  void initState() {
    super.initState();
    coffeeShops.forEach((element) {
      allMarkers.add(Marker(
          markerId: MarkerId(element.shopName),
          draggable: false,
          infoWindow:
              InfoWindow(title: element.shopName, snippet: element.address),
          position: element.locationCoords));
    });
    _pageController = PageController(initialPage: 1, viewportFraction: 0.4)
      ..addListener(_onScroll);
  }

  void _onScroll() {
    if (_pageController.page.toInt() != prevPage) {
      prevPage = _pageController.page.toInt();
      moveCamera();
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

  _coffeeShopList(index) {
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
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            //print(data);
          },
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
                          height: 100,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[50],
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),

                            //padding: EdgeInsets.only(top: 10, bottom: 10),
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage(
                                  'https://icons.iconarchive.com/icons/aha-soft/free-large-boss/512/Head-Physician-icon.png'),
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
                                    DemoLocalization.of(context)
                                        .translate("name"),
                                style: TextStyle(
                                  fontSize: 21,
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                DemoLocalization.of(context)
                                    .translate("radiologist"),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromRGBO(0, 0, 0, 0.9),
                                ),
                              ),
                              Text(
                                DemoLocalization.of(context)
                                    .translate("10_years_exp"),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color.fromRGBO(0, 0, 0, 0.9),
                                ),
                              ),
                              ratingBar(3.67),
                              Text(
                                DemoLocalization.of(context)
                                    .translate("workplace_address"),
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
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 2, right: 2),
                          child: Text(
                              DemoLocalization.of(context)
                                  .translate("10km_away"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color.fromRGBO(0, 0, 0, 0.9),
                              )),
                        ),
                      ),
                      Container(
                        width: 125,
                        margin: EdgeInsets.only(right: 10, bottom: 10),
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(28, 195, 217, 1),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: TextButton(
                          child: Text(
                              DemoLocalization.of(context)
                                  .translate("book_video_consult"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          onPressed: () {},
                        ),
                      ),
                      Container(
                        width: 130,
                        margin: EdgeInsets.only(right: 10, bottom: 10),
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue[900],
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: TextButton(
                          child: Text(
                              DemoLocalization.of(context)
                                  .translate("book_appointment"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              )),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Positioned(
          height: MediaQuery.of(context).size.height / 2.5,
          width: MediaQuery.of(context).size.width,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
                target: LatLng(40.7128, -74.0060), zoom: 12.0, tilt: 45.0),
            markers: Set.from(allMarkers),
            onMapCreated: mapCreated,
          ),
        ),
        Positioned(
          bottom: 5.0,
          child: Container(
            height: MediaQuery.of(context).size.height * .6,
            width: MediaQuery.of(context).size.width,
            child: PageView.builder(
              scrollDirection: Axis.vertical,
              controller: _pageController,
              itemCount: coffeeShops.length,
              itemBuilder: (BuildContext context, int index) {
                return _coffeeShopList(index);
              },
            ),
          ),
        )
      ],
    ));
  }

  void mapCreated(controller) async {
    _controller = controller;
    String value = await DefaultAssetBundle.of(context)
        .loadString('assets/map_styles/doclocation.json');
    _controller.setMapStyle(value);
  }

  moveCamera() {
    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: coffeeShops[_pageController.page.toInt()].locationCoords,
        zoom: 14.0,
        bearing: 45.0,
        tilt: 45.0)));
  }
}
