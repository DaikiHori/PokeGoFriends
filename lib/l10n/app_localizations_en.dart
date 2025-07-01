// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloWorld => 'Hello, World!';

  @override
  String greeting(Object name) {
    return 'Hello, $name!';
  }

  @override
  String get title => 'Poke GO Friends';

  @override
  String get noFriends => 'Please add friends using the \"+\" button below.';

  @override
  String pluralExample(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have $count items',
      one: 'You have $count item',
    );
    return '$_temp0';
  }

  @override
  String get addFriendPageTitle => 'Add New Friend';

  @override
  String get editFriendPageTitle => 'Edit Friend';

  @override
  String get friendNameLabel => 'Name';

  @override
  String get friendNameRequired => 'Name cannot be empty';

  @override
  String get saveButtonText => 'Save Friend';

  @override
  String get friendNicknameLabel => 'Nickname';

  @override
  String get friendCampfireIdLabel => 'Campfire ID';

  @override
  String get friendCampfireNameLabel => 'Campfire Name';

  @override
  String get friendXAccountLabel => 'X (Twitter) Account';

  @override
  String get friendLineNameLabel => 'LINE Name';

  @override
  String get friendIsLuckyLabel => 'Is Lucky?';

  @override
  String get friendContactedLabel => 'Contacted';

  @override
  String get friendCanContactLabel => 'Can Contact';

  @override
  String get friendsListPageTitle => 'My Friends';

  @override
  String get noFriendsMessage =>
      'No friends added yet.\n Tap \'+\' to add one!';

  @override
  String get addFriendButtonTooltip => 'Add New Friend';

  @override
  String get deleteConfirmTitle => 'Delete Friend?';

  @override
  String deleteConfirmMessage(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get cancelButtonText => 'Cancel';

  @override
  String get deleteButtonText => 'Delete';

  @override
  String friendDeletedMessage(String name) {
    return 'Friend \"$name\" deleted.';
  }

  @override
  String get searchByNameLabel => 'Search by Name';

  @override
  String get filterByLuckyLabel => 'Filter by Lucky Status';

  @override
  String get luckyFilterAll => 'All';

  @override
  String get luckyFilterLuckyOnly => 'Lucky';

  @override
  String get luckyFilterNotLucky => 'Not';

  @override
  String get noMatchingFriendsMessage => 'No matching friends found.';

  @override
  String get ocrFromCameraTooltip => 'OCR from Camera';

  @override
  String get ocrFromGalleryTooltip => 'OCR from Gallery';

  @override
  String get ocrResultDialogTitle => 'OCR Results';

  @override
  String get noTextRecognized => 'No text was recognized.';

  @override
  String get selectTextPrompt => 'Tap on the recognized text to select it.';

  @override
  String get closeButtonText => 'Close';

  @override
  String get permissionDeniedMessage =>
      'Permission denied. Please grant camera/gallery access.';

  @override
  String get imagePickingCancelled => 'Image selection cancelled.';

  @override
  String textRecognitionFailed(Object error) {
    return 'Text recognition failed: $error';
  }
}
