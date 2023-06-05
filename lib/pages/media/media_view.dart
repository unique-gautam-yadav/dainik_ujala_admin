import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../backend/api.dart';
import '../../backend/models.dart';
import '../../utils.dart';

class MediaSection extends StatefulWidget {
  const MediaSection({super.key});

  @override
  State<MediaSection> createState() => _MediaSectionState();
}

class _MediaSectionState extends State<MediaSection> {
  List<MediaModel>? data;

  getAllMedia() async {
    List<MediaModel>? temp = await CloudFire.getAllPosts();
    if (mounted && context.mounted) {
      setState(() {
        data = temp;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getAllMedia();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: data != null
          ? data!.isNotEmpty
              ? GridView.builder(
                  physics: const ClampingScrollPhysics(),
                  itemCount: data!.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    return MediaItem(
                      item: data!.elementAt(index),
                    );
                  },
                )
              : const Center(
                  child: Text("No data found!!"),
                )
          : Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).iconTheme.color,
                strokeWidth: 5,
              ),
            ),
    );
  }
}

class MediaItem extends StatefulWidget {
  const MediaItem({
    super.key,
    required this.item,
  });

  final MediaModel item;

  @override
  State<MediaItem> createState() => _MediaItemState();
}

class _MediaItemState extends State<MediaItem> {
  bool pressed = false;
  File? thumbernail;

  firstStep() async {
    if (widget.item.isVideo) {
      try {
        String? t = await VideoThumbnail.thumbnailFile(
          video: widget.item.path!,
          imageFormat: ImageFormat.JPEG,
        );
        if (t != null) {
          if (mounted && context.mounted) {
            setState(() {
              thumbernail = File(t);
            });
          }
        }
      } catch (e) {
        log(e.toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    firstStep();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: Styled.widget(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .color!
                      .withOpacity(.1),
                ),
              ),
              child: widget.item.isVideo
                  ? thumbernail == null
                      ? SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        )
                      : Image.file(
                          thumbernail!,
                          fit: BoxFit.cover,
                        )
                  : CachedNetworkImage(
                      imageUrl: widget.item.path!,
                      fit: BoxFit.cover,
                      progressIndicatorBuilder: (context, url, progress) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                            value: progress.progress,
                          ),
                        );
                      },
                    ),
            ),
          )
              .ripple()
              .padding(all: 2)
              .gestures(onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.transparent,
                    shape: const RoundedRectangleBorder(),
                    elevation: 0,
                    contentPadding: EdgeInsets.zero,
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Preview(widget: widget),
                        Text(widget.item.captions!)
                      ],
                    ),
                  ),
                );
              }, onTapChange: (tapState) {
                setState(() {
                  pressed = tapState;
                });
              })
              .scale(all: pressed ? 0.95 : 1, animate: true)
              .animate(const Duration(milliseconds: 150), Curves.easeOut),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color:
                      Theme.of(context).scaffoldBackgroundColor.withOpacity(.3),
                  blurRadius: 20,
                )
              ],
            ),
            child: PopupMenuButton(
              itemBuilder: (context) {
                return const [
                  PopupMenuItem(
                    value: 1,
                    child: Text("Send notification"),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Text("Delete"),
                  ),
                ];
              },
              onSelected: (value) {
                log("$value");
                if (value == 1) {
                  sendN(widget.item);
                }
                if (value == 2) {
                  deleteMedia(widget.item);
                }
              },
            ),
          ),
        )
      ],
    );
  }

  deleteMedia(MediaModel post) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Are you sure!!"),
        content:
            const Text("Do you want to delete this media from application."),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                FirebaseStorage storage = FirebaseStorage.instance;
                Reference postRef = storage.refFromURL(post.path!);
                await postRef.delete();
                await CloudFire.deletePost(post.id!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text("Task Done")));
                }
              } catch (e) {
                log(e.toString());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Something went wrong"),
                  ),
                );
              }
            },
            child: const Text("Yes"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("No"),
          )
        ],
      ),
    );
  }

  sendN(MediaModel post) async {
    TextEditingController bodyController = TextEditingController();
    TextEditingController titleController = TextEditingController();
    titleController.text = post.captions ?? "";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          height: 250,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                height: 5,
                width: MediaQuery.of(context).size.width / 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(.9),
                  borderRadius: BorderRadius.circular(12),
                )),
            const SizedBox(height: 20),
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Title",
                hintText: "Title for notification",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const Expanded(child: SizedBox.expand()),
            ElevatedButton(
                onPressed: () async {
                  await Utils.sendNotification(
                      title: titleController.text,
                      body: bodyController.text,
                      imgUrl: post.path!,
                      url: post.path!);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Sent"),
                    ));
                  }
                },
                child: const Text("Send"))
          ]),
        ),
      ),
    );
  }
}

class Preview extends StatelessWidget {
  const Preview({
    super.key,
    required this.widget,
  });

  final MediaItem widget;

  @override
  Widget build(BuildContext context) {
    return widget.item.isVideo
        ? NetworkPlayerWidget(
            path: widget.item.path!,
          )
        : CachedNetworkImage(
            imageUrl: widget.item.path!,
          );
  }
}

class NetworkPlayerWidget extends StatefulWidget {
  const NetworkPlayerWidget({
    super.key,
    required this.path,
  });

  final String path;

  @override
  State<NetworkPlayerWidget> createState() => _NetworkPlayerWidgetState();
}

class _NetworkPlayerWidgetState extends State<NetworkPlayerWidget> {
  late VideoPlayerController videoController;

  bool isPlaying = false;
  double seek = 0.0;

  @override
  void initState() {
    super.initState();
    videoController = VideoPlayerController.network(widget.path)
      ..initialize().then((_) {
        setState(() {});
      });

    videoController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(13),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: videoController.value.aspectRatio,
            child: VideoPlayer(videoController),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width - 50,
            child: Row(
              children: [
                IconButton(
                  onPressed: isPlaying
                      ? () {
                          videoController.pause().then((value) {
                            setState(() {
                              isPlaying = false;
                            });
                          });
                        }
                      : () {
                          videoController.play().then((value) {
                            setState(() {
                              isPlaying = true;
                            });

                            Timer.periodic(const Duration(milliseconds: 100),
                                (timer) {
                              if (videoController.value.isPlaying) {
                                seek = videoController
                                        .value.position.inMilliseconds /
                                    videoController
                                        .value.duration.inMilliseconds;
                              } else {
                                timer.cancel();
                                setState(() {
                                  isPlaying = false;
                                });
                              }
                            });
                          });
                        },
                  icon: isPlaying
                      ? const Icon(Icons.pause_rounded)
                      : const Icon(Icons.play_arrow_rounded),
                ),
                Expanded(
                  // width: 30,
                  // height: 10,
                  // child: VideoProgressIndicator(videoController,
                  //     allowScrubbing: true),
                  child: Slider(
                    value: seek <= 1.0 ? seek : 1.0,
                    onChanged: (val) {
                      videoController
                          .seekTo(videoController.value.duration * val);
                      log((videoController.value.duration * val).toString());
                      setState(() {
                        seek = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    videoController.dispose();
    super.dispose();
  }
}
