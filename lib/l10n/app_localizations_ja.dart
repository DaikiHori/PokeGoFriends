// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get helloWorld => 'こんにちは、世界！';

  @override
  String greeting(Object name) {
    return 'こんにちは、$nameさん！';
  }

  @override
  String get title => 'Poke GO Friends';

  @override
  String get noFriends => '下の「＋」ボタンからフレンドを追加して下さい。';

  @override
  String pluralExample(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count個のアイテムがあります',
      one: '$count個のアイテムがあります',
    );
    return '$_temp0';
  }

  @override
  String get addFriendPageTitle => '新しいフレンドを追加';

  @override
  String get editFriendPageTitle => 'フレンドを編集';

  @override
  String get friendNameLabel => '名前';

  @override
  String get friendNameRequired => '名前は必須です';

  @override
  String get saveButtonText => 'フレンドを保存';

  @override
  String get friendNicknameLabel => 'ニックネーム';

  @override
  String get friendCampfireIdLabel => 'キャンプファイアID';

  @override
  String get friendCampfireNameLabel => 'キャンプファイア名';

  @override
  String get friendXAccountLabel => 'X (旧Twitter) アカウント';

  @override
  String get friendLineNameLabel => 'LINE名';

  @override
  String get friendIsLuckyLabel => 'キラ';

  @override
  String get friendContactedLabel => '連絡済み';

  @override
  String get friendCanContactLabel => '連絡可能';

  @override
  String get friendsListPageTitle => 'マイフレンド';

  @override
  String get noFriendsMessage => 'まだフレンドがいません。\n「+」をタップして追加してください！';

  @override
  String get addFriendButtonTooltip => '新しいフレンドを追加';

  @override
  String get deleteConfirmTitle => 'フレンドを削除しますか？';

  @override
  String deleteConfirmMessage(String name) {
    return '$nameさんを削除してもよろしいですか？';
  }

  @override
  String get cancelButtonText => 'キャンセル';

  @override
  String get deleteButtonText => '削除';

  @override
  String friendDeletedMessage(String name) {
    return '$nameさんを削除しました。';
  }

  @override
  String get searchByNameLabel => '名前またはニックネームで検索';

  @override
  String get filterByLuckyLabel => 'キラで絞り込み';

  @override
  String get luckyFilterAll => 'すべて';

  @override
  String get luckyFilterLuckyOnly => 'キラ';

  @override
  String get luckyFilterNotLucky => '!キラ';

  @override
  String get noMatchingFriendsMessage => '該当する友達が見つかりませんでした。';

  @override
  String get ocrFromCameraTooltip => 'カメラからOCR';

  @override
  String get ocrFromGalleryTooltip => 'ギャラリーからOCR';

  @override
  String get ocrResultDialogTitle => 'OCR結果';

  @override
  String get noTextRecognized => 'テキストが認識されませんでした。';

  @override
  String get selectTextPrompt => '認識されたテキストをタップして選択してください。';

  @override
  String get closeButtonText => '閉じる';

  @override
  String get permissionDeniedMessage => '権限が拒否されました。カメラ/ギャラリーへのアクセスを許可してください。';

  @override
  String get imagePickingCancelled => '画像の選択がキャンセルされました。';

  @override
  String textRecognitionFailed(Object error) {
    return 'テキスト認識に失敗しました: $error';
  }

  @override
  String get sortNameAscTooltip => '名前で昇順ソート (あ-ん)';

  @override
  String get sortNameDescTooltip => '名前で降順ソート (ん-あ)';

  @override
  String get sortNicknameAscTooltip => 'ニックネームで昇順ソート (あ-ん)';

  @override
  String get sortNicknameDescTooltip => 'ニックネームで降順ソート (ん-あ)';

  @override
  String get exportDataMenuText => 'データエクスポート';

  @override
  String get importDataMenuText => 'データインポート';

  @override
  String get exportSelectLocationTitle => 'エクスポート先を選択';

  @override
  String exportSuccessMessage(Object path) {
    return 'データを $path にエクスポートしました。';
  }

  @override
  String get exportCancelledMessage => 'データのエクスポートがキャンセルされました。';

  @override
  String exportFailedMessage(Object error) {
    return 'データのエクスポートに失敗しました: $error';
  }

  @override
  String get importSelectFileTitle => 'インポートファイルを選択';

  @override
  String get importConfirmTitle => 'インポートの確認';

  @override
  String get importConfirmMessage =>
      'データをインポートすると、既存の全てのデータが削除されます。続行してもよろしいですか？';

  @override
  String get importConfirmButtonText => 'インポート';

  @override
  String get importCancelledMessage => 'データのインポートがキャンセルされました。';

  @override
  String importFailedMessage(Object error) {
    return 'データのインポートに失敗しました: $error';
  }

  @override
  String get csvImportFailedEmptyOrUnreadable =>
      'CSVインポートに失敗しました: ファイルが空であるか、読み取れません。';

  @override
  String friendImportSummaryMessage(Object friendsCount, Object path) {
    return '$path からデータをインポートしました。\n友達: $friendsCount件';
  }

  @override
  String get menuTitle => 'メニュー';

  @override
  String get tradeDateTimeLabel => 'トレード日時';

  @override
  String get tradePlaceLabel => 'トレード場所';

  @override
  String get dateTimeFormat => 'yyyy/MM/dd HH:mm';
}
