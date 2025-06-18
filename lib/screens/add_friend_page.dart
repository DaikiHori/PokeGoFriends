// lib/screens/add_friend_page.dart

import 'package:flutter/material.dart';
import '../models/friend.dart'; // Friendモデルクラスをインポート
import '../database/database_helper.dart';   // DbHelperクラスをインポート
import 'package:poke_go_friends/l10n/app_localizations.dart'; // 多言語対応のためのインポート

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

  // booleanフィールド: lucky
  bool _isLucky = false;
  // booleanフィールド: contacted
  bool _isContacted = false;
  // booleanフィールド: canContact
  bool _canContact = false;

  // 編集モードの場合、既存のFriendオブジェクトを保持
  Friend? _currentFriend;

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

      _isLucky = _currentFriend!.lucky == 1;
      _isContacted = _currentFriend!.contacted == 1;
      _canContact = _currentFriend!.canContact == 1;
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
              TextFormField(
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
              const SizedBox(height: 16.0),

              // ニックネーム（オプション）
              TextFormField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: localizations.friendNicknameLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // キャンプファイアID（オプション）
              TextFormField(
                controller: _campfireIdController,
                decoration: InputDecoration(
                  labelText: localizations.friendCampfireIdLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // キャンプファイア名（オプション）
              TextFormField(
                controller: _campfireNameController,
                decoration: InputDecoration(
                  labelText: localizations.friendCampfireNameLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Xアカウント（オプション）
              TextFormField(
                controller: _xAccountController,
                decoration: InputDecoration(
                  labelText: localizations.friendXAccountLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // LINE名（オプション）
              TextFormField(
                controller: _lineNameController,
                decoration: InputDecoration(
                  labelText: localizations.friendLineNameLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
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
