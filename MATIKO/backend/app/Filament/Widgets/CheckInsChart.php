<?php

namespace App\Filament\Widgets;

use Filament\Widgets\ChartWidget;

class CheckInsChart extends ChartWidget
{
    public function getHeading(): string
    {
        return 'Check-ins Count per Event';
    }

    protected function getData(): array
    {
        $data = \App\Models\Event::select('events.*')
            ->selectRaw('COALESCE(checkin_counts.total_checkins, 0) as check_ins_count')
            ->leftJoinSub(
                \DB::table('ticket_categories')
                    ->select('ticket_categories.event_id')
                    ->selectRaw('COUNT(check_ins.id) as total_checkins')
                    ->leftJoin('tickets', 'ticket_categories.id', '=', 'tickets.ticket_category_id')
                    ->leftJoin('check_ins', 'tickets.id', '=', 'check_ins.ticket_id')
                    ->groupBy('ticket_categories.event_id'),
                'checkin_counts',
                'events.id',
                '=',
                'checkin_counts.event_id'
            )
            ->get();

        return [
            'datasets' => [
                [
                    'label' => 'Check-ins',
                    'data' => $data->pluck('check_ins_count')->toArray(),
                    'backgroundColor' => 'rgba(255, 206, 86, 0.2)',
                    'borderColor' => 'rgba(255, 206, 86, 1)',
                    'borderWidth' => 1,
                ],
            ],
            'labels' => $data->pluck('name')->toArray(),
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }
}
