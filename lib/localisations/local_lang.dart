// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DemoLocalization {
  final Locale locale;
  static DemoLocalization? of(BuildContext context) {
    return Localizations.of<DemoLocalization>(context, DemoLocalization);
  }

  Map<String, String> _localizedValues;
  DemoLocalization({
    required this.locale,
    Map<String, String>? localizedValues,
  }) : _localizedValues = localizedValues!;

  Future<void> load() async {
    String jsonStringValues =
        await rootBundle.loadString('lib/lang/${locale.languageCode}.json');
    Map<String, dynamic> mappedJson = json.decode(jsonStringValues);
    _localizedValues =
        mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }

  String? translate(String key) {
    return _localizedValues[key];
  }

  // static member to have simple access to the delegate from Material App
  static const LocalizationsDelegate<DemoLocalization> delegate =
      _DemoLocalizationsDelegate();
}

class _DemoLocalizationsDelegate
    extends LocalizationsDelegate<DemoLocalization> {
  const _DemoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'tr'].contains(locale.languageCode);
  }

  @override
  Future<DemoLocalization> load(Locale locale) async {
    DemoLocalization localization = DemoLocalization(
      locale: locale,
    );
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(LocalizationsDelegate<DemoLocalization> old) => false;
}
