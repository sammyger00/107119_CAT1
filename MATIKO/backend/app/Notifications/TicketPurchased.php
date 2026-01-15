<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;
use Illuminate\Support\Facades\Storage;

class TicketPurchased extends Notification implements ShouldQueue
{
    use Queueable;

    protected $ticket;
    protected $pdfPath;

    /**
     * Create a new notification instance.
     */
    public function __construct($ticket, $pdfPath)
    {
        $this->ticket = $ticket;
        $this->pdfPath = $pdfPath;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    /**
     * Get the mail representation of the notification.
     */
    public function toMail(object $notifiable): MailMessage
    {
        $url = url('/storage/' . $this->pdfPath); // Or a frontend URL

        return (new MailMessage)
            ->subject('Your Ticket for ' . $this->ticket->order->event->name)
            ->greeting('Hello ' . $notifiable->name . '!')
            ->line('Thank you for your purchase. Please find your ticket attached.')
            ->line('Event: ' . $this->ticket->order->event->name)
            ->line('Venue: ' . $this->ticket->order->event->venue)
            ->action('Download Ticket', $url)
            ->attach(storage_path('app/public/' . $this->pdfPath), [
                'as' => 'ticket-' . $this->ticket->qr_code . '.pdf',
                'mime' => 'application/pdf',
            ]);
    }
}
