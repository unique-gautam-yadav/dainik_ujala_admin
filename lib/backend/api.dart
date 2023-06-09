import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import 'models.dart';

class FetchData {
  static String api = "https://dainikujala.live/wp-json/wp/v2/posts";

  static Future<Iterable<NewsArtical>> callApi(
      {int page = 1, category = 0, String? slug}) async {
    List<NewsArtical> dataToBeSent = <NewsArtical>[];
    try {
      String url;
      if (category == 0 && page > 0 && slug == null) {
        url = "$api?page=$page";
      } else {
        if (slug == null && page != 0) {
          url = "$api?categories=$category&page=$page";
        } else {
          url = "$api?slug=$slug";
        }
      }
      log(url);
      final response = await http.get(Uri.parse(url));

      final decodedData = jsonDecode(response.body);

      // var newsData = decodedData["articles"];
      // log(decodedData);

      List<dynamic> data = List.from(decodedData);

      for (int i = 0; i < data.length; i++) {
        if (data[i] == null) {
          log("Something Skipped");
          continue;
        } else {
          NewsArtical item = NewsArtical(
            id: int.parse(data[i]["id"].toString()),
            author: data[i]["yoast_head_json"]["author"].toString(),
            title: data[i]["title"]["rendered"].toString(),
            content: data[i]["content"]["rendered"].toString(),
            url: data[i]["link"].toString(),
            urlToImage: data[i]["yoast_head_json"]["og_image"][0]["url"],
            publishedAt: data[i]["date"].toString(),
            categories: data[i]["categories"],
          );
          dataToBeSent.add(item);
        }
      }
      log("$page  ${dataToBeSent.length}    Data Fetched");
    } catch (e) {
      log(e.toString());
    }
    return dataToBeSent;
  }
}

class CloudFire {
  static FirebaseFirestore store = FirebaseFirestore.instance;
  static CollectionReference<dynamic> mediaCollection =
      store.collection('posts');

  static upload({required MediaModel data}) async {
    await mediaCollection.doc(data.id).set(data.toMap());
  }

  static Future<List<MediaModel>> getAllPosts({int times = 1}) async {
    QuerySnapshot<dynamic> d =
        await mediaCollection.orderBy('timeStamp').limit(20 * times).get();
    return List.generate(d.docs.length, (index) {
      return MediaModel.fromMap(d.docs.elementAt(index).data());
    });
  }

  static Future<void> deletePost(String id) async {
    await mediaCollection.doc(id).delete();
  }
}
