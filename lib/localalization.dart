import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// Uncomment if you are using flutter_dotenv
// import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  Map<String, String>? _localizedStrings;

  /// Loads the localization data, either from cache or API
  Future<bool> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedTranslations = prefs.getString('translations_${locale.languageCode}');

    if (cachedTranslations != null) {
      _localizedStrings = json.decode(cachedTranslations).cast<String, String>();
      return true;
    }

    String jsonString = await _fetchTranslations(locale.languageCode);
    prefs.setString('translations_${locale.languageCode}', jsonString);
    _localizedStrings = json.decode(jsonString).cast<String, String>();

    return true;
  }

  /// Fetches the translations from the API
  Future<String> _fetchTranslations(String languageCode) async {
    const String apiKey = "data";  // "data" is your API key, make sure it's correct

    final response = await http.get(
      Uri.parse('https://spotdev.reapmind.com/beemate/api/languageTranslation/$languageCode'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        // Add any other headers if required
      },
    );

    if (response.statusCode == 200) {
      print('Language data fetched successfully for: $languageCode');
      return response.body;
    } else {
      throw Exception('Failed to load translations');
    }
  }

  /// Translates a given key using the loaded translations
  String translate(String key) {
    return _localizedStrings![key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);  // Add more supported languages here
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
