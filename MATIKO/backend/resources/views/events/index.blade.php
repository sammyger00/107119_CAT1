@extends('layout')

@section('content')
<div class="relative">
    <div class="text-center mb-12">
        <h1 class="text-4xl font-extrabold text-transparent bg-clip-text bg-gradient-to-r from-purple-400 to-pink-600">
            Upcoming Events
        </h1>
        <p class="mt-4 text-xl text-gray-600">Discover and book the best experiences.</p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        @foreach($events as $event)
        <div class="bg-white rounded-xl shadow-lg hover:shadow-2xl transition duration-300 transform hover:-translate-y-1 overflow-hidden group">
            <div class="h-48 bg-gradient-to-br from-indigo-500 to-purple-600 relative overflow-hidden">
                <!-- Placeholder for Event Image -->
                <div class="absolute inset-0 bg-black opacity-20 group-hover:opacity-10 transition duration-300"></div>
                <div class="absolute bottom-4 left-4 text-white">
                    <p class="text-sm font-semibold uppercase tracking-wider backdrop-blur-sm bg-white/20 px-2 py-1 rounded">
                        {{ \Carbon\Carbon::parse($event->event_date)->format('M d, Y') }}
                    </p>
                </div>
            </div>
            
            <div class="p-6">
                <h3 class="text-2xl font-bold text-gray-800 mb-2 group-hover:text-indigo-600 transition">{{ $event->name }}</h3>
                <div class="flex items-center text-gray-500 mb-4">
                    <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13 21.01m0 0l-4.657-4.343m4.657 4.343V11m0-11a5 5 0 015 5v3.586a1 1 0 01-.293.707l-2.828 2.828a1 1 0 01-1.414 0l-2.828-2.828a1 1 0 00-1.414 0V5a5 5 0 015-5z"></path></svg>
                    <span>{{ $event->venue }}</span>
                </div>
                <p class="text-gray-600 line-clamp-3 mb-6">{{ $event->description }}</p>
                
                <a href="{{ route('events.show', $event->id) }}" class="block w-full text-center bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-3 px-4 rounded-lg transition duration-300 shadow-md hover:shadow-lg">
                    Get Tickets
                </a>
            </div>
        </div>
        @endforeach
    </div>
</div>
@endsection
