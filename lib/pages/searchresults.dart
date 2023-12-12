import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heyhealth/pages/doc.dart';
import 'package:heyhealth/localisations/local_lang.dart';

class SearchResultScreen extends StatefulWidget {
  @override
  SearchResultScreenState createState() => SearchResultScreenState();
}

class SearchResultScreenState extends State<SearchResultScreen> {
  String name = " ";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.teal[50],
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Card(
          child: TextField(
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                hintText: DemoLocalization.of(context)
                    .translate("search_dr_clinics")),
            onChanged: (val) {
              setState(() {
                name = val == '' ? '*' : val.toLowerCase();
              });
            },
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: (name != "" && name != null)
            ? FirebaseFirestore.instance
                .collection('doctor')
                .where("search", arrayContains: name)
                .snapshots()
            : FirebaseFirestore.instance.collection("doctor").snapshots(),
        builder: (context, snapshot) {
          return (snapshot.connectionState == ConnectionState.waiting)
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot data = snapshot.data.docs[index];
                    String docdata = data['name'] +
                        '\n\n' +
                        data['specialization'] +
                        '\n\n' +
                        data['workplaceaddress1'];
                    return InkWell(
                        splashColor: Colors.blue.withAlpha(30),
                        onTap: () {
                          //print(data);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DocPage(
                                      title: data['specialization'],
                                      clickedDoc: data.id,
                                    )),
                          );
                        },
                        child: Card(
                          child: Row(
                            children: <Widget>[Text(docdata)],
                          ),
                        ));
                  },
                );
        },
      ),
    );
  }
}
