<?php

namespace App\Http\Controllers\Api;

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

    /**
     * Store a new order and initiate payment.
     */
    public function store(Request $request)
    {
        $request->validate([
            'event_id' => 'required|exists:events,id',
            'ticket_category_id' => 'required|exists:ticket_categories,id',
            'phone_number' => 'required|string',
        ]);

        $category = TicketCategory::findOrFail($request->ticket_category_id);

        // Verify category belongs to event
        if ($category->event_id != $request->event_id) {
            return response()->json(['message' => 'Invalid ticket category for this event'], 422);
        }

        // Check availability
        // (Assuming we track quantity sold vs total, simplified here by just checking if > 0)
        // Ideally we count tickets sold for this category
        $sold = \App\Models\Ticket::where('ticket_category_id', $category->id)->count();
        if ($sold >= $category->quantity) {
             return response()->json(['message' => 'Tickets sold out'], 422);
        }

        // Create Order
        $order = Order::create([
            'order_number' => 'ORD-' . strtoupper(Str::random(10)),
            'user_id' => $request->user()->id,
            'event_id' => $request->event_id,
            'ticket_category_id' => $category->id,
            'amount' => $category->price,
            'payment_status' => 'pending',
            'phone_number' => $request->phone_number,
        ]);

        // Initiate Payment
        try {
            $response = $this->daraja->initiateStkPush($order, $request->phone_number);
            
            // Save CheckoutRequestID if needed for later verification/query status
            // $order->update(['checkout_request_id' => $response['CheckoutRequestID']]); 
            // Add column if needed or store in payment_reference
            $order->update(['payment_reference' => $response['CheckoutRequestID'] ?? null]);

            return response()->json([
                'message' => 'Order created and payment initiated',
                'order' => $order,
                'mpesa_response' => $response
            ], 201);

        } catch (\Exception $e) {
            // Log error
            \Log::error("Payment Initiation Failed: " . $e->getMessage());
            
            // We might want to keep the order as failed or delete it.
            // Keeping it allows retry.
            return response()->json([
                'message' => 'Order created but payment initiation failed. Please try paying again.',
                'order' => $order,
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * List user orders
     */
    public function myOrders(Request $request)
    {
        $orders = Order::with(['event', 'tickets'])
            ->where('user_id', $request->user()->id)
            ->latest()
            ->paginate(10);

        return response()->json($orders);
    }

    /**
     * List all orders (Admin)
     */
    public function index(Request $request)
    {
        $orders = Order::with(['user', 'event'])
            ->latest()
            ->paginate(20);

        return response()->json($orders);
    }
}
