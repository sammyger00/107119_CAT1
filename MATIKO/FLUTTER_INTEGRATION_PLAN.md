# Flutter POS Integration Plan

## Objective
Develop a mobile application for Agents to verify tickets and potentiality sell tickets (via STK push).

## Prerequisites
- Flutter SDK installed and configured
- Backend API running at `http://localhost:8001/api/v1` (or accessible IP)
- Test Agent Account (`agent@matiko.com` / `password`)

## tech Stack
- **Framework**: Flutter
- **State Management**: Provider (simple and effective)
- **HTTP Client**: `http` package
- **Storage**: `flutter_secure_storage` (for JWT token)
- **QR Scanning**: `mobile_scanner` or `qr_code_scanner`

## Implementation Steps

### 1. Project Setup
- Verify Flutter environment.
- Create new project `matiko_pos`.
- Add dependencies:
  ```yaml
  dependencies:
    flutter:
      sdk: flutter
    http: ^1.2.0
    flutter_secure_storage: ^9.0.0
    provider: ^6.1.1
    mobile_scanner: ^5.0.0
    intl: ^0.19.0
  ```

### 2. Services Layer
Create `lib/services/`
- **`api_service.dart`**: Base class for HTTP requests, handling Authorization header injection.
- **`auth_service.dart`**: Handle login, logout, and token storage.
- **`ticket_service.dart`**: Handle ticket verification and scanning.

### 3. Models Layer
Create `lib/models/`
- **`user.dart`**: User profile and role.
- **`ticket.dart`**: Ticket details (event, category, status).
- **`api_response.dart`**: standardized response wrapper.

### 4. UI Layer
Create `lib/screens/`
- **`login_screen.dart`**: Email/Password input.
- **`home_screen.dart`**: Dashboard showing basic stats or actions.
- **`scanner_screen.dart`**: Camera view for scanning QR codes.
- **`ticket_result_screen.dart`**: Show valid/invalid status and check-in button.

### 5. Integration Flow

#### Authentication
1. User enters credentials.
2. App calls `POST /api/v1/login`.
3. Save `token` to secure storage.
4. Navigate to Home.

#### Ticket Verification
1. Agent taps "Scan Ticket".
2. Camera opens (permission requested).
3. Scan QR code (content = Ticket Code).
4. App calls `POST /api/v1/tickets/scan` with code.
5. Display result:
   - **Valid**: Show Event, Category, Holder. Button "Check In".
   - **Invalid**: Show red error.
   - **Already Used**: Show warning.

#### Check-In
1. On valid ticket screen, Agent taps "Check In".
2. App calls `POST /api/v1/tickets/check-in`.
3. Success message shown.
4. Navigate back to scan.

## Development Tasks

1. [ ] Initialize Flutter Project
2. [ ] Configure `pubspec.yaml`
3. [ ] Implement `AuthService`
4. [ ] Build Login Screen
5. [ ] Build Scanner Screen
6. [ ] Implement Ticket Verification Logic
7. [ ] Test with backend

## API Endpoints Reference
- Base: `http://localhost:8001/api/v1`
- Login: `POST /login`
- Scan: `POST /tickets/scan`
- Check-In: `POST /tickets/check-in`

## Notes
- Ensure CORS is configured on backend if running on web, or allow cleartext traffic on Android `AndroidManifest.xml` for local testing.
- Use `10.0.2.2` for localhost emulator access.
