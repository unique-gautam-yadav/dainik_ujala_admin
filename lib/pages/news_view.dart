import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';

import '../backend/api.dart';
import '../backend/models.dart';
import '../utils.dart';

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
                          TextEditingController bodyController =
                              TextEditingController();
                          TextEditingController titleController =
                              TextEditingController();
                          bodyController.text = a.title;
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12))),
                            builder: (context) => Padding(
                              padding: MediaQuery.of(context).viewInsets,
                              child: Container(
                                height: 250,
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12))),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                          height: 5,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              4,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(.9),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          )),
                                      const SizedBox(height: 20),
                                      TextFormField(
                                        controller: titleController,
                                        decoration: InputDecoration(
                                          labelText: "Title",
                                          hintText:
                                              "Trending News || Latest News || Crucial Topic etc...",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      TextFormField(
                                        controller: bodyController,
                                        decoration: InputDecoration(
                                          labelText: "Body",
                                          hintText: "Body for notification",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                      const Expanded(child: SizedBox.expand()),
                                      ElevatedButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            await Utils.sendNotification(
                                              title: titleController.text,
                                              body: bodyController.text,
                                              imgUrl: a.urlToImage,
                                              url: a.url,
                                            );
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                content: Text("Sent"),
                                              ));
                                            }
                                          },
                                          child: const Text("Send"))
                                    ]),
                              ),
                            ),
                          );
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
}
