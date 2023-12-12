import 'package:flutter/material.dart';
import 'package:heyhealth/localisations/local_lang.dart';

class Notificationn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColorDark,
          bottom: TabBar(
            indicatorColor: Theme.of(context).primaryColorDark,
            tabs: <Widget>[
              new Tab(
                child: Text(
                  DemoLocalization.of(context).translate("all"),
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              new Tab(
                  child: Text(
                "Mentions",
                style: TextStyle(fontSize: 18.0),
              )),
            ],
          ),
        ),
        body: Center(
          child: Container(
            color: Theme.of(context).primaryColorDark,
            child: ListView(
              children: <Widget>[
                new Container(
                  padding: EdgeInsets.only(top: 10.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25.0,
                      backgroundImage: NetworkImage(
                          'https://www.inovex.de/blog/wp-content/uploads/2019/01/Flutter-1-1.png'),
                    ),
                    title: Text(
                      "Flutter",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Container(
                      padding: EdgeInsets.only(top: 5.0),
                      child: Text(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                        style: TextStyle(color: Colors.black, fontSize: 15.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: Icon(Icons.edit),
            backgroundColor: Theme.of(context).colorScheme.secondary),
      ),
    );
  }
}
