import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import '../backend/api.dart';
import '../backend/models.dart';

class NewsNotifications extends StatefulWidget {
  const NewsNotifications({super.key});

  @override
  State<NewsNotifications> createState() => _NewsNotificationsState();
}

class _NewsNotificationsState extends State<NewsNotifications> {
  int pageNo = 1;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder<Iterable<NewsArtical>>(
              future: FetchData.callApi(page: pageNo),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      NewsArtical a = snapshot.data!.elementAt(index);
                      return ListTile(
                        onTap: () async {
                          await sendNotification(
                            body: a.title
                                .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
                            imgUrl: a.urlToImage,
                            title: "Latest News",
                            url: a.url,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Sent")));
                          }
                        },
                        title: Text(
                          a.title.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        leading: SizedBox(
                          height: 50,
                          width: 100,
                          child: CachedNetworkImage(
                            imageUrl: a.urlToImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                        subtitle: Text(
                          a.content.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: SizedBox(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator()),
                  );
                }
              },
            ),
          ),
          Text("Current Page : $pageNo"),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 60,
            child: ButtonBar(children: [
              TextButton(
                  onPressed: () {
                    if (pageNo != 1) {
                      setState(() {
                        pageNo--;
                      });
                    }
                  },
                  child: const Text("Prev")),
              TextButton(
                  onPressed: () {
                    setState(() {
                      pageNo++;
                    });
                  },
                  child: const Text("Next")),
            ]),
          )
        ],
      ),
    );
  }

  Future<void> sendNotification(
      {required String title,
      required String body,
      required String imgUrl,
      required String url}) async {
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
              'body': body,
              'title': title,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'imgUrl': imgUrl,
              'url': url,
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
