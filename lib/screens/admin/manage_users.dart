import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No users found.'));
        }
        
        final docs = snapshot.data!.docs;
        
        return ListView.builder(
          itemCount: docs.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  backgroundImage: (data['photoUrl'] != null && data['photoUrl'] != '') ? NetworkImage(data['photoUrl']) : null,
                  child: (data['photoUrl'] == null || data['photoUrl'] == '') 
                    ? Text(data['name']?.substring(0, 1).toUpperCase() ?? 'U', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)) 
                    : null,
                ),
                title: Text(data['name'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(data['email'] ?? 'No Email', style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showUserDetails(context, data, docs[index].id),
              ),
            );
          },
        );
      },
    );
  }

  void _showUserDetails(BuildContext context, Map<String, dynamic> user, String docId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: (user['photoUrl'] != null && user['photoUrl'] != '') ? NetworkImage(user['photoUrl']) : null,
              child: (user['photoUrl'] == null || user['photoUrl'] == '') ? const Icon(Icons.person, size: 40) : null,
            ),
            const SizedBox(height: 16),
            Text(user['name'] ?? 'No Name', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(user['email'] ?? 'No Email', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            _buildInfoTile(Icons.location_on_outlined, 'Address', user['address'] ?? 'No address provided'),
            _buildInfoTile(Icons.phone_outlined, 'Phone', user['phoneNumber'] ?? user['phone'] ?? 'N/A'),
            const Divider(height: 40),
            const Align(alignment: Alignment.centerLeft, child: Text('Order History', style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('orders').where('userId', isEqualTo: user['uid']).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final orders = snapshot.data!.docs;
                  if (orders.isEmpty) return const Center(child: Text('No orders found'));
                  
                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, i) {
                      final o = orders[i].data() as Map<String, dynamic>;
                      return Card(
                        elevation: 0,
                        color: Colors.grey[50],
                        child: ListTile(
                          title: Text('Order #${orders[i].id.substring(0, 5)}', style: const TextStyle(fontSize: 14)),
                          subtitle: Text(o['status'], style: const TextStyle(fontSize: 12)),
                          trailing: Text('₹${o['totalPrice']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
