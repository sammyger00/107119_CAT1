# Raha Express Mobile - Implementation TODO Summary

Last Updated: 2025-12-22

## ✅ COMPLETED (Phase 1 & 2 - Data & API Layer)

### Data Models ✅
- [x] `ParcelModel` with all fields, enums, and JSON serialization
- [x] `StationModel` with business logic
- [x] `VehicleModel` with all fields
- [x] `ParcelStatus` enum (Sent, Loaded, Offloaded, Received, Issued)
- [x] `PaymentMethod` enum (7 payment types)
- [x] Generated `.g.dart` files for all models

### API Infrastructure ✅
- [x] `ApiClient` - Dio HTTP client with comprehensive error handling
- [x] `AuthInterceptor` - Automatic Bearer token injection
- [x] `api_constants.dart` - All API endpoints defined
- [x] Custom exception classes (Network, Server, Validation, etc.)
- [x] Response error handling (400, 401, 403, 404, 422, 500)

### API Service ✅
- [x] `ParcelApiService` with Retrofit
- [x] All parcel operations (create, load, offload, receive, issue)
- [x] Tracking endpoint
- [x] Station and vehicle endpoints
- [x] Pagination support
- [x] Response models (ParcelResponse, ParcelListResponse, etc.)
- [x] Generated Retrofit implementation

### Documentation ✅
- [x] `IMPLEMENTATION_PLAN.md` - 500+ line comprehensive guide
- [x] `PARCEL_FEATURES_SUMMARY.md` - Feature progress tracking
- [x] `QUICK_START_GUIDE.md` - Quick reference
- [x] `TEST_CREDENTIALS.md` - Test accounts
- [x] `SETUP_BACKEND.md` - Backend setup
- [x] `IMPLEMENTATION_STATUS.md` - Overall project status

### Backend ✅
- [x] Complete Laravel backend with Filament admin
- [x] Test credentials seeder
- [x] API endpoints ready
- [x] Payment integration (M-Pesa & Family Bank)
- [x] SMS notification system

---

## 📋 PENDING (Phase 3-6)

### Phase 3: Payment Integration ⏳

#### Payment API Service
- [ ] Create `payment_api_service.dart` with Retrofit
- [ ] M-Pesa endpoints:
  - [ ] `POST /payments/mpesa/initiate` - STK Push
  - [ ] `GET /payments/{id}/status` - Check status
- [ ] Family Bank endpoints:
  - [ ] `POST /payments/family-bank/initiate` - STK Push
  - [ ] `GET /payments/{id}/status` - Check status
- [ ] Generate Retrofit code

#### Payment Models
- [ ] `MpesaSTKResponse` model
- [ ] `FamilyBankSTKResponse` model
- [ ] `PaymentStatusResponse` model
- [ ] JSON serialization for all payment models

#### Phone Number Utility
- [ ] Create `phone_formatter.dart` in `lib/core/utils/`
- [ ] `normalizePhoneNumber()` - Convert to 254XXXXXXXXX format
- [ ] Handle prefixes: 0, +254, 254
- [ ] Validation for Kenyan numbers

#### Payment Status Polling
- [ ] Create `payment_polling_service.dart`
- [ ] Poll every 3 seconds for 60 seconds max
- [ ] Return success/failure/timeout status
- [ ] Cancel polling on user navigation

---

### Phase 4: Domain Layer (Repositories & Use Cases) ⏳

#### Repository Interface
- [ ] Create `lib/features/parcel/domain/repositories/parcel_repository.dart`
- [ ] Define abstract methods returning `Either<Failure, Success>`
- [ ] Methods for all parcel operations
- [ ] Error handling contracts

#### Repository Implementation
- [ ] Create `lib/features/parcel/data/repositories/parcel_repository_impl.dart`
- [ ] Implement all methods using API service
- [ ] Convert API exceptions to domain failures
- [ ] Handle network errors gracefully

#### Failure Classes
- [ ] Create `lib/core/errors/failures.dart`
- [ ] `NetworkFailure` - No internet connection
- [ ] `ServerFailure` - Backend server errors
- [ ] `ValidationFailure` - Form validation errors
- [ ] `UnauthorizedFailure` - Authentication errors

