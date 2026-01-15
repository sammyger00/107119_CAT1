<?php

namespace App\Filament\Resources\Agents\Pages;

use App\Filament\Resources\Agents\AgentResource;
use App\Models\User;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Database\Eloquent\Model;

class CreateAgent extends CreateRecord
{
    protected static string $resource = AgentResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        // Create the user first
        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'phone' => $data['phone'],
            'password' => bcrypt('password123'), // Default password
            'role' => 'agent',
        ]);

        // Assign agent role
        $user->assignRole('agent');

        // Replace the form data with user_id and keep assigned_events
        return [
            'user_id' => $user->id,
            'assigned_events' => $data['assigned_events'] ?? [],
        ];
    }
}
