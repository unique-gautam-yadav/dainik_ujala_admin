import 'dart:io';

import 'package:dainik_ujala_admin/backend/models.dart';
import 'package:dainik_ujala_admin/backend/promotions_backend.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils.dart';

Future<void> newPromotionBanner(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
    builder: (context) => Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        height: 300,
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: const EditablePromotion(),
      ),
    ),
  );
}

class EditablePromotion extends StatefulWidget {
  const EditablePromotion({
    super.key,
  });

  @override
  State<EditablePromotion> createState() => _EditablePromotionState();
}

class _EditablePromotionState extends State<EditablePromotion> {
  bool pressed = false;

  bool onFront = false;
  String? title;
  String? url;
  String? path;

  String status = "";

  bool hasError = false;

  pickFile({required ImageSource src}) async {
    XFile? rawFile = await ImagePicker().pickImage(source: src);
    if (rawFile != null) {
      CroppedFile? file = await ImageCropper()
          .cropImage(sourcePath: rawFile.path, compressQuality: 100);
      if (file != null) {
        setState(() {
          path = file.path;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 5,
          width: 150,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: hasError
                ? Colors.red
                : Theme.of(context).colorScheme.primary.withOpacity(.05),
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              GestureDetector(
                onTapDown: (details) {
                  setState(() {
                    hasError = false;
                    pressed = true;
                  });
                },
                onTapUp: (details) {
                  setState(() {
                    hasError = false;
                    pressed = false;
                  });
                },
                onTapCancel: () {
                  setState(() {
                    hasError = false;
                    pressed = false;
                  });
                },
                onTap: () {
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  foregroundDecoration: BoxDecoration(
                    color: pressed
                        ? CupertinoColors.systemGrey.withOpacity(.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(5),
                  height: 95,
                  width: 95,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 95,
                      width: 95,
                      child: path == null
                          ? const Center(
                              child: Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 60,
                              ),
                            )
                          : Image.file(File(path!), fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      onChanged: (value) {
                        setState(() {
                          hasError = false;

                          title = value;
                        });
                      },
                      decoration: const InputDecoration(hintText: "Title"),
                    ),
                    ChoiceChip(
                      label: const Text("On font"),
                      selected: onFront,
                      onSelected: (value) {
                        setState(() {
                          hasError = false;
                          onFront = !onFront;
                        });
                      },
                    ),
                    TextFormField(
                      onChanged: (value) {
                        setState(() {
                          hasError = false;
                          url = value;
                        });
                      },
                      decoration: const InputDecoration(hintText: "Url"),
                    ),
                    const SizedBox(height: 16)
                  ],
                ),
              ),
              const SizedBox(width: 16)
            ],
          ),
        ),
        Expanded(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: hasError ? 1 : 0,
            child: Center(
              child: Text(
                status,
                style: TextStyle(
                  color: Colors.red.shade800,
                ),
              ),
            ),
          ),
        ),
        OutlinedButton(
            onPressed: () async {
              setState(() {
                hasError = false;
                status = "";
              });
              if (title == null || title!.isEmpty) {
                setState(() {
                  hasError = true;
                  status = "Missing title";
                });
              } else if (url == null || url!.isEmpty) {
                setState(() {
                  hasError = true;
                  status = "Missing url";
                });
              } else if (path == null || path!.isEmpty) {
                setState(() {
                  hasError = true;
                  status = "Missing image";
                });
              } else {
                String id = "advt_${DateTime.now().millisecondsSinceEpoch}";
                late String imgUrl;
                FirebaseStorage storage = FirebaseStorage.instance;
                Reference ref = storage.ref("posts").child(id);
                await ref.putFile(File(path!)).whenComplete(() async {
                  String url = await ref.getDownloadURL();
                  imgUrl = url;
                });
                AdvtModel model = AdvtModel(
                  id: id,
                  imageUrl: imgUrl,
                  link: url!,
                  title: title!,
                  onMainScreen: onFront,
                );
                PromotionsStorage().storePromotion(model).then((value) {
                  if (mounted && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Prmotion added"),
                      ),
                    );
                    Navigator.pop(context);
                  }
                });
              }
            },
            child: const Text("Upload")),
        const SizedBox(height: 10),
      ],
    );
  }
}
