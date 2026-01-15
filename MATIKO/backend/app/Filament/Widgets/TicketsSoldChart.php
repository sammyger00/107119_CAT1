<?php

namespace App\Filament\Widgets;

use Filament\Widgets\ChartWidget;

class TicketsSoldChart extends ChartWidget
{
    public function getHeading(): string
    {
        return 'Tickets Sold per Event';
    }

    protected function getData(): array
    {
        $data = \App\Models\Event::withCount('tickets')->get();

        return [
            'datasets' => [
                [
                    'label' => 'Tickets Sold',
                    'data' => $data->pluck('tickets_count')->toArray(),
                    'backgroundColor' => 'rgba(54, 162, 235, 0.2)',
                    'borderColor' => 'rgba(54, 162, 235, 1)',
                    'borderWidth' => 1,
                ],
            ],
            'labels' => $data->pluck('name')->toArray(),
        ];
    }

    protected function getType(): string
    {
        return 'bar';
    }
}
