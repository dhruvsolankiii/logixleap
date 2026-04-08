import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // For Chrome (Web) testing:
  static const String baseUrl = "http://127.0.0.1:5000/api";

  // For Mobile (Phone) testing:
  // static const String baseUrl = "http://192.168.199.207:5000/api";

  // Timeout duration for all API calls
  static const Duration _timeout = Duration(seconds: 30);

  // Helper method for handling errors
  static Map<String, dynamic> _errorResponse(String message) {
    return {"error": true, "message": message};
  }

  // LOGIN
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/auth/login"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(_timeout);

      return jsonDecode(response.body);
    } on TimeoutException {
      return _errorResponse(
        "Connection timed out. Please check your internet connection.",
      );
    } on SocketException {
      return _errorResponse(
        "Unable to connect to server. Please make sure the server is running.",
      );
    } catch (e) {
      return _errorResponse("Something went wrong. Please try again.");
    }
  }

  // REGISTER
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/auth/register"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "name": name,
              "email": email,
              "password": password,
            }),
          )
          .timeout(_timeout);

      return jsonDecode(response.body);
    } on TimeoutException {
      return _errorResponse(
        "Connection timed out. Please check your internet connection.",
      );
    } on SocketException {
      return _errorResponse(
        "Unable to connect to server. Please make sure the server is running.",
      );
    } catch (e) {
      return _errorResponse("Something went wrong. Please try again.");
    }
  }

  // INVEST
  static Future<Map<String, dynamic>> invest(
    String userId,
    String plan,
    double amount,
    double roi,
    String duration,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/invest"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "userId": userId,
              "plan": plan,
              "amount": amount,
              "roi": roi,
              "duration": duration,
            }),
          )
          .timeout(_timeout);

      return jsonDecode(response.body);
    } on TimeoutException {
      return _errorResponse("Connection timed out. Please try again.");
    } on SocketException {
      return _errorResponse("Unable to connect to server.");
    } catch (e) {
      return _errorResponse("Something went wrong. Please try again.");
    }
  }

  // GET PORTFOLIO
  static Future<Map<String, dynamic>> getPortfolio(String userId) async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/portfolio/$userId"))
          .timeout(_timeout);

      return jsonDecode(response.body);
    } on TimeoutException {
      return _errorResponse("Connection timed out.");
    } on SocketException {
      return _errorResponse("Unable to connect to server.");
    } catch (e) {
      return _errorResponse("Something went wrong.");
    }
  }

  // WITHDRAW
  static Future<Map<String, dynamic>> withdraw(
    String investmentId,
    String userId,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/withdraw/$investmentId"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"userId": userId}),
          )
          .timeout(_timeout);

      return jsonDecode(response.body);
    } on TimeoutException {
      return _errorResponse("Connection timed out.");
    } on SocketException {
      return _errorResponse("Unable to connect to server.");
    } catch (e) {
      return _errorResponse("Something went wrong.");
    }
  }

  // GET TRANSACTIONS
  static Future<List<dynamic>> getTransactions(String userId) async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/transactions/$userId"))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load transactions");
      }
    } on TimeoutException {
      throw Exception("Connection timed out.");
    } on SocketException {
      throw Exception("Unable to connect to server.");
    } catch (e) {
      throw Exception("Failed to load transactions: $e");
    }
  }

  // --- ADMIN & PLAN ROUTES ---

  // Get all plans (public)
  static Future<List<dynamic>> getPlans() async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/admin/plans"))
          .timeout(_timeout);

      return jsonDecode(response.body);
    } on TimeoutException {
      throw Exception("Connection timed out.");
    } on SocketException {
      throw Exception("Unable to connect to server.");
    } catch (e) {
      throw Exception("Failed to load plans: $e");
    }
  }

  // Get all users (Admin only)
  static Future<List<dynamic>> getAllUsers(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/admin/users"),
            headers: {"Authorization": "Bearer $token"},
          )
          .timeout(_timeout);

      return jsonDecode(response.body);
    } on TimeoutException {
      throw Exception("Connection timed out.");
    } on SocketException {
      throw Exception("Unable to connect to server.");
    } catch (e) {
      throw Exception("Failed to load users: $e");
    }
  }

  // Delete User (Admin only)
  static Future<Map<String, dynamic>> deleteUser(
    String token,
    String userId,
  ) async {
    try {
      final response = await http
          .delete(
            Uri.parse("$baseUrl/admin/users/$userId"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          )
          .timeout(_timeout);

      return jsonDecode(response.body);
    } on TimeoutException {
      return _errorResponse("Connection timed out.");
    } on SocketException {
      return _errorResponse("Unable to connect to server.");
    } catch (e) {
      return _errorResponse("Something went wrong.");
    }
  }

  // Fund a user
  static Future<Map<String, dynamic>> fundUser(
    String token,
    String userId,
    double amount,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/admin/users/$userId/fund"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode({"amount": amount}),
          )
          .timeout(_timeout);

      return jsonDecode(response.body);
    } on TimeoutException {
      return _errorResponse("Connection timed out.");
    } on SocketException {
      return _errorResponse("Unable to connect to server.");
    } catch (e) {
      return _errorResponse("Something went wrong.");
    }
  }

  // Create Plan (Admin only)
  static Future<Map<String, dynamic>> createPlan(
    String token,
    String title,
    String description,
    double roi,
    String duration,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/admin/plans"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode({
              "title": title,
              "description": description,
              "roi": roi,
              "duration": duration,
            }),
          )
          .timeout(_timeout);

      return jsonDecode(response.body);
    } on TimeoutException {
      return _errorResponse("Connection timed out.");
    } on SocketException {
      return _errorResponse("Unable to connect to server.");
    } catch (e) {
      return _errorResponse("Something went wrong.");
    }
  }

  // Delete Plan (Admin only)
  static Future<Map<String, dynamic>> deletePlan(
    String token,
    String planId,
  ) async {
    try {
      final response = await http
          .delete(
            Uri.parse("$baseUrl/admin/plans/$planId"),
            headers: {"Authorization": "Bearer $token"},
          )
          .timeout(_timeout);

      return jsonDecode(response.body);
    } on TimeoutException {
      return _errorResponse("Connection timed out.");
    } on SocketException {
      return _errorResponse("Unable to connect to server.");
    } catch (e) {
      return _errorResponse("Something went wrong.");
    }
  }

  // Update Plan (Admin only)
  static Future<Map<String, dynamic>> updatePlan(
    String token,
    String planId,
    String title,
    String description,
    double roi,
    String duration,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse("$baseUrl/admin/plans/$planId"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode({
              "title": title,
              "description": description,
              "roi": roi,
              "duration": duration,
            }),
          )
          .timeout(_timeout);

      return jsonDecode(response.body);
    } on TimeoutException {
      return _errorResponse("Connection timed out.");
    } on SocketException {
      return _errorResponse("Unable to connect to server.");
    } catch (e) {
      return _errorResponse("Something went wrong.");
    }
  }
}
