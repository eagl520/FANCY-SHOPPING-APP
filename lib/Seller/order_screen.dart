import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({super.key});

  
  Future<void> _deleteOrder(BuildContext context, String orderId) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order deleted successfully')),
      );
    } catch (e) {
      print("Error deleting order: $e");
    }
  }

  
  Future<void> _acceptOrder(BuildContext context, String orderId, String buyerId, String productName) async {
    try {
      
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': 'Shipped',
      });

      
      await FirebaseFirestore.instance.collection('notifications').add({
        'buyerId': buyerId,
        'title': 'Order Update',
        'message': 'Your order ($productName) will be delivered in 14 days.',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false, 
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification sent to buyer!')),
        );
      }
    } catch (e) {
      print("Error accepting order: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentSellerId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incoming Orders'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('sellerId', isEqualTo: currentSellerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'NO DATA FOUND.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderDoc = orders[index];
              final order = orderDoc.data() as Map<String, dynamic>;
              
              final String orderId = orderDoc.id;
              final String buyerId = order['buyerId'] ?? '';
              final String imageUrl = order['imageUrl'] ?? '';
              final String productName = order['productName'] ?? 'Unknown Product';
              final String price = order['price'] ?? '0';
              String status = order['status'] ?? 'Pending';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple.shade50,
                          backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                          child: imageUrl.isEmpty 
                              ? const Icon(Icons.shopping_bag, color: Colors.deepPurple) 
                              : null,
                        ),
                        title: Text(
                          productName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Price: Rs $price\nStatus: $status'),
                        isThreeLine: true,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: status == 'Pending' ? Colors.orange.shade100 : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: status == 'Pending' ? Colors.orange.shade800 : Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const Divider(),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          
                          OutlinedButton.icon(
                            onPressed: () => _deleteOrder(context, orderId),
                            icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                            label: const Text('Delete', style: TextStyle(color: Colors.red)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                          const SizedBox(width: 10),
                          
                          ElevatedButton.icon(
                            onPressed: status == 'Pending' 
                                ? () => _acceptOrder(context, orderId, buyerId, productName) 
                                : null, 
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Yes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}