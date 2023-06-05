import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dainik_ujala_admin/pages/brouser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../backend/models.dart';
import '../../backend/promotions_backend.dart';
import 'new_promotion.dart';

class PromotionsView extends StatefulWidget {
  const PromotionsView({super.key});

  @override
  State<PromotionsView> createState() => _PromotionsViewState();
}

class _PromotionsViewState extends State<PromotionsView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<AdvtModel>>(
        future: PromotionsStorage().getPromotions(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isNotEmpty) {
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) => PromotionWidget(
                  model: snapshot.data!.elementAt(index),
                  index: index,
                  sets: () {
                    setState(() {});
                  },
                ),
              );
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.hourglass_empty_rounded, size: 75),
                  const Text("No promotion added"),
                  const SizedBox(height: 50),
                  OutlinedButton.icon(
                    onPressed: () {
                      newPromotionBanner(context).then((value) {
                        if (mounted && context.mounted) {
                          setState(() {});
                        }
                      });
                    },
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: const Text("Add new"),
                  )
                ],
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 5,
                color: Theme.of(context).iconTheme.color,
              ),
            );
          }
        },
      ),
    );
  }
}

class PromotionWidget extends StatelessWidget {
  const PromotionWidget({
    super.key,
    required this.index,
    required this.model,
    required this.sets,
  });

  final int index;
  final AdvtModel model;

  final VoidCallback sets;
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 105,
      width: double.infinity,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(.05),
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Row(
        children: [
          PromotionImage(path: model.imageUrl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(model.title),
                Text(
                  model.onMainScreen ? "Home Screen" : "Detail Screen",
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                    decorationThickness: 3,
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebBrouser(url: model.link),
                        ));
                  },
                  splashColor: Colors.blue.shade300,
                  padding: const EdgeInsets.all(0),
                  minWidth: 1,
                  highlightColor: Colors.blue.shade300,
                  height: 12,
                  child: Text(
                    overflow: TextOverflow.ellipsis,
                    model.link,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Are you sure!!"),
                      content: const Text(
                          "Do you want to delete this promotion from application."),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            PromotionsStorage()
                                .removePromotion(
                                    id: model.id, imageUrl: model.imageUrl)
                                .then((value) {
                              if (context.mounted) {
                                sets();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Item removed"),
                                  ),
                                );
                              }
                            });
                            sets();
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
                },
                icon: const Icon(Icons.highlight_remove_rounded),
              ))
        ],
      ),
    );
  }
}

class PromotionImage extends StatefulWidget {
  const PromotionImage({
    super.key,
    required this.path,
  });

  final String path;

  @override
  State<PromotionImage> createState() => _PromotionImageState();
}

class _PromotionImageState extends State<PromotionImage> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          pressed = true;
        });
      },
      onTapUp: (details) {
        setState(() {
          pressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          pressed = false;
        });
      },
      onTap: () {
        showDialog(
          barrierDismissible: true,
          context: context,
          builder: (context) {
            return Dialog(
              elevation: 0,
              insetPadding: EdgeInsets.zero,
              child: SizedBox(
                width: 500,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: widget.path,
                  ),
                ),
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
        margin: const EdgeInsets.all(10),
        height: 95,
        width: 95,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: widget.path,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
