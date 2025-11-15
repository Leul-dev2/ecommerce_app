// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get languageTitle => 'Select Language';

  @override
  String get choosePreferredLanguage => 'Choose your preferred language';

  @override
  String get error => 'Error';

  @override
  String get noLanguages => 'No languages found';

  @override
  String get continueButton => 'Continue';
}
