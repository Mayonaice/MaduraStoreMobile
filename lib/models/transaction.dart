import 'package:intl/intl.dart';

class Transaction {
  final int id;
  final DateTime date;
  final double totalAmount;
  final String paymentMethod;

  Transaction({
    required this.id,
    required this.date,
    required this.totalAmount,
    required this.paymentMethod,
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

  // Create transaction from Map
  factory Transaction.fromMap(Map<String, dynamic> map) {
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

    return Transaction(
      id: map['id'],
      date: parsedDate,
      totalAmount: map['totalAmount'].toDouble(),
      paymentMethod: map['paymentMethod'],
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
    };
  }

  @override
  String toString() {
    return 'Transaction(id: $id, date: $date, totalAmount: $totalAmount, paymentMethod: $paymentMethod)';
  }
} 