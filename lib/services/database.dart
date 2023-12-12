import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:heyhealth/models/dawai.dart';
import 'package:heyhealth/models/user.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final CollectionReference videoCollection =
      FirebaseFirestore.instance.collection('videos');
  final CollectionReference paitentCollection =
      FirebaseFirestore.instance.collection('patients');

  Future<void> updateData(String name, String phone, String address,
      String gender, String dob, String profileurl) async {
    return await paitentCollection.doc(uid).set({
      'name': name,
      'phone': phone,
      'address': address,
      'dob': dob,
      'gender': gender,
      'profileurl': profileurl,
      'reg_date': ""
    });
  }

  Future<void> updateProfileData(String name, String phone, String address,
      String gender, String dob, String regdate) async {
    return await paitentCollection.doc(uid).update({
      'name': name,
      'phone': phone,
      'address': address,
      'dob': dob,
      'gender': gender,
      'reg_date': regdate
    });
  }

  Future<void> deleteDawai(String docid) async {
    return await paitentCollection
        .doc(uid)
        .collection('dawai')
        .doc(docid)
        .delete();
  }

  Future<void> addDawai(
      String temp,
      String name,
      String dosage,
      String durStart,
      String durEnd,
      bool notify,
      bool afterMeal,
      bool morning,
      bool afternoon,
      bool night) async {
    TimeOfDay t1 = TimeOfDay(hour: 7, minute: 0);
    TimeOfDay t2 = TimeOfDay(hour: 12, minute: 30);
    TimeOfDay t3 = TimeOfDay(hour: 19, minute: 30);
    if (afterMeal) {
      t1 = TimeOfDay(hour: 9, minute: 0);
      t2 = TimeOfDay(hour: 14, minute: 30);
      t3 = TimeOfDay(hour: 21, minute: 30);
    }
    final dawaiCollection = paitentCollection.doc(uid).collection('dawai');
    return await dawaiCollection.doc(temp).set({
      'uid': temp,
      'name': name,
      'dosage': dosage,
      'durStart': durStart,
      'durEnd': durEnd,
      'notify': notify,
      'afterMeal': afterMeal,
      't1': morning ? t1.toString() : '',
      't2': afternoon ? t2.toString() : '',
      't3': night ? t3.toString() : '',
    });
  }

  List<Dawai> _dawaiListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Dawai(
        uid: doc['uid'] ?? '',
        name: doc['name'] ?? '',
        dosage: doc['dosage'] ?? '',
        durStart: doc['durStart'] ?? '',
        durEnd: doc['durEnd'] ?? '',
        notify: doc['notify'] ?? false,
        afterMeal: doc['afterMeal'] ?? true,
        t1: doc['t1'] ?? '',
        t2: doc['t2'] ?? '',
        t3: doc['t3'] ?? '',
      );
    }).toList();
  }

  Stream<List<Dawai>> get dawais {
    return paitentCollection
        .doc(uid)
        .collection('dawai')
        .snapshots()
        .map(_dawaiListFromSnapshot);
  }

  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      uid: uid,
      name: snapshot['name'],
      phone: snapshot['phone'],
      address: snapshot['address'],
      dob: snapshot['dob'],
      gender: snapshot['gender'],
      profileurl: snapshot['profileurl'],
      regdate: '',
    );
  }

  Stream<UserData> get userData {
    return paitentCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }
}
