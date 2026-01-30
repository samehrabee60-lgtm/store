import 'package:flutter/material.dart';
import '../../models/cart_model.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import 'checkout_screen.dart';
import '../../widgets/responsive_scaffold.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _couponController = TextEditingController();
  String? _appliedCouponCode;
  double _discountAmount = 0.0;
  String _discountType = ''; // 'percentage' or 'fixed'
  num _discountValue = 0;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon(double currentTotal) async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    final coupon = await DatabaseService().checkCoupon(code);
    if (coupon == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كود الخصم غير صالح أو منتهي الصلاحية')),
      );
      setState(() {
        _appliedCouponCode = null;
        _discountAmount = 0.0;
      });
      return;
    }

    setState(() {
      _appliedCouponCode = code;
      _discountType = coupon['discount_type'];
      _discountValue = coupon['value'];

      if (_discountType == 'percentage') {
        _discountAmount = currentTotal * (_discountValue / 100);
      } else {
        _discountAmount = _discountValue.toDouble();
      }

      // Ensure discount doesn't exceed total
      if (_discountAmount > currentTotal) {
        _discountAmount = currentTotal;
      }
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تطبيق الخصم: $_discountAmount ج.م')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    if (user == null) {
      return ResponsiveScaffold(
        mobileAppBar: AppBar(title: const Text('سلة الشراء')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('يرجى تسجيل الدخول لعرض سلة الشراء'),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/client-login');
                },
                child: const Text('تسجيل الدخول'),
              ),
            ],
          ),
        ),
      );
    }

    return ResponsiveScaffold(
      mobileAppBar: AppBar(title: const Text('سلة الشراء')),
      body: StreamBuilder<List<CartItem>>(
        stream: DatabaseService().getCart(user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'السلة فارغة',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final cartItems = snapshot.data!;
          final subtotal = cartItems.fold(
            0.0,
            (sum, item) => sum + (item.price * item.quantity),
          );

          // Recalculate discount if items changed (e.g. quantity update)
          // Simple logic: re-apply formula based on stored coupon values
          if (_appliedCouponCode != null) {
            if (_discountType == 'percentage') {
              _discountAmount = subtotal * (_discountValue / 100);
            } else {
              _discountAmount = _discountValue.toDouble();
            }
            if (_discountAmount > subtotal) _discountAmount = subtotal;
          } else {
            _discountAmount = 0.0;
          }

          final finalTotal = subtotal - _discountAmount;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: Image.network(
                          item.imageUrl.isNotEmpty
                              ? item.imageUrl
                              : 'https://via.placeholder.com/150',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image),
                        ),
                        title: Text(item.productName),
                        subtitle: Text(
                          '${item.price} ج.م  ×  ${item.quantity} = ${item.price * item.quantity} ج.م',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              onPressed: () {
                                DatabaseService().updateCartItemQuantity(
                                  user.id,
                                  item.productId,
                                  item.quantity - 1,
                                );
                              },
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              icon: const Icon(Icons.add_circle,
                                  color: Colors.green),
                              onPressed: () {
                                DatabaseService().updateCartItemQuantity(
                                  user.id,
                                  item.productId,
                                  item.quantity + 1,
                                );
                              },
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.grey),
                              onPressed: () {
                                DatabaseService().removeFromCart(
                                  user.id,
                                  item.productId,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, -2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Coupon Section
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _couponController,
                            decoration: InputDecoration(
                              labelText: 'كود الخصم',
                              border: const OutlineInputBorder(),
                              suffixIcon: _appliedCouponCode != null
                                  ? IconButton(
                                      icon: const Icon(Icons.cancel,
                                          color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _appliedCouponCode = null;
                                          _discountAmount = 0.0;
                                          _couponController.clear();
                                        });
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => _applyCoupon(subtotal),
                          child: const Text('تطبيق'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Totals
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('المجموع الفرعي:',
                            style: TextStyle(fontSize: 16)),
                        Text('$subtotal ج.م',
                            style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    if (_discountAmount > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الخصم:',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.green)),
                          Text('-${_discountAmount.toStringAsFixed(2)} ج.م',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.green)),
                        ],
                      ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'الإجمالي:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${finalTotal.toStringAsFixed(2)} ج.م',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutScreen(
                                totalAmount:
                                    finalTotal, // Send discounted total
                                cartItems: cartItems,
                                couponCode: _appliedCouponCode,
                                discountAmount: _discountAmount,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'إتمام الشراء',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
