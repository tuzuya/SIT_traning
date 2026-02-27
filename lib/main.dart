import 'package:flutter/material.dart';
import "dart:convert";
import 'package:http/http.dart' as http;

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
      home: NewsListScreen(),// 最初に表示する画面を指定
    );
  }
}
//⭐️上の部分の大文字のやつはウィジェットではなくクラスのインスタンス（Dartはnewがないのでわかりにくいが）
// //一番上のMaterialAppというインスタンスの引数としてtitleなどのパラメータがあり、そこに「:」でThemeDataなどのインスタンスを代入、さらにその引数として。。。。という感じ

// //⭐️つまり、↑と↓のクラスの中の大文字の奴らは全部クラスのインスタンスだが、その中でも↓で使っている、「見た目に出る」ものは、裏側でWidgetクラスを継承しているので、特別ウィジェットと呼ぶ

//取得するニュースデータの構造を表すクラス
class NewsItem {
  NewsItem({
    required this.newsId,
    required this.title,
    required this.author,
    required this.publishTime,
    required this.isImportant,
    this.fileName,
    this.fileUrlPath,
  });

  final String newsId;
  final String title;
  final String author;
  final String publishTime;
  final bool isImportant;
  final String? fileName;
  final String? fileUrlPath;

  //base64の解読用の関数
  static String _decodeBase64(String base64String) {
    if (base64String.isEmpty) return "";
    
    try {
      // 1. 余計な空白や改行コードをすべて取り除く（原因2の対策）
      String normalized = base64String.replaceAll(RegExp(r'\s+'), '');
      
      // 2. 文字数が4の倍数になるように末尾に「=」を補う（原因1の対策）
      int padding = normalized.length % 4;
      if (padding != 0) {
        normalized += '=' * (4 - padding);
      }

      // 3. Base64をバイト列（数値の配列）に変換
      final bytes = base64Decode(normalized);
      
      // 4. バイト列をUTF-8の文字列に変換
      // allowMalformed: true をつけると、少し文字コードがおかしくてもエラーにならず「」で強行突破してくれます（原因4の対策）
      return utf8.decode(bytes, allowMalformed: true);
      
    } catch (e) {
      // ⚠️ここが重要！なぜ失敗したのかをコンソール（ターミナル）に出力します
      debugPrint("デコード失敗の原因: $e");
      debugPrint("失敗した文字列: $base64String");
      
      // 失敗した場合は、そのまま返す（平文だった場合＝原因3の対策）
      return base64String; 
    }
  }

  //factoryと書くことで、名前付きでコンストラクタを作ることができる
  //順番は、factoryコンストラクタ -> 通常のコンストラクタ -> クラスのフィールドへの代入 ->  return　という流れ
  //⚠️複数個factoryコンストラクタを作った時は、呼び出し側で「NewsItem.fromJson()」のように、どのコンストラクタを呼ぶか指定する必要がある
  factory NewsItem.fromJson(Map<String, dynamic> json) {
    final tags = json["tags"] ?? "";
    return NewsItem(
      newsId: json["newsId"] ?? "",
      title: _decodeBase64(json["title"] ?? ""),
      author: _decodeBase64(json["author"] ?? ""),
      publishTime: (json["publishTime"] ?? "").toString().substring(0, 16),
      isImportant: tags.contains("重要"),
      fileName: json["file_name1"] == "" ? null : json["file_name1"],
      fileUrlPath: json["obj_name1"] == "" ? null : json["obj_name1"],
    );
  }
}

// // 実際の画面（UI）を作る部分
// 2. お知らせ一覧画面（ページコンポーネント）
// 2. お知らせ一覧画面（ページコンポーネント）
class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  //表側のクラスの中で、createState()を使うことで裏側を担当するクラスを指定することができる
  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

//引数の前の方宣言はジェネリクス、_NewsListScreenStateがNewsListScreenの状態を管理する裏方のクラスであるということを指定している
class _NewsListScreenState extends State<NewsListScreen> {

  //late は、後々値が入る想定の変数の宣言に使う。Dartは中身を入れるor？をつけないとエラーになるが、lateはそれを回避できる
  late Future<List<NewsItem>> _newsFuture;

  @override
  void initState() {
    super.initState();
    // 画面を開いた時に、2024年度の前期のニュースを取得する（仮設定）
    _newsFuture = fetchNews(2024, "02");
  }

  Future<List<NewsItem>> fetchNews(int year, String semester) async {
    // ⚠️【要変更】APIの実際のURL（パス）に書き換えてください
    final baseUrl = 'https://smob.sic.shibaura-it.ac.jp/smob/api/news'; 
    final url = Uri.parse('$baseUrl?year=$year&semester=$semester');

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

        List<dynamic> targetList;
        if(decodedData is List){
          return  decodedData.map((data) => NewsItem.fromJson(data)).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('最新のお知らせ'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      //FutureBuilderは、非同期処理の結果を元にUIを作ってくれるウィジェット
      body: FutureBuilder<List<NewsItem>>(
        future: _newsFuture,
        //context,shapshotはFutureBuilderのbuilder関数に自動で渡される値で、contextはウィジェットツリーの位置情報を持ち、snapshotは非同期処理の状態や結果を持つオブジェクト
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました\n${snapshot.error}'));
          }

          final newsList = snapshot.data!;
          if (newsList.isEmpty) {
            return const Center(child: Text('お知らせはありません'));
          }

          return ListView.separated(
            itemCount: newsList.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final news = newsList[index];

              return ListTile(
                leading: Icon(
                  news.isImportant ? Icons.notification_important : Icons.article,
                  color: news.isImportant ? Colors.red : Colors.teal,
                ),
                title: Text(
                  news.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${news.author} • ${news.publishTime}"),
                    if (news.fileName != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.attach_file, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              news.fileName!,
                              style: const TextStyle(color: Colors.blue, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                isThreeLine: news.fileName != null,
              );
            },
          );
        },
      ),
    );
  }
}