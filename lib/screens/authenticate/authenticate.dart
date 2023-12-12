//import 'package:heyhealth/screens/authenticate/register.dart';
import 'package:heyhealth/screens/authenticate/register_new.dart';
import 'package:heyhealth/screens/authenticate/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:heyhealth/services/auth.dart';
import 'package:heyhealth/localisations/local_lang.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  /*bool showSignIn = true;
  void toggleView() {
    setState(() => showSignIn = !showSignIn);
  }*/

  @override
  Widget build(BuildContext context) {
    return SignIn();
    /*
    if (showSignIn) {
      return SignIn(toggleView: toggleView);
    } else {
      return Register(toggleView: toggleView);
    }
    */
  }
}

class GoogleButton extends StatefulWidget {
  @override
  _GoogleButtonState createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<GoogleButton> {
  bool _isProcessing = false;
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Color.fromRGBO(03, 43, 68, 1), width: 3),
        ),
        color: Color.fromRGBO(03, 43, 68, 1),
      ),
      child: OutlinedButton(
        onPressed: () async {
          setState(() {
            _isProcessing = true;
          });
          await _auth.signInWithGoogle(context).then((result) {
            print(result);
          }).catchError((error) {
            print('Registration Error: $error');
          });
          setState(() {
            _isProcessing = false;
          });
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: _isProcessing
              ? CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                    Colors.blueGrey,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Image(
                      image: AssetImage("assets/auth/google.png"),
                      height: 25.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: Text(
                        DemoLocalization.of(context)
                            .translate("continue_with_google"),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
