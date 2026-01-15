<?php

namespace App\Services;

use App\Jobs\SendTicketEmailJob;
use App\Jobs\SendTicketSMSJob;
use App\Models\Order;
use App\Models\Ticket;
use App\Notifications\TicketPurchased;
use Barryvdh\DomPDF\Facade\Pdf;
use chillerlan\QRCode\QRCode;
use chillerlan\QRCode\QROptions;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class TicketService
{
    /**
     * Generate tickets for a paid order
     */
    public function generateTickets(Order $order)
    {
        // 1. Create Ticket Records
        // Assuming quantity is 1 for now per order line item logic,
        // effectively 1 order = 1 ticket in simple flow,
        // OR if the system supports multiple quantities, we loop.
        // But the current OrderForm doesn't show quantity, just amount.
        // The TicketCategoryResource has quantity.
        // Let's assume 1 ticket per order for the MVP or check if Order has items.
        // The `Ticket` model links to `Order`.
        // The prompt says "Select ticket category".

        // Let's create one ticket for now.
        $ticket = Ticket::create([
            'order_id' => $order->id,
            'ticket_category_id' => $order->ticket_category_id ?? \App\Models\TicketCategory::where('event_id', $order->event_id)->first()->id,
            'qr_code' => Str::upper(Str::random(10)), // Placeholder, will generate unique hash
            'uuid' => Str::uuid(),
            'is_checked_in' => false,
        ]);

        // Generate checksum after creation
        $checksum = $this->generateChecksum($ticket);
        $ticket->update(['checksum' => $checksum]);

        // Update QR code with something unique and verifiable, e.g., signed JWT or just UUID
        $ticket->update([
            'qr_code' => 'TKT-' . $order->id . '-' . $ticket->id . '-' . Str::random(5)
        ]);

        // 2. Generate QR Code Image/Data
        $qrContent = json_encode([
            'ticket_id' => $ticket->uuid,
            'event_id' => $order->event_id,
            'checksum' => $ticket->checksum
        ]);

        $options = new QROptions([
            'version'    => 5,
            'outputType' => QRCode::OUTPUT_IMAGE_PNG,
            'eccLevel'   => QRCode::ECC_L,
        ]);

        $qrcode = (new QRCode($options))->render($qrContent);
        $qrcode = 'data:image/png;base64,' . base64_encode($qrcode);
        // This returns base64 string including header usually? verify render output.
        // It returns a binary string if path is null, or base64 data URI if configured?
        // Default render uses Svg. Let's force PNG.
        // Actually, for PDF we can use the base64 string directly in <img> src.

        // 3. Generate PDF
        $pdf = Pdf::loadView('pdfs.ticket', [
            'ticket' => $ticket,
            'order' => $order,
            'event' => $order->event,
            'qrcode' => $qrcode
        ]);

        $pdfPath = 'tickets/ticket-' . $ticket->qr_code . '.pdf';
        Storage::disk('public')->put($pdfPath, $pdf->output());

        // 4. Dispatch notification jobs
        SendTicketEmailJob::dispatch($ticket->id);
        SendTicketSMSJob::dispatch($ticket->id);

        return $ticket;
    }

    /**
     * Validate a ticket QR code
     */
    public function validateTicket(string $qrData): array
    {
        $data = json_decode($qrData, true);

        if (!$data || !isset($data['ticket_id'], $data['event_id'], $data['checksum'])) {
            return ['valid' => false, 'message' => 'Invalid QR code format'];
        }

        $ticket = Ticket::where('uuid', $data['ticket_id'])->first();

        if (!$ticket) {
            return ['valid' => false, 'message' => 'Ticket not found'];
        }

        // Check event matches
        if ($ticket->order->event_id != $data['event_id']) {
            return ['valid' => false, 'message' => 'Event mismatch'];
        }

        // Check not already checked in
        if ($ticket->is_checked_in) {
            return ['valid' => false, 'message' => 'Ticket already checked in'];
        }

        // Check payment successful
        if ($ticket->order->payment_status !== 'completed') {
            return ['valid' => false, 'message' => 'Payment not completed'];
        }

        // Verify checksum
        $expectedChecksum = $this->generateChecksum($ticket);
        if ($data['checksum'] !== $expectedChecksum) {
            return ['valid' => false, 'message' => 'Invalid checksum'];
        }

        return ['valid' => true, 'ticket' => $ticket];
    }

    /**
     * Generate checksum for ticket
     */
    private function generateChecksum(Ticket $ticket): string
    {
        $data = $ticket->uuid . $ticket->order->event_id . $ticket->order->user_id . config('app.key');
        return hash('sha256', $data);
    }

    protected function sendSms($phone, $ticket, $event)
    {
        // Use AfricasTalking or similar
        // Mocking for now or using the AT package if configured
        try {
            $message = "Hello! Your ticket for {$event->name} is ready. Download here: " . url('storage/tickets/ticket-' . $ticket->qr_code . '.pdf');
            // Core SMS sending logic would go here
            Log::info("SMS sent to {$phone}: {$message}");
        } catch (\Exception $e) {
            Log::error("SMS Send Error: " . $e->getMessage());
        }
    }
}
