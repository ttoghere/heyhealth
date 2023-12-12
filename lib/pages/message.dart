import 'package:flutter/material.dart';
import 'package:heyhealth/bottomtabnav.dart';

class Message extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/inside/nearby-map.png"),
                  fit: BoxFit.cover))),
      floatingActionButton: FloatingActionButton(
        hoverElevation: 5,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BottomTab()),
          );
        },
        child: Icon(
          Icons.map,
          size: 25,
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
