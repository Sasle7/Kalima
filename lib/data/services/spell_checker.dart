import 'dart:collection';
import 'dart:math';

class SpellResult {
  final bool isCorrect;
  final List<String> suggestions;
  final String original;

  const SpellResult({
    required this.original,
    this.isCorrect = true,
    this.suggestions = const [],
  });
}

class SpellError {
  final String word;
  final int startOffset;
  final int endOffset;
  final List<String> suggestions;
  final String? ruleViolated;

  const SpellError({
    required this.word,
    required this.startOffset,
    required this.endOffset,
    this.suggestions = const [],
    this.ruleViolated,
  });
}

class SpellChecker {
  final Set<String> _dictionary = {};
  final Set<String> _userDictionary = {};
  final Set<String> _ignoredWords = {};
  final Map<String, String> _commonMisspellings = {};
  final Map<String, String> _hamzaReplacements = {};
  final Map<String, String> _taaMarboutaReplacements = {};
  final Map<String, String> _alifMaqsuraReplacements = {};
  final int _maxSuggestions;

  SpellChecker({this._maxSuggestions = 10}) {
    _initializeDictionary();
    _initializeArabicRules();
    _initializeCommonMisspellings();
  }

  void _initializeDictionary() {
    final words = [
      'من', 'إلى', 'عن', 'على', 'في', 'لا', 'ما', 'هو', 'هي', 'هم', 'هن',
      'كان', 'ليس', 'إن', 'أن', 'قد', 'لن', 'لم', 'لما', 'سوف', 'سـ',
      'هذا', 'هذه', 'هؤلاء', 'ذلك', 'تلك', 'أولئك', 'الذي', 'التي', 'الذين', 'اللواتي',
      'أنا', 'نحن', 'أنت', 'أنت', 'أنتما', 'أنتم', 'أنتن', 'هو', 'هي', 'هما', 'هم', 'هن',
      'فعل', 'يفعل', 'افعل', 'مفعول', 'فاعل', 'فعيل', 'تفعيل', 'مفاعلة', 'استفعال',
      'ذهب', 'يذهب', 'اذهب', 'مذهب', 'ذاهب', 'ذهاب',
      'كتب', 'يكتب', 'اكتب', 'مكتب', 'كاتب', 'كتاب', 'مكتوب', 'كتابة', 'كتّاب', 'مكتبة',
      'قرأ', 'يقرأ', 'اقرأ', 'مقرأ', 'قارئ', 'قراءة', 'مقروء', 'قرآن',
      'علم', 'يعلم', 'اعلم', 'معلم', 'عالم', 'علماء', 'تعليم', 'معلوم', 'عليم', 'علام',
      'عمل', 'يعمل', 'اعمل', 'معمل', 'عامل', 'عمال', 'عمّال', 'عميل', 'معمول', 'عَمَل',
      'قال', 'يقول', 'قل', 'مقال', 'قائل', 'مقول', 'قول', 'مقولة', 'قيل',
      'جاء', 'يجيء', 'اجئ', 'مجيء', 'جائي', 'مجيء',
      'فتح', 'يفتح', 'افتح', 'مفتاح', 'فاتح', 'فتاحة', 'فتح', 'مفتوح', 'فتّاح',
      'جلس', 'يجلس', 'اجلس', 'مجلس', 'جالس', 'جليس', 'جلسة', 'مجالس',
      'خرج', 'يخرج', 'اخرج', 'مخرج', 'خارج', 'خروج', 'مخرجة',
      'دخل', 'يدخل', 'ادخل', 'مدخل', 'داخل', 'دخول', 'مدخول', 'دخلة',
      'أكل', 'يأكل', 'كل', 'مأكل', 'آكل', 'أكول', 'أكلة', 'مأكول',
      'شرب', 'يشرب', 'اشرب', 'مشرب', 'شارب', 'شروب', 'مشروب', 'شراب', 'شربة',
      'سأل', 'يسأل', 'اسأل', 'مسألة', 'سائل', 'مسؤول', 'سؤال', 'أسئلة',
      'حسب', 'يحسب', 'احسب', 'محسب', 'حاسب', 'حساب', 'محسوب', 'حسابات',
      'طلب', 'يطلب', 'اطلب', 'مطلب', 'طالب', 'طلاب', 'مطلوب', 'طلب', 'طلبة',
      'بحث', 'يبحث', 'ابحث', 'مبحث', 'باحث', 'بحاث', 'مبحوث', 'بحث', 'أبحاث',
      'درس', 'يدرس', 'ادرس', 'مدرس', 'دارس', 'دروس', 'مدروس', 'دراسة', 'مدرسة',
      'فهم', 'يفهم', 'افهم', 'مفهم', 'فاهم', 'فهم', 'مفهوم', 'فهمان',
      'حمل', 'يحمل', 'احمل', 'محمل', 'حامل', 'حمّال', 'محمول', 'حمولة', 'حمول',
      'ساعد', 'يساعد', 'ساعد', 'مساعدة', 'مساعد', 'مساعدة',
      'شارك', 'يشارك', 'شارك', 'مشاركة', 'مشارك', 'شريك', 'شركاء',
      'تعلم', 'يتعلم', 'تعلم', 'تعلم', 'تعليم', 'متعلم',
      'استعمل', 'يستعمل', 'استعمل', 'استعمال', 'مستعمل',
      'استخدم', 'يستخدم', 'استخدم', 'استخدام', 'مستخدم',
      'استطاع', 'يستطيع', 'استطع', 'استطاعة', 'مستطيع',
      'استغفر', 'يستغفر', 'استغفر', 'استغفار', 'مستغفر',
      'كان', 'يكون', 'كن', 'كائن', 'كيان', 'تكوين', 'مكون', 'كائن',
      'صار', 'يصير', 'صر', 'صائرة', 'مصير', 'صيرورة',
      'ليس', 'ليس', 'لا',
      'كتاب', 'كتاب', 'الكتاب', 'كتابي', 'كتابك', 'كتابه', 'كتب', 'الكتب',
      'قلم', 'قلم', 'أقلام', 'قلمي', 'قلمك', 'قلمه',
      'بيت', 'بيت', 'بيوت', 'بيتي', 'بيتك', 'بيته', 'بيتاً',
      'رجل', 'رجل', 'رجال', 'رجلي', 'رجلك', 'رجله', 'رِجَال',
      'امرأة', 'امرأة', 'نساء', 'نساء', 'امرأتي', 'امرأتك', 'امرأته',
      'ولد', 'ولد', 'أولاد', 'ولدي', 'ولدك', 'ولده', 'مولود', 'ولادة',
      'بنت', 'بنت', 'بنات', 'بنتي', 'بنتك', 'بنته', 'بنو', 'بنات',
      'مدير', 'مدير', 'مديرة', 'مديرون', 'مديرين', 'مدراء', 'إدارة',
      'مهندس', 'مهندس', 'مهندسة', 'مهندسون', 'مهندسين', 'مهندسات',
      'طبيب', 'طبيب', 'طبيبة', 'أطباء', 'طبابة', 'طب',
      'معلم', 'معلم', 'معلمة', 'معلمون', 'معلمين', 'معلمات', 'تعليم',
      'محام', 'محام', 'محاماة', 'محامون', 'محامين',
      'تلميذ', 'تلميذ', 'تلميذة', 'تلاميذ', 'تلميذات',
      'جامعة', 'جامعة', 'جامعات', 'جامعي', 'جامعية',
      'مدرسة', 'مدرسة', 'مدارس', 'دراسي', 'دراسية',
      'مستشفى', 'مستشفى', 'مستشفيات', 'مستشفيان',
      'مكتب', 'مكتب', 'مكاتب', 'مكتبي', 'مكتبة', 'مكتبات',
      'مطبخ', 'مطبخ', 'مطابخ', 'مطبخي', 'مطبخك',
      'حمام', 'حمام', 'حمامات', 'حمامي', 'حمامك',
      'غرفة', 'غرفة', 'غرف', 'غرفتي', 'غرفتك', 'غرفته',
      'سوق', 'سوق', 'أسواق', 'سوقي', 'سوقك', 'تسوق',
      'مدينة', 'مدينة', 'مدن', 'مدينتي', 'مدينتك', 'مدينته',
      'قرية', 'قرية', 'قرى', 'قريتي', 'قريتك', 'قريته',
      'شارع', 'شارع', 'شوارع', 'شارعي', 'شارعك', 'شارعه',
      'طريق', 'طريق', 'طرق', 'طريقي', 'طريقك', 'طريقه',
      'جسر', 'جسر', 'جسور', 'جسري', 'جسرك', 'جسره',
      'نهر', 'نهر', 'أنهار', 'نهري', 'نهرك', 'نهره',
      'بحر', 'بحر', 'بحار', 'بحري', 'بحرك', 'بحره', 'بحار',
      'جبل', 'جبل', 'جبال', 'جبلي', 'جبل', 'جبله',
      'واد', 'واد', 'أودية', 'وادي', 'واديك', 'واديه',
      'صحراء', 'صحراء', 'صحارى', 'صحراوي',
      'شمس', 'شمس', 'شموس', 'شمسي', 'شمسي', 'شمسية',
      'قمر', 'قمر', 'أقمار', 'قمري', 'قمرك', 'قمره',
      'نجم', 'نجم', 'نجوم', 'نجمي', 'نجمك', 'نجمه',
      'سماء', 'سماء', 'سماوات', 'سماوي', 'سماوية',
      'أرض', 'أرض', 'أراض', 'أرضي', 'أرضك', 'أرضه', 'أراضي',
      'نار', 'نار', 'نيران', 'ناري', 'نارك', 'ناره',
      'ماء', 'ماء', 'مياه', 'مائي', 'مائية', 'مياه',
      'هواء', 'هواء', 'هوائي', 'هوائية',
      'نور', 'نور', 'أنوار', 'نوري', 'نورك', 'نوره', 'نوار', 'منور',
      'ظلام', 'ظلام', 'ظلمة', 'مظلم', 'ظلماء',
      'يوم', 'يوم', 'أيام', 'يومي', 'يومك', 'يومه', 'أيام',
      'شهر', 'شهر', 'شهور', 'شهري', 'شهرك', 'شهره', 'أشهر',
      'سنة', 'سنة', 'سنين', 'سنوات', 'سنتي', 'سنتك', 'سنته', 'عام',
      'ساعة', 'ساعة', 'ساعات', 'ساعتي', 'ساعتك', 'ساعته',
      'دقيقة', 'دقيقة', 'دقائق', 'دقيقتي', 'دقيقتك', 'دقيقته',
      'ثانية', 'ثانية', 'ثوان', 'ثواني', 'ثانيتي',
      'وقت', 'وقت', 'أوقات', 'وقتي', 'وقتك', 'وقته', 'توقيت',
      'زمن', 'زمن', 'أزمنة', 'زمان', 'زمني', 'زمنية', 'أزمنة',
      'مكان', 'مكان', 'أمكنة', 'أماكن', 'مكاني', 'مكانك', 'مكانه',
      'جهة', 'جهة', 'جهات', 'جهتي', 'جهتك', 'جهته',
      'يمين', 'يمين', 'أيمان', 'يمني', 'يمينك', 'يمينه',
      'يسار', 'يسار', 'يساري', 'يسارك', 'يساره',
      'فوق', 'فوق', 'فوقي', 'فوقك', 'فوقه',
      'تحت', 'تحت', 'تحتي', 'تحتك', 'تحته', 'سفلي',
      'داخل', 'داخل', 'داخلي', 'داخلك', 'داخله', 'داخلية',
      'خارج', 'خارج', 'خارجي', 'خارجك', 'خارجه', 'خارجية',
      'أمام', 'أمام', 'أمامي', 'أمامك', 'أمامه',
      'خلف', 'خلف', 'خلفي', 'خلفك', 'خلفه',
      'يمين', 'يسار', 'شمال', 'جنوب', 'شرق', 'غرب',
      'شمال', 'شمال', 'شمالي', 'شمالك', 'شماله', 'شمالية',
      'جنوب', 'جنوب', 'جنوبي', 'جنوبك', 'جنوبه', 'جنوبية',
      'شرق', 'شرق', 'شرقي', 'شرقك', 'شرقه', 'شرقية',
      'غرب', 'غرب', 'غربي', 'غربك', 'غربه', 'غربية',
      'كبير', 'كبير', 'كبيرة', 'كبار', 'كبرى', 'أكبر',
      'صغير', 'صغير', 'صغيرة', 'صغار', 'صغرى', 'أصغر',
      'طويل', 'طويل', 'طويلة', 'طوال', 'طولى', 'أطول',
      'قصير', 'قصير', 'قصيرة', 'قصار', 'قصر', 'أقصر',
      'جميل', 'جميل', 'جميلة', 'جمال', 'أجمل', 'حسن', 'حسنة',
      'قبيح', 'قبيح', 'قبيحة', 'قباحة', 'أقبح',
      'جيد', 'جيد', 'جيدة', 'جياد', 'أجود',
      'سيء', 'سيء', 'سيئة', 'أسوأ', 'سوء',
      'سريع', 'سريع', 'سريعة', 'سراع', 'أسرع', 'سرعة',
      'بطيء', 'بطيء', 'بطيئة', 'بطء', 'أبطأ',
      'ثقيل', 'ثقيل', 'ثقيلة', 'ثقال', 'أثقل', 'ثقل',
      'خفيف', 'خفيف', 'خفيفة', 'خفاف', 'أخف', 'خفة',
      'قوي', 'قوي', 'قوية', 'أقوياء', 'أقوى', 'قوة',
      'ضعيف', 'ضعيف', 'ضعيفة', 'ضعفاء', 'أضعف', 'ضعف',
      'غني', 'غني', 'غنية', 'أغنياء', 'أغنى', 'غنى',
      'فقير', 'فقير', 'فقيرة', 'فقراء', 'أفقر', 'فقر',
      'حار', 'حار', 'حارة', 'حر', 'حرار', 'أحر',
      'بارد', 'بارد', 'باردة', 'برد', 'أبرد', 'برودة',
      'نظيف', 'نظيف', 'نظيفة', 'نظفاء', 'أنظف', 'نظافة',
      'قذر', 'قذر', 'قذرة', 'أقذر', 'قذارة',
      'قديم', 'قديم', 'قديمة', 'قدماء', 'أقدم', 'قدم',
      'جديد', 'جديد', 'جديدة', 'جدد', 'أجدد', 'جدة',
      'حديث', 'حديث', 'حديثة', 'أحداث', 'أحدث', 'حداثة',
      'سهل', 'سهل', 'سهلة', 'سهول', 'أسهل', 'سهولة',
      'صعب', 'صعب', 'صعبة', 'صعاب', 'أصعب', 'صعوبة',
      'قريب', 'قريب', 'قريبة', 'أقارب', 'أقرب', 'قرب',
      'بعيد', 'بعيد', 'بعيدة', 'أباعد', 'أبعد', 'بعد',
      'واسع', 'واسع', 'واسعة', 'أوسع', 'سعة', 'اتساع',
      'ضيق', 'ضيق', 'ضيقة', 'أضيق', 'ضيق', 'ضاق',
      'طيب', 'طيب', 'طيبة', 'طيوب', 'أطيب', 'طيب',
      'خبيث', 'خبيث', 'خبيثة', 'خبثاء', 'أخبث', 'خبث',
      'شريف', 'شريف', 'شريفة', 'شرفاء', 'أشرف', 'شرف',
      'واضح', 'واضح', 'واضحة', 'وضوح', 'أوضح',
      'مهم', 'مهم', 'مهمة', 'أهم', 'أهمية', 'اهتمام',
      'ضروري', 'ضروري', 'ضرورية', 'ضرورات', 'ضرورة',
      'عادي', 'عادي', 'عادية', 'عاديون', 'عادة',
      'خاص', 'خاص', 'خاصة', 'خواص', 'أخص', 'خصوص',
      'عام', 'عام', 'عامة', 'عوام', 'أعم', 'عموم',
      'وحيد', 'وحيد', 'وحيدة', 'وحد', 'أوحد', 'وحدانية',
      'متعدد', 'متعدد', 'متعددة', 'تعدد', 'أكثر',
      'عشرة', 'عشرون', 'ثلاثون', 'أربعون', 'خمسون', 'ستون',
      'سبعون', 'ثمانون', 'تسعون', 'مئة', 'مائتان', 'ثلاث مئة',
      'ألف', 'آلاف', 'مليون', 'ملايين', 'مليار', 'مليارات',
      'أول', 'أولى', 'أولون', 'أولات', 'أولاء',
      'آخر', 'أخرى', 'آخرون', 'أخريات', 'أواخر',
      'كل', 'كل', 'كلما', 'كلية', 'كلي',
      'بعض', 'بعض', 'بعضهم', 'بعضنا', 'بعضكن',
      'نفس', 'نفس', 'أنفس', 'نفسي', 'نفسك', 'نفسه', 'نفسها',
      'ذات', 'ذات', 'ذوات', 'ذاتي', 'ذاتية',
      'غير', 'غير', 'غيري', 'غيرك', 'غيره', 'غيرها',
      'مثل', 'مثل', 'أمثال', 'مثلي', 'مثلك', 'مثله', 'مثيل',
      'شبه', 'شبه', 'أشباه', 'شبيه', 'شبيهة',
      'دون', 'دون', 'دوني', 'دونك', 'دونه', 'دونها',
      'مع', 'مع', 'معي', 'معك', 'معه', 'معها', 'معاً',
      'بين', 'بين', 'بيني', 'بينك', 'بينه', 'بينها',
      'تحت', 'فوق', 'عند', 'لدى', 'لدن', 'عندما',
      'إن', 'أن', 'لو', 'لولا', 'لوما', 'كأن', 'لكن', 'لكن',
      'إذا', 'إذاً', 'إذن', 'حين', 'حينما', 'حيث', 'حيثما',
      'لماذا', 'كيف', 'أين', 'متى', 'كم', 'أي',
      'منذ', 'مذ', 'من', 'في', 'بـ', 'لـ', 'كـ',
      'بعد', 'بعد', 'بعدي', 'بعدك', 'بعده', 'بعدها',
      'قبل', 'قبل', 'قبلي', 'قبلك', 'قبله', 'قبلها',
      'أثناء', 'أثناء', 'خلال', 'وسط', 'أثناء',
      'رب', 'ربما', 'لعل', 'ليت', 'لكن',
      'هكذا', 'هكذا', 'كذا', 'كذلك', 'مثلما',
      'عم', 'عما', 'ممن', 'فيم', 'بم', 'لم', 'لما', 'علام', 'حتى',
      'ثم', 'ثم', 'ثمة',
      'جداً', 'جدا', 'كثيراً', 'قليلاً',
      'نعم', 'لا', 'بلى', 'أجل', 'إي', 'إي والله',
      'أهلاً', 'مرحباً', 'بخير', 'الحمد لله', 'بسم الله',
      'إن شاء الله', 'ما شاء الله', 'تبارك الله', 'سبحان الله',
      'الحمد لله', 'الله أكبر', 'لا إله إلا الله',
      'استغفر الله', 'أستغفر الله', 'بسم الله الرحمن الرحيم',
      'السلام', 'سلام', 'السلام عليكم', 'وعليكم السلام',
      'صباح', 'صباح الخير', 'مساء', 'مساء الخير',
      'تصبح', 'تصبح على خير', 'ليلة', 'ليلة سعيدة',
      'مع السلامة', 'إلى اللقاء', 'وداعاً',
      'شكراً', 'شكراً جزيلاً', 'عفواً', 'آسف', 'آسفة',
      'من فضلك', 'لو سمحت', 'تفضل', 'تفضلي',
      'مبروك', 'مبارك', 'تهانينا', 'تهنئة',
      'كل عام وأنتم بخير', 'عيد', 'عيد مبارك',
      'رمضان', 'رمضان كريم', 'فاطر', 'أضحى', 'أضحى مبارك',
      'وطني', 'وطن', 'أوطان', 'مواطن', 'مواطنة', 'مواطنون',
      'حرية', 'حرية', 'حر', 'أحرار', 'حريات',
      'عدل', 'عدل', 'عدالة', 'عادل', 'عُدول',
      'سلام', 'سلام', 'سلم', 'مسالم', 'مسالمة', 'سلامة',
      'حرب', 'حرب', 'حروب', 'محارب', 'محاربة', 'حربي',
      'حب', 'حب', 'حب', 'محبة', 'أحباب', 'محبوب', 'محب',
      'كراهية', 'كراهية', 'كاره', 'مكروه', 'مكروهة',
      'صداقة', 'صداقة', 'صديق', 'أصدقاء', 'صداقات',
      'عداوة', 'عداوة', 'عدو', 'أعداء', 'عدائية',
      'عائلة', 'عائلة', 'عائلات', 'أسرة', 'أسر',
      'أب', 'أب', 'آباء', 'أبو', 'أبي', 'أبيك', 'أباه',
      'أم', 'أم', 'أمهات', 'أمي', 'أمك', 'أمه',
      'أخ', 'أخ', 'إخوة', 'أخوة', 'أخي', 'أخيك', 'أخاه',
      'أخت', 'أخت', 'أخوات', 'أختي', 'أختك', 'أخته',
      'ابن', 'ابن', 'أبناء', 'ابني', 'ابنك', 'ابنه', 'بني',
      'ابنة', 'ابنة', 'بنات', 'ابنتي', 'ابنتك', 'ابنته',
      'عم', 'عم', 'أعمام', 'عمي', 'عمك', 'عمه', 'عمتي',
      'خال', 'خال', 'أخوال', 'خالي', 'خالك', 'خاله', 'خالتي',
      'جد', 'جد', 'أجداد', 'جدي', 'جدك', 'جده', 'جدة',
      'جدة', 'جدة', 'جدات', 'جدتي', 'جدتك', 'جدتها',
      'زوج', 'زوج', 'أزواج', 'زوجي', 'زوجك', 'زوجه',
      'زوجة', 'زوجة', 'زوجات', 'زوجتي', 'زوجتك', 'زوجته',
      'صديق', 'صديق', 'أصدقاء', 'صديقي', 'صديقك', 'صديقه',
      'صديقة', 'صديقة', 'صديقات', 'صديقتي', 'صديقتك', 'صديقته',
      'جار', 'جار', 'جيران', 'جاري', 'جارك', 'جاره', 'جارة',
      'ضيف', 'ضيف', 'ضيوف', 'ضيفي', 'ضيفك', 'ضيوف',
      'رب', 'رب', 'أرباب', 'ربي', 'ربنا', 'ربكم',
      'إله', 'إله', 'آلهة', 'إلهي', 'إلهكم',
      'دين', 'دين', 'أديان', 'ديني', 'دينك', 'دينه', 'ديانة', 'ديني',
      'إيمان', 'إيمان', 'مؤمن', 'مؤمنون', 'مؤمنات',
      'كفر', 'كفر', 'كافر', 'كفار', 'كفور',
      'صلاة', 'صلاة', 'صلوات', 'مصلي', 'مصلون',
      'زكاة', 'زكاة', 'زكوات', 'مزكي',
      'صوم', 'صوم', 'صيام', 'صائمو', 'صائمون',
      'حج', 'حج', 'حجاج', 'حاج',
      'مسجد', 'مسجد', 'مساجد', 'مسجدي', 'مسجدك',
      'كنيسة', 'كنيسة', 'كنائس', 'كنيستي',
      'معبد', 'معبد', 'معابد', 'معبدي',
      'نبي', 'نبي', 'أنبياء', 'نبوة', 'نبوي',
      'رسول', 'رسول', 'رسل', 'رسالة', 'رسالات', 'رسالي',
      'ملك', 'ملك', 'ملوك', 'مليك', 'مملكة', 'ممالك',
      'سلطان', 'سلطان', 'سلاطين', 'سلطة', 'سلطات',
      'رئيس', 'رئيس', 'رؤساء', 'رئاسة', 'رئيسي',
      'وزير', 'وزير', 'وزراء', 'وزارة', 'وزاري',
      'قائد', 'قائد', 'قادة', 'قيادة',
      'جيش', 'جيش', 'جيوش', 'جيشي', 'جيشك', 'جيشه',
      'جندي', 'جندي', 'جنود', 'جنديان',
      'شرطة', 'شرطة', 'شرطي', 'شرطيون',
      'قاض', 'قاض', 'قضاة', 'قضاء', 'قضائي',
      'محكمة', 'محكمة', 'محاكم', 'محكمتي',
      'سجن', 'سجن', 'سجون', 'مسجون', 'سجين', 'سجناء',
      'حدود', 'حدود', 'حد', 'حدود',
      'قانون', 'قانون', 'قوانين', 'قانوني', 'قانونية',
      'حق', 'حق', 'حقوق', 'حقي', 'حقك', 'حقه', 'حقوقي',
      'واجب', 'واجب', 'واجبات', 'واجبي',
      'فكرة', 'فكرة', 'أفكار', 'فكري', 'فكرية', 'تفكير',
      'رأي', 'رأي', 'آراء', 'رأيي', 'رأيك', 'رأيه',
      'خبر', 'خبر', 'أخبار', 'خبري', 'خبرك', 'خبره', 'إخبار',
      'علم', 'علم', 'علوم', 'عالم', 'علمي', 'علماء',
      'معرفة', 'معرفة', 'معارف', 'معرفي', 'معرفي',
      'جهل', 'جهل', 'جاهل', 'جهلاء', 'جهالة',
      'ثقافة', 'ثقافة', 'ثقافات', 'ثقافي', 'ثقافية',
      'فن', 'فن', 'فنون', 'فني', 'فنية', 'فنان', 'فنانون',
      'أدب', 'أدب', 'آداب', 'أديب', 'أدباء', 'أدبي',
      'شعر', 'شعر', 'أشعار', 'شاعر', 'شعراء', 'شعري',
      'قصة', 'قصة', 'قصص', 'قصصي', 'قصصية', 'قصاص',
      'رواية', 'رواية', 'روايات', 'روائي', 'روائية',
      'مسرحية', 'مسرحية', 'مسرحيات', 'مسرحي',
      'فيلم', 'فيلم', 'أفلام', 'سينما', 'سينمائي',
      'لغة', 'لغة', 'لغات', 'لغوي', 'لغوية', 'لسان',
      'كلمة', 'كلمة', 'كلمات', 'كلِم', 'كلام',
      'جملة', 'جملة', 'جمل', 'جميل',
      'حرف', 'حرف', 'حروف', 'حرفي', 'حرفية',
      'معنى', 'معنى', 'معان', 'معانٍ', 'معنوي', 'معنوية',
      'مصطلح', 'مصطلح', 'مصطلحات', 'اصطلاح', 'اصطلاحات',
      'ترجمة', 'ترجمة', 'ترجمات', 'مترجم', 'مترجمة',
      'كتابة', 'كتابة', 'كتابات', 'كتابي', 'كتابية',
      'قراءة', 'قراءة', 'قراءات', 'قارئ', 'قرائي',
      'طباعة', 'طباعة', 'مطبوعات', 'مطبوعة', 'مطبعة',
      'نشر', 'نشر', 'منشورات', 'منشور', 'ناشر',
      'مخطوطة', 'مخطوطة', 'مخطوطات', 'مخطوط',
      'ورقة', 'ورقة', 'أوراق', 'ورقي', 'ورقية',
      'صفحة', 'صفحة', 'صفحات', 'صفحي',
      'فصل', 'فصل', 'فصول', 'فصلي', 'فصلية',
      'باب', 'باب', 'أبواب', 'بابي', 'بابك',
      'جزء', 'جزء', 'أجزاء', 'جزئي', 'جزئية',
      'رقم', 'رقم', 'أرقام', 'رقمي', 'رقمية',
      'عدد', 'عدد', 'أعداد', 'عددي', 'عددية',
      'تاريخ', 'تاريخ', 'تواريخ', 'تاريخي', 'تاريخية',
      'حضارة', 'حضارة', 'حضارات', 'حضاري', 'حضارية',
      'مستقبل', 'مستقبل', 'مستقبلي', 'مستقبلية',
      'حاضر', 'حاضر', 'حاضرة', 'حضور',
      'ماضي', 'ماضي', 'ماضية', 'ماضون',
      'تطور', 'تطور', 'تطورات', 'تطوري', 'تطورية',
      'تقدم', 'تقدم', 'متقدم', 'متقدمة',
      'تخلف', 'تخلف', 'متخلف', 'متخلفة',
      'نجاح', 'نجاح', 'نجاحات', 'ناجح', 'ناجحة',
      'فشل', 'فشل', 'فاشل', 'فاشلة', 'فشل',
      'حياة', 'حياة', 'حياتي', 'حياتك', 'حياته', 'حيوي',
      'موت', 'موت', 'ميت', 'أموات', 'ممات', 'موت',
      'روح', 'روح', 'أرواح', 'روحي', 'روحية',
      'جسد', 'جسد', 'أجساد', 'جسدي', 'جسدية',
      'عقل', 'عقل', 'عقول', 'عقلي', 'عقلية', 'عاقل',
      'قلب', 'قلب', 'قلوب', 'قلبي', 'قلبك', 'قلبه',
      'نفس', 'نفس', 'أنفس', 'نفسي', 'نفسية', 'نفساني',
      'دماغ', 'دماغ', 'أدمغة', 'دماغي', 'دماغية',
      'صحة', 'صحة', 'صحي', 'صحية', 'صحي',
      'مرض', 'مرض', 'أمراض', 'مريض', 'مرضى',
      'دواء', 'دواء', 'أدوية', 'دواء', 'دواء',
      'علاج', 'علاج', 'علاجات', 'معالجة', 'معالج',
      'مريض', 'مريض', 'مرضى', 'مريضة', 'مريضات',
      'طبيب', 'طبيب', 'أطباء', 'طبيبة',
      'ممرض', 'ممرض', 'ممرضة', 'ممرضون',
      'مستوصف', 'مستوصف', 'مستوصفات',
      'فيتامين', 'فيتامينات', 'بروتين', 'كربوهيدرات', 'دهون',
      'أكسجين', 'هيدروجين', 'نيتروجين', 'كربون',
      'طاقة', 'طاقة', 'طاقات', 'طاقوي', 'طاقوية',
      'قوة', 'قوة', 'قوى', 'قوي', 'تقوية',
      'حركة', 'حركة', 'حركات', 'حركي', 'حركية',
      'سكون', 'سكون', 'ساكن', 'ساكنة',
      'سرعة', 'سرعة', 'سرعات', 'سريع', 'سرعة',
      'اتجاه', 'اتجاه', 'اتجاهات', 'اتجاهي',
      'ارتفاع', 'ارتفاع', 'ارتفاعات', 'مرتفع',
      'انخفاض', 'انخفاض', 'منخفض', 'منخفضة',
      'زيادة', 'زيادة', 'زيادات', 'مزيد', 'متزايد',
      'نقص', 'نقص', 'ناقص', 'نقصان', 'تناقص',
      'بداية', 'بداية', 'بدايات', 'بدئي', 'مبدأ',
      'نهاية', 'نهاية', 'نهايات', 'نهائي', 'نهاية',
      'أساس', 'أساس', 'أسس', 'أساسي', 'أساسية', 'تأسيس',
      'فرع', 'فرع', 'فروع', 'فرعي', 'فرعية',
      'نوع', 'نوع', 'أنواع', 'نوعي', 'نوعية',
      'جنس', 'جنس', 'أجناس', 'جنسي', 'جنسية',
      'لون', 'لون', 'ألوان', 'لوني', 'لونية',
      'شكل', 'شكل', 'أشكال', 'شكلي', 'شكلية', 'تشكيل',
      'حجم', 'حجم', 'أحجام', 'حجمي', 'حجمية',
      'وزن', 'وزن', 'أوزان', 'وزني', 'وزنية',
      'طول', 'طول', 'أطوال', 'طولي', 'طولية',
      'عرض', 'عرض', 'أعراض', 'عريض', 'عرضي',
      'عمق', 'عمق', 'أعماق', 'عميق', 'عميقة',
      'ارتفاع', 'ارتفاع', 'مرتفعات', 'مرتفع',
      'مساحة', 'مساحة', 'مساحات', 'مساحي',
      'مسافة', 'مسافة', 'مسافات', 'متباعد',
      'درجة', 'درجة', 'درجات', 'تدريجي', 'تدريجية',
      'مستوى', 'مستوى', 'مستويات', 'مستو',
      'خط', 'خط', 'خطوط', 'خطي', 'خطية',
      'دائرة', 'دائرة', 'دوائر', 'دائري', 'دائرية',
      'مربع', 'مربع', 'مربعات', 'تربيع',
      'مثلث', 'مثلث', 'مثلثات', 'مثلثي', 'ثلاثي',
      'زاوية', 'زاوية', 'زوايا', 'زاوي', 'زاوي',
    ];
    _dictionary.addAll(words);
  }

