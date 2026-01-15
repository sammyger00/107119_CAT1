<?php

use App\Http\Controllers\Web\EventController;
use App\Http\Controllers\Web\OrderController;
use Illuminate\Support\Facades\Route;

Route::get('/', [EventController::class, 'index'])->name('home');
Route::get('/events/{id}', [EventController::class, 'show'])->name('events.show');

Route::middleware(['web'])->group(function () {
    Route::get('/checkout/{event}', [OrderController::class, 'checkout'])->name('checkout');
    Route::post('/orders', [OrderController::class, 'store'])->name('orders.store');
    Route::get('/orders/{id}/success', [OrderController::class, 'success'])->name('orders.success');
});

require __DIR__.'/auth.php';
