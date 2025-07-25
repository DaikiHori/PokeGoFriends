// lib/screens/friends_list_page.dart

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/friend.dart'; // Friendモデルクラスをインポート
import '../widgets/filter_toggle_button.dart';
import 'package:poke_go_friends/screens/add_friend_page.dart'; // AddFriendPageへ遷移するため
import 'package:url_launcher/url_launcher.dart'; // URLを開くためのパッケージ
import 'package:file_picker/file_picker.dart'; // ファイルピッカー用
import 'dart:io'; // ファイル操作用 (kIsWebの代替)
import 'dart:convert'; // CSVエンコード/デコード用
import 'dart:typed_data'; // バイトデータ操作用
import 'package:csv/csv.dart'; // CSVライブラリ用
import 'package:flutter/foundation.dart' show kIsWeb; // Webプラットフォーム判定用
import 'package:intl/intl.dart'; // 日付フォーマット用 (エクスポートファイル名用)

// ソートの状態を定義するenum
enum SortOrder {
  nameAsc,      // 名前 昇順
  nameDesc,     // 名前 降順
  nicknameAsc,  // ニックネーム 昇順
  nicknameDesc, // ニックネーム 降順
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
  // 各フィルターの状態を管理するインデックス (0:All, 1:Only/Yes, 2:Not/No)
  int _luckyFilterStateIndex = 0;
  int _contactedFilterStateIndex = 0;
  int _canContactFilterStateIndex = 0;
  // 現在選択されているソート順 (デフォルトは名前昇順)
  SortOrder _currentSortOrder = SortOrder.nameAsc;
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
        // 名前とニックネームによるフィルタリング
        final bool nameOrNicknameMatches = searchText.isEmpty ||
            friend.name.toLowerCase().contains(searchText) ||
            (friend.nickname != null && friend.nickname!.toLowerCase().contains(searchText));

        // luckyフィルタによるフィルタリング
        final bool luckyMatches;
        if (_luckyFilterStateIndex == 1) {
          luckyMatches = friend.lucky == 1;
        } else if (_luckyFilterStateIndex == 2) {
          luckyMatches = friend.lucky == 0;
        } else {
          luckyMatches = true; // LuckyFilter.all の場合
        }

        // contactedフィルタリングロジック
        final bool contactedMatches;
        if (_contactedFilterStateIndex == 1) { // 1: Contacted
          contactedMatches = friend.contacted == 1;
        } else if (_contactedFilterStateIndex == 2) { // 2: Not Contacted
          contactedMatches = friend.contacted == 0;
        } else { // 0: All
          contactedMatches = true;
        }

