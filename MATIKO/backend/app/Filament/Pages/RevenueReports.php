<?php

namespace App\Filament\Pages;

use App\Filament\Widgets\AgentPerformanceTable;
use App\Filament\Widgets\CheckInsChart;
use App\Filament\Widgets\RevenueChart;
use App\Filament\Widgets\RevenueStatsOverview;
use App\Filament\Widgets\TicketsSoldChart;
use Filament\Pages\Page;

class RevenueReports extends Page
{

    public function getWidgets(): array
    {
        return [
            RevenueStatsOverview::class,
            TicketsSoldChart::class,
            RevenueChart::class,
            CheckInsChart::class,
            AgentPerformanceTable::class,
        ];
    }

    public function getColumns(): int
    {
        return 2;
    }
}
