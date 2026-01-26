import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../services/database_service.dart'; 
import '../../models/product_model.dart';
import '../../widgets/app_drawer.dart';
import 'product_details_screen.dart';
import '../../widgets/web_layout_container.dart';

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
    {'name': 'أجهزة', 'icon': Icons.device_hub},
    {'name': 'محاليل', 'icon': Icons.science},
    {'name': 'مستلزمات', 'icon': Icons.medical_services},
    {'name': 'أخرى', 'icon': Icons.more_horiz},
  ];

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Image.asset('assets/images/logo.png', height: 40,
              errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.business,
                color: Colors.blue); 
          }),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: WebLayoutContainer(
        child: isWeb ? _buildWebLayout() : _buildMobileLayout(),
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
          _buildCategoriesList(horizontal: true),
          _buildProductsSectionTitle(),
          _buildProductsList(horizontal: true),
        ],
      ),
    );
  }

  // --- Web Layout (Sidebar + Grid) ---
  Widget _buildWebLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Sidebar (Categories)
        Container(
          width: 250,
          color: Colors.white,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('الفئات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const Divider(),
              Expanded(child: _buildCategoriesList(horizontal: false)),
            ],
          ),
        ),
        // Right Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSlider(),
                const SizedBox(height: 20),
                _buildProductsSectionTitle(),
                // Use Grid for Web
                SizedBox(
                  height: 600, // Fixed height or calculate
                  child: _buildProductsList(horizontal: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Components ---

  Widget _buildSlider() {
    return StreamBuilder<List<Product>>(
        stream: DatabaseService().products,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
             return CarouselSlider(
              options: CarouselOptions(
                height: 180.0,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                viewportFraction: 0.85,
              ),
              items: imgList.map((item) => Container(
                        margin: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          image: DecorationImage(image: NetworkImage(item), fit: BoxFit.cover),
                        ),
                      )).toList(),
            );
          }
           final products = snapshot.data!;
           // Show last 5 products (assuming new ones are at the end or just random)
           // If we are filtering, maybe we don't want to filter the SLIDER?
           // The slider usually shows "Hot Deals" or "Latest". Let's keep it as latest regardless of filter for now.
           final latestProducts = products.reversed.take(5).toList();
           
           if (latestProducts.isEmpty) {
              return const SizedBox(); // Hide slider if no products?
           }

           return CarouselSlider(
             options: CarouselOptions(
               height: 180.0,
               autoPlay: true,
               enlargeCenterPage: true,
               aspectRatio: 16 / 9,
               viewportFraction: 0.85,
             ),
             items: latestProducts.map((product) {
               return Builder(
                 builder: (BuildContext context) {
                   return GestureDetector(
                     onTap: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)));
                     },
                     child: Container(
                         width: MediaQuery.of(context).size.width,
                         margin: const EdgeInsets.symmetric(horizontal: 5.0),
                         decoration: BoxDecoration(
                           color: Colors.grey[200],
                           borderRadius: BorderRadius.circular(15.0),
                         ),
                         child: Stack(
                           children: [
                             ClipRRect(
                               borderRadius: BorderRadius.circular(15.0),
                               child: product.imageUrl.isNotEmpty
                                   ? Image.network(product.imageUrl, fit: BoxFit.cover, width: double.infinity, height: double.infinity, errorBuilder: (c,e,s) => const Icon(Icons.error))
                                   : const Icon(Icons.image, size: 50),
                             ),
                             Positioned(
                               bottom: 0, left: 0, right: 0,
                               child: Container(
                                 decoration: BoxDecoration(
                                   borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                                   gradient: LinearGradient(colors: [Colors.black.withOpacity(0.7), Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                                 ),
                                 padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                 child: Text(product.name, style: const TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold)),
                               ),
                             ),
                           ],
                         )),
                   );
                 },
               );
             }).toList(),
           );
        }
    );
  }

  Widget _buildCategoriesList({required bool horizontal}) {
    // Add "All" logic implicitly by allowing deselection or checking _selectedCategory
    return ListView.builder(
      shrinkWrap: true,
      physics: horizontal ? const ScrollPhysics() : const NeverScrollableScrollPhysics(),
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
                    backgroundColor: isSelected ? Colors.blue : Colors.blue.withOpacity(0.1),
                    child: Icon(categories[index]['icon'],
                        size: 28, color: isSelected ? Colors.white : Colors.blue),
                  ),
                  const SizedBox(height: 5),
                  Text(catName, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                ],
              )
            : Container( // Vertical List Item for Sidebar
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                    children: [
                        Icon(categories[index]['icon'], color: Colors.blue),
                        const SizedBox(width: 12),
                        Text(catName, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
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
            Text(_selectedCategory != null ? 'نتائج $_selectedCategory' : 'أحدث المنتجات',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (_selectedCategory == null)
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/products'),
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
        if (snapshot.hasError) return Center(child: Text('حدث خطأ: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('لا توجد منتجات متاحة حالياً'));

        var productList = snapshot.data!;
        
        // --- FILTERING LOGIC ---
        if (_selectedCategory != null) {
            productList = productList.where((p) => p.category == _selectedCategory).toList();
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
                itemBuilder: (context, index) => _buildProductCard(productList[index]),
              ),
            );
        } else {
            // Web: Grid View
            return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 columns for web
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                ),
                itemCount: productList.length,
                itemBuilder: (context, index) => _buildProductCard(productList[index]),
            );
        }
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product)));
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
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
                  Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${product.price} ج.م', style: const TextStyle(color: Colors.blue)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
