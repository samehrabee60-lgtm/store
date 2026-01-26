import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_core/firebase_core.dart';

import 'add_edit_product_screen.dart';
import '../../models/product_model.dart';
import '../../services/database_service.dart';

class DashboardScreen extends StatelessWidget {
  // إضافة key المطلوب لتجنب أخطاء البناء
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم - Beta Lab'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.pushNamed(context, '/home'),
            tooltip: 'الرئيسية',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddEditProductScreen())),
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: DatabaseService().products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد منتجات لتعديلها'));
          }

          final products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    backgroundImage: product.imageUrl.isNotEmpty
                        ? NetworkImage(product.imageUrl)
                        : null,
                    child: product.imageUrl.isEmpty
                        ? const Icon(Icons.shopping_bag, color: Colors.grey)
                        : null,
                  ),
                  title: Text(product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${product.price} ج.م - ${product.category}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddEditProductScreen(product: product),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, product),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddEditProductScreen()),
          );
        },
        tooltip: 'إضافة منتج جديد',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // دالة للتأكد من رغبة المستخدم في الحذف
  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من رغبتك في حذف "${product.name}"؟'),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await DatabaseService().deleteProduct(product.id);
                if (context.mounted) Navigator.of(context).pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف المنتج بنجاح')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
