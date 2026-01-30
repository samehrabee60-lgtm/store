import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final users = await _databaseService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleBan(String uid, bool currentStatus) async {
    // currentStatus: true if currently banned
    try {
      await _databaseService.toggleUserBan(uid, !currentStatus);
      await _fetchUsers(); // Refresh list
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(!currentStatus ? 'تم حظر المستخدم' : 'تم إلغاء الحظر')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل التعديل: $e')),
      );
    }
  }

  Future<void> _deleteUser(String uid) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المستخدم'),
        content: const Text(
            'هل أنت متأكد من رغبتك في حذف هذا المستخدم؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _databaseService.deleteUser(uid);
        await _fetchUsers();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف المستخدم بنجاح')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الحذف: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الأعضاء'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUsers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(child: Text('لا يوجد أعضاء مسجلين'))
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    final isBanned = user['role'] == 'banned';
                    final name = user['name'] ?? 'بدون اسم';
                    final email = user['email'] ?? 'بدون بريد';
                    final phone = user['phone'] ?? 'بدون هاتف';

                    return Card(
                      color: isBanned ? Colors.red.shade50 : null,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              isBanned ? Colors.grey : Colors.blue.shade100,
                          child: Icon(Icons.person,
                              color: isBanned ? Colors.white : Colors.blue),
                        ),
                        title: Text(name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(email),
                            Text(phone,
                                style: TextStyle(color: Colors.grey.shade600)),
                            if (isBanned)
                              const Text(
                                'محظور',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: isBanned ? 'إلغاء الحظر' : 'حظر',
                              icon: Icon(
                                isBanned ? Icons.check_circle : Icons.block,
                                color: isBanned ? Colors.green : Colors.orange,
                              ),
                              onPressed: () => _toggleBan(user['id'], isBanned),
                            ),
                            IconButton(
                              tooltip: 'حذف',
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteUser(user['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
