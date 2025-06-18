// lib/screens/friends_list_page.dart

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/friend.dart'; // Friendモデルクラスをインポート
import 'package:poke_go_friends/screens/add_friend_page.dart'; // AddFriendPageへ遷移するため
import 'package:url_launcher/url_launcher.dart'; // URLを開くためのパッケージ

// luckyによるフィルタリングの状態を定義するenum
enum LuckyFilter {
  all, // 全ての友達
  luckyOnly, // luckyが1の友達のみ
  notLucky // luckyが0の友達のみ
}
// FriendsListPageは、データベースから友達のリストを表示するためのステートフルウィジェットです。
class FriendsListPage extends StatefulWidget {
  const FriendsListPage({super.key});

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  // 友達の全リスト（フィルタリング前）
  List<Friend> _friends = [];

  // フィルタリング後の表示用リスト
  List<Friend> _filteredFriends = [];

  // 検索バーのテキスト入力用コントローラー
  final TextEditingController _searchController = TextEditingController();

  // 選択されているluckyフィルタ
  LuckyFilter _selectedLuckyFilter = LuckyFilter.all;

  // データがロード中かどうかを示すフラグ
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends(); // ウィジェットが初期化されたときに友達のリストをロード

    // 検索テキストの変更をリッスンし、フィルタリングを再実行
    _searchController.addListener(() {
      _filterFriends();
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // コントローラーを破棄
    super.dispose();
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
      _filterFriends(); // データロード後、初期フィルタリングを実行
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
          SnackBar(content: Text(
              AppLocalizations.of(context).friendDeletedMessage(name))),
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

  // URLをブラウザで開くためのヘルパーメソッド
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $urlString')),
      );
    }
  }

  // 友達リストをフィルタリングするメソッド
  void _filterFriends() {
    final String searchText = _searchController.text.toLowerCase();
    setState(() {
      _filteredFriends = _friends.where((friend) {
        // 名前によるフィルタリング
        final bool nameMatches = searchText.isEmpty ||
            friend.name.toLowerCase().contains(searchText);

        // luckyフィルタによるフィルタリング
        final bool luckyMatches;
        if (_selectedLuckyFilter == LuckyFilter.luckyOnly) {
          luckyMatches = friend.lucky == 1;
        } else if (_selectedLuckyFilter == LuckyFilter.notLucky) {
          luckyMatches = friend.lucky == 0;
        } else {
          luckyMatches = true; // LuckyFilter.all の場合
        }

        return nameMatches && luckyMatches;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.friendsListPageTitle), // ページのタイトル
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator()) // ロード中はプログレスインジケータを表示
          : _filteredFriends.isEmpty
          ? Center(
          child: Text(localizations.noMatchingFriendsMessage)) // 友達がいない場合のメッセージ
          : ListView.builder(
        itemCount: _filteredFriends.length, // フィルタリング後のリストの件数を使用
        itemBuilder: (context, index) {
          final friend = _filteredFriends[index];
          return Card( // 各友達をカードで表示
            margin: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 8.0),
            elevation: 4.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Row(
                mainAxisSize: MainAxisSize.min, // Rowの幅を子ウィジェットに合わせて最小限にする
                children: [
                  Flexible( // Textが長くなってもIconを押し出さないようにFlexibleで囲む
                    child: Text(
                      friend.name,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        // luckyが1ならオレンジ色、そうでなければデフォルトの色
                        color: friend.lucky == 1 ? Colors.orange : null,
                      ),
                      overflow: TextOverflow.ellipsis, // テキストが長すぎる場合は省略記号を表示
                    ),
                  ),
                  const SizedBox(width: 8.0), // 名前とアイコンの間にスペースを追加
                  // contactedアイコン
                  if (friend.contacted == 1)
                    const Padding(
                      padding: EdgeInsets.only(right: 4.0),
                      child: Icon(Icons.check_circle, color: Colors.green,
                          size: 18),
                    ),
                  // canContactアイコン
                  if (friend.canContact == 1)
                    const Icon(
                        Icons.phone_in_talk, color: Colors.blue, size: 18),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (friend.campfireName != null &&
                      friend.campfireName!.isNotEmpty)
                    Text(
                      '${localizations.friendCampfireNameLabel}: ${friend
                          .campfireName!}',
                      style: TextStyle(
                        // contactedが1なら青、そうでなければデフォルトの色
                        color: friend.contacted == 1
                            ? Colors.lightGreen
                            : null,
                      ),
                    ),

                  if (friend.xAccount != null && friend.xAccount!.isNotEmpty)
                    GestureDetector( // GestureDetectorでタップ検出
                      onTap: () {
                        // XのアカウントページURLを構築して開く
                        _launchUrl('https://x.com/${friend.xAccount!}');
                      },
                      child: Text(
                        '${localizations.friendXAccountLabel}: ${friend
                            .xAccount!}',
                        style: const TextStyle(
                          color: Colors.blue, // リンクのように青色にする
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () =>
                    _deleteFriend(friend.id!, friend.name), // 削除ボタン
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
      // 検索バーを最下部に固定
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme
              .of(context)
              .cardColor, // カードの背景色に合わせる
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, -3), // 上部に影をつける
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 高さを内容に合わせる
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: localizations.searchByNameLabel, // 検索バーのラベル
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                prefixIcon: const Icon(Icons.search), // 検索アイコン
              ),
            ),
            const SizedBox(height: 12.0),
            Text(localizations.filterByLuckyLabel, style: Theme
                .of(context)
                .textTheme
                .titleSmall), // ラジオボタンのタイトル
            Row(
              children: [
                Expanded(
                  child: RadioListTile<LuckyFilter>(
                    title: Text(localizations.luckyFilterAll),
                    value: LuckyFilter.all,
                    groupValue: _selectedLuckyFilter,
                    onChanged: (LuckyFilter? value) {
                      setState(() {
                        _selectedLuckyFilter = value!;
                        _filterFriends(); // ラジオボタン変更でフィルタリングを再実行
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<LuckyFilter>(
                    title: Text(localizations.luckyFilterLuckyOnly),
                    value: LuckyFilter.luckyOnly,
                    groupValue: _selectedLuckyFilter,
                    onChanged: (LuckyFilter? value) {
                      setState(() {
                        _selectedLuckyFilter = value!;
                        _filterFriends();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<LuckyFilter>(
                    title: Text(localizations.luckyFilterNotLucky),
                    value: LuckyFilter.notLucky,
                    groupValue: _selectedLuckyFilter,
                    onChanged: (LuckyFilter? value) {
                      setState(() {
                        _selectedLuckyFilter = value!;
                        _filterFriends();
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}