#### Parcel Use Cases
Create each in `lib/features/parcel/domain/usecases/`:

- [ ] `send_parcel.dart`
  - Validate: origin != destination
  - Validate: weight >= 0.1 KG
  - Validate: value >= 100 KES
  - Validate: cost <= 50,000 KES
  - Validate: phone number if M-Pesa/Family Bank
  - Call repository.createParcel()

- [ ] `load_parcel.dart`
  - Validate: parcel status is 'Sent'
  - Validate: vehicle_id provided
  - Call repository.loadParcel()

- [ ] `offload_parcel.dart`
  - Validate: parcel status is 'Loaded'
  - Validate: offload mode (Transit/Final)
  - Validate: transit_id if mode is Transit
  - Call repository.offloadParcel()

- [ ] `receive_parcel.dart`
  - Validate: parcel status is 'Offloaded'
  - Call repository.receiveParcel()

- [ ] `issue_parcel.dart`
  - Validate: parcel status is 'Received'
  - Validate: recipient_name provided
  - Validate: recipient_id provided
  - Call repository.issueParcel()

- [ ] `get_parcels.dart`
  - Get paginated list
  - Apply filters (status, search)
  - Station-scoped for non-admin users

- [ ] `track_parcel.dart`
  - Get parcel by parcel number
  - Return status history
  - Return current location

#### Payment Use Cases
Create each in `lib/features/payment/domain/usecases/`:

- [ ] `initiate_mpesa_payment.dart`
  - Normalize phone number
  - Initiate STK push
  - Return checkout request ID

- [ ] `initiate_family_bank_payment.dart`
  - Normalize phone number
  - Initiate STK push
  - Return transaction ID

- [ ] `check_payment_status.dart`
  - Poll payment status
  - Return success/failure/pending

---

### Phase 5: State Management (BLoC) ⏳

#### Parcel BLoC
Create in `lib/features/parcel/presentation/bloc/`:

- [ ] `parcel_event.dart` - Define all events:
  - [ ] `SendParcelEvent`
  - [ ] `LoadParcelEvent`
  - [ ] `OffloadParcelEvent`
  - [ ] `ReceiveParcelEvent`
  - [ ] `IssueParcelEvent`
  - [ ] `FetchParcelsEvent`
  - [ ] `TrackParcelEvent`

- [ ] `parcel_state.dart` - Define all states:
  - [ ] `ParcelInitial`
  - [ ] `ParcelLoading`
  - [ ] `ParcelSuccess` - Single parcel
  - [ ] `ParcelsLoaded` - List of parcels
  - [ ] `ParcelTracking` - Tracking info
  - [ ] `ParcelError` - Error message

- [ ] `parcel_bloc.dart` - Implement BLoC:
  - [ ] Constructor with use case dependencies
  - [ ] Event handlers for each event
  - [ ] Emit appropriate states
  - [ ] Handle errors gracefully

#### Payment BLoC
Create in `lib/features/payment/presentation/bloc/`:

- [ ] `payment_event.dart`:
  - [ ] `InitiateMpesaEvent`
  - [ ] `InitiateFamilyBankEvent`
  - [ ] `CheckPaymentStatusEvent`
  - [ ] `CancelPaymentEvent`

- [ ] `payment_state.dart`:
  - [ ] `PaymentInitial`
  - [ ] `PaymentInitiating` - STK push sent
  - [ ] `PaymentPending` - Waiting for user input
  - [ ] `PaymentPolling` - Checking status
  - [ ] `PaymentSuccess` - Payment complete
  - [ ] `PaymentFailed` - Payment failed
  - [ ] `PaymentTimeout` - No response after 60s

- [ ] `payment_bloc.dart`:
  - [ ] Implement all event handlers
  - [ ] Polling logic with timer
  - [ ] Cancel polling on navigation

#### Dependency Injection
- [ ] Create `lib/injection_container.dart`
- [ ] Register all dependencies with get_it
- [ ] Register singletons (API client, services)
- [ ] Register factories (repositories, use cases, blocs)

