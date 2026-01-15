<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Agent;
use Illuminate\Http\Request;

class AgentController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        return Agent::with('user')->paginate(20);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id|unique:agents,user_id',
            'assigned_events' => 'nullable|array',
        ]);

        $agent = Agent::create($validated);
        
        // Ensure user has agent role
        $user = \App\Models\User::find($validated['user_id']);
        if (!$user->hasRole('agent')) {
            $user->assignRole('agent');
        }

        return response()->json($agent, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        return Agent::with('user')->findOrFail($id);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $agent = Agent::findOrFail($id);

        $validated = $request->validate([
            'assigned_events' => 'nullable|array',
        ]);

        $agent->update($validated);

        return response()->json($agent);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $agent = Agent::findOrFail($id);
        
        // Note: we might want to remove the role from the user too, but maybe not.
        
        $agent->delete();

        return response()->json(null, 204);
    }
}
