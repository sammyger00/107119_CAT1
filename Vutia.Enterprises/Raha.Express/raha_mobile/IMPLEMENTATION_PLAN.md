# Mobile App Implementation Plan - Raha Express

This document outlines the implementation plan for the Flutter mobile app to match the Laravel backend functionality.

## Overview

The mobile app will implement the complete parcel lifecycle with payment integration:
- **Parcel Operations:** Send, Load, Offload, Receive, Issue
- **Payment Integration:** M-Pesa STK Push, Family Bank STK Push
- **Status Tracking:** Real-time parcel status with history
- **Station Scoping:** Role-based access control

## Architecture

### Clean Architecture Layers

```
lib/
├── core/
│   ├── constants/          # API endpoints, app constants
│   ├── errors/             # Error handling
│   ├── network/            # HTTP client, interceptors
│   └── utils/              # Helper functions, extensions
│
├── features/
│   ├── auth/               # Authentication (Sanctum)
│   ├── parcel/             # Parcel management
│   │   ├── data/
│   │   │   ├── models/     # Parcel, Station, Vehicle models
│   │   │   ├── datasources/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/   # SendParcel, LoadParcel, etc.
│   │   └── presentation/
│   │       ├── screens/
│   │       ├── widgets/
│   │       └── bloc/       # State management
│   │
│   ├── payment/            # Payment integration
│   │   ├── data/
│   │   │   ├── models/     # Payment models
│   │   │   ├── datasources/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   └── usecases/   # InitiateMpesa, InitiateFamilyBank
│   │   └── presentation/
│   │
│   └── tracking/           # Parcel tracking
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── main.dart
```

---

## Phase 1: Core Setup & Data Models

### 1.1 API Client Setup

**File:** `lib/core/network/api_client.dart`

```dart
class ApiClient {
  final Dio _dio;
  static const String baseUrl = 'http://YOUR_BACKEND_URL/api/v1';

  ApiClient() : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  )) {
    _dio.interceptors.add(AuthInterceptor()); // Add Bearer token
    _dio.interceptors.add(LoggingInterceptor()); // Log requests
  }
}
```

### 1.2 Data Models

**Parcel Model:** `lib/features/parcel/data/models/parcel_model.dart`

```dart
class ParcelModel {
  final int? id;
  final String parcelNumber;
  final String senderName;
  final String senderPhoneNumber;
  final String receiverName;
  final String receiverPhoneNumber;
  final int originStationId;
  final int destinationStationId;
  final double weight;
  final double value;
  final double cost;
  final PaymentMethod paymentMethod;
  final String? mpesaPhoneNumber;
  final String description;
  final ParcelStatus status;

  // Status tracking fields
  final int? sentBy;
  final DateTime? sentAt;
  final int? loadedBy;
  final DateTime? loadedAt;
  final int? vehicleId;
  final int? offloadedBy;
  final DateTime? offloadedAt;
  final String? offloadedMode; // 'Transit' or 'Final'
  final int? transitId;
  final int? receivedBy;
  final DateTime? receivedAt;
  final int? issuedBy;
  final DateTime? issuedAt;
  final String? recipientName;
  final String? recipientId;

  // Relations
  final StationModel? originStation;
  final StationModel? destinationStation;
  final VehicleModel? vehicle;

  factory ParcelModel.fromJson(Map<String, dynamic> json) {
    return ParcelModel(
      id: json['id'],
      parcelNumber: json['parcel_number'],
      senderName: json['sender_name'],
      // ... map all fields
      status: ParcelStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status']
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender_name': senderName,
      'sender_phone_number': senderPhoneNumber,
      'receiver_name': receiverName,
      'receiver_phone_number': receiverPhoneNumber,
      'origin_station_id': originStationId,
      'destination_station_id': destinationStationId,
      'weight': weight,
      'value': value,
      'cost': cost,
      'payment_method': paymentMethod.toApiString(),
      'description': description,
      if (mpesaPhoneNumber != null) 'mpesa_phone_number': mpesaPhoneNumber,
    };
  }
}

enum ParcelStatus {
  sent,
  loaded,
  offloaded,
  received,
  issued
}

enum PaymentMethod {
  cash,
  mpesa,
  familyBank,
  notPaid,
  cashOnIssue,
  mpesaOnIssue,
  familyBankOnIssue
}

extension PaymentMethodExtension on PaymentMethod {
  String toApiString() {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.mpesa:
        return 'M-Pesa';
      case PaymentMethod.familyBank:
        return 'Family Bank';
      case PaymentMethod.notPaid:
        return 'Not Paid';
      case PaymentMethod.cashOnIssue:
        return 'Cash on Issue';
      case PaymentMethod.mpesaOnIssue:
        return 'M-Pesa on Issue';
      case PaymentMethod.familyBankOnIssue:
        return 'Family Bank on Issue';
    }
  }
}
```

