# Daraja API Setup Guide

## 1. Environment Variables
Add these to your `.env` file:

```env
DARAJA_BASE_URL=https://sandbox.safaricom.co.ke
DARAJA_CONSUMER_KEY=your_consumer_key
DARAJA_CONSUMER_SECRET=your_consumer_secret
DARAJA_SHORTCODE=174379
DARAJA_PASSKEY=bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919
DARAJA_CALLBACK_URL=https://your-domain.com/api/v1/payments/callback
```

> **Note**: For local testing with `localhost`, use ngrok to expose your server and update `DARAJA_CALLBACK_URL`.

## 2. Queue Configuration
For local development, ensure queues run synchronously:
```env
QUEUE_CONNECTION=sync
```
For production, use `database` or `redis` and run `php artisan queue:work`.

## 3. Testing the Flow
1. Go to `http://localhost:8001`.
2. Select an Event.
3. Choose a Ticket Category.
4. Enter your M-Pesa phone number.
5. Click **Pay with M-Pesa**.
6. You should receive an STK Push on your phone (if credentials are valid) or see a success message (mock/if sandbox).
7. If simulating callback locally:
   ```bash
   curl -X POST http://localhost:8001/api/v1/payments/callback \
     -H "Content-Type: application/json" \
     -d @stk_callback_payload.json
   ```

## 4. Verification
Check `mpesa_transactions` table:
```bash
php artisan tinker
> DB::table('mpesa_transactions')->get()
```
Check `orders` table for status `paid`:
```bash
> App\Models\Order::where('payment_status', 'paid')->get()
```
