import 'package:dainik_ujala_admin/pages/new_media.dart';
import 'package:flutter/material.dart';

import 'pages/media_view.dart';
import 'pages/news_view.dart';

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
  ];
  int cIndex = 0;

  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: cIndex == 1
          ? FloatingActionButton.extended(
              heroTag: "hr",
              tooltip: "New Media",
              label: const Text(
                "New",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.normal),
              ),
              icon: const Icon(Icons.add_rounded),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewMediaPage(),
                    ));
              },
            )
          : null,
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
        ],
        selectedIndex: cIndex,
        onDestinationSelected: (value) {
          pageController.animateToPage(value,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut);
        },
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          setState(() => cIndex = index);
        },
        children: pages,
      ),
    );
  }
}
