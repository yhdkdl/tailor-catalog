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
    'header.marketplace': 'Marketplace',
    'header.favourites': 'Saved ({count})',

    // Catalog & Filters
    'catalog.title': 'Custom Catalog',
    'catalog.subtitle': 'Browse authentic handcrafted designs and bespoke fashion',
    'catalog.all_categories': 'All Categories',
    'catalog.search_placeholder': 'Search by style or tag...',
    'catalog.sort.newest': 'Newest First',
    'catalog.showing_count': 'Showing {count} of {total} designs',
    'catalog.reset_filters': 'Reset Filters',
    'catalog.no_designs': 'No designs found',
    'catalog.no_designs_desc': 'Try selecting a different category or clearing your search filters.',
    'catalog.photos_count': '{count} Photos',
    'catalog.currency': '{price} ETB',

    // Design Card & Detail
    'design.view_details': 'View Details',
    'design.view_360': 'View 360°',
    'design.share': 'Share Design',
    'design.category': 'Category',
    'design.tag': 'Style Tag',
    'design.format': 'Format',
    'design.format_single': 'Single Photo',
    'design.format_grouped': 'Multi-Photo Collection',
    'design.close': 'Close',

    // Share Modal
    'share.title': 'Share this Design',
    'share.whatsapp': 'Share on WhatsApp',
    'share.telegram': 'Share on Telegram',
    'share.copy': 'Copy Direct Link',
    'share.copied': 'Link Copied!',

    // Trending Section
    'trending.title': 'Trending Now',
    'trending.badge': 'Trending',
    'trending.see_all': 'See All Trending',
    'trending.preview_title': 'Trending Designs',
    'trending.preview_link': 'See all trending',
    'error.browse_all': 'Browse All Designs',

    // Favourites Page
    'favourites.title': 'Saved Designs',
    'favourites.subtitle': 'Your saved favourite styles and designs',
    'favourites.empty': 'No saved designs yet',
    'favourites.empty_desc': 'Tap the heart on any design to save it to your favourites.',
    'favourites.remove': 'Remove',
    'favourites.browse': 'Browse Marketplace',

    // Marketplace Page
    'marketplace.title': 'Ethiopian Fashion Marketplace',
    'marketplace.subtitle': 'Discover authentic custom designs from verified master tailors across Ethiopia',
    'marketplace.all_tab': 'All Designs',
    'marketplace.trending_tab': 'Trending 🔥',
    'marketplace.filter_tailor': 'All Tailor Shops',
    'marketplace.load_more': 'Load More',
    'marketplace.no_more': 'You have reached the end of the catalog',

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
    'header.marketplace': 'ገበያ',
    'header.favourites': 'የተቀመጡ ({count})',

    // Catalog & Filters
    'catalog.title': 'የልብስ ካታሎግ',
    'catalog.subtitle': 'በባህልና በዘመናዊ ጥበብ የተሰሩ ልዩ የልብስ ዲዛይኖችን ይመልከቱ',
    'catalog.all_categories': 'ሁሉም ምድቦች',
    'catalog.search_placeholder': 'በስም ወይም በመለያ ይፈልጉ...',
    'catalog.sort.newest': 'አዳዲስ',
    'catalog.showing_count': 'ከ{total} ውስጥ {count} ዲዛይኖች',
    'catalog.reset_filters': 'ሁሉንም አሳይ',
    'catalog.no_designs': 'ምንም ዲዛይን አልተገኘም',
    'catalog.no_designs_desc': 'የተመረጠው ምድብ ውስጥ ምንም ዲዛይን የለም። እባክዎ ሌላ ምድብ ይምረጡ።',
    'catalog.photos_count': '{count} ፎቶዎች',
    'catalog.currency': '{price} ብር',

    // Design Card & Detail
    'design.view_details': 'ዝርዝሩን ይመልከቱ',
    'design.view_360': '360° እይታ',
    'design.share': 'ዲዛይን አጋራ',
    'design.category': 'ምድብ',
    'design.tag': 'መለያ',
    'design.format': 'ቅርጸት',
    'design.format_single': 'ነጠላ ፎቶ',
    'design.format_grouped': 'ባለብዙ ፎቶ ስብስብ',
    'design.close': 'ዝጋ',

    // Share Modal
    'share.title': 'ይህን ዲዛይን ያጋሩ',
    'share.whatsapp': 'በዋትስአፕ አጋራ',
    'share.telegram': 'በቴሌግራም አጋራ',
    'share.copy': 'ሊንኩን ቅዳ',
    'share.copied': 'ሊንኩ ተቀድቷል!',

    // Trending Section
    'trending.title': 'አሁን በጣም ተፈላጊ',
    'trending.badge': 'ተፈላጊ',
    'trending.see_all': 'ሁሉንም ተፈላጊዎች ይመልከቱ',
    'trending.preview_title': 'ታዋቂ ዲዛይኖች',
    'trending.preview_link': 'ሁሉንም ተፈላጊ ዝርዝሮች ይመልከቱ',
    'error.browse_all': 'ሁሉንም ዲዛይኖች ያስሱ',

    // Favourites Page
    'favourites.title': 'የተቀመጡ ዲዛይኖች',
    'favourites.subtitle': 'እስካሁን ያከማቿቸው ተወዳጅ ዲዛይኖች',
    'favourites.empty': 'እስካሁን የተቀመጡ ዲዛይኖች የሉም',
    'favourites.empty_desc': 'ለማስቀመጥ በየትኛውም ዲዛይን ላይ የልብ ምልክቱን ይጫኑ።',
    'favourites.remove': 'አስወግድ',
    'favourites.browse': 'ገበያውን ያስሱ',

    // Marketplace Page
    'marketplace.title': 'የኢትዮጵያ የልብስ ዲዛይኖች ገበያ',
    'marketplace.subtitle': 'ከተረጋገጡ የሀገር ውስጥ ሰፊዎች የተሰሩ ሁሉንም ምርጥ ዲዛይኖች ያስሱ',
    'marketplace.all_tab': 'ሁሉም ዲዛይኖች',
    'marketplace.trending_tab': 'በጣም ተፈላጊ 🔥',
    'marketplace.filter_tailor': 'ሁሉም የሰፊ ሱቆች',
    'marketplace.load_more': 'ተጨማሪ አሳይ',
    'marketplace.no_more': 'ሁሉንም ዲዛይኖች አይተዋል',

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
    'header.marketplace': 'Gabaa',
    'header.favourites': 'Kuusaman ({count})',

    // Catalog & Filters
    'catalog.title': 'Katalogii Dizaayinii',
    'catalog.subtitle': 'Dizaayinii aadaa fi ammayyaa harkaatiin hojjetaman daawwadhaa',
    'catalog.all_categories': 'Garee Hunda',
    'catalog.search_placeholder': 'Gosa yookiin mallattoon barbaadi...',
    'catalog.sort.newest': 'Haaraa Dura',
    'catalog.showing_count': 'Dizaayinoota {total} keessaa {count} agarsiisaa jira',
    'catalog.reset_filters': 'Filtara Qulqulleessi',
    'catalog.no_designs': 'Dizaayiniin hin argamne',
    'catalog.no_designs_desc': 'Dizaayiniin filannoo keessan waliin walsimu hin jiru.',
    'catalog.photos_count': 'Suuraa {count}',
    'catalog.currency': '{price} ETB',

    // Design Card & Detail
    'design.view_details': 'Bal\'ina Ilaali',
    'design.view_360': 'Ilaalcha 360°',
    'design.share': 'Dizaayina Qoodi',
    'design.category': 'Garee',
    'design.tag': 'Mallattoo',
    'design.format': 'Bifa',
    'design.format_single': 'Suuraa Qeenxee',
    'design.format_grouped': 'Kuusaa Suuraa Hedduu',
    'design.close': 'Cufi',

    // Share Modal
    'share.title': 'Dizaayinii kana qoodaa',
    'share.whatsapp': 'WhatsApp irratti qoodi',
    'share.telegram': 'Telegram irratti qoodi',
    'share.copy': 'Geessituu Garagalchi',
    'share.copied': 'Geessituun Garagalfameera!',

    // Trending Section
    'trending.title': 'Amma Baay\'ee Barbaadama',
    'trending.badge': 'Barbaadama',
    'trending.see_all': 'Kanneen Barbaadaman Hunda Ilaali',
    'trending.preview_title': 'Dizaayinoota Beekamoo',
    'trending.preview_link': 'Hundumaa ilaali',
    'error.browse_all': 'Dizaayinoota Hunda Ilaalaa',

    // Favourites Page
    'favourites.title': 'Dizaayinoota Kuusaman',
    'favourites.subtitle': 'Dizaayinoota jaallattan kanneen kuufatan',
    'favourites.empty': 'Dizaayinni kuusamee hin jiru',
    'favourites.empty_desc': 'Kuusuuf dizaayinii kamiyyuu irratti mallattoo onnee tuqaa.',
    'favourites.remove': 'Haqi',
    'favourites.browse': 'Gabaa Daawwadhaa',

    // Marketplace Page
    'marketplace.title': 'Gabaa Dizaayinii Itoophiyaa',
    'marketplace.subtitle': 'Dizaayinoota aadaa fi ammayyaa hodhitoota mirkanaa\'an irraa daawwadhaa',
    'marketplace.all_tab': 'Dizaayinoota Hunda',
    'marketplace.trending_tab': 'Barbaadama 🔥',
    'marketplace.filter_tailor': 'Suuqiilee Hodhaa Hunda',
    'marketplace.load_more': 'Dabalata Fe\'i',
    'marketplace.no_more': 'Dizaayinoota hunda xumurtaniittu',

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
    'header.marketplace': 'Suuqa',
    'header.favourites': 'La Keydiyay ({count})',

    // Catalog & Filters
    'catalog.title': 'Buugga Naqshadaha',
    'catalog.subtitle': 'Sahmi naqshadaha dharka dhaqanka iyo casriga ah',
    'catalog.all_categories': 'Dhammaan Qaybaha',
    'catalog.search_placeholder': 'Ku raadi qaabka ama calaamadda...',
    'catalog.sort.newest': 'Kuwa Cusub Marka Hore',
    'catalog.showing_count': 'Waxaa la muujinayaa {count} ka mid ah {total} naqshadood',
    'catalog.reset_filters': 'Dib u Deji Shaandhada',
    'catalog.no_designs': 'Lama helin naqshado',
    'catalog.no_designs_desc': 'Ma jiraan naqshado u dhigma shaandhada aad dooratay.',
    'catalog.photos_count': '{count} Sawirro',
    'catalog.currency': '{price} ETB',

    // Design Card & Detail
    'design.view_details': 'Faahfaahinta Eeg',
    'design.view_360': 'Aragtida 360°',
    'design.share': 'Naqshada La Wadaag',
    'design.category': 'Qaybta',
    'design.tag': 'Calaamadda',
    'design.format': 'Qaabka',
    'design.format_single': 'Hal Sawir',
    'design.format_grouped': 'Sawirro Badan',
    'design.close': 'Xir',

    // Share Modal
    'share.title': 'La wadaag naqshadan',
    'share.whatsapp': 'Ku wadaag WhatsApp',
    'share.telegram': 'Ku wadaag Telegram',
    'share.copy': 'Koobiyeey Xiriirka',
    'share.copied': 'Xiriirinta waa la koobiyeeyay!',

    // Trending Section
    'trending.title': 'Hadda Caanka Ah',
    'trending.badge': 'Caanka Ah',
    'trending.see_all': 'Eeg Dhammaan Kuwa Caanka Ah',
    'trending.preview_title': 'Naqshadaha Caanka Ah',
    'trending.preview_link': 'Dhamaan arag',
    'error.browse_all': 'Dhammaan Naqshadaha Raadi',

    // Favourites Page
    'favourites.title': 'Naqshadaha La Keydsaday',
    'favourites.subtitle': 'Naqshadaha aad jeceshahay ee aad keydsatay',
    'favourites.empty': 'Weli naqshad la keydsaday ma jirto',
    'favourites.empty_desc': 'Taabo wadnaha naqshad kasta si aad u keydiso.',
    'favourites.remove': 'Ka saar',
    'favourites.browse': 'Sahmi Suuqa',

    // Marketplace Page
    'marketplace.title': 'Suuqa Naqshadaha Itoobiya',
    'marketplace.subtitle': 'Ka hel naqshado tayo sare leh talaamiyiinta ugu wanaagsan',
    'marketplace.all_tab': 'Dhammaan Naqshadaha',
    'marketplace.trending_tab': 'Caanka Ah 🔥',
    'marketplace.filter_tailor': 'Dhammaan Dukaamada',
    'marketplace.load_more': 'Soo saar wax badan',
    'marketplace.no_more': 'Waxaad gaartay dhammaadka buugga',

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
