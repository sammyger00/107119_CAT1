<?php

namespace App\Filament\Widgets;

use Filament\Widgets\ChartWidget;

class RevenueChart extends ChartWidget
{
    public function getHeading(): string
    {
        return 'Revenue per Event';
    }

    protected function getData(): array
    {
        $data = \App\Models\Event::select('events.name')
            ->join('orders', 'events.id', '=', 'orders.event_id')
            ->where('orders.payment_status', 'paid')
            ->selectRaw('events.name, SUM(orders.amount) as revenue')
            ->groupBy('events.id', 'events.name')
            ->get();

        return [
            'datasets' => [
                [
                    'label' => 'Revenue (KES)',
                    'data' => $data->pluck('revenue')->toArray(),
                    'backgroundColor' => 'rgba(75, 192, 192, 0.2)',
                    'borderColor' => 'rgba(75, 192, 192, 1)',
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
