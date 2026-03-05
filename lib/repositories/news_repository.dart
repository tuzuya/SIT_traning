import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_item.dart'; // 作ったNewsItemモデルを読み込む


class NewsRepository {
  
  //ここでconstコンストラクタを宣言することで、何回呼び出されても同じNewRepositoryという箱を使いまわせる
  //APIからのデータが入る箱は下のFutureの中で宣言しているので毎回最新のデータを入れられる
  const NewsRepository();
  
  // ニュースデータをAPIから取得する関数
  Future<List<NewsItem>> fetchNews(int year, String semester) async {
      // ⚠️【要変更】APIの実際のURL（パス）に書き換えてください
      final baseUrl = 'https://smob.sic.shibaura-it.ac.jp/smob/api/news/'; 
      final url = Uri.parse('$baseUrl$year$semester');

      // ⚠️【要変更】Postmanで使用したトークン文字列に書き換えてください
      const String apiToken = "QjcyQzJEOTFBQzkyNTcxOUREMEI3MDczMjJFMTlDOTA";

      //APIへリクエストを送る部分
      try {
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $apiToken', // Bearerが不要な場合は消してください
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          //responseのボディー部分を文字化けしないようににデコードしてから、jsonとして解釈する
          final decodedString = utf8.decode(response.bodyBytes);
          final decodedData = json.decode(decodedString);

          if(decodedData is List){
            return  decodedData
              .map((data) => NewsItem.fromJson(data))
              .where((item) => item.categoryCd == "51" || item.tagsEnglish == "LMS")
              .toList();
              /* 授業のお知らせは、categoryCdが「51」か、tagsEnglishに「LMS」が含まれているものと定義してみました */
          }else{
            throw Exception('予期しないデータ形式: JSONのルートがリストではありません');
          }
        } else {
          throw Exception('サーバーエラー (コード: ${response.statusCode})');
        }
      } catch (e) {
        throw Exception('通信に失敗しました: $e');
      }
    }
}