**Station Model:** `lib/features/parcel/data/models/station_model.dart`

```dart
class StationModel {
  final int id;
  final String name;
  final String? sendingPhoneNumber;
  final String? receivingPhoneNumber;
  final String? openingTime;
  final String? closingTime;
  final String? stationType; // 'main' or 'branch'

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      id: json['id'],
      name: json['name'],
      sendingPhoneNumber: json['sending_phone_number'],
      receivingPhoneNumber: json['receiving_phone_number'],
      openingTime: json['opening_time'],
      closingTime: json['closing_time'],
      stationType: json['station_type'],
    );
  }
}
```

**Vehicle Model:** `lib/features/parcel/data/models/vehicle_model.dart`

```dart
class VehicleModel {
  final int id;
  final String name;
  final String registrationNumber;
  final String? driverName;
  final String? driverPhone;

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'],
      name: json['name'],
      registrationNumber: json['registration_number'],
      driverName: json['driver_name'],
      driverPhone: json['driver_phone'],
    );
  }
}
```

---

## Phase 2: Parcel Operations

### 2.1 Send Parcel Feature

**Use Case:** `lib/features/parcel/domain/usecases/send_parcel.dart`

```dart
class SendParcel {
  final ParcelRepository repository;

  Future<Either<Failure, ParcelModel>> call(SendParcelParams params) async {
    // Validate params
    if (params.originStationId == params.destinationStationId) {
      return Left(ValidationFailure('Origin and destination must be different'));
    }
    if (params.weight < 0.1) {
      return Left(ValidationFailure('Weight must be at least 0.1 KG'));
    }
    if (params.value < 100) {
      return Left(ValidationFailure('Value must be at least 100 KES'));
    }
    if (params.cost > 50000) {
      return Left(ValidationFailure('Cost cannot exceed 50,000 KES'));
    }

    return await repository.createParcel(params);
  }
}

class SendParcelParams {
  final String senderName;
  final String senderPhoneNumber;
  final String receiverName;
  final String receiverPhoneNumber;
  final int originStationId;
  final int destinationStationId;
  final double weight;
  final double value;
  final double cost;
  final PaymentMethod paymentMethod;
  final String? mpesaPhoneNumber;
  final String description;
}
```

**API Implementation:** `lib/features/parcel/data/datasources/parcel_remote_datasource.dart`

```dart
abstract class ParcelRemoteDataSource {
  Future<ParcelModel> createParcel(SendParcelParams params);
  Future<ParcelModel> loadParcel(int parcelId, int vehicleId);
  Future<ParcelModel> offloadParcel(int parcelId, String mode, int? transitId);
  Future<ParcelModel> receiveParcel(int parcelId);
  Future<ParcelModel> issueParcel(int parcelId, String recipientName, String recipientId);
  Future<List<ParcelModel>> getParcels({int page = 1});
  Future<ParcelTrackingResponse> trackParcel(String parcelNumber);
}

class ParcelRemoteDataSourceImpl implements ParcelRemoteDataSource {
  final ApiClient client;

  @override
  Future<ParcelModel> createParcel(SendParcelParams params) async {
    final response = await client.post('/parcels', data: params.toJson());
    return ParcelModel.fromJson(response.data['parcel']);
  }

  @override
  Future<ParcelModel> loadParcel(int parcelId, int vehicleId) async {
    final response = await client.post(
      '/parcels/$parcelId/load',
      data: {'vehicle_id': vehicleId},
    );
    return ParcelModel.fromJson(response.data['parcel']);
  }

  @override
  Future<ParcelModel> offloadParcel(int parcelId, String mode, int? transitId) async {
    final response = await client.post(
      '/parcels/$parcelId/offload',
      data: {
        'offloaded_mode': mode,
        if (transitId != null) 'transit_id': transitId,
      },
    );
    return ParcelModel.fromJson(response.data['parcel']);
  }

  @override
  Future<ParcelModel> receiveParcel(int parcelId) async {
    final response = await client.post('/parcels/$parcelId/receive');
    return ParcelModel.fromJson(response.data['parcel']);
  }

  @override
  Future<ParcelModel> issueParcel(
    int parcelId,
    String recipientName,
    String recipientId,
  ) async {
    final response = await client.post(
      '/parcels/$parcelId/issue',
      data: {
        'recipient_name': recipientName,
        'recipient_id': recipientId,
      },
    );
    return ParcelModel.fromJson(response.data['parcel']);
  }

  @override
  Future<ParcelTrackingResponse> trackParcel(String parcelNumber) async {
    final response = await client.get('/parcels/track/$parcelNumber');
    return ParcelTrackingResponse.fromJson(response.data);
  }
}
```

