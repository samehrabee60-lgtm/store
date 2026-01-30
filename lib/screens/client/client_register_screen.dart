import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/web_footer.dart';

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

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        await authProvider
            .signUp(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
            )
            .timeout(const Duration(seconds: 90));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء الحساب بنجاح')),
          );
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'فشل التسجيل: $e';
          if (e.toString().contains('TimeoutException')) {
            errorMessage =
                'انتهت مهلة الاتصال. يرجى التحقق من الإنترنت والمحاولة مرة أخرى.';
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
    final isLoading = context.watch<AuthProvider>().isLoading;
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Left Side (Web Only)
          if (isWeb)
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo.png', height: 150),
                    const SizedBox(height: 30),
                    const Text(
                      'Beta Lab Group',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'انضم إلينا الآن',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Right Side: Register Form
          Expanded(
            flex: 1,
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!isWeb) ...[
                          Align(
                            alignment: Alignment.center,
                            child: Image.asset('assets/images/logo.png',
                                height: 80),
                          ),
                          const SizedBox(height: 30),
                        ],
                        const Text(
                          'إنشاء حساب جديد',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'يرجى ملء البيانات التالية للانضمام إلينا',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        _buildTextField(
                          controller: _nameController,
                          label: 'الاسم بالكامل',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'رقم الهاتف (+20...)',
                          icon: Icons.phone_android_outlined,
                          inputType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال رقم الهاتف';
                            }
                            if (!value.startsWith('+')) {
                              return 'يجب أن يبدأ بـ +';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _emailController,
                          label: 'البريد الإلكتروني',
                          icon: Icons.email_outlined,
                          inputType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _passwordController,
                          label: 'كلمة المرور',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'كلمة المرور قصيرة جداً';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    'تسجيل حساب',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('لديك حساب بالفعل؟'),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'تسجيل الدخول',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        if (isWeb) const WebFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.red),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      obscureText: isPassword,
      keyboardType: inputType,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
            return null;
          },
    );
  }
}
