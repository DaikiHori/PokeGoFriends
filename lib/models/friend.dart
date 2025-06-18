class Friend {
  final int? id;

  final String name;
  final int lucky;
  final String? nickname;
  final String? campfireId;
  final String? campfireName;
  final int contacted;
  final int canContact;
  final String? xAccount;
  final String? lineName;

  // idはオプションで、データベースが自動生成する際にnullを渡します。
  Friend({
    this.id,
    required this.lucky,
    required this.name,
    this.nickname,
    this.campfireId,
    this.campfireName,
    required this.contacted,
    required this.canContact,
    this.xAccount,
    this.lineName,
  });

  // オブジェクトの現在の値を元に、新しいFriendオブジェクトを生成します。
  // 例えば、既存のFriendオブジェクトの一部フィールドだけを更新したい場合などに便利です。
  Friend copyWith({
    int? id,
    int? lucky,
    String? name,
    String? nickname,
    String? campfireId,
    String? campfireName,
    int? contacted,
    int? canContact,
    String? xAccount,
    String? lineName,
  }) {
    return Friend(
      id: id ?? this.id,
      lucky: lucky ?? this.lucky,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      campfireId: campfireId ?? this.campfireId,
      campfireName: campfireName ?? this.campfireName,
      contacted: contacted ?? this.contacted,
      canContact: canContact ?? this.canContact,
      xAccount: xAccount ?? this.xAccount,
      lineName: lineName ?? this.lineName,
    );
  }

  // Friendオブジェクトをデータベースに保存可能なMap形式に変換します。
  // SQLiteデータベースに挿入または更新する際に使用されます。
  Map<String, dynamic> toMap() {
    return {
      'id': id, // IDがnullの場合、DBが自動生成する
      'lucky': lucky,
      'name': name,
      'nickname': nickname ,
      'campfireId': campfireId,
      'campfireName': campfireName,
      'contacted': contacted,
      'canContact': canContact,
      'xAccount': xAccount,
      'lineName': lineName,
    };
  }

  // データベースから取得したMap形式のデータをFriendオブジェクトに変換します。
  // データベースからデータを読み込む際に使用されます。
  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      id: map['id'] as int?, // IDはnullの可能性も考慮
      lucky: map['lucky'] as int,
      name: map['name'] as String,
      nickname: map['nickname'] as String?,
      campfireId: map['campfireId'] as String?,
      campfireName: map['campfireName'] as String?,
      contacted: map['contacted'] as int,
      canContact: map['canContact'] as int,
      xAccount: map['xAccount'] as String?,
      lineName: map['lineName'] as String?,
    );
  }

  // デバッグ時にオブジェクトの内容を確認しやすくするためのtoStringメソッド。
  @override
  String toString() {
    return 'Friend{id: $id, lucky: $lucky name: $name, nickname: $nickname, campfireId: $campfireId, campfireId: $campfireId, contacted: $contacted, canContact: $canContact, xAccount: $xAccount, lineName: $lineName,}';
  }
}
