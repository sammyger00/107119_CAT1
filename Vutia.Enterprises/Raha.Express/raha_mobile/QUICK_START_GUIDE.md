# Raha Express Mobile App - Quick Start Guide

## ✅ What's Implemented

### Phase 1: Data Layer (COMPLETE)

1. **Data Models** ✅
   - `ParcelModel` - Complete parcel model with status & payment enums
   - `StationModel` - Station information
   - `VehicleModel` - Vehicle information
   - All models have JSON serialization support

2. **API Infrastructure** ✅
   - `ApiClient` - Dio-based HTTP client with error handling
   - `AuthInterceptor` - Automatic Bearer token injection
   - `ParcelApiService` - Retrofit service for all parcel operations
   - Custom exception classes for different error types

3. **API Service Methods** ✅
   - `getParcels()` - List parcels with pagination
   - `createParcel()` - Send new parcel
   - `getParcelById()` - Get single parcel
   - `trackParcel()` - Track by parcel number
   - `loadParcel()` - Load onto vehicle
   - `offloadParcel()` - Offload from vehicle
   - `receiveParcel()` - Receive at station
   - `issueParcel()` - Issue to recipient
   - `getStations()` - List all stations
   - `getVehicles()` - List all vehicles

## 🚀 Running the Code Generator

The API service needs code generation to work. Run this command:

```bash
cd raha_mobile
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate:
- `parcel_api_service.g.dart` - Retrofit implementation

## 📱 Testing the App

The Flutter app is currently running on your Android device. You can:

1. **Hot Reload** - Press `r` in the terminal where the app is running
2. **Hot Restart** - Press `R` in the terminal
3. **Stop App** - Press `q` in the terminal

## 🔄 Next Steps

### To Complete the Implementation:

1. **Generate API Service Code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Create Payment API Service**
   - M-Pesa STK Push integration
   - Family Bank STK Push integration
   - Payment status polling

3. **Implement Repositories**
   - Abstract repository interface
   - Concrete implementation with error handling
   - Convert API exceptions to domain failures

4. **Create Use Cases**
   - SendParcel
   - LoadParcel
   - OffloadParcel
   - ReceiveParcel
   - IssueParcel
   - TrackParcel

5. **Build BLoC State Management**
   - ParcelBloc with events/states
   - PaymentBloc
   - Integration with dependency injection

6. **Create UI Screens**
   - Send Parcel Screen (with form validation)
   - Load Parcel Screen
   - Offload Parcel Screen
   - Receive Parcel Screen
   - Issue Parcel Screen
   - Track Parcel Screen
   - Payment Dialog

## 🔧 Configuration

### Backend URL

Update the backend URL in `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'http://YOUR_IP:8000/api/v1';
```

**Options:**
- Android Emulator: `http://10.0.2.2:8000/api/v1`
- Physical Device: `http://YOUR_LOCAL_IP:8000/api/v1`
- Production: `https://api.rahaexpress.co.ke/api/v1`

### Finding Your Local IP (for physical device testing)

**Windows:**
```bash
ipconfig
# Look for IPv4 Address under your active network adapter
```

**Mac/Linux:**
```bash
ifconfig
# Look for inet address under your active network adapter
```

## 📚 File Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart          # ✅ API endpoints
│   └── network/
│       ├── api_client.dart             # ✅ Dio HTTP client
│       └── auth_interceptor.dart       # ✅ Bearer token handler
│
└── features/
    └── parcel/
        └── data/
            ├── models/
            │   ├── parcel_model.dart       # ✅ Complete
            │   ├── parcel_model.g.dart     # ✅ Generated
            │   ├── station_model.dart      # ✅ Complete
            │   ├── station_model.g.dart    # ✅ Generated
            │   ├── vehicle_model.dart      # ✅ Complete
            │   └── vehicle_model.g.dart    # ✅ Generated
            │
            └── datasources/
                ├── parcel_api_service.dart # ✅ Retrofit service
                └── parcel_api_service.g.dart # ⏳ Needs generation
