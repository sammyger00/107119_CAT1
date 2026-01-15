import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanning = false;

  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
    controller?.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!isScanning && scanData.code != null) {
        setState(() {
          isScanning = true;
        });
        _verifyTicket(scanData.code!);
      }
    });
  }

  void _verifyTicket(String code) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final authService = AuthService();
      final headers = await authService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('${authService.baseUrl}/agent/scan-ticket'),
        headers: headers,
        body: jsonEncode({'qr_code': code}),
      );

      final data = jsonDecode(response.body);

      if (mounted) {
        Navigator.pop(context); // Pop loading
        if (response.statusCode == 200) {
          _showTicketResult(data);
        } else {
          _showError(data['message'] ?? 'Invalid ticket');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop loading
        _showError('Connection error: $e');
      }
    }
  }

  void _showTicketResult(Map<String, dynamic> ticketData) {
    final ticket = ticketData['ticket'];
    final isValid = ticketData['valid'];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isValid ? Icons.check_circle : Icons.error,
              color: isValid ? Colors.green : Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              isValid ? 'Ticket Valid' : 'Ticket Invalid',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (ticket != null) ...[
              Text('Ticket ID: ${ticket['id']}'),
              Text('Event: ${ticket['order']['event']['name']}'),
              Text('Customer: ${ticket['order']['user']['name']}'),
              Text(
                'Status: ${ticket['is_checked_in'] ? 'Already Used' : 'Valid'}',
              ),
            ],
            const SizedBox(height: 24),
            if (isValid && ticket != null && !ticket['is_checked_in'])
              ElevatedButton(
                onPressed: () => _checkInTicket(ticket['qr_code']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Check In'),
              ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  isScanning = false;
                });
              },
              child: const Text('Back to Scanner'),
            ),
          ],
        ),
      ),
    );
  }

  void _checkInTicket(String qrCode) async {
    Navigator.pop(context); // Close result modal

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final authService = AuthService();
      final headers = await authService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('${authService.baseUrl}/v1/tickets/check-in'),
        headers: headers,
        body: jsonEncode({'qr_code': qrCode}),
      );

      if (mounted) {
        Navigator.pop(context); // Pop loading
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Check-in successful!')));
        } else {
          final data = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Check-in failed')),
          );
        }
        setState(() {
          isScanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop loading
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Connection error: $e')));
        setState(() {
          isScanning = false;
        });
      }
    }
  }

  void _showError(String message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Error',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  isScanning = false;
                });
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Ticket')),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.teal,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Center(
              child: Text('Point the camera at the ticket QR code'),
            ),
          ),
        ],
      ),
    );
  }
}
