# Parcel Features Implementation Summary - Raha Express Mobile

This document summarizes the parcel management features implemented in the mobile app based on the Laravel backend.

## ✅ Completed

### 1. Data Models Created

#### ParcelModel (`lib/features/parcel/data/models/parcel_model.dart`)
Complete parcel model matching backend schema with:
- All parcel fields (sender, receiver, stations, weight, value, cost)
- Payment method enum (Cash, M-Pesa, Family Bank, Not Paid, etc.)
- Parcel status enum (Sent, Loaded, Offloaded, Received, Issued)
- Status tracking fields (sent_by, loaded_by, offloaded_by, received_by, issued_by with timestamps)
- Relations (origin/destination stations, vehicle, transit vehicle)
- Helper methods (toCreateJson, copyWith, payment method extensions)

#### StationModel (`lib/features/parcel/data/models/station_model.dart`)
Station model with:
- Basic fields (id, name, phone numbers, hours)
- Station type (main/branch)
- Receipt type (thermal/SMS)
- isOpen getter to check if station is currently open

#### VehicleModel (`lib/features/parcel/data/models/vehicle_model.dart`)
Vehicle model with:
- Basic fields (id, name, registration number)
- Driver information (name, phone)
- Vehicle type and description

### 2. Documentation Created

#### Implementation Plan (`IMPLEMENTATION_PLAN.md`)
Comprehensive 500+ line implementation guide covering:
- Clean Architecture structure
- Phase-by-phase implementation plan
- Data models specification
- API integration details
- Payment integration (M-Pesa & Family Bank)
- BLoC state management
- UI screen specifications
- Dependencies and setup instructions

#### Backend Analysis
Complete backend workflow analysis including:
- Parcel status flow (Sent → Loaded → Offloaded → Received → Issued)
- Database schema and relationships
- API endpoints for each operation
- Payment integration details (STK Push, IPN callbacks)
- SMS notification system
- Business validations

### 3. Dependencies Added
- `dartz: ^0.10.1` - For functional programming (Either, Option)

## 📋 Next Steps

### Phase 1: Generate Model Files & Create API Service
```bash
# Run in raha_mobile directory
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate:
- `parcel_model.g.dart`
- `station_model.g.dart`
- `vehicle_model.g.dart`

### Phase 2: Create API Client & Services

Files to create:
1. `lib/core/network/api_client.dart` - Dio HTTP client
2. `lib/core/network/auth_interceptor.dart` - Bearer token injection
3. `lib/core/constants/api_endpoints.dart` - API URL constants
4. `lib/features/parcel/data/datasources/parcel_api_service.dart` - Retrofit API service
5. `lib/features/payment/data/datasources/payment_api_service.dart` - Payment APIs

### Phase 3: Repository & Use Cases

Files to create:
1. `lib/features/parcel/domain/repositories/parcel_repository.dart` - Abstract repository
2. `lib/features/parcel/data/repositories/parcel_repository_impl.dart` - Implementation
3. `lib/features/parcel/domain/usecases/send_parcel.dart`
4. `lib/features/parcel/domain/usecases/load_parcel.dart`
5. `lib/features/parcel/domain/usecases/offload_parcel.dart`
6. `lib/features/parcel/domain/usecases/receive_parcel.dart`
7. `lib/features/parcel/domain/usecases/issue_parcel.dart`
8. `lib/features/parcel/domain/usecases/get_parcels.dart`
9. `lib/features/parcel/domain/usecases/track_parcel.dart`

### Phase 4: State Management (BLoC)

Files to create:
1. `lib/features/parcel/presentation/bloc/parcel_bloc.dart`
2. `lib/features/parcel/presentation/bloc/parcel_event.dart`
3. `lib/features/parcel/presentation/bloc/parcel_state.dart`
4. `lib/features/payment/presentation/bloc/payment_bloc.dart`

### Phase 5: UI Screens

Files to create:
1. `lib/features/parcel/presentation/screens/send_parcel_screen.dart`
2. `lib/features/parcel/presentation/screens/load_parcel_screen.dart`
3. `lib/features/parcel/presentation/screens/offload_parcel_screen.dart`
4. `lib/features/parcel/presentation/screens/receive_parcel_screen.dart`
5. `lib/features/parcel/presentation/screens/issue_parcel_screen.dart`
6. `lib/features/parcel/presentation/screens/parcel_list_screen.dart`
7. `lib/features/tracking/presentation/screens/track_parcel_screen.dart`
8. `lib/features/payment/presentation/widgets/payment_dialog.dart`

### Phase 6: Payment Integration

Files to create:
1. `lib/features/payment/data/models/mpesa_response.dart`
2. `lib/features/payment/data/models/family_bank_response.dart`
3. `lib/features/payment/data/datasources/mpesa_service.dart`
4. `lib/features/payment/data/datasources/family_bank_service.dart`
5. `lib/core/utils/phone_formatter.dart` - Phone number normalization

## 🎯 Key Implementation Requirements

### Parcel Workflow
1. **Status Flow Validation**
   - Enforce exact sequence: Sent → Loaded → Offloaded → Received → Issued
   - Validate current status before allowing transition
   - Display appropriate UI based on current status

2. **Station Scoping**
   - Filter parcels by user's station_id
   - Show only parcels where station is origin OR destination
   - Super admins see all parcels

3. **Form Validations**
   - Weight >= 0.1 KG
   - Value >= 100 KES
   - Cost <= 50,000 KES
   - Origin != Destination
   - M-Pesa phone required if payment method is M-Pesa

### Payment Integration
1. **Phone Number Formatting**
   - Always normalize to `254XXXXXXXXX` format
   - Handle `0` prefix, `+254` prefix, or plain number

2. **M-Pesa STK Push**
   - Generate access token before each request
   - Send STK push to Safaricom API
   - Poll payment status every 3 seconds for 60 seconds
   - Show "Check your phone" message

3. **Family Bank STK Push**
   - Generate access token (different endpoint than M-Pesa)
   - Send STK push to Family Bank API
   - Handle callback/IPN responses

4. **Payment Status Polling**
   ```dart
   // Pseudo-code
   Future<void> pollPaymentStatus(String transactionId) async {
     for (int i = 0; i < 20; i++) { // 20 attempts x 3 seconds = 60 seconds
       await Future.delayed(Duration(seconds: 3));
       final status = await checkPaymentStatus(transactionId);
       if (status.isComplete || status.isFailed) {
         break;
       }
     }
   }
   ```

### API Endpoints to Implement

```dart
// Parcel Operations
POST   /api/v1/parcels                  // Create parcel
GET    /api/v1/parcels                  // List parcels
GET    /api/v1/parcels/{id}             // Get parcel
GET    /api/v1/parcels/track/{number}   // Track by parcel number
POST   /api/v1/parcels/{id}/load        // Load onto vehicle
POST   /api/v1/parcels/{id}/offload     // Offload from vehicle
POST   /api/v1/parcels/{id}/receive     // Receive at station
POST   /api/v1/parcels/{id}/issue       // Issue to recipient

