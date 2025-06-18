import 'package:intl/intl.dart';
import 'package:madura_store_mobile/models/transaction.dart';

class TransactionSummary {
  final int totalTransactions;
  final double totalSpending;
  final List<Transaction> latestTransactions;
  final List<MonthlySpending> monthlySpending;

  TransactionSummary({
    required this.totalTransactions,
    required this.totalSpending,
    required this.latestTransactions,
    required this.monthlySpending,
  });

  // Format currency
  String get formattedTotalSpending {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormat.format(totalSpending);
  }

  // Create transaction summary from Map
  factory TransactionSummary.fromMap(Map<String, dynamic> map) {
    return TransactionSummary(
      totalTransactions: map['totalTransactions'],
      totalSpending: map['totalSpending'].toDouble(),
      latestTransactions: List<Transaction>.from(
        (map['latestTransactions'] as List).map(
          (transaction) => Transaction.fromMap(transaction),
        ),
      ),
      monthlySpending: List<MonthlySpending>.from(
        (map['monthlySpending'] as List).map(
          (spending) => MonthlySpending.fromMap(spending),
        ),
      ),
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'totalTransactions': totalTransactions,
      'totalSpending': totalSpending,
      'latestTransactions': latestTransactions.map((transaction) => transaction.toMap()).toList(),
      'monthlySpending': monthlySpending.map((spending) => spending.toMap()).toList(),
    };
  }

  @override
  String toString() {
    return 'TransactionSummary(totalTransactions: $totalTransactions, totalSpending: $totalSpending, latestTransactions: ${latestTransactions.length}, monthlySpending: ${monthlySpending.length})';
  }
}

class MonthlySpending {
  final String month;
  final double total;

  MonthlySpending({
    required this.month,
    required this.total,
  });

  // Format currency
  String get formattedTotal {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormat.format(total);
  }

  // Format month for display
  String get formattedMonth {
    // Parse the month string (yyyy-MM)
    final List<String> parts = month.split('-');
    if (parts.length == 2) {
      final year = int.tryParse(parts[0]) ?? 0;
      final monthNum = int.tryParse(parts[1]) ?? 1;
      
      // Create a date for the first day of the month
      final date = DateTime(year, monthNum, 1);
      
      // Format just the month name
      return DateFormat('MMM yyyy').format(date);
    }
    return month;
  }

  // Create monthly spending from Map
  factory MonthlySpending.fromMap(Map<String, dynamic> map) {
    return MonthlySpending(
      month: map['month'],
      total: map['total'].toDouble(),
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'total': total,
    };
  }

  @override
  String toString() {
    return 'MonthlySpending(month: $month, total: $total)';
  }
} 