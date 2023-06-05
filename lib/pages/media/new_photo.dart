import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../backend/api.dart';
import '../../backend/models.dart';
import '../../utils.dart';

class NewPhotoPage extends StatefulWidget {
  const NewPhotoPage({super.key});

  @override
  State<NewPhotoPage> createState() => _NewPhotoPageState();
}

class _NewPhotoPageState extends State<NewPhotoPage> {
  File? image;

  pickFile({required ImageSource src}) async {
    log("$src");
    XFile? rawFile = await ImagePicker().pickImage(source: src);
    if (rawFile != null) {
      CroppedFile? file = await ImageCropper()
          .cropImage(sourcePath: rawFile.path, compressQuality: 100);
      if (file != null) {
        setState(() {
          image = File(file.path);
        });
      }
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
        physics: const ClampingScrollPhysics(),
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
                                    icon: Icons.camera_alt_rounded,
                                    title: "Camera",
                                    onPressed: () {
                                      pickFile(src: ImageSource.camera);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  CustomButton(
                                    icon: Icons.image,
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
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(image!)),
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
                    isVideo: false,
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
