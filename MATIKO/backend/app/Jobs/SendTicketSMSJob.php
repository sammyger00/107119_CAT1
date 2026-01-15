<?php

namespace App\Jobs;

use App\Models\Ticket;
use App\Services\AfricasTalkingService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class SendTicketSMSJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $ticketId;

    /**
     * Create a new job instance.
     */
    public function __construct($ticketId)
    {
        $this->ticketId = $ticketId;
    }

    /**
     * Execute the job.
     */
    public function handle(AfricasTalkingService $atService): void
    {
        $ticket = Ticket::with(['order.user', 'order.event'])->find($this->ticketId);

        if (!$ticket) {
            Log::error("Ticket not found for SMS job: {$this->ticketId}");
            return;
        }

        $user = $ticket->order->user;
        $event = $ticket->order->event;

        // Prepare SMS content
        $downloadUrl = url('storage/tickets/ticket-' . $ticket->qr_code . '.pdf');
        $message = "Your ticket for {$event->name}. Download QR Code: {$downloadUrl}";

        // Send SMS
        $result = $atService->sendSms($user->phone, $message);

        if (isset($result['status']) && $result['status'] === 'error') {
            Log::error("Failed to send SMS for ticket {$ticket->id}: " . $result['message']);
            throw new \Exception("SMS sending failed: " . $result['message']);
        }

        Log::info("SMS sent successfully for ticket {$ticket->id} to {$user->phone}");
    }
}
