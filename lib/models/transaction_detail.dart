import 'package:intl/intl.dart';

class TransactionDetail {
  final int id;
  final DateTime date;
  final double totalAmount;
  final String paymentMethod;
  final List<TransactionItem> items;

  TransactionDetail({
    required this.id,
    required this.date,
    required this.totalAmount,
    required this.paymentMethod,
    required this.items,
  });

  // Format currency
  String get formattedTotal {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormat.format(totalAmount);
  }

  // Format date
  String get formattedDate {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // Format short date
  String get formattedShortDate {
    return DateFormat('dd MMM yyyy').format(date);
  }

  // Create transaction detail from Map
  factory TransactionDetail.fromMap(Map<String, dynamic> map) {
    // Attempt to parse the date in both ISO format and custom format
    DateTime parsedDate;
    try {
      if (map['date'] is String) {
        // Attempt to parse date in dd/MM/yyyy HH:mm:ss format from API
        parsedDate = DateFormat('dd/MM/yyyy HH:mm:ss').parse(map['date']);
      } else {
        // Fall back to DateTime.parse for ISO formatted date
        parsedDate = DateTime.parse(map['date'].toString());
      }
    } catch (e) {
      // Fall back to current date if parsing fails
      print('Error parsing date: ${map['date']}, using current date. Error: $e');
      parsedDate = DateTime.now();
    }
    
    return TransactionDetail(
      id: map['id'],
      date: parsedDate,
      totalAmount: map['totalAmount'].toDouble(),
      paymentMethod: map['paymentMethod'],
      items: List<TransactionItem>.from(
        (map['items'] as List).map(
          (item) => TransactionItem.fromMap(item),
        ),
      ),
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  @override
  String toString() {
    return 'TransactionDetail(id: $id, date: $date, totalAmount: $totalAmount, paymentMethod: $paymentMethod, items: ${items.length})';
  }
}

class TransactionItem {
  final int detailId;
  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final double subtotal;
  final String category;

  TransactionItem({
    required this.detailId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
    required this.category,
  });

  // Format currency
  String get formattedPrice {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormat.format(price);
  }

  // Format subtotal
  String get formattedSubtotal {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormat.format(subtotal);
  }

  // Create transaction item from Map
  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      detailId: map['detailId'],
      productId: map['productId'],
      productName: map['productName'],
      quantity: map['quantity'],
      price: map['price'].toDouble(),
      subtotal: map['subtotal'].toDouble(),
      category: map['category'],
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'detailId': detailId,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
      'category': category,
    };
  }

  @override
  String toString() {
    return 'TransactionItem(detailId: $detailId, productId: $productId, productName: $productName, quantity: $quantity, price: $price, subtotal: $subtotal, category: $category)';
  }
} 