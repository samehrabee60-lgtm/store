import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/product_model.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../models/review_model.dart';
import '../../models/cart_model.dart';
import '../../widgets/web_footer.dart';
import '../../widgets/responsive_scaffold.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  Future<void> _launchWhatsApp() async {
    try {
      String phoneNumber = '01018690407';
      phoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      if (phoneNumber.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('رقم الواتساب غير متوفر حالياً')),
          );
        }
        return;
      }

      final Uri whatsappUrl = Uri.parse('whatsapp://send?phone=$phoneNumber');
      final Uri webUrl = Uri.parse('https://wa.me/$phoneNumber');

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      } else if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لا يمكن فتح واتساب')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    }
  }

  void _showAddReviewModelDialog(BuildContext context) {
    final commentController = TextEditingController();
    double rating = 5.0;

    final user = AuthService().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يجب تسجيل الدخول لإضافة تقييم')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('إضافة تقييم'),
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
                    decoration: const InputDecoration(
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
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (commentController.text.isNotEmpty) {
                      Navigator.pop(context);
                      Map<String, dynamic>? userData =
                          await DatabaseService().getUserData(user.id);
                      String userName = userData?['name'] ?? 'مستخدم';

                      final review = ReviewModel(
                        id: '',
                        userId: user.id,
                        userName: userName,
                        rating: rating,
                        comment: commentController.text,
                        createdAt: DateTime.now(),
                      );

                      await DatabaseService()
                          .addReview(widget.product.id, review);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم نشر تقييمك')));
                      }
                    }
                  },
                  child: const Text('نشر'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      mobileAppBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // عرض صورة المنتج
            CachedNetworkImage(
              imageUrl: widget.product.imageUrl,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.image_not_supported, size: 100),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.product.price} ج.م',
                    style: const TextStyle(fontSize: 20, color: Colors.blue),
                  ),
                  const Divider(),
                  const Text(
                    'الوصف',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.product.description,
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _launchWhatsApp,
                      icon: const Icon(Icons.chat),
                      label: const Text('طلب عبر واتساب'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final user = AuthService().currentUser;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
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
                          user.id,
                          CartItem(
                            productId: widget.product.id,
                            productName: widget.product.name,
                            price: widget.product.price,
                            imageUrl: widget.product.imageUrl,
                            quantity: 1,
                          ),
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تمت الإضافة للسلة'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('أضف للسلة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 2),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'المراجعات',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<List<ReviewModel>>(
                    stream: DatabaseService().getReviews(widget.product.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Column(
                          children: [
                            const Text('لا تتوفر مراجعات بعد لهذا المنتج'),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () =>
                                  _showAddReviewModelDialog(context),
                              child: const Text('كن أول من يقيم'),
                            ),
                          ],
                        );
                      }

                      final reviews = snapshot.data!;
                      return Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reviews.length,
                            itemBuilder: (context, index) {
                              final rev = reviews[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(rev.userName.isNotEmpty
                                      ? rev.userName[0].toUpperCase()
                                      : '?'),
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
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => _showAddReviewModelDialog(context),
                            child: const Text('أضف تقييمك'),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            if (MediaQuery.of(context).size.width > 800) const WebFooter(),
          ],
        ),
      ),
    );
  }
}
