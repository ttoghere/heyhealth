import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:heyhealth/pages/doc.dart';
import 'package:heyhealth/shared/loading.dart';
import 'package:heyhealth/shared/methods.dart';
import 'package:provider/provider.dart';
import 'package:heyhealth/models/user.dart';
import 'package:heyhealth/localisations/local_lang.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share/share.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class Appointment extends StatefulWidget {
  @override
  ProfileState createState() {
    return ProfileState();
  }
}

class ProfileState extends State<Appointment> {
  List appointmentlist = [];
  List pastappointments = [];
  List nextappointments = [];
  String _linkMessage;
  bool _isCreatingLink = false;
  double rating = 0.0;
  TextEditingController reviewTextController = TextEditingController();

  Future<dynamic> _appointments(uid) async {
    var firestore = FirebaseFirestore.instance;
    QuerySnapshot ds = await firestore
        .collection('patients')
        .doc(uid)
        .collection('appointments')
        .orderBy('appointmenttime')
        .get();
    print(ds.size);
    if (ds.size > 0) return ds;
  }

  Future<void> _createDynamicLink(bool short, String id, String name) async {
    print("Name Passded " + name);
    setState(() {
      _isCreatingLink = true;
    });

    final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: 'https://heyhealth.page.link',
        link: Uri.parse('https://heyhealth.page.link/refer?refId=' + id),
        androidParameters: AndroidParameters(
          packageName: 'com.heyhealth.heyhealth',
          minimumVersion: 0,
        ),
        dynamicLinkParametersOptions: DynamicLinkParametersOptions(
          shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
        ),
        iosParameters: IosParameters(
          bundleId: 'com.heyhealth.heyhealth',
          minimumVersion: '0',
        ),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: DemoLocalization.of(context).translate("view_dr") +
              " " +
              name +
              " " +
              DemoLocalization.of(context).translate("on_heyhealth"),
          description:
              DemoLocalization.of(context).translate("heyhealth_description"),
          imageUrl: Uri(
              scheme: 'https',
              path:
                  'https://res-3.cloudinary.com/crunchbase-production/image/upload/c_lpad,h_170,w_170,f_auto,b_white,q_auto:eco/zb104qvexylrksbpisd6'),
        ));

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink = await parameters.buildShortLink();
      url = shortLink.shortUrl;
    } else {
      url = await parameters.buildUrl();
    }

    setState(() {
      _linkMessage = url.toString();
      _isCreatingLink = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(elevation: 0,
      //   backgroundColor: Colors.white,
      //   title:Row(children: [
      //     Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: Icon(Icons.calendar_today,color: Color(0xff032B44),),
      //     ),
      //     Text("Appointments",style: GoogleFonts.manrope(color: Colors.black,fontSize: 21,fontWeight: FontWeight.bold),)
      //   ],) ,
      //
      //   actions: [
      //     Padding(
      //       padding: const EdgeInsets.only(right: 15.0),
      //       child: Image.asset("assets/onboard/logo.png",width: 50,),
      //     )
      //   ],
      // ),
      backgroundColor: Colors.white,
      body: _buildBody(context),
    );
  }

  Widget appointmentcard(data, flag, rating) {
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
    // print(data.data);
    return InkWell(
      splashColor: Colors.blue.withAlpha(30),
      onTap: () {
        //print(data);
        /*
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DocPage(
                    title: data['specialization'],
                    clickedDoc: data.documentID,
                  )),
        );
        */
      },
      child: Container(
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        decoration: BoxDecoration(
          color: Color(0xff032B44),
          border: Border.all(color: Color(0xff032B44), width: 1),
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
          children: [
            ListTile(
              leading: Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Image.asset(
                      "assets/docicon3.png",
                      height: 50,
                      width: 50,
                    ),
                  ),
                ),
              ),
              title: Text(
                DemoLocalization.of(context).translate("dr") +
                    data.data()['docname'],
                style: GoogleFonts.manrope(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Row(
                children: [
                  Text(
                      (data.data()['appointmentdate'])
                              .toString()
                              .substring(0, 2) +
                          " " +
                          month[int.parse((data.data()['appointmentdate'])
                                  .toString()
                                  .substring(3, 5)) -
                              1] +
                          ", " +
                          to12hr(data.data()['appointmenttime']),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        color: Color.fromRGBO(216, 216, 216, 1),
                      )),
                  Text(
                    data.data()['appointmenttype'] != 'video'
                        ? " |  In-Person"
                        : " | Video Consultation",
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      color: Color.fromRGBO(216, 216, 216, 1),
                    ),
                  ),
                ],
              ),
              /*
                            trailing: flag?SizedBox():InkWell(
                              onTap: (){},
                              child: Column(children: [
                                Icon(Icons.list_alt_outlined,color: Colors.white,),
                                Text("Report",style: GoogleFonts.manrope(color: Colors.white,fontSize: 12),)
                              ],),
                            ),
                            */
              // childrenPadding: EdgeInsets.all(12),

              // child: Container(
              //   padding: EdgeInsets.only(
              //     top: 10,
              //     bottom: 10,
              //     right: 15,
              //     left: 15,
              //   ),
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Row(
              //         children: [
              //           Container(
              //             padding:
              //                 EdgeInsets.only(left: 10, right: 10),
              //             child: ClipRRect(
              //               borderRadius: BorderRadius.circular(60),
              //               child: Image(
              //                 height: 60,
              //                 width: 60,
              //                 image: NetworkImage(data.data()['profileurl'] == null
              //       ? 'https://icons.iconarchive.com/icons/aha-soft/free-large-boss/512/Head-Physician-icon.png'
              //       : data.data()['profileurl']),
              //               ),),
              //           ),
              //           Expanded(
              //               child: Container(
              //             padding: EdgeInsets.only(
              //                 top: 10, bottom: 10, right: 10),
              //             child: Column(
              //                 mainAxisAlignment:
              //                     MainAxisAlignment.spaceBetween,
              //                 crossAxisAlignment:
              //                     CrossAxisAlignment.start,
              //                 children: [
              //                   Text(
              //                     DemoLocalization.of(context)
              //                             .translate("dr") +
              //                         data.data()['docname'],
              //                     style: GoogleFonts.manrope(
              //                       fontSize: 21,
              //                       color: Color.fromRGBO(0, 0, 0, 1),
              //                       fontWeight: FontWeight.w600,
              //                     ),
              //                   ),
              //                   Text(
              //                     data.data()['docspecialization'],
              //                     style: GoogleFonts.manrope(
              //                       fontSize: 14,
              //                       fontWeight: FontWeight.w500,
              //                       color:
              //                           Color.fromRGBO(0, 0, 0, 0.9),
              //                     ),
              //                   ),
              //                   Text(data.data()['appointmenttype'] != 'video' ? "In-Person appointment":"Video Consultation",
              //                     style: GoogleFonts.manrope(
              //                       fontSize: 13,
              //                       color:
              //                           Color.fromRGBO(0, 0, 0, 0.9),
              //                     ),
              //                   ),
              //                 ]),
              //           ))
              //         ],
              //       ),
              //
              //       //ratingBar(3.67),
              //       Row(
              //         children: [
              //           Expanded(
              //             child: Container(
              //               width: double.infinity,
              //               margin:
              //                   EdgeInsets.only(right: 10, top: 5),
              //               height: 40,
              //               decoration: BoxDecoration(
              //                 color: data.data()['appointmenttype'] != 'video'
              //                    ? Color.fromRGBO(149,250,196,1)
              //                    : Colors.pink[100], //
              //                 borderRadius: BorderRadius.all(
              //                   Radius.circular(10),
              //                 ),
              //               ),
              //               child: TextButton(
              //                 child: Text(
              //                     to12hr(data.data()['appointmenttime']),
              //                     textAlign: TextAlign.center,
              //                     style: GoogleFonts.manrope(
              //                       color: Colors.black,
              //                     )),
              //                 onPressed: () {},
              //               ),
              //             ),
              //           ),
              //           Expanded(
              //             child: Container(
              //               //width: 130,
              //               margin:
              //                   EdgeInsets.only(right: 10, top: 5),
              //               height: 40,
              //               decoration: BoxDecoration(
              //                 color: data.data()['appointmenttype'] != 'video'
              //                   ? Color.fromRGBO(149,250,196,1)
              //                   : Colors.pink[100],
              //                 borderRadius: BorderRadius.all(
              //                   Radius.circular(10),
              //                 ),
              //               ),
              //               child: TextButton(
              //                 child: Text(data.data()['appointmentdate'],
              //                     textAlign: TextAlign.center,
              //                     style: GoogleFonts.manrope(
              //                       color: Colors.black,
              //                     )),
              //                 onPressed: () {},
              //               ),
              //             ),
              //           )
              //         ],
              //       ),
              //       //Expanded(child:
              //       Container(
              //         width: double.infinity,
              //         margin: EdgeInsets.only(right: 10, top: 10),
              //         height: 50,
              //         decoration: BoxDecoration(
              //           color: data.data()['appointmenttype'] != 'video'
              //           ? Color.fromRGBO(03, 43, 68, 1)
              //           : Colors.deepPurple[900],
              //           borderRadius: BorderRadius.all(
              //             Radius.circular(10),
              //           ),
              //         ),
              //         child: TextButton(
              //           child: Text(
              //               data.data()['appointmenttype'] != 'video'
              //                   ? DemoLocalization.of(context)
              //                       .translate(
              //                           "in_person_appointment")
              //                   : DemoLocalization.of(context)
              //                       .translate("video_consultation"),
              //               textAlign: TextAlign.center,
              //               style: GoogleFonts.manrope(
              //                 color: Colors.white,
              //               )),
              //           onPressed: () {},
              //         ),
              //       ),
              //       // )
              //     ],
              //   ),
              // ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                flag
                    ? InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DocPage(
                                      title: data.data()['specialization'],
                                      clickedDoc: data.data()['doctorid'],
                                    )),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 10, bottom: 10, right: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.alarm,
                                color: Colors.white,
                              ),
                              Text(
                                "Reschedule",
                                style: GoogleFonts.manrope(
                                    color: Colors.white, fontSize: 12),
                              )
                            ],
                          ),
                        ),
                      )
                    : InkWell(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 10, bottom: 10, right: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_add_alt,
                                color: Colors.white,
                              ),
                              Text(
                                "Rebook",
                                style: GoogleFonts.manrope(
                                    color: Colors.white, fontSize: 12),
                              )
                            ],
                          ),
                        ),
                      ),
                flag
                    ? InkWell(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 10, bottom: 10, right: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cancel,
                                color: Colors.white,
                              ),
                              Text(
                                "Cancel",
                                style: GoogleFonts.manrope(
                                    color: Colors.white, fontSize: 12),
                              )
                            ],
                          ),
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          print("tapped");
                          showRatingDialogue(context, reviewTextController,
                              rating); //todo:Rating value
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 10, bottom: 10, right: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.thumb_up_off_alt_rounded,
                                color: Colors.white,
                              ),
                              Text(
                                "Review",
                                style: GoogleFonts.manrope(
                                    color: Colors.white, fontSize: 12),
                              )
                            ],
                          ),
                        ),
                      ),
                flag
                    ? SizedBox(
                        width: 60,
                      )
                    : InkWell(
                        onTap: !_isCreatingLink
                            ? () async {
                                print("Clicked");
                                print(data.data());
                                print("ID:" +
                                    data.data()['doctorid'] +
                                    " " +
                                    data.data()['docname']);
                                await _createDynamicLink(
                                    true,
                                    data.data()['doctorid'],
                                    data.data()['docname']);
                                //print();
                                print("MEssage:" + _linkMessage);
                                print("Collected");
                                final RenderBox box =
                                    context.findRenderObject();
                                Share.share(
                                  _linkMessage,
                                  /*
                            subject:
                                DemoLocalization.of(context).translate("view") +
                                    docdata['name'] +
                                    DemoLocalization.of(context)
                                        .translate("on_heyhealth"),
                                        */
                                  sharePositionOrigin:
                                      box.localToGlobal(Offset.zero) & box.size,
                                );
                                print("Message");
                              }
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 10, bottom: 10, right: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite,
                                color: Colors.white,
                              ),
                              Text(
                                "Favourite",
                                style: GoogleFonts.manrope(
                                    color: Colors.white, fontSize: 12),
                              )
                            ],
                          ),
                        ),
                      ),
                flag
                    ? SizedBox(
                        width: 60,
                      )
                    : InkWell(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 10, bottom: 10, right: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                              Text(
                                "Recommend",
                                style: GoogleFonts.manrope(
                                    color: Colors.white, fontSize: 12),
                              )
                            ],
                          ),
                        ),
                      ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    // const i=0;
    User user = Provider.of<User>(context);
    return FutureBuilder(
      future: _appointments(user.uid),
      builder: (
        BuildContext context,
        AsyncSnapshot snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Loading();
        else if (!snapshot.hasData)
          return Container(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.contain,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset('assets/onboard/appointment.png',
                      width: 500.0, height: 300),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "No Appointment Proccessed",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ));

        appointmentlist = snapshot.data.docs.toList();
        for (int i = 0; i < appointmentlist.length; i++) {
          var datesplit = appointmentlist[i]['appointmentdate'].split('-');
          var thisdate = datesplit[2] + '-' + datesplit[1] + '-' + datesplit[0];
          var thistime = appointmentlist[i]['appointmenttime'] + ':00.000';
          var thisdatetime = thisdate + ' ' + thistime;
          var now = DateTime.now();
          if (now.isAfter(DateTime.parse(thisdatetime))) {
            pastappointments.add(appointmentlist[i]);
          } else
            nextappointments.add(appointmentlist[i]);
        }
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              /*
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton.icon(onPressed: (){}, icon: Icon(Icons.folder,color: Colors.white,), label: Text("Reports",style: GoogleFonts.manrope(color: Colors.white),)),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton.icon(onPressed: (){}, icon: Icon(Icons.search,color: Colors.white,), label: Text("",style: GoogleFonts.manrope(color: Colors.white),)),
                ),

              ],),
*/
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  DemoLocalization.of(context)
                      .translate("upcoming_appointments"),
                  style: GoogleFonts.manrope(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                ),
                // subtitle: Container(
                //   padding: EdgeInsets.only(top: 10.0),
                //   child: Text(
                //     DemoLocalization.of(context)
                //         .translate("we_show_active_appointment"),
                //     style: GoogleFonts.manrope(color: Colors.grey, fontSize: 15.0),
                //   ),
                // ),
              ),
              nextappointments.length == 0
                  ? SizedBox(
                      height: 50,
                      child: Text(
                        "",
                        // DemoLocalization.of(context)
                        //    .translate("u_hv_no_active_appointment"),
                        style: GoogleFonts.manrope(
                            color: Colors.green[900],
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  : Column(
                      children: nextappointments.map((element) {
                        return appointmentcard(element, true, rating);
                      }).toList(),
                    ),
              Divider(
                color: Theme.of(context).primaryColor,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  DemoLocalization.of(context).translate("past_appointments"),
                  style: GoogleFonts.manrope(
                      color: Theme.of(context).primaryColorDark,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                ),
                // subtitle: Container(
                //   padding: EdgeInsets.only(top: 10.0),
                //   child: Text(
                //     DemoLocalization.of(context)
                //         .translate("we_show_previous_bookings"),
                //     style: GoogleFonts.manrope(color: Colors.grey, fontSize: 15.0),
                //   ),
                // ),
              ),
              pastappointments.length == 0
                  ? SizedBox(
                      height: 50,
                      child: Text(
                          DemoLocalization.of(context)
                              .translate("u_hv_no_prior_appointments"),
                          style: GoogleFonts.manrope(
                              color: Colors.green[900],
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold)))
                  : Column(
                      children: pastappointments.map((element) {
                        return appointmentcard(element, false, rating);
                      }).toList(),
                    ),
            ],
          ),
        );
      },
    );
  }

  showRatingDialogue(BuildContext context,
      TextEditingController reviewTextController, double rating) {
    showDialog(
        context: context,
        barrierDismissible: true, // set to false if you want to force a rating
        builder: (context) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white),
                  height: MediaQuery.of(context).size.height / 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Rate the Doctor',
                          style: GoogleFonts.manrope(
                              color: Colors.black, fontSize: 16),
                        ),
                        Text("Your Rating: $rating/5",
                            style: GoogleFonts.manrope(
                                color: Color(0xff032B44), fontSize: 16)),
                        SmoothStarRating(
                          rating: rating,
                          isReadOnly: false,
                          size: 50,
                          color: Color(0xff032B44),
                          borderColor: Color(0xff032B44),
                          filledIconData: Icons.star,
                          halfFilledIconData: Icons.star_half,
                          defaultIconData: Icons.star_border,
                          starCount: 5,
                          allowHalfRating: true,
                          spacing: 1.0,
                          onRated: (value) {
                            rating = value;
                          },
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  maxLines: 4,
                                  cursorColor: Colors.black,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.go,
                                  controller: reviewTextController,
                                  style: TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide(
                                        width: 2.0,
                                        color: Color.fromRGBO(3, 43, 68, 1),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide(
                                        width: 2.0,
                                        color: Color.fromRGBO(3, 43, 68, 1),
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    hintText: "Write a Review..",
                                    hintStyle: GoogleFonts.manrope(
                                      fontSize: 15,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 40,
                          width: double.infinity,
                          margin: EdgeInsets.all(8),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              //  padding: EdgeInsets.all(12),
                              primary: Color.fromRGBO(5, 105, 255, 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    //DemoLocalization.of(context).translate("Scan QR"),
                                    "Submit",
                                    style: GoogleFonts.manrope(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                            onPressed: () {
                              print(reviewTextController.text +
                                  " " +
                                  rating.toString());
                              Navigator.pop(context, false);
                              //todo upload the data to database
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
