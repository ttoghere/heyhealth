import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heyhealth/localisations/local_lang.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
              child: FittedBox(
                fit: BoxFit.contain,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset('assets/onboard/logo.png',
                      width: 120.0, height: 120),
                ),
              ),
            ),
            SizedBox(
              child: SpinKitChasingDots(
                color: Colors.teal[700],
                size: 70.0,
              ),
            ),
          ],
        ));
  }
}

class Loadingerror extends StatelessWidget {
  const Loadingerror({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.asset('assets/onboard/logo.png',
                          width: 120.0, height: 120),
                    ),
                  ),
                ),
                Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: const Text(
                      "Loading...",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                    )),
                Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: const Text(
                      "Loading Error",
                      textAlign: TextAlign.center,
                    )),
                SizedBox(
                  child: SpinKitChasingDots(
                    color: Colors.teal[700],
                    size: 70.0,
                  ),
                ),
              ],
            )));
  }
}
