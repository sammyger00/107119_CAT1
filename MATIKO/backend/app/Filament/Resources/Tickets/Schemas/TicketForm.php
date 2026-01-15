<?php

namespace App\Filament\Resources\Tickets\Schemas;

use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Toggle;
use Filament\Forms\Components\DateTimePicker;
use Filament\Schemas\Schema;

class TicketForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('order_id')
                    ->relationship('order', 'order_number')
                    ->required()
                    ->searchable(),
                Select::make('ticket_category_id')
                    ->relationship('category', 'name')
                    ->required()
                    ->searchable(),
                TextInput::make('qr_code')
                    ->required()
                    ->unique(ignoreRecord: true),
                Toggle::make('is_checked_in')
                    ->required(),
                DateTimePicker::make('checked_in_at'),
            ]);
    }
}
