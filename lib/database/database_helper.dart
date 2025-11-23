import 'package:sqflite/sqflite.dart'; // SQLiteデータベース操作のためのパッケージ
import 'package:path/path.dart';      // パス操作のためのパッケージ
import 'package:path_provider/path_provider.dart'; // アプリケーションのドキュメントディレクトリを取得するためのパッケージ
import '../models/friend.dart';      // 前に定義したFriendモデルクラス

// データベースのバージョン番号。スキーマ変更時にインクリメントします。
const int _databaseVersion = 2;

// データベース名
const String _databaseName = 'poke_go_friends_database.db';

// テーブル名
const String _tableName = 'friends';

// DbHelperクラスは、SQLiteデータベースとのやり取りを管理します。
class DbHelper {
  // シングルトンインスタンスを保持するためのプライベート変数
  static Database? _database;
  static final DbHelper instance = DbHelper._privateConstructor();

  // プライベートコンストラクタでシングルトンを強制します。
  DbHelper._privateConstructor();

  // データベースインスタンスへのゲッター。
  // 必要に応じてデータベースを初期化します。
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // データベースを初期化し、テーブルを作成します。
  Future<Database> _initDatabase() async {
    // アプリケーションのドキュメントディレクトリのパスを取得します。
    final documentsDirectory = await getApplicationDocumentsDirectory();
    // データベースファイルのフルパスを構築します。
    final path = join(documentsDirectory.path, _databaseName);

    // データベースを開きます。存在しない場合は作成し、onCreateが呼び出されます。
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // バージョンアップグレード時の処理
    );
  }

  // データベースが初めて作成されるときにテーブルを作成します。
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lucky INTEGER NOT NULL DEFAULT 0,
        name TEXT NOT NULL,
        nickname TEXT,
        campfireId TEXT,
        campfireName TEXT,
        contacted INTEGER NOT NULL DEFAULT 0,
        canContact INTEGER NOT NULL DEFAULT 0,
        xAccount TEXT,
        lineName TEXT,
        tradeDateTime TEXT,
        tradePlace TEXT
      )
    ''');
    // SQLITEにおけるTEXTはDartのString、INTEGERはDartのintに対応します。
    // AUTOINCREMENT: IDが自動的に増えるように設定
    // NOT NULL: このカラムはNULLを許容しない
    // DEFAULT 0: デフォルト値を0に設定
  }

  // データベースのバージョンが上がったときの処理 (マイグレーションなど)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // バージョンが1から2に上がった場合
    if (oldVersion < 2) {
      // 新しいカラムを追加する場合
      await db.execute("ALTER TABLE $_tableName ADD COLUMN tradeDateTime TEXT");
      await db.execute("ALTER TABLE $_tableName ADD COLUMN tradePlace TEXT");
    }
  }

  // 新しい友達をデータベースに挿入します。
  // FriendオブジェクトをMapに変換して挿入します。
  Future<int> insertFriend(Friend friend) async {
    final db = await instance.database;
    // Map形式のデータをfriendsテーブルに挿入し、新しく挿入された行のIDを返します。
    return await db.insert(
      _tableName,
      friend.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // 競合時の動作: 既存の行を置き換える
    );
  }

  // すべての友達のリストをデータベースから取得します。
  Future<List<Friend>> getFriends() async {
    final db = await instance.database;
    // friendsテーブルからすべての行をMapのリストとしてクエリします。
    final List<Map<String, dynamic>> maps = await db.query(_tableName);

    // MapのリストをFriendオブジェクトのリストに変換して返します。
    return List.generate(maps.length, (i) {
      return Friend.fromMap(maps[i]);
    });
  }

  // 指定されたIDの友達をデータベースから取得します。
  Future<Friend?> getFriendById(int id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?', // WHERE句でIDを指定
      whereArgs: [id], // プレースホルダーに渡す引数
    );
    if (maps.isNotEmpty) {
      return Friend.fromMap(maps.first);
    }
    return null; // 見つからなかった場合はnullを返す
  }

  // 既存の友達の情報をデータベースで更新します。
  // friend.idを使用して更新する行を特定します。
  Future<int> updateFriend(Friend friend) async {
    final db = await instance.database;
    // Map形式のデータを更新し、更新された行数を返します。
    return await db.update(
      _tableName,
      friend.toMap(),
      where: 'id = ?', // 更新する行の条件
      whereArgs: [friend.id], // 条件に渡す引数
    );
  }

  // 指定されたIDの友達をデータベースから削除します。
  Future<int> deleteFriend(int id) async {
    final db = await instance.database;
    // 指定されたIDの行を削除し、削除された行数を返します。
    return await db.delete(
      _tableName,
      where: 'id = ?', // 削除する行の条件
      whereArgs: [id], // 条件に渡す引数
    );
  }

  // データベースを閉じます。アプリケーション終了時などに呼び出すことができます。
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null; // データベースインスタンスをクリア
  }

  // 全てのテーブルのデータをクリアするメソッド (CSVインポート前に使用)
  Future<void> clearAllTables() async {
    final db = await instance.database;
    await db.delete('friends');
  }

  // 取引日時（tradeDateTime）がNULLまたは空文字列のフレンドのみを取得します。
  Future<List<Friend>> getFriendsWithTradeDate() async {
    final db = await instance.database;

    // tradeDateTime が NULL または 空文字列 ('') のレコードを取得するクエリ
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName, // 'friends' テーブル
      where: 'tradeDateTime IS NOT NULL',
    );

    // MapのリストをFriendオブジェクトのリストに変換して返します。
    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (i) {
      // Friend.fromMap() は、tradeDateTimeがNULLや空文字列の場合は
      // DartのDateTime?としてnullを返すように設計されていると想定します。
      return Friend.fromMap(maps[i]);
    });
  }
}
