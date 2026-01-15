<?php

namespace App\Services;

use App\Models\Order;
use Carbon\Carbon;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class DarajaService
{
    protected $baseUrl;
    protected $consumerKey;
    protected $consumerSecret;
    protected $passkey;
    protected $shortcode;
    protected $callbackUrl;

    public function __construct()
    {
        $this->baseUrl = config('services.daraja.base_url');
        $this->consumerKey = config('services.daraja.key');
        $this->consumerSecret = config('services.daraja.secret');
        $this->passkey = config('services.daraja.passkey');
        $this->shortcode = config('services.daraja.shortcode');
        $this->callbackUrl = config('services.daraja.callback_url');
    }

    /**
     * Get access token from Daraja API with caching
     */
    public function getAccessToken()
    {
        return Cache::remember('daraja_token', 3500, function () {
            $credentials = base64_encode($this->consumerKey . ':' . $this->consumerSecret);

            $response = Http::withHeaders([
                'Authorization' => 'Basic ' . $credentials,
            ])->get($this->baseUrl . '/oauth/v1/generate?grant_type=client_credentials');

            if ($response->successful()) {
                return $response->json()['access_token'];
            }

            Log::error('Daraja Token Error: ' . $response->body());
            throw new \Exception('Failed to obtain Daraja Access Token');
        });
    }

    /**
     * Initiate STK Push
     */
    public function initiateStkPush(Order $order, $phoneNumber)
    {
        $token = $this->getAccessToken();
        
        $timestamp = Carbon::now()->format('YmdHis');
        $password = base64_encode($this->shortcode . $this->passkey . $timestamp);

        // Format phone number to 254...
        $phone = $this->formatPhoneNumber($phoneNumber);

        $response = Http::withToken($token)->post($this->baseUrl . '/mpesa/stkpush/v1/processrequest', [
            'BusinessShortCode' => $this->shortcode,
            'Password' => $password,
            'Timestamp' => $timestamp,
            'TransactionType' => 'CustomerPayBillOnline',
            'Amount' => (int) $order->amount, // Ensure integer
            'PartyA' => $phone,
            'PartyB' => $this->shortcode,
            'PhoneNumber' => $phone,
            'CallBackURL' => $this->callbackUrl,
            'AccountReference' => 'Order ' . $order->order_number,
            'TransactionDesc' => 'Payment for Order ' . $order->order_number,
        ]);

        if ($response->successful()) {
            return $response->json();
        }

        Log::error('Daraja STK Push Error: ' . $response->body());
        throw new \Exception('STK Push Failed: ' . ($response->json()['errorMessage'] ?? 'Unknown Error'));
    }

    /**
     * Helper to format phone number to 254 format
     */
    protected function formatPhoneNumber($phone)
    {
        $phone = preg_replace('/[^0-9]/', '', $phone);
        if (str_starts_with($phone, '0')) return '254' . substr($phone, 1);
        if (str_starts_with($phone, '7') || str_starts_with($phone, '1')) return '254' . $phone;
        return $phone;
    }
}
