import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'models.dart';

FirebaseFirestore store = FirebaseFirestore.instance;
CollectionReference<dynamic> advtCollection = store.collection('promotions');

class PromotionsStorage {
  PromotionsStorage() {
    log("Performing operation on Promotions ");
  }
  Future<void> storePromotion(AdvtModel model) async {
    await advtCollection.doc(model.id).set(model.toMap());
  }

  Future<List<AdvtModel>> getPromotions() async {
    List<AdvtModel> data = [];
    QuerySnapshot<dynamic> d = await advtCollection.orderBy('id').get();

    for (var e in d.docs) {
      data.add(AdvtModel.fromMap(e.data() as Map<String, dynamic>));
    }

    return data;
  }

  Future<void> removePromotion({required String id, required String imageUrl}) async {
    await advtCollection.doc(id).delete();
    await FirebaseStorage.instance.refFromURL(imageUrl).delete();
  }
}
