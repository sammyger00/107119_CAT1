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
use Illuminate\Support\Facades\Storage;

class SendTicketEmailJob implements ShouldQueue
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
            Log::error("Ticket not found for email job: {$this->ticketId}");
            return;
        }

        $user = $ticket->order->user;
        $event = $ticket->order->event;

        // Prepare email content
        $subject = "Your Ticket for {$event->name}";
        $message = "Dear {$user->name},\n\nYour ticket for {$event->name} has been successfully purchased.\n\nPlease find your ticket attached to this email.\n\nThank you for using our service!\n\nBest regards,\nEvent Team";

        // Prepare attachment
        $pdfPath = storage_path('app/public/tickets/ticket-' . $ticket->qr_code . '.pdf');

        if (!file_exists($pdfPath)) {
            Log::error("PDF not found for ticket: {$ticket->qr_code}");
            return;
        }

        $attachments = [
            [
                'filename' => 'ticket-' . $ticket->qr_code . '.pdf',
                'content' => base64_encode(file_get_contents($pdfPath)),
                'contentType' => 'application/pdf'
            ]
        ];

        // Send email
        $result = $atService->sendEmail($user->email, $subject, $message, $attachments);

        if (isset($result['status']) && $result['status'] === 'error') {
            Log::error("Failed to send email for ticket {$ticket->id}: " . $result['message']);
            throw new \Exception("Email sending failed: " . $result['message']);
        }

        Log::info("Email sent successfully for ticket {$ticket->id} to {$user->email}");
    }
}
