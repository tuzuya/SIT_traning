import 'package:flutter/material.dart';
import "dart:convert";
import 'package:http/http.dart' as http;
import "./pages/news_list_page.dart";
import"./pages/news_search_page.dart";

void main() {
  runApp(const CampusNewsApp());
}

// 1. アプリ全体の設定（ルートコンポーネント）
class CampusNewsApp extends StatelessWidget {
  const CampusNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    //return MaterialAppはFlutterアプリの基本的な構造を提供するウィジェットで、テーマやルーティングなどの設定を行う。基本的に一度だけ最上位の部分で使用される。
    return MaterialApp(
      title: '学内お知らせアプリ',
      //テーマはアプリ全体の見た目を統一するための設定。ここでは、色のスキームを指定して、Material Design 3を使用するようにしています。
//    //ここで一度設定しておくと、appBarやその他のウィジェットがこのテーマを自動的に使用して、統一感のあるデザインになる。
      theme: ThemeData(
        // ニュースアプリらしく、少し知的なティール（青緑）をテーマカラーにしてみました
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: SearchPage(),// 最初に表示する画面を指定
    );
  }
}
//⭐️上の部分の大文字のやつはウィジェットではなくクラスのインスタンス（Dartはnewがないのでわかりにくいが）
// //一番上のMaterialAppというインスタンスの引数としてtitleなどのパラメータがあり、そこに「:」でThemeDataなどのインスタンスを代入、さらにその引数として。。。。という感じ

// //⭐️つまり、↑と↓のクラスの中の大文字の奴らは全部クラスのインスタンスだが、その中でも↓で使っている、「見た目に出る」ものは、裏側でWidgetクラスを継承しているので、特別ウィジェットと呼ぶ

//取得するニュースデータの構造を表すクラス


