<?php

namespace App\Filament\Widgets;

use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class RevenueStatsOverview extends BaseWidget
{
    protected function getStats(): array
    {
        $totalRevenue = \App\Models\Order::where('payment_status', 'paid')->sum('amount');
        $totalTickets = \App\Models\Ticket::count();
        $totalEvents = \App\Models\Event::count();
        $totalCheckIns = \App\Models\CheckIn::count();

        return [
            Stat::make('Total Revenue', 'KES ' . number_format($totalRevenue))
                ->description('Total revenue from paid orders')
                ->descriptionIcon('heroicon-m-arrow-trending-up')
                ->color('success'),
            Stat::make('Tickets Sold', $totalTickets)
                ->description('Total tickets sold')
                ->descriptionIcon('heroicon-m-ticket')
                ->color('primary'),
            Stat::make('Total Events', $totalEvents)
                ->description('Number of events created')
                ->descriptionIcon('heroicon-m-calendar-days')
                ->color('info'),
            Stat::make('Check-ins', $totalCheckIns)
                ->description('Total check-ins recorded')
                ->descriptionIcon('heroicon-m-check-circle')
                ->color('warning'),
        ];
    }
}
