<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function sales()
    {
        // Calculate Total Sales, Sales per Event
        $sales = \App\Models\Order::where('payment_status', 'paid')
            ->selectRaw('count(*) as total_orders, sum(amount) as total_revenue, event_id')
            ->groupBy('event_id')
            ->with('event:id,name')
            ->get();
            
        return response()->json($sales);
    }
    
    public function analytics()
    {
        // System wide analytics
        return response()->json([
            'total_users' => \App\Models\User::count(),
            'total_events' => \App\Models\Event::count(),
            'total_tickets_sold' => \App\Models\Ticket::count(),
            'revenue' => \App\Models\Order::where('payment_status', 'paid')->sum('amount')
        ]);
    }
}
