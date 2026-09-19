// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appTitle => 'ጥለት ካታሎግ';

  @override
  String get language => 'ቋንቋ';

  @override
  String get english => 'English';

  @override
  String get amharic => 'አማርኛ (Amharic)';

  @override
  String get signIn => 'ግባ';

  @override
  String get signInTitle => 'የጥለት ባለሙያ መግቢያ';

  @override
  String get signInSubtitle => 'ዲዛይን ካታሎጅዎን ለማስተዳደር ይግቡ።';

  @override
  String get signingIn => 'እየገባ...';

  @override
  String get signOut => 'ውጣ';

  @override
  String get email => 'ኢሜይል';

  @override
  String get password => 'የይለፍ ቃል';

  @override
  String get tryAgain => 'እንደገና ሞክር';

  @override
  String get refreshStatus => 'ሁኔታን አድስ';

  @override
  String get pendingApproval => 'ፈቃድ በመጠባበቅ';

  @override
  String get pendingApprovalBody => 'መለያዎ የአስተዳዳሪ ፈቃድ እየጠበቀ ነው። ሲፈቀድ ይነዘርዎታል።';

  @override
  String get accountNotApproved => 'መለያ አልተፈቀደም';

  @override
  String get rejectedBody => 'የጥለት መለያዎ አልተፈቀደም። ድጋፍ ያግኙ።';

  @override
  String get uploadDesign => 'ዲዛይን ጫን';

  @override
  String get singlePhotoDesign => 'ነጠላ ፎቶ ዲዛይን';

  @override
  String get singlePhotoSubtitle => 'አንድ ፎቶ ከምድብ ጋር ጫን';

  @override
  String get bulkUpload => 'ብዙ ፎቶ ጫን';

  @override
  String get bulkUploadSubtitle => 'ብዙ ፎቶዎችን ወይም ቡድን ጫን';

  @override
  String get deleteDesign => 'ዲዛይን ሰርዝ';

  @override
  String get deleteConfirm => 'ይህን ዲዛይን ከካታሎጉ ማስወገድ እርግጠኛ ነዎት?';

  @override
  String get cancel => 'ሰርዝ';

  @override
  String get delete => 'አጥፋ';

  @override
  String get category => 'ምድብ';

  @override
  String get tagOptional => 'ምልክት / ርዕስ (አማራጭ)';

  @override
  String get addPhotos => 'ፎቶ አክል';

  @override
  String get editDesign => 'ዲዛይን አርትዕ';

  @override
  String get chooseFromGallery => 'ከጋለሪ ምረጥ';

  @override
  String get takePhoto => 'ፎቶ ምሰ';

  @override
  String get retake => 'እንደገና ምሰ';

  @override
  String get useThisPhoto => 'ይህን ፎቶ ተጠቀም';

  @override
  String get storeQrCode => 'የሱቅ QR ኮድ';

  @override
  String get copyCatalogLink => 'የካታሎግ ሊንክ ቅዳ';

  @override
  String get shareCatalogLink => 'የካታሎግ ሊንክ አጋራ';

  @override
  String get pointCameraToScan => 'ለመቃኘት ካሜራውን ያነጣጥሩ';

  @override
  String get catalogUrlCopied => 'የካታሎግ ዩአርኤል ወደ ቅንጥብ ሰሌዳ ተቀድቷል!';

  @override
  String get syncNow => 'አሁን አመሳስለ';

  @override
  String get tryAgainBtn => 'እንደገና ሞክር';

  @override
  String get uploadFirstDesign => 'የመጀመሪያ ዲዛይን ጫን';

  @override
  String get bulkUploadTitle => 'ብዙ ፎቶ ጫን';

  @override
  String get takePhotoWithCamera => 'በካሜራ ፎቶ ምሰ';

  @override
  String get back => 'ተመለስ';

  @override
  String get save => 'አስቀምጥ';

  @override
  String get saving => 'እያስቀመጠ...';

  @override
  String get uploading => 'እየጫነ...';

  @override
  String get noDesignsYet => 'ምንም ዲዛይን የለም';

  @override
  String get errorLoadingDesigns => 'ዲዛይኖችን መጫን አልተቻለም። እንደገና ይሞክሩ።';

  @override
  String get pendingSync => 'ሲንክ በመጠባበቅ';

  @override
  String batchDeleteConfirm(int count) {
    return '$count ዲዛይን(ዎች) ይሰረዙ?';
  }

  @override
  String selected(int count) {
    return '$count ተመርጧል';
  }

  @override
  String get selectPhotoRequired => 'እባክዎ የዲዛይን ፎቶ ይምረጡ።';

  @override
  String get selectCategoryRequired => 'እባክዎ ምድብ ይምረጡ';

  @override
  String get designUploadedSuccess => 'ዲዛይኑ በተሳካ ሁኔታ ተጭኗል!';

  @override
  String get optionalTagLabel => 'ተጨማሪ መለያ / ምልክት (አማራጭ)';

  @override
  String get tagHint => 'ለምሳሌ፡ የሐር ጥልፍ፣ የሰርግ፣ የወንዶች';

  @override
  String get uploadingToCatalog => 'ወደ ካታሎግ እየተጫነ...';

  @override
  String get publishDesign => 'ዲዛይን ለጥፍ';

  @override
  String selectedPhotosCount(int count) {
    return 'የተመረጡ ፎቶዎች ($count)';
  }

  @override
  String get selectPhotosFromGallery => 'ፎቶዎችን ከጋለሪ ምረጥ';

  @override
  String get uploadStructure => 'የአጫጫን ሁኔታ';

  @override
  String get separateCards => 'የተለያዩ ካርዶች';

  @override
  String get separateCardsDescription => 'እያንዳንዱ ፎቶ የራሱ ነጠላ ዲዛይን ይሆናል';

  @override
  String get groupedCarousel => 'የተጣመሩ ፎቶዎች';

  @override
  String get groupedCarouselDescription => 'ሁሉም ፎቶዎች በአንድ ተንሸራታች ዲዛይን';

  @override
  String get bulkTagLabel => 'ተጨማሪ መለያ / ምልክት (አማራጭ)';

  @override
  String get bulkTagHint => 'ለምሳሌ፡ ሀበሻ ቀሚስ፣ የ2026 ወንዶች ስብስብ';

  @override
  String get publishingToCatalog => 'ወደ ካታሎግ እየተለጠፈ...';

  @override
  String get publishMultiPhotoDesign => 'ባለብዙ ፎቶ ዲዛይን ለጥፍ';

  @override
  String publishBulkDesigns(int count) {
    return '$count ዲዛይኖችን ለጥፍ';
  }

  @override
  String get selectAtLeastOnePhoto => 'እባክዎ ቢያንስ አንድ ፎቶ ይምረጡ።';

  @override
  String get multiPhotoSuccess => 'ባለብዙ ፎቶ ዲዛይን በተሳካ ሁኔታ ተፈጥሯል!';

  @override
  String individualDesignsSuccess(int count) {
    return '$count ነጠላ ዲዛይኖች በተሳካ ሁኔታ ተፈጥረዋል!';
  }

  @override
  String get couldNotReadPhoto => 'የተመረጠውን ፎቶ ማንበብ አልተቻለም።';

  @override
  String get failedToLoadCategories => 'ምድቦችን መጫን አልተቻለም';

  @override
  String get couldNotSelectPhotos => 'ፎቶዎችን መምረጥ አልተቻለም';

  @override
  String get cameraCaptureFailed => 'ካሜራ ማንሳት አልተቻለም';

  @override
  String get cover => 'ኮቨር';

  @override
  String preparingPhotos(int count) {
    return '$count ፎቶዎችን በማዘጋጀት ላይ...';
  }

  @override
  String uploadedPhotoProgress(int current, int total, int percent) {
    return 'ፎቶ $current ከ $total ($percent%) ተጭኗል';
  }

  @override
  String uploadedDesignProgress(int current, int total, int percent) {
    return 'ዲዛይን $current ከ $total ($percent%) ተጭኗል';
  }

  @override
  String get uploadingPhotos => 'ፎቶዎችን በመጫን ላይ...';

  @override
  String successfullySynced(int count) {
    return '$count የተጫኑ ዲዛይኖች በተሳካ ሁኔታ ተመሳስለዋል!';
  }

  @override
  String get designRemoved => 'ዲዛይን ተወግዷል';

  @override
  String get failedToDeleteDesign => 'ዲዛይን ማጥፋት አልተቻለም';

  @override
  String get deleteEntireCatalog => 'ሙሉ ካታሎግ አጥፋ';

  @override
  String deleteCountDesigns(int count) {
    return '$count ዲዛይኖች አጥፋ';
  }

  @override
  String deleteCount(int count) {
    return 'አጥፋ ($count)';
  }

  @override
  String allDesignsDeleted(int count) {
    return 'ሁሉም $count ዲዛይኖች ከካታሎጉ ተወግደዋል';
  }

  @override
  String successfullyDeletedCount(int count) {
    return '$count ዲዛይኖች በተሳካ ሁኔታ ተወግደዋል';
  }

  @override
  String deletedWithFailures(int successCount, int failedCount) {
    return '$successCount ዲዛይኖች ተወግደዋል። $failedCount ማጥፋት አልተቻለም።';
  }

  @override
  String countSelected(int count) {
    return '$count ተመርጧል';
  }

  @override
  String get deselectAll => 'ሁሉንም አውርዝ';

  @override
  String get selectAll => 'ሁሉንም ምረጥ';

  @override
  String get deleteSelected => 'የተመረጡትን አጥፋ';

  @override
  String get selectDesignsToDelete => 'ለማጥፋት ዲዛይኖችን ምረጡ';

  @override
  String get approved => 'ተፈቅዷል';

  @override
  String get selectDesignsToDeleteBottom => 'ለማጥፋት ዲዛይኖችን ምረጡ';

  @override
  String countOfTotalSelected(int count, int total) {
    return '$count ከ $total ተመርጧል';
  }

  @override
  String uploadsPending(int count) {
    return '$count ጫን በኦፍላይን ወረፋ በመጠባበቅ ነው።';
  }

  @override
  String get designUpdatedSuccessfully => 'ዲዛይን በተሳካ ሁኔታ ተስተካክሏል';

  @override
  String get appTagline => 'የእርስዎ ፋሽን። የእርስዎ ካታሎግ።';

  @override
  String get contactAdminReset => 'የይለፍ ቃል ለመቀየር አስተዳዳሪውን ያነጋግሩ';

  @override
  String get connectionError =>
      'ከበይነመረብ ጋር መገናኘት አልተቻለም። እባክዎ ግንኙነትዎን ያረጋግጡና እንደገና ይሞክሩ።';

  @override
  String get invalidCredentials =>
      'የተሳሳተ ኢሜይል ወይም የይለፍ ቃል ነው። እባክዎ እንደገና ይሞክሩ።';

  @override
  String get serverError =>
      'አገልጋዩ ለጊዜው አልተገኘም። እባክዎ ከጥቂት ደቂቃዎች በኋላ እንደገና ይሞክሩ።';

  @override
  String get genericError => 'ስህተት ተፈጥሯል። እባክዎ እንደገና ይሞክሩ።';
}
