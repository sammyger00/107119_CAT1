<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class AuditController extends Controller
{
    public function index()
    {
        // Return audit logs, for now just a message as we haven't implemented comprehensive logging/activity log package
        // typically uses spatie/laravel-activitylog
        return response()->json(['logs' => []]);
    }
}
