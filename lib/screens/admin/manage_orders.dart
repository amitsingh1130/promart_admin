import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ManageOrdersScreen extends StatelessWidget {
  const ManageOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').orderBy('orderDate', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No orders yet.'));
        }
        
        final docs = snapshot.data!.docs;
        
        return ListView.separated(
          itemCount: docs.length,
          padding: const EdgeInsets.all(16),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final products = data['products'] as List<dynamic>? ?? [];
            final date = (data['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now();
            final status = data['status'] ?? 'Pending';
            
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: ExpansionTile(
                leading: _buildStatusIcon(status),
                title: Text(
                  'Order #${docs[index].id.substring(0, 8)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Total: ₹${data['totalPrice']} • ${DateFormat('dd MMM').format(date)}'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('User ID', data['userId']),
                        _buildInfoRow('Address', data['address']),
                        _buildInfoRow('Date', DateFormat('dd MMM yyyy HH:mm').format(date)),
                        const Divider(height: 32),
                        const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...products.map((p) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Text('${p['quantity']}x', style: const TextStyle(color: Colors.grey)),
                              const SizedBox(width: 8),
                              Expanded(child: Text(p['name'] ?? 'Unknown')),
                              Text('₹${p['price']}'),
                            ],
                          ),
                        )),
                        const Divider(height: 32),
                        const Text('Update Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _statusButton(context, docs[index].id, 'Pending', Colors.orange),
                              const SizedBox(width: 8),
                              _statusButton(context, docs[index].id, 'Shipped', Colors.blue),
                              const SizedBox(width: 8),
                              _statusButton(context, docs[index].id, 'Delivered', Colors.green),
                              const SizedBox(width: 8),
                              _statusButton(context, docs[index].id, 'Cancelled', Colors.red),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData icon;
    Color color;
    switch (status.toLowerCase()) {
      case 'delivered': icon = Icons.check_circle; color = Colors.green; break;
      case 'shipped': icon = Icons.local_shipping; color = Colors.blue; break;
      case 'cancelled': icon = Icons.cancel; color = Colors.red; break;
      default: icon = Icons.access_time_filled; color = Colors.orange;
    }
    return CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 20));
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text('$label:', style: const TextStyle(color: Colors.grey, fontSize: 12))),
          Expanded(child: Text(value ?? 'N/A', style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _statusButton(BuildContext context, String orderId, String status, Color color) {
    return ActionChip(
      label: Text(status, style: const TextStyle(fontSize: 12)),
      onPressed: () => _updateStatus(orderId, status),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  void _updateStatus(String orderId, String status) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({'status': status});
  }
}
