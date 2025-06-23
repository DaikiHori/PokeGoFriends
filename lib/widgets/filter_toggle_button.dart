import 'package:flutter/material.dart';

// FilterToggleButtonは、クリックで3つの状態を切り替えるカスタムボタンです。
class FilterToggleButton extends StatefulWidget {
  // ボタンの各状態に対応するアイコンデータのリスト
  final List<IconData> icons;
  // 各状態に対応する背景色のリスト
  final List<Color> backgroundColors;
  // 各状態に対応するアイコン色のリスト
  final List<Color> iconColors; // TextColorsからIconColorsに変更
  // ボタンがクリックされたときに、新しい状態のインデックスを通知するコールバック
  final ValueChanged<int> onChanged;
  // 初期状態のインデックス
  final int initialIndex;
  // オプションでアイコンのサイズを指定
  final double iconSize;

  const FilterToggleButton({
    super.key,
    required this.icons, // labelsからiconsに変更
    required this.backgroundColors,
    required this.iconColors, // textColorsからiconColorsに変更
    required this.onChanged,
    this.initialIndex = 0, // デフォルトは最初の状態
    this.iconSize = 24.0, // デフォルトのアイコンサイズ
  }) : assert(icons.length == backgroundColors.length && icons.length == iconColors.length,
  'Icons, backgroundColors, and iconColors must have the same length.');

  @override
  State<FilterToggleButton> createState() => _FilterToggleButtonState();
}

class _FilterToggleButtonState extends State<FilterToggleButton> {
  // 現在選択されている状態のインデックス
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // 初期状態を設定
  }

  // ボタンがタップされたときの処理
  void _onTap() {
    setState(() {
      // インデックスをインクリメントし、リストの最後に到達したら0に戻る（サイクル）
      _currentIndex = (_currentIndex + 1) % widget.icons.length;
    });
    // 親ウィジェットに新しい状態を通知
    widget.onChanged(_currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap, // タップジェスチャーを検出
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          // 現在のインデックスに対応する背景色を設定
          color: widget.backgroundColors[_currentIndex],
          borderRadius: BorderRadius.circular(8.0), // 角丸
          border: Border.all(color: Colors.grey.shade400), // 軽い境界線
        ),
        child: Icon( // TextからIconに変更
          widget.icons[_currentIndex], // 現在のインデックスに対応するアイコンを表示
          color: widget.iconColors[_currentIndex], // 現在のインデックスに対応するアイコン色を設定
          size: widget.iconSize, // アイコンサイズ
        ),
      ),
    );
  }
}
