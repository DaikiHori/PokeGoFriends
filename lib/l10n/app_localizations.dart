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
  /// **'No friends added yet.\n Tap \'+\' to add one!'**
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

  /// No description provided for @searchByNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by Name or Nickname'**
  String get searchByNameLabel;

  /// No description provided for @filterByLuckyLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter by Lucky Status'**
  String get filterByLuckyLabel;

  /// No description provided for @luckyFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get luckyFilterAll;

  /// No description provided for @luckyFilterLuckyOnly.
  ///
  /// In en, this message translates to:
  /// **'Lucky'**
  String get luckyFilterLuckyOnly;

  /// No description provided for @luckyFilterNotLucky.
  ///
  /// In en, this message translates to:
  /// **'Not'**
  String get luckyFilterNotLucky;

  /// No description provided for @noMatchingFriendsMessage.
  ///
  /// In en, this message translates to:
  /// **'No matching friends found.'**
  String get noMatchingFriendsMessage;

  /// No description provided for @ocrFromCameraTooltip.
  ///
  /// In en, this message translates to:
  /// **'OCR from Camera'**
  String get ocrFromCameraTooltip;

  /// No description provided for @ocrFromGalleryTooltip.
  ///
  /// In en, this message translates to:
  /// **'OCR from Gallery'**
  String get ocrFromGalleryTooltip;

  /// No description provided for @ocrResultDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'OCR Results'**
  String get ocrResultDialogTitle;

  /// No description provided for @noTextRecognized.
  ///
  /// In en, this message translates to:
  /// **'No text was recognized.'**
  String get noTextRecognized;

  /// No description provided for @selectTextPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap on the recognized text to select it.'**
  String get selectTextPrompt;

  /// No description provided for @closeButtonText.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButtonText;

  /// No description provided for @permissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Please grant camera/gallery access.'**
  String get permissionDeniedMessage;

  /// No description provided for @imagePickingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Image selection cancelled.'**
  String get imagePickingCancelled;

  /// No description provided for @textRecognitionFailed.
  ///
  /// In en, this message translates to:
  /// **'Text recognition failed: {error}'**
  String textRecognitionFailed(Object error);

  /// No description provided for @sortNameAscTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort by Name (A-Z)'**
  String get sortNameAscTooltip;

  /// No description provided for @sortNameDescTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort by Name (Z-A)'**
  String get sortNameDescTooltip;

  /// No description provided for @sortNicknameAscTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort by Nickname (A-Z)'**
  String get sortNicknameAscTooltip;

  /// No description provided for @sortNicknameDescTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort by Nickname (Z-A)'**
  String get sortNicknameDescTooltip;

  /// No description provided for @exportDataMenuText.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportDataMenuText;

  /// No description provided for @importDataMenuText.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importDataMenuText;

  /// No description provided for @exportSelectLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Export Location'**
  String get exportSelectLocationTitle;

  /// No description provided for @exportSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully to: {path}'**
  String exportSuccessMessage(Object path);

  /// No description provided for @exportCancelledMessage.
  ///
  /// In en, this message translates to:
  /// **'Data export cancelled.'**
  String get exportCancelledMessage;

  /// No description provided for @exportFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to export data: {error}'**
  String exportFailedMessage(Object error);

  /// No description provided for @importSelectFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Import File'**
  String get importSelectFileTitle;

  /// No description provided for @importConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Import'**
  String get importConfirmTitle;

  /// No description provided for @importConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Importing data will delete all existing data. Are you sure you want to proceed?'**
  String get importConfirmMessage;

  /// No description provided for @importConfirmButtonText.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importConfirmButtonText;

  /// No description provided for @importCancelledMessage.
  ///
  /// In en, this message translates to:
  /// **'Data import cancelled.'**
  String get importCancelledMessage;

  /// No description provided for @importFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to import data: {error}'**
  String importFailedMessage(Object error);

  /// No description provided for @csvImportFailedEmptyOrUnreadable.
  ///
  /// In en, this message translates to:
  /// **'CSV import failed: file is empty or unreadable.'**
  String get csvImportFailedEmptyOrUnreadable;

  /// No description provided for @friendImportSummaryMessage.
  ///
  /// In en, this message translates to:
  /// **'Data imported successfully from {path}.\nFriends imported: {friendsCount}.'**
  String friendImportSummaryMessage(Object friendsCount, Object path);

  /// No description provided for @menuTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuTitle;

  /// No description provided for @tradeDateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Trade Date'**
  String get tradeDateTimeLabel;

  /// No description provided for @tradePlaceLabel.
  ///
  /// In en, this message translates to:
  /// **'Trade Place'**
  String get tradePlaceLabel;

  /// No description provided for @dateTimeFormat.
  ///
  /// In en, this message translates to:
  /// **'MM/dd/yyyy h:mm a'**
  String get dateTimeFormat;
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
