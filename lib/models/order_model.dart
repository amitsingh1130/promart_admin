import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final String address;
  final List<Map<String, dynamic>> products; // list of {productId, quantity}
  final double totalPrice;
  final DateTime orderDate;
  final String status;

  OrderModel({
    required this.id,
    required this.userId,
    required this.address,
    required this.products,
    required this.totalPrice,
    required this.orderDate,
    required this.status,
  });

  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    return OrderModel(
      id: id,
      userId: data['userId'] ?? '',
      address: data['address'] ?? '',
      products: List<Map<String, dynamic>>.from(data['products'] ?? []),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      orderDate: (data['orderDate'] is Timestamp) 
          ? (data['orderDate'] as Timestamp).toDate() 
          : DateTime.now(),
      status: data['status'] ?? 'Pending',
    );
  }
}
