# Test all user roles
Write-Host "`n=== Testing Authentication System ===" -ForegroundColor Cyan

# Test users
$users = @(
    @{email='customer@matiko.com'; password='password'; role='Customer'},
    @{email='agent@matiko.com'; password='password'; role='Agent'},
    @{email='admin@matiko.com'; password='password'; role='Admin'},
    @{email='superadmin@matiko.com'; password='password'; role='Super Admin'}
)

foreach ($user in $users) {
    Write-Host "`nTesting $($user.role) login..." -ForegroundColor Yellow
    
    $body = @{
        email = $user.email
        password = $user.password
    } | ConvertTo-Json
    
    try {
        $response = Invoke-WebRequest -Uri 'http://localhost:8001/api/v1/login' `
            -Method POST `
            -Body $body `
            -ContentType 'application/json' `
            -ErrorAction Stop
        
        $data = $response.Content | ConvertFrom-Json
        
        Write-Host "✓ Login successful" -ForegroundColor Green
        Write-Host "  Name: $($data.user.name)" -ForegroundColor Gray
        Write-Host "  Role: $($data.user.role)" -ForegroundColor Gray
        Write-Host "  Permissions: $($data.user.permissions.Count) total" -ForegroundColor Gray
        Write-Host "  Token: $($data.token.Substring(0, 20))..." -ForegroundColor Gray
        
    } catch {
        Write-Host "✗ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== Test Complete ===" -ForegroundColor Cyan
