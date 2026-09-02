import type { Language } from '@tailor-catalog/shared';

export interface LanguageOption {
  code: Language;
  label: string;
  nativeLabel: string;
  region: string;
}

export const SUPPORTED_LANGUAGES: LanguageOption[] = [
  { code: 'en', label: 'English', nativeLabel: 'English', region: 'Default' },
  { code: 'am', label: 'Amharic', nativeLabel: 'አማርኛ', region: 'ኢትዮጵያ' },
  { code: 'om', label: 'Oromifa', nativeLabel: 'Afaan Oromoo', region: 'Oromiyaa' },
  { code: 'so', label: 'Somali', nativeLabel: 'Af Soomaali', region: 'Soomaali' },
];

export const translations = {
  en: {
    // Language Selection Modal
    'language.picker.title': 'Choose Your Language',
    'language.picker.subtitle': 'Select your preferred language to browse the tailor catalog',
    'language.picker.continue': 'Continue',
    'language.picker.change_anytime': 'You can change the language anytime from the menu',

    // Header & Navigation
    'header.verified_tailor': 'Verified Tailor',
    'header.contact_tailor': 'Contact Tailor',
    'header.call_phone': 'Call Shop',
    'header.share_catalog': 'Share Catalog',
    'header.link_copied': 'Link copied to clipboard!',
    'header.qr_code': 'Shop QR Code',
    'header.change_language': 'Change Language',

    // Catalog & Filters
    'catalog.title': 'Designs Catalog',
    'catalog.subtitle': 'Explore custom handcrafted designs and traditional fashion',
    'catalog.all_categories': 'All Categories',
    'catalog.search_placeholder': 'Search by style, tag or price...',
    'catalog.sort.newest': 'Newest First',
    'catalog.sort.price_low': 'Price: Low to High',
    'catalog.sort.price_high': 'Price: High to Low',
    'catalog.showing_count': 'Showing {count} of {total} designs',
    'catalog.reset_filters': 'Reset Filters',
    'catalog.no_designs': 'No designs found',
    'catalog.no_designs_desc': 'There are no designs matching your selected filters.',
    'catalog.photos_count': '{count} Photos',
    'catalog.currency': 'ETB {price}',

    // Design Card & Detail
    'design.view_details': 'View Details',
    'design.try_on': 'Virtual Try-On',
    'design.price': 'Price',
    'design.category': 'Category',
    'design.tag': 'Style Tag',
    'design.format': 'Format',
    'design.format_single': 'Single Photo',
    'design.format_grouped': 'Multi-Photo Collection',
    'design.close': 'Close',

    // Virtual Try-On
    'tryon.title': 'Virtual Try-On',
    'tryon.subtitle': 'Overlay this outfit onto your camera to preview how it looks',
    'tryon.hint': 'Drag to position • Pinch or slide to resize',
    'tryon.opacity': 'Opacity',
    'tryon.size': 'Size',
    'tryon.flip_camera': 'Flip Camera',
    'tryon.take_snapshot': 'Take Photo',
    'tryon.reset_overlay': 'Reset Position',
    'tryon.camera_error': 'Unable to access camera. Please allow camera permissions.',
    'tryon.camera_permission': 'Camera Access Required',
    'tryon.camera_permission_desc': 'Please allow camera access in your browser settings to use the live try-on feature.',
    'tryon.close': 'Exit Try-On',

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
    'language.picker.subtitle': 'የልብስ ዲዛይኖችን ለመመልከት የሚመርጡትን ቋንቋ ይምረጡ',
    'language.picker.continue': 'ቀጥል',
    'language.picker.change_anytime': 'ቋንቋውን በማንኛውም ጊዜ መቀየር ይችላሉ',

    // Header & Navigation
    'header.verified_tailor': 'የተረጋገጠ ሰፊ',
    'header.contact_tailor': 'ሰፊውን ያግኙ',
    'header.call_phone': 'ደውል',
    'header.share_catalog': 'ካታሎግ አጋራ',
    'header.link_copied': 'ሊንኩ ተገልብጧል!',
    'header.qr_code': 'የሱቅ QR ኮድ',
    'header.change_language': 'ቋንቋ ቀይር',

    // Catalog & Filters
    'catalog.title': 'የዲዛይን ካታሎግ',
    'catalog.subtitle': 'የተመረጡ የፋሽን እና የባህል ልብስ ዲዛይኖችን ይመልከቱ',
    'catalog.all_categories': 'ሁሉም ምድቦች',
    'catalog.search_placeholder': 'በስም ፣ መለያ ወይም ዋጋ ይፈልጉ...',
    'catalog.sort.newest': 'አዳዲስ መጀመሪያ',
    'catalog.sort.price_low': 'ዋጋ፡ ከዝቅተኛ ወደ ከፍተኛ',
    'catalog.sort.price_high': 'ዋጋ፡ ከከፍተኛ ወደ ዝቅተኛ',
    'catalog.showing_count': 'ከ {total} ውስጥ {count} ዲዛይኖች ታይተዋል',
    'catalog.reset_filters': 'ማጣሪያዎችን አጽዳ',
    'catalog.no_designs': 'ምንም ዲዛይን አልተገኘም',
    'catalog.no_designs_desc': 'ከተመረጠው ማጣሪያ ጋር የሚስማማ ዲዛይን የለም።',
    'catalog.photos_count': '{count} ፎቶዎች',
    'catalog.currency': '{price} ብር',

    // Design Card & Detail
    'design.view_details': 'ዝርዝሩን ይመልከቱ',
    'design.try_on': 'በካሜራ ይሞክሩ',
    'design.price': 'ዋጋ',
    'design.category': 'ምድብ',
    'design.tag': 'መለያ',
    'design.format': 'ቅርጸት',
    'design.format_single': 'ነጠላ ፎቶ',
    'design.format_grouped': 'ባለብዙ ፎቶ ስብስብ',
    'design.close': 'ዝጋ',

    // Virtual Try-On
    'tryon.title': 'በካሜራ ልብሱን ይሞክሩ',
    'tryon.subtitle': 'ልብሱ በእርስዎ ላይ እንዴት እንደሚታይ በካሜራው ላይ አስተካክለው ይመልከቱ',
    'tryon.hint': 'ለማንቀሳቀስ ይጎትቱ • በመቆንጠጥ መጠኑን ያስተካክሉ',
    'tryon.opacity': 'የቀለም ጥራት',
    'tryon.size': 'መጠን',
    'tryon.flip_camera': 'ካሜራ ቀይር',
    'tryon.take_snapshot': 'ፎቶ አንሳ',
    'tryon.reset_overlay': 'መጀመሪያ ቦታ መልስ',
    'tryon.camera_error': 'ካሜራውን መክፈት አልተቻለም። እባክዎ ፍቃድ ይስጡ።',
    'tryon.camera_permission': 'የካሜራ ፍቃድ ያስፈልጋል',
    'tryon.camera_permission_desc': 'የቀጥታ ሙከራውን ለመጠቀም እባክዎ በስልክዎ ላይ የካሜራ ፍቃድ ይፍቀዱ።',
    'tryon.close': 'ውጣ',

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
    'design.try_on': 'Kaameraan Yaali',
    'design.price': 'Gatii',
    'design.category': 'Garee',
    'design.tag': 'Mallattoo',
    'design.format': 'Bifa',
    'design.format_single': 'Suuraa Qeenxee',
    'design.format_grouped': 'Kuusaa Suuraa Hedduu',
    'design.close': 'Cufi',

    // Virtual Try-On
    'tryon.title': 'Uffata Kaameraan Yaali',
    'tryon.subtitle': 'Uffanni kun akkamitti akka sitti tolu kaameraa irratti ilaali',
    'tryon.hint': 'Sossoosuuf harkisaa • Bal\'isuuf xuqaa',
    'tryon.opacity': 'Ifa Suuraa',
    'tryon.size': 'Hammamtaa',
    'tryon.flip_camera': 'Kaameraa Jijjiiri',
    'tryon.take_snapshot': 'Suuraa Kaasi',
    'tryon.reset_overlay': 'Iddoo Duriitti Deebisi',
    'tryon.camera_error': 'Kaameraa banuu hin dandeenye. Hayyama kennaa.',
    'tryon.camera_permission': 'Hayyama Kaameraa Barbaachisa',
    'tryon.camera_permission_desc': 'Yaalii kaameraa fayyadamuuf saayitiif hayyama kennaa.',
    'tryon.close': 'Bahi',

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
    'design.try_on': 'Kamarad Ku Tijaabi',
    'design.price': 'Qiimaha',
    'design.category': 'Qaybta',
    'design.tag': 'Calaamadda',
    'design.format': 'Qaabka',
    'design.format_single': 'Hal Sawir',
    'design.format_grouped': 'Sawirro Badan',
    'design.close': 'Xir',

    // Virtual Try-On
    'tryon.title': 'Kamarad Ku Tijaabi Dharka',
    'tryon.subtitle': 'Dharka dusha saar kamaradaada si aad u aragto sida uu kuugu ekaanayo',
    'tryon.hint': 'Jiid si aad u dhaqaajiso • Fara-fuji si aad u weyneeyso',
    'tryon.opacity': 'Cadadka Muuqaalka',
    'tryon.size': 'Cabbirka',
    'tryon.flip_camera': 'Beddel Kamarada',
    'tryon.take_snapshot': 'Sawir Qaad',
    'tryon.reset_overlay': 'Dib u Deji',
    'tryon.camera_error': 'Kamarada lama furi karo. Fadlan fasax bixi.',
    'tryon.camera_permission': 'Fasaxa Kamarada ayaa Loo Baahan Yahay',
    'tryon.camera_permission_desc': 'Fadlan fasax u sii kamarada biraawsarkaaga si aad u isticmaasho tijaabada tooska ah.',
    'tryon.close': 'Ka Bax',

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
