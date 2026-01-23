import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/product_model.dart'; // تأكد من صحة المسار
import '../../services/database_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

<<<<<<< HEAD
  const ProductDetailsScreen({super.key, required this.product});
=======
  const ProductDetailsScreen({super.key, required this.product});
>>>>>>> df094a09f831d15687de47dc41bd9a53678acd36

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // عرض صورة المنتج
            Image.network(
              widget.product.imageUrl,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported, size: 100),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.product.price} ج.م',
                    style: const TextStyle(fontSize: 20, color: Colors.blue),
                  ),
                  const Divider(),
                  const Text(
                    'التقييمات والمراجعات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
<<<<<<< HEAD
                  Text(product.description, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _launchWhatsApp,
                      icon: Icon(Icons.chat),
                      label: Text('طلب عبر واتساب'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final user = AuthService().currentUser;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'يرجى تسجيل الدخول لإضافة للمنتجات للسلة',
                              ),
                              action: SnackBarAction(
                                label: 'دخول',
                                onPressed: () {
                                  Navigator.pushNamed(context, '/client-login');
                                },
                              ),
                            ),
                          );
                          return;
                        }

                        // Add to cart
                        await DatabaseService().addToCart(
                          user.uid,
                          CartItem(
                            productId: product.id,
                            productName: product.name,
                            price: product.price,
                            imageUrl: product.imageUrl,
                            quantity: 1,
                          ),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تمت الإضافة للسلة'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: Icon(Icons.add_shopping_cart),
                      label: Text('أضف للسلة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(thickness: 2),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المراجعات',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  StreamBuilder<List<ReviewModel>>(
                    stream: DatabaseService().getReviews(product.id),
                    builder: (context, snapshot) {
=======
                  
                  // إصلاح استدعاء getReviews (الذي سبب خطأ البناء)
                  StreamBuilder(
                    stream: DatabaseService().getReviews(widget.product.id),
                    builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
>>>>>>> df094a09f831d15687de47dc41bd9a53678acd36
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
<<<<<<< HEAD
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Column(
                          children: [
                            Text('لا تتوفر مراجعات بعد لهذا المنتج'),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () =>
                                  _showAddReviewModelDialog(context),
                              child: Text('كن أول من يقيم'),
                            ),
                          ],
                        );
                      }

                      final reviews = snapshot.data!;
                      // Calculate averages visually here or rely on stored updated stats
                      // Simple list display:
                      return Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: reviews.length,
                            itemBuilder: (context, index) {
                              final rev = reviews[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(rev.userName[0].toUpperCase()),
                                ),
                                title: Text(rev.userName),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: List.generate(
                                        5,
                                        (i) => Icon(
                                          i < rev.rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          size: 16,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ),
                                    Text(rev.comment),
                                  ],
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => _showAddReviewModelDialog(context),
                            child: Text('أضف تقييمك'),
                          ),
                        ],
=======
                      
                      if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text('لا توجد تقييمات لهذا المنتج بعد.'),
                        );
                      }

                      Map<dynamic, dynamic> reviews = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          var review = reviews.values.elementAt(index);
                          return ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(review['comment'] ?? ''),
                            subtitle: Text('التقييم: ${review['rating']}'),
                          );
                        },
>>>>>>> df094a09f831d15687de47dc41bd9a53678acd36
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // حقل إضافة تقييم جديد
                  TextField(
                    controller: _reviewController,
                    decoration: const InputDecoration(
                      labelText: 'أضف تعليقك...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_reviewController.text.isNotEmpty) {
                        // إصلاح استدعاء addReview (الذي سبب خطأ البناء)
                        await DatabaseService().addReview(widget.product.id, {
                          'comment': _reviewController.text,
                          'rating': 5, // افتراضي مؤقتاً
                          'date': DateTime.now().toIso8601String(),
                        });
                        _reviewController.clear();
                      }
                    },
                    child: const Text('إرسال التقييم'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD

  void _showAddReviewModelDialog(BuildContext context) {
    final commentController = TextEditingController();
    double rating = 5.0;

    final user = AuthService().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('يجب تسجيل الدخول لإضافة تقييم')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('إضافة تقييم'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 30,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      labelText: 'تعليقك',
                      hintText: 'اكتب رأيك هنا...',
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (commentController.text.isNotEmpty) {
                      Navigator.pop(context);
                      // Fetch user name fresh or use placeholder needed
                      Map<String, dynamic>? userData =
                          await DatabaseService().getUserData(user.uid);
                      String userName = userData?['name'] ?? 'مستخدم';

                      final review = ReviewModel(
                        id: '', // Generated by Firestore doesn't matter for add, or we rely on .add()
                        userId: user.uid,
                        userName: userName,
                        rating: rating,
                        comment: commentController.text,
                        createdAt: DateTime.now(),
                      );

                      await DatabaseService().addReview(product.id, review);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('تم نشر تقييمك')));
                    }
                  },
                  child: Text('نشر'),
                ),
              ],
            );
          },
        );
      },
    );
  }
=======
>>>>>>> df094a09f831d15687de47dc41bd9a53678acd36
}