  void _initializeArabicRules() {
    _hamzaReplacements['ا'] = 'أإآء';
    _hamzaReplacements['أ'] = 'اإآء';
    _hamzaReplacements['إ'] = 'اأآء';
    _hamzaReplacements['آ'] = 'اأإء';
    _hamzaReplacements['ؤ'] = 'ء';
    _hamzaReplacements['ئ'] = 'ء';
    _hamzaReplacements['ء'] = 'أإآؤئ';

    _taaMarboutaReplacements['ة'] = 'ه';
    _taaMarboutaReplacements['ه'] = 'ة';

    _alifMaqsuraReplacements['ى'] = 'ي';
    _alifMaqsuraReplacements['ي'] = 'ى';
  }

  void _initializeCommonMisspellings() {
    _commonMisspellings['هذا'] = 'هذا';
    _commonMisspellings['هذه'] = 'هذه';
    _commonMisspellings['اللذي'] = 'الذي';
    _commonMisspellings['اللتي'] = 'التي';
    _commonMisspellings['لذيذ'] = 'لذيذ';
    _commonMisspellings['لذيد'] = 'لذيذ';
    _commonMisspellings['ذالك'] = 'ذلك';
    _commonMisspellings['هاذا'] = 'هذا';
    _commonMisspellings['هاذه'] = 'هذه';
    _commonMisspellings['عندما'] = 'عندما';
    _commonMisspellings['لأن'] = 'لأن';
    _commonMisspellings['لان'] = 'لأن';
    _commonMisspellings['لأ'] = 'لا';
    _commonMisspellings['لآ'] = 'لا';
    _commonMisspellings['مليون'] = 'مليون';
    _commonMisspellings['ملون'] = 'مليون';
    _commonMisspellings['اخر'] = 'آخر';
    _commonMisspellings['اول'] = 'أول';
    _commonMisspellings['اخذ'] = 'أخذ';
    _commonMisspellings['اكل'] = 'أكل';
    _commonMisspellings['امر'] = 'أمر';
    _commonMisspellings['ادن'] = 'أذن';
    _commonMisspellings['ان'] = 'أن';
    _commonMisspellings['ان'] = 'إن';
    _commonMisspellings['سؤال'] = 'سؤال';
    _commonMisspellings['مسئول'] = 'مسؤول';
    _commonMisspellings['مسالة'] = 'مسألة';
    _commonMisspellings['ميناء'] = 'ميناء';
    _commonMisspellings['قرءان'] = 'قرآن';
    _commonMisspellings['قرأن'] = 'قرآن';
    _commonMisspellings['القرءان'] = 'القرآن';
    _commonMisspellings['القرأن'] = 'القرآن';
    _commonMisspellings['شاء'] = 'شاء';
    _commonMisspellings['شي'] = 'شيء';
    _commonMisspellings['شيئ'] = 'شيء';
    _commonMisspellings['شئ'] = 'شيء';
    _commonMisspellings['بطئ'] = 'بطيء';
    _commonMisspellings['بطيئ'] = 'بطيء';
    _commonMisspellings['جزيء'] = 'جزء';
    _commonMisspellings['جزء'] = 'جزء';
    _commonMisspellings['دفئ'] = 'دفيء';
    _commonMisspellings['دفا'] = 'دفء';
    _commonMisspellings['الساء'] = 'السماء';
    _commonMisspellings['السماء'] = 'السماء';
    _commonMisspellings['بناء'] = 'بناء';
    _commonMisspellings['بنا'] = 'بناء';
    _commonMisspellings['إنشاء'] = 'إنشاء';
    _commonMisspellings['انشا'] = 'إنشاء';
    _commonMisspellings['انشاء'] = 'إنشاء';
    _commonMisspellings['إستاذ'] = 'أستاذ';
    _commonMisspellings['استاذ'] = 'أستاذ';
    _commonMisspellings['إستاد'] = 'أستاذ';
    _commonMisspellings['مؤمن'] = 'مؤمن';
    _commonMisspellings['مومن'] = 'مؤمن';
    _commonMisspellings['مؤتمر'] = 'مؤتمر';
    _commonMisspellings['مؤتمر'] = 'مؤتمر';
    _commonMisspellings['يئس'] = 'يئس';
    _commonMisspellings['يأس'] = 'يأس';
    _commonMisspellings['راي'] = 'رأي';
    _commonMisspellings['رئي'] = 'رأي';
    _commonMisspellings['مبدا'] = 'مبدأ';
    _commonMisspellings['مبدء'] = 'مبدأ';
    _commonMisspellings['بدأ'] = 'بدأ';
    _commonMisspellings['بدا'] = 'بدأ';
    _commonMisspellings['قراة'] = 'قراءة';
    _commonMisspellings['قراءه'] = 'قراءة';
    _commonMisspellings['كتابة'] = 'كتابة';
    _commonMisspellings['كتابه'] = 'كتابة';
    _commonMisspellings['مدرسة'] = 'مدرسة';
    _commonMisspellings['مدرسه'] = 'مدرسة';
    _commonMisspellings['جامعة'] = 'جامعة';
    _commonMisspellings['جامعه'] = 'جامعة';
    _commonMisspellings['مديرة'] = 'مديرة';
    _commonMisspellings['مديره'] = 'مديرة';
    _commonMisspellings['طالبة'] = 'طالبة';
    _commonMisspellings['طالبه'] = 'طالبة';
    _commonMisspellings['معلمة'] = 'معلمة';
    _commonMisspellings['معلمه'] = 'معلمة';
    _commonMisspellings['مكافأة'] = 'مكافأة';
    _commonMisspellings['مكافاة'] = 'مكافأة';
    _commonMisspellings['هداة'] = 'هداية';
    _commonMisspellings['هداية'] = 'هداية';
    _commonMisspellings['هدايه'] = 'هداية';
    _commonMisspellings['فتاة'] = 'فتاة';
    _commonMisspellings['فتاه'] = 'فتاة';
    _commonMisspellings['عصا'] = 'عصا';
    _commonMisspellings['عصى'] = 'عصا';
    _commonMisspellings['الضحى'] = 'الضحى';
    _commonMisspellings['الضحا'] = 'الضحى';
    _commonMisspellings['مستشفى'] = 'مستشفى';
    _commonMisspellings['مستشفي'] = 'مستشفى';
    _commonMisspellings['مصطفى'] = 'مصطفى';
    _commonMisspellings['مصطفي'] = 'مصطفى';
    _commonMisspellings['مجرى'] = 'مجرى';
    _commonMisspellings['مجري'] = 'مجرى';
    _commonMisspellings['ذكرى'] = 'ذكرى';
    _commonMisspellings['ذكري'] = 'ذكرى';
    _commonMisspellings['حبلى'] = 'حبلى';
    _commonMisspellings['حبلي'] = 'حبلى';
  }

