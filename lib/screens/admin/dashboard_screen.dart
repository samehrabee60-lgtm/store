import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../services/database_service.dart';
import 'add_edit_product_screen.dart';

class DashboardScreen extends StatelessWidget {
  // إضافة key المطلوب لتجنب أخطاء البناء
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // تعريف مرجع قاعدة البيانات بشكل صحيح
    final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child('products');

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم - Beta Lab'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const AddEditProductScreen())
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _databaseRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text('لا توجد منتجات لتعديلها'));
          }
          
          Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          List<dynamic> products = data.values.toList();
          
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(products[index]['name'] ?? ''),
                subtitle: Text('${products[index]['price']} ج.م'),
                trailing: const Icon(Icons.edit),
              );
            },
          );
        },
      ),
    );
  }
}