---

### Phase 6: Presentation Layer (UI) ⏳

#### Send Parcel Screen
Create `lib/features/parcel/presentation/screens/send_parcel_screen.dart`:

- [ ] Form with validation:
  - [ ] Sender name & phone
  - [ ] Receiver name & phone
  - [ ] Origin station (dropdown)
  - [ ] Destination station (dropdown)
  - [ ] Weight input (numeric, >= 0.1)
  - [ ] Value input (numeric, >= 100)
  - [ ] Cost input (numeric, <= 50000)
  - [ ] Payment method (dropdown)
  - [ ] M-Pesa phone (conditional, if M-Pesa selected)
  - [ ] Description (text area)
- [ ] Submit button
- [ ] Integration with ParcelBloc
- [ ] Show payment dialog if M-Pesa/Family Bank
- [ ] Success message with parcel number

#### Load Parcel Screen
Create `lib/features/parcel/presentation/screens/load_parcel_screen.dart`:

- [ ] Search parcels by number
- [ ] Filter: Status = 'Sent'
- [ ] Vehicle selection dropdown
- [ ] Parcel list with checkboxes (bulk load)
- [ ] Load button
- [ ] Confirmation dialog
- [ ] Success/error messages

#### Offload Parcel Screen
Create `lib/features/parcel/presentation/screens/offload_parcel_screen.dart`:

- [ ] Select vehicle from dropdown
- [ ] List parcels on vehicle (Status = 'Loaded')
- [ ] Offload mode selection (Transit/Final)
- [ ] If Transit: Select transit vehicle
- [ ] Checkboxes for bulk offload
- [ ] Offload button
- [ ] Confirmation dialog

#### Receive Parcel Screen
Create `lib/features/parcel/presentation/screens/receive_parcel_screen.dart`:

- [ ] List parcels with Status = 'Offloaded'
- [ ] Filter by destination = user's station
- [ ] Search by parcel number or phone
- [ ] Checkboxes for bulk receive
- [ ] Receive button
- [ ] Success message

#### Issue Parcel Screen
Create `lib/features/parcel/presentation/screens/issue_parcel_screen.dart`:

- [ ] List parcels with Status = 'Received'
- [ ] Search by parcel number or receiver phone
- [ ] Parcel details display
- [ ] Recipient name input
- [ ] Recipient ID input (National ID/Passport)
- [ ] Optional: Signature capture
- [ ] Issue button
- [ ] Print receipt (optional)

#### Parcel List Screen
Create `lib/features/parcel/presentation/screens/parcel_list_screen.dart`:

- [ ] Paginated list of parcels
- [ ] Filter by status
- [ ] Search by parcel number
- [ ] Pull to refresh
- [ ] Infinite scroll (load more)
- [ ] Navigate to details on tap
- [ ] Station-scoped (automatic)

#### Track Parcel Screen
Create `lib/features/tracking/presentation/screens/track_parcel_screen.dart`:

- [ ] Search by parcel number
- [ ] Display parcel details
- [ ] Status timeline widget
- [ ] Current status highlighted
- [ ] Timestamps for each status
- [ ] User/station info for each transition
- [ ] Refresh button

#### Payment Dialog
Create `lib/features/payment/presentation/widgets/payment_dialog.dart`:

- [ ] Show "Initiating payment..." message
- [ ] Show "Check your phone for M-Pesa prompt"
- [ ] Show payment polling progress
- [ ] Show success message
- [ ] Show failure message with retry option
- [ ] Show timeout message
- [ ] Cancel button

#### Common Widgets
Create in `lib/features/parcel/presentation/widgets/`:

- [ ] `parcel_card.dart` - Display parcel in list
- [ ] `status_badge.dart` - Colored status badge
- [ ] `parcel_details_card.dart` - Full parcel details
- [ ] `station_dropdown.dart` - Reusable station selector
- [ ] `vehicle_dropdown.dart` - Reusable vehicle selector
- [ ] `loading_indicator.dart` - Custom loading widget
- [ ] `error_message.dart` - Error display widget