  SpellResult checkWord(String word) {
    if (word.isEmpty) {
      return SpellResult(original: word, isCorrect: true);
    }

    final cleaned = word.trim();
    if (cleaned.isEmpty) return SpellResult(original: word, isCorrect: true);

    if (_dictionary.contains(cleaned) ||
        _userDictionary.contains(cleaned) ||
        _ignoredWords.contains(cleaned)) {
      return SpellResult(original: cleaned, isCorrect: true);
    }

    final withTashkeel = _removeTashkeel(cleaned);
    if (withTashkeel != cleaned && _dictionary.contains(withTashkeel)) {
      return SpellResult(original: cleaned, isCorrect: true);
    }

    if (_checkHamzaSpelling(cleaned)) {
      return SpellResult(original: cleaned, isCorrect: true);
    }
    if (_checkTaaMarbouta(cleaned)) {
      return SpellResult(original: cleaned, isCorrect: true);
    }
    if (_checkAlifMaqsura(cleaned)) {
      return SpellResult(original: cleaned, isCorrect: true);
    }

    final suggestions = _generateSuggestions(cleaned);
    return SpellResult(
      original: cleaned,
      isCorrect: false,
      suggestions: suggestions.take(_maxSuggestions).toList(),
    );
  }

  List<SpellError> checkText(String text) {
    final errors = <SpellError>[];
    final words = _tokenize(text);

    for (final wordInfo in words) {
      final word = wordInfo['word'] as String;
      final start = wordInfo['start'] as int;

      if (word.isEmpty) continue;

      final result = checkWord(word);
      if (!result.isCorrect) {
        String? rule;
        if (_hasHamzaIssue(word)) rule = 'hamza';
        if (_hasTaaMarboutaIssue(word)) rule = 'taaMarbouta';
        if (_hasAlifMaqsuraIssue(word)) rule = 'alifMaqsura';

        errors.add(SpellError(
          word: word,
          startOffset: start,
          endOffset: start + word.length,
          suggestions: result.suggestions,
          ruleViolated: rule,
        ));
      }
    }

    return errors;
  }