// Payment Operations
POST   /api/v1/payments/mpesa/initiate  // M-Pesa STK Push
POST   /api/v1/payments/family-bank/initiate  // Family Bank STK Push
GET    /api/v1/payments/{txnId}/status  // Check payment status

// Reference Data
GET    /api/v1/stations                 // List stations
GET    /api/v1/vehicles                 // List vehicles
```

## 🔧 Commands Reference

### Development
```bash
# Get dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes (auto-regenerate)
flutter pub run build_runner watch

# Clean build
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# Run on specific device
flutter run -d <device-id>

# Hot reload: Press 'r' in terminal
# Hot restart: Press 'R' in terminal
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/parcel/parcel_bloc_test.dart

# Run with coverage
flutter test --coverage
```

## 📊 Progress Tracking

### Models ✅ (Complete)
- [x] ParcelModel with all fields and enums
- [x] StationModel
- [x] VehicleModel
- [ ] PaymentResponseModel (M-Pesa)
- [ ] PaymentResponseModel (Family Bank)
- [ ] TrackingModel

### API Layer ⏳ (Pending)
- [ ] API Client setup
- [ ] Auth Interceptor
- [ ] Parcel API Service (Retrofit)
- [ ] Payment API Service
- [ ] Error handling

### Business Logic ⏳ (Pending)
- [ ] Parcel Repository
- [ ] Send Parcel Use Case
- [ ] Load Parcel Use Case
- [ ] Offload Parcel Use Case
- [ ] Receive Parcel Use Case
- [ ] Issue Parcel Use Case
- [ ] Track Parcel Use Case
- [ ] M-Pesa Payment Use Case
- [ ] Family Bank Payment Use Case

### State Management ⏳ (Pending)
- [ ] Parcel BLoC
- [ ] Payment BLoC
- [ ] Tracking BLoC

### UI Screens ⏳ (Pending)
- [ ] Send Parcel Screen
- [ ] Load Parcel Screen
- [ ] Offload Parcel Screen
- [ ] Receive Parcel Screen
- [ ] Issue Parcel Screen
- [ ] Parcel List Screen
- [ ] Track Parcel Screen
- [ ] Payment Dialog
- [ ] Status Timeline Widget

### Integration ⏳ (Pending)
- [ ] Configure backend API URL
- [ ] Test authentication flow
- [ ] Test parcel creation
- [ ] Test status transitions
- [ ] Test M-Pesa payment
- [ ] Test Family Bank payment
- [ ] Test parcel tracking

## 🚨 Important Notes

1. **Code Generation Required**: The `.g.dart` files are not committed to Git. Always run `build_runner` after pulling changes or modifying models.

2. **API URL Configuration**: Update the base URL in `api_client.dart` to point to your backend:
   ```dart
   static const String baseUrl = 'http://YOUR_BACKEND_URL/api/v1';
   ```

3. **Authentication**: All API calls require Bearer token from login. The auth interceptor adds this automatically.

4. **Phone Number Format**: Always normalize to `254XXXXXXXXX` before sending to backend.

5. **Status Flow**: The backend enforces status transitions. Client-side validation prevents invalid API calls.

6. **Payment Callbacks**: The backend handles IPN callbacks from M-Pesa/Family Bank. The mobile app polls for status updates.

7. **Station Scoping**: Non-admin users only see parcels for their assigned station.

8. **SMS Notifications**: Sent by backend, not mobile app. User will receive SMS for Sent, Received, and Issued statuses.

## 📚 Resources

- [Backend Documentation](../raha-express/CLAUDE.md)
- [Implementation Plan](IMPLEMENTATION_PLAN.md)
- [Test Credentials](../TEST_CREDENTIALS.md)
- [Setup Guide](../SETUP_BACKEND.md)
- [Flutter BLoC Documentation](https://bloclibrary.dev/)
- [Retrofit for Flutter](https://pub.dev/packages/retrofit)
- [Dartz Functional Programming](https://pub.dev/packages/dartz)

---

**Status**: Phase 1 Complete (Data Models) ✅
**Next**: Run `flutter pub run build_runner build` to generate model files, then proceed to Phase 2 (API Services).
