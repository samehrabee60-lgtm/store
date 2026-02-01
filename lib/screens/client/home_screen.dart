import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../services/database_service.dart';
import '../../models/product_model.dart';
import '../../widgets/app_drawer.dart';
import 'product_details_screen.dart';
// import '../../widgets/web_layout_container.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/web_footer.dart';
import '../../widgets/product_card_web.dart';
import '../../services/supabase_service.dart';
import '../../models/cart_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategory;

  final List<String> imgList = const [
    'https://via.placeholder.com/800x400?text=Offer+1',
    'https://via.placeholder.com/800x400?text=Offer+2',
    'https://via.placeholder.com/800x400?text=Offer+3',
  ];

  final List<Map<String, dynamic>> categories = const [
    {
      'name': 'أجهزة',
      'icon': Icons.device_hub,
    },
    {
      'name': 'محاليل',
      'icon': Icons.science,
    },
    {
      'name': 'مستلزمات',
      'icon': Icons.medical_services,
    },
    {
      'name': 'أخرى',
      'icon': Icons.more_horiz,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Define Mobile App Bar
    final mobileAppBar = AppBar(
      title: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Image.asset('assets/images/logo.png', height: 40,
            errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.business, color: Colors.blue);
        }),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ],
    );

    return ResponsiveScaffold(
      mobileAppBar: mobileAppBar,
      mobileDrawer: const AppDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return _buildWebLayout();
          } else {
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  // --- Mobile Layout (Original) ---
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildSlider(),
          const SizedBox(height: 20),
          _buildProductsSectionTitle(),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: _buildCategoriesList(horizontal: true),
          ),
          _buildProductsList(horizontal: true),
        ],
      ),
    );
  }

  // --- Web Layout (Sidebar + Grid) ---
  Widget _buildWebLayout() {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Sidebar (Categories)
              SizedBox(
                width: 300,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildCategoriesSidebar(),
                  ),
                ),
              ),

              // Right Content (Slider + Products)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hero Section
                            _buildSlider(),
                            const SizedBox(height: 40),

                            // Products
                            _buildProductsSectionTitle(),
                            const SizedBox(height: 20),
                            SizedBox(
                              // Removed fixed height 800 to allow dynamic expansion
                              child: _buildProductsList(horizontal: false),
                            ),
                          ],
                        ),
                      ),
                      // Footer Spans Full Width (inside ScrollView, or specific layout)
                      const WebFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Components ---

  Widget _buildCategoriesSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFd92b2c), // Red Header
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: const Text(
              "الأقسام",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          // List (Dynamic Products)
          StreamBuilder<List<Product>>(
            stream: DatabaseService().products,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final products = snapshot.data ?? [];

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final catName = cat['name'] as String;

                  // Filter products for this category
                  final catProducts =
                      products.where((p) => p.category == catName).toList();

                  return Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading:
                          Icon(cat['icon'], color: const Color(0xFFd92b2c)),
                      title: Text(
                        catName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      textColor: const Color(0xFFd92b2c),
                      iconColor: const Color(0xFFd92b2c),
                      childrenPadding:
                          const EdgeInsets.only(right: 20, bottom: 10),
                      children: catProducts.isEmpty
                          ? [
                              const ListTile(
                                dense: true,
                                title: Text("لا توجد منتجات",
                                    style: TextStyle(color: Colors.grey)),
                              )
                            ]
                          : catProducts.map((product) {
                              return ListTile(
                                dense: true,
                                title: Text(
                                  product.name,
                                  style: TextStyle(color: Colors.grey[700]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                leading: const Icon(
                                  Icons.arrow_left,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                onTap: () {
                                  // Navigate to Product Details
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProductDetailsScreen(
                                              product: product),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // Helper _buildCategoryAccordionItem removed as it's integrated above

  Widget _buildSlider() {
    return StreamBuilder<List<String>>(
      stream: DatabaseService().banners,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 180,
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final banners = snapshot.data ?? [];

        if (banners.isEmpty) {
          // Show default local banner if no dynamic banners exist
          return Container(
            height: 180,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFd92b2c), Colors.red.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.storefront, color: Colors.white, size: 50),
                const SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "أهلاً بك في Beta Lab Store",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo', // Ensure font is used
                      ),
                    ),
                    Text(
                      "تسوق أفضل المنتجات الطبية والمخبرية",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return CarouselSlider(
          options: CarouselOptions(
            height: 180.0,
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            viewportFraction: 0.85,
          ),
          items: banners.map((item) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.network(
                      item,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image,
                            size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCategoriesList({required bool horizontal}) {
    // Add "All" logic implicitly by allowing deselection or checking _selectedCategory
    return ListView.builder(
      shrinkWrap: true,
      physics: horizontal
          ? const ScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      scrollDirection: horizontal ? Axis.horizontal : Axis.vertical,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final catName = categories[index]['name'];
        final isSelected = _selectedCategory == catName;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (_selectedCategory == catName) {
                  _selectedCategory = null; // Deselect to show all
                } else {
                  _selectedCategory = catName;
                }
              });
            },
            child: horizontal
                ? Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: isSelected
                            ? Colors.blue
                            : Colors.blue.withValues(alpha: 0.1),
                        child: Icon(categories[index]['icon'],
                            size: 28,
                            color: isSelected ? Colors.white : Colors.blue),
                      ),
                      const SizedBox(height: 5),
                      Text(catName,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                    ],
                  )
                : Container(
                    // Vertical List Item for Sidebar
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(categories[index]['icon'], color: Colors.blue),
                        const SizedBox(width: 12),
                        Text(catName,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildProductsSectionTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              _selectedCategory != null
                  ? 'نتائج $_selectedCategory'
                  : 'أحدث المنتجات',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (_selectedCategory == null)
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/products'),
              child: const Text('عرض الكل'),
            ),
          if (_selectedCategory != null)
            TextButton(
              onPressed: () => setState(() {
                _selectedCategory = null;
              }),
              child: const Text('عرض الكل'),
            ),
        ],
      ),
    );
  }

  Widget _buildProductsList({required bool horizontal}) {
    return StreamBuilder<List<Product>>(
      stream: DatabaseService().products,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('حدث خطأ: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('لا توجد منتجات متاحة حالياً'));
        }

        var productList = snapshot.data!;

        if (_selectedCategory != null) {
          productList = productList
              .where((p) => p.category == _selectedCategory)
              .toList();
        }

        if (productList.isEmpty) {
          return const Center(child: Text('لا توجد منتجات في هذا القسم'));
        }

        if (horizontal) {
          // Mobile: Horizontal List
          return SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: productList.length,
              itemBuilder: (context, index) =>
                  _buildProductCard(productList[index]),
            ),
          );
        } else {
          // Web: Grid View
          return GridView.builder(
            shrinkWrap: true, // Allow grid to take needed height
            padding: const EdgeInsets.all(0), // Padding handled by parent
            physics:
                const NeverScrollableScrollPhysics(), // Scroll handled by SingleChildScrollView
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250, // Responsive card width
              childAspectRatio: 0.7,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: productList.length,
            itemBuilder: (context, index) {
              final product = productList[index];
              // Use Web Card if on Desktop
              if (MediaQuery.of(context).size.width > 800) {
                return ProductCardWeb(
                  product: product,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailsScreen(product: product))),
                  onAddToCart: () {
                    DatabaseService().addToCart(
                        SupabaseService.client.auth.currentUser?.id ?? '',
                        CartItem(
                            productId: product.id,
                            productName: product.name,
                            price: product.price,
                            imageUrl: product.imageUrl,
                            quantity: 1));
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("تمت الإضافة للسلة")));
                  },
                );
              }
              return _buildProductCard(product);
            },
          );
        }
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductDetailsScreen(product: product)));
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.grey.withValues(alpha: 0.2), blurRadius: 5)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  image: DecorationImage(
                    image: (product.imageUrl.isNotEmpty)
                        ? NetworkImage(product.imageUrl) as ImageProvider
                        : const AssetImage('assets/images/placeholder.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${product.price} ج.م',
                      style: const TextStyle(color: Colors.blue)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