---

## 🧪 Testing TODO

### Unit Tests ⏳
- [ ] Model tests (serialization/deserialization)
- [ ] Use case tests (business logic)
- [ ] Repository tests (API calls)
- [ ] Phone formatter tests
- [ ] Validation tests

### Widget Tests ⏳
- [ ] Form validation tests
- [ ] Button interaction tests
- [ ] Navigation tests
- [ ] BLoC integration tests

### Integration Tests ⏳
- [ ] End-to-end parcel workflow
- [ ] Payment flow
- [ ] Authentication flow
- [ ] Error handling

---

## 🔧 Configuration TODO

### Environment Setup ⏳
- [ ] Configure backend URL in `api_constants.dart`
- [ ] Set up environment variables (if needed)
- [ ] Configure flavor-specific settings (dev/staging/prod)

### Backend Setup ⏳
- [ ] Upgrade PHP to 8.2+ in Laragon
- [ ] Install composer dependencies
- [ ] Run migrations
- [ ] Seed test data
- [ ] Start development server

### Testing Setup ⏳
- [ ] Test backend connectivity from mobile app
- [ ] Test authentication flow
- [ ] Test parcel creation
- [ ] Test M-Pesa sandbox
- [ ] Test Family Bank sandbox

---

## 📊 Priority Levels

### High Priority (MVP - Minimum Viable Product)
1. ✅ Data models
2. ✅ API client
3. ✅ Parcel API service
4. 🔴 Payment API service
5. 🔴 Repositories
6. 🔴 Core use cases (send, load, offload, receive, issue)
7. 🔴 Parcel BLoC
8. 🔴 Send parcel screen
9. 🔴 Load parcel screen
10. 🔴 Issue parcel screen

### Medium Priority (Full Feature Set)
11. 🟡 Payment BLoC
12. 🟡 Payment dialog
13. 🟡 Offload parcel screen
14. 🟡 Receive parcel screen
15. 🟡 Parcel list screen
16. 🟡 Track parcel screen
17. 🟡 Phone formatter utility
18. 🟡 Payment polling service

### Low Priority (Nice to Have)
19. 🟢 Signature capture on issue
20. 🟢 Print receipt
21. 🟢 QR code scanner
22. 🟢 Offline caching
23. 🟢 Push notifications
24. 🟢 Analytics

---

## ⏱️ Time Estimates

**To MVP (Items 1-10)**: 2-3 days of focused development
- Repositories & Use Cases: 4-6 hours
- BLoC State Management: 4-6 hours
- UI Screens (MVP): 8-12 hours
- Testing & Bug Fixes: 4-6 hours

**To Full Feature Set (Items 1-18)**: 4-5 days
- Additional screens: 6-8 hours
- Payment integration: 4-6 hours
- Polish & refinement: 4-6 hours

**Total (All Features)**: 5-7 days

---

## 🎯 Next Immediate Steps

1. **Create Payment API Service** (30 min)
   - M-Pesa and Family Bank endpoints
   - Payment models
   - Generate Retrofit code

2. **Implement Repositories** (1-2 hours)
   - Abstract interface
   - Concrete implementation
   - Error handling

3. **Create Core Use Cases** (2-3 hours)
   - SendParcel
   - LoadParcel
   - IssueParcel (minimum for MVP)

4. **Build Parcel BLoC** (2-3 hours)
   - Events, States, BLoC
   - Dependency injection

5. **Create Send Parcel Screen** (3-4 hours)
   - Form UI
   - Validation
   - BLoC integration
   - Payment dialog

---

## 📝 Notes

- All models and API services are complete and generated
- Backend is ready but needs PHP upgrade to run
- Documentation is comprehensive and up-to-date
- Follow Clean Architecture principles
- Use BLoC for state management
- Keep UI simple and focused on functionality first
- Add polish and animations later

---

**Status**: Phase 1 & 2 Complete (30% of total work)
**Next Phase**: Payment Service → Repositories → Use Cases → BLoC → UI

**Target**: MVP ready for testing in 2-3 days of focused development
