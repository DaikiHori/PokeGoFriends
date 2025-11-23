// lib/screens/add_friend_page.dart
import 'package:flutter/material.dart';
import '../models/friend.dart'; // Friendモデルクラスをインポート
import '../database/database_helper.dart';   // DbHelperクラスをインポート
import 'package:poke_go_friends/l10n/app_localizations.dart'; // 多言語対応のためのインポート
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controller/date_time_controller.dart';

// AddFriendPageは新しい友達を追加/既存の友達を編集するためのステートフルウィジェットです。
class AddFriendPage extends StatefulWidget {
  // 編集する友達のオブジェクト（新規追加の場合はnull）
  final Friend? friendToEdit;
  const AddFriendPage({super.key, this.friendToEdit});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  // 入力フォームのキー
  final _formKey = GlobalKey<FormState>();

  // 友達の名前入力用コントローラー
  final TextEditingController _nameController = TextEditingController();
  // 友達のニックネーム入力用コントローラー
  final TextEditingController _nicknameController = TextEditingController();
  // キャンプファイアID入力用コントローラー
  final TextEditingController _campfireIdController = TextEditingController();
  // キャンプファイア名入力用コントローラー
  final TextEditingController _campfireNameController = TextEditingController();
  // Xアカウント入力用コントローラー
  final TextEditingController _xAccountController = TextEditingController();
  // LINE名入力用コントローラー
  final TextEditingController _lineNameController = TextEditingController();
  // トレード日
  final TextEditingController _tradeDateTimeController = TextEditingController();
  // トレード場所
  final TextEditingController _tradePlaceController = TextEditingController();

  late final DateTimeController _dateTimeController;

  late final AppLocalizations localizations;
  // booleanフィールド: lucky
  bool _isLucky = false;
  // booleanフィールド: contacted
  bool _isContacted = false;
  // booleanフィールド: canContact
  bool _canContact = false;

