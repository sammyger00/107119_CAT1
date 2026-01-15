<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Event;
use Illuminate\Http\Request;

class EventController extends Controller
{
    /**
     * Display a listing of upcoming events.
     */
    public function index()
    {
        $events = Event::with(['categories'])
            ->where('status', 'upcoming')
            ->where('event_date', '>=', now()->toDateString())
            ->orderBy('event_date')
            ->paginate(10);

        return response()->json($events);
    }

    /**
     * Display the specified event.
     */
    public function show($id)
    {
        $event = Event::with(['categories', 'creator:id,name'])
            ->findOrFail($id);

        return response()->json($event);
    }
}
