import 'package:flutter/material.dart';
import '../models/news_item.dart';
import '../repositories/news_repository.dart';

// // 実際の画面（UI）を作る部分
// 2. お知らせ一覧画面（ページコンポーネント）

class NewsListScreen extends StatefulWidget {

  final int year;
  final String semester;

  const NewsListScreen({
    //keyは、このクラスが呼び出されるとき、特にマップを使って表示したりするときに必要
    super.key,
    required this.year,
    required this.semester,
    });

  //表側のクラスの中で、createState()を使うことで裏側を担当するクラスを指定することができる
  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

//NewsRepositoryクラスの中で、const コンストラクタを宣言しているので、呼び出し側でもconstをつけて呼び出せて、メモリを圧迫しないで済む
const newsRepository = NewsRepository(); 

//引数の前の方宣言はジェネリクス、_NewsListScreenStateがNewsListScreenの状態を管理する裏方のクラスであるということを指定している
class _NewsListScreenState extends State<NewsListScreen> {

  //late は、後々値が入る想定の変数の宣言に使う。Dartは中身を入れるor？をつけないとエラーになるが、lateはそれを回避できる
  late Future<List<NewsItem>> _newsFuture;

  @override
  void initState() {
    super.initState();
    //表のwidgetクラスで受け取って、裏のStateクラスでwidget.？？でアクセスする
    _newsFuture = newsRepository.fetchNews(widget.year, widget.semester);
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