import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Docpagemap extends StatefulWidget {
  final List workplacecoord;
  final GoogleMapController controller;

  Docpagemap({required this.workplacecoord, required this.controller});
  @override
  _DocpagemapState createState() =>
      _DocpagemapState(workplacecoord: workplacecoord);
}

class _DocpagemapState extends State<Docpagemap> {
  List? coordinates;
  //Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController _controller;
  Map<MarkerId, Marker> markers = {};

  _DocpagemapState({required List workplacecoord});

  @override
  void initState() {
    super.initState();
    coordinates = (widget.workplacecoord);
    LatLng _center =
        LatLng(double.parse(coordinates![0]), double.parse(coordinates![1]));

    /// destination marker
    _addMarker(
        _center, "destination", BitmapDescriptor.defaultMarkerWithHue(270));
  }

  void _onMapCreated(GoogleMapController controller) async {
    _controller = controller;
    String value = await DefaultAssetBundle.of(context)
        .loadString('assets/map_styles/doclocation.json');
    _controller.setMapStyle(value);
    //_controller.complete(controller);
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: LatLng(
            double.parse(coordinates![0]), double.parse(coordinates![1])),
        zoom: 15.0,
      ),
      markers: Set<Marker>.of(markers.values),
    );
  }
}
