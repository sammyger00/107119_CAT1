<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Event Ticket</title>
    <style>
        body { font-family: sans-serif; }
        .ticket-box { border: 2px solid #000; padding: 20px; width: 100%; max-width: 600px; margin: 0 auto; }
        .header { text-align: center; border-bottom: 2px dashed #ccc; padding-bottom: 10px; margin-bottom: 20px; }
        .event-name { font-size: 24px; font-weight: bold; color: #333; }
        .event-details { margin-top: 10px; font-size: 14px; }
        .qr-code { text-align: center; margin: 20px 0; }
        .footer { font-size: 12px; text-align: center; color: #666; border-top: 1px solid #eee; padding-top: 10px;}
        .label { font-weight: bold; margin-right: 5px; }
    </style>
</head>
<body>
    <div class="ticket-box">
        <div class="header">
            <div class="event-name">{{ $event->name }}</div>
            <div class="event-details">
                <div><span class="label">Date:</span> {{ \Carbon\Carbon::parse($event->event_date)->format('D, d M Y') }}</div>
                <div><span class="label">Time:</span> {{ $event->start_time }} - {{ $event->end_time }}</div>
                <div><span class="label">Venue:</span> {{ $event->venue }}</div>
            </div>
        </div>

        <div style="text-align: center;">
            <h2>{{ $ticket->category->name ?? 'General Admission' }}</h2>
            <p>Ticket #{{ $ticket->qr_code }}</p>
        </div>

        <div class="qr-code">
            <img src="{{ $qrcode }}" alt="QR Code" style="width: 200px; height: 200px;">
            <p><small>Scan at gate for entry</small></p>
        </div>

        <div class="footer">
            <p>Ordered by: {{ $order->user->name }} | Order #{{ $order->order_number }}</p>
            <p>Powered by MATIKO Ticketing</p>
        </div>
    </div>
</body>
</html>
