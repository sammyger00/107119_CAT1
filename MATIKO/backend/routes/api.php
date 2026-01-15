<?php

use App\Http\Controllers\Api\AuthController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Public routes (no authentication required)
Route::prefix('v1')->group(function () {

    // Authentication routes
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
});

// Agent specific routes
Route::prefix('agent')->group(function () {
    Route::post('/login', [AuthController::class, 'login']);
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/scan-ticket', [\App\Http\Controllers\Api\TicketController::class, 'scan']);
        Route::get('/search-tickets', [\App\Http\Controllers\Api\TicketController::class, 'searchByPhone']);
        Route::post('/stk-push', [\App\Http\Controllers\Api\PaymentController::class, 'stkPush']);
    });
});

// Public routes (no authentication required)
Route::prefix('v1')->group(function () {

    // Public Callbacks & Verification
    Route::post('/payments/callback', [\App\Http\Controllers\Api\PaymentController::class, 'callback']);
    Route::get('/tickets/verify/{code}', [\App\Http\Controllers\Api\TicketController::class, 'verify'])->name('api.tickets.verify');

    // Protected routes (require authentication)
    Route::middleware('auth:sanctum')->group(function () {
        
        // Auth management
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/user', [AuthController::class, 'user']);
        Route::post('/refresh-token', [AuthController::class, 'refresh']);
        Route::put('/profile', [AuthController::class, 'updateProfile']);
        Route::put('/change-password', [AuthController::class, 'changePassword']);

        // Events routes
        Route::apiResource('events', \App\Http\Controllers\Api\EventController::class)->names([
            'index' => 'api.events.index',
            'store' => 'api.events.store',
            'show' => 'api.events.show',
            'update' => 'api.events.update',
            'destroy' => 'api.events.destroy',
        ]);

        // Customer routes (buy tickets, view orders)
        Route::middleware('role:customer|admin|super_admin')->group(function () {
            Route::post('/orders', [\App\Http\Controllers\Api\OrderController::class, 'store']);
            Route::get('/my-orders', [\App\Http\Controllers\Api\OrderController::class, 'myOrders']);
            Route::get('/my-tickets', [\App\Http\Controllers\Api\TicketController::class, 'myTickets']);
        });

        // Agent routes (scan tickets, STK push)
        Route::middleware('role:agent|admin|super_admin')->group(function () {
            Route::post('/tickets/scan', [\App\Http\Controllers\Api\TicketController::class, 'scan']);
            Route::post('/tickets/verify', [\App\Http\Controllers\Api\TicketController::class, 'verify']);
            Route::post('/tickets/check-in', [\App\Http\Controllers\Api\TicketController::class, 'checkIn']);
            Route::post('/payments/stk-push', [\App\Http\Controllers\Api\PaymentController::class, 'stkPush']);
        });

        // Admin routes (manage events, agents)
        Route::middleware('role:admin|super_admin')->group(function () {
            Route::apiResource('ticket-categories', \App\Http\Controllers\Api\TicketCategoryController::class);
            Route::apiResource('agents', \App\Http\Controllers\Api\AgentController::class);
            Route::get('/orders', [\App\Http\Controllers\Api\OrderController::class, 'index']);
            Route::get('/reports/sales', [\App\Http\Controllers\Api\ReportController::class, 'sales']);
        });

        // Super Admin routes (full system control)
        Route::middleware('role:super_admin')->group(function () {
            Route::apiResource('users', \App\Http\Controllers\Api\UserController::class);
            Route::post('/users/{user}/assign-role', [\App\Http\Controllers\Api\UserController::class, 'assignRole']);
            Route::get('/reports/analytics', [\App\Http\Controllers\Api\ReportController::class, 'analytics']);
            Route::get('/audit-logs', [\App\Http\Controllers\Api\AuditController::class, 'index']);
        });
    });
});

// API health check
Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'timestamp' => now()->toIso8601String(),
        'service' => 'MATIKO Ticketing API',
        'version' => '1.0.0',
    ]);
});
