import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heyhealth/models/dawai.dart';
import 'package:heyhealth/models/user.dart';
import 'package:heyhealth/services/database.dart';
import 'package:heyhealth/pages/prescriptions.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

class DawaiTile extends StatelessWidget {
  final Dawai dawai;
  DawaiTile({this.dawai});

  @override
  Widget build(BuildContext context) {
    String leading = dawai.afterMeal ? 'After Meal' : 'Before Meal';
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        child: Container(
          //height: 175,
          decoration: BoxDecoration(
              // boxShadow: [
              //   BoxShadow(
              //       color: Colors.blueGrey.withOpacity(.3),
              //       offset: Offset(0, 8),
              //       blurRadius: 5)
              // ],
              // gradient: LinearGradient(
              //     begin: Alignment.centerLeft,
              //     end: Alignment.centerRight,
              //     colors: [Colors.grey[50], Colors.white]),
              color: Color(0xff032B44),
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(color: Colors.blueGrey)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 180,
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: AutoSizeText(
                            "${dawai.name}",
                            style: GoogleFonts.manrope(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold),
                            minFontSize: 12,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (dawai.dosage != null)
                          Text(
                            "Dosage: ${dawai.dosage}",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontSize: 12.0,
                              //fontWeight: FontWeight.bold
                            ),
                          ),
                        if (dawai.dosage != null) SizedBox(height: 10),
                      ]),
                ),
                /*  if(dawai.timesperday!=null)
                 Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 10),
                  child: Text(
                    "Timings: once per day",
                    style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 12.0,
                        //fontWeight: FontWeight.bold
                        ),
                  ),),*/

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (dawai.t1 != null)
                        new IconButton(
                          icon: new Icon(
                            Icons.wb_sunny_rounded,
                            size: 21,
                          ),
                          color: dawai.t1 == ""
                              ? Colors.red[50]
                              : Colors.greenAccent[100],
                          padding: new EdgeInsets.only(top: 10, bottom: 20),
                          iconSize: 30,
                          onPressed: () {},
                        ),
                      if (dawai.t2 != null)
                        new IconButton(
                            icon: new Icon(
                              Icons.fastfood_rounded,
                              size: 21,
                            ),
                            disabledColor: Colors.grey,
                            color: dawai.t2 == ""
                                ? Colors.red[50]
                                : Colors.greenAccent[100],
                            padding: new EdgeInsets.only(top: 10, bottom: 20),
                            iconSize: 30,
                            onPressed: () {}),
                      if (dawai.t3 != null)
                        new IconButton(
                          icon: new Icon(
                            Icons.nights_stay_rounded,
                            size: 21,
                          ),
                          iconSize: 30,
                          color: dawai.t3 == ""
                              ? Colors.red[50]
                              : Colors.greenAccent[100],
                          padding: new EdgeInsets.only(top: 10, bottom: 20),
                          onPressed: () {},
                        ),
                    ],
                  ),
                ),
              ],
            ),

            Divider(
              thickness: 0.5,
              height: 0.5,
              color: Colors.white,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Take",
                          style: GoogleFonts.manrope(
                              fontSize: 12, color: Color(0xFFC4C4C4))),
                      Text(
                        leading,
                        style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("From",
                          style: GoogleFonts.manrope(
                              fontSize: 12, color: Color(0xFFC4C4C4))),
                      Text(
                        dawai.durStart,
                        style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Till",
                          style: GoogleFonts.manrope(
                              fontSize: 12, color: Color(0xFFC4C4C4))),
                      Text(
                        dawai.durEnd,
                        style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              ],
            ),

            // Padding(
            //   padding: EdgeInsets.symmetric(vertical: 10),
            //   child:
            //   ListTile(
            //     isThreeLine: true,
            //     title: Text(
            //       "${dawai.name}",
            //       style: GoogleFonts.manrope(
            //           color: Colors.white,
            //           fontSize: 16.0,
            //           fontWeight: FontWeight.bold),
            //     ),
            //     subtitle: Padding(
            //       padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
            //       child: Table(columnWidths: {
            //         0: FlexColumnWidth(1), // fixed to 100 width
            //         1: FlexColumnWidth(2),
            //       }, children: [
            //         TableRow(children: [
            //           Text(
            //             DemoLocalization.of(context).translate("take"),
            //             style: TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 15.0,
            //                 fontWeight: FontWeight.bold),
            //           ),
            //           Text(
            //             leading,
            //             style: TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 15.0,
            //                 fontWeight: FontWeight.bold),
            //           ),
            //         ]),
            //         TableRow(children: [
            //           Text(
            //             DemoLocalization.of(context).translate("from"),
            //             style: TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 15.0,
            //                 fontWeight: FontWeight.bold),
            //           ),
            //           Text(
            //             dawai.durStart,
            //             style: TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 15.0,
            //                 fontWeight: FontWeight.bold),
            //           ),
            //         ]),
            //         TableRow(children: [
            //           Text(
            //             DemoLocalization.of(context).translate("till"),
            //             style: TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 15.0,
            //                 fontWeight: FontWeight.bold),
            //           ),
            //           Text(
            //             dawai.durEnd,
            //             style: TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 15.0,
            //                 fontWeight: FontWeight.bold),
            //           ),
            //         ]),
            //       ]),
            //     ),
            //     /*
            //      Container(
            //       padding: EdgeInsets.only(top: 5.0),
            //       child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Text(DemoLocalization.of(context).translate("take")+leading,
            //               style: TextStyle(
            //                   color: Colors.black,
            //                   fontSize: 15.0,
            //                   fontWeight: FontWeight.bold),
            //             ),
            //             Text(DemoLocalization.of(context).translate("from")+dawai.durStart,
            //                 style: TextStyle(
            //                   color: Colors.black,
            //                   fontSize: 15.0,
            //                 ) //fontWeight: FontWeight.bold),
            //                 ),
            //             Text(DemoLocalization.of(context).translate("till")+dawai.durEnd,
            //                 style: TextStyle(
            //                   color: Colors.black,
            //                   fontSize: 15.0,
            //                 ) //fontWeight: FontWeight.bold),
            //                 ),
            //           ]),
            //     ),
            //     */
            //     trailing: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       mainAxisSize: MainAxisSize.min,
            //       children: <Widget>[
            //         new IconButton(
            //           icon: new Icon(dawai.t1 == ""
            //               ? Icons.wb_sunny_outlined
            //               : Icons.wb_sunny_rounded),
            //           color:
            //               dawai.t1 == "" ? Colors.red[600] : Colors.green[900],
            //           padding: new EdgeInsets.only(top: 10, bottom: 20),
            //           iconSize: 30,
            //           onPressed: () {},
            //         ),
            //         new IconButton(
            //             icon: new Icon(dawai.t2 == ""
            //                 ? Icons.fastfood_outlined
            //                 : Icons.fastfood_rounded),
            //             disabledColor: Colors.grey,
            //             color: dawai.t2 == ""
            //                 ? Colors.red[600]
            //                 : Colors.green[900],
            //             padding: new EdgeInsets.only(top: 10, bottom: 20),
            //             iconSize: 30,
            //             onPressed: () {}),
            //         new IconButton(
            //           icon: new Icon(dawai.t3 == ""
            //               ? Icons.nights_stay_outlined
            //               : Icons.nights_stay_rounded),
            //           iconSize: 30,
            //           color:
            //               dawai.t3 == "" ? Colors.red[600] : Colors.green[900],
            //           padding: new EdgeInsets.only(top: 10, bottom: 20),
            //           onPressed: () {},
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ]),
        ),
      ),
    );
  }
}

