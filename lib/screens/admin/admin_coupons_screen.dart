import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import 'package:intl/intl.dart';

class AdminCouponsScreen extends StatefulWidget {
  const AdminCouponsScreen({super.key});

  @override
  State<AdminCouponsScreen> createState() => _AdminCouponsScreenState();
}

class _AdminCouponsScreenState extends State<AdminCouponsScreen> {
  final DatabaseService _db = DatabaseService();

  void _showAddDialog() {
    final codeController = TextEditingController();
    final valueController = TextEditingController();
    String discountType = 'percentage';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إضافة كوبون جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                      labelText: 'كود الخصم (مثال: SAVE10)'),
                ),
                TextField(
                  controller: valueController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'قيمة الخصم'),
                ),
                DropdownButton<String>(
                  value: discountType,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                        value: 'percentage', child: Text('نسبة مئوية (%)')),
                    DropdownMenuItem(
                        value: 'fixed', child: Text('مبلغ ثابت (ج.م)')),
                  ],
                  onChanged: (val) => setDialogState(() => discountType = val!),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('تاريخ الانتهاء: '),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030));
                        if (picked != null) {
                          setDialogState(() => selectedDate = picked);
                        }
                      },
                      child:
                          Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                    )
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (codeController.text.isEmpty ||
                    valueController.text.isEmpty) {
                  return;
                }

                await _db.addCoupon(
                  code: codeController.text,
                  discountType: discountType,
                  value: num.parse(valueController.text),
                  expiryDate: selectedDate,
                );
                if (context.mounted) Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الكوبونات')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _db.coupons,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final coupons = snapshot.data!;
          if (coupons.isEmpty) {
            return const Center(child: Text('لا توجد كوبونات'));
          }

          return ListView.separated(
            itemCount: coupons.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final coupon = coupons[index];
              final isExpired = DateTime.parse(coupon['expiry_date'])
                  .isBefore(DateTime.now());

              return ListTile(
                leading: Icon(Icons.confirmation_number,
                    color: isExpired ? Colors.grey : Colors.green),
                title: Text(coupon['code'],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    '${coupon['value']} ${coupon['discount_type'] == 'percentage' ? '%' : 'ج.م'} - ينتهي في ${DateFormat('yyyy-MM-dd').format(DateTime.parse(coupon['expiry_date']))}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _db.deleteCoupon(coupon['code']),
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
