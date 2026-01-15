<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\TicketCategory;
use App\Services\DarajaService;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class OrderController extends Controller
{
    protected $daraja;

    public function __construct(DarajaService $daraja)
    {
        $this->daraja = $daraja;
    }

    public function checkout(Request $request, $eventId)
    {
        $category = TicketCategory::findOrFail($request->category);
        return view('orders.checkout', compact('category'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'event_id' => 'required',
            'ticket_category_id' => 'required',
            'phone_number' => 'required',
            // 'email' => 'required|email' // If we want to capture customer info
        ]);

        $category = TicketCategory::findOrFail($request->ticket_category_id);
        
        // Simulating logged in user or creating a guest user?
        // For now, let's assume we require login or just use a guest user placeholder.
        // Prompt says "Enters phone number... System creates order".
        // It doesn't explicitly say "Login". A "Guest Checkout" is common.
        // But my Order model requires `user_id`.
        // I'll attach it to the currently authenticated user (if I enforce auth) or create a "Guest" user.
        
        $user = auth()->user();
        
        if (!$user) {
            $request->validate([
                'name' => 'required|string',
                'email' => 'nullable|email',
            ]);

            // Check if user exists
            if ($request->email && \App\Models\User::where('email', $request->email)->exists()) {
                 return back()->with('error', 'Account exists. Please login to continue.');
            }
            
            // Create Guest User
            $password = Str::random(12);
            $user = \App\Models\User::create([
                'name' => $request->name,
                'email' => $request->email ?? Str::slug($request->name).rand(1000,9999).'@guest.matiko.com',
                'phone' => $request->phone_number,
                'password' => \Illuminate\Support\Facades\Hash::make($password),
                'role' => 'customer',
                'status' => 'active',
            ]);
            
            $user->assignRole('customer');
            auth()->login($user);
        }

        $order = Order::create([
            'order_number' => 'ORD-' . strtoupper(Str::random(10)),
            'user_id' => $user->id,
            'event_id' => $request->event_id,
            'ticket_category_id' => $category->id,
            'amount' => $category->price,
            'payment_status' => 'pending',
            'phone_number' => $request->phone_number,
        ]);

        try {
            $this->daraja->initiateStkPush($order, $request->phone_number);
            
            return redirect()->route('orders.success', $order->id)
                ->with('success', 'Payment initiated! Check your phone.');
                
        } catch (\Exception $e) {
            return back()->with('error', 'Payment Initiation Failed: ' . $e->getMessage());
        }
    }

    public function success($id)
    {
        $order = Order::findOrFail($id);
        return view('orders.success', compact('order'));
    }
}
