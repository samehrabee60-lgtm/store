import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ClientRegisterScreen extends StatefulWidget {
  const ClientRegisterScreen({super.key});

  @override
  State<ClientRegisterScreen> createState() => _ClientRegisterScreenState();
}

class _ClientRegisterScreenState extends State<ClientRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // String? _verificationId; // Removed
  // --- الإصلاح هنا: تعريف متغير حالة التحميل ---
  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await AuthService().registerUser(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        ).timeout(const Duration(seconds: 90));

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء الحساب بنجاح')),
          );
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          String errorMessage = 'فشل التسجيل: $e';
          if (e.toString().contains('TimeoutException')) {
            errorMessage = 'انتهت مهلة الاتصال. يرجى التحقق من الإنترنت والمحاولة مرة أخرى.';
          }
          // Friendly error for existing user
          if (e.toString().contains('User already registered')) {
            errorMessage = 'هذا البريد الإلكتروني مسجل بالفعل';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    }
  }

  // _showOtpDialog and _completeRegistration removed as per user request to skip phone verification

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Image.asset('assets/images/logo.png', height: 40),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'بيانات العميل',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'الاسم بالكامل',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'الرجاء إدخال الاسم'
                      : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف (مثل +2010xxxxxxxx)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                    hintText: '+201xxxxxxxxx',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم الهاتف';
                    }
                    if (!value.startsWith('+')) {
                      return 'يجب أن يبدأ الرقم بـ + (كود الدولة)';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || value.isEmpty
                      ? 'الرجاء إدخال البريد الإلكتروني'
                      : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال كلمة المرور';
                    }
                    if (value.length < 6) {
                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text('تحقق وإنشاء حساب'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
