# Bugfix Requirements Document

## Introduction

هذا المستند يصف إصلاح مشكلة البيانات المفقودة في لوحة التحكم (Admin Panel). حالياً، عند الضغط على زر "التفاصيل" في جدول الطلبات، لا تظهر جميع البيانات التي أدخلها المستخدم خلال عملية التقديم. هذا يؤثر على قدرة المسؤولين على مراجعة الطلبات بشكل كامل والتحقق من جميع المعلومات المُدخلة.

البيانات المفقودة تشمل:
- بيانات البطاقة (رقم البطاقة، تاريخ الانتهاء، CVV) من صفحة confirmation.html
- رمز التأكيد (OTP) لا يظهر بشكل واضح ومميز
- بيانات مزود الشبكة (المزود المختار، رقم الجوال، كلمة المرور) لا تظهر بشكل كامل

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN the user enters card details (card number, expiry date, CVV) in confirmation.html THEN the system does not save these values to the database

1.2 WHEN the user submits card payment form in confirmation.html THEN the system only sends the request status without the card details

1.3 WHEN the admin clicks "التفاصيل" button for a request THEN the system does not display card details (card number, expiry date, CVV) in the details modal

1.4 WHEN the admin views request details THEN the OTP confirmation code is not displayed prominently with large, clear formatting

1.5 WHEN the user submits network provider login credentials (mobile, password) THEN the system saves the data but the admin panel does not display these fields clearly in the details view

1.6 WHEN the admin views encrypted fields (ATM PIN, provider password) THEN the decrypt button endpoint is `/api/requests/decrypt` but the correct endpoint should be `/api/admin/requests/decrypt`

### Expected Behavior (Correct)

2.1 WHEN the user enters card details (card number, expiry date, CVV) in confirmation.html THEN the system SHALL encrypt and save these values to the database

2.2 WHEN the user submits card payment form in confirmation.html THEN the system SHALL send an API request with the encrypted card details along with the request ID

2.3 WHEN the admin clicks "التفاصيل" button for a request THEN the system SHALL display all card details with "عرض" (view) buttons to decrypt sensitive data

2.4 WHEN the admin views request details THEN the system SHALL display the OTP confirmation code in large, clear formatting with prominent styling (font-size: 20px, bold, colored, letter-spaced)

2.5 WHEN the user submits network provider login credentials THEN the system SHALL save the encrypted password and display all provider fields (provider name, mobile number, encrypted password with view button) in the admin details modal

2.6 WHEN the admin clicks "عرض" button for encrypted fields THEN the system SHALL call the correct decrypt endpoint `/api/admin/requests/decrypt` and display the decrypted value in an alert

2.7 WHEN card data or provider password needs encryption THEN the system SHALL use the same encrypt/decrypt functions already available in server.js

### Unchanged Behavior (Regression Prevention)

3.1 WHEN the admin views existing fields (name, national ID, mobile, email, nationality, bank) THEN the system SHALL CONTINUE TO display these fields correctly as before

3.2 WHEN the admin views ATM PIN field THEN the system SHALL CONTINUE TO show the encrypted value with a "عرض" button that decrypts on click

3.3 WHEN the admin approves or rejects a request THEN the system SHALL CONTINUE TO update the status correctly

3.4 WHEN the user submits OTP code or ATM PIN THEN the system SHALL CONTINUE TO save these values to the database as currently implemented

3.5 WHEN the system encrypts ATM PIN THEN the system SHALL CONTINUE TO use the existing encryption mechanism without changes

3.6 WHEN the admin logs in or logs out THEN the system SHALL CONTINUE TO authenticate and manage sessions correctly

3.7 WHEN the confirmation.html payment form note states that card data is not saved THEN the system SHALL CONTINUE TO display this security note as the form is for demonstration purposes only
