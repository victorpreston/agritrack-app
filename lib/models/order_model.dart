import 'package:flutter/material.dart';

enum OrderStatus { pending, processing, shipped, delivered, cancelled }

class OrderItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;

  OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  double get totalPrice => price * quantity;
}

class Order {
  final String id;
  final List<OrderItem> items;
  final DateTime orderDate;
  final OrderStatus status;
  final double shippingCost;
  final String shippingAddress;
  final String? trackingNumber;
  final DateTime? estimatedDelivery;

  Order({
    required this.id,
    required this.items,
    required this.orderDate,
    required this.status,
    required this.shippingCost,
    required this.shippingAddress,
    this.trackingNumber,
    this.estimatedDelivery,
  });

  // Calculate total order price
  double get totalPrice {
    double itemsTotal = items.fold(0, (sum, item) => sum + item.totalPrice);
    return itemsTotal + shippingCost;
  }

  // Get status color
  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get status text
  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  // Get status icon
  IconData get statusIcon {
    switch (status) {
      case OrderStatus.pending:
        return Icons.hourglass_empty;
      case OrderStatus.processing:
        return Icons.sync;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }
}

// Sample orders data
List<Order> sampleOrders = [
  Order(
    id: 'ORD-2023-001',
    items: [
      OrderItem(
        id: '1',
        name: 'BioFungal Pro',
        price: 29.99,
        quantity: 2,
        imageUrl: '/placeholder.svg?height=60&width=60',
      ),
      OrderItem(
        id: '2',
        name: 'InsectGuard Plus',
        price: 34.99,
        quantity: 1,
        imageUrl: '/placeholder.svg?height=60&width=60',
      ),
    ],
    orderDate: DateTime.now().subtract(const Duration(days: 2)),
    status: OrderStatus.shipped,
    shippingCost: 5.99,
    shippingAddress: '123 Farm Road, Countryside, CA 90210',
    trackingNumber: 'TRK-9876543210',
    estimatedDelivery: DateTime.now().add(const Duration(days: 2)),
  ),
  Order(
    id: 'ORD-2023-002',
    items: [
      OrderItem(
        id: '3',
        name: 'Nutriboost Complete',
        price: 19.99,
        quantity: 3,
        imageUrl: '/placeholder.svg?height=60&width=60',
      ),
    ],
    orderDate: DateTime.now().subtract(const Duration(days: 5)),
    status: OrderStatus.delivered,
    shippingCost: 5.99,
    shippingAddress: '123 Farm Road, Countryside, CA 90210',
    trackingNumber: 'TRK-1234567890',
    estimatedDelivery: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Order(
    id: 'ORD-2023-003',
    items: [
      OrderItem(
        id: '4',
        name: 'WeedClear Advanced',
        price: 39.99,
        quantity: 1,
        imageUrl: '/placeholder.svg?height=60&width=60',
      ),
      OrderItem(
        id: '5',
        name: 'FungStop Ultra',
        price: 45.99,
        quantity: 1,
        imageUrl: '/placeholder.svg?height=60&width=60',
      ),
    ],
    orderDate: DateTime.now().subtract(const Duration(hours: 12)),
    status: OrderStatus.processing,
    shippingCost: 5.99,
    shippingAddress: '123 Farm Road, Countryside, CA 90210',
  ),
  Order(
    id: 'ORD-2023-004',
    items: [
      OrderItem(
        id: '6',
        name: 'BugShield Organic',
        price: 27.99,
        quantity: 2,
        imageUrl: '/placeholder.svg?height=60&width=60',
      ),
    ],
    orderDate: DateTime.now().subtract(const Duration(minutes: 30)),
    status: OrderStatus.pending,
    shippingCost: 5.99,
    shippingAddress: '123 Farm Road, Countryside, CA 90210',
  ),
];