import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:heyhealth/main.dart';
//import 'dart:io' show Platform;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationPlugin {
  //InitializationSettings initializationSettings;

  NotificationPlugin() {
    init();
  }
  init() async {
    tz.initializeTimeZones();
    String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<void> showNotification(
      RecievedNotification notifData, DateTime time) async {
    final styleInformation = BigPictureStyleInformation(
        DrawableResourceAndroidBitmap("presc"),
        largeIcon: DrawableResourceAndroidBitmap("icon"));
    /*
      AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          "1",
          "Medicine",
          "Time to take your pill!",
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
        )
      ;
      IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();
      NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );
    */
    showPending();
    tz.TZDateTime nowtime = tz.TZDateTime.now(tz.local);
    print(nowtime);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notifData.id,
      notifData.title,
      notifData.body,
      nowtime.add(Duration(
          hours: time.hour - nowtime.hour,
          minutes: time.minute - nowtime.minute)),
      NotificationDetails(
          android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        icon: "logo",
        timeoutAfter: 20000,
        color: Colors.teal,
        //largeIcon: DrawableResourceAndroidBitmap("icon"),
        styleInformation: styleInformation,
        playSound: true,
        enableVibration: true,
        priority: Priority.high,
        importance: Importance.max,
      )),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> bookingconfirmed(RecievedNotification notifData, String time,
      String date, String name) async {
    /*
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      "1",
      "Appointment with Dr. " + name,
      "Reminder for your appointment today in an hour",
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
    );
    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();
    
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    */
    final styleInformation = BigPictureStyleInformation(
        DrawableResourceAndroidBitmap("signindoc"),
        largeIcon: DrawableResourceAndroidBitmap("icon"));
    tz.TZDateTime nowtime = tz.TZDateTime.now(tz.local);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notifData.id,
      notifData.title,
      notifData.body,
      nowtime.add(Duration(minutes: 1)),
      NotificationDetails(
          android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        icon: "logo",
        timeoutAfter: 20000,
        color: Colors.teal,
        styleInformation: styleInformation,
        playSound: true,
        enableVibration: true,
        priority: Priority.high,
        importance: Importance.max,
      )),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> appointment(RecievedNotification notifData, String time,
      String date, String name) async {
    /*
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      "1",
      "Appointment with Dr. " + name,
      "Reminder for your appointment today in an hour",
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
    );
    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();
    
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    */
    final styleInformation = BigPictureStyleInformation(
        DrawableResourceAndroidBitmap("signindoc"),
        largeIcon: DrawableResourceAndroidBitmap("icon"));
    var day = date.split('-');
    var hr = time.split(':');
    tz.TZDateTime notifTime = tz.TZDateTime.local(
        int.parse(day[2]),
        int.parse(day[1]),
        int.parse(day[0]),
        int.parse(hr[0]),
        int.parse(hr[1]));
    showPending();
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notifData.id,
      notifData.title,
      "Your Appointment is due in 20 minutes",
      notifTime.subtract(Duration(minutes: 20)),
      NotificationDetails(
          android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        icon: "logo",
        timeoutAfter: 20000,
        color: Colors.teal,
        styleInformation: styleInformation,
        playSound: true,
        enableVibration: true,
        priority: Priority.high,
        importance: Importance.max,
      )),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notifData.id,
      notifData.title,
      notifData.body,
      notifTime.subtract(Duration(hours: 1)),
      NotificationDetails(
          android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        icon: "logo",
        timeoutAfter: 20000,
        styleInformation: styleInformation,
        playSound: true,
        enableVibration: true,
        priority: Priority.high,
        importance: Importance.max,
      )),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    // await flutterLocalNotificationsPlugin.cancelAll();
    print((id ~/ 10) * 10 + 1);
    print((id ~/ 10) * 10 + 2);
    print((id ~/ 10) * 10 + 3);
    await flutterLocalNotificationsPlugin.cancel((id ~/ 10) * 10 + 1);
    await flutterLocalNotificationsPlugin.cancel((id ~/ 10) * 10 + 2);
    await flutterLocalNotificationsPlugin.cancel((id ~/ 10) * 10 + 3);
    showPending();
  }

/*
  setOnNotificationClick(Function onNotificationClick) async {
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String payload) async {
        onNotificationClick(payload);
      },
    );
  }
  */

  Future<void> showPending() async {
    Future pending =
        flutterLocalNotificationsPlugin.pendingNotificationRequests();
    pending.then((value) {
      print(value);
      for (var i = 0; i < value.length; i++) {
        print(value[i].id);
      }
    });
  }
}

class RecievedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;
  RecievedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });
}
