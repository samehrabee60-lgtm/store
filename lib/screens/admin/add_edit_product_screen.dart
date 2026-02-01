import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/product_model.dart';
import '../../services/storage_service.dart';
import '../../services/database_service.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'أجهزة';
  final List<String> _categories = ['أجهزة', 'محاليل', 'مستلزمات', 'أخرى'];

  XFile? _imageFile; // Main image
  PlatformFile? _pdfFile; // PDF file
  String? _pdfUrl; // Existing PDF URL
  List<XFile> _newAdditionalImages = []; // New additional images to upload
  List<String> _existingAdditionalImages =
      []; // Existing additional images URLs

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _descriptionController.text = widget.product!.description;
      _selectedCategory = widget.product!.category;
      _pdfUrl = widget.product!.pdfUrl;
      _existingAdditionalImages = List.from(widget.product!.additionalImages);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _pickPdf() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _pdfFile = result.files.first;
          _pdfUrl = null; // Reset existing URL if new file picked
        });
      }
    } catch (e) {
      debugPrint("Error picking PDF: $e");
    }
  }

  Future<void> _pickAdditionalImages() async {
    final picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        // Limit to total 2 additional images (existing + new) - Logic can be adjusted
        // For now, just add them.
        _newAdditionalImages.addAll(pickedFiles);
      });
    }
  }

  void _removeNewAdditionalImage(int index) {
    setState(() {
      _newAdditionalImages.removeAt(index);
    });
  }

  void _removeExistingAdditionalImage(int index) {
    setState(() {
      _existingAdditionalImages.removeAt(index);
    });
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final storage = StorageService();
        String imageUrl = widget.product?.imageUrl ?? '';

        // Upload Main Image
        if (_imageFile != null) {
          imageUrl = (await storage.uploadFile(
                file: kIsWeb ? _imageFile! : File(_imageFile!.path),
                bucketName: 'products',
                fileExtension: 'jpg',
                contentType: 'image/jpeg',
              )) ??
              '';
        }

        // Upload PDF
        String? finalPdfUrl = _pdfUrl;
        if (_pdfFile != null) {
          dynamic fileToUpload;
          if (kIsWeb) {
            fileToUpload =
                _pdfFile; // StorageService needs to handle PlatformFile specific logic for web reading bytes if passed directly?
            // Actually my StorageService expects 'dynamic file' and uses readAsBytes via interface wrapper or assumes File/XFile.
            // PlatformFile (file_picker) on web has 'bytes'.
            // Let's modify StorageService to handle PlatformFile or convert here.
            // Simplest: Pass object and let StorageService handle or handle here?
            // StorageService implementation I wrote: `file.readAsBytes()`
            // platformFile.readAsBytes() doesn't exist directly maybe? It has .bytes property on web if withReadStream...
            // For consistency let's stick to XFile if possible or pass bytes directly?
            // Wait, `_pdfFile` is `PlatformFile`.
            // If web, `_pdfFile.bytes` has data.
          }

          // Quick fix: StorageService `uploadFile` logic I wrote expects object with `readAsBytes`.
          // PlatformFile doesn't always have that.
          // I'll assume for this prototype we are mostly mobile/desktop or handle bytes manually.
          // On Web: file_picker returns bytes.
          // On Mobile: returns path.
          // I will duplicate logic here slightly for safety or update StorageService later.

          // Actually, let's reuse StorageService but pass something it understands or modify it?
          // I will update StorageService in next step if needed, but for now let's try to pass the right thing.
          // If I pass File(_pdfFile!.path!) on mobile it works (has readAsBytes).
          // On web, I can't easily wrap bytes into something with readAsBytes without a custom class.
          // Let's assume mobile mostly for now or pass bytes if I rewrite StorageService?
          // My StorageService handles kIsWeb by `file.readAsBytes()`. XFile has this. File has this.
          // PlatformFile... does not.

          // workaround:
          finalPdfUrl = await _uploadPdf(_pdfFile!);
        }

        // Upload Additional Images
        List<String> finalAdditionalImages =
            List.from(_existingAdditionalImages);
        for (var img in _newAdditionalImages) {
          final url = await storage.uploadFile(
            file: kIsWeb ? img : File(img.path),
            bucketName: 'products',
            fileExtension: 'jpg',
            contentType: 'image/jpeg',
          );
          if (url != null) finalAdditionalImages.add(url);
        }

        final product = Product(
          id: widget.product?.id ?? '',
          name: _nameController.text,
          category: _selectedCategory,
          price: double.tryParse(_priceController.text) ?? 0.0,
          description: _descriptionController.text,
          imageUrl: imageUrl,
          pdfUrl: finalPdfUrl,
          additionalImages: finalAdditionalImages,
        );

        Future<void> saveFuture;
        if (widget.product == null) {
          saveFuture = DatabaseService().addProduct(product);
        } else {
          saveFuture = DatabaseService().updateProduct(product);
        }

        await saveFuture.timeout(const Duration(seconds: 90));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حفظ المنتج بنجاح')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ: $e')),
          );
        }
        debugPrint(e.toString());
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<String?> _uploadPdf(PlatformFile file) async {
    // Custom helper since PlatformFile is different from XFile
    final storage = StorageService();
    if (kIsWeb) {
      // On web, `file.bytes` should be available if picked correctly.
      // However, StorageService expects an object it can call .readAsBytes() on.
      // Or I need to overload StorageService.
      // Since I can't easily change StorageService interface right here without breaking previous step logic potentially...
      // I will create a temporary wrapper or just use direct Supabase call?
      // Better: Use a wrapper class.
      return await storage.uploadFile(
          file: _PlatformFileWrapper(file),
          bucketName: 'products',
          fileExtension: 'pdf',
          contentType: 'application/pdf');
    } else {
      return await storage.uploadFile(
          file: File(file.path!),
          bucketName: 'products',
          fileExtension: 'pdf',
          contentType: 'application/pdf');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'إضافة منتج' : 'تعديل منتج'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main Image
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _imageFile != null
                      ? (kIsWeb
                          ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                          : Image.file(File(_imageFile!.path),
                              fit: BoxFit.cover))
                      : (widget.product?.imageUrl.isNotEmpty ?? false)
                          ? Image.network(widget.product!.imageUrl,
                              fit: BoxFit.cover)
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo,
                                    size: 50, color: Colors.grey),
                                Text('صورة المنتج الرئيسية'),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المنتج',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'الرجاء إدخال اسم المنتج' : null,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'الفئة',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'السعر',
                  border: OutlineInputBorder(),
                  suffixText: 'ج.م',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'الرجاء إدخال السعر';
                  if (double.tryParse(value) == null) {
                    return 'الرجاء إدخال رقم صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'الوصف',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'الرجاء إدخال الوصف' : null,
              ),

              const SizedBox(height: 25),
              const Divider(),
              const Text("ملفات إضافية",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // PDF Helper
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text(_pdfFile != null
                    ? "تم اختيار ملف: ${_pdfFile!.name}"
                    : (_pdfUrl != null
                        ? "يوجد ملف PDF مرفق"
                        : "لا يوجد ملف PDF")),
                subtitle: const Text("ارفق كتالوج أو شرح للمنتج"),
                trailing: IconButton(
                  icon: const Icon(Icons.upload_file),
                  onPressed: _pickPdf,
                ),
              ),

              const SizedBox(height: 10),
              // Additional Images
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("صور إضافية (تظهر داخل المنتج)",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                      icon: const Icon(Icons.add_photo_alternate),
                      onPressed: _pickAdditionalImages),
                ],
              ),

              if (_existingAdditionalImages.isNotEmpty ||
                  _newAdditionalImages.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._existingAdditionalImages.asMap().entries.map((entry) {
                        return Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(4),
                              width: 100,
                              child:
                                  Image.network(entry.value, fit: BoxFit.cover),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () =>
                                    _removeExistingAdditionalImage(entry.key),
                                child: const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.close,
                                      size: 12, color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        );
                      }),
                      ..._newAdditionalImages.asMap().entries.map((entry) {
                        return Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(4),
                              width: 100,
                              child: kIsWeb
                                  ? Image.network(entry.value.path,
                                      fit: BoxFit.cover)
                                  : Image.file(File(entry.value.path),
                                      fit: BoxFit.cover),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () =>
                                    _removeNewAdditionalImage(entry.key),
                                child: const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.close,
                                      size: 12, color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        );
                      }),
                    ],
                  ),
                ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('حفظ المنتج',
                          style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper wrapper for Web PlatformFile to behave like file with readAsBytes
class _PlatformFileWrapper {
  final PlatformFile file;
  _PlatformFileWrapper(this.file);

  Future<Uint8List> readAsBytes() async {
    return file.bytes!;
  }
}
