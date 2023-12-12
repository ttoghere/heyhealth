import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:heyhealth/localisations/local_lang.dart';
import 'package:heyhealth/models/user.dart' as UserModel;
import 'package:heyhealth/screens/wrapper.dart';
import 'package:heyhealth/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:heyhealth/screens/onboard/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heyhealth/localisations/lang_const.dart';
import 'dart:async';

int? initScreen;
bool selected = false;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(Duration(seconds: 1), () {
      setState(() {
        selected = !selected;
      });
    });
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => initScreen == 0 || initScreen == null
            ? OnBoardingPage()
            : Wrapper(),
      ));
    });
  }

//Final
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              //color:Colors.red,
              width: selected ? 300.0 : 150.0,
              height: selected ? 300.0 : 150.0,
              //color: selected ? Colors.teal[50] : Colors.cyan[50],
              /* alignment:
              selected ? Alignment.center : AlignmentDirectional.topCenter,*/
              duration: const Duration(seconds: 2),
              curve: Curves.fastOutSlowIn,
              child: Image.asset(
                'assets/onboard/logo.png',
                // height: 75:,
              ),
            ),
            // logo here

            SizedBox(
              height: 20,
            ),
            /* CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[700]),
            )*/
          ],
        ),
      ),
    );
  }
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('ringtone'),
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message just showed up :  ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  initScreen = prefs.getInt("initScreen");
  await prefs.setInt("initScreen", 1);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) {
    MyAppState? state = context.findAncestorStateOfType<MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
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
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