class DawaiList extends StatefulWidget {
  @override
  _DawaiListState createState() => _DawaiListState();
}

class _DawaiListState extends State<DawaiList> {
  void remove(List<Dawai> dawais, int index, uid) async {
    await plugin.cancelNotification(int.parse(dawais[index].uid));
    await DatabaseService(uid: uid).deleteDawai(dawais[index].uid);
    setState(() {
      dawais.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    final dawais = Provider.of<List<Dawai>>(context) ?? [];

    if (dawais.length == 0) {
      return Container(
          child: Column(
        children: [
          FittedBox(
            fit: BoxFit.contain,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset('assets/inside/presc.png',
                  width: 500.0, height: 300),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "No Active Prescriptions",
            style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.w600),
          ),
        ],
      ));
    } else {
      return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: dawais.length,
        itemBuilder: (context, index) {
          Dawai item = dawais[index];
          List<String> end = dawais[index].durEnd.split('-');
          if (DateTime.now().isAfter(DateTime(
              int.parse(end[2]),
              int.parse(end[1]),
              int.parse(end[0]),
              23,
              59,
              59))) remove(dawais, index, user.uid);
          return Dismissible(
            key: Key(item.name),
            onDismissed: (direction) => remove(dawais, index, user.uid),
            background: Container(color: Colors.red),
            child: DawaiTile(
              dawai: item,
            ),
          );
        },
      );
    }
  }
}
