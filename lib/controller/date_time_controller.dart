import 'package:flutter/foundation.dart';

class DateTimeController extends ChangeNotifier {
  // ① 内部で管理する DateTime
  DateTime _selectedDate = DateTime.now();

  // ② 外部から値を取得するためのゲッター
  DateTime get selectedDate => _selectedDate;

  // ③ 外部から値を更新するためのセッター
  void setDate(DateTime newDate) {
    if (_selectedDate != newDate) {
      _selectedDate = newDate;
      // 変更をリスナー（ConsumerやSelector）に通知
      notifyListeners();
    }
  }

  // ④ 時間を追加するようなロジックも追加可能
  void addDays(int days) {
    _selectedDate = _selectedDate.add(Duration(days: days));
    notifyListeners();
  }
}