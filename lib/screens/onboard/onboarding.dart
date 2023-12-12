import 'package:flutter/material.dart';
import 'package:heyhealth/main.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:heyhealth/screens/wrapper.dart';
import 'package:heyhealth/localisations/local_lang.dart';
import 'package:heyhealth/localisations/lang_const.dart';
import 'package:heyhealth/shared/constants.dart';

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();
  Language dropdownvalue = Language(1, "English", "en");

  void _onIntroEnd(context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => Wrapper()),
    );
  }

  void _changeLanguage(Language language) async {
    Locale _locale = await setLocale(language.languageCode);
    MyApp.setLocale(context, _locale);
  }

  Widget _buildImage(String assetName) {
    return Align(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.asset('assets/onboard/$assetName.png',
              width: 250.0, height: 350),
        ),
      ),
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: DemoLocalization.of(context).translate("welcome_to_hey_doc"),
          bodyWidget: Center(
            child: Container(
              padding: const EdgeInsets.all(0.0),
              child: DropdownButton<Language>(
                underline: SizedBox(),
                hint: Text(
                  "language/भाषा",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                onChanged: (Language language) {
                  _changeLanguage(language);
                },
                items: Language.languageList()
                    .map<DropdownMenuItem<Language>>(
                      (e) => DropdownMenuItem<Language>(
                        value: e,
                        child: Text(
                          e.name,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          image: _buildImage('logo'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: DemoLocalization.of(context).translate('find_doctors'),
          body:
              DemoLocalization.of(context).translate("find_doctor_description"),
          image: _buildImage('find_docs'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: DemoLocalization.of(context).translate("appointments_24*7"),
          body: DemoLocalization.of(context)
              .translate("book_appointment_description"),
          image: _buildImage('appointment'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: DemoLocalization.of(context).translate("report_meds"),
          body: DemoLocalization.of(context)
              .translate("keep_track_of_reports_description"),
          image: _buildImage('report'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: Text(DemoLocalization.of(context).translate("skip")),
      next: const Icon(Icons.arrow_forward),
      done: Text(DemoLocalization.of(context).translate("done"),
          style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
