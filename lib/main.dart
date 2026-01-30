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
import 'screens/client/profile_screen.dart';

// import 'firebase_options.dart';
import 'services/database_service.dart';

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
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");

    try {
      // Initialize Supabase
      await SupabaseService.initialize();

      // Initialize Firebase (for Notifications)
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Set Background Handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Initialize Notification Service
      await NotificationService().initialize();

      // Test Connection (Optional)
      DatabaseService().testConnection();

      runApp(const MyApp());
    } catch (e, stack) {
      debugPrint("Error during app initialization: $e");
      debugPrint(stack.toString());
      // يمكن هنا تشغيل تطبيق بديل يعرض رسالة الخطأ
      runApp(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text(
                'حدث خطأ أثناء تشغيل التطبيق:\n$e',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
        ),
      );
    }
  }, (error, stack) {
    debugPrint("Uncaught error: $error");
    debugPrint(stack.toString());
  });
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
      home: StreamBuilder(
        // Removed <AuthState> to avoid type error
        stream: SupabaseService.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final session = SupabaseService.client.auth.currentSession;
          if (session != null) {
            // Check if admin email
            if (session.user.email == 'sameh.rabee007@gmail.com') {
              return const DashboardScreen();
            }
            // Otherwise go to home (client logged in)
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
        '/profile': (context) => const ProfileScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
