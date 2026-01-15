<?php

namespace App\Filament\Widgets;

use Filament\Widgets\TableWidget as BaseWidget;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class AgentPerformanceTable extends BaseWidget
{
    protected function getHeading(): string
    {
        return 'Agent Performance';
    }

    protected int | string | array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                \App\Models\Agent::query()
                    ->with('user')
            )
            ->columns([
                Tables\Columns\TextColumn::make('user.name')
                    ->label('Agent Name')
                    ->searchable(),
                Tables\Columns\TextColumn::make('check_ins_count')
                    ->label('Check-ins Handled')
                    ->getStateUsing(fn ($record) => $record->user?->checkIns()?->count() ?? 0),
                Tables\Columns\TextColumn::make('tickets_verified_count')
                    ->label('Tickets Verified')
                    ->getStateUsing(fn ($record) => $record->user?->ticketsVerified()?->count() ?? 0),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc');
    }
}
