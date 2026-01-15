import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class StkPushPage extends StatefulWidget {
  const StkPushPage({super.key});

  @override
  State<StkPushPage> createState() => _StkPushPageState();
}

class _StkPushPageState extends State<StkPushPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _sendStkPush() async {
    if (_phoneController.text.isEmpty || _amountController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _message = null;
      _isSuccess = false;
    });

    try {
      final authService = AuthService();
      final headers = await authService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('${authService.baseUrl}/agent/stk-push'),
        headers: headers,
        body: jsonEncode({
          'phone': _phoneController.text,
          'amount': int.parse(_amountController.text),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _isSuccess = true;
          _message =
              'STK Push sent successfully. Check your phone to complete payment.';
        });
      } else {
        setState(() {
          _message = data['message'] ?? 'Failed to send STK Push';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Connection error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('STK Push')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number (254XXXXXXXXX)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount (KES)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendStkPush,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Send STK Push'),
            ),
            const SizedBox(height: 16),
            if (_message != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _isSuccess
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'STK Push allows customers to pay directly from their mobile money accounts.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
