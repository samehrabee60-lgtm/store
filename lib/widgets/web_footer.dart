import 'package:flutter/material.dart';

class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF212121),
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: About and Logo
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 60,
                      color:
                          Colors.white, // Assuming white logo version or tint
                      colorBlendMode: BlendMode.srcIn,
                      errorBuilder: (c, e, s) => const Text("BetaLab",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "متجرك الأول لكل المستلزمات الطبية والحلول المخبرية المتقدمة. جودة عالية وخدمة موثوقة.",
                      style: TextStyle(
                          color: Colors.white70,
                          height: 1.6,
                          fontFamily: 'Cairo'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),

              // Column 2: Quick Links
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("روابط سريعة",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo')),
                    const SizedBox(height: 20),
                    _FooterLink(text: "الرئيسية", onTap: () {}),
                    _FooterLink(text: "المتجر", onTap: () {}),
                    _FooterLink(text: "من نحن", onTap: () {}),
                    _FooterLink(text: "سياسة الخصوصية", onTap: () {}),
                  ],
                ),
              ),

              // Column 3: Contact
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("تواصل معنا",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo')),
                    const SizedBox(height: 20),
                    _ContactItem(icon: Icons.phone, text: "01018690407"),
                    _ContactItem(
                        icon: Icons.email, text: "sameh.rabee007@gmail.com"),
                    _ContactItem(
                        icon: Icons.location_on,
                        text: "5 شارع بستان الخشاب - القصر العيني"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white24),
          const SizedBox(height: 20),
          // Bottom Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("© 2024 BetaLab Store. جميع الحقوق محفوظة.",
                  style: TextStyle(color: Colors.white54, fontFamily: 'Cairo')),
              Row(
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.facebook, color: Colors.white54)),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.camera_alt,
                          color: Colors.white54)), // Instagram placeholder
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _FooterLink({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        child: Text(text,
            style: const TextStyle(color: Colors.white70, fontFamily: 'Cairo')),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFd92b2c), size: 18),
          const SizedBox(width: 10),
          Text(text,
              style:
                  const TextStyle(color: Colors.white70, fontFamily: 'Cairo')),
        ],
      ),
    );
  }
}
