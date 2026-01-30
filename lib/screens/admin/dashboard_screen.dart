import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'add_edit_product_screen.dart';
import '../../models/product_model.dart';

import '../../services/database_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for modern look
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'إضافة منتج',
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddEditProductScreen())),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الإحصائيات',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildStatsRow(),
            const SizedBox(height: 20),
            const Text(
              'إدارة المنتجات',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildProductList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red, // Brand color
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

  Widget _buildDrawer(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userEmail = authProvider.user?.email ?? 'Admin';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.black87),
            accountName: const Text('Admin Panel'),
            accountEmail: Text(userEmail),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings,
                  color: Colors.black87, size: 30),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('الرئيسية'),
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('الطلبات'),
            onTap: () => Navigator.pushNamed(context, '/admin-orders'),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('الأعضاء'),
            onTap: () => Navigator.pushNamed(context, '/admin-users'),
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('إدارة البنرات'),
            onTap: () => Navigator.pushNamed(context, '/admin-banners'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text('إرسال إشعارات'),
            onTap: () => Navigator.pushNamed(context, '/admin-notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('التقارير والتحليلات'),
            onTap: () => Navigator.pushNamed(context, '/admin-analytics'),
          ),
          ListTile(
            leading: const Icon(Icons.percent),
            title: const Text('كوبونات الخصم'),
            onTap: () => Navigator.pushNamed(context, '/admin-coupons'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title:
                const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
            onTap: () {
              authProvider.signOut();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return SizedBox(
      height: 120, // Height for cards
      child: Row(
        children: [
          _buildStatCard(
            title: 'المنتجات',
            stream: _databaseService.products.map((list) => list.length),
            icon: Icons.inventory_2,
            color: Colors.blue,
          ),
          const SizedBox(width: 10),
          _buildStatCard(
            title: 'الطلبات',
            stream: _databaseService.allOrders.map((list) => list.length),
            icon: Icons.shopping_cart_checkout,
            color: Colors.orange,
          ),
          const SizedBox(width: 10),
          _buildStatCard(
            title: 'العملاء',
            stream: _databaseService.allUsers.map((list) => list.length),
            icon: Icons.people_alt,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required Stream<int> stream,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: StreamBuilder<int>(
        stream: stream,
        builder: (context, snapshot) {
          final count = snapshot.data ?? 0;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withAlpha(50)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 30),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                      color: color.withAlpha(200), fontWeight: FontWeight.bold),
                ),
                Text(
                  count.toString(),
                  style: TextStyle(
                      color: color, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductList() {
    return StreamBuilder<List<Product>>(
      stream: _databaseService.products,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('لا توجد منتجات'));
        }

        final products = snapshot.data!;
        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    image: product.imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(product.imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: product.imageUrl.isEmpty
                      ? const Icon(Icons.image, color: Colors.grey)
                      : null,
                ),
                title: Text(product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${product.price} ج.م'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddEditProductScreen(product: product),
                        ),
                      ),
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
    );
  }

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
                await _databaseService.deleteProduct(product.id);
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
