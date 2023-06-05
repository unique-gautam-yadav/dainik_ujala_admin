import 'package:dainik_ujala_admin/pages/media/new_photo.dart';
import 'package:dainik_ujala_admin/pages/media/new_video.dart';
import 'package:dainik_ujala_admin/pages/promotions/new_promotion.dart';
import 'package:flutter/material.dart';

import 'pages/media/media_view.dart';
import 'pages/news_view.dart';
import 'pages/promotions/promotions_view.dart';
import 'utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  List<Widget> pages = const [
    NewsNotifications(),
    MediaSection(),
    PromotionsView()
  ];
  int cIndex = 0;
  int ii = 0;

  PageController pageController = PageController();

  bool showBtn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ii == 1
          ? AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: showBtn ? 1 : 0,
              // scale: showBtn ? 1 : 0,
              child: FloatingActionButton.extended(
                label: const Text("New"),
                icon: const Icon(Icons.add_rounded),
                onPressed: () async {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                        margin: const EdgeInsets.only(
                          left: 12,
                          right: 12,
                          top: 12,
                          bottom: 24,
                        ),
                        height: 180,
                        child: Column(
                          children: [
                            Container(
                              height: 5,
                              width: 100,
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color!
                                      .withOpacity(.2),
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            const SizedBox(height: 05),
                            SizedBox(
                              height: 170,
                              width: MediaQuery.of(context).size.width,
                              child: ButtonBar(
                                alignment: MainAxisAlignment.spaceAround,
                                children: [
                                  CustomButton(
                                    icon: Icons.image,
                                    title: "Photo",
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const NewPhotoPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  CustomButton(
                                    icon: Icons.movie,
                                    title: "Video",
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const NewVideoPage(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            )
          : ii == 2
              ? AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: showBtn ? 1 : 0,
                  // scale: showBtn ? 1 : 0,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      newPromotionBanner(context);
                    },
                    label: const Text("New"),
                    icon: const Icon(Icons.add),
                  ),
                )
              : const SizedBox.shrink(),
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      bottomNavigationBar: NavigationBar(
        animationDuration: const Duration(milliseconds: 500),
        height: 60,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.newspaper),
            label: "News",
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_library),
            label: "Media",
          ),
          NavigationDestination(
            icon: Icon(Icons.monetization_on_rounded),
            label: "Promotions",
          ),
        ],
        selectedIndex: cIndex,
        onDestinationSelected: (value) {
          if (value == 0) {
            setState(() {
              showBtn = false;
              cIndex = value;
            });
            Future.delayed(const Duration(milliseconds: 250))
                .then((value) => setState(() {
                      ii = 0;
                    }));
          } else {
            setState(() {
              showBtn = false;
              cIndex = value;
              ii = value;
            });
          }
          pageController.animateToPage(value,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut);
          if (value != 0) {
            Future.delayed(const Duration(milliseconds: 300)).then((value) {
              setState(() {
                showBtn = true;
              });
            });
          }
        },
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: pages,
      ),
    );
  }
}
