import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/items.dart';

class ItemsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateItemData(Items item) async {
    try {
      await _firestore
          .collection('sellers')
          .doc(item.sellersUID)
          .collection('menus')
          .doc(item.menuID)
          .collection('items')
          .doc(item.productsID)
          .update({
        'productTitle': item.productTitle,
        'productDescription': item.productDescription,
        'productPrice': item.productPrice,
        'productQuantity': item.productQuantity,
        'thumbnailUrl': item.thumbnailUrl, // Include thumbnailUrl field
      });
    } catch (e) {
      print('Error updating item data: $e');
      // Handle error
    }
  }
}
