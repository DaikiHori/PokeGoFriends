import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @helloWorld.
  ///
  /// In en, this message translates to:
  /// **'Hello, World!'**
  String get helloWorld;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}!'**
  String greeting(Object name);

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Poke GO Friends'**
  String get title;

  /// No description provided for @noFriends.
  ///
  /// In en, this message translates to:
  /// **'Please add friends using the \"+\" button below.'**
  String get noFriends;

  /// No description provided for @pluralExample.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{You have {count} item} other{You have {count} items}}'**
  String pluralExample(num count);

  /// No description provided for @addFriendPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Friend'**
  String get addFriendPageTitle;

  /// No description provided for @editFriendPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Friend'**
  String get editFriendPageTitle;

  /// No description provided for @friendNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get friendNameLabel;

  /// No description provided for @friendNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get friendNameRequired;

  /// No description provided for @saveButtonText.
  ///
  /// In en, this message translates to:
  /// **'Save Friend'**
  String get saveButtonText;

  /// No description provided for @friendNicknameLabel.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get friendNicknameLabel;

  /// No description provided for @friendCampfireIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Campfire ID'**
  String get friendCampfireIdLabel;

  /// No description provided for @friendCampfireNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Campfire Name'**
  String get friendCampfireNameLabel;

  /// No description provided for @friendXAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'X (Twitter) Account'**
  String get friendXAccountLabel;

  /// No description provided for @friendLineNameLabel.
  ///
  /// In en, this message translates to:
  /// **'LINE Name'**
  String get friendLineNameLabel;

  /// No description provided for @friendIsLuckyLabel.
  ///
  /// In en, this message translates to:
  /// **'Is Lucky?'**
  String get friendIsLuckyLabel;

  /// No description provided for @friendContactedLabel.
  ///
  /// In en, this message translates to:
  /// **'Contacted'**
  String get friendContactedLabel;

  /// No description provided for @friendCanContactLabel.
  ///
  /// In en, this message translates to:
  /// **'Can Contact'**
  String get friendCanContactLabel;

  /// No description provided for @friendsListPageTitle.
  ///
  /// In en, this message translates to:
  /// **'My Friends'**
  String get friendsListPageTitle;

  /// No description provided for @noFriendsMessage.
  ///
  /// In en, this message translates to:
  /// **'No friends added yet. Tap \'+\' to add one!'**
  String get noFriendsMessage;

  /// No description provided for @addFriendButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add New Friend'**
  String get addFriendButtonTooltip;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Friend?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String deleteConfirmMessage(String name);

  /// No description provided for @cancelButtonText.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButtonText;

  /// No description provided for @deleteButtonText.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButtonText;

  /// No description provided for @friendDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Friend \"{name}\" deleted.'**
  String friendDeletedMessage(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
