import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:madura_store_mobile/models/user.dart';
import 'package:madura_store_mobile/services/api_service.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Constructor
  AuthService() {
    loadUser();
  }

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

  // Set current user
  void _setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  // Load user from local storage
  Future<void> loadUser() async {
    _setLoading(true);
    _setError(null);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');

      if (userData != null) {
        _setCurrentUser(User.fromJson(userData));
        
        // Validate token with server
        final response = await ApiService.get('api/auth.ashx', queryParams: {'action': 'validate'});
        
        if (!response['success']) {
          // Token is invalid, logout
          logout();
        }
      }
    } catch (e) {
      _setError('Error loading user: ${e.toString()}');
      logout();
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      // Buat URL dengan query parameter action
      final response = await ApiService.post(
        'api/auth.ashx?action=login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response['success']) {
        // Save token
        final token = response['token'];
        await ApiService.setToken(token);

        // Save user data
        final userData = response['user'];
        final user = User(
          id: userData['userId'],
          name: userData['name'],
          email: userData['email'],
          role: userData['role'],
          phoneNumber: userData['phoneNumber'],
        );
        
        // Save to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', user.toJson());
        
        _setCurrentUser(user);
        return true;
      } else {
        _setError(response['message'] ?? 'Login gagal');
        return false;
      }
    } catch (e) {
      _setError('Error during login: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register
  Future<bool> register(String name, String email, String password, String phoneNumber) async {
    _setLoading(true);
    _setError(null);

    try {
      // Buat URL dengan query parameter action
      final response = await ApiService.post(
        'api/auth.ashx?action=register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
        },
      );

      if (response['success']) {
        if (response.containsKey('token') && response.containsKey('user')) {
          // Auto-login after registration
          // Save token
          final token = response['token'];
          await ApiService.setToken(token);

          // Save user data
          final userData = response['user'];
          final user = User(
            id: userData['userId'],
            name: userData['name'],
            email: userData['email'],
            role: userData['role'],
            phoneNumber: userData['phoneNumber'],
          );
          
          // Save to shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', user.toJson());
          
          _setCurrentUser(user);
        }
        return true;
      } else {
        _setError(response['message'] ?? 'Registrasi gagal');
        return false;
      }
    } catch (e) {
      _setError('Error during registration: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get user profile
  Future<bool> getUserProfile() async {
    if (!isAuthenticated) return false;
    
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.get('api/auth.ashx', queryParams: {'action': 'profile'});

      if (response['success']) {
        final userData = response['user'];
        final user = User(
          id: userData['userId'],
          name: userData['name'],
          email: userData['email'],
          role: userData['role'],
          phoneNumber: userData['phoneNumber'],
        );
        
        // Save to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', user.toJson());
        
        _setCurrentUser(user);
        return true;
      } else {
        _setError(response['message'] ?? 'Gagal mendapatkan profil');
        return false;
      }
    } catch (e) {
      _setError('Error getting profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      // Clear token and user data
      await ApiService.clearToken();
      
      // Remove user data from shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      
      _setCurrentUser(null);
    } catch (e) {
      _setError('Error during logout: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Clear error
  void clearError() {
    _setError(null);
  }
} 