@extends('layout')

@section('content')
<div class="max-w-5xl mx-auto">
    <div class="bg-white rounded-2xl shadow-xl overflow-hidden">
        <div class="relative h-64 md:h-80 bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600">
             <div class="absolute inset-0 bg-black opacity-30"></div>
             <div class="absolute bottom-0 left-0 p-8 md:p-12 text-white w-full backdrop-blur-sm bg-gradient-to-t from-black/60">
                 <h1 class="text-4xl md:text-5xl font-extrabold tracking-tight mb-2">{{ $event->name }}</h1>
                 <div class="flex flex-col md:flex-row md:items-center space-y-2 md:space-y-0 md:space-x-6 text-lg">
                     <div class="flex items-center">
                         <svg class="w-6 h-6 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
                         {{ \Carbon\Carbon::parse($event->event_date)->format('l, M d, Y') }}
                     </div>
                     <div class="flex items-center">
                         <svg class="w-6 h-6 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                         {{ \Carbon\Carbon::parse($event->start_time)->format('g:i A') }} - {{ \Carbon\Carbon::parse($event->end_time)->format('g:i A') }}
                     </div>
                     <div class="flex items-center">
                         <svg class="w-6 h-6 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13 21.01m0 0l-4.657-4.343m4.657 4.343V11m0-11a5 5 0 015 5v3.586a1 1 0 01-.293.707l-2.828 2.828a1 1 0 01-1.414 0l-2.828-2.828a1 1 0 00-1.414 0V5a5 5 0 015-5z"></path></svg>
                         {{ $event->venue }}
                     </div>
                 </div>
             </div>
        </div>

        <div class="p-8 md:p-12">
            <div class="flex flex-col lg:flex-row gap-12">
                <div class="lg:w-2/3">
                    <h2 class="text-2xl font-bold mb-4 text-gray-800">About the Event</h2>
                    <div class="prose max-w-none text-gray-600 leading-relaxed">
                        {{ $event->description }}
                    </div>
                </div>

                <div class="lg:w-1/3">
                    <div class="bg-gray-50 rounded-xl p-6 border border-gray-100 shadow-inner">
                        <h3 class="text-xl font-bold mb-6 text-gray-800 flex items-center">
                            <span class="w-1 h-8 bg-indigo-600 rounded mr-3"></span>
                            Select Tickets
                        </h3>
                        
                        <div class="space-y-4">
                            @forelse($event->categories as $category)
                            <div class="bg-white p-4 rounded-lg border border-gray-200 shadow-sm hover:shadow-md transition hover:border-indigo-300 relative group">
                                <div class="flex justify-between items-center mb-2">
                                    <h4 class="font-bold text-lg text-gray-800">{{ $category->name }}</h4>
                                    <span class="text-indigo-600 font-bold text-xl">Ksh {{ number_format($category->price) }}</span>
                                </div>
                                <div class="text-sm text-gray-500 mb-4">{{ $category->quantity }} tickets available</div>
                                
                                <form action="{{ route('checkout', $event->id) }}" method="GET">
                                    <input type="hidden" name="category" value="{{ $category->id }}">
                                    <button type="submit" class="w-full bg-gray-900 text-white font-bold py-2 rounded hover:bg-indigo-600 transition duration-300">
                                        Select
                                    </button>
                                </form>
                            </div>
                            @empty
                                <div class="text-center text-gray-500 py-4">No tickets available at the moment.</div>
                            @endforelse
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
