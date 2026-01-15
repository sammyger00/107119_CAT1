<?php

namespace App\Jobs;

use App\Models\Order;
use App\Services\TicketService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ProcessStkCallback implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $payload;

    /**
     * Create a new job instance.
     */
    public function __construct(array $payload)
    {
        $this->payload = $payload;
    }

    /**
     * Execute the job.
     */
    public function handle(TicketService $ticketService): void
    {
        $content = $this->payload['Body']['stkCallback'];
        
        $merchantRequestId = $content['MerchantRequestID'];
        $checkoutRequestId = $content['CheckoutRequestID'];
        $resultCode = $content['ResultCode'];
        $resultDesc = $content['ResultDesc'];
        
        $metadata = $content['CallbackMetadata']['Item'] ?? [];
        $amount = null;
        $receipt = null;
        $phone = null;
        $date = null;

        foreach ($metadata as $item) {
            switch ($item['Name']) {
                case 'Amount': $amount = $item['Value']; break;
                case 'MpesaReceiptNumber': $receipt = $item['Value']; break;
                case 'PhoneNumber': $phone = $item['Value']; break;
                case 'TransactionDate': $date = $item['Value']; break;
            }
        }

        // Find Order
        $order = Order::where('payment_reference', $checkoutRequestId)->first();

        // Log Transaction
        DB::table('mpesa_transactions')->insert([
            'merchant_request_id' => $merchantRequestId,
            'checkout_request_id' => $checkoutRequestId,
            'result_code' => $resultCode,
            'result_desc' => $resultDesc,
            'amount' => $amount,
            'mpesa_receipt_number' => $receipt,
            'transaction_date' => $date,
            'phone_number' => $phone,
            'callback_metadata' => json_encode($content),
            'order_id' => $order?->id,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        if (!$order) {
            Log::error("Order not found for STK Callback: $checkoutRequestId");
            return;
        }

        if ($resultCode == 0) {
            // Success
            $order->update([
                'payment_status' => 'paid',
                'phone_number' => $phone ?? $order->phone_number // Update with actual payer phone if present
            ]);
            
            Log::info("Order {$order->order_number} PAID via M-Pesa ($receipt)");
            
            // Generate Tickets
            try {
                $ticketService->generateTickets($order);
            } catch (\Exception $e) {
                Log::error("Failed to generate tickets for Order {$order->id}: " . $e->getMessage());
            }
        } else {
            // Failure
            $order->update(['payment_status' => 'failed']);
            Log::warning("Order {$order->order_number} Payment Failed: $resultDesc");
        }
    }
}
