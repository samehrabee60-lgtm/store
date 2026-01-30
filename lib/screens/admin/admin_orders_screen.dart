import 'package:flutter/material.dart';
import '../../models/order_model.dart'; // Ensure this model exists and is imported correctly
import '../../services/database_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إدارة الطلبات')),
      body: StreamBuilder<List<OrderModel>>(
        stream: DatabaseService().allOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('لا توجد طلبات'));
          }

          final orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text('طلب من: ${order.userName}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('العنوان: ${order.address}'),
                      Text(
                        'التاريخ: ${order.date.toString().substring(0, 16)}',
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Text('الحالة: '),
                          _buildStatusDropdown(context, order),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.print, color: Colors.blueGrey),
                    onPressed: () => _generatePdf(order),
                    tooltip: 'طباعة الفاتورة',
                  ),
                  children: order.items.map((item) {
                    return ListTile(
                      title: Text(item.productName),
                      subtitle: Text('${item.price} ج.م × ${item.quantity}'),
                      trailing: Text('${item.price * item.quantity} ج.م'),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context, OrderModel order) {
    return DropdownButton<OrderStatus>(
      value: order.status,
      onChanged: (OrderStatus? newValue) {
        if (newValue != null) {
          DatabaseService().updateOrderStatus(order.id, newValue);
        }
      },
      items: OrderStatus.values.map<DropdownMenuItem<OrderStatus>>((
        OrderStatus value,
      ) {
        return DropdownMenuItem<OrderStatus>(
          value: value,
          child: Text(
            _getStatusText(value),
            style: TextStyle(color: _getStatusColor(value)),
          ),
        );
      }).toList(),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'قيد الانتظار';
      case OrderStatus.processing:
        return 'جاري التجهيز';
      case OrderStatus.shipped:
        return 'تم الشحن';
      case OrderStatus.delivered:
        return 'تم التسليم';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  Future<void> _generatePdf(OrderModel order) async {
    final pdf = pw.Document();

    // Use a font that supports Arabic
    final font = await PdfGoogleFonts.cairoRegular();

    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(base: font),
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                  level: 0,
                  child: pw.Center(
                      child: pw.Text('فاتورة مبيعات',
                          style: const pw.TextStyle(fontSize: 24)))),
              pw.SizedBox(height: 20),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('رقم الطلب: ${order.id}'),
                          pw.Text('العميل: ${order.userName}'),
                          pw.Text(
                              'التاريخ: ${order.date.toString().substring(0, 10)}'),
                        ]),
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Betalab Store'),
                          pw.Text('العنوان: المحلة الكبرى'),
                          pw.Text('هاتف: 01018690407'),
                        ]),
                  ]),
              pw.SizedBox(height: 30),
              pw.TableHelper.fromTextArray(
                headers: ['المنتج', 'السعر', 'الكمية', 'الاجمالي'],
                data: order.items
                    .map((item) => [
                          item.productName,
                          '${item.price}',
                          '${item.quantity}',
                          '${item.price * item.quantity}'
                        ])
                    .toList(),
                headerStyle:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                cellAlignment: pw.Alignment.centerLeft,
              ),
              pw.Divider(),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('الاجمالي الكلي:',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    pw.Text('${order.totalAmount} ج.م',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 16,
                            color: PdfColors.red)),
                  ]),
              pw.SizedBox(height: 50),
              pw.Center(child: pw.Text('شكرا لتعاملكم معنا!')),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'invoice_${order.id}.pdf',
    );
  }
}
