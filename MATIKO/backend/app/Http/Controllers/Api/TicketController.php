<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Ticket;
use App\Services\TicketService;
use Illuminate\Http\Request;

class TicketController extends Controller
{
    /**
     * List my tickets
     */
    public function myTickets(Request $request)
    {
        $tickets = Ticket::with(['order.event', 'category'])
            ->whereHas('order', function ($query) use ($request) {
                $query->where('user_id', $request->user()->id);
            })
            ->latest()
            ->paginate(10);
            
        return response()->json($tickets);
    }
    
    /**
     * Scan Ticket (Agent)
     */
    public function scan(Request $request)
    {
        $request->validate([
            'qr_code' => 'required|string'
        ]);
        
        $ticket = Ticket::with(['order.user', 'category', 'order.event'])
            ->where('qr_code', $request->qr_code)->first();
            
        if (!$ticket) {
            return response()->json(['message' => 'Invalid ticket'], 404);
        }
        
        return response()->json([
            'ticket' => $ticket,
            'valid' => !$ticket->is_checked_in, // Simple valid check
            'message' => $ticket->is_checked_in ? 'Ticket already used' : 'Ticket valid'
        ]);
    }

    /**
     * Check-in Ticket (Agent)
     */
    public function checkIn(Request $request)
    {
        $request->validate([
            'qr_code' => 'required|string',
            'agent_id' => 'required|exists:users,id' // Or auth()->id()
        ]);
        
        $ticket = Ticket::where('qr_code', $request->qr_code)->firstOrFail();
        
        if ($ticket->is_checked_in) {
            return response()->json(['message' => 'Ticket already checked in'], 400);
        }
        
        $ticket->update([
            'is_checked_in' => true,
            'checked_in_at' => now(),
            // 'checked_in_by' => $request->user()->id // If we had this column
        ]);
        
        // Log check-in if we have CheckIn model/table
        \App\Models\CheckIn::create([
            'ticket_id' => $ticket->id,
            'agent_id' => $request->user()->id, // Assuming authenticated agent
            'created_at' => now(),
        ]);
         
        return response()->json(['message' => 'Check-in successful']);
    }

    /**
     * Search tickets by phone (Agent)
     */
    public function searchByPhone(Request $request)
    {
        $request->validate([
            'phone' => 'required|string'
        ]);

        $tickets = Ticket::with(['order.user', 'order.event', 'category'])
            ->whereHas('order.user', function ($query) use ($request) {
                $query->where('phone', 'like', '%' . $request->phone . '%');
            })
            ->latest()
            ->paginate(20);

        return response()->json($tickets);
    }

    /**
     * Verify Ticket (Public/Agent)
     */
    public function verify(Request $request, $code = null)
    {
        $ticketService = app(TicketService::class);

        // Handle POST request with QR data (new format)
        if ($request->isMethod('post')) {
            $request->validate([
                'qr_data' => 'required|string'
            ]);

            $result = $ticketService->validateTicket($request->qr_data);

            return response()->json([
                'valid' => $result['valid'],
                'message' => $result['valid'] ? 'Ticket valid' : ($result['message'] ?? 'Invalid ticket'),
                'ticket' => $result['valid'] ? $result['ticket'] : null
            ]);
        }

        // Handle GET request with code (legacy)
        if ($code) {
            $ticket = Ticket::with(['order.event'])->where('qr_code', $code)->first();

            if (!$ticket) {
                return response()->json(['status' => 'invalid'], 404);
            }

            return response()->json([
                'status' => 'valid',
                'event' => $ticket->order->event->name,
                'category' => $ticket->category->name ?? 'General',
                'used' => $ticket->is_checked_in
            ]);
        }

        return response()->json(['message' => 'Invalid request'], 400);
    }
}