  // 編集モードの場合、既存のFriendオブジェクトを保持
  Friend? _currentFriend;
  // ImagePickerのインスタンス
  final ImagePicker _picker = ImagePicker();
  // TextRecognizerのインスタンス
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.japanese);
  @override
  void initState() {
    super.initState();
    // widget.friendToEdit がnullでなければ、編集モードとして初期データを設定
    if (widget.friendToEdit != null) {
      _currentFriend = widget.friendToEdit;
      _nameController.text = _currentFriend!.name;
      _nicknameController.text = _currentFriend!.nickname ?? '';
      _campfireIdController.text = _currentFriend!.campfireId ?? '';
      _campfireNameController.text = _currentFriend!.campfireName ?? '';
      _xAccountController.text = _currentFriend!.xAccount ?? '';
      _lineNameController.text = _currentFriend!.lineName ?? '';
      _tradeDateTimeController.text = _currentFriend!.tradeDateTime?.toString() ?? '';
      _tradePlaceController.text = _currentFriend!.tradePlace ?? '';

      _isLucky = _currentFriend!.lucky == 1;
      _isContacted = _currentFriend!.contacted == 1;
      _canContact = _currentFriend!.canContact == 1;
    }
    _dateTimeController = context.read<DateTimeController>();
  }
  bool _isInitialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final String languageCode = Localizations.localeOf(context).languageCode;
      if (widget.friendToEdit != null) {
        final existingDateTime = widget.friendToEdit!.tradeDateTime;
        if (existingDateTime != null) {
          // DateTimeControllerに値をセット
          _dateTimeController.setDate(existingDateTime);
          // TextFieldにロケール対応した初期値をセット
          _updateTradeDateTimeText(existingDateTime, languageCode);
        }
      }
      _isInitialized = true;
    }
  }

  // 画像を選択し、OCRでテキストを認識する非同期メソッド
  Future<void> _pickImageAndRecognizeText(ImageSource source, TextEditingController controller) async {
    final localizations = AppLocalizations.of(context)!;
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.imagePickingCancelled)),
        );
        return;
      }

      final InputImage inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      if (recognizedText.text.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.noTextRecognized)),
        );
        return;
      }

      // 認識されたテキストを行ごとに分割
      final List<String> lines = recognizedText.blocks.expand((block) => block.lines.map((line) => line.text)).toList();

      if (!mounted) return;
      // 認識されたテキストをユーザーに表示し、選択させるダイアログ
      final String? selectedText = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(localizations.ocrResultDialogTitle),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: lines.length,
                itemBuilder: (BuildContext context, int index) {
                  final String line = lines[index];
                  return ListTile(
                    title: Text(line),
                    onTap: () {
                      Navigator.of(context).pop(line); // 選択された行を返す
                    },
                  );
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(), // ダイアログを閉じる
                child: Text(localizations.closeButtonText),
              ),
            ],
          );
        },
      );

      if (selectedText != null) {
        controller.text = selectedText; // 選択されたテキストをコントローラーに設定
      }
    } catch (e) {
      if (!mounted) return;
      String errorMessage;
      if (e.toString().contains("Permission denied")) {
        errorMessage = localizations.permissionDeniedMessage;
      } else {
        errorMessage = localizations.textRecognitionFailed(e.toString());
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      print('OCR処理中にエラーが発生しました: $e');
    }
  }

  @override
  void dispose() {
    // コントローラーはウィジェットが破棄されるときに破棄する必要があります
    _nameController.dispose();
    _nicknameController.dispose();
    _campfireIdController.dispose();
    _campfireNameController.dispose();
    _xAccountController.dispose();
    _lineNameController.dispose();
    _tradeDateTimeController.dispose();
    _tradePlaceController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  // 友達をデータベースに保存または更新する非同期メソッド
  Future<void> _saveFriend() async {
    // フォームのバリデーションを実行
    if (_formKey.currentState!.validate()) {
      // Friendオブジェクトを作成
      final Friend friendToSave = Friend(
        // 編集モードの場合は既存のIDを使用、新規追加の場合はnull
        id: _currentFriend?.id,
        name: _nameController.text,
        lucky: _isLucky ? 1 : 0,
        nickname: _nicknameController.text.isEmpty ? null : _nicknameController.text,
        campfireId: _campfireIdController.text.isEmpty ? null : _campfireIdController.text,
        campfireName: _campfireNameController.text.isEmpty ? null : _campfireNameController.text,
        contacted: _isContacted ? 1 : 0,
        canContact: _canContact ? 1 : 0,
        xAccount: _xAccountController.text.isEmpty ? null : _xAccountController.text,
        lineName: _lineNameController.text.isEmpty ? null : _lineNameController.text,
        tradeDateTime: _tradeDateTimeController.text.isEmpty ? null : convertCustomFormat(_tradeDateTimeController.text),
        tradePlace: _tradePlaceController.text.isEmpty ? null : _tradePlaceController.text
      );

      final dbHelper = DbHelper.instance;
      try {
        int id;
        String message;
        if (friendToSave.id == null) {
          // 新規追加
          id = await dbHelper.insertFriend(friendToSave);
          message = 'Friend "${friendToSave.name}" saved with ID: $id';
        } else {
          // 更新
          id = await dbHelper.updateFriend(friendToSave);
          message = 'Friend "${friendToSave.name}" updated.';
        }

        // 保存/更新成功時のフィードバック
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        // 保存/更新後、前の画面に戻る
        Navigator.pop(context, true); // trueを渡してデータが更新されたことを前の画面に伝える
      } catch (e) {
        // 保存/更新失敗時のエラーフィードバック
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save friend: $e')),
        );
      }
    }
  }

  // OCRボタンを生成するヘルパーウィジェット
  Widget _buildOcrButtons(TextEditingController controller, AppLocalizations localizations) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.camera_alt),
          tooltip: localizations.ocrFromCameraTooltip,
          onPressed: () => _pickImageAndRecognizeText(ImageSource.camera, controller),
        ),
        IconButton(
          icon: const Icon(Icons.image),
          tooltip: localizations.ocrFromGalleryTooltip,
          onPressed: () => _pickImageAndRecognizeText(ImageSource.gallery, controller),
        ),
      ],
    );
  }

  DateTime? convertCustomFormat(String input) {
    final localizations = AppLocalizations.of(context)!;
    final String formatString = localizations.dateTimeFormat;
    // 入力形式に完全に一致するDateFormatオブジェクトを作成
    DateFormat format = DateFormat(formatString);

    try {
      // parseStrict: true を指定すると、形式が厳密にチェックされます
      DateTime result = format.parseStrict(input);
      return result;
    } on FormatException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to exchange datetime: $e')),
      );
    }
  }
  // 💡 languageCode を引数として受け取るように修正
  void _updateTradeDateTimeText(DateTime date, String languageCode) {
    // 1. AppLocalizationsからロケール固有のフォーマット文字列を取得
    final localizations = AppLocalizations.of(context)!;
    final String formatString = localizations.dateTimeFormat; // .arbファイルで定義されたフォーマット文字列

    // 2. DateFormatにロケールとフォーマット文字列を渡す
    final DateFormat formatter = DateFormat(formatString, languageCode);

    String formattedDate = formatter.format(date);
    _tradeDateTimeController.text = formattedDate;
  }

  Future<void> _selectDateTime(BuildContext context) async {
    // 1. まず日付を選択 (showDatePicker)
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateTimeController.selectedDate,
      firstDate: DateTime(2000), // 選択可能な範囲を設定
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) return; // 日付選択がキャンセルされたら終了

    // 2. 次に時刻を選択 (showTimePicker)
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTimeController.selectedDate),
    );

    if (pickedTime == null) return; // 時刻選択がキャンセルされたら終了

    // 3. 選択された日付と時刻を結合
    final DateTime finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    // 4. ControllerとTextFieldを更新
    _dateTimeController.setDate(finalDateTime);
    // 💡 ここで context からロケール情報を取得し、整形関数に渡す
    final String languageCode = Localizations.localeOf(context).languageCode;
    // TextFieldの表示を更新
    _updateTradeDateTimeText(finalDateTime, languageCode);
  }

  @override
  Widget build(BuildContext context) {
    // 多言語対応のテキストリソースを取得
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        // 編集モードか新規追加モードかでタイトルを動的に変更
        title: Text(widget.friendToEdit == null
            ? localizations.addFriendPageTitle
            : localizations.editFriendPageTitle), // 新しい多言語キー
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // フォームのバリデーションキー
          child: ListView(
            children: <Widget>[
              // 名前（必須）
              Row( // <-- Rowで囲む
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: localizations.friendNameLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.friendNameRequired;
                        }
                        return null;
                      },
                    ),
                  ),
                  _buildOcrButtons(_nameController, localizations), // OCRボタンを追加
                ],
              ),
              const SizedBox(height: 16.0),

              // ニックネーム（オプション）
              Row( // <-- Rowで囲む
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nicknameController,
                      decoration: InputDecoration(
                        labelText: localizations.friendNicknameLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  _buildOcrButtons(_nicknameController, localizations), // OCRボタンを追加
                ],
              ),
              const SizedBox(height: 16.0),

              // キャンプファイアID（オプション）
              Row( // <-- Rowで囲む
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _campfireIdController,
                      decoration: InputDecoration(
                        labelText: localizations.friendCampfireIdLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  _buildOcrButtons(_campfireIdController, localizations), // OCRボタンを追加
                ],
              ),
              const SizedBox(height: 16.0),

              // キャンプファイア名（オプション）
              Row( // <-- Rowで囲む
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _campfireNameController,
                      decoration: InputDecoration(
                        labelText: localizations.friendCampfireNameLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  _buildOcrButtons(_campfireNameController, localizations), // OCRボタンを追加
                ],
              ),
              const SizedBox(height: 16.0),

              // Xアカウント（オプション）
              Row( // <-- Rowで囲む
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _xAccountController,
                      decoration: InputDecoration(
                        labelText: localizations.friendXAccountLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  _buildOcrButtons(_xAccountController, localizations), // OCRボタンを追加
                ],
              ),
              const SizedBox(height: 16.0),

              // LINE名（オプション）
              Row( // <-- Rowで囲む
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lineNameController,
                      decoration: InputDecoration(
                        labelText: localizations.friendLineNameLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  _buildOcrButtons(_lineNameController, localizations), // OCRボタンを追加
                ],
              ),
              const SizedBox(height: 16.0),

              // trade日時
              Row( // <-- Rowで囲む
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tradeDateTimeController,
                      readOnly: true, // ユーザーが直接入力できないようにする
                      decoration: InputDecoration(
                        labelText: localizations.tradeDateTimeLabel,
                        suffixIcon: Icon(Icons.calendar_today), // カレンダーアイコンを追加
                      ),
                      onTap: () {
                        // タップ時にPickerダイアログを表示
                        _selectDateTime(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // trade場所
              Row( // <-- Rowで囲む
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tradePlaceController,
                      decoration: InputDecoration(
                        labelText: localizations.tradePlaceLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  // _buildOcrButtons(_tradePlaceController, localizations), // OCRボタンを追加
                ],
              ),
              const SizedBox(height: 16.0),

              // lucky (SwitchListTile)
              SwitchListTile(
                title: Text(localizations.friendIsLuckyLabel),
                value: _isLucky,
                onChanged: (bool value) {
                  setState(() {
                    _isLucky = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),

              // contacted (SwitchListTile)
              SwitchListTile(
                title: Text(localizations.friendContactedLabel),
                value: _isContacted,
                onChanged: (bool value) {
                  setState(() {
                    _isContacted = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),

              // canContact (SwitchListTile)
              SwitchListTile(
                title: Text(localizations.friendCanContactLabel),
                value: _canContact,
                onChanged: (bool value) {
                  setState(() {
                    _canContact = value;
                  });
                },
              ),
              const SizedBox(height: 24.0),

              ElevatedButton(
                onPressed: _saveFriend, // 保存ボタンを押したときに_saveFriendを実行
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  localizations.saveButtonText,
                  style: const TextStyle(fontSize: 18.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
