// event.dart

class Event {
  final String title;
  final DateTime date;
  // 他のfriend tableのカラムを追加できます（例: friendName, tradeDetailsなど）

  const Event(this.title, this.date);

  // table_calendarでイベントを識別するために、toStringをオーバーライドすることが推奨されます
  @override
  String toString() => title;
}