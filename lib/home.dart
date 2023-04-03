import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import 'backend/api.dart';
import 'backend/models.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int pageNo = 1;
  bool hasMore = true;

  late List<Widget> newsItems;

  loadNews() async {
    Iterable<NewsArtical> d = await FetchData.callApi(page: pageNo);
    newsItems = <Widget>[];
    if (mounted) {
      setState(() {
        if (d.isNotEmpty) {
          for (int i = 0; i < d.length; i++) {
            Widget one = ListTile(
              title: Text(d.elementAt(i).title),
              // subtitle: ,
            );
            // Widget one = Article(data: d.elementAt(i), curIndex: i);
            newsItems.add(one);
          }
          pageNo++;
        } else {
          hasMore = false;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: Column(
        children: [
          OutlinedButton(
              onPressed: () {
                sendNotification();
              },
              child: const Text("Send")),
        ],
      ),
    );
  }

  Future<void> sendNotification() async {
    try {
      http.Response response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAAAegRZZA:APA91bFVSfaC3HCQZ64J0kaD49RGoxiN15TcgryaB-FvKY50DJmEFmlRa0nQQmFOLz5LyosanHu1WkxuhXzCDtEHZfNn8TvxxV6XJpxq1WknKwSpBN82akfiYIscfEEL6F0kRQ7b-1WZ',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': 'test notification from admin app',
              'title': 'Hello 😋',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'imgUrl': 'FLUTTER_NOTIFICATION_CLICK',
              'url': 'done',
              'id': 1,
            },
            'to': '/topics/news',
          },
        ),
      );
      response;
    } catch (e) {
      e;
    }
  }
}
