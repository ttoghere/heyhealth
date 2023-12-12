import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heyhealth/pages/pdfpage.dart';
import 'package:heyhealth/shared/loading.dart';
import 'package:open_file/open_file.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'doc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:heyhealth/localisations/local_lang.dart';

class ReportTile extends StatefulWidget {
  ReportTile({this.report});
  final dynamic report;
  @override
  _ReportTileState createState() => new _ReportTileState(report);
}

class _ReportTileState extends State<ReportTile> {
  dynamic repdata;
  String _openResult = 'Unknown';
  _ReportTileState(repdata);

  @override
  void initState() {
    repdata = (widget.report);
    super.initState();
  }

  Future<void> openFile() async {
    Dio dio = Dio();
    var tempDir = await getApplicationDocumentsDirectory();
    final fullPath = tempDir.path + '${repdata['location']}';
    print(repdata['location']);
    //final filePath = '/storage/emulated/0/Download/' + '${repdata['location']}';
    var status = await Permission.storage.status;
    print(status);
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    //final filePath = '/storage/emulated/0/Download/20-21 odd mid sem soln.docx';
    var sts = await dio.download(repdata['reporturl'], fullPath);
    print(sts);
    final result = await OpenFile.open(fullPath);

    setState(() {
      _openResult = "type=${result.type}  message=${result.message}";
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return reporttile(context, 'what kind of data?');
  }

  Widget reporttile(BuildContext context, data) {
    List month = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    //print(repdata.data()['prescription']);
    return Container(
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xff032B44),
        border: Border.all(color: Color(0xff032B44)),
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300],
            blurRadius: 5.0, // soften the shadow
            spreadRadius: 2.0, //extend the shadow
            offset: Offset(
              2.0, // Move to right 10  horizontally
              2.0, // Move to bottom 10 Vertically
            ),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            leading: Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Image.asset(
                    "assets/docicon3.png",
                    height: 40,
                    width: 40,
                  ),
                ),
              ),
            ),
            title: Text(
              DemoLocalization.of(context).translate("dr") +
                  repdata.data()["doctorname"],
              style: GoogleFonts.manrope(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Row(
              children: [
                Text(
                    (repdata.id.toString().substring(0, 2) +
                        " " +
                        month[int.parse(repdata.id.toString().substring(3, 5)) -
                            1]),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      color: Colors.white,
                    )),
                Text(
                  repdata.data()['appointmenttype'] != 'video'
                      ? "  |  In-Person"
                      : "  |  Video Consultation",
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.download_sharp, color: Colors.white, size: 30),
              onPressed: () {
                var filename = repdata['location'].toString();
                var type = filename.substring(filename.length - 3);
                if (type == "pdf") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PdfViewerPage(
                            url: repdata['reporturl'].toString(),
                            loc: repdata['location'])),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Loading()),
                  );
                  openFile();
                  print(_openResult);
                }
              },
            ),
          ),
          if (repdata.data()['prescription'] != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8),
              child: Text(
                "Prescriptions",
                style: GoogleFonts.manrope(color: Colors.white),
              ),
            ),
          SizedBox(
            height: 5,
          ),
          Container(child: repdata.data()['prescription'] != null ? prescriptList(
              /*
                        {Uploadreport
                        'a': 'paracetamol',
                        'b': 'diclobin +',
                        'c': 'ceftum glycerol'
                      }
                      */
              repdata['prescription']) : null),

          // Padding(
          //     padding: EdgeInsets.only(left: 10, top: 20),
          //     child: Text(repdata.id.toString().substring(0, 10),
          //         style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
          /*
          FocusedMenuHolder(
            blurSize: 5.0,
            animateMenuItems: true,
            menuWidth: 150,
            duration: Duration(milliseconds: 100),
            blurBackgroundColor: Colors.black45,
            onPressed: () {

              // printf(data.documentID);
            },
            menuItems: <FocusedMenuItem>[
              FocusedMenuItem(
                  title: Text("Open"),
                  trailingIcon: Icon(Icons.open_in_new),
                  onPressed: () {}),
              FocusedMenuItem(
                  title: Text("Share"),
                  trailingIcon: Icon(Icons.share),
                  onPressed: () {}),
              FocusedMenuItem(
                  backgroundColor: Colors.redAccent,
                  title: Text(
                    "Delete",
                    style: TextStyle(color: Colors.white),
                  ),
                  trailingIcon: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  onPressed: () {}),
            ],
            */
          // Padding(
          //   padding: const EdgeInsets.only(top: 5),
          //   child: Container(
          //     decoration: BoxDecoration(
          //         boxShadow: [
          //           BoxShadow(
          //               color: Colors.blueGrey.withOpacity(.1),
          //               offset: Offset(0, 8),
          //               blurRadius: 5),
          //         ],
          //         gradient: LinearGradient(
          //             begin: Alignment.centerLeft,
          //             end: Alignment.centerRight,
          //             colors: [Colors.grey[50], Colors.white]),
          //         borderRadius: repdata.data()['referred_docid'] != null
          //             ? BorderRadius.only(
          //                 topLeft: Radius.circular(20),
          //                 topRight: Radius.circular(20))
          //             : BorderRadius.circular(20.0),
          //         border: Border.all(color: Colors.blueGrey)),
          //     padding: EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 15),
          //     child: Column(
          //       children: [
          //         Row(
          //           children: <Widget>[
          //             Card(
          //               elevation: 2,
          //               shape: RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(10.0),
          //               ),
          //               child: Container(
          //                   padding: const EdgeInsets.all(3),
          //                   child: Column(
          //                     children: <Widget>[
          //                       FittedBox(
          //                         fit: BoxFit.scaleDown,
          //                         child: ClipRRect(
          //                           borderRadius: BorderRadius.circular(10.0),
          //                           child: Image(
          //                             image: NetworkImage(
          //                                 'https://th.bing.com/th/id/OIP.AsfdVeoje1KpYXypsUNxnAHaE9?w=266&h=180&c=7&o=5&dpr=1.25&pid=1.7'),
          //                             width: 72,
          //                             height: 72,
          //                           ),
          //                         ),
          //                       ),
          //                     ],
          //                   )),
          //             ),
          //             Expanded(
          //               child: ListTile(
          //                 isThreeLine: true,
          //                 title: Text(
          //                   repdata.data()["doctorname"],
          //                   style: TextStyle(
          //                       color: Theme.of(context).primaryColorDark,
          //                       fontSize: 20.0,
          //                       fontWeight: FontWeight.bold),
          //                 ),
          //                 subtitle: Container(
          //                   padding: EdgeInsets.only(top: 2.0),
          //                   child: Text(
          //                     repdata.data()["specialization"],
          //                     style: TextStyle(
          //                         color: Theme.of(context).primaryColorDark,
          //                         fontSize: 16.0),
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           ],
          //         ),
          //         Material(
          //             color: Colors.blueGrey[50],
          //             child: InkWell(
          //               onTap: () {
          //                 var filename = repdata['location'].toString();
          //                 var type = filename.substring(filename.length - 3);
          //                 if (type == "pdf") {
          //                   Navigator.push(
          //                     context,
          //                     MaterialPageRoute(
          //                         builder: (context) => PdfViewerPage(
          //                             url: repdata['reporturl'].toString(),
          //                             loc: repdata['location'])),
          //                   );
          //                 } else {
          //                   Navigator.push(
          //                   context,
          //                   MaterialPageRoute(builder: (context) => Loading()),
          //                 );
          //                 openFile();
          //                 print(_openResult);
          //                 }
          //               },
          //               highlightColor: Colors.teal,
          //               splashColor: Colors.black,
          //               radius: 50,
          //               child: ListTile(
          //                 isThreeLine: false,
          //                 title: Text(
          //                   DemoLocalization.of(context)
          //                       .translate("tap_to_view_report"),
          //                   style: TextStyle(
          //                       color: Theme.of(context).primaryColorDark,
          //                       fontSize: 15.0,
          //                       fontWeight: FontWeight.bold),
          //                 ),
          //                 trailing: Icon(Icons.remove_red_eye,
          //                     size: 25, color: Colors.black),
          //               ),
          //             )),
          //         SizedBox(height: 5,),
          //         // Prescriptions list container
          //         Container(
          //             child: repdata.data()['prescription'] != null ? prescriptList(
          //                 /*
          //               {Uploadreport
          //               'a': 'paracetamol',
          //               'b': 'diclobin +',
          //               'c': 'ceftum glycerol'
          //             }
          //             */
          //                 repdata['prescription']) : null),
          //       ],
          //     ),
          //   ),
          // ),
          //Padding(padding: EdgeInsets.only(top: 2)),
          SizedBox(
            height: 5,
          ),
          repdata.data()['referred_docid'] != null
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15)),
                  ),
                  child: ListTile(
                    isThreeLine: false,
                    leading: Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Image.asset(
                            "assets/docicon1.png",
                            height: 40,
                            width: 40,
                          ),
                        ),
                      ),
                    ),
                    subtitle: Text(
                      DemoLocalization.of(context).translate("referred_dr"),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600),
                    ),
                    title: Text(
                      DemoLocalization.of(context).translate("dr") +
                          repdata.data()["referred_doc"],
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold),
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50)),
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color(0xff0569FF))),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DocPage(
                                      title: DemoLocalization.of(context)
                                          .translate("doctor"),
                                      clickedDoc:
                                          repdata.data()["referred_docid"],
                                    )),
                          );
                        },
                        //icon: Icon(Icons.insert_invitation, size: 35, color: Colors.lightBlueAccent),
                        child: Text(
                          "Book",
                          style: GoogleFonts.manrope(
                              color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
          //Padding(padding: EdgeInsets.only(top: 5)),
        ],
      ),
    );
  }

  Widget prescriptList(Map dic) {
    //print(dic.keys);
    List<Widget> widgetsList = [];
    for (var key in dic.keys) {
      widgetsList.add(Padding(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      dic[key]['name'],
                      style: GoogleFonts.manrope(
                        color: Color.fromRGBO(216, 216, 216, 1),
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${dic[key]['durStart']} to ${dic[key]['durEnd']}",
                          style: GoogleFonts.manrope(
                              color: Colors.white, fontSize: 12),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.circle,
                          size: 12,
                          color: dic[key]['t1'] == ""
                              ? Colors.red[50]
                              : Colors.greenAccent,
                        ),
                        Icon(
                          Icons.circle,
                          size: 12,
                          color: dic[key]['t2'] == ""
                              ? Colors.red[50]
                              : Colors.greenAccent,
                        ),
                        Icon(
                          Icons.circle,
                          size: 12,
                          color: dic[key]['t3'] == ""
                              ? Colors.red[50]
                              : Colors.greenAccent,
                        ),
                      ],
                    ),
                  )
                ],
              )

              // ListTile(
              //   title: Text(
              //     dic[key]['name'],
              //     style: TextStyle(fontSize: 20.0),
              //   ),
              //   trailing:Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       Icon(Icons.circle,
              //         color: dic[key]['t1'] == ""
              //             ? Colors.green[900]
              //             : Colors.green[100],
              //       ),
              //       Icon(Icons.circle,
              //         color: dic[key]['t1'] == ""
              //             ? Colors.green[900]
              //             : Colors.green[100],
              //       ),
              //       Icon(Icons.circle,
              //         color: dic[key]['t1'] == ""
              //             ? Colors.green[900]
              //             : Colors.green[100],
              //       ),
              //                        ],
              //   ),
              //   subtitle:
              //       Text("${dic[key]['durStart']} to ${dic[key]['durEnd']}"),
              )));
    }

    return Column(
      children: widgetsList,
    );
  }
}
