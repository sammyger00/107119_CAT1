# Test Customer Flow
Write-Host "=== Testing Customer Flow ===" -ForegroundColor Cyan

# 1. Login
Write-Host "`n1. Logging in as Customer..." -ForegroundColor Yellow
$login = Invoke-WebRequest -Uri 'http://localhost:8001/api/v1/login' -Method POST -Body (@{email='customer@matiko.com';password='password'} | ConvertTo-Json) -ContentType 'application/json'
$token = ($login.Content | ConvertFrom-Json).token
Write-Host "✓ Logged in. Token: $token" -ForegroundColor Green

# 2. Get Events
Write-Host "`n2. Fetching Events..." -ForegroundColor Yellow
$events = Invoke-WebRequest -Uri 'http://localhost:8001/api/v1/events'
$eventData = $events.Content | ConvertFrom-Json
$event = $eventData.data[0]

if (-not $event) {
    Write-Error "No events found!"
    exit
}
Write-Host "✓ Found Event: $($event.name) (ID: $($event.id))" -ForegroundColor Green

# 3. Get Ticket Categories for Event
$category = $event.categories[0]
if (-not $category) {
    Write-Error "No ticket categories found for event!"
    exit
}
Write-Host "✓ Found Category: $($category.name) (Price: $($category.price))" -ForegroundColor Green

# 4. Place Order
Write-Host "`n3. Placing Order..." -ForegroundColor Yellow
$headers = @{Authorization="Bearer $token"}
$orderBody = @{
    event_id = $event.id
    ticket_category_id = $category.id
    phone_number = "0712345678"
} | ConvertTo-Json

try {
    $orderReq = Invoke-WebRequest -Uri 'http://localhost:8001/api/v1/orders' -Method POST -Headers $headers -Body $orderBody -ContentType 'application/json'
    $orderData = $orderReq.Content | ConvertFrom-Json
    $order = $orderData.order
    $checkoutId = $orderData.mpesa_response.CheckoutRequestID
    
    Write-Host "✓ Order Created: $($order.order_number)" -ForegroundColor Green
    Write-Host "  Status: $($order.payment_status)" -ForegroundColor Gray
    Write-Host "  CheckoutID: $checkoutId" -ForegroundColor Gray
} catch {
    Write-Error "Order Failed: $($_.Exception.Message)"
    if ($_.ErrorDetails) {
        Write-Host $_.ErrorDetails.Message
    } else {
        Write-Host "No error details."
    }
    exit
}

# 5. Simulate Payment Callback
Write-Host "`n4. Simulating Payment Callback..." -ForegroundColor Yellow
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
$res = $callbackReq.Content | ConvertFrom-Json
Write-Host "✓ Callback Sent: Result: $($res.result)" -ForegroundColor Green

# 6. Verify Order is Paid
Write-Host "`n5. Verifying Order Status..." -ForegroundColor Yellow
$myOrders = Invoke-WebRequest -Uri 'http://localhost:8001/api/v1/my-orders' -Headers $headers
$updatedOrder = ($myOrders.Content | ConvertFrom-Json).data | Where-Object { $_.id -eq $order.id }

if ($updatedOrder.payment_status -eq 'paid') {
    Write-Host "✓ Order is PAID!" -ForegroundColor Green
} else {
    Write-Host "✗ Order status is: $($updatedOrder.payment_status)" -ForegroundColor Red
}

# 7. Check for Tickets
Write-Host "`n6. Checking for Tickets..." -ForegroundColor Yellow
$myTickets = Invoke-WebRequest -Uri 'http://localhost:8001/api/v1/my-tickets' -Headers $headers
$ticket = ($myTickets.Content | ConvertFrom-Json).data | Where-Object { $_.order_id -eq $order.id }

if ($ticket) {
    Write-Host "✓ Ticket Generated!" -ForegroundColor Green
    Write-Host "  QR Code: $($ticket.qr_code)" -ForegroundColor Cyan
} else {
    Write-Host "✗ No ticket found for order." -ForegroundColor Red
}

Write-Host "`n=== Test Complete ===" -ForegroundColor Cyan
