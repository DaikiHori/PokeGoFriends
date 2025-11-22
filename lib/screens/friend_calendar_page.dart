import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../database/database_helper.dart'; // データベースヘルパーのインポート
import '../models/friend.dart'; // Friend モデルのインポート
import '../event/event.dart'; // Event モデルのインポート
import 'package:intl/intl.dart'; // 日付整形用
import 'package:poke_go_friends/l10n/app_localizations.dart';
class FriendCalendarScreen extends StatefulWidget {
  const FriendCalendarScreen({super.key});

  @override
  State<FriendCalendarScreen> createState() => _FriendCalendarScreenState();
}

class _FriendCalendarScreenState extends State<FriendCalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // 💡 FutureBuilder 用の Future 変数
  late final Future<Map<DateTime, List<Event>>> _eventsFuture;

  List<Event> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    // 💡 initState でデータロードを開始し、Future を保持
    _eventsFuture = _loadAllEventsFromDatabase();
    // 初回は空リストで初期化しておき、データロード後に _onDaySelected が呼ばれるようにする
  }

  // MARK: - データのロードと整形

  /// データベースからフレンドデータを取得し、カレンダー用のマップに整形する
  Future<Map<DateTime, List<Event>>> _loadAllEventsFromDatabase() async {
    // データベースから全フレンドデータを取得
    final List<Friend> friends = await DbHelper.instance.getFriendsWithTradeDate();
    final Map<DateTime, List<Event>> organizedEvents = {};

    for (var friend in friends) {
        final DateTime dateWithTime = friend.tradeDateTime!;

        // 1. Mapのキーとして使用するため、時間情報をクリア（UTC推奨）
        final dateOnly = DateTime.utc(dateWithTime.year, dateWithTime.month, dateWithTime.day);

        // 2. Friend データから Event オブジェクトを作成
        final event = Event(
          '${friend.name}:${friend.tradePlace}', // イベントタイトル (フレンド名を使用)
          dateWithTime, // イベントオブジェクトには時間情報を含める
        );

        // 3. Mapにイベントを追加
        organizedEvents.putIfAbsent(dateOnly, () => []).add(event);
    }

    // 4. すべての日付について、イベントを時間順にソート（ユーザー要求）
    organizedEvents.forEach((key, events) {
      events.sort((a, b) => a.date.compareTo(b.date));
    });

    return organizedEvents;
  }

  // 特定の日付のイベントを取得するヘルパー関数
  List<Event> _getEventsForDay(DateTime day, Map<DateTime, List<Event>> allEvents) {
    // 時間を無視したDateTimeオブジェクト（キー）を取得
    final dateOnly = DateTime.utc(day.year, day.month, day.day);
    return allEvents[dateOnly] ?? [];
  }

  // MARK: - カレンダーイベントハンドラ

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay, Map<DateTime, List<Event>> allEvents) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        // 選択された日付のイベントを再読み込み
        _selectedEvents = _getEventsForDay(selectedDay, allEvents);
      });
    }
  }

  // MARK: - UIの構築

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.tradeDateTimeLabel)),
      body: FutureBuilder<Map<DateTime, List<Event>>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          // 1. ローディング中の表示
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. エラー時の表示
          if (snapshot.hasError) {
            return Center(child: Text(' ${snapshot.error}'));
          }

          // 3. データが正常にロードされた場合
          final Map<DateTime, List<Event>> eventsMap = snapshot.data ?? {};

          // 初回ロード時に今日の日付のイベントをセット
          if (_selectedEvents.isEmpty) {
            _selectedEvents = _getEventsForDay(_selectedDay, eventsMap);
          }

          return Column(
            children: [
              // カレンダーウィジェット本体
              TableCalendar<Event>(
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                },
                locale: Localizations.localeOf(context).languageCode,
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                // 💡 ロードされたデータを eventLoader に渡す
                eventLoader: (day) => _getEventsForDay(day, eventsMap),
                onDaySelected: (selectedDay, focusedDay) {
                  _onDaySelected(selectedDay, focusedDay, eventsMap);
                },

                // 💡 イベントの個数を数字で表示するマーカーを実装
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          width: 18.0,
                          height: 18.0,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${events.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.0,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
                // ... その他のカレンダー設定
              ),

              const Divider(height: 1.0),

              // 選択された日付のイベントリスト表示
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedEvents.length,
                  itemBuilder: (context, index) {
                    final event = _selectedEvents[index];
                    final timeFormat = DateFormat('HH:mm');

                    return ListTile(
                      title: Text(event.title),
                      subtitle: Text(timeFormat.format(event.date)),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}