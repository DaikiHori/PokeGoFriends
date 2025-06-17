// lib/screens/friends_list_page.dart

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/friend.dart';      // Friendモデルクラスをインポート
import 'package:poke_go_friends/screens/add_friend_page.dart'; // AddFriendPageへ遷移するため

// FriendsListPageは、データベースから友達のリストを表示するためのステートフルウィジェットです。
class FriendsListPage extends StatefulWidget {
  const FriendsListPage({super.key});

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  // 友達のリストを保持する変数
  List<Friend> _friends = [];
  // データがロード中かどうかを示すフラグ
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends(); // ウィジェットが初期化されたときに友達のリストをロード
  }

  // データベースから友達のリストをロードする非同期メソッド
  Future<void> _loadFriends() async {
    setState(() {
      _isLoading = true; // ロード開始
    });
    try {
      // DbHelperからすべての友達を取得
      final loadedFriends = await DbHelper.instance.getFriends();
      setState(() {
        _friends = loadedFriends; // 取得したリストを更新
        _isLoading = false; // ロード完了
      });
    } catch (e) {
      // エラー処理
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load friends: $e')),
      );
      setState(() {
        _isLoading = false; // ロード完了 (エラー時も)
      });
    }
  }

  // 友達を削除する非同期メソッド
  Future<void> _deleteFriend(int id, String name) async {
    // 削除確認のダイアログ表示
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final localizations = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(localizations.deleteConfirmTitle),
          content: Text(localizations.deleteConfirmMessage(name)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // キャンセル
              child: Text(localizations.cancelButtonText),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // 削除
              child: Text(localizations.deleteButtonText),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await DbHelper.instance.deleteFriend(id);
        // 削除成功時のフィードバック
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).friendDeletedMessage(name))),
        );
        _loadFriends(); // リストを再ロードしてUIを更新
      } catch (e) {
        // 削除失敗時のエラーフィードバック
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete friend: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.friendsListPageTitle), // ページのタイトル
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // ロード中はプログレスインジケータを表示
          : _friends.isEmpty
          ? Center(child: Text(localizations.noFriendsMessage)) // 友達がいない場合のメッセージ
          : ListView.builder(
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friend = _friends[index];
          return Card( // 各友達をカードで表示
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            elevation: 4.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(
                friend.name,
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (friend.nickname != null && friend.nickname!.isNotEmpty)
                    Text('${localizations.friendNicknameLabel}: ${friend.nickname!}'),
                  // 以下、他の連絡先情報などを表示
                  if (friend.campfireName != null && friend.campfireName!.isNotEmpty)
                    Text('${localizations.friendCampfireNameLabel}: ${friend.campfireName!}'),
                  if (friend.xAccount != null && friend.xAccount!.isNotEmpty)
                    Text('${localizations.friendXAccountLabel}: ${friend.xAccount!}'),
                  if (friend.lineName != null && friend.lineName!.isNotEmpty)
                    Text('${localizations.friendLineNameLabel}: ${friend.lineName!}'),
                  Row(
                    children: [
                      if (friend.lucky == 1)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(Icons.star, color: Colors.amber, size: 20),
                        ),
                      if (friend.contacted == 1)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(Icons.check_circle, color: Colors.green, size: 20),
                        ),
                      if (friend.canContact == 1)
                        Icon(Icons.phone_in_talk, color: Colors.blue, size: 20),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteFriend(friend.id!, friend.name), // 削除ボタン
              ),
              onTap: () async {
                // 友達の詳細/編集ページへ遷移 (Friendオブジェクトを渡す)
                final bool? result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddFriendPage(friendToEdit: friend),
                  ),
                );
                // 編集ページから戻ってきたときに、データが更新された場合はリストを再ロード
                if (result == true) {
                  _loadFriends();
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // AddFriendPageに遷移し、戻ってきたときにリストをリフレッシュ
          final bool? result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFriendPage()),
          );
          if (result == true) {
            _loadFriends(); // 友達が追加されたらリストを再ロード
          }
        },
        tooltip: localizations.addFriendButtonTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }
}
