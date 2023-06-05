import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebBrouser extends StatefulWidget {
  const WebBrouser({super.key, required this.url});

  final String url;

  @override
  State<WebBrouser> createState() => _WebBrouserState();
}

class _WebBrouserState extends State<WebBrouser> {
  late WebViewController controller;
  String? title;
  String? url;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..loadRequest(Uri.parse(widget.url))
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
      controller.getTitle().then(
          (value) => setState(() {
            title = value;
          }),
        );
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (mounted && context.mounted) {
        String? temp = await controller.getTitle();
        String? temp2 = await controller.currentUrl();
        if (mounted && context.mounted) {
          setState(() {
            title = temp;
            url = temp2;
          });
        } else {
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close_rounded),
        ),
        leadingWidth: 50,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title != null && title!.trim().isNotEmpty ? title! : "Loading...",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              url != null && url!.trim().isNotEmpty ? url! : "Loading...",
              style: Theme.of(context).textTheme.bodySmall,
            )
          ],
        ),
      ),
      body: SafeArea(
        child: WebViewWidget(
          controller: controller,
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const [
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.arrow_back_ios),
      //         label: "Back",
      //         tooltip: "Back in brouser"),
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.arrow_forward_ios),
      //         label: "Forward",
      //         tooltip: "Forward in brouser"),
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.replay_rounded),
      //         label: "Reload",
      //         tooltip: "Reload brouser"),
      //   ],
      //   onTap: (value) {
      //     switch (value) {
      //       case 0:
      //         controller.goBack();
      //         break;
      //       case 1:
      //         controller.goForward();
      //         break;
      //       case 2:
      //         controller.reload();
      //         break;
      //       default:
      //         break;
      //     }
      //   },
      // ),
    );
  }
}
