import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class WebAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WebAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
      child: Row(
        children: [
          // Logo
          InkWell(
            onTap: () => Navigator.pushNamed(context, '/home'),
            child: Image.asset(
              'assets/images/logo.png',
              height: 50,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.store, size: 40, color: Color(0xFFd92b2c)),
            ),
          ),
          const SizedBox(width: 40),

          // Categories Menu (Optional Dropdown could go here)
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.menu, color: Colors.black87),
            label: const Text("كل الفئات",
                style: TextStyle(color: Colors.black87, fontFamily: 'Cairo')),
          ),
          const SizedBox(width: 20),

          // Search Bar
          Expanded(
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          Navigator.pushNamed(context, '/products',
                              arguments: {'search': value.trim()});
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: "ابحث عن منتجات...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 30),

          // Navigation Links
          _NavButton(title: "الرئيسية", route: "/home"),
          _NavButton(title: "المتجر", route: "/products"),
          _NavButton(title: "من نحن", route: "/about"),

          const SizedBox(width: 20),
          // Divider
          Container(height: 30, width: 1, color: Colors.grey[300]),
          const SizedBox(width: 20),

          // Actions
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () => Navigator.pushNamed(context, '/wishlist'),
            tooltip: "المفضلة",
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            tooltip: "السلة",
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              if (auth.user != null) {
                Navigator.pushNamed(context, '/profile');
              } else {
                Navigator.pushNamed(context, '/client-login');
              }
            },
            tooltip: "حسابي",
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String title;
  final String route;

  const _NavButton({required this.title, required this.route});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, route),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
