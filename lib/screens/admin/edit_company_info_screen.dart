import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/database_service.dart';

class EditCompanyInfoScreen extends StatefulWidget {
  const EditCompanyInfoScreen({super.key});

  @override
  State<EditCompanyInfoScreen> createState() => _EditCompanyInfoScreenState();
}

class _EditCompanyInfoScreenState extends State<EditCompanyInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final data = await DatabaseService().getCompanyInfo();
    if (data != null) {
      _aboutController.text = data['about'] ?? '';
      _facebookController.text = data['facebook'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _emailController.text = data['email'] ?? '';
      _addressController.text = data['address'] ?? '';
    } else {
      // Defaults
      _facebookController.text = 'https://www.facebook.com/BetaLabGroup1';
      _phoneController.text = '01018690407';
      _emailController.text = 'sameh.rabee007@gmail.com';
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await DatabaseService().updateCompanyInfo({
        'about': _aboutController.text,
        'facebook': _facebookController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'address': _addressController.text,
      });

      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('تم الحفظ بنجاح')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تعديل معلومات الشركة')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _aboutController,
                      decoration: InputDecoration(
                        labelText: 'نبذة عن الشركة',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _facebookController,
                      decoration: InputDecoration(
                        labelText: 'رابط فيسبوك',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.facebook),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'رقم الهاتف',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
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
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'العنوان',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveData,
                        child: Text('حفظ التعديلات'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
