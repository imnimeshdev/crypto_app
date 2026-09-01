import 'dart:convert';
import 'package:http/http.dart' as http;
import 'networking_constants.dart';


class ApiService {
  // GET method
  Future<Map<String, dynamic>> get(String endpoint) async {
    final headers = {
      "Content-Type": "application/json",
    };

    final response = await http.get(
      Uri.parse("${NetworkConstants.baseUrl}$endpoint"),
      headers: headers,
    );

    return {
      "statusCode": response.statusCode,
      "body": jsonDecode(response.body),
    };
  }

  // POST method
  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> body) async {
    final headers = {
      "Content-Type": "application/json",
    };

    final response = await http.post(
      Uri.parse("${NetworkConstants.baseUrl}$endpoint"),
      headers: headers,
      body: jsonEncode(body),
    );

    return {
      "statusCode": response.statusCode,
      "body": jsonDecode(response.body),
    };
  }

  // PUT method
  Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> body) async {
    final headers = {
      "Content-Type": "application/json",
    };

    final response = await http.put(
      Uri.parse("${NetworkConstants.baseUrl}$endpoint"),
      headers: headers,
      body: jsonEncode(body),
    );

    return {
      "statusCode": response.statusCode,
      "body": jsonDecode(response.body),
    };
  }

  // DELETE method
  Future<Map<String, dynamic>> delete(String endpoint) async {
    final headers = {
      "Content-Type": "application/json",
    };

    final response = await http.delete(
      Uri.parse("${NetworkConstants.baseUrl}$endpoint"),
      headers: headers,
    );

    return {
      "statusCode": response.statusCode,
      "body": jsonDecode(response.body),
    };
  }
}