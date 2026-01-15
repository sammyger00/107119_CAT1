$ErrorActionPreference = "Stop"

Write-Host "=== Testing Customer Flow (Simple) ===" -ForegroundColor Cyan

# 1. Login
Write-Host "`n1. Logging in..."
$login = Invoke-WebRequest -Uri 'http://localhost:8001/api/v1/login' -Method POST -Body (@{email='customer@matiko.com';password='password'} | ConvertTo-Json) -ContentType 'application/json'
$token = ($login.Content | ConvertFrom-Json).token
Write-Host "Token: $token"

# 2. Get Events
Write-Host "`n2. Getting Events..."
$events = Invoke-WebRequest -Uri 'http://localhost:8001/api/v1/events'
$event = ($events.Content | ConvertFrom-Json).data[0]
Write-Host "Event: $($event.name) ($($event.id))"

# 3. Get Category
$category = $event.categories[0]
Write-Host "Category: $($category.name) ($($category.id))"

# 4. Place Order
Write-Host "`n3. Placing Order..."
$headers = @{Authorization="Bearer $token"}
$orderBody = @{
    event_id = $event.id
    ticket_category_id = $category.id
    phone_number = "0712345678"
} | ConvertTo-Json

$orderReq = Invoke-WebRequest -Uri 'http://localhost:8001/api/v1/orders' -Method POST -Headers $headers -Body $orderBody -ContentType 'application/json'
$orderData = $orderReq.Content | ConvertFrom-Json
$order = $orderData.order
$checkoutId = $orderData.mpesa_response.CheckoutRequestID
Write-Host "Order Created: $($order.order_number)"
Write-Host "CheckoutID: $checkoutId"

# 5. Callback
Write-Host "`n4. Sending Callback..."
$callbackBody = @{
    Body = @{
        stkCallback = @{
            MerchantRequestID = "12345"
            CheckoutRequestID = $checkoutId
            ResultCode = 0
            ResultDesc = "The service request is processed successfully."
            CallbackMetadata = @{
                Item = @()
            }
        }
    }
} | ConvertTo-Json

$callbackReq = Invoke-WebRequest -Uri 'http://localhost:8001/api/v1/payments/callback' -Method POST -Body $callbackBody -ContentType 'application/json'
Write-Host "Callback Response: $($callbackReq.Content)"

# 6. Verify
Write-Host "`n5. Verifying..."
$myOrders = Invoke-WebRequest -Uri 'http://localhost:8001/api/v1/my-orders' -Headers $headers
$updatedOrder = ($myOrders.Content | ConvertFrom-Json).data | Where-Object { $_.id -eq $order.id }
Write-Host "Order Status: $($updatedOrder.payment_status)"

$myTickets = Invoke-WebRequest -Uri 'http://localhost:8001/api/v1/my-tickets' -Headers $headers
$ticket = ($myTickets.Content | ConvertFrom-Json).data | Where-Object { $_.order_id -eq $order.id }

if ($ticket) {
    Write-Host "Ticket Generated! QR: $($ticket.qr_code)"
} else {
    Write-Host "No Ticket Found!"
}
