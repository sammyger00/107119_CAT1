<?php

namespace App\Filament\Resources\Transactions\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class TransactionInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('ticket.id')
                    ->label('Ticket')
                    ->placeholder('-'),
                TextEntry::make('checkout_request_id'),
                TextEntry::make('merchant_request_id')
                    ->placeholder('-'),
                TextEntry::make('mpesa_receipt_number')
                    ->placeholder('-'),
                TextEntry::make('phone_number'),
                TextEntry::make('amount')
                    ->numeric(),
                TextEntry::make('status'),
                TextEntry::make('response_data')
                    ->placeholder('-')
                    ->columnSpanFull(),
                TextEntry::make('created_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('updated_at')
                    ->dateTime()
                    ->placeholder('-'),
            ]);
    }
}
