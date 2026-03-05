import 'dart:convert';
import 'package:flutter/material.dart'; // debugPrintを使うために必要

class NewsItem {
  NewsItem({
    required this.newsId,
    required this.title,
    required this.author,
    required this.publishTime,
    required this.isImportant,
    required this.categoryCd,
    required this.tagsEnglish,
    this.fileName,

  });

  final String newsId;
  final String title;
  final String author;
  final String publishTime;
  final bool isImportant;
  final String categoryCd;
  final String tagsEnglish;
  final String? fileName;

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
      //なぜ失敗したのかをコンソール（ターミナル）に出力します
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
      categoryCd: json["categoryCd"] ?? "",
      tagsEnglish: json["tagsEnglish"] ?? "",
      fileName: json["file_name1"] == "" ? null : json["file_name1"],
    );
  }
}