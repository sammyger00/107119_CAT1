@extends('layout')

@section('content')
<div class="max-w-2xl mx-auto text-center pt-12">
    <div class="bg-white rounded-2xl shadow-xl p-12">
        <div class="flex justify-center mb-6">
            <div class="rounded-full bg-green-100 p-4">
                <svg class="w-16 h-16 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
            </div>
        </div>
        
        <h1 class="text-3xl font-bold text-gray-900 mb-4">Payment Initiated!</h1>
        <p class="text-xl text-gray-600 mb-8">Please check your phone <strong>{{ $order->phone_number }}</strong> and enter your M-Pesa PIN.</p>
        
        <div class="bg-gray-50 rounded-lg p-6 mb-8 text-left">
            <h3 class="font-bold text-gray-800 mb-2">Order #{{ $order->order_number }}</h3>
            <p class="text-gray-600 mb-4">Once payment is confirmed, we will send your ticket to:</p>
            <ul class="space-y-2 text-sm text-gray-700">
                <li class="flex items-center"><svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path></svg> Email: {{ $order->user->email }}</li>
                <li class="flex items-center"><svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z"></path></svg> SMS: {{ $order->phone_number }}</li>
            </ul>
        </div>
        
        <a href="/" class="text-indigo-600 hover:text-indigo-800 font-medium">Return to Home</a>
    </div>
</div>
@endsection
