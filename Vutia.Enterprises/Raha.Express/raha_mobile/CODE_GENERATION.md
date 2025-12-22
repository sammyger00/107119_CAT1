# Code Generation Guide

This project uses code generation for JSON serialization and Retrofit API clients.

## Setup

After cloning the project and adding dependencies, you need to run code generation to create the required `.g.dart` files.

## Commands

### Install dependencies
```bash
flutter pub get
```

### Run code generation (one-time)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Watch mode (auto-regenerate on file changes)
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Clean generated files
```bash
flutter pub run build_runner clean
```

## Generated Files

The following files will be auto-generated:

- `lib/core/network/api_response.g.dart` - JSON serialization for ApiResponse and PaginatedResponse
- `lib/core/network/api_service.g.dart` - Retrofit implementation for ApiService

## When to Run

Run code generation after:
- Initial project setup
- Adding/modifying `@JsonSerializable` classes
- Adding/modifying Retrofit API endpoints
- Pulling changes that affect generated files

## Troubleshooting

If you encounter import errors for `.g.dart` files:
1. Ensure all dependencies are installed: `flutter pub get`
2. Run build_runner: `flutter pub run build_runner build --delete-conflicting-outputs`
3. Restart your IDE/editor

The `--delete-conflicting-outputs` flag automatically resolves conflicts by regenerating files.
