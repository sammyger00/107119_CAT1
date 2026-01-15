@extends('layout')

@section('content')
<div class="max-w-3xl mx-auto">
    <div class="bg-white rounded-2xl shadow-xl overflow-hidden border border-gray-100">
        <div class="bg-gradient-to-r from-green-600 to-teal-600 p-6 text-white text-center">
            <h1 class="text-3xl font-bold">Secure Checkout</h1>
            <p class="opacity-90 mt-1">Complete your purchase securely with M-Pesa</p>
        </div>
        
        <div class="p-8">
            <!-- Order Summary -->
            <div class="bg-gray-50 rounded-xl p-6 mb-8 border border-gray-200">
                <h2 class="text-gray-800 font-bold text-lg mb-4 border-b border-gray-200 pb-2">Order Summary</h2>
                <div class="flex justify-between items-center mb-2">
                    <span class="text-gray-600">{{ $category->event->name }}</span>
                    <span class="font-medium text-gray-800">{{ \Carbon\Carbon::parse($category->event->event_date)->format('M d, Y') }}</span>
                </div>
                <div class="flex justify-between items-center mb-4">
                    <span class="text-gray-600">Ticket Type: {{ $category->name }}</span>
                    <span class="font-medium text-gray-800">1 x Ksh {{ number_format($category->price) }}</span>
                </div>
                <div class="flex justify-between items-center pt-4 border-t border-gray-200 text-xl font-bold text-gray-900">
                    <span>Total</span>
                    <span>Ksh {{ number_format($category->price) }}</span>
                </div>
            </div>

            <!-- Payment Form -->
            <form action="{{ route('orders.store') }}" method="POST" class="space-y-6">
                @csrf
                <input type="hidden" name="event_id" value="{{ $category->event->id }}">
                <input type="hidden" name="ticket_category_id" value="{{ $category->id }}">
                
                @guest
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                        <label for="name" class="block text-sm font-medium text-gray-700 mb-1">Full Name</label>
                        <input type="text" name="name" id="name" required class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 transition" placeholder="John Doe">
                    </div>
                     <div>
                        <label for="email" class="block text-sm font-medium text-gray-700 mb-1">Email Address (Optional)</label>
                        <input type="email" name="email" id="email" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 transition" placeholder="john@example.com">
                    </div>
                </div>
                @endguest

                <div>
                    <label for="phone_number" class="block text-sm font-medium text-gray-700 mb-1">M-Pesa Phone Number</label>
                    <div class="relative">
                        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                            <span class="text-gray-500 font-medium">🇰🇪 +254</span>
                        </div>
                        <input type="tel" name="phone_number" id="phone_number" required class="w-full pl-20 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 transition" placeholder="700 000 000">
                    </div>
                    <p class="text-xs text-gray-500 mt-1">We will send an M-Pesa prompt to this number.</p>
                </div>

                <div class="pt-4">
                    <button type="submit" class="w-full bg-green-600 hover:bg-green-700 text-white font-bold py-4 px-6 rounded-lg shadow-lg hover:shadow-xl transition duration-300 flex justify-center items-center">
                        <svg class="w-6 h-6 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z"></path></svg>
                        Pay Ksh {{ number_format($category->price) }} with M-Pesa
                    </button>
                    <p class="text-center text-gray-500 text-sm mt-4 flex items-center justify-center">
                        <svg class="w-4 h-4 mr-1 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path></svg>
                        Secure Payment via Daraja API
                    </p>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
