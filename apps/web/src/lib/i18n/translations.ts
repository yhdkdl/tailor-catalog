export type Language = 'en' | 'am' | 'om' | 'so';

export interface LanguageOption {
  code: Language;
  label: string;
  nativeLabel: string;
  flag: string;
}

export const SUPPORTED_LANGUAGES: LanguageOption[] = [
  {
    code: 'en',
    label: 'English',
    nativeLabel: 'English',
    flag: '🇬🇧',
  },
  {
    code: 'am',
    label: 'Amharic',
    nativeLabel: 'አማርኛ',
    flag: '🇪🇹',
  },
  {
    code: 'om',
    label: 'Oromifa',
    nativeLabel: 'Afaan Oromoo',
    flag: '🇪🇹',
  },
  {
    code: 'so',
    label: 'Somali',
    nativeLabel: 'Af Soomaali',
    flag: '🇸🇴',
  },
];

export const translations = {
  en: {
    // Language Selection Modal
    'language.picker.title': 'Choose Your Language',
    'language.picker.subtitle': 'Select your preferred language to browse handcrafted designs',
    'language.picker.continue': 'Continue',
    'language.picker.change_anytime': 'You can change language anytime from the header',

    // Header & Navigation
    'header.verified_tailor': 'Verified Tailor',
    'header.contact_tailor': 'Contact Tailor',
    'header.call_phone': 'Call Shop',
    'header.share_catalog': 'Share Catalog',
    'header.link_copied': 'Link copied to clipboard!',
    'header.qr_code': 'Shop QR Code',
    'header.change_language': 'Change Language',

    // Catalog & Filters
    'catalog.title': 'Custom Catalog',
    'catalog.subtitle': 'Browse authentic handcrafted designs and bespoke fashion',
    'catalog.all_categories': 'All Categories',
    'catalog.search_placeholder': 'Search by style, tag, or price...',
    'catalog.sort.newest': 'Newest First',
    'catalog.sort.price_low': 'Price: Low to High',
    'catalog.sort.price_high': 'Price: High to Low',
    'catalog.showing_count': 'Showing {count} of {total} designs',
    'catalog.reset_filters': 'Reset Filters',
    'catalog.no_designs': 'No designs found',
    'catalog.no_designs_desc': 'Try selecting a different category or clearing your search filters.',
    'catalog.photos_count': '{count} Photos',
    'catalog.currency': 'ETB {price}',

    // Design Card & Detail
    'design.view_details': 'View Details',
    'design.view_360': 'View 360°',
    'design.price': 'Price',
    'design.category': 'Category',
    'design.tag': 'Style Tag',
    'design.format': 'Format',
    'design.format_single': 'Single Photo',
    'design.format_grouped': 'Multi-Photo Collection',
    'design.close': 'Close',

    // 360 Photo Viewer
    'viewer360.title': '360° Photo Viewer',
    'viewer360.counter': '{current} of {total}',
    'viewer360.zoom_hint': 'Pinch or double-tap to zoom',
    'viewer360.close': 'Close',
    'viewer360.prev': 'Previous photo',
    'viewer360.next': 'Next photo',

    // 404 & Error states
    'error.tailor_not_found': 'Tailor Shop Not Found',
    'error.tailor_not_found_desc': 'The tailor catalog you are looking for does not exist or has been relocated.',
    'error.tailor_pending': 'Shop Pending Verification',
    'error.tailor_pending_desc': 'This tailor shop is currently undergoing verification by our team.',
    'error.back_home': 'Go to Homepage',

    // Common
    'common.loading': 'Loading...',
    'common.error': 'Something went wrong',
    'common.retry': 'Try Again',
  },
  am: {
    // Language Selection Modal
    'language.picker.title': 'ቋንቋ ይምረጡ',
    'language.picker.subtitle': 'የተሰፉ ልብሶችን ለመመልከት የሚመርጡትን ቋንቋ ይምረጡ',
    'language.picker.continue': 'ቀጥል',
    'language.picker.change_anytime': 'በማንኛውም ጊዜ ከላይ ያለውን የቋንቋ ምልክት በመጫን መቀየር ይችላሉ',

    // Header & Navigation
    'header.verified_tailor': 'የተረጋገጠ ሰፊ',
    'header.contact_tailor': 'ሰፊውን ያግኙ',
    'header.call_phone': 'ይደውሉ',
    'header.share_catalog': 'ካታሎጉን አጋራ',
    'header.link_copied': 'ሊንኩ ተቀድቷል!',
    'header.qr_code': 'የሱቅ QR ኮድ',
    'header.change_language': 'ቋንቋ ቀይር',

    // Catalog & Filters
    'catalog.title': 'የልብስ ካታሎግ',
    'catalog.subtitle': 'በባህልና በዘመናዊ ጥበብ የተሰሩ ልዩ የልብስ ዲዛይኖችን ይመልከቱ',
    'catalog.all_categories': 'ሁሉም ምድቦች',
    'catalog.search_placeholder': 'በስም ፣ በመለያ ወይም በዋጋ ይፈልጉ...',
    'catalog.sort.newest': 'አዳዲስ',
    'catalog.sort.price_low': 'ዋጋ፡ ከዝቅተኛ ወደ ከፍተኛ',
    'catalog.sort.price_high': 'ዋጋ፡ ከከፍተኛ ወደ ዝቅተኛ',
    'catalog.showing_count': 'ከ{total} ውስጥ {count} ዲዛይኖች',
    'catalog.reset_filters': 'ሁሉንም አሳይ',
    'catalog.no_designs': 'ምንም ዲዛይን አልተገኘም',
    'catalog.no_designs_desc': 'የተመረጠው ምድብ ውስጥ ምንም ዲዛይን የለም። እባክዎ ሌላ ምድብ ይምረጡ።',
    'catalog.photos_count': '{count} ፎቶዎች',
    'catalog.currency': '{price} ብር',

    // Design Card & Detail
    'design.view_details': 'ዝርዝሩን ይመልከቱ',
    'design.view_360': '360° እይታ',
    'design.price': 'ዋጋ',
    'design.category': 'ምድብ',
    'design.tag': 'መለያ',
    'design.format': 'ቅርጸት',
    'design.format_single': 'ነጠላ ፎቶ',
    'design.format_grouped': 'ባለብዙ ፎቶ ስብስብ',
    'design.close': 'ዝጋ',

    // 360 Photo Viewer
    'viewer360.title': '360° የፎቶ እይታ',
    'viewer360.counter': '{current} ከ {total}',
    'viewer360.zoom_hint': 'ለማጉላት ሁለቴ ይንኩ ወይም ያሳድጉ',
    'viewer360.close': 'ዝጋ',
    'viewer360.prev': 'ቀዳሚ ፎቶ',
    'viewer360.next': 'ቀጣይ ፎቶ',

    // 404 & Error states
    'error.tailor_not_found': 'የሰፊ ሱቅ አልተገኘም',
    'error.tailor_not_found_desc': 'የፈለጉት የሰፊ ሱቅ አልተገኘም ወይም ተዘግቷል።',
    'error.tailor_pending': 'በማረጋገጥ ላይ ያለ ሱቅ',
    'error.tailor_pending_desc': 'ይህ የሰፊ ሱቅ በአስተዳዳሪው እየተረጋገጠ ነው።',
    'error.back_home': 'ወደ መነሻ ገጽ ተመለስ',

    // Common
    'common.loading': 'በመጫን ላይ...',
    'common.error': 'ስህተት ተፈጥሯል',
    'common.retry': 'እንደገና ሞክር',
  },
  om: {
    // Language Selection Modal
    'language.picker.title': 'Afaan Filadhaa',
    'language.picker.subtitle': 'Katalogii uffataa ilaaluuf afaan barbaaddan filadhaa',
    'language.picker.continue': 'Itti Fufi',
    'language.picker.change_anytime': 'Afaan yeroo kamiyyuu jijjiiruu dandeessu',

    // Header & Navigation
    'header.verified_tailor': 'Hodhaa Mirkanaa\'e',
    'header.contact_tailor': 'Hodhaa Quunnamaa',
    'header.call_phone': 'Bilbilaa',
    'header.share_catalog': 'Katalogii Qoodaa',
    'header.link_copied': 'Geessituun garagalfameera!',
    'header.qr_code': 'Koodii QR Suuqii',
    'header.change_language': 'Afaan Jijjiiri',

    // Catalog & Filters
    'catalog.title': 'Katalogii Dizaayinii',
    'catalog.subtitle': 'Dizaayinii aadaa fi ammayyaa harkaatiin hojjetaman daawwadhaa',
    'catalog.all_categories': 'Garee Hunda',
    'catalog.search_placeholder': 'Gosa, mallattoo yookiin gatiin barbaadi...',
    'catalog.sort.newest': 'Haaraa Dura',
    'catalog.sort.price_low': 'Gatii: Gadi aanaa gara Ol\'aanaatti',
    'catalog.sort.price_high': 'Gatii: Ol\'aanaa gara Gadi aanaatti',
    'catalog.showing_count': 'Dizaayinoota {total} keessaa {count} agarsiisaa jira',
    'catalog.reset_filters': 'Filtara Qulqulleessi',
    'catalog.no_designs': 'Dizaayiniin hin argamne',
    'catalog.no_designs_desc': 'Dizaayiniin filannoo keessan waliin walsimu hin jiru.',
    'catalog.photos_count': 'Suuraa {count}',
    'catalog.currency': 'ETB {price}',

    // Design Card & Detail
    'design.view_details': 'Bal\'ina Ilaali',
    'design.view_360': 'Ilaalcha 360°',
    'design.price': 'Gatii',
    'design.category': 'Garee',
    'design.tag': 'Mallattoo',
    'design.format': 'Bifa',
    'design.format_single': 'Suuraa Qeenxee',
    'design.format_grouped': 'Kuusaa Suuraa Hedduu',
    'design.close': 'Cufi',

    // 360 Photo Viewer
    'viewer360.title': 'Ilaalcha Suuraa 360°',
    'viewer360.counter': '{current} keessaa {total}',
    'viewer360.zoom_hint': 'Guddisuuf dachaa xuqaa',
    'viewer360.close': 'Cufi',
    'viewer360.prev': 'Suuraa duraa',
    'viewer360.next': 'Suuraa itti aanu',

    // 404 & Error states
    'error.tailor_not_found': 'Suuqiin Hodhaa Hin Argamne',
    'error.tailor_not_found_desc': 'Suuqiin hodhaa ati barbaadde hin jiru yookiin cufameera.',
    'error.tailor_pending': 'Suuqiin Mirkaneessaa Irra Jira',
    'error.tailor_pending_desc': 'Suuqiin kun yeroo ammaa qoratamaa jira.',
    'error.back_home': 'Gara Fuula Jalqabaatti Deebi\'i',

    // Common
    'common.loading': 'Fe\'amaa jira...',
    'common.error': 'Dogoggorri uumameera',
    'common.retry': 'Irra Deebi\'i Yaali',
  },
  so: {
    // Language Selection Modal
    'language.picker.title': 'Dooro Luqaddaada',
    'language.picker.subtitle': 'Dooro luqadda aad doorbideyso si aad u daawato buugga dharka',
    'language.picker.continue': 'Sii wad',
    'language.picker.change_anytime': 'Waad beddeli kartaa luqadda wakhti kasta',

    // Header & Navigation
    'header.verified_tailor': 'Talaami La Xaqiijiyay',
    'header.contact_tailor': 'La Xiriir Talaamiga',
    'header.call_phone': 'Wac Dukanka',
    'header.share_catalog': 'La Wadaag Buugga',
    'header.link_copied': 'Xiriirinta waa la koobiyeeyay!',
    'header.qr_code': 'Koodhka QR ee Dukanka',
    'header.change_language': 'Beddel Luqadda',

    // Catalog & Filters
    'catalog.title': 'Buugga Naqshadaha',
    'catalog.subtitle': 'Sahmi naqshadaha dharka dhaqanka iyo casriga ah',
    'catalog.all_categories': 'Dhammaan Qaybaha',
    'catalog.search_placeholder': 'Ku raadi qaabka, calaamadda ama qiimaha...',
    'catalog.sort.newest': 'Kuwa Cusub Marka Hore',
    'catalog.sort.price_low': 'Qiimaha: Hoose ilaa Sare',
    'catalog.sort.price_high': 'Qiimaha: Sare ilaa Hoose',
    'catalog.showing_count': 'Waxaa la muujinayaa {count} ka mid ah {total} naqshadood',
    'catalog.reset_filters': 'Dib u Deji Shaandhada',
    'catalog.no_designs': 'Lama helin naqshado',
    'catalog.no_designs_desc': 'Ma jiraan naqshado u dhigma shaandhada aad dooratay.',
    'catalog.photos_count': '{count} Sawirro',
    'catalog.currency': 'ETB {price}',

    // Design Card & Detail
    'design.view_details': 'Faahfaahinta Eeg',
    'design.view_360': 'Aragtida 360°',
    'design.price': 'Qiimaha',
    'design.category': 'Qaybta',
    'design.tag': 'Calaamadda',
    'design.format': 'Qaabka',
    'design.format_single': 'Hal Sawir',
    'design.format_grouped': 'Sawirro Badan',
    'design.close': 'Xir',

    // 360 Photo Viewer
    'viewer360.title': 'Aragtida Sawirka 360°',
    'viewer360.counter': '{current} ee {total}',
    'viewer360.zoom_hint': 'Taabo laba jeer si aad u weynayso',
    'viewer360.close': 'Xir',
    'viewer360.prev': 'Sawirkii hore',
    'viewer360.next': 'Sawirka xiga',

    // 404 & Error states
    'error.tailor_not_found': 'Dukaanka Talaamiga Lama Helin',
    'error.tailor_not_found_desc': 'Buugga aad raadineyso ma jiro ama waa la raray.',
    'error.tailor_pending': 'Dukaanka Waa La Xaqiijinayaa',
    'error.tailor_pending_desc': 'Dukaankan hadda waxaa ku socda hubin rasmi ah.',
    'error.back_home': 'Ku Noqo Bogga Hore',

    // Common
    'common.loading': 'Waa la soo gelinayaa...',
    'common.error': 'Khalad ayaa dhacay',
    'common.retry': 'Mar Kale Isku Day',
  },
} as const;

export type TranslationKey = keyof typeof translations.en;
