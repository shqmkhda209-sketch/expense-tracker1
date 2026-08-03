# حساب‌دار من — اپلیکیشن آفلاین مدیریت درآمد و هزینه

اپلیکیشن Flutter، کاملاً آفلاین، برای ثبت و مدیریت تراکنش‌های شخصی با پایگاه داده SQLite محلی.

## ✅ چه چیزی در این پروژه آماده است؟

تمام کد Dart لایه‌های `core`, `domain`, `data`, `presentation`, `services` به‌صورت
کامل نوشته شده‌اند (بیش از ۳۰ فایل) و شامل موارد زیر است:

- مدل‌ها، دیتابیس SQLite (sqflite) و ریپازیتوری‌ها
- مدیریت وضعیت با `provider` (بدون نیاز به build_runner)
- صفحات: خانه، افزودن/ویرایش تراکنش، لیست کامل با جستجو/فیلتر/مرتب‌سازی، گزارش‌ها، تنظیمات
- نمودار دایره‌ای و میله‌ای با `fl_chart`
- تم روشن/تیره Material 3 با رنگ اصلی سبز (#22C55E)
- فونت وزیرمتن (Vazirmatn) به‌صورت آفلاین در پوشه `assets/fonts`
- پشتیبان‌گیری/بازیابی JSON، حذف کامل داده‌ها
- یادآوری روزانه با `flutter_local_notifications`

## ⚠️ مرحله‌ای که باید خودتان انجام دهید (مهم)

این کد در محیطی نوشته شده که به `pub.dev` و ابزار Flutter SDK دسترسی نداشت،
بنابراین پوشه‌های پلتفرمی (`android/`, `ios/`) که معمولاً با دستور
`flutter create` ساخته می‌شوند، در این خروجی وجود ندارند. برای اجرای پروژه:

```bash
# ۱. در یک پوشه خالی، اسکلت پروژه را بسازید
flutter create --org com.example expense_tracker_shell
# ۲. پوشه‌های android و ios ساخته‌شده را به این پروژه کپی کنید
cp -r expense_tracker_shell/android  expense_tracker/
cp -r expense_tracker_shell/ios      expense_tracker/
# ۳. وابستگی‌ها را نصب کنید
cd expense_tracker
flutter pub get
# ۴. اجرا
flutter run
```

### تنظیمات لازم در android/app/src/main/AndroidManifest.xml

برای کارکرد صحیح اعلان‌های محلی (یادآوری روزانه)، این خطوط را داخل تگ
`<manifest>` (بالای `<application>`) اضافه کنید:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

و در `android/app/build.gradle` مطمئن شوید:

```gradle
minSdkVersion 23   // حداقل برای sqflite و local notifications
```

## 📂 ساختار پروژه

```
lib/
  core/            رنگ‌ها، رشته‌ها، دسته‌بندی‌ها، تم، توابع کمکی
  domain/          موجودیت‌ها و قرارداد ریپازیتوری (Clean Architecture)
  data/            مدل‌ها، دیتابیس SQLite، پیاده‌سازی ریپازیتوری‌ها
  presentation/
    providers/     مدیریت وضعیت (ChangeNotifier)
    screens/       صفحات اصلی برنامه
    widgets/       ویجت‌های قابل استفاده مجدد
  services/        اعلان‌ها و پشتیبان‌گیری
  main.dart        نقطه ورود برنامه
```

## 🎨 رنگ‌ها

| مورد | رنگ |
|---|---|
| اصلی | `#22C55E` |
| درآمد | سبز |
| هزینه | قرمز `#EF4444` |

## 🗄️ دیتابیس

از `sqflite` (بدون نیاز به code-generation) استفاده شده تا پروژه در هر محیطی
بدون اجرای `build_runner` قابل build باشد. ایندکس روی ستون‌های `date` و `type`
برای عملکرد روان حتی با ده‌ها هزار تراکنش ایجاد شده است.

## 💾 پشتیبان‌گیری

خروجی JSON شامل نسخه فرمت و تمام تراکنش‌ها است و از طریق `share_plus` برای
ذخیره یا اشتراک‌گذاری در دستگاه در دسترس قرار می‌گیرد — هیچ اتصال اینترنتی
برقرار نمی‌شود.

## 📲 گرفتن فایل نصبی APK (بدون نصب چیزی روی سیستم خودتان)

این پروژه یک وورک‌فلوی GitHub Actions آماده در مسیر
`.github/workflows/build-apk.yml` دارد که به‌صورت خودکار APK را می‌سازد:

1. یک ریپازیتوری جدید و **خصوصی** در GitHub بسازید و کل این پوشه را در آن push کنید.
2. به تب **Actions** ریپازیتوری بروید؛ وورک‌فلوی «Build Android APK» خودش
   با اولین push اجرا می‌شود (یا از دکمه «Run workflow» استفاده کنید).
3. حدود ۵ تا ۱۰ دقیقه صبر کنید تا اجرا تمام شود (سبز شود).
4. روی همان اجرا کلیک کنید، در پایین صفحه بخش **Artifacts** فایل
   `expense-tracker-apk` را دانلود کنید — یک ZIP حاوی `app-release.apk` است.
5. فایل APK را به گوشی اندروید منتقل کرده و نصب کنید (باید «نصب از منابع
   ناشناس» را برای آن فعال کنید).

## نکته درباره کامپایل

از آنجا که ساخت این پروژه در محیطی بدون دسترسی به Flutter SDK/pub.dev انجام
شده، کد به‌صورت دستی و با دقت نوشته شده اما با `flutter analyze` تست نشده است.
اگر پس از `flutter pub get` خطای جزئی (مثلاً نام‌گذاری پارامتر در یک نسخه جدیدتر
پکیج) مشاهده کردید، به‌احتمال زیاد با تطبیق نسخه پکیج در `pubspec.yaml` قابل
رفع است.