### 2.2 UI Screens

**Send Parcel Screen:** `lib/features/parcel/presentation/screens/send_parcel_screen.dart`

Features:
- Form with sender/receiver details
- Station selection (origin/destination)
- Weight/value/cost input
- Payment method selector
- M-Pesa phone number (if M-Pesa selected)
- Submit button (triggers SendParcel use case)

**Load Parcel Screen:** `lib/features/parcel/presentation/screens/load_parcel_screen.dart`

Features:
- Search parcels by parcel number
- Filter by status=Sent
- Vehicle selection dropdown
- Bulk load (select multiple parcels)
- Confirm load button

**Offload Parcel Screen:** `lib/features/parcel/presentation/screens/offload_parcel_screen.dart`

Features:
- List parcels on selected vehicle
- Offload mode selector (Transit/Final)
- If Transit: Select transit vehicle
- Confirm offload button

**Receive Parcel Screen:** `lib/features/parcel/presentation/screens/receive_parcel_screen.dart`

Features:
- List offloaded parcels for user's station
- Filter by destination_station_id = user.station_id
- Bulk receive option
- Confirm receive button

**Issue Parcel Screen:** `lib/features/parcel/presentation/screens/issue_parcel_screen.dart`

Features:
- List received parcels
- Search by parcel number or receiver phone
- Recipient name input
- Recipient ID input
- Confirm issue button
- Optional: Signature capture

---

## Phase 3: Payment Integration

### 3.1 M-Pesa Integration

**Service:** `lib/features/payment/data/datasources/mpesa_remote_datasource.dart`

```dart
class MpesaRemoteDataSource {
  final ApiClient client;

  Future<MpesaSTKResponse> initiateStkPush({
    required int parcelId,
    required String phoneNumber,
  }) async {
    // Normalize phone number to 254 format
    String normalizedPhone = _normalizePhoneNumber(phoneNumber);

    final response = await client.post(
      '/payments/mpesa/initiate',
      data: {
        'parcel_id': parcelId,
        'phone_number': normalizedPhone,
      },
    );

    return MpesaSTKResponse.fromJson(response.data);
  }

  Future<PaymentStatusResponse> checkPaymentStatus(String transactionId) async {
    final response = await client.get('/payments/$transactionId/status');
    return PaymentStatusResponse.fromJson(response.data);
  }

  String _normalizePhoneNumber(String phone) {
    // Remove all non-digits
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Convert to 254 format
    if (cleaned.startsWith('0')) {
      return '254${cleaned.substring(1)}';
    } else if (!cleaned.startsWith('254')) {
      return '254$cleaned';
    }
    return cleaned;
  }
}

class MpesaSTKResponse {
  final String checkoutRequestId;
  final String merchantRequestId;
  final String responseCode;

  bool get isSuccess => responseCode == '0';

  factory MpesaSTKResponse.fromJson(Map<String, dynamic> json) {
    return MpesaSTKResponse(
      checkoutRequestId: json['checkout_request_id'],
      merchantRequestId: json['merchant_request_id'],
      responseCode: json['response_code'],
    );
  }
}
```

