<?php

namespace App\Filament\Resources\Agents\Pages;

use App\Filament\Resources\Agents\AgentResource;
use Filament\Resources\Pages\EditRecord;

class EditAgent extends EditRecord
{
    protected static string $resource = AgentResource::class;

    protected function mutateFormDataBeforeFill(array $data): array
    {
        $agent = $this->getRecord();

        return [
            'name' => $agent->user->name ?? '',
            'email' => $agent->user->email ?? '',
            'phone' => $agent->user->phone ?? '',
            'assigned_events' => $data['assigned_events'] ?? [],
        ];
    }

    protected function mutateFormDataBeforeSave(array $data): array
    {
        $agent = $this->getRecord();

        // Update the user record
        $agent->user->update([
            'name' => $data['name'],
            'email' => $data['email'],
            'phone' => $data['phone'],
        ]);

        // Return only the agent-specific data
        return [
            'assigned_events' => $data['assigned_events'] ?? [],
        ];
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}
