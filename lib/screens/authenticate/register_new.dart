import 'package:flutter/material.dart';
import 'package:heyhealth/localisations/local_lang.dart';

class RegisterNew extends StatefulWidget {
  const RegisterNew({Key key}) : super(key: key);

  @override
  State<RegisterNew> createState() => _RegisterNewState();
}

class _RegisterNewState extends State<RegisterNew> {
  int _groupvalue = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Create Account",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Icon(Icons.person_outline_outlined),
                        ],
                      ),
                      Text("Welcome to heyhealth"),
                    ],
                  ),
                  Image.asset('assets/inside/logo.png',
                      width: 85.0, height: 85.0)
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Container(
                      height: 43,
                      child: TextFormField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: "Name"),
                      ),
                    ),
                    SizedBox(
                      height: 17,
                    ),
                    Container(
                      height: 43,
                      child: TextFormField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: "Mobile Number"),
                      ),
                    ),
                    SizedBox(
                      height: 17,
                    ),
                    Container(
                      height: 43,
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: "Address",
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 17,
                    ),
                    Container(
                      height: 43,
                      child: TextFormField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: "Date of birth: DD/MM/YYYY"),
                      ),
                    ),
                    SizedBox(
                      height: 17,
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Gender")),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile(
                                value: _groupvalue,
                                contentPadding: EdgeInsets.all(0),
                                groupValue: 0,
                                onChanged: (value) {
                                  setState(() {
                                    _groupvalue = 0;
                                  });
                                },
                                title: Text("Male"),
                              ),
                            ),
                            Expanded(
                              child: RadioListTile(
                                value: 1,
                                groupValue: _groupvalue,
                                contentPadding: EdgeInsets.all(0),
                                onChanged: (value) {
                                  setState(() {
                                    _groupvalue = 1;
                                  });
                                },
                                title: Text("Female"),
                              ),
                            ),
                            Expanded(
                              child: RadioListTile(
                                value: 2,
                                groupValue: _groupvalue,
                                contentPadding: EdgeInsets.all(0),
                                onChanged: (value) {
                                  setState(() {
                                    _groupvalue = 2;
                                  });
                                },
                                title: Text("Other"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                height: 55,
                width: double.infinity,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(8),
                      primary: Color.fromRGBO(3, 43, 68, 1),
                    ),
                    child: Text(
                      DemoLocalization.of(context).translate("finish"),
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    onPressed: () {}),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
