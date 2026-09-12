@echo off
set PORT=3000
set ADMIN_USER=admin
set ADMIN_PASSWORD=test123
set SESSION_SECRET=test-session-secret-for-development
set ENCRYPTION_KEY=0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
set DATA_DIR=./data
node server.js
