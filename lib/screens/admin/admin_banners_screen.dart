import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/database_service.dart';
import '../../services/storage_service.dart';

class AdminBannersScreen extends StatefulWidget {
  const AdminBannersScreen({super.key});

  @override
  State<AdminBannersScreen> createState() => _AdminBannersScreenState();
}

class _AdminBannersScreenState extends State<AdminBannersScreen> {
  final TextEditingController _urlController = TextEditingController();
  final DatabaseService _db = DatabaseService();

  XFile? _pickedImage;
  bool _isUploading = false;

  Future<void> _pickImage(StateSetter setDialogState) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setDialogState(() {
        _pickedImage = image;
      });
    }
  }

  void _addBanner() async {
    // If no image and no text, return
    if (_pickedImage == null && _urlController.text.isEmpty) return;

    setState(() {
      _isUploading = true;
    });
    // Close dialog immediately or keep it open?
    // Usually close and show loading, or show loading in dialog.
    // Let's close dialog and show global loading overlay or just non-blocking since we have separate screen state.
    // Actually, keeping dialog open with spinner is better for feedback.
    // But `_addBanner` is called from dialog.

    // We'll handle loading inside the dialog button logic if possible,
    // but here we are in main widget state.
    // Let's modify the flow: _uploadAndSave called from dialog.
  }

  Future<void> _uploadAndAdd(StateSetter setDialogState) async {
    if (_pickedImage == null && _urlController.text.trim().isEmpty) return;

    setDialogState(() => _isUploading = true);

    try {
      String finalUrl = _urlController.text.trim();

      if (_pickedImage != null) {
        final url = await StorageService().uploadImage(_pickedImage!);
        if (url != null) {
          finalUrl = url;
        } else {
          throw 'فشل رفع الصورة';
        }
      }

      if (finalUrl.isNotEmpty) {
        await _db.addBanner(finalUrl);
        _urlController.clear();
        _pickedImage = null;
        if (mounted) {
          Navigator.pop(context); // Close dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إضافة البانر بنجاح')),
          );
        }
      }
    } catch (e) {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    } finally {
      if (mounted) {
        setDialogState(() => _isUploading = false);
      }
    }
  }

  void _showAddDialog() {
    _pickedImage = null;
    _urlController.clear();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text('إضافة بانر جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _pickImage(setDialogState),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _pickedImage != null
                      ? (kIsWeb
                          ? Image.network(_pickedImage!.path, fit: BoxFit.cover)
                          : Image.file(File(_pickedImage!.path),
                              fit: BoxFit.cover))
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo,
                                size: 50, color: Colors.grey),
                            Text('اضغط لاختيار صورة'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'أو رابط الصورة (اختياري)',
                  hintText: 'https://example.com/image.jpg',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_isUploading)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: _isUploading ? null : () => Navigator.pop(ctx),
                child: const Text('إلغاء')),
            ElevatedButton(
              onPressed:
                  _isUploading ? null : () => _uploadAndAdd(setDialogState),
              child: const Text('إضافة'),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة البنرات')),
      body: StreamBuilder<List<String>>(
        stream: _db.banners,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final banners = snapshot.data ?? [];

          if (banners.isEmpty) {
            return const Center(child: Text('لا توجد بنرات حالياً'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: banners.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 16),
            itemBuilder: (ctx, i) {
              final url = banners[i];
              return Card(
                clipBehavior: Clip.antiAlias,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Stack(
                  children: [
                    Image.network(
                      url,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          height: 150,
                          color: Colors.grey,
                          child: const Center(child: Icon(Icons.broken_image))),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _db.deleteBanner(url);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
