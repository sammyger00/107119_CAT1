# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Structure

This is a monorepo for **Raha Express**, a comprehensive parcel/courier management platform consisting of three integrated applications:

```
Raha.Express/
├── raha-express/          # Backend API & Admin Panel (Laravel 12 + Filament 3)
│   ├── app/               # Laravel application code
│   ├── desktop/           # Electron print service (bundled with backend)
│   ├── database/          # Migrations, seeders, factories
│   ├── config/            # Laravel & service configurations
│   └── CLAUDE.md          # Detailed backend documentation (READ THIS FIRST)
└── raha_mobile/           # Mobile application (Flutter - early stage)
    ├── lib/               # Flutter application code
    ├── android/           # Android platform code
    ├── ios/               # iOS platform code
    └── web/               # Web platform code
```

## Quick Start by Project

### Backend (raha-express/)
```bash
cd raha-express

# Install dependencies
composer install
npm install

# Environment setup
cp .env.example .env
php artisan key:generate

# Database setup
php artisan migrate

# Start all services (server, queue, logs, vite)
composer dev

# Run tests
composer test
```

**See [raha-express/CLAUDE.md](raha-express/CLAUDE.md) for comprehensive backend documentation.**

### Mobile App (raha_mobile/)
```bash
cd raha_mobile

# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build for specific platform
flutter build apk              # Android
flutter build ios              # iOS (macOS only)
flutter build web              # Web
```

**Note:** The mobile app is in early development stage with minimal implementation.

### Print Service (raha-express/desktop/)
```bash
cd raha-express/desktop

# Install dependencies
npm install

# Run in development
npm run dev

# Build for distribution
npm run build:mac              # macOS
npm run build:win              # Windows
npm run build                  # Both platforms
```

**See [raha-express/desktop/README.md](raha-express/desktop/README.md) for detailed print service documentation.**

## High-Level Architecture

### System Overview
```
┌─────────────────┐
│  Mobile App     │ (Flutter - iOS/Android)
│  raha_mobile/   │
└────────┬────────┘
         │ REST API
         ↓
┌─────────────────────────────────────────────────────┐
│  Backend Server & Admin Panel                       │
│  raha-express/ (Laravel 12 + Filament 3)           │
│                                                      │
│  ┌──────────────┐  ┌─────────────┐  ┌───────────┐ │
│  │ REST API     │  │ Admin Panel │  │ Queue     │ │
│  │ (Sanctum)    │  │ (Filament)  │  │ (SMS/Jobs)│ │
│  └──────────────┘  └─────────────┘  └───────────┘ │
│                                                      │
│  ┌──────────────────────────────────────────────┐  │
│  │ Services:                                     │  │
│  │ • M-Pesa STK Push                            │  │
│  │ • Family Bank IPN callbacks                  │  │
│  │ • SMS notifications (queued)                 │  │
│  │ • PDF generation (receipts/labels)           │  │
│  └──────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
         │
         ↓ HTTPS API (port 3333)
┌─────────────────────────────────┐
│  Desktop Print Service           │
│  raha-express/desktop/          │
│  (Electron)                     │
│                                  │
│  • Silent thermal printing      │
│  • System tray application      │
│  • Auto-generated TLS certs     │
└─────────────────────────────────┘
```

### Data Flow

**Parcel Lifecycle:**
1. Parcel created at origin station (Status: `Sent`)
2. Loaded onto vehicle (Status: `Loaded`)
3. Transported and offloaded at destination (Status: `Offloaded`)
4. Received at destination station (Status: `Received`)
5. Issued to recipient (Status: `Issued`)

**Payment Processing:**
- M-Pesa STK Push initiated from admin panel
- Family Bank IPN callbacks received at `/api/family-bank/ipn/`
- Transactions logged in database with reconciliation

**Printing Workflow:**
1. Admin panel triggers print action
2. JavaScript attempts HTTPS call to `https://127.0.0.1:3333/print`
3. If print service running: Silent print via thermal printer
4. If service offline: Fallback to browser print dialog

## Core Domain Entities

These entities span across all applications:

- **Parcel** - Core entity tracked through the system
- **Station** - Origin/destination locations for parcels
- **Vehicle** - Transport vehicles with manifests
- **VehicleManifest** - Trip records with passengers and deductions
- **DeliveryNote** - Groups parcels for delivery operations
- **User** - Staff accounts with station assignments and role-based access
- **Customer** - Parcel senders/recipients
- **MpesaTransaction** - Payment transaction records
- **Sms** - SMS notification logs

