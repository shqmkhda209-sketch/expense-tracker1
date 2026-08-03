/// رشته‌های متنی ثابت برنامه (فارسی)
class AppStrings {
  AppStrings._();

  static const appName = 'حساب‌دار من';

  // صفحه اصلی
  static const totalBalance = 'موجودی کل';
  static const totalIncome = 'مجموع درآمد';
  static const totalExpense = 'مجموع هزینه';
  static const addIncome = 'افزودن درآمد';
  static const addExpense = 'افزودن هزینه';
  static const reports = 'گزارش‌ها';
  static const recentTransactions = 'آخرین تراکنش‌ها';
  static const seeAll = 'مشاهده همه';
  static const noTransactions = 'هنوز تراکنشی ثبت نشده است';
  static const noTransactionsHint = 'با دکمه‌های بالا اولین تراکنش خود را اضافه کنید';

  // فرم افزودن/ویرایش
  static const amount = 'مبلغ';
  static const title = 'عنوان';
  static const category = 'دسته‌بندی';
  static const date = 'تاریخ';
  static const description = 'توضیحات (اختیاری)';
  static const save = 'ذخیره';
  static const update = 'به‌روزرسانی';
  static const cancel = 'انصراف';
  static const editTransaction = 'ویرایش تراکنش';
  static const newIncome = 'درآمد جدید';
  static const newExpense = 'هزینه جدید';
  static const savedSuccessfully = 'با موفقیت ذخیره شد';
  static const updatedSuccessfully = 'با موفقیت به‌روزرسانی شد';
  static const deletedSuccessfully = 'با موفقیت حذف شد';

  // اعتبارسنجی
  static const amountRequired = 'وارد کردن مبلغ الزامی است';
  static const amountInvalid = 'مبلغ وارد شده معتبر نیست';
  static const titleRequired = 'وارد کردن عنوان الزامی است';
  static const categoryRequired = 'انتخاب دسته‌بندی الزامی است';

  // لیست تراکنش‌ها
  static const allTransactions = 'همه تراکنش‌ها';
  static const search = 'جستجو در تراکنش‌ها...';
  static const filter = 'فیلتر';
  static const sort = 'مرتب‌سازی';
  static const edit = 'ویرایش';
  static const delete = 'حذف';
  static const deleteConfirmTitle = 'حذف تراکنش';
  static const deleteConfirmMessage = 'آیا از حذف این تراکنش مطمئن هستید؟ این عمل قابل بازگشت نیست.';
  static const all = 'همه';
  static const incomeOnly = 'فقط درآمد';
  static const expenseOnly = 'فقط هزینه';
  static const newestFirst = 'جدیدترین';
  static const oldestFirst = 'قدیمی‌ترین';
  static const highestAmount = 'بیشترین مبلغ';
  static const lowestAmount = 'کمترین مبلغ';

  // گزارش‌ها
  static const monthlyIncome = 'درآمد این ماه';
  static const monthlyExpense = 'هزینه این ماه';
  static const monthlyBalance = 'مانده حساب';
  static const expenseByCategory = 'نمودار هزینه‌ها بر اساس دسته';
  static const monthlyChart = 'نمودار درآمد و هزینه ماهانه';
  static const topExpenseCategory = 'بیشترین دسته هزینه';
  static const topIncomeCategory = 'بیشترین دسته درآمد';
  static const noData = 'داده‌ای برای نمایش وجود ندارد';

  // تنظیمات
  static const settings = 'تنظیمات';
  static const theme = 'تم برنامه';
  static const lightTheme = 'روشن';
  static const darkTheme = 'تیره';
  static const systemTheme = 'پیش‌فرض سیستم';
  static const currency = 'واحد پول';
  static const backup = 'تهیه نسخه پشتیبان';
  static const backupDesc = 'خروجی گرفتن از تمام اطلاعات به‌صورت فایل JSON';
  static const restore = 'بازیابی نسخه پشتیبان';
  static const restoreDesc = 'بازگرداندن اطلاعات از یک فایل پشتیبان';
  static const deleteAll = 'حذف تمام اطلاعات';
  static const deleteAllDesc = 'حذف کامل و غیرقابل بازگشت تمام تراکنش‌ها';
  static const deleteAllConfirm = 'با این کار تمام تراکنش‌های ثبت‌شده برای همیشه حذف می‌شوند. این عمل قابل بازگشت نیست.';
  static const dailyReminder = 'یادآوری روزانه';
  static const dailyReminderDesc = 'یادآوری برای ثبت هزینه‌های روزانه';
  static const reminderTime = 'زمان یادآوری';
  static const backupSuccess = 'نسخه پشتیبان با موفقیت ذخیره شد';
  static const restoreSuccess = 'اطلاعات با موفقیت بازیابی شد';
  static const restoreError = 'فایل پشتیبان معتبر نیست';
  static const allDataDeleted = 'تمام اطلاعات حذف شد';
}
