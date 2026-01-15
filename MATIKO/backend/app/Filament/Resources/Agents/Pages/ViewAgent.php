<?php

namespace App\Filament\Resources\Agents\Pages;

use App\Filament\Resources\Agents\AgentResource;
use Filament\Resources\Pages\ViewRecord;

class ViewAgent extends ViewRecord
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
}
