import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shop_model.dart';

class ShopRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tạo Shop mới
  Future<void> createShop(ShopModel shop) async {
    await _firestore.collection('shops').doc(shop.uid).set(shop.toJson());
  }

  // Lấy thông tin Shop (Dùng cho sau này vào Dashboard)
  Future<ShopModel?> getShop(String uid) async {
    var doc = await _firestore.collection('shops').doc(uid).get();
    if (doc.exists) {
      return ShopModel.fromJson(doc.data()!, doc.id);
    }
    return null;
  }
}