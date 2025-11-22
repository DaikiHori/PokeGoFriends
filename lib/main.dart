import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:poke_go_friends/l10n/app_localizations.dart';
import 'package:poke_go_friends/screens/friends_list_page.dart';
import 'package:provider/provider.dart';
import 'controller/date_time_controller.dart';
void main() {
  runApp(
    ChangeNotifierProvider(
      // コントローラーのインスタンスを作成
      create: (context) => DateTimeController(),
      child: const MyApp(), // アプリケーション全体で利用可能にする
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ja', ''),
      ],
      // ホーム画面をFriendsListPageに変更
      home: const FriendsListPage(), // <-- ここを変更
    );
  }
}