**UI Flow:**

1. User selects M-Pesa payment method when creating parcel
2. App shows payment confirmation dialog
3. On confirm, initiate STK push
4. Show "Check your phone..." message
5. Poll payment status every 3 seconds for 60 seconds
6. On success: Show success message, parcel created
7. On timeout: Show "Payment pending" message

### 3.2 Family Bank Integration

**Service:** `lib/features/payment/data/datasources/family_bank_remote_datasource.dart`

```dart
class FamilyBankRemoteDataSource {
  final ApiClient client;

  Future<FamilyBankSTKResponse> initiateStkPush({
    required int parcelId,
    required String phoneNumber,
  }) async {
    String normalizedPhone = _normalizePhoneNumber(phoneNumber);

    final response = await client.post(
      '/payments/family-bank/initiate',
      data: {
        'parcel_id': parcelId,
        'phone_number': normalizedPhone,
      },
    );

    return FamilyBankSTKResponse.fromJson(response.data);
  }
}

class FamilyBankSTKResponse {
  final String? transactionId;
  final String? status;

  bool get isSuccess => status == 'success';

  factory FamilyBankSTKResponse.fromJson(Map<String, dynamic> json) {
    return FamilyBankSTKResponse(
      transactionId: json['transaction_id'],
      status: json['status'],
    );
  }
}
```

---

## Phase 4: Parcel Tracking

### 4.1 Tracking Feature

**Model:** `lib/features/tracking/data/models/tracking_model.dart`

```dart
class ParcelTrackingResponse {
  final ParcelModel parcel;
  final List<StatusHistoryItem> statusHistory;
  final String currentStatus;

  factory ParcelTrackingResponse.fromJson(Map<String, dynamic> json) {
    return ParcelTrackingResponse(
      parcel: ParcelModel.fromJson(json['parcel']),
      statusHistory: (json['status_history'] as List)
          .map((item) => StatusHistoryItem.fromJson(item))
          .toList(),
      currentStatus: json['current_status'],
    );
  }
}

class StatusHistoryItem {
  final String status;
  final DateTime timestamp;
  final String? userName;
  final String? stationName;
  final String? vehicleName;

  factory StatusHistoryItem.fromJson(Map<String, dynamic> json) {
    return StatusHistoryItem(
      status: json['status'],
      timestamp: DateTime.parse(json['timestamp']),
      userName: json['user'],
      stationName: json['station'],
      vehicleName: json['vehicle'],
    );
  }
}
```

**UI:** `lib/features/tracking/presentation/screens/track_parcel_screen.dart`

Features:
- Search by parcel number
- Display parcel details
- Timeline view of status history
- Current location indicator
- Estimated delivery (if available)

---

## Phase 5: State Management (BLoC)

### 5.1 Parcel BLoC

**File:** `lib/features/parcel/presentation/bloc/parcel_bloc.dart`

```dart
// Events
abstract class ParcelEvent extends Equatable {}

class SendParcelEvent extends ParcelEvent {
  final SendParcelParams params;
}

class LoadParcelEvent extends ParcelEvent {
  final int parcelId;
  final int vehicleId;
}

class OffloadParcelEvent extends ParcelEvent {
  final int parcelId;
  final String mode;
  final int? transitId;
}

class ReceiveParcelEvent extends ParcelEvent {
  final int parcelId;
}

class IssueParcelEvent extends ParcelEvent {
  final int parcelId;
  final String recipientName;
  final String recipientId;
}

class FetchParcelsEvent extends ParcelEvent {}

// States
abstract class ParcelState extends Equatable {}

class ParcelInitial extends ParcelState {}
class ParcelLoading extends ParcelState {}
class ParcelSuccess extends ParcelState {
  final ParcelModel parcel;
}
class ParcelsLoaded extends ParcelState {
  final List<ParcelModel> parcels;
}
class ParcelError extends ParcelState {
  final String message;
}

// BLoC
class ParcelBloc extends Bloc<ParcelEvent, ParcelState> {
  final SendParcel sendParcel;
  final LoadParcel loadParcel;
  final OffloadParcel offloadParcel;
  final ReceiveParcel receiveParcel;
  final IssueParcel issueParcel;
  final GetParcels getParcels;

  ParcelBloc({
    required this.sendParcel,
    required this.loadParcel,
    // ... other use cases
  }) : super(ParcelInitial()) {
    on<SendParcelEvent>(_onSendParcel);
    on<LoadParcelEvent>(_onLoadParcel);
    on<OffloadParcelEvent>(_onOffloadParcel);
    on<ReceiveParcelEvent>(_onReceiveParcel);
    on<IssueParcelEvent>(_onIssueParcel);
    on<FetchParcelsEvent>(_onFetchParcels);
  }

  Future<void> _onSendParcel(
    SendParcelEvent event,
    Emitter<ParcelState> emit,
  ) async {
    emit(ParcelLoading());
    final result = await sendParcel(event.params);
    result.fold(
      (failure) => emit(ParcelError(failure.message)),
      (parcel) => emit(ParcelSuccess(parcel)),
    );
  }

  // ... implement other event handlers
}
```

