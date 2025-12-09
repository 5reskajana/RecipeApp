import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesService {
  final CollectionReference favorites = FirebaseFirestore.instance.collection(
    'favorites',
  );

  Future<void> addFavorite(String mealId, String mealTitle, String imageUrl) {
    return favorites.doc(mealId).set({
      'id': mealId,

      'title': mealTitle,

      'image': imageUrl,
    });
  }

  Future<void> removeFavorite(String mealId) {
    return favorites.doc(mealId).delete();
  }

  Stream<QuerySnapshot> getFavorites() {
    return favorites.snapshots();
  }

  Stream<DocumentSnapshot<Object?>> isFavoriteStream(String mealId) {
    return favorites.doc(mealId).snapshots();
  }
}
