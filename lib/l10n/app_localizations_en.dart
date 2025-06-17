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
  String get noFriendsMessage => 'No friends added yet. Tap \'+\' to add one!';

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
}
