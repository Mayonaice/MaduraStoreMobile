import 'package:flutter/material.dart';
import 'package:madura_store_mobile/models/transaction.dart';
import 'package:madura_store_mobile/models/transaction_detail.dart';
import 'package:madura_store_mobile/models/transaction_summary.dart';
import 'package:madura_store_mobile/services/api_service.dart';

class TransactionService extends ChangeNotifier {
  List<Transaction> _transactions = [];
  TransactionSummary? _summary;
  TransactionDetail? _transactionDetail;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMoreData = true;

  // Getters
  List<Transaction> get transactions => _transactions;
  TransactionSummary? get summary => _summary;
  TransactionDetail? get transactionDetail => _transactionDetail;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMoreData => _hasMoreData;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  // Clear transactions
  void clearTransactions() {
    _transactions = [];
    _currentPage = 1;
    _totalPages = 1;
    _hasMoreData = true;
    notifyListeners();
  }

  // Get transaction summary for dashboard
  Future<bool> getTransactionSummary() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.get(
        'transactions.ashx',
        queryParams: {'action': 'summary'},
      );

      if (response['success']) {
        final summaryData = response['summary'];
        _summary = TransactionSummary.fromMap(summaryData);
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Gagal mendapatkan ringkasan transaksi');
        return false;
      }
    } catch (e) {
      _setError('Error loading transaction summary: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get transactions list
  Future<bool> getTransactions({bool refresh = false}) async {
    if (refresh) {
      clearTransactions();
    }

    if (_isLoading || (!_hasMoreData && !refresh)) {
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.get(
        'transactions.ashx',
        queryParams: {
          'action': 'list',
          'page': _currentPage,
          'pageSize': 10,
        },
      );

      if (response['success']) {
        final List<dynamic> transactionsData = response['transactions'];
        final paginationData = response['pagination'];
        
        final newTransactions = transactionsData
            .map((data) => Transaction.fromMap(data))
            .toList();
        
        if (refresh) {
          _transactions = newTransactions;
        } else {
          _transactions.addAll(newTransactions);
        }
        
        _currentPage = paginationData['currentPage'];
        _totalPages = paginationData['totalPages'];
        _hasMoreData = _currentPage < _totalPages;
        
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Gagal mendapatkan data transaksi');
        return false;
      }
    } catch (e) {
      _setError('Error loading transactions: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load more transactions
  Future<bool> loadMoreTransactions() async {
    if (!_hasMoreData || _isLoading) {
      return false;
    }
    
    _currentPage++;
    return getTransactions();
  }

  // Get transaction detail
  Future<bool> getTransactionDetail(int transactionId) async {
    _setLoading(true);
    _setError(null);
    _transactionDetail = null;

    try {
      final response = await ApiService.get(
        'transactions.ashx',
        queryParams: {
          'action': 'detail',
          'id': transactionId,
        },
      );

      if (response['success']) {
        final detailData = response['transaction'];
        _transactionDetail = TransactionDetail.fromMap(detailData);
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Gagal mendapatkan detail transaksi');
        return false;
      }
    } catch (e) {
      _setError('Error loading transaction detail: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Clear error
  void clearError() {
    _setError(null);
  }
} 