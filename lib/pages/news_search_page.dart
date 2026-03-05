import 'package:flutter/material.dart';
import "./news_list_page.dart";

class SearchPage extends StatefulWidget{
  const SearchPage({super.key});

  //SearchPageが継承した「StatefulWidget」の定義をOverrideしている
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>{
  final _yearController = TextEditingController();
  String _semester = "02";

  @override
  void dispose(){
    //_yearControllerは、入力欄を常に監視しているので、　disposeで閉じないとメモリが圧迫させる
    //_semesterは、ただのStringなので、勝手に捨てられる
    _yearController.dispose();
    super.dispose();
  }

  void _goToNewsList(){
    //_yearController.textはstring型なので、intに変換しつつ、
    //stringなどが入力された時のクラッシュ防止でint.Parseを使っている（int以外の入力時はnullが返る）
    final year = int.tryParse(_yearController.text);

    //contextは、ウィジェットツリー状で今ユーザーがどのページにいるのかの情報を持っている
    if(year == null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("年度は数字で入力してください")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewsListScreen(
          year: year,
          semester: _semester,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('条件入力')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _yearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '年度'),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: _semester,
              items: const [
                DropdownMenuItem(value: '01', child: Text('前期')),
                DropdownMenuItem(value: '02', child: Text('後期')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _semester = v);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _goToNewsList,
              child: const Text('お知らせを見る'),
            ),
          ],
        ),
      ),
    );
  }
}