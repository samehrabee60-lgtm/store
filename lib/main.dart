import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';
import 'services/supabase_service.dart';
import 'screens/client/home_screen.dart';
import 'screens/client/products_screen.dart';
import 'screens/client/about_screen.dart';
import 'screens/admin/login_screen.dart';
import 'screens/admin/dashboard_screen.dart';
import 'screens/admin/edit_company_info_screen.dart';
import 'screens/client/client_login_screen.dart';
import 'screens/client/client_register_screen.dart';
import 'screens/client/cart_screen.dart';
import 'screens/client/wishlist_screen.dart';
import 'screens/client/my_orders_screen.dart';
import 'screens/admin/admin_orders_screen.dart';
import 'screens/admin/admin_users_screen.dart';
import 'screens/admin/admin_banners_screen.dart';
import 'screens/admin/admin_notifications_screen.dart';
import 'screens/admin/admin_analytics_screen.dart';
import 'screens/admin/admin_coupons_screen.dart';
import 'screens/client/profile_screen.dart';

// import 'firebase_options.dart';
import 'services/database_service.dart';

import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
  // You can process the message here, e.g., show a local notification
  NotificationService().showNotification(
    id: message.hashCode,
    title: message.notification?.title ?? 'New Notification',
    body: message.notification?.body ?? 'You have a new message.',
    payload: message.data['route'],
  );
}

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      try {
        await dotenv.load(fileName: ".env");
      } catch (e) {
        debugPrint(
          "Note: .env file not found. Using defaults/environment variables.",
        );
      }

      bool isSupabaseInitialized = false;
      String? initError;

      // Initialize Supabase
      try {
        await SupabaseService.initialize();
        isSupabaseInitialized = true;
      } catch (e) {
        debugPrint("🛑 Supabase initialization failed: $e");
        initError = "Supabase init failed: $e";
      }

      // Initialize Firebase (for Notifications)
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler,
        );
        await NotificationService().initialize();
      } catch (e) {
        debugPrint(
          "⚠️ Warning: Firebase initialization failed. Notifications will not work.\nError: $e",
        );
      }

      // Test Connection (Optional)
      try {
        if (isSupabaseInitialized) {
          DatabaseService().testConnection();
        }
      } catch (e) {
        debugPrint("⚠️ Warning: Database connection test failed: $e");
      }

      if (!isSupabaseInitialized) {
        runApp(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text(
                  'فشل تشغيل التطبيق (قاعدة البيانات):\n$initError',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: Colors.red, fontSize: 18),
                ),
              ),
            ),
          ),
        );
        return;
      }

      runApp(
        MultiProvider(
          providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
          child: const MyApp(),
        ),
      );
    },
    (error, stack) {
      debugPrint("Uncaught error: $error");
      debugPrint(stack.toString());
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Betalab Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: const Color(0xFFd92b2c),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFd92b2c),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.red,
          accentColor: const Color(0xFF212121),
        ),
        useMaterial3: true,
        fontFamily: 'Cairo',
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (auth.user != null) {
            // Check Role using AuthProvider logic
            if (auth.isAdmin) {
              return const DashboardScreen();
            }
            // Client logged in
            return const HomeScreen();
          }

          // Not logged in
          return const HomeScreen();
        },
      ),
      routes: {
        '/products': (context) => const ProductsScreen(),
        '/about': (context) => const AboutScreen(),
        '/admin-login': (context) => LoginScreen(),
        '/admin-dashboard': (context) => const DashboardScreen(),
        '/edit-company-info': (context) => const EditCompanyInfoScreen(),
        '/client-login': (context) => ClientLoginScreen(),
        '/client-register': (context) => ClientRegisterScreen(),
        '/cart': (context) => const CartScreen(),
        '/wishlist': (context) => const WishlistScreen(),
        '/orders': (context) => MyOrdersScreen(),
        '/admin-orders': (context) => const AdminOrdersScreen(),
        '/admin-users': (context) => const AdminUsersScreen(),
        '/admin-banners': (context) => const AdminBannersScreen(),
        '/admin-notifications': (context) => const AdminNotificationsScreen(),
        '/admin-analytics': (context) => const AdminAnalyticsScreen(),
        '/admin-coupons': (context) => const AdminCouponsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
