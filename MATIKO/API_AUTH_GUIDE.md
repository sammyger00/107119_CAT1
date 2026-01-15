# Authentication & Authorization Test Guide

## API Base URL
```
http://localhost:8001/api/v1
```

## Test Users

After running `php artisan migrate:fresh --seed`, you'll have these users:

| Role | Email | Password | Permissions |
|------|-------|----------|-------------|
| Super Admin | superadmin@matiko.com | password | Full system control |
| Admin | admin@matiko.com | password | Manage events, agents |
| Agent | agent@matiko.com | password | Scan tickets, STK push |
| Customer | customer@matiko.com | password | Buy tickets |

## API Endpoints

### 1. Registration (Public)
```http
POST /api/v1/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+254700000000",
  "password": "password123",
  "password_confirmation": "password123"
}
```

**Response:**
```json
{
  "message": "Registration successful",
  "user": {
    "id": 5,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+254700000000",
    "role": "customer",
    "status": "active"
  },
  "token": "1|laravel_sanctum_xxx...",
  "token_type": "Bearer"
}
```

### 2. Login (Public)
```http
POST /api/v1/login
Content-Type: application/json

{
  "email": "customer@matiko.com",
  "password": "password"
}
```

**Response:**
```json
{
  "message": "Login successful",
  "user": {
    "id": 4,
    "name": "Customer User",
    "email": "customer@matiko.com",
    "phone": "+254712345681",
    "role": "customer",
    "status": "active",
    "permissions": [
      "buy tickets",
      "view own tickets",
      "view own orders",
      "view events"
    ]
  },
  "token": "2|laravel_sanctum_xxx...",
  "token_type": "Bearer"
}
```

### 3. Get User Info (Protected)
```http
GET /api/v1/user
Authorization: Bearer {token}
```

**Response:**
```json
{
  "user": {
    "id": 4,
    "name": "Customer User",
    "email": "customer@matiko.com",
    "phone": "+254712345681",
    "role": "customer",
    "status": "active",
    "permissions": ["buy tickets", "view own tickets", ...],
    "roles": ["customer"]
  }
}
```

### 4. Logout (Protected)
```http
POST /api/v1/logout
Authorization: Bearer {token}
```

**Response:**
```json
{
  "message": "Logged out successfully"
}
```

### 5. Refresh Token (Protected)
```http
POST /api/v1/refresh-token
Authorization: Bearer {token}
```

**Response:**
```json
{
  "message": "Token refreshed successfully",
  "token": "3|laravel_sanctum_xxx...",
  "token_type": "Bearer"
}
```

### 6. Update Profile (Protected)
```http
PUT /api/v1/profile
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "John Updated",
  "phone": "+254700000001"
}
```

### 7. Change Password (Protected)
```http
PUT /api/v1/change-password
Authorization: Bearer {token}
Content-Type: application/json

{
  "current_password": "password",
  "password": "newpassword123",
  "password_confirmation": "newpassword123"
}
```

## Role-Based Access Control

### Customer Routes
- ✅ `POST /api/v1/orders` - Place order
- ✅ `GET /api/v1/my-orders` - View own orders
- ✅ `GET /api/v1/my-tickets` - View own tickets

### Agent Routes
- ✅ `POST /api/v1/tickets/scan` - Scan ticket QR code
- ✅ `POST /api/v1/tickets/verify` - Verify ticket
- ✅ `POST /api/v1/tickets/check-in` - Check-in ticket
- ✅ `POST /api/v1/payments/stk-push` - Initiate M-Pesa STK push

### Admin Routes
- ✅ `GET|POST|PUT|DELETE /api/v1/ticket-categories` - Manage ticket categories
- ✅ `GET|POST|PUT|DELETE /api/v1/agents` - Manage agents
- ✅ `GET /api/v1/orders` - View all orders
- ✅ `GET /api/v1/reports/sales` - Sales reports

### Super Admin Routes
- ✅ `GET|POST|PUT|DELETE /api/v1/users` - User management
- ✅ `POST /api/v1/users/{user}/assign-role` - Assign roles
- ✅ `GET /api/v1/reports/analytics` - Analytics
- ✅ `GET /api/v1/audit-logs` - Audit logs

## Testing with cURL

### Login as Customer
```bash
curl -X POST http://localhost:8001/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "customer@matiko.com",
    "password": "password"
  }'
```

### Get User Info
```bash
curl -X GET http://localhost:8001/api/v1/user \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Try Accessing Admin Route (Should Fail)
```bash
curl -X GET http://localhost:8001/api/v1/orders \
  -H "Authorization: Bearer CUSTOMER_TOKEN_HERE"
```

## Testing with Postman

1. **Import Collection**: Create a new Postman collection
2. **Set Environment Variables**:
   - `base_url`: `http://localhost:8001/api/v1`
   - `token`: (will be set automatically after login)
3. **Login Request**: 
   - Save token from response to environment variable
   - Use `{{token}}` in Authorization header for subsequent requests

## Flutter Integration

### Login Example
```dart
final response = await http.post(
  Uri.parse('http://localhost:8001/api/v1/login'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'email': 'agent@matiko.com',
    'password': 'password',
  }),
);

if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  final token = data['token'];
  final user = data['user'];
  
  // Save token to secure storage
  await storage.write(key: 'auth_token', value: token);
}
```

### Authenticated Request Example
```dart
final token = await storage.read(key: 'auth_token');

final response = await http.get(
  Uri.parse('http://localhost:8001/api/v1/user'),
  headers: {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  },
);
```

## Error Responses

### Unauthenticated (401)
```json
{
  "message": "Unauthenticated."
}
```

### Unauthorized - Wrong Role (403)
```json
{
  "message": "Unauthorized. You do not have permission to access this resource.",
  "required_roles": ["admin", "super_admin"],
  "your_role": "customer"
}
```

### Validation Error (422)
```json
{
  "message": "The email field is required.",
  "errors": {
    "email": ["The email field is required."]
  }
}
```

### Inactive Account (422)
```json
{
  "message": "The email field is required.",
  "errors": {
    "email": ["Your account has been suspended. Please contact support."]
  }
}
```

## Security Features

1. ✅ **Token-based authentication** using Laravel Sanctum
2. ✅ **Role-based access control** (Customer, Agent, Admin, Super Admin)
3. ✅ **Permission-based authorization** using Spatie Permissions
4. ✅ **Password hashing** with bcrypt
5. ✅ **Token expiration** (30 days)
6. ✅ **Old token revocation** on password change
7. ✅ **Account status checking** (active, inactive, suspended)
8. ✅ **Email verification ready** (using Laravel Breeze)

## Next Steps

1. ✅ Test all authentication endpoints
2. ⏳ Implement remaining API controllers (Events, Orders, Tickets, etc.)
3. ⏳ Add M-Pesa STK Push integration
4. ⏳ Implement QR code generation and scanning
5. ⏳ Build Flutter POS app with authentication
6. ⏳ Add API rate limiting
7. ⏳ Implement audit logging
8. ⏳ Add email notifications

---

**Authentication System Status**: ✅ Complete and Ready for Testing
