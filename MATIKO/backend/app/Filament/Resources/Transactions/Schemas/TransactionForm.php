<?php

namespace App\Filament\Resources\Transactions\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class TransactionForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('ticket_id')
                    ->relationship('ticket', 'id'),
                TextInput::make('checkout_request_id')
                    ->required(),
                TextInput::make('merchant_request_id'),
                TextInput::make('mpesa_receipt_number'),
                TextInput::make('phone_number')
                    ->tel()
                    ->required(),
                TextInput::make('amount')
                    ->required()
                    ->numeric(),
                TextInput::make('status')
                    ->required()
                    ->default('pending'),
                Textarea::make('response_data')
                    ->columnSpanFull(),
            ]);
    }
}
