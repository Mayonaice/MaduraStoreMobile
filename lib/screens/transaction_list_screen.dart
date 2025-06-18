import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:madura_store_mobile/models/transaction.dart';
import 'package:madura_store_mobile/screens/transaction_detail_screen.dart';
import 'package:madura_store_mobile/services/transaction_service.dart';
import 'package:madura_store_mobile/theme/app_theme.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({Key? key}) : super(key: key);

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    
    // Load transactions when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactions(refresh: true);
    });
    
    // Add scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
        _loadMoreTransactions();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions({bool refresh = false}) async {
    final transactionService = Provider.of<TransactionService>(context, listen: false);
    await transactionService.getTransactions(refresh: refresh);
  }

  Future<void> _loadMoreTransactions() async {
    final transactionService = Provider.of<TransactionService>(context, listen: false);
    
    if (transactionService.isLoading || 
        !transactionService.hasMoreData || 
        _isLoadingMore) {
      return;
    }
    
    setState(() {
      _isLoadingMore = true;
    });
    
    await transactionService.loadMoreTransactions();
    
    setState(() {
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadTransactions(refresh: true),
          ),
        ],
      ),
      body: Consumer<TransactionService>(
        builder: (context, transactionService, child) {
          if (transactionService.isLoading && transactionService.transactions.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (transactionService.error != null && transactionService.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    transactionService.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _loadTransactions(refresh: true),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          
          if (transactionService.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long,
                    color: AppTheme.textLightColor,
                    size: 72,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada transaksi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textLightColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Transaksi Anda akan muncul di sini',
                    style: TextStyle(
                      color: AppTheme.textLightColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _loadTransactions(refresh: true),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () => _loadTransactions(refresh: true),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: transactionService.transactions.length + 
                  (transactionService.hasMoreData || _isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= transactionService.transactions.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                final transaction = transactionService.transactions[index];
                return _buildTransactionItem(transaction);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionDetailScreen(transactionId: transaction.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction ID and Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaksi #${transaction.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLightColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      transaction.paymentMethod,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Date
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppTheme.textLightColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    transaction.formattedDate,
                    style: const TextStyle(
                      color: AppTheme.textLightColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Divider
              const Divider(),
              const SizedBox(height: 12),
              
              // Total Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    transaction.formattedTotal,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // View Details Button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionDetailScreen(transactionId: transaction.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('Lihat Detail'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 