$env:PORT="3000"
$env:ADMIN_USER="admin"
$env:ADMIN_PASSWORD="test123"
$env:SESSION_SECRET="test-session-secret"
$env:ENCRYPTION_KEY="0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
$env:DATA_DIR="./data"

Write-Host "Starting Himyan Server..." -ForegroundColor Cyan
node server.js
