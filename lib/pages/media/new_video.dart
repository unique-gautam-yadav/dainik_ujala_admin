import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../backend/api.dart';
import '../../backend/models.dart';
import '../../utils.dart';

class NewVideoPage extends StatefulWidget {
  const NewVideoPage({super.key});

  @override
  State<NewVideoPage> createState() => _NewVideoPageState();
}

class _NewVideoPageState extends State<NewVideoPage> {
  File? image;

  pickFile({required ImageSource src}) async {
    log("$src");
    XFile? rawFile = await ImagePicker().pickVideo(source: src);
    if (rawFile != null) {
      setState(() {
        image = File(rawFile.path);
      });
    }
  }

  TextEditingController caption = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "New",
          style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.normal),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () {
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
                                    icon: Icons.videocam_rounded,
                                    title: "Camera",
                                    onPressed: () {
                                      pickFile(src: ImageSource.camera);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  CustomButton(
                                    icon: Icons.video_collection_rounded,
                                    title: "Gallery",
                                    onPressed: () {
                                      pickFile(src: ImageSource.gallery);
                                      Navigator.pop(context);
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
                padding: EdgeInsets.zero,
                shape:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                child: image == null
                    ? Container(
                        height: MediaQuery.of(context).size.width - 16,
                        width: MediaQuery.of(context).size.width - 16,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color!),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.add_circle_rounded,
                            size: MediaQuery.of(context).size.width * .2,
                          ),
                        ),
                      )
                    : PlayerWidget(image: image!),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: caption,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    labelText: "Caption",
                    hintText: "Enter caption for media."),
              ),
              OutlinedButton.icon(
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 45))),
                onPressed: () async {
                  MediaModel data = MediaModel(
                    captions: caption.text,
                    isVideo: true,
                  );
                  String timeStamp =
                      DateTime.now().millisecondsSinceEpoch.toString();
                  data.timeStamp = timeStamp;
                  data.id = "post_$timeStamp";
                  FirebaseStorage storage = FirebaseStorage.instance;
                  Reference ref = storage.ref("posts").child(data.id!);
                  await ref.putFile(image!).whenComplete(() async {
                    String url = await ref.getDownloadURL();
                    log(url);
                    data.path = url;
                  });
                  await CloudFire.upload(data: data);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Task done"),
                    ));
                  }
                },
                label: const Text("Upload"),
                icon: const Icon(Icons.upload_rounded),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PlayerWidget extends StatefulWidget {
  const PlayerWidget({
    super.key,
    required this.image,
  });

  final File image;

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  late VideoPlayerController videoController;

  bool isPlaying = false;
  double seek = 0.0;

  @override
  void initState() {
    super.initState();
    videoController = VideoPlayerController.file(widget.image)
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
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: videoController.value.aspectRatio,
              child: VideoPlayer(videoController),
            ),
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
