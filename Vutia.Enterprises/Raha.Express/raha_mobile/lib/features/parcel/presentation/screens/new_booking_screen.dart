import 'package:flutter/material.dart';

class NewBookingScreen extends StatefulWidget {
  const NewBookingScreen({super.key});

  @override
  State<NewBookingScreen> createState() => _NewBookingScreenState();
}

class _NewBookingScreenState extends State<NewBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Form controllers
  final _senderNameController = TextEditingController();
  final _senderPhoneController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _weightController = TextEditingController();

  String? _selectedOriginStation;
  String? _selectedDestinationStation;
  String _selectedPaymentMethod = 'mpesa';
  bool _isLoading = false;

  // Sample stations - in production, fetch from API
  final List<Map<String, String>> _stations = [
    {'id': '1', 'name': 'Nairobi CBD'},
    {'id': '2', 'name': 'Mombasa'},
    {'id': '3', 'name': 'Kisumu'},
    {'id': '4', 'name': 'Nakuru'},
    {'id': '5', 'name': 'Eldoret'},
    {'id': '6', 'name': 'Thika'},
    {'id': '7', 'name': 'Nyeri'},
    {'id': '8', 'name': 'Machakos'},
  ];

  @override
  void dispose() {
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _descriptionController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  List<Step> get _steps => [
    Step(
      title: const Text('Sender'),
      subtitle: const Text('Sender details'),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: _buildSenderStep(),
    ),
    Step(
      title: const Text('Recipient'),
      subtitle: const Text('Recipient details'),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: _buildRecipientStep(),
    ),
    Step(
      title: const Text('Parcel'),
      subtitle: const Text('Parcel details'),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      content: _buildParcelStep(),
    ),
    Step(
      title: const Text('Payment'),
      subtitle: const Text('Payment method'),
      isActive: _currentStep >= 3,
      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      content: _buildPaymentStep(),
    ),
  ];

  Widget _buildSenderStep() {
    return Column(
      children: [
        TextFormField(
          controller: _senderNameController,
          decoration: const InputDecoration(
            labelText: 'Sender Name',
            hintText: 'Enter sender\'s full name',
            prefixIcon: Icon(Icons.person_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter sender name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _senderPhoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Sender Phone',
            hintText: '07XXXXXXXX',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter sender phone';
            }
            if (value.length < 10) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedOriginStation,
          decoration: const InputDecoration(
            labelText: 'Origin Station',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          items: _stations.map((station) {
            return DropdownMenuItem(
              value: station['id'],
              child: Text(station['name']!),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedOriginStation = value);
          },
          validator: (value) {
            if (value == null) {
              return 'Please select origin station';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRecipientStep() {
    return Column(
      children: [
        TextFormField(
          controller: _recipientNameController,
          decoration: const InputDecoration(
            labelText: 'Recipient Name',
            hintText: 'Enter recipient\'s full name',
            prefixIcon: Icon(Icons.person_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter recipient name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _recipientPhoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Recipient Phone',
            hintText: '07XXXXXXXX',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter recipient phone';
            }
            if (value.length < 10) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedDestinationStation,
          decoration: const InputDecoration(
            labelText: 'Destination Station',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          items: _stations.map((station) {
            return DropdownMenuItem(
              value: station['id'],
              child: Text(station['name']!),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedDestinationStation = value);
          },
          validator: (value) {
            if (value == null) {
              return 'Please select destination station';
            }
            if (value == _selectedOriginStation) {
              return 'Destination must be different from origin';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildParcelStep() {
    return Column(
      children: [
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Parcel Description',
            hintText: 'Describe the parcel contents',
            prefixIcon: Icon(Icons.inventory_2_outlined),
            alignLabelWithHint: true,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter parcel description';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _weightController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Weight (kg)',
            hintText: 'Enter parcel weight',
            prefixIcon: Icon(Icons.scale_outlined),
            suffixText: 'kg',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter parcel weight';
            }
            final weight = double.tryParse(value);
            if (weight == null || weight <= 0) {
              return 'Please enter a valid weight';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        Card(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimated Cost',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'KES ${_calculateEstimatedCost()}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStep() {
    return Column(
      children: [
        RadioListTile<String>(
          value: 'mpesa',
          groupValue: _selectedPaymentMethod,
          onChanged: (value) {
            setState(() => _selectedPaymentMethod = value!);
          },
          title: const Text('M-Pesa'),
          subtitle: const Text('Pay via M-Pesa STK Push'),
          secondary: Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/M-PESA_LOGO-01.svg/512px-M-PESA_LOGO-01.svg.png',
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.phone_android),
          ),
        ),
        RadioListTile<String>(
          value: 'cash',
          groupValue: _selectedPaymentMethod,
          onChanged: (value) {
            setState(() => _selectedPaymentMethod = value!);
          },
          title: const Text('Cash'),
          subtitle: const Text('Pay at the station'),
          secondary: const Icon(Icons.money, size: 40),
        ),
        RadioListTile<String>(
          value: 'bank',
          groupValue: _selectedPaymentMethod,
          onChanged: (value) {
            setState(() => _selectedPaymentMethod = value!);
          },
          title: const Text('Bank Transfer'),
          subtitle: const Text('Pay via Family Bank'),
          secondary: const Icon(Icons.account_balance, size: 40),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                _buildSummaryRow('From', _getStationName(_selectedOriginStation)),
                _buildSummaryRow('To', _getStationName(_selectedDestinationStation)),
                _buildSummaryRow('Sender', _senderNameController.text),
                _buildSummaryRow('Recipient', _recipientNameController.text),
                _buildSummaryRow('Description', _descriptionController.text),
                _buildSummaryRow('Weight', '${_weightController.text} kg'),
                const Divider(),
                _buildSummaryRow('Total', 'KES ${_calculateEstimatedCost()}', isBold: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value.isEmpty ? '-' : value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _getStationName(String? stationId) {
    if (stationId == null) return '-';
    final station = _stations.firstWhere(
      (s) => s['id'] == stationId,
      orElse: () => {'name': '-'},
    );
    return station['name'] ?? '-';
  }

  String _calculateEstimatedCost() {
    final weight = double.tryParse(_weightController.text) ?? 0;
    // Base price of 200 + 50 per kg
    final cost = 200 + (weight * 50);
    return cost.toStringAsFixed(0);
  }

  void _onStepContinue() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      _submitBooking();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
          title: const Text('Booking Successful!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Your parcel has been booked successfully.'),
              const SizedBox(height: 16),
              Text(
                'Tracking Number: TRK${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to dashboard
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Booking'),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: _isLoading ? null : _onStepContinue,
          onStepCancel: _isLoading ? null : _onStepCancel,
          onStepTapped: (step) {
            if (!_isLoading) {
              setState(() => _currentStep = step);
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : details.onStepContinue,
                      child: _isLoading && _currentStep == _steps.length - 1
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_currentStep == _steps.length - 1
                              ? 'Submit Booking'
                              : 'Continue'),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : details.onStepCancel,
                        child: const Text('Back'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: _steps,
        ),
      ),
    );
  }
}