  List<Map<String, dynamic>> _tokenize(String text) {
    final tokens = <Map<String, dynamic>>[];
    final buffer = StringBuffer();
    int start = -1;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      if (RegExp(r'[\w\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]').hasMatch(char)) {
        if (buffer.isEmpty) start = i;
        buffer.write(char);
      } else {
        if (buffer.isNotEmpty) {
          tokens.add({'word': buffer.toString(), 'start': start});
          buffer.clear();
        }
      }
    }
    if (buffer.isNotEmpty) {
      tokens.add({'word': buffer.toString(), 'start': start});
    }
    return tokens;
  }

  String _removeTashkeel(String text) {
    return text.replaceAll(RegExp(
        r'[\u064B-\u065F\u0670\u0610-\u061A\u06D6-\u06ED]'), '');
  }

  bool _checkHamzaSpelling(String word) {
    if (!word.contains(RegExp(r'[أإآؤئء]'))) return true;

    final wordsWithHamza = _dictionary.where((w) {
      final baseW = _normalizeHamza(w);
      final baseWord = _normalizeHamza(word);
      return baseW == baseWord && w != word;
    }).toList();

    return wordsWithHamza.isEmpty;
  }

  bool _checkTaaMarbouta(String word) {
    if (!word.endsWith('ة') && !word.endsWith('ه')) return true;

    final normalized = word.endsWith('ة')
        ? '${word.substring(0, word.length - 1)}ه'
        : '${word.substring(0, word.length - 1)}ة';

    return !_dictionary.contains(normalized);
  }

  bool _checkAlifMaqsura(String word) {
    if (!word.endsWith('ى') && !word.endsWith('ي')) return true;

    final normalized = word.endsWith('ى')
        ? '${word.substring(0, word.length - 1)}ي'
        : '${word.substring(0, word.length - 1)}ى';

    return !_dictionary.contains(normalized);
  }

  bool _hasHamzaIssue(String word) {
    if (!word.contains(RegExp(r'[أإآؤئء]'))) return false;
    final wordsWithHamza =
        _dictionary.where((w) => _normalizeHamza(w) == _normalizeHamza(word)).toList();
    return wordsWithHamza.isNotEmpty && !wordsWithHamza.contains(word);
  }

  bool _hasTaaMarboutaIssue(String word) {
    if (!word.endsWith('ة') && !word.endsWith('ه')) return false;
    return _checkTaaMarbouta(word);
  }

  bool _hasAlifMaqsuraIssue(String word) {
    if (!word.endsWith('ى') && !word.endsWith('ي')) return false;
    return _checkAlifMaqsura(word);
  }

  String _normalizeHamza(String word) {
    return word
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ؤ', 'ء')
        .replaceAll('ئ', 'ء');
  }

  List<String> _generateSuggestions(String word) {
    final suggestions = <String>{};

    if (_commonMisspellings.containsKey(word)) {
      suggestions.add(_commonMisspellings[word]!);
    }

    for (final entry in _commonMisspellings.entries) {
      if (entry.value == word && entry.key != word) {
        suggestions.add(entry.key);
      }
    }

    suggestions.addAll(_levenshteinSuggestions(word));

    suggestions.addAll(_hamzaSuggestions(word));
    suggestions.addAll(_taaMarboutaSuggestions(word));
    suggestions.addAll(_alifMaqsuraSuggestions(word));

    suggestions.remove(word);

    return suggestions.where((s) {
      return _dictionary.contains(s) || _userDictionary.contains(s);
    }).toList();
  }

  List<String> _levenshteinSuggestions(String word) {
    final threshold = (word.length / 3).ceil().clamp(1, 4);
    final candidates = <_Candidate>[];

    const prefixes = ['ا', 'أ', 'إ', 'ب', 'ت', 'ن', 'ي', 'س', 'ف', 'ل', 'و', 'م'];
    const suffixes = [
      'ة', 'ه', 'ات', 'ون', 'ين', 'ان', 'ون', 'نا', 'كم', 'هم',
      'ي', 'ك', 'ه', 'نا', 'كم', 'هم', 'كن', 'ها',
    ];

    for (final word2 in _dictionary) {
      if ((word2.length - word.length).abs() > threshold + 2) continue;

      if (word2.startsWith(word) || word.startsWith(word2)) {
        final distance = _levenshteinDistance(word, word2);
        if (distance <= threshold) {
          candidates.add(_Candidate(word2, distance));
        }
        continue;
      }

      for (final prefix in prefixes) {
        if ('$prefix$word' == word2 || word == '$prefix$word2') {
          candidates.add(_Candidate(word2, 1));
          break;
        }
      }

      for (final suffix in suffixes) {
        if ('$word$suffix' == word2 || word == '$word2$suffix') {
          candidates.add(_Candidate(word2, 1));
          break;
        }
      }

      if (candidates.isEmpty || candidates.last.word != word2) {
        final distance = _levenshteinDistance(word, word2);
        if (distance <= threshold) {
          candidates.add(_Candidate(word2, distance));
        }
      }
    }

    candidates.sort((a, b) => a.distance.compareTo(b.distance));

    return candidates.map((c) => c.word).toList();
  }

  List<String> _hamzaSuggestions(String word) {
    final suggestions = <String>[];
    final hamzaPattern = RegExp(r'[أإآؤئء]');

    if (!word.contains(hamzaPattern)) return suggestions;

    for (final entry in _hamzaReplacements.entries) {
      for (final replacement in entry.value.split('')) {
        final variant = word.replaceAll(entry.key, replacement);
        if (_dictionary.contains(variant) || _userDictionary.contains(variant)) {
          suggestions.add(variant);
        }
      }
    }

    final normalized = _normalizeHamza(word);
    final matches = _dictionary.where((w) => _normalizeHamza(w) == normalized);
    suggestions.addAll(matches);

    return suggestions;
  }

  List<String> _taaMarboutaSuggestions(String word) {
    final suggestions = <String>[];
    if (word.endsWith('ة')) {
      final variant = '${word.substring(0, word.length - 1)}ه';
      if (_dictionary.contains(variant)) suggestions.add(variant);
    } else if (word.endsWith('ه')) {
      final variant = '${word.substring(0, word.length - 1)}ة';
      if (_dictionary.contains(variant)) suggestions.add(variant);
    }
    return suggestions;
  }

  List<String> _alifMaqsuraSuggestions(String word) {
    final suggestions = <String>[];
    if (word.endsWith('ى')) {
      final variant = '${word.substring(0, word.length - 1)}ي';
      if (_dictionary.contains(variant)) suggestions.add(variant);
    } else if (word.endsWith('ي')) {
      final variant = '${word.substring(0, word.length - 1)}ى';
      if (_dictionary.contains(variant)) suggestions.add(variant);
    }
    return suggestions;
  }

  int _levenshteinDistance(String s1, String s2) {
    final m = s1.length;
    final n = s2.length;

    if (m == 0) return n;
    if (n == 0) return m;

    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (int i = 0; i <= m; i++) dp[i][0] = i;
    for (int j = 0; j <= n; j++) dp[0][j] = j;

    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (s1[i - 1] == s2[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = 1 + [
                dp[i - 1][j],
                dp[i][j - 1],
                dp[i - 1][j - 1],
              ].reduce(min);
        }
      }
    }

    return dp[m][n];
  }

  void addToUserDictionary(String word) {
    _userDictionary.add(word.trim());
  }

  void removeFromUserDictionary(String word) {
    _userDictionary.remove(word.trim());
  }

  bool isInUserDictionary(String word) {
    return _userDictionary.contains(word.trim());
  }

  Set<String> getUserDictionary() => Set.unmodifiable(_userDictionary);

  void clearUserDictionary() {
    _userDictionary.clear();
  }

  void ignoreWord(String word) {
    _ignoredWords.add(word.trim());
  }

  void clearIgnoredWords() {
    _ignoredWords.clear();
  }

  void addCustomWord(String word) {
    _dictionary.add(word.trim());
  }

  void removeCustomWord(String word) {
    _dictionary.remove(word.trim());
  }

  bool hasDictionaryWord(String word) {
    return _dictionary.contains(word.trim());
  }

  int get dictionarySize => _dictionary.length;
  int get userDictionarySize => _userDictionary.length;
}

class _Candidate {
  final String word;
  final int distance;

  const _Candidate(this.word, this.distance);
}