```

## 🎯 Parcel Status Workflow

The backend enforces this exact status flow:

```
1. Sent      → Parcel created at origin station
2. Loaded    → Parcel loaded onto vehicle (requires vehicle_id)
3. Offloaded → Parcel offloaded (Transit or Final mode)
4. Received  → Parcel received at destination station
5. Issued    → Parcel issued to recipient (requires recipient details)
```

**Important:** Each status transition must happen in order. You cannot skip statuses.

## 💳 Payment Methods

The app supports 7 payment methods (matching backend):

1. **Cash** - Pay at station with cash
2. **M-Pesa** - Mobile money (STK Push)
3. **Family Bank** - Bank payment (STK Push)
4. **Not Paid** - No payment yet
5. **Cash on Issue** - Pay when collecting parcel
6. **M-Pesa on Issue** - Pay via M-Pesa when collecting
7. **Family Bank on Issue** - Pay via bank when collecting

## 🔐 Authentication

The app uses Laravel Sanctum for authentication:

1. User logs in → receives Bearer token
2. Token stored in secure storage (flutter_secure_storage)
3. AuthInterceptor automatically adds token to all requests
4. On 401 error → token cleared, user redirected to login

## 📖 API Response Format

All API responses follow this structure:

```json
{
  "success": true,
  "message": "Operation successful",
  "parcel": { ... },
  "data": { ... }
}
```

The API service handles both `parcel` and `data` keys for flexibility.

## 🐛 Common Issues

### 1. Code Generation Errors

**Problem:** "Target of URI hasn't been generated"

**Solution:**
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Connection Refused

**Problem:** App can't connect to backend

**Solutions:**
- Check backend is running: `cd raha-express && composer dev`
- Update API URL in `api_constants.dart`
- For physical device: Use local IP, not localhost
- Check firewall allows connections on port 8000

### 3. 401 Unauthorized

**Problem:** API returns 401 error

**Solutions:**
- User not logged in - need to authenticate first
- Token expired - need to login again
- Check token is being saved after login

### 4. Validation Errors (422)

**Problem:** API returns validation error

**Solutions:**
- Check all required fields are provided
- Verify data types match backend expectations
- Check phone number format (should be 254XXXXXXXXX)
- Ensure weight >= 0.1 KG
- Ensure value >= 100 KES
- Ensure cost <= 50,000 KES

## 🧪 Testing with Backend

### 1. Start Backend Server

```bash
cd raha-express
composer dev
```

This starts:
- Laravel server on `http://localhost:8000`
- Queue worker for background jobs
- Vite dev server for assets

### 2. Seed Test Data

```bash
cd raha-express
php artisan db:seed --class=TestCredentialsSeeder
```

This creates test users and stations.

### 3. Test API Endpoints

Use Postman or curl to test endpoints:

```bash
# Login
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"courier@rahaexpress.test","password":"password"}'

# Get parcels (use token from login)
curl http://localhost:8000/api/v1/parcels \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## 📊 Implementation Progress

**Overall: 25% Complete**

- ✅ Data Models (100%)
- ✅ API Infrastructure (100%)
- ✅ API Service Definitions (100%)
- ⏳ Payment Integration (0%)
- ⏳ Repositories (0%)
- ⏳ Use Cases (0%)
- ⏳ BLoC State Management (0%)
- ⏳ UI Screens (0%)
- ⏳ Integration Testing (0%)

## 🎓 Learning Resources

- [Retrofit for Flutter](https://pub.dev/packages/retrofit)
- [Dio HTTP Client](https://pub.dev/packages/dio)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)

## 🤝 Getting Help

1. Check the implementation plan: `IMPLEMENTATION_PLAN.md`
2. Review backend documentation: `../raha-express/CLAUDE.md`
3. See test credentials: `../TEST_CREDENTIALS.md`
4. Check overall status: `../IMPLEMENTATION_STATUS.md`

---

**Ready to continue?** Run the build_runner command above to generate the Retrofit code, then proceed with implementing the payment service and repositories!