## Technology Stack Summary

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Backend** | Laravel 12 | REST API & business logic |
| **Admin Panel** | Filament 3 | CRUD operations & management UI |
| **Database** | MySQL/MariaDB | Data persistence |
| **Queue** | Laravel Queue | Async jobs (SMS, exports) |
| **Mobile** | Flutter 3.10+ | Cross-platform mobile app |
| **Print Service** | Electron 39 | Silent thermal printing |
| **Frontend Assets** | Vite 6 + Tailwind CSS 4 | Admin panel styling |
| **Payments** | M-Pesa + Family Bank APIs | Payment processing |
| **PDF Generation** | DomPDF | Receipts & labels |

## Development Workflow

### Working on Backend Features
1. Read [raha-express/CLAUDE.md](raha-express/CLAUDE.md) for detailed conventions
2. Make sure all services are running: `cd raha-express && composer dev`
3. Code changes trigger hot reload via Vite
4. Queue worker processes background jobs
5. Run tests with `composer test` before committing

### Working on Mobile App
1. Ensure backend is running and accessible
2. Configure API endpoints in Flutter app
3. Use `flutter run` for hot reload during development
4. Test on multiple platforms (iOS/Android/Web as needed)

### Working on Print Service
1. Ensure backend is running (provides PDFs to print)
2. Launch print service: `cd raha-express/desktop && npm run dev`
3. Configure printer settings via system tray icon
4. Test with actual print jobs from admin panel

## Key Conventions

- **All Laravel models use soft deletes** - Records marked `deleted_at` not removed
- **Station-scoped access** - Station users only see their station's data via `byStationParcels` scope
- **Queued jobs for side effects** - SMS, exports, and notifications run async
- **Filament Shield for RBAC** - Role-based access control integrated throughout
- **Code formatting** - Use Laravel Pint: `./vendor/bin/pint`
- **Testing** - PHPUnit for backend, no mobile tests yet

## Configuration Files

### Backend (.env required)
```bash
# Database
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_DATABASE=raha_express

# M-Pesa API
MPESA_CONSUMER_KEY=
MPESA_CONSUMER_SECRET=
MPESA_SHORTCODE=
MPESA_PASSKEY=

# Family Bank API
FAMILY_BANK_API_KEY=
FAMILY_BANK_MERCHANT_CODE=

# SMS Provider
SMS_API_KEY=
SMS_SENDER_ID=

# Queue (use database or redis in production)
QUEUE_CONNECTION=database
```

### Print Service (.env optional)
```bash
PRINT_SERVICE_PORT=3333
PRINT_SERVICE_TOKEN=          # Optional auth token
PRINT_SERVICE_ALLOWED_ORIGINS=https://app.rahaexpress.co.ke,http://localhost:8000
```

## Deployment

- **Backend**: Standard Laravel deployment (Apache/Nginx + PHP-FPM + MySQL)
- **Mobile**: Build and publish to App Store/Play Store
- **Print Service**: Distribute as desktop installer (DMG for macOS, NSIS for Windows)

## Common Tasks

### Adding a New Parcel Status
1. Update `Parcel` model enum/constants
2. Update Filament resource status badge colors
3. Add status transition logic in appropriate controllers/observers
4. Update SMS templates if status triggers notification
5. Run tests to verify status flow

### Adding a New Payment Gateway
1. Create service class in `app/Services/` (follow `MpesaService` pattern)
2. Add configuration to `config/services.php`
3. Create migration for transaction log table
4. Add webhook route in `routes/api.php`
5. Create controller to handle IPN callbacks
6. Add Filament resource for transaction management

### Adding a New Filament Resource
```bash
cd raha-express
php artisan make:filament-resource ModelName
```
Then implement authorization via Filament Shield policies.

## Testing Strategy

### Backend
- **Unit tests**: Service classes, helpers, utilities
- **Feature tests**: HTTP endpoints, Filament actions, queue jobs
- **Browser tests**: Not currently implemented

### Mobile
- **Widget tests**: Not currently implemented
- **Integration tests**: Not currently implemented

### Print Service
- Manual testing with actual thermal printers

## Important Notes

- **Print service must run locally** on workstations that need thermal printing
- **Queue worker must be running** for SMS and background jobs to process
- **M-Pesa and Family Bank credentials** are production-sensitive - never commit
- **Filament Shield** roles are seeded during deployment - don't modify in migrations
- **Soft deletes are enforced** - use `forceDelete()` only when absolutely necessary

## Further Reading

- [raha-express/CLAUDE.md](raha-express/CLAUDE.md) - Comprehensive backend documentation (**START HERE for backend work**)
- [raha-express/desktop/README.md](raha-express/desktop/README.md) - Print service API and architecture
- [Laravel 12 Documentation](https://laravel.com/docs/12.x)
- [Filament 3 Documentation](https://filamentphp.com/docs/3.x)
- [Flutter Documentation](https://docs.flutter.dev/)
