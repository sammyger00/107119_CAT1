import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../parcel/data/services/parcel_service.dart';
import '../../../station/data/services/station_service.dart';
import '../../../payment/data/services/payment_service.dart';
import '../../../../core/storage/secure_storage.dart';

class CourierDashboardScreen extends StatefulWidget {
  const CourierDashboardScreen({super.key});

  @override
  State<CourierDashboardScreen> createState() => _CourierDashboardScreenState();
}

class _CourierDashboardScreenState extends State<CourierDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ParcelListScreen(),
    const ScanParcelScreen(),
    const CourierProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Parcels',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Parcel List Screen with status filters
class ParcelListScreen extends StatefulWidget {
  const ParcelListScreen({super.key});

  @override
  State<ParcelListScreen> createState() => _ParcelListScreenState();
}

class _ParcelListScreenState extends State<ParcelListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ParcelService _parcelService = ParcelService();
  final StationService _stationService = StationService();

  List<dynamic> _parcels = [];
  List<dynamic> _vehicles = [];
  bool _isLoading = false;
  String _currentStatus = 'Sent';
  String? _errorMessage;

  final List<Map<String, dynamic>> _statusTabs = [
    {'label': 'Sent', 'status': 'Sent', 'color': Colors.blue},
    {'label': 'Loaded', 'status': 'Loaded', 'color': Colors.orange},
    {'label': 'Offloaded', 'status': 'Offloaded', 'color': Colors.purple},
    {'label': 'Received', 'status': 'Received', 'color': Colors.teal},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadParcels();
    _loadVehicles();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _currentStatus = _statusTabs[_tabController.index]['status'];
      });
      _loadParcels();
    }
  }

  Future<void> _loadParcels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _parcelService.getParcels(status: _currentStatus);

      if (response['success'] == true) {
        setState(() {
          _parcels = response['data'] ?? [];
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load parcels';
        });
      }
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?['message'] ?? 'Network error occurred';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadVehicles() async {
    try {
      final response = await _stationService.getVehicles();
      if (response['success'] == true) {
        setState(() {
          _vehicles = response['data'] ?? [];
        });
      }
    } catch (e) {
      // Silently fail - vehicles will be empty
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parcel Operations'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _statusTabs.map((tab) => Tab(
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: tab['color'],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(tab['label']),
              ],
            ),
          )).toList(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadParcels,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadParcels,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_parcels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No $_currentStatus parcels',
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadParcels,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _parcels.length,
        itemBuilder: (context, index) {
          final parcel = _parcels[index];
          return _buildParcelCard(parcel);
        },
      ),
    );
  }

  Widget _buildParcelCard(Map<String, dynamic> parcel) {
    final status = parcel['status'] ?? 'Unknown';
    final statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showParcelActions(parcel),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    parcel['parcel_number'] ?? 'N/A',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('From', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        Text(
                          parcel['origin_station']?['name'] ?? 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.grey),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('To', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        Text(
                          parcel['destination_station']?['name'] ?? 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        parcel['receiver_name'] ?? 'N/A',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Text(
                    'KES ${parcel['cost']?.toString() ?? '0'}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Sent':
        return Colors.blue;
      case 'Loaded':
        return Colors.orange;
      case 'Offloaded':
        return Colors.purple;
      case 'Received':
        return Colors.teal;
      case 'Issued':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showParcelActions(Map<String, dynamic> parcel) {
    final status = parcel['status'] ?? '';
    final parcelId = parcel['id'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                parcel['parcel_number'] ?? 'N/A',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildDetailRow('Receiver', parcel['receiver_name'] ?? 'N/A'),
              _buildDetailRow('Phone', parcel['receiver_phone_number'] ?? 'N/A'),
              _buildDetailRow('Description', parcel['description'] ?? 'N/A'),
              _buildDetailRow('Weight', '${parcel['weight'] ?? 0} kg'),
              _buildDetailRow('Cost', 'KES ${parcel['cost'] ?? 0}'),
              const SizedBox(height: 24),
              Text(
                'Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildActionButtons(status, parcelId, parcel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String status, int parcelId, Map<String, dynamic> parcel) {
    switch (status) {
      case 'Sent':
        return _buildLoadButton(parcelId);
      case 'Loaded':
        return _buildOffloadButton(parcelId);
      case 'Offloaded':
        return _buildReceiveButton(parcelId);
      case 'Received':
        return _buildIssueButton(parcelId, parcel);
      default:
        return const Text('No actions available');
    }
  }

  Widget _buildLoadButton(int parcelId) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLoadDialog(parcelId),
        icon: const Icon(Icons.upload),
        label: const Text('Load onto Vehicle'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildOffloadButton(int parcelId) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showOffloadDialog(parcelId),
        icon: const Icon(Icons.download),
        label: const Text('Offload from Vehicle'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildReceiveButton(int parcelId) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _receiveParcel(parcelId),
        icon: const Icon(Icons.check_circle),
        label: const Text('Receive at Station'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildIssueButton(int parcelId, Map<String, dynamic> parcel) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showIssueDialog(parcelId, parcel),
            icon: const Icon(Icons.person_add),
            label: const Text('Issue to Recipient'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showPaymentDialog(parcelId, parcel),
            icon: const Icon(Icons.payment),
            label: const Text('Process Payment'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _showLoadDialog(int parcelId) {
    int? selectedVehicleId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Load Parcel'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select a vehicle to load this parcel onto:'),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedVehicleId,
                decoration: const InputDecoration(
                  labelText: 'Vehicle',
                  border: OutlineInputBorder(),
                ),
                items: _vehicles.map<DropdownMenuItem<int>>((vehicle) {
                  return DropdownMenuItem<int>(
                    value: vehicle['id'],
                    child: Text(vehicle['registration_number'] ?? 'Unknown'),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() => selectedVehicleId = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedVehicleId == null
                  ? null
                  : () {
                      Navigator.pop(context);
                      _loadParcel(parcelId, selectedVehicleId!);
                    },
              child: const Text('Load'),
            ),
          ],
        ),
      ),
    );
  }

  void _showOffloadDialog(int parcelId) {
    String offloadMode = 'Final';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Offload Parcel'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select offload mode:'),
              const SizedBox(height: 16),
              RadioListTile<String>(
                title: const Text('Final Destination'),
                subtitle: const Text('Parcel has arrived at destination station'),
                value: 'Final',
                groupValue: offloadMode,
                onChanged: (value) {
                  setDialogState(() => offloadMode = value!);
                },
              ),
              RadioListTile<String>(
                title: const Text('Transit'),
                subtitle: const Text('Parcel will be loaded onto another vehicle'),
                value: 'Transit',
                groupValue: offloadMode,
                onChanged: (value) {
                  setDialogState(() => offloadMode = value!);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _offloadParcel(parcelId, offloadMode);
              },
              child: const Text('Offload'),
            ),
          ],
        ),
      ),
    );
  }

  void _showIssueDialog(int parcelId, Map<String, dynamic> parcel) {
    final nameController = TextEditingController(text: parcel['receiver_name'] ?? '');
    final idController = TextEditingController();
    final phoneController = TextEditingController(text: parcel['receiver_phone_number'] ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Issue Parcel'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter recipient details:'),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Recipient Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter recipient name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: idController,
                decoration: const InputDecoration(
                  labelText: 'ID Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter ID number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (Optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                _issueParcel(
                  parcelId,
                  nameController.text,
                  idController.text,
                  phoneController.text.isNotEmpty ? phoneController.text : null,
                );
              }
            },
            child: const Text('Issue'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(int parcelId, Map<String, dynamic> parcel) {
    String paymentMethod = 'mpesa';
    final phoneController = TextEditingController();
    final cost = parcel['cost']?.toString() ?? '0';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Process Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Amount: KES $cost', style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
              const SizedBox(height: 16),
              RadioListTile<String>(
                title: Row(
                  children: [
                    Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/M-PESA_LOGO-01.svg/512px-M-PESA_LOGO-01.svg.png',
                      width: 24,
                      height: 24,
                      errorBuilder: (_, __, ___) => const Icon(Icons.phone_android, size: 24),
                    ),
                    const SizedBox(width: 8),
                    const Text('M-Pesa'),
                  ],
                ),
                value: 'mpesa',
                groupValue: paymentMethod,
                onChanged: (value) {
                  setDialogState(() => paymentMethod = value!);
                },
              ),
              RadioListTile<String>(
                title: const Row(
                  children: [
                    Icon(Icons.account_balance, size: 24),
                    SizedBox(width: 8),
                    Text('Family Bank'),
                  ],
                ),
                value: 'family_bank',
                groupValue: paymentMethod,
                onChanged: (value) {
                  setDialogState(() => paymentMethod = value!);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '07XXXXXXXX',
                  border: OutlineInputBorder(),
                  prefixText: '+254 ',
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a phone number')),
                  );
                  return;
                }
                Navigator.pop(context);
                _processPayment(parcelId, paymentMethod, phoneController.text);
              },
              child: const Text('Send STK Push'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadParcel(int parcelId, int vehicleId) async {
    _showLoadingDialog('Loading parcel...');

    try {
      final response = await _parcelService.loadParcel(parcelId, vehicleId);
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      Navigator.pop(context); // Close action sheet

      if (response['success'] == true) {
        _showSuccessSnackBar('Parcel loaded successfully');
        _loadParcels();
      } else {
        _showErrorSnackBar(response['message'] ?? 'Failed to load parcel');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showErrorSnackBar('Error loading parcel');
    }
  }

  Future<void> _offloadParcel(int parcelId, String mode) async {
    _showLoadingDialog('Offloading parcel...');

    try {
      final response = await _parcelService.offloadParcel(parcelId, offloadedMode: mode);
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      Navigator.pop(context); // Close action sheet

      if (response['success'] == true) {
        _showSuccessSnackBar('Parcel offloaded successfully');
        _loadParcels();
      } else {
        _showErrorSnackBar(response['message'] ?? 'Failed to offload parcel');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showErrorSnackBar('Error offloading parcel');
    }
  }

  Future<void> _receiveParcel(int parcelId) async {
    _showLoadingDialog('Receiving parcel...');

    try {
      final response = await _parcelService.receiveParcel(parcelId);
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      Navigator.pop(context); // Close action sheet

      if (response['success'] == true) {
        _showSuccessSnackBar('Parcel received successfully. SMS sent to receiver.');
        _loadParcels();
      } else {
        _showErrorSnackBar(response['message'] ?? 'Failed to receive parcel');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showErrorSnackBar('Error receiving parcel');
    }
  }

  Future<void> _issueParcel(int parcelId, String name, String id, String? phone) async {
    _showLoadingDialog('Issuing parcel...');

    try {
      final response = await _parcelService.issueParcel(
        parcelId,
        recipientName: name,
        recipientId: id,
        recipientPhone: phone,
      );
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      Navigator.pop(context); // Close action sheet

      if (response['success'] == true) {
        _showSuccessSnackBar('Parcel issued successfully. SMS sent to sender.');
        _loadParcels();
      } else {
        _showErrorSnackBar(response['message'] ?? 'Failed to issue parcel');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showErrorSnackBar('Error issuing parcel');
    }
  }

  Future<void> _processPayment(int parcelId, String method, String phone) async {
    final paymentService = PaymentService();
    _showLoadingDialog('Initiating payment...');

    try {
      Map<String, dynamic> response;

      if (method == 'mpesa') {
        response = await paymentService.initiateMpesa(
          parcelId: parcelId,
          phoneNumber: phone,
        );
      } else {
        response = await paymentService.initiateFamilyBank(
          parcelId: parcelId,
          phoneNumber: phone,
        );
      }

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (response['success'] == true) {
        _showSuccessSnackBar(response['message'] ?? 'Payment initiated. Check your phone.');
      } else {
        _showErrorSnackBar(response['message'] ?? 'Failed to initiate payment');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showErrorSnackBar('Error processing payment');
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// Scan Parcel Screen - for quick parcel lookup
class ScanParcelScreen extends StatefulWidget {
  const ScanParcelScreen({super.key});

  @override
  State<ScanParcelScreen> createState() => _ScanParcelScreenState();
}

class _ScanParcelScreenState extends State<ScanParcelScreen> {
  final _searchController = TextEditingController();
  final ParcelService _parcelService = ParcelService();
  bool _isSearching = false;
  Map<String, dynamic>? _parcelResult;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchParcel() async {
    if (_searchController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a parcel number')),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _parcelResult = null;
    });

    try {
      final response = await _parcelService.trackParcel(_searchController.text.trim());

      if (response['success'] == true) {
        setState(() {
          _parcelResult = response['data'];
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Parcel not found';
        });
      }
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?['message'] ?? 'Parcel not found';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred while searching';
      });
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan / Search Parcel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter Parcel Number',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'e.g., 12345678',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('QR Scanner coming soon')),
                            );
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (_) => _searchParcel(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSearching ? null : _searchParcel,
                        icon: _isSearching
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.search),
                        label: Text(_isSearching ? 'Searching...' : 'Search'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
              ),
            if (_parcelResult != null) _buildParcelDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildParcelDetails() {
    final parcel = _parcelResult!['parcel'];
    final statusHistory = _parcelResult!['status_history'] as List? ?? [];
    final currentStatus = _parcelResult!['current_status'] ?? 'Unknown';

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      parcel['parcel_number'] ?? 'N/A',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(currentStatus).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        currentStatus,
                        style: TextStyle(
                          color: _getStatusColor(currentStatus),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildInfoRow(Icons.person_outline, 'Sender', parcel['sender_name'] ?? 'N/A'),
                _buildInfoRow(Icons.person, 'Receiver', parcel['receiver_name'] ?? 'N/A'),
                _buildInfoRow(Icons.location_on_outlined, 'From', parcel['origin_station']?['name'] ?? 'N/A'),
                _buildInfoRow(Icons.location_on, 'To', parcel['destination_station']?['name'] ?? 'N/A'),
                _buildInfoRow(Icons.scale, 'Weight', '${parcel['weight'] ?? 0} kg'),
                _buildInfoRow(Icons.attach_money, 'Cost', 'KES ${parcel['cost'] ?? 0}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (statusHistory.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status History',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...statusHistory.map((item) => _buildTimelineItem(item)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: Colors.grey[600])),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getStatusColor(item['status'] ?? ''),
              ),
              child: const Icon(Icons.check, size: 16, color: Colors.white),
            ),
            Container(
              width: 2,
              height: 40,
              color: Colors.grey[300],
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['status'] ?? 'Unknown',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (item['timestamp'] != null)
                Text(
                  item['timestamp'].toString(),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              if (item['user'] != null)
                Text(
                  'By: ${item['user']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Sent':
        return Colors.blue;
      case 'Loaded':
        return Colors.orange;
      case 'Offloaded':
        return Colors.purple;
      case 'Received':
        return Colors.teal;
      case 'Issued':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

// Courier Profile Screen
class CourierProfileScreen extends StatelessWidget {
  const CourierProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Staff User',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Station Staff',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    Icons.history,
                    'Activity Log',
                    'View your recent activities',
                    () => _showComingSoon(context, 'Activity Log'),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.settings,
                    'Settings',
                    'App preferences',
                    () => _showComingSoon(context, 'Settings'),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.help_outline,
                    'Help & Support',
                    'Get help or contact us',
                    () => _showComingSoon(context, 'Help & Support'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text('Log Out', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon')),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await SecureStorage().clear();
              if (!context.mounted) return;
              Navigator.pop(context);
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
