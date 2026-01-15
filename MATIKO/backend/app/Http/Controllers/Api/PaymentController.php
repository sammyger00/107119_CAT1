<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Jobs\ProcessStkCallback;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class PaymentController extends Controller
{
    /**
     * Handle M-Pesa Callback
     */
    public function callback(Request $request)
    {
        Log::info('M-Pesa Callback Received', $request->all());

        $content = $request->input('Body.stkCallback');
        
        if (!$content) {
             return response()->json(['result' => 'invalid_body'], 400);
        }

        // Dispatch Job
        ProcessStkCallback::dispatch($request->all());

        return response()->json(['result' => 'queued']);
    }

    /**
     * Agent initiated STK Push (for manual sales)
     */
    public function stkPush(Request $request)
    {
        return response()->json(['message' => 'Not implemented yet']);
    }
}
