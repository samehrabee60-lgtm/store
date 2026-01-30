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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('لوحة التحكم',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              child: const Icon(Icons.add, color: Colors.red),
            ),
            tooltip: 'إضافة منتج',
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddEditProductScreen())),
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Section
            _buildSectionTitle('نظرة عامة'),
            const SizedBox(height: 10),
            _buildStatsRow(),

            const SizedBox(height: 25),

            // Quick Actions Section
            _buildSectionTitle('الوصول السريع'),
            const SizedBox(height: 10),
            _buildQuickActionsGrid(context),

            const SizedBox(height: 25),

            // Products Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('أحدث المنتجات'),
                TextButton(
                  onPressed: () {
                    // Navigate to a full product list screen if implemented,
                    // or just scroll down. For now, it stays here.
                  },
                  child: const Text('عرض الكل'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildProductList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userEmail = authProvider.user?.email ?? 'Admin';

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: const Text('لوحة المشرف',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                userEmail.isNotEmpty ? userEmail[0].toUpperCase() : 'A',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(context, Icons.dashboard, 'الرئيسية',
                    onTap: () => Navigator.pop(context), selected: true),
                _buildDrawerItem(context, Icons.shopping_cart, 'الطلبات',
                    onTap: () => Navigator.pushNamed(context, '/admin-orders')),
                _buildDrawerItem(context, Icons.people, 'العملاء',
                    onTap: () => Navigator.pushNamed(context, '/admin-users')),
                const Divider(),
                _buildDrawerItem(context, Icons.analytics, 'التقارير',
                    onTap: () =>
                        Navigator.pushNamed(context, '/admin-analytics')),
                _buildDrawerItem(context, Icons.local_offer, 'الكوبونات',
                    onTap: () =>
                        Navigator.pushNamed(context, '/admin-coupons')),
                _buildDrawerItem(context, Icons.campaign, 'الإشعارات',
                    onTap: () =>
                        Navigator.pushNamed(context, '/admin-notifications')),
                _buildDrawerItem(context, Icons.view_carousel, 'البنرات',
                    onTap: () =>
                        Navigator.pushNamed(context, '/admin-banners')),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('تسجيل الخروج',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              authProvider.signOut();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (route) => false);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title,
      {required VoidCallback onTap, bool selected = false}) {
    return ListTile(
      leading: Icon(icon, color: selected ? Colors.red : Colors.grey[700]),
      title: Text(title,
          style: TextStyle(
              color: selected ? Colors.red : Colors.black87,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      selected: selected,
      selectedTileColor: Colors.red.withValues(alpha: 0.05),
      onTap: onTap,
    );
  }

  Widget _buildStatsRow() {
    return SizedBox(
      height: 110,
      child: Row(
        children: [
          _buildStatCard(
            title: 'إجمالي الطلبات',
            stream: _databaseService.allOrders.map((list) => list.length),
            icon: Icons.shopping_bag,
            color: Colors.orange,
            context: context,
            onTap: () => Navigator.pushNamed(context, '/admin-orders'),
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            title: 'المنتجات',
            stream: _databaseService.products.map((list) => list.length),
            icon: Icons.inventory,
            color: Colors.blue,
            context: context,
            onTap: () {}, // Already on products screen basically
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            title: 'المستخدمين',
            stream: _databaseService.allUsers.map((list) => list.length),
            icon: Icons.group,
            color: Colors.green,
            context: context,
            onTap: () => Navigator.pushNamed(context, '/admin-users'),
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
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: StreamBuilder<int>(
            stream: stream,
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const Spacer(),
                  Text(count.toString(),
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(title,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      {
        'icon': Icons.analytics,
        'label': 'التحليلات',
        'route': '/admin-analytics',
        'color': Colors.purple
      },
      {
        'icon': Icons.local_offer,
        'label': 'الكوبونات',
        'route': '/admin-coupons',
        'color': Colors.teal
      },
      {
        'icon': Icons.view_carousel,
        'label': 'البنرات',
        'route': '/admin-banners',
        'color': Colors.pink
      },
      {
        'icon': Icons.notifications,
        'label': 'الإشعارات',
        'route': '/admin-notifications',
        'color': Colors.amber
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildQuickActionCard(
          context,
          icon: action['icon'] as IconData,
          label: action['label'] as String,
          route: action['route'] as String,
          color: action['color'] as Color,
        );
      },
    );
  }

  Widget _buildQuickActionCard(BuildContext context,
      {required IconData icon,
      required String label,
      required String route,
      required Color color}) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
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
          return const Center(
              child:
                  Text('لا توجد منتجات', style: TextStyle(color: Colors.grey)));
        }

        final products = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[100],
                    child: product.imageUrl.isNotEmpty
                        ? Image.network(product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image))
                        : const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
                title: Text(product.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text('${product.price} ج.م',
                    style: const TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  AddEditProductScreen(product: product))),
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
      builder: (ctx) => AlertDialog(
        title: const Text('حذف المنتج'),
        content: Text('هل أنت متأكد من حذف ${product.name}؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog first
              await _databaseService.deleteProduct(product.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف المنتج')));
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