---

## Implementation Checklist

### Phase 1: Core Setup ✓
- [ ] API client with Dio
- [ ] Auth interceptor for Bearer token
- [ ] Error handling framework
- [ ] Parcel data model
- [ ] Station data model
- [ ] Vehicle data model
- [ ] Payment models

### Phase 2: Parcel Operations
- [ ] Send parcel use case
- [ ] Load parcel use case
- [ ] Offload parcel use case
- [ ] Receive parcel use case
- [ ] Issue parcel use case
- [ ] Get parcels list use case
- [ ] Remote data sources
- [ ] Repository implementation
- [ ] Send parcel screen
- [ ] Load parcel screen
- [ ] Offload parcel screen
- [ ] Receive parcel screen
- [ ] Issue parcel screen

### Phase 3: Payment Integration
- [ ] M-Pesa STK push implementation
- [ ] Family Bank STK push implementation
- [ ] Payment status polling
- [ ] Phone number normalization utility
- [ ] Payment confirmation dialogs
- [ ] Payment success/failure handling

### Phase 4: Tracking
- [ ] Track parcel use case
- [ ] Tracking data models
- [ ] Track parcel screen
- [ ] Status timeline widget
- [ ] QR code scanner (optional)

### Phase 5: State Management
- [ ] Parcel BLoC setup
- [ ] Payment BLoC setup
- [ ] Tracking BLoC setup
- [ ] BLoC integration in screens
- [ ] Loading states
- [ ] Error handling

### Phase 6: Testing
- [ ] Unit tests for use cases
- [ ] Widget tests for screens
- [ ] Integration tests for workflows
- [ ] API mocking for tests

---

## Key Implementation Notes

1. **Phone Number Format:** Always normalize to `254XXXXXXXXX` before API calls
2. **Status Flow Enforcement:** Validate status transitions client-side before API call
3. **Payment Polling:** Poll status for max 60 seconds with 3-second intervals
4. **Station Scoping:** Filter parcels by user's station_id on list screens
5. **Offline Support:** Cache parcels locally using Hive/SQLite for offline viewing
6. **Error Handling:** Use Either<Failure, Success> pattern from dartz package
7. **Loading States:** Show skeleton loaders, not just spinners
8. **Form Validation:** Match backend validation rules exactly
9. **SMS Notification:** Inform users that SMS will be sent (don't implement in app)
10. **Security:** Never store API keys in code; use environment variables

---

## Dependencies Required

```yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  dartz: ^0.10.1
  dio: ^5.3.3
  get_it: ^7.6.4
  injectable: ^2.3.2
  retrofit: ^4.0.3
  json_annotation: ^4.8.1
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0

dev_dependencies:
  build_runner: ^2.4.6
  retrofit_generator: ^8.0.4
  json_serializable: ^6.7.1
  injectable_generator: ^2.4.0
  mockito: ^5.4.2
  bloc_test: ^9.1.5
```

---

## Next Steps

1. Review and approve this implementation plan
2. Set up project dependencies
3. Implement Phase 1 (Core Setup)
4. Test with backend API
5. Implement Phase 2-5 incrementally
6. Conduct thorough testing
7. Deploy to staging environment

---

This implementation plan ensures the Flutter mobile app exactly replicates the Laravel backend parcel workflow and payment integration logic.
