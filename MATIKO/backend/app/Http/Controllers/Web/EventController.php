<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Event;
use App\Models\TicketCategory;
use Illuminate\Http\Request;

class EventController extends Controller
{
    public function index()
    {
        $events = Event::where('status', 'upcoming')
            ->orderBy('event_date')
            ->get();
            
        return view('events.index', compact('events'));
    }

    public function show($id)
    {
        $event = Event::with('categories')->findOrFail($id);
        return view('events.show', compact('event'));
    }
}