        // canContactフィルタリングロジック
        final bool canContactMatches;
        if (_canContactFilterStateIndex == 1) { // 1: Can Contact
          canContactMatches = friend.canContact == 1;
        } else if (_canContactFilterStateIndex == 2) { // 2: Cannot Contact
          canContactMatches = friend.canContact == 0;
        } else { // 0: All
          canContactMatches = true;
        }
        return nameOrNicknameMatches && luckyMatches && contactedMatches && canContactMatches;
      }).toList();
      // フィルタリング後にソートを実行
      _filteredFriends.sort((a, b) {
        switch (_currentSortOrder) {
          case SortOrder.nameAsc:
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          case SortOrder.nameDesc:
            return b.name.toLowerCase().compareTo(a.name.toLowerCase());
          case SortOrder.nicknameAsc:
          // nullを考慮したソート: nullは空文字列として扱う
            final String nickA = a.nickname ?? '';
            final String nickB = b.nickname ?? '';
            return nickA.compareTo(nickB);
          case SortOrder.nicknameDesc:
          // nullを考慮したソート: nullは空文字列として扱う
            final String nickA = a.nickname ?? '';
            final String nickB = b.nickname ?? '';
            return nickB.compareTo(nickA);
        }
      });
    });
  }

  // ソート順を切り替えるメソッド
  void _toggleSortOrder() {
    setState(() {
      switch (_currentSortOrder) {
        case SortOrder.nameAsc:
          _currentSortOrder = SortOrder.nameDesc;
          break;
        case SortOrder.nameDesc:
          _currentSortOrder = SortOrder.nicknameAsc;
          break;
        case SortOrder.nicknameAsc:
          _currentSortOrder = SortOrder.nicknameDesc;
          break;
        case SortOrder.nicknameDesc:
          _currentSortOrder = SortOrder.nameAsc; // 最初の状態に戻る
          break;
      }
      _filterFriends(); // ソート順変更後、再フィルタリング（ソート）
    });
  }

  // 現在のソート順に応じたアイコンの色を取得 (新規追加)
  Color _getSortIconColor() {
    switch (_currentSortOrder) {
      case SortOrder.nameAsc:
        return Colors.blue; // 名前昇順は青
      case SortOrder.nameDesc:
        return Colors.yellow; // 名前降順は黄色
      case SortOrder.nicknameAsc:
        return Colors.lightBlue; // ニックネーム昇順は薄い青
      case SortOrder.nicknameDesc:
        return Colors.yellow.shade200; // ニックネーム降順は薄い黄色
    }
  }
  // 現在のソート順に応じたアイコンを取得
  IconData _getSortIcon() {
    switch (_currentSortOrder) {
      case SortOrder.nameAsc:
        return Icons.sort_by_alpha; // 名前昇順
      case SortOrder.nameDesc:
        return Icons.sort_by_alpha; // 名前降順 (アイコンは同じだがツールチップで区別)
      case SortOrder.nicknameAsc:
        return Icons.text_fields; // ニックネーム昇順 (別のアイコンで区別)
      case SortOrder.nicknameDesc:
        return Icons.text_fields; // ニックネーム降順 (アイコンは同じだがツールチップで区別)
    }
  }
  // 現在のソート順に応じたツールチップを取得
  String _getSortTooltip(AppLocalizations localizations) {
    switch (_currentSortOrder) {
      case SortOrder.nameAsc:
        return localizations.sortNameAscTooltip;
      case SortOrder.nameDesc:
        return localizations.sortNameDescTooltip;
      case SortOrder.nicknameAsc:
        return localizations.sortNicknameAscTooltip;
      case SortOrder.nicknameDesc:
        return localizations.sortNicknameDescTooltip;
    }
  }

  // エクスポート機能
  String _generateCsvContent(List<Friend> friends) {
    List<List<dynamic>> csvData = [];
    // ヘッダー行
    csvData.add([
      'id', 'name', 'lucky', 'nickname', 'campfireId', 'campfireName',
      'contacted', 'canContact', 'xAccount', 'lineName'
    ]);
    // データ行
    for (var friend in friends) {
      csvData.add([
        friend.id,
        friend.name,
        friend.lucky,
        friend.nickname ?? '', // nullの場合は空文字列
        friend.campfireId ?? '',
        friend.campfireName ?? '',
        friend.contacted,
        friend.canContact,
        friend.xAccount ?? '',
        friend.lineName ?? '',
      ]);
    }
    const converter = ListToCsvConverter();
    return converter.convert(csvData);
  }

  Future<void> _exportData() async {
    final localizations = AppLocalizations.of(context)!;
    try {
      final allFriends = await DbHelper.instance.getFriends();
      String csvContent = _generateCsvContent(allFriends);
      final List<int> bytes = utf8.encode(csvContent);
      final Uint8List data = Uint8List.fromList(bytes);

      String? outputPath = await FilePicker.platform.saveFile(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        dialogTitle: localizations.exportSelectLocationTitle,
        fileName: 'friends_data_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv',
        bytes: data, // Webではbytesを指定
      );

      if (outputPath != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.exportSuccessMessage(outputPath))),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.exportCancelledMessage)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.exportFailedMessage(e.toString()))),
      );
    }
  }

  // インポート機能
  Future<void> _importData() async {
    final localizations = AppLocalizations.of(context)!;
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        dialogTitle: localizations.importSelectFileTitle,
      );

      if (result != null && result.files.single.name.isNotEmpty) {
        String csvContent;
        if (kIsWeb) {
          if (result.files.single.bytes == null) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizations.importFailedMessage('Failed to read file bytes on web.'))),
            );
            return;
          }
          csvContent = utf8.decode(result.files.single.bytes!);
        } else {
          if (result.files.single.path == null) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizations.importFailedMessage('Failed to get file path on native platform.'))),
            );
            return;
          }
          final File file = File(result.files.single.path!);
          csvContent = await file.readAsString();
        }

        final bool? confirmImport = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(localizations.importConfirmTitle),
              content: Text(localizations.importConfirmMessage),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(localizations.cancelButtonText),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(localizations.importConfirmButtonText),
                ),
              ],
            );
          },
        );

        if (confirmImport != true) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.importCancelledMessage)),
          );
          return;
        }

        await DbHelper.instance.clearAllTables();

        csvContent = csvContent.replaceAll('\r\n', '\n'); // 改行コードを正規化
        final List<List<dynamic>> rows = const CsvToListConverter(eol: '\n').convert(csvContent);

        if (rows.isEmpty || rows.first.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.csvImportFailedEmptyOrUnreadable)),
          );
          return;
        }

        // ヘッダー行をスキップし、データ行のみを処理
        final List<String> headers = rows.first.map((e) => e.toString()).toList();
        int importedFriends = 0;

        for (int i = 1; i < rows.length; i++) { // ヘッダー行の次から開始
          final row = rows[i];
          if (row.isEmpty || (row.length == 1 && row[0].toString().trim().isEmpty)) {
            continue; // 空行はスキップ
          }

          final Map<String, dynamic> rowMap = {};
          for (int j = 0; j < headers.length; j++) {
            if (j < row.length) {
              rowMap[headers[j]] = row[j];
            } else {
              rowMap[headers[j]] = null;
            }
          }

          try {
            // Friendデータのインポート
            final friendName = rowMap['name']?.toString() ?? '';
            if (friendName.isEmpty) {
              continue;
            }

            final newFriend = Friend(
              name: friendName,
              lucky: int.tryParse(rowMap['lucky'].toString()) ?? 0,
              nickname: rowMap['nickname']?.toString().isEmpty == true ? null : rowMap['nickname'].toString(),
              campfireId: rowMap['campfireId']?.toString().isEmpty == true ? null : rowMap['campfireId'].toString(),
              campfireName: rowMap['campfireName']?.toString().isEmpty == true ? null : rowMap['campfireName'].toString(),
              contacted: int.tryParse(rowMap['contacted'].toString()) ?? 0,
              canContact: int.tryParse(rowMap['canContact'].toString()) ?? 0,
              xAccount: rowMap['xAccount']?.toString().isEmpty == true ? null : rowMap['xAccount'].toString(),
              lineName: rowMap['lineName']?.toString().isEmpty == true ? null : rowMap['lineName'].toString(),
            );
            await DbHelper.instance.insertFriend(newFriend);
            importedFriends++;

          } catch (e) {
            // エラーが発生しても処理を続行するために、ここではスキップされた行のカウントはしない
          }
        }

        final String displayPath = kIsWeb ? result.files.single.name : (result.files.single.path ?? 'selected file');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizations.friendImportSummaryMessage(
                displayPath,
                importedFriends
              ),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
        await _loadFriends();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.importCancelledMessage)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.importFailedMessage(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.friendsListPageTitle), // ページのタイトル
      ),
      endDrawer: Drawer( // ドロワー
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                localizations.menuTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),

            const Divider(), // 区切り線
            ListTile( // <-- データエクスポート
              leading: const Icon(Icons.upload_file),
              title: Text(localizations.exportDataMenuText),
              onTap: () {
                Navigator.pop(context); // ドロワーを閉じる
                _exportData();
              },
            ),
            ListTile( // <-- データインポート
              leading: const Icon(Icons.file_download),
              title: Text(localizations.importDataMenuText),
              onTap: () {
                Navigator.pop(context); // ドロワーを閉じる
                _importData();
              },
            ),
          ],
        ),
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
                  if (friend.nickname != null && friend.nickname!.isNotEmpty)
                    Text('${localizations.friendNicknameLabel}: ${friend.nickname!}'),
                  if (friend.campfireName != null && friend.campfireName!.isNotEmpty)
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: localizations.searchByNameLabel, // 検索バーのラベル
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                      prefixIcon: const Icon(Icons.search), // 検索アイコン
                    ),
                  ),
                ),
                const SizedBox(width: 8.0), // テキストフィールドとアイコンの間のスペース
                IconButton( // <-- ソートアイコン
                  icon: Icon(_getSortIcon()),
                  color: _getSortIconColor(),
                  tooltip: _getSortTooltip(localizations),
                  onPressed: _toggleSortOrder,
                ),
              ],
            ),
            const SizedBox(height: 14.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, // ボタンを均等に配置
              children: [
                // Luckyフィルター用のトグルボタン
                FilterToggleButton(
                  // アイコンリストを渡す
                  icons: const [
                    Icons.star, // All
                    Icons.star,        // Lucky Only
                    Icons.star_border, // Not Lucky
                  ],
                  backgroundColors: const [
                    Colors.grey,
                    Colors.orange,
                    Colors.blueGrey,
                  ],
                  iconColors: const [
                    Colors.black,
                    Colors.white,
                    Colors.white,
                  ],
                  initialIndex: _luckyFilterStateIndex,
                  onChanged: (newIndex) {
                    setState(() {
                      _luckyFilterStateIndex = newIndex;
                      _filterFriends();
                    });
                  },
                ),
                // Contactedフィルター用のトグルボタン
                FilterToggleButton(
                  // アイコンリストを渡す
                  icons: const [
                    Icons.check, // All
                    Icons.check,       // Contacted
                    Icons.close,       // Not Contacted
                  ],
                  backgroundColors: const [
                    Colors.grey,
                    Colors.green,
                    Colors.red,
                  ],
                  iconColors: const [
                    Colors.black,
                    Colors.white,
                    Colors.white,
                  ],
                  initialIndex: _contactedFilterStateIndex,
                  onChanged: (newIndex) {
                    setState(() {
                      _contactedFilterStateIndex = newIndex;
                      _filterFriends();
                    });
                  },
                ),
                // CanContactフィルター用のトグルボタン
                FilterToggleButton(
                  // アイコンリストを渡す
                  icons: const [
                    Icons.phone_in_talk,   // All
                    Icons.phone_in_talk, // Can Contact
                    Icons.phone_disabled, // Cannot Contact
                  ],
                  backgroundColors: const [
                    Colors.grey,
                    Colors.blue,
                    Colors.deepOrange,
                  ],
                  iconColors: const [
                    Colors.black,
                    Colors.white,
                    Colors.white,
                  ],
                  initialIndex: _canContactFilterStateIndex,
                  onChanged: (newIndex) {
                    setState(() {
                      _canContactFilterStateIndex = newIndex;
                      _filterFriends();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}