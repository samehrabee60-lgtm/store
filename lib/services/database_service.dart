import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // 1. وظيفة مسح السلة بعد الشراء (المطلوبة في checkout_screen.dart)
  Future<void> clearCart(String userId) async {
    await _db.child('carts').child(userId).remove();
  }

  // 2. وظيفة جلب التقييمات (المطلوبة في product_details_screen.dart)
  Stream<DatabaseEvent> getReviews(String productId) {
    return _db.child('reviews').child(productId).onValue;
  }

  // 3. وظيفة إضافة تقييم جديد (المطلوبة في product_details_screen.dart)
  Future<void> addReview(String productId, Map<String, dynamic> reviewData) async {
    await _db.child('reviews').child(productId).push().set(reviewData);
  }

  // وظائف إضافية قد تحتاجها
  Stream<DatabaseEvent> get allProducts => _db.child('products').onValue;
}
