import 'dart:convert';

class NewsArtical {
  late final int id;
  late final String author;
  late final String title;
  late final String url;
  late final String urlToImage;
  late final String publishedAt;
  late final String content;
  late final List<dynamic> categories;
  late final List<String> categoriesStr;

  NewsArtical({
    required this.id,
    required this.author,
    required this.title,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.content,
    required this.categories,
  }) {
    invokeCategory();
  }

  invokeCategory() {
    categoriesStr = <String>[];

    if (categories.contains(4)) {
      categoriesStr.add("प्रदेश");
    }
    if (categories.contains(6)) {
      categoriesStr.add("खेल");
    }
    if (categories.contains(5)) {
      categoriesStr.add("देश-विदेश");
    }
    if (categories.contains(3)) {
      categoriesStr.add("बृज समाचार");
    }
    if (categories.contains(1)) {
      categoriesStr.add("पंचांग-राशिफल");
    }
    if (categories.contains(55)) {
      categoriesStr.add("बिजनेस");
    }
  }
}

class MediaModel {
  String? id;
  String? timeStamp;
  String? path;
  String? captions;
  MediaModel({
    this.id,
    this.timeStamp,
    this.path,
    this.captions,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'timeStamp': timeStamp,
      'path': path,
      'captions': captions,
    };
  }

  factory MediaModel.fromMap(Map<String, dynamic> map) {
    return MediaModel(
      id: map['id'] != null ? map['id'] as String : null,
      timeStamp: map['timeStamp'] != null ? map['timeStamp'] as String : null,
      path: map['path'] != null ? map['path'] as String : null,
      captions: map['captions'] != null ? map['captions'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory MediaModel.fromJson(String source) =>
      MediaModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